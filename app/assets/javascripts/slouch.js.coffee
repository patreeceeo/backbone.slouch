# TODO write tests for:
#   inheritance w/ and w/o coffeescript
#   not attempting to use constructors for 'primative' types
#
report = (message) ->
  throw new Error "You're slouching: #{message} :("

with_each_attr = (thing, fn) ->
  if _.isObject(thing)
    fn key, thing[key] for key of thing
  else
    fn thing

# Aggregate defaults up the prototype chain in `snapshot`
aggregate_defaults = (current) ->
  defaults = {}
  while current?.defaults
    defaults = _.defaults {}, defaults, _.result(current, 'defaults')
    current = Object.getPrototypeOf current
  defaults 

  
window.Slouch =
  attributeKeys: () ->
    snapshot = aggregate_defaults this

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

  isPrimative: (val) ->
    _.isArray(val) or
      val.constructor isnt Object or
      _.isFunction(val) or
      _.isString(val) or
      _.isNumber(val) or
      _.isBoolean(val) or
      _.isDate(val) or
      _.isRegExp(val)


  attributeTypes: () ->
    snapshot = aggregate_defaults this

    _set = @set
    @set = (arg1, options...) ->
      deserializers = @deserializers or []
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
          else if ref.constructor? and not Slouch.isPrimative(ref) and Slouch.isPrimative(value)
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

    _toJSON = @toJSON
    @toJSON = (args...) ->
      _serializeNestedData = (data) ->
        for own key, value of data
          if _.isFunction(value?.toJSON)
            nested_data = value.toJSON()
            data[key] = _serializeNestedData(nested_data)
        data
      _serializeNestedData(_toJSON.call(this, args...))

class Slouch.Model extends Backbone.Model
  constructor: (args...) ->
    super
    fn.apply this, args for fn in [
        Slouch.attributeKeys
        Slouch.attributeTypes
    ]




