# 
# # App Core
#

# A few global vars to make sense of the world.
USER      = KD.nick()
HOME      = "/home/#{USER}"

# Define our App Object 
#
# Note that we are naming this, rather than the generic `App` that i like,
# because we are sharing context with whatever the loaded app is. Long story
# short, who knows what is loaded in our context. We want to protect our
# variables so our App doesn't explode.
AppAid =
  Core      : {}
  Utilities : {}
  Views     : {}
  Settings  :
    defaultIcon : "https://koding.com/images/default.app.thumb.png"


