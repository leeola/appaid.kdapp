# 
# # App Views
#
core          = require './core'
isolated_eval = require './isolated_eval'
{notify}      = require './utils'




USER      = KD.nick()
HOME      = "/home/#{USER}"




# ## MainView
#
class MainView extends KDView
  constructor: (@options={})->
    @options.cssClass ?= "appaid"
    @options.vmName ?= KD.singletons.vmController.defaultVmName

    # We used to use `KD.singletons.appManager.getFrontAppManifest()` to get
    # the manifest, but it seems during App Initialization that the "in front"
    # app is not entirely known. So, we're grabbing our app manifest manually.
    @options.manifest ?= KD.getAppOptions('AppAid')
    @options.fsHelperPath = "[#{@options.vmName}]#{@options.manifest.path}"

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
    

    # #### App Test View Definitions
    testShowTgl = new KDToggleButton
      states: [
        {
          title     : 'Show Tests'
          callback  : =>
            testShowTgl.setState 'Hide Tests'
        }
        {
          title     : 'Hide Tests'
          callback  : =>
            testShowTgl.setState 'Show Tests'
        }
      ]
    testShowTgl.setClass 'float-left'

    testBtn = new KDButtonView
      title     : 'Run Tests'
      callback  : =>
        console.log 'Running tests'
    testBtn.setClass 'float-left'
    testBtn.hide() # Note that we hide this for continuous toggle, not app load

    @testContinuous = new KDMultipleChoice
      labels        : ['Continuous', 'Manual']
      defaultValue  : 'Continuous'
      callback      : (state) =>
        if state is 'Continuous'
          testBtn.hide()
        else
          testBtn.show()
    @testContinuous.setClass 'float-left'


    # #### App Split Section
    # Our app split section defines the views for the app selection splitview.
    appClearBtn = new KDButtonView
      title     : 'Clear App'
      callback  : =>
        console.log 'Clearing App'
        @previewView.destroySubViews()
        @appCssStyle.html ''
        @previewView.addSubView @defaultPreview

        appClearBtn.hide()
        @appAutoCompile.hide()
        appCompileBtn.hide()
        
        @options.targetApp.appName = @options.targetApp.manifest = null
        notify 'App Cleared.'
    appClearBtn.setClass 'float-right'


    appSelectBox = new KDSelectBox
      label: new KDLabelView
        title: 'App:'
    appSelectBox.setClass 'float-right'

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
        appName = @options.targetApp.appName = appSelectBox.getValue()
        @loadApp (err) =>
          if err?
            # Remove the manifest so that other buttons know it didn't load
            # fully or properly.
            @options.targetApp.manifest = null
            new KDModalView
              title     : "Error during Load: #{err.name}"
              width     : 700 # Pixels
              content   :
                """
                <div class="modalformline">
                <p>
                  There has been an error compiling #{appName}.
                </p>
                <pre>#{err.message}</pre>
                <pre>#{err.stack}</pre>
                </div>
                """
            return
          appClearBtn.show()
          @appAutoCompile.show()
          appCompileBtn.show()
          @testContinuous.show()
          testShowTgl.show()
    appLoadBtn.setClass 'float-right'

    @appAutoCompile = new KDMultipleChoice
      labels        : ['Auto', 'Manual']
      defaultValue  : if @autoCompile then 'Auto' else 'Manual'
      callback      : (state) =>
        @autoCompile = if state is 'Auto' then true  else false
        if @autoCompile and not @watching
          notify 'Starting watch..'
          @watchCompile()
    @appAutoCompile.setClass 'float-right'

    appCompileBtn = new KDButtonView
      title     : 'Compile and Preview'
      callback  : =>
        {appName} = @options.targetApp
        bailErr = (err) ->
          new KDModalView
            title     : "Error during Compile: #{err.name}"
            width     : 700 # Pixels
            content   :
              """
              <div class="modalformline">
              <p>
                There has been an error compiling #{appName}.
              </p>
              <pre>#{err.message}</pre>
              <pre>#{err.stack}</pre>
              </div>
              """

        @compileApp (err) =>
          if err? then bailErr(err) else @previewCss (err) =>
            if err? then bailErr(err) else @previewApp ->
              notify 'Success!', type: 'tray'
    appCompileBtn.setClass 'float-right'

    barView = new KDView
      cssClass  : 'appaid-bar inner-header'
    # Due to the float, these are ordered backwards.
    barView.addSubView appCompileBtn
    barView.addSubView @appAutoCompile
    barView.addSubView appLoadBtn
    barView.addSubView appSelectBox
    barView.addSubView appClearBtn
    # and now our tests
    barView.addSubView testShowTgl
    barView.addSubView @testContinuous
    barView.addSubView testBtn

    # Hide our loaded-only app buttons.
    appClearBtn.hide()
    appCompileBtn.hide()
    @appAutoCompile.hide()
    @testContinuous.hide()
    testShowTgl.hide()

    @previewView = new KDView()
    # Our CSS DOM Object is used to inject loaded css into our preview.
    @appCssStyle = $ "<style scoped></style>"
    @previewView.domElement.prepend @appCssStyle

    @addSubView new KDSplitView
      type      : 'horizontal'
      resizable : false
      sizes     : ['40px', '100%']
      views     : [barView, @previewView]

    # And finally, add our placeholder view.
    @defaultPreview = new PreviewDefault()
    @previewView.addSubView @defaultPreview
  
    
  # ### App Loaded
  #
  # Called from an app that has been programmed to integrate with AppAid
  appLoaded: =>
    console.log 'App Loaded! Yay!'


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
      @appAutoCompile.setValue 'Manual'
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

        if coFiles or cssFiles
          notify "Change detected",
            type: 'tray'
            duration: 4000
            closeManually: true


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
    note = notify "Compiling '#{appName}'...",
      type          : 'tray'
      duration      : 60000
      closeManually : false

    # Bit of a hack, but we're just forcing the kdc-plus usage if plus options
    # are detected.
    if @options.manifest.plus?
      compiler  = 'kdc-plus compile'
    else
      compiler  = 'kdc'

    KD.singletons.vmController.run
      vmName    : vmName
      withArgs  : "#{compiler} ~/Applications/#{appName}"
      (err, res) ->
        note.destroy()
        if err?
          # Errors from KDC are handled oddly. The error object is the return
          # code from the process, and the response is the actual error
          # message. With this information, we want to change our error
          # object to be more informative.
          err.stack = res
          # Note that the following line is very hacky. We may want to improve
          # this .. or at least make this more robust.
          [err.name, err.message] = res.split('\n')[0].split ': '
          callback err

        notify "Compile completed", type: 'tray'
        # No need to return the success response.
        callback null

  # ### Load App
  #
  loadApp: (callback=->) ->
    {
      appName
      vmName
    } = @options.targetApp
    note = notify "Loading '#{appName}'...",
      type          : 'tray'
      duration      : 60000
      closeManually : false

    appHelperDir = "[#{vmName}]~/Applications/#{appName}"
    @options.targetApp.helperDir = appHelperDir

    appManifestHelper = FSHelper.createFileFromPath(
      "#{appHelperDir}/manifest.json")
    appManifestHelper.fetchContents (err, res) =>
      note.destroy()
      if err? then return callback err
      try
        @options.targetApp.manifest = JSON.parse res
      catch err
        return callback err

      notify "Load completed", type: 'tray'

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
    manifestAppName = @options.targetApp.manifest.name
    note = notify "Previewing '#{appName}'...",
      type          : 'tray'
      duration      : 60000
      closeManually : false

    @appIndexHelper.fetchContents (err, res) =>
      note.destroy()
      if err? then return callback err

      # By destroying the subviews, we ensure (or try to) that the newly
      # compiled code is applied to a fresh view.
      @previewView.destroySubViews()

      # Our appAid object is passed in to allow the child application to signal
      # when it is done loading. Allowing us to start tests, etc.
      appAid =
        view: @previewView
        loaded: @appLoaded

      # We're just using a simple eval on the loaded JS code, 
      # this may be a bit unsafe, but it should be this clients
      # code anyway.
      try
        isolated_eval res, @previewView, appAid
      catch e
        new KDModalView
          title     : "#{manifestAppName} Error: #{e.name}"
          width     : 700 # Pixels
          content   :
            """
            <div class="modalformline">
            <p>
              There has been a runtime error of #{appName}.
            </p>
            <pre>#{e.message}</pre>
            <pre>#{e.stack}</pre>
            </div>
            """

      notify "Preview completed", type: 'tray'

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
    console.log 'Previewing CSS...'

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
class PreviewDefault extends JView
  constructor: -> super

  pistachio: ->
    """
    <div style="text-align: center; margin-top: 80px;">
      <h1 style="font-size: 90px; margin: 20px 0;">
        Load Your App
      </h1>
      <p style="font-size: 25px;">
        Select your app from the list above, then click Load.
      </p>
    </div>
    """




exports.MainView      = MainView
exports.PreviewDefult = PreviewDefault
