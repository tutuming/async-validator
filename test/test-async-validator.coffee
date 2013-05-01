if typeof @asyncValidator is 'undefined'
  try
    asyncValidator = require("../")
else
  asyncValidator = @asyncValidator

if typeof @should is 'undefined'
  try
    should = require('should')
else
  should = @should

describe "async-validator", ->
  describe "String validator", ->
    describe "object feature", ->
      it "should be different objects when add new validation", ->
        v1 = asyncValidator.string()
        v2 = v1.required()
        v1.should.not.equal(v2)

        v3 = v2.isEmail()
        v2.should.not.equal(v3)

    describe "validator registration", ->
      it "can register a custom validator" , (done)->
        asyncValidator.Validator.register 'foo', ->
          (str, next) ->
            if str is 'hogehoge'
              next(null, str)
            else
              next('not hogehoge')

        v = asyncValidator.string()
        v.foo().validate 'hogehoge', (err, str) ->
          str.should.equal('hogehoge')
          v.foo().validate 'hogehoge2', (err, str) ->
            err.should.equal('not hogehoge')
            done()

    describe "required and option", ->
      it "should validate string", (done) ->
        asyncValidator.string().required().validate "a", (err, str) ->
          str.should.equal('a')
          done()

      it "should validate empty string", (done) ->
        asyncValidator.string().required().validate "", (err, str) ->
          str.should.equal('')
          done()

      it "should validate required string", (done) ->
        asyncValidator.string().required().validate null, (err, str) ->
          should.not.exist(err)
          should.not.exist(str)
          done()

      it "should validate null", (done) ->
        asyncValidator.string().required().notNullable().validate \
        null, (err, str) ->
          err.should.equal('Not nullable')
          done()

      it "should validate option string (undefined)", (done) ->
        asyncValidator.string().option().validate undefined, (err, str) ->
          should.not.exist(err)
          should.not.exist(str)
          done()

      it "should validate option array (null)", (done) ->
        asyncValidator.array().option().validate undefined, (err, str) ->
          should.not.exist(err)
          should.not.exist(str)
          done()

      it "should validate array nullable", (done) ->
        asyncValidator.array().required().validate null, (err, str) ->
          should.not.exist(err)
          should.not.exist(str)
          done()

      it "should validate array nullable", (done) ->
        asyncValidator.array().required().notNullable().validate null, (err, str) ->
          err.should.equal('Not nullable')
          done()

    describe 'numeric', ->
      it "should validate numeric string(1)", (done) ->
        asyncValidator.number().isInt().validate '123' , (err, number) ->
          should.not.exist(err)
          number.should.equal(123)
          done()

      it "should validate numeric string(2)", (done) ->
        asyncValidator.number().isInt().validate 'abc' , (err, number) ->
          err.should.equal('Invalid Integer')
          done()

    describe 'boolean', ->
      it "should validate bool(true)", (done) ->
        asyncValidator.bool().validate true , (err, bool) ->
          should.not.exist(err)
          bool.should.equal true
          done()

      it "should validate bool(false)", (done) ->
        asyncValidator.bool().validate true , (err, bool) ->
          should.not.exist(err)
          bool.should.equal true
          done()

      it "should validate bool with options", (done) ->
        asyncValidator.bool().in([false]).validate true , (err, bool) ->
          err.should.equal "Unexpected value"
          done()

    describe 'object', ->
      V = asyncValidator

      it "should validate object", (done) ->
        registerValidator = V.obj
          name : V.string().required().len(1, 100)
          clientId : V.string().required().regex(/[a-zA-Z0-9-]*/).len(1, 100)
          policy : V.string().len(3000)
          redirectUris : V.array(
            V.string().required()
          )

        registerValidator.validate
          name : 'aiueo'
          clientId : 'abcde'
        , (err, obj) ->
          should.not.exist(err)
          done()
