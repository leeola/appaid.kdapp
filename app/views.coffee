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

    #@indexjsHelper
    
    barHeader = new KDHeaderView
      title     : @options.manifest.description
      type      : 'medium'

    barCompileBtn = new KDButtonView
      title     : 'Compile and Preview'
      callback  : =>
        @compileApp => @previewApp -> new KDNotification title: 'Success!'

    barSplit = new KDSplitView
      type      : 'vertical'
      resizable : false
      sizes     : ['40%', '30%', '30%']
      views     : [barHeader, null, barCompileBtn]

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

  pistachio: ->
    """
    <h1 style="font-size: 90px; text-align: center; margin-top: 80px;">
      Your App Here
    </h1>
    """


