# 
# # App Index
#

# Our App variable is global, defined in `./app/core.coffee`
{MainView} = AppAid.Views

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

  # 
  new AppAid.Views.InstallView @options.vmName,
    @options.targetApp.vmName,
    @

