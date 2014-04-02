#
# # Appaid Controllers
#
{MainView} = require './views'




class AppaidController extends AppController
  constructor:(options = {}, data)->
    options.view    = new MainView
    options.appInfo =
      name : "Appaid"
      type : "application"

    super options, data



class AppWatcher extends FSWatcher
  constructor: (options) ->
    options.throttle ?= 3000
    super

  fileChanged: (change) ->
    @throttle @emit 'SourceChanged', change.file.name, change.file.fullPath

  throttle: (callback) -> KD.utils.throttle @getOption('throttle'), callback




exports.AppaidController = AppaidController
exports.AppWatcher       = AppWatcher
