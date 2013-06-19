
report = (message) ->
  throw new Error "You're slouching: #{message} :("

with_each_attr = (thing, fn) ->
  if _.isObject(thing)
    fn key, thing[key] for key of thing
  else
    fn thing
  
window.Slouch =
  attributeKeys: (snapshot = @defaults) ->
    # Bind reference to original methods in outer scope.
    _get = @get
    _set = @set

    @get = (key, options...) ->
      unless key of snapshot
        report "Attempting to `get()` with unknown key '#{key}'."
      _get.call this, key, options...
    @set = (arg1, options...) ->
      with_each_attr arg1, (key) ->
        unless key of snapshot
          report "Attempting to `set()` with unknown key '#{arg1}'."
      _set.call this, arg1, options...

  attributeTypes: (snapshot = @defaults) ->
    _set = @set
    @set = (arg1, options...) ->
      deserializers = @deserializers
      with_each_attr arg1, (key, associated_value) ->
        ref = snapshot[arg1]
        value = associated_value or options[0]
        if ref? and ref.constructor isnt value.constructor
          deserializer = _.compact(des.test(value) for des in deserializers)[0]
          if deserializer?
            new_value = deserializer(value)
            if associated_value?
              arg1[key] = new_value
            else
              options[0] = new_value
          else if ref.constructor? and not
              _.isArray(ref) and
              ref.constructor isnt Object and not
              _.isFunction(ref) and not
              _.isString(ref) and not
              _.isNumber(ref) and not
              _.isBoolean(ref) and not
              _.isDate(ref) and not
              _.isRegExp(ref)
            new_value = new ref.constructor(value)
            if associated_value?
              arg1[key] = new_value
            else
              options[0] = new_value
          else
            report """
              Attempting to `set()` with value of type
              '#{value.constructor}' is not allowed for key '#{arg1}'.
              """
      _set.call this, arg1, options...

class Slouch.Model extends Backbone.Model
  constructor: (args...) ->
    super
    fn.apply this, args for fn in [
        Slouch.attributeKeys
        Slouch.attributeTypes
    ]
  toJSON: ->
    _serializeNestedData = (data) ->
      for own key, value of data
        if _.isFunction(value?.toJSON)
          data[key] = value.toJSON()
      data
    _serializeNestedData(super)




