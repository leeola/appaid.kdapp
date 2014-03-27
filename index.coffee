# 
# # App Index
#

# Our App variable is global, defined in `./app/core.coffee`
{MainView} = AppAid.Views

# AppControllers are new to me, so this is undocumented/unknown.
class AppaidController extends AppController
  constructor:(options = {}, data)->
    options.view    = new MainView
    options.appInfo =
      name : "Appaid"
      type : "application"

    super options, data

do ->
  if appView?
    console.log "AppAid Loaded into id:#{appView.id}"

    # Our MainView instance, which is assigned in `./app/views.coffee`.
    mainView = new MainView()
    appView.addSubView mainView
  else
    console.log "Appaid Loaded"

    KD.registerAppClass AppaidController,
      name     : "Appaid"
      routes   :
        "/:name?/Appaid" : null
        "/:name?/leeolayvar/Apps/Appaid" : null
      dockPath : "/leeolayvar/Apps/Appaid"
      behavior : "application"
