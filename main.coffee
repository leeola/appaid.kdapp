# 
# # App Index
#
{MainView} = require './app/views'

do ->
  console.log "AppAid Loaded into id:#{appView.id}"

  # I don't think this is the proper way to enable binds. We're binding to
  # the global state, which is probably not what we want. Currently i am not
  # aware of a better way to bind the keys though.
  Mousetrap.bind ['command+enter', 'ctrl+enter'],
    -> KD.getSingleton('mainView').toggleFullscreen()

  # Our MainView instance, which is assigned in `./app/views.coffee`.
  mainView = new MainView()
  appView.addSubView mainView

  # If we're running appAid in AppAid, tell it we loaded. Meta!
  if appAid? then appAid.loaded()
