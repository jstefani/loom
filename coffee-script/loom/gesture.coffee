# 
# gesture.coffee: A gesture is a collection of MIDI Events, as influenced by
# certain applicable Modules.
# 
# Copyright 2013 Adam Florin
# 

class Gesture
  mixin @, Serializable
  @::serialized "meter", "deviceId", "afterTime", "events", "activatedModules"

  DEFAULT_METER: 2

  # Ur-gesture
  # 
  constructor: (gestureData) ->
    @deserialize gestureData,
      events: (data) -> new (Loom::Events[data.loadClass]) data
    @meter ?= @DEFAULT_METER
    @events ?= []
    if @events.length == 0
      @events.push new (Loom::Events["Note"])
        at: @nextDownbeat(@afterTime)
        duration: @meter
        deviceId: @deviceId

  # Generate UI events for module patchers.
  # 
  allEvents: ->
    uiEvents = []
    for module in @activatedModules
      uiEvents.push module.activated @startAt()
      for name, parameter of module.parameters when parameter.activated?
        uiEvents.push parameter.activated @startAt()
    return @events.concat uiEvents

  # Gesture starts when its first event starts.
  # 
  startAt: ->
    Math.min (event.at for event in @events)...

  # Gesture ends when its last event ends.
  # 
  endAt: ->
    Math.max (event.endAt() for event in @events)...

  # Find next downbeat (relative to internal meter).
  # 
  nextDownbeat: (time) ->
    Math.ceil(time / @meter) * @meter
