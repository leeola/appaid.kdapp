# 
# # Utilities
#




# # Notify
#
# This is rather hacky at the moment, and should likely be a view of it's own
# in the near future.
notify = (message, options={})->
  if typeof message is 'string'
    options.title = message
  else
    options = message
  new KDNotificationView options



exports.notify = notify
