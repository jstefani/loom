# 
# blank.coffee: "blank" player module
# 
# Copyright 2013 Adam Florin
# 

class Module.Blank
  Module::register @
  
  processGesture: (gesture) ->
    logger.debug "Processing gesture..."
    # TEMP: double up
    gesture.events.push gesture.events[0]
    return gesture
