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
          if appname is 'appaid.kdapp' then continue
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

    barSplit = new KDSplitView
      type      : 'vertical'
      resizable : false
      sizes     : ['30%', '40%', '30%']
      views     : [barHeader, appSplit, barCompileBtn]

    @previewView = new KDView()

    @addSubView new KDSplitView
      type      : 'horizontal'
      resizable : false
      sizes     : ['40px', '90%']
      views     : [barSplit, @previewView]

    # Let the hacks begin.
    _appView = window.appView
    window.appView = @previewView

    # And finally, add our placeholder view.
    @previewView.addSubView new AppAid.Views.PreviewDefault()


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
    console.log "Wtf?"
    console.log @options.targetApp
    {
      appName
      vmName
    } = @options.targetApp
    notify "Loading '#{appName}'..."

    @appIndexHelper = FSHelper.createFileFromPath(
      "[#{vmName}]~/Applications/#{appName}/index.js"
    )
    @appIndexHelper.exists (err, exists) =>
      if exists
        @previewApp callback
      else
        @compileApp (err) =>
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




# ## Preview Default
#
# The view that is loaded in the previewView by default.
class AppAid.Views.PreviewDefault extends JView
  constructor: -> super

  pistachio: ->
    """
    <h1 style="font-size: 90px; text-align: center; margin-top: 80px;">
      Your App Here
    </h1>
    """


