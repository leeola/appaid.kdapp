# 
# # Utilities
#
{Utilities} = AppAid



# # Notify
#
Utilities.notify = (message, options={})->
  if typeof message is 'string'
    options.title = message
  else
    options = message
  new KDNotificationView options


