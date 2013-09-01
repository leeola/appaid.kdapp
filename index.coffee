# 
# # App Index
#

# Our App variable is global, defined in `./app/core.coffee`
{MainView} = AppAid.Views

do ->
  console.log "AppAid Loaded into id:#{appView.id}"

  # Our MainView instance, which is assigned in `./app/views.coffee`.
  mainView = new MainView()
  appView.addSubView mainView
