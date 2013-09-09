# 
# # Install
#
# **!INCOMPLETE!**: This is way incomplete, i'm just merging it in for
# the basic done features
#
# InstallView attempts to be a generic blocking (or non-blocking) install
# view.
#
# Simple instantiate on a view, and if it detects installation requirements
# that are not met, it will modify the current view structure to display
# helpful information while it handles the installation.
#
# The intended scope, is to support any packager, but currently the supported
# packages are:
#
# - NPM
#




# ## InstallView
#
class InstallView extends KDView
  notify = (message, options={})->
    if typeof message is 'string'
      options.title = message
    else
      options = message
    new KDNotificationView options

  constructor: (options={}) ->
    options.npm ?= false
    options.hideSiblings ?= true
    options.autoDestroy ?= true
    super options

    @vmController = KD.getSingleton 'vmController'
    @manifest = KD.getAppOptions @options.appName

    @npmCheck (err, installed) =>
      if err? then return throw err
      if not installed
        notify "#{@options.appName} not installed, installing..."
        @npmInstall (err) =>
          if err? then return throw err
          notify "#{@options.appName} installed!"
  

  # ### npmCheck
  # Check the current install. True if installed, false if need install/update
  npmCheck: (callback=->)->
    @vmController.run
      withArgs  : "cd #{@manifest.path}; npm --silent outdated"
      (err, res) =>
        if err? then return callback err
        if res is "\n"
          callback null, true
        else
          callback null, false


  # ### npmInstall
  # 
  npmInstall: (callback=->) ->
    @vmController.run
      withArgs  : "cd #{@manifest.path}; npm --silent install"
      (err, res) =>
        if err? then return callback err
        # Currently not handling npm response at all, hoping it succeeds.
        # Obviously this will need to be improved later.
        callback null

