# 
# # Appaid Entry
#
# The main entry point for our app.
#
{AppaidController} = require './app/controllers'
{MainView}         = require './app/views'




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
