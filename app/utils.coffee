# 
# # Utilities
#



# # Notify
#
notify = (message, options={})->
  if typeof message is 'string'
    options.title = message
  else
    options = message
  new KDNotificationView options


exports.notify  = notify
