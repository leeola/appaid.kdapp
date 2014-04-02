# 
# # Isolated Eval
#
# Because appaid is evaling the users own code, we don't really have to worry
# about security, but we do have to worry about the users code stomping on our
# applications context. So, this module serves as a top level closure,
# ensuring that the App does not get violated by user code.. well, as much
# as we can.
#
# ## Why the module though, and not simply a closure?
# 
# Well, a closure works great for variables escaping into the parent context,
# but that won't prevent the parent context from slipping in. Of course, if it
# slips in, then it can leak out.
#
# So, this module is put at the root closure scope by our commonjs library, and
# this way nothing leaks in from Appaid into your app. Wee!
#




module.exports = (code, appView) ->
  eval code

