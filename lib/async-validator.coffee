asyncValidator = {}

previousAsyncValidator = @asyncValidator

if module?.exports?
  module.exports = asyncValidator
else
  # in browser
  asyncValidator.noConflict = =>
    @asyncValidator = previousAsyncValidator
    asyncValidator
  @asyncValidator = asyncValidator

asyncValidator.Validator = class Validator
  constructor : (message) ->
    @_msg = message
    @_validators = []
    @_context = null
    @_required = false
    @_nullable = true

  clone : ->
    newInstance = new (@constructor)()

    newInstance._msg = @_msg
    newInstance._validators = @_validators.slice(0)
    newInstance._context = @_context
    newInstance._required = @_required
    newInstance._nullable = @_nullable

    return newInstance

  msg : (msg) ->
    newInstance = @clone()
    newInstance._msg = msg
    return newInstance

  context : (context) ->
    newInstance = @clone()
    newInstance._context = context
    return newInstance

  @register = (name, validateFunc) ->
    if this::[name]?
      throw new Error("#{name} is already registered")

    this::[name] = ->
      newInstance = @clone()
      v_args = arguments
      newInstance._validators.push (str, next, context) =>
        validateFunc.apply(newInstance, v_args) str, next, context
      return newInstance

  validate :(str, cb) ->
    idx = 0
    if typeof str is 'undefined'
      if @_required
        return cb?("Required")

    if str is null
      if not @_nullable
        return cb?("Not nullable")

    if not str?
      return cb? null, str

    _next = (err) =>
      if err
        if @_msg
          cb? @_msg
        else
          cb? err
      else
        if idx is @_validators.length
          cb? null, str
        else
          @_validators[idx++] str, _next, @_context

    _next()

  required : ->
    newInstance = @clone()
    newInstance._required = true
    return newInstance

  option : ->
    newInstance = @clone()
    newInstance._required = false
    return newInstance

  nullable : ->
    newInstance = @clone()
    newInstance._nullable = true
    return newInstance

  notNullable : ->
    newInstance = @clone()
    newInstance._nullable = false
    return newInstance

asyncValidator.ScalarValidator = class ScalarValidator extends Validator

asyncValidator.StringValidator = class StringValidator extends ScalarValidator

asyncValidator.NumberValidator = class NumberValidator extends ScalarValidator
  validate : (strOrNumber, cb) ->
    str = strOrNumber + ''
    super str, (err, str) ->
      if err
        return cb?(err)
      else
        return cb? null, parseFloat str, 10

asyncValidator.BooleanValidator = class BooleanValidator extends Validator
  validate : (value, cb) ->
    boolValue = null
    if value in [0, false, '0', 'false', 'no', 'off']
      boolValue = false
    else if value in [1, true, '1', 'true', 'yes', 'on']
      boolValue = true
    else if value?
      return cb? 'Invalid boolean value'

    super value, (err, str) ->
      if err?
        return cb?(err)
      else
        return cb? null, boolValue

asyncValidator.ArrayValidator = class ArrayValidator extends Validator
  constructor :  (innerValidator, @msg) ->
    super(@msg)
    @_innerValidator = innerValidator
    @_min = 0
    @_max = null

  clone : ->
    newInstance = super()
    newInstance._innerValidator = @_innerValidator
    newInstance._min = @_min
    newInstance._max = @_max

    return newInstance

  context : (context) ->
    newInstance = @clone()
    newInstance._innerValidator = newInstance._innerValidator.context(context)

    return newInstance

  len : (args...) ->
    newInstance = @clone()
    if args.length is 1
      newInstance._max = args[0]

    if args.length is 2
      newInstance._min = args[0]
      newInstance._max = args[1]
    return newInstance

  validate : (array, cb) ->
    isArray = array and typeof array.indexOf is "function"
    len = (if array then parseInt(array.length) else null)
    errors = []
    errorOccured = false
    completes = []
    count = 0
    idx = 0
    _next = (err) =>
      if err
        cb? err
      else
        if idx is @_validators.length
          cb? null, completes
        else
          @_validators[idx++] array, _next, @_context

    if typeof array is 'undefined'
      if @_required
        return cb?("Required")

    if array is null
      if not @_nullable
        return cb?("Not nullable")

    if not array?
      return cb? null, array

    if isNaN(len) or not len?
      _next()
      return
    if isArray
      if @_min > len
        cb? "Invalid length"
        return
      if @_max isnt null and @_max < len
        cb? "Invalid length"
        return
      if len is 0
        cb? null, completes
        return

    if not  @_innerValidator
      cb? null, array

    else
      for i in [0 ... len]
        do (i) =>
          @_innerValidator.validate array[i], (err, obj) ->
            if err
              errorOccured = true
              errors[i] = err
            else
              errors[i] = null
              completes[i] = obj
            count += 1
            if count is len
              if errorOccured
                cb? errors
              else
                _next()

asyncValidator.ObjectValidator = class ObjectValidator extends Validator
  constructor : (innerValidators, @msg) ->
    super(@msg)
    @_innerValidators = []
    for key of innerValidators
      @_innerValidators.push
        name: key
        validator: innerValidators[key]

  clone : ->
    newInstance = super()
    a = super
    newInstance._innerValidators = @_innerValidators.slice(0)
    return newInstance

  context : (context) ->
    newInstance = @clone()

    contextValidators = []
    for innerValidator in newInstance._innerValidators
      contextValidators.push
        name : innerValidator.name
        validator : innerValidator.validator.context(context)

    newInstance._innerValidators = contextValidators
    return newInstance

  addProperty : (name, validator) ->
    newInstance = @clone()
    newInstance._innerValidators.push
      name: name
      validator: validator

    return newInstance

  validate : (obj, cb) ->
    completes = {}
    errors = {}
    errorOccured = false
    count = 0
    idx = 0
    _next = (err) =>
      if err
        cb? err
      else
        if idx is @_validators.length
          cb? null, completes
        else
          @_validators[idx++] obj, _next, @_context
    if typeof obj is 'undefined'
      if @_required
        return cb?("Required")

    if obj is null
      if not @_nullable
        return cb?("Not nullable")

    if not obj?
      return cb? null, obj

    if @_innerValidators.length is 0
      _next()
      return
    checkComplete = =>
      count += 1
      if count is @_innerValidators.length
        if errorOccured
          cb? errors
        else
          _next()

    for innerValidator in @_innerValidators
      do (innerValidator) ->
        name = innerValidator.name
        validator = innerValidator.validator
        if not validator
          completes[name] = obj[name]
          checkComplete()
          return
        else
          if not Object.prototype.hasOwnProperty.call(obj, name)
            checkComplete()
            return
          validator.validate obj[name], (err, obj) ->
            if err
              errorOccured = true
              errors[name] = err
            else
              errors[name] = null
              completes[name] = obj
            checkComplete()
            return

regexValidaor = (regex, msg) ->
  (str, next) ->
    if not str or str == ''
      return next()
    if str.match(regex)
      next()
    else
      next msg

ScalarValidator.register "isEmail", ->
  regexValidaor /^(?:[\w\!\#\$\%\&\'\*\+\-\/\=\?\^\`\{\|\}\~]+\.)*[\w\!\#\$\%\&\'\*\+\-\/\=\?\^\`\{\|\}\~]+@(?:(?:(?:[a-zA-Z0-9](?:[a-zA-Z0-9\-](?!\.)){0,61}[a-zA-Z0-9]?\.)+[a-zA-Z0-9](?:[a-zA-Z0-9\-](?!$)){0,61}[a-zA-Z0-9]?)|(?:\[(?:(?:[01]?\d{1,2}|2[0-4]\d|25[0-5])\.){3}(?:[01]?\d{1,2}|2[0-4]\d|25[0-5])\]))$/, "Invalid email"

ScalarValidator.register "isURL", ->
  regexValidaor /^(?:(?:ht|f)tp(?:s?)\:\/\/|~\/|\/)?(?:\w+:\w+@)?((?:(?:[-\w\d{1-3}]+\.)+(?:com|org|net|gov|mil|biz|info|mobi|name|aero|jobs|edu|co\.uk|ac\.uk|it|fr|tv|museum|asia|local|travel|[a-z]{2}))|((\b25[0-5]\b|\b[2][0-4][0-9]\b|\b[0-1]?[0-9]?[0-9]\b)(\.(\b25[0-5]\b|\b[2][0-4][0-9]\b|\b[0-1]?[0-9]?[0-9]\b)){3}))(?::[\d]{1,5})?(?:(?:(?:\/(?:[-\w~!$+|.,=]|%[a-f\d]{2})+)+|\/)+|\?|#)?(?:(?:\?(?:[-\w~!$+|.,*:]|%[a-f\d{2}])+=?(?:[-\w~!$+|.,*:=]|%[a-f\d]{2})*)(?:&(?:[-\w~!$+|.,*:]|%[a-f\d{2}])+=?(?:[-\w~!$+|.,*:=]|%[a-f\d]{2})*)*)*(?:#(?:[-\w~!$ |\/.,*:;=]|%[a-f\d]{2})*)?$/, "Invalid URL"

ScalarValidator.register "isInt", ->
  regexValidaor /^(?:-?(?:0|[1-9][0-9]*))$/, "Invalid Integer"

ScalarValidator.register "isAlpha", ->
  regexValidaor /^[a-zA-Z]+$/, "Invalid characters"

ScalarValidator.register "isAlphanumeric", ->
  regexValidaor /^[a-zA-Z0-9]+$/, "Invalid characters"

ScalarValidator.register "isNumeric", ->
  regexValidaor /^-?[0-9]+$/, "Invalid number"

ScalarValidator.register "isDecimal", ->
  regexValidaor /^(?:-?(?:0|[1-9][0-9]*))?(?:\.[0-9]*)?$/, "Invalid decimal"

Validator.register "isFloat", ->
  regexValidaor /^(?:-?(?:0|[1-9][0-9]*))?(?:\.[0-9]*)?$/, "Invalid float"

Validator.register "equals", (val) ->
  (str, next) ->
    if val isnt str
      next "Not equal"
    else
      next()

ScalarValidator.register "regex", (pattern, modifiers) ->
  (str, next) ->
    pattern = new RegExp(pattern, modifiers)  if typeof pattern isnt "function"

    if not str || str.match(pattern)
      next()
    else
      next "Invalid characters"


ScalarValidator.register "notRegex", (pattern, modifiers) ->
  (str, next) ->
    pattern = new RegExp(pattern, modifiers)  if typeof pattern isnt "function"
    if str and str.match(pattern)
      next "Invalid characters"
    else
      next()

Validator.register "in", (options) ->
  (str, next) ->
    if options and typeof options.indexOf is "function"
      unless ~options.indexOf(str)
        next "Unexpected value"
      else
        next()
    else
      throw new Error("Invalid in() argument")

Validator.register "notIn", (options) ->
  (str, next) ->
    if options and typeof options.indexOf is "function"
      if options.indexOf(str)
        next "Unexpected value"
      else
        next()
    else
      throw new Error("Invalid in() argument")

ScalarValidator.register "max", (val) ->
  (str, next) ->
    number = parseFloat(str)
    if not isNaN(number) and number > val
      next "Invalid Number"
    else
      next()

ScalarValidator.register "min", (val) ->
  (str, next) ->
    number = parseFloat(str)
    if not isNaN(number) and number < val
      next "Invalid Number"
    else
      next()

ScalarValidator.register "len", (args...) ->
  (str, next) ->
    if args.length is 1
      max = args[0]
      min = null

    if args.length is 2
      min = args[0]
      max = args[1]

    if min? and (not str or str.length < min)
      next "String is too small"
    else if max and str.length > max
      next "String is too large"
    else
      next()

Validator.register "custom", (validator) ->
  validator

# utility functions
asyncValidator.string = ->
  new StringValidator()

asyncValidator.number = ->
  new NumberValidator()

asyncValidator.bool = ->
  new BooleanValidator()

asyncValidator. array = (innerValidator) ->
  new ArrayValidator(innerValidator)

asyncValidator.obj =  (innerValidators) ->
  new ObjectValidator(innerValidators)
