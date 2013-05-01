# 
# module.coffee: base class for modules
# 
# Copyright 2013 Adam Florin
# 

class Module extends Persistence
  
  # Reduce deviation to contain Gaussian random values.
  # 
  @::DEVIATION_REDUCE = 0.2

  # 
  # 
  constructor: (@id, moduleData, args) ->
    {@playerId, @probability, @mute, @parameters} = moduleData
    {@player} = args if args
    @probability ?= 1.0
    @mute ?= 0
    @parameters ?= {}

  # Serialize object data to be passed into constructor by Persistence later.
  # 
  # loadClass tells Persistence
  # 
  serialize: ->
    id: @id
    loadClass: @constructor.name
    playerId: @playerId
    probability: @probability
    mute: @mute
    value: @value
    parameters: @parameters

  # Set module value.
  # 
  # Anything with a name of the form patcher::object is a parameter. The rest
  # are instance properties.
  # 
  set: (name, value) ->
    [all, major, separator, minor] = name.match(/([^:]*)(::)?([^:]*)/)
    if separator?
      @parameters[major] ?= {}
      @parameters[major][minor] = value
    else
      @[name] = value


  # Override Persistence's classKey, as Module is subclassable.
  # 
  classKey: -> "module"

  # Overwrite Persistence for convenience, as we always want the appropriate
  # subclass
  # 
  load: (id, constructorArgs) -> super id, Loom::moduleClass, constructorArgs

  # 
  # 
  player: -> Loom::player @playerId

  # Generate a random value based on parameter input.
  # 
  generateValue: (parameterName) ->
    parameter = @parameters[parameterName] || @defaultParameter()
    nextValue = Probability::gaussian(
      parameter.mean,
      parameter.deviation * @DEVIATION_REDUCE)
    nextValue = Probability::constrain nextValue
    parameter.generatedValue = Probability::applyInertia(
      (@lastValue() || nextValue),
      nextValue,
      parameter.inertia)

  # Get last output value from player's gesture history.
  # 
  lastValue: (parameterName) ->
    for gestureIndex in [Math.max(@player.pastGestures.length-1, 0)..0]
      if (gesture = @player.pastGestures[gestureIndex])?
        thisModule = module for module in gesture.activatedModules when module.id is @id
        return thisModule.parameters[parameterName]?.generatedValue if thisModule?

  # Failsafe default parameter.
  # 
  defaultParameter: ->
    mean: 0.5, deviation: 0, inertia: 0
