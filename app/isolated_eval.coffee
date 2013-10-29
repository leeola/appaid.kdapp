# 
# # Isolated Eval
#
# Because appaid is evaling the users own code, we don't really have to worry
# about security, but we do have to worry about the users code stomping on our
# applications context. So, this module serves as a top level closure,
# ensuring that the App does not get violated by user code.. well, as much
# as we can.
#




module.exports = (code, appView) ->
  eval code
