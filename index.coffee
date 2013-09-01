# 
# # App Index
#

# Our App variable is global, defined in `./app/core.coffee`
{MainView} = AppAid.Views

do ->
  #Enable Logs for Development
  KD.enableLogs()
  console.log "AppAid Loaded"
  console.log "Loading into ID:#{appView.id}"

  # Our MainView instance, which is assigned in `./app/views.coffee`.
  mainView = new MainView()
  appView.addSubView mainView
