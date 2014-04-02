#
# # Appaid Controllers
#
{MainView} = require './views'




# ## AppaidController
#
# The main controller for this app. I'm not clear on this usage yet,
# since it's new with "GreenKD"
class AppaidController extends AppController
  constructor:(options = {}, data)->
    options.view    = new MainView
    options.appInfo =
      name : "Appaid"
      type : "application"

    super options, data



# ## AppWatcher
#
# This class simply watches a given directory and responds back with the
# changed info.
class AppWatcher extends FSWatcher
  constructor: (options) ->
    options.throttle ?= 3000
    super

  fileChanged: (change) ->
    @throttle @emit 'SourceChanged', change.file.name, change.file.fullPath

  throttle: (callback) -> KD.utils.throttle @getOption('throttle'), callback




exports.AppaidController = AppaidController
exports.AppWatcher       = AppWatcher
