asyncValidator = require("../")  if typeof asyncValidator is "undefined"
should = require('should') if typeof should is "undefined"

describe "String validator", ->
  describe "object feature", ->
    it "should be different objects when add new validation", ->
      v1 = asyncValidator.string()
      v2 = v1.required()
      v1.should.not.equal(v2)

      v3 = v2.isEmail()
      v2.should.not.equal(v3)

  describe "validater registration", ->
    it "can register a custom validator to string validator" , (done)->
      asyncValidator.Validator.register 'foo', ->
        (str, next) ->
          if str is 'hogehoge'
            next(null, str)
          else
            next('not hogehoge')

      v = asyncValidator.string()
      v.foo().validate 'hogehoge', (err, str) ->
        str.should.equal('hogehoge')
        done()

  describe "required and option", ->
    it "should validate string", (done) ->
      asyncValidator.string().required().validate()
      asyncValidator.string().required().validate "a", (err, str) ->
        str.should.equal('a')
        done()

    it "should validate empty string", (done) ->
      asyncValidator.string().required().validate "", (err, str) ->
        str.should.equal('')
        done()

    it "should validate required string", (done) ->
      asyncValidator.string().required().validate null, (err, str) ->
        err.should.equal('Required')
        done()

    it "should validate option string", (done) ->
      asyncValidator.string().option().validate null, (err, str) ->
        should.equal(str, null)
        done()

describe "String validator", ->
  it "should validate numeric string(1)", (done) ->
    asyncValidator.number().isInt().validate '123' , (err, number) ->
      should.equal(null, err)
      number.should.equal(123)
      done()

  it "should validate numeric string(2)", (done) ->
    asyncValidator.number().isInt().validate 'abc' , (err, number) ->
      err.should.equal('Invalid Integer')
      done()




