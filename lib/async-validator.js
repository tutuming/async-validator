// Generated by CoffeeScript 1.3.3
(function() {
  var ArrayValidator, BooleanValidator, NumberValidator, ObjectValidator, ScalarValidator, StringValidator, Validator, asyncValidator, previousAsyncValidator, regexValidaor,
    _this = this,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  asyncValidator = {};

  previousAsyncValidator = this.asyncValidator;

  if ((typeof module !== "undefined" && module !== null ? module.exports : void 0) != null) {
    module.exports = asyncValidator;
  } else {
    asyncValidator.noConflict = function() {
      _this.asyncValidator = previousAsyncValidator;
      return asyncValidator;
    };
    this.asyncValidator = asyncValidator;
  }

  asyncValidator.Validator = Validator = (function() {

    function Validator(msg) {
      this.msg = msg;
      this._validators = [];
      this._required = false;
    }

    Validator.prototype.clone = function() {
      var newInstance;
      newInstance = new this.constructor(this.msg);
      newInstance._validators = this._validators.slice(0);
      newInstance._required = this.required;
      return newInstance;
    };

    Validator.prototype.msg = function(msg) {
      var newInstance;
      newInstance = this.clone();
      newInstance._msg = msg;
      return newInstance;
    };

    Validator.register = function(name, validateFunc) {
      if (this.prototype[name] != null) {
        throw new Error("" + name + " is already registered");
      }
      return this.prototype[name] = function() {
        var newInstance, v_args,
          _this = this;
        newInstance = this.clone();
        v_args = arguments;
        newInstance._validators.push(function(str, next) {
          return validateFunc.apply(newInstance, v_args)(str, next);
        });
        return newInstance;
      };
    };

    Validator.prototype.validate = function(str, cb) {
      var idx, _next,
        _this = this;
      idx = 0;
      if (str === null || str === undefined) {
        if (this._required) {
          return typeof cb === "function" ? cb("Required") : void 0;
        } else {
          return typeof cb === "function" ? cb(null, str) : void 0;
        }
      }
      _next = function(err) {
        if (err) {
          if (_this._msg) {
            return typeof cb === "function" ? cb(_this._msg) : void 0;
          } else {
            return typeof cb === "function" ? cb(err) : void 0;
          }
        } else {
          if (idx === _this._validators.length) {
            return typeof cb === "function" ? cb(null, str) : void 0;
          } else {
            return _this._validators[idx++](str, _next);
          }
        }
      };
      return _next();
    };

    Validator.prototype.required = function() {
      var newInstance;
      newInstance = this.clone();
      newInstance._required = true;
      return newInstance;
    };

    Validator.prototype.option = function() {
      var newInstance;
      newInstance = this.clone();
      newInstance._required = false;
      return newInstance;
    };

    return Validator;

  })();

  asyncValidator.ScalarValidator = ScalarValidator = (function(_super) {

    __extends(ScalarValidator, _super);

    function ScalarValidator() {
      return ScalarValidator.__super__.constructor.apply(this, arguments);
    }

    return ScalarValidator;

  })(Validator);

  asyncValidator.StringValidator = StringValidator = (function(_super) {

    __extends(StringValidator, _super);

    function StringValidator() {
      return StringValidator.__super__.constructor.apply(this, arguments);
    }

    return StringValidator;

  })(ScalarValidator);

  asyncValidator.NumberValidator = NumberValidator = (function(_super) {

    __extends(NumberValidator, _super);

    function NumberValidator() {
      return NumberValidator.__super__.constructor.apply(this, arguments);
    }

    NumberValidator.prototype.validate = function(strOrNumber, cb) {
      var str;
      str = strOrNumber + '';
      return NumberValidator.__super__.validate.call(this, str, function(err, str) {
        if (err) {
          return typeof cb === "function" ? cb(err) : void 0;
        } else {
          return typeof cb === "function" ? cb(null, parseFloat(str, 10)) : void 0;
        }
      });
    };

    return NumberValidator;

  })(ScalarValidator);

  asyncValidator.BooleanValidator = BooleanValidator = (function(_super) {

    __extends(BooleanValidator, _super);

    function BooleanValidator() {
      return BooleanValidator.__super__.constructor.apply(this, arguments);
    }

    BooleanValidator.prototype.validate = function(value, cb) {
      if (value === 0 || value === false || value === '0' || value === 'false' || value === 'no' || value === 'off') {
        return typeof cb === "function" ? cb(null, false) : void 0;
      }
      if (value === 1 || value === true || value === '1' || value === 'true' || value === 'yes' || value === 'on') {
        return typeof cb === "function" ? cb(null, true) : void 0;
      }
      return typeof cb === "function" ? cb('Invalid boolean value') : void 0;
    };

    return BooleanValidator;

  })(Validator);

  asyncValidator.ArrayValidator = ArrayValidator = (function(_super) {

    __extends(ArrayValidator, _super);

    function ArrayValidator(innerValidator, msg) {
      this.msg = msg;
      ArrayValidator.__super__.constructor.call(this, this.msg);
      this._innerValidator = innerValidator;
      this._min = 0;
      this._max = null;
    }

    ArrayValidator.prototype.clone = function() {
      var newInstance;
      newInstance = ArrayValidator.__super__.clone.call(this);
      newInstance._innerValidator = this._innerValidator;
      newInstance._min = this._min;
      newInstance._max = this._max;
      return newInstance;
    };

    ArrayValidator.prototype.len = function(min, max) {
      var newInstance;
      newInstance = this.clone();
      newInstance._min = min;
      newInstance._max = max;
      return newInstance;
    };

    ArrayValidator.prototype.validate = function(array, cb) {
      var completes, count, errorOccured, errors, i, idx, isArray, len, _i, _next, _results,
        _this = this;
      isArray = array && typeof array.indexOf === "function";
      len = (array ? parseInt(array.length) : null);
      errors = [];
      errorOccured = false;
      completes = [];
      count = 0;
      idx = 0;
      _next = function(err) {
        if (err) {
          return typeof cb === "function" ? cb(err) : void 0;
        } else {
          if (idx === _this._validators.length) {
            return typeof cb === "function" ? cb(null, array) : void 0;
          } else {
            return _this._validators[idx++](array, _next);
          }
        }
      };
      if (array === null || array === undefined) {
        if (this._required) {
          return typeof cb === "function" ? cb("Required") : void 0;
        } else {
          return typeof cb === "function" ? cb(null, array) : void 0;
        }
      }
      if (isNaN(len) || !(len != null)) {
        _next();
        return;
      }
      if (isArray) {
        if (this._min > len) {
          if (typeof cb === "function") {
            cb("Invalid length");
          }
          return;
        }
        if (this._max !== null && this._max < len) {
          if (typeof cb === "function") {
            cb("Invalid length");
          }
          return;
        }
        if (len === 0) {
          if (typeof cb === "function") {
            cb(null, completes);
          }
          return;
        }
      }
      if (!this._innerValidator) {
        return typeof cb === "function" ? cb(null, array) : void 0;
      } else {
        _results = [];
        for (i = _i = 0; 0 <= len ? _i < len : _i > len; i = 0 <= len ? ++_i : --_i) {
          _results.push((function(i) {
            return _this._innerValidator.validate(array[i], function(err, obj) {
              if (err) {
                errorOccured = true;
                errors[i] = err;
              } else {
                errors[i] = null;
                completes[i] = obj;
              }
              count += 1;
              if (count === len) {
                if (errorOccured) {
                  return typeof cb === "function" ? cb(errors) : void 0;
                } else {
                  return _next();
                }
              }
            });
          })(i));
        }
        return _results;
      }
    };

    return ArrayValidator;

  })(Validator);

  asyncValidator.ObjectValidator = ObjectValidator = (function(_super) {

    __extends(ObjectValidator, _super);

    function ObjectValidator(innerValidators, msg) {
      var key;
      this.msg = msg;
      ObjectValidator.__super__.constructor.call(this, this.msg);
      this._innerValidators = [];
      for (key in innerValidators) {
        this._innerValidators.push({
          name: key,
          validator: innerValidators[key]
        });
      }
    }

    ObjectValidator.prototype.clone = function() {
      var newInstance;
      newInstance = ObjectValidator.__super__.clone.call(this);
      newInstance._innerValidators = this._innerValidators.slice(0);
      return newInstance;
    };

    ObjectValidator.prototype.addProperty = function(name, validator) {
      this._innerValidators.push({
        name: name,
        validator: validator
      });
      return this;
    };

    ObjectValidator.prototype.validate = function(obj, cb) {
      var checkComplete, completes, count, errorOccured, errors, idx, innerValidator, _i, _len, _next, _ref, _results,
        _this = this;
      completes = {};
      errors = {};
      errorOccured = false;
      count = 0;
      idx = 0;
      _next = function(err) {
        if (err) {
          return typeof cb === "function" ? cb(err) : void 0;
        } else {
          if (idx === _this._validators.length) {
            return typeof cb === "function" ? cb(null, obj) : void 0;
          } else {
            return _this._validators[idx++](obj, _next);
          }
        }
      };
      if (obj === null || obj === undefined) {
        if (this._required) {
          return typeof cb === "function" ? cb("Required") : void 0;
        } else {
          return typeof cb === "function" ? cb(null, obj) : void 0;
        }
      }
      if (this._innerValidators.length === 0) {
        _next();
        return;
      }
      checkComplete = function() {
        count += 1;
        if (count === _this._innerValidators.length) {
          if (errorOccured) {
            return typeof cb === "function" ? cb(errors) : void 0;
          } else {
            return _next();
          }
        }
      };
      _ref = this._innerValidators;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        innerValidator = _ref[_i];
        _results.push((function(innerValidator) {
          var name, validator;
          name = innerValidator.name;
          validator = innerValidator.validator;
          if (!validator) {
            completes[name] = obj[name];
            checkComplete();
          } else {
            return validator.validate(obj[name], function(err, obj) {
              if (err) {
                errorOccured = true;
                errors[name] = err;
              } else {
                errors[name] = null;
                completes[name] = obj;
              }
              checkComplete();
            });
          }
        })(innerValidator));
      }
      return _results;
    };

    return ObjectValidator;

  })(Validator);

  regexValidaor = function(regex, msg) {
    return function(str, next) {
      if (!str || str === '') {
        return next();
      }
      if (str.match(regex)) {
        return next();
      } else {
        return next(msg);
      }
    };
  };

  ScalarValidator.register("isEmail", function() {
    return regexValidaor(/^(?:[\w\!\#\$\%\&\'\*\+\-\/\=\?\^\`\{\|\}\~]+\.)*[\w\!\#\$\%\&\'\*\+\-\/\=\?\^\`\{\|\}\~]+@(?:(?:(?:[a-zA-Z0-9](?:[a-zA-Z0-9\-](?!\.)){0,61}[a-zA-Z0-9]?\.)+[a-zA-Z0-9](?:[a-zA-Z0-9\-](?!$)){0,61}[a-zA-Z0-9]?)|(?:\[(?:(?:[01]?\d{1,2}|2[0-4]\d|25[0-5])\.){3}(?:[01]?\d{1,2}|2[0-4]\d|25[0-5])\]))$/, "Invalid email");
  });

  ScalarValidator.register("isURL", function() {
    return regexValidaor(/^(?:(?:ht|f)tp(?:s?)\:\/\/|~\/|\/)?(?:\w+:\w+@)?((?:(?:[-\w\d{1-3}]+\.)+(?:com|org|net|gov|mil|biz|info|mobi|name|aero|jobs|edu|co\.uk|ac\.uk|it|fr|tv|museum|asia|local|travel|[a-z]{2}))|((\b25[0-5]\b|\b[2][0-4][0-9]\b|\b[0-1]?[0-9]?[0-9]\b)(\.(\b25[0-5]\b|\b[2][0-4][0-9]\b|\b[0-1]?[0-9]?[0-9]\b)){3}))(?::[\d]{1,5})?(?:(?:(?:\/(?:[-\w~!$+|.,=]|%[a-f\d]{2})+)+|\/)+|\?|#)?(?:(?:\?(?:[-\w~!$+|.,*:]|%[a-f\d{2}])+=?(?:[-\w~!$+|.,*:=]|%[a-f\d]{2})*)(?:&(?:[-\w~!$+|.,*:]|%[a-f\d{2}])+=?(?:[-\w~!$+|.,*:=]|%[a-f\d]{2})*)*)*(?:#(?:[-\w~!$ |\/.,*:;=]|%[a-f\d]{2})*)?$/, "Invalid URL");
  });

  ScalarValidator.register("isInt", function() {
    return regexValidaor(/^(?:-?(?:0|[1-9][0-9]*))$/, "Invalid Integer");
  });

  ScalarValidator.register("isAlpha", function() {
    return regexValidaor(/^[a-zA-Z]+$/, "Invalid characters");
  });

  ScalarValidator.register("isAlphanumeric", function() {
    return regexValidaor(/^[a-zA-Z0-9]+$/, "Invalid characters");
  });

  ScalarValidator.register("isNumeric", function() {
    return regexValidaor(/^-?[0-9]+$/, "Invalid number");
  });

  ScalarValidator.register("isDecimal", function() {
    return regexValidaor(/^(?:-?(?:0|[1-9][0-9]*))?(?:\.[0-9]*)?$/, "Invalid decimal");
  });

  Validator.register("isFloat", function() {
    return regexValidaor(/^(?:-?(?:0|[1-9][0-9]*))?(?:\.[0-9]*)?$/, "Invalid float");
  });

  Validator.register("equals", function(val) {
    return function(str, next) {
      if (val !== str) {
        return next("Not equal");
      } else {
        return next();
      }
    };
  });

  ScalarValidator.register("regex", function(pattern, modifiers) {
    return function(str, next) {
      if (typeof pattern !== "function") {
        pattern = new RegExp(pattern, modifiers);
      }
      if (!str.match(pattern)) {
        return next("Invalid characters");
      } else {
        return next();
      }
    };
  });

  ScalarValidator.register("notRegex", function(pattern, modifiers) {
    return function(str, next) {
      if (typeof pattern !== "function") {
        pattern = new RegExp(pattern, modifiers);
      }
      if (str.match(pattern)) {
        return next("Invalid characters");
      } else {
        return next();
      }
    };
  });

  Validator.register("in", function(options) {
    return function(str, next) {
      if (options && typeof options.indexOf === "function") {
        if (!~options.indexOf(str)) {
          return next("Unexpected value");
        } else {
          return next();
        }
      } else {
        throw new Error("Invalid in() argument");
      }
    };
  });

  Validator.register("notIn", function(options) {
    return function(str, next) {
      if (options && typeof options.indexOf === "function") {
        if (options.indexOf(str)) {
          return next("Unexpected value");
        } else {
          return next();
        }
      } else {
        throw new Error("Invalid in() argument");
      }
    };
  });

  ScalarValidator.register("max", function(val) {
    return function(str, next) {
      var number;
      number = parseFloat(str);
      if (!isNaN(number) && number > val) {
        return next("Invalid Number");
      } else {
        return next();
      }
    };
  });

  ScalarValidator.register("min", function(val) {
    return function(str, next) {
      var number;
      number = parseFloat(str);
      if (!isNaN(number) && number < val) {
        return next("Invalid Number");
      } else {
        return next();
      }
    };
  });

  ScalarValidator.register("len", function(min, max) {
    return function(str, next) {
      if (str.length < min) {
        return next("String is too small");
      } else if (typeof max !== undefined && str.length > max) {
        return next("String is too large");
      } else {
        return next();
      }
    };
  });

  Validator.register("custom", function(validator) {
    return validator;
  });

  asyncValidator.string = function() {
    return new StringValidator();
  };

  asyncValidator.number = function() {
    return new NumberValidator();
  };

  asyncValidator.array = function(innerValidator) {
    return new ArrayValidator(innerValidator);
  };

  asyncValidator.obj = function(innerValidators) {
    return new ObjectValidator(innerValidators);
  };

}).call(this);