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
    @options.manifest ?= KD.singletons.appManager.getFrontAppManifest()
    super @options
    
    barHeader = new KDHeaderView
      title     : 'App Aid'

    barCompileBtn = new KDButtonView
      title     : 'Compile and Preview'
      callback  : =>
        @compileApp => @previewApp -> new KDNotification title: 'Success!'

    barSplit = new KDSplitView
      type      : 'vertical'
      resizable : false
      sizes     : ['30%', '40%', '30%']
      views     : [barHeader, null, barCompileBtn]

    @previewView = new KDView()

    console.log 'Wut?'

    @addSubView barSplit
    @addSubView @previewView

    # Let the hacks begin.
    _appView = window.appView
    window.appView = @previewView


  # ### Compile App
  #
  compileApp: (callback) ->
    new KDNotificationView
      title: 'Compiling...'

    KD.singletons.vmController.run
      vmName    : @options.vmName
      withArgs  : "kdc #{Settings.APP_DIR}"
      (err, res) ->
        # Currently ignoring the response of kdc.
        callback err


  # ### Preview App
  #
  previewApp: ->
    new KDNotificationView
      title: 'Loading preview...'

    @indexjsHelper.fetchContents (err, res) =>
      if err? then new KDNotificationView title: err.message
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

  pistachio: -> "Hello!"


