# 
# # App Views
#
{Settings}  = AppAid
{notify}    = AppAid.Utilities




# ## MainView
#
class AppAid.Views.MainView extends KDView
  constructor: (@options={})->
    @options.cssClass ?= "appaid-mainview"
    @options.vmName ?= KD.singletons.vmController.defaultVmName

    # We used to use `KD.singletons.appManager.getFrontAppManifest()` to get
    # the manifest, but it seems during App Initialization that the "in front"
    # app is not entirely known. So, we're grabbing our app manifest manually.
    @options.manifest ?= KD.getAppOptions('AppAid')

    super @options

    # As described above, getting the manifest has proven "interesting"
    # in the past. So, i check now, just to be safe.
    if not @options.manifest?
      notify 'Manifest could not load, halting app.'
      return

    @options.targetApp = {}
    # Soon we'll offer targetted VMs, but for now default it.
    @options.targetApp.vmName = @options.vmName


    # Autocompile States.
    # @watching means that the process is currently running.
    @watching = false
    # @autoCompile means that we want to auto compile.
    @autoCompile = false



    # #### App Split Section
    # Our app split section defines the views for the app selection splitview.
    appSelectBox = new KDSelectBox
      label: new KDLabelView
        title: 'App:'

    KD.singletons.vmController.run
      vmName    : @options.vmName
      withArgs  : "ls ~/Applications"
      (err, res) =>
        if err? then notify err.message; return
        kdAppNames = res.split('\n')[...-1]
        kdAppNameOpt = []
        for appname in kdAppNames
          #if appname is 'appaid.kdapp' then continue
          kdAppNameOpt.push {title: appname, value: appname}
        appSelectBox.setSelectOptions kdAppNameOpt
        # Don't forget to add our targetApp Default
        @options.targetApp.appName = appSelectBox.getValue()

    appLoadBtn = new KDButtonView
      title     : 'Load App'
      callback  : =>
        @options.targetApp.appName = appSelectBox.getValue()
        @loadApp (err) ->
          if err?
            notify "Error during Load: #{err.message}"
        

    appSplit = new KDSplitView
      type      : 'vertical'
      resizable : false
      sizes     : ['50%', '50%']
      views     : [appSelectBox, appLoadBtn]

    
    # #### Bar Split Section
    # The bar is the top bar split thing.
    barHeader = new KDHeaderView
      title     : @options.manifest.description
      type      : 'medium'

    barCompileBtn = new KDButtonView
      title     : 'Compile and Preview'
      callback  : =>
        @compileApp => @previewApp -> notify 'Success!'

    @barAutoCompile = new KDMultipleChoice
      labels        : ['Auto', 'Manual']
      defaultValue  : if @autoCompile then 'Auto' else 'Manual'
      callback      : (state) =>
        if not @options.targetApp.manifest?
          notify 'No App Loaded, Please Load App First'
          #This blows up Koding, not sure why.
          #@barAutoCompile.setValue if state is 'Auto' then 'Manual' else 'Auto'
          return

        @autoCompile = if state is 'Auto' then true  else false
        if @autoCompile and not @watching
          notify 'Starting watch..'
          @watchCompile()
          

    barSplit = new KDSplitView
      type      : 'vertical'
      resizable : false
      sizes     : ['30%', '40%', '15%', '15%']
      views     : [barHeader, appSplit, @barAutoCompile, barCompileBtn]

    @previewView = new KDView()
    # Our CSS DOM Object is used to inject loaded css into our preview.
    @appCssStyle = $ "<style scoped></style>"
    @previewView.domElement.prepend @appCssStyle

    @addSubView new KDSplitView
      type      : 'horizontal'
      resizable : false
      sizes     : ['40px', '90%']
      views     : [barSplit, @previewView]

    # And finally, add our placeholder view.
    @previewView.addSubView new AppAid.Views.PreviewDefault()



  # ### Watch Compile
  #
  watchCompile: ->
    {
      appName
      vmName
    } = @options.targetApp
    thisAppPath = @options.manifest.path

    errBail = (err) =>
      notify "Error: #{err.message}"
      @barAutoCompile.setValue 'Manual'
      @autoCompile = false

    if @waching then return
    @watching = true
    
    console.log 'Executing watch..'
    KD.singletons.vmController.run
      vmName    : vmName
      withArgs  : "#{thisAppPath}/bin/watch.js ~/Applications/#{appName}"
      (err, res) =>
        @watching = false
        if err? then return errBail err

        coFiles = /\.coffee/.test res
        cssFiles = /\.css/.test res
        console.log('Watch returned!', coFiles, cssFiles, res)

        if not KD.singletons.appManager.get(@options.manifest.name)?
          console.log 'Watch returned, but app is closed. Exiting.'
          return
        if not @autoCompile then return

        checkPreviewApp = =>
          console.log 'check preview'
          if not coFiles then return @watchCompile()
          @previewApp (err) =>
            if err? then return errBail err
            @watchCompile()

        checkPreviewCss = =>
          console.log 'check css'
          if not cssFiles then return checkPreviewApp()
          @previewCss (err) ->
            if err? then return errBail err
            checkPreviewApp()

        do checkCompileApp = =>
          console.log 'check compile'
          if not coFiles then return checkPreviewCss()
          @compileApp (err) ->
            if err? then return errBail err
            checkPreviewCss()



  # ### Compile App
  #
  compileApp: (callback=->) ->
    {
      appName
      vmName
    } = @options.targetApp
    notify "Compiling '#{appName}'..."

    KD.singletons.vmController.run
      vmName    : vmName
      withArgs  : "kdc ~/Applications/#{appName}"
      (err, res) ->
        # Currently ignoring the response of kdc.
        callback err

  # ### Load App
  #
  loadApp: (callback=->) ->
    {
      appName
      vmName
    } = @options.targetApp
    notify "Loading '#{appName}'..."
    
    appHelperDir = "[#{vmName}]~/Applications/#{appName}"
    @options.targetApp.helperDir = appHelperDir

    appManifestHelper = FSHelper.createFileFromPath(
      "#{appHelperDir}/manifest.json")
    appManifestHelper.fetchContents (err, res) =>
      if err? then return callback err
      try
        @options.targetApp.manifest = JSON.parse res
      catch err
        return callback err

      @appIndexHelper = FSHelper.createFileFromPath "#{appHelperDir}/index.js"
      @appIndexHelper.exists (err, exists) =>
        if exists
          @previewCss (err) =>
            if err? then return callback err
            @previewApp callback
        else
          @compileApp (err) =>
            if err? then return callback err
            @previewCss (err) =>
              if err? then return callback err
              @previewApp callback


  # ### Preview App
  #
  previewApp: (callback=->) ->
    {
      appName
      vmName
    } = @options.targetApp
    notify "Previewing '#{appName}'..."

    # Let the hacks begin.
    if appView?.id isnt @previewView.id
      console.log "Overwriting local appView. Previous id:#{@parent.id}, "+
        "new id:#{@previewView.id}"
      appView = @previewView
    
    @appIndexHelper.fetchContents (err, res) =>
      if err? then return callback err
      console.log 'Fetched! '+ res?.length

      # By destroying the subviews, we ensure (or try to) that the newly
      # compiled code is applied to a fresh view.
      @previewView.destroySubViews()
      
      # We're just using a simple eval on the loaded JS code, 
      # this may be a bit unsafe, but it should be this clients
      # code anyway.
      eval res

      callback null

  # ### Preview CSS
  #
  previewCss: (callback=->) ->
    {
      appName
      vmName
      helperDir
    } = @options.targetApp
    {stylesheets} = @options.targetApp.manifest.source
    notify 'Previewing CSS...'

    if not stylesheets? or stylesheets.length is 0 then return callback null

    concatedCss = ''
    do concatCss = (index=0) =>
      stylesheet = stylesheets[index]

      if not stylesheet?
        @appCssStyle.html concatedCss
        return callback null

      stylesheetPath = "#{helperDir}/#{stylesheet}"
      stylesheetHelper = FSHelper.createFileFromPath stylesheetPath
      stylesheetHelper.fetchContents (err, res) ->
        if err? then return callback err
        concatedCss += res
        concatCss ++index
      
    




# ## Preview Default
#
# The view that is loaded in the previewView by default.
class AppAid.Views.PreviewDefault extends JView
  constructor: -> super

  pistachio: ->
    """
    <h1 style="font-size: 90px; text-align: center; margin-top: 80px;">
      Load your App
    </h1>
    """


