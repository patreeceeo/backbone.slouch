describe 'Slouch.Model', ->
  model1 = null
  model2 = null

  beforeEach ->
    class Actor extends Slouch.Model
      defaults:
        color: 'blue'
        name: 'tobias'
        age: 34
        coach: new Actor()
        birthday: moment(0)
      deserializers: [
        test: (value) ->
          if moment(value).isValid() and _.isString(value)
            moment
      ]

    model1 = new Actor()

    model2 = new Actor
      color: 'yellow'
      name: 'gob'
      age: 35
      tricks: 'illusions'

  it 'should be defined', ->
    expect(Slouch.Model).toBeDefined()

  describe 'attribute name posture', ->

    it 'should not allow us to create new attributes', ->
      expect(-> model1.set('hair', true)).toThrow()
      expect(-> new Actor {occupation: true}).toThrow()
      expect(-> model2.set {poof: 'magazine', friends: []}).toThrow()

    it 'should not allow us to `get` non-existent attributes', ->
      expect(-> model1.get('hair')).toThrow()
      expect(-> model2.get('teeth')).toThrow()

    it 'should allow us to get attributes that do exist', ->
      expect(-> model1.get('name')).not.toThrow()
      expect(-> model2.get('age')).not.toThrow()

  describe 'attribute type posture', ->

    it 'should not allow us to change the type of attributes', ->
      expect(-> model1.set('name', 5)).toThrow()
      expect(-> model2.set('age', 'is just a number')).toThrow()

  describe 'posture superpowers!', ->

    it 'should automatically deserialize serialized objects', ->
      expect(-> model1.set 'coach',
        color: 'gold'
        name: 'Carl'
        age: 56
      ).not.toThrow()
      expect(model1.get('coach').get('name')).toBe 'Carl'

    it 'should know how to serialize nested models/collections', ->
      model1.set 'coach',
        color: 'gold'
        name: 'Carl'
        age: 56
      model1JSON = model1.toJSON()
      expect(model1JSON.coach.name).toBe 'Carl'

    it 'should (be able to) know how to deserialize anything!', ->
      now = moment()
      model1.set('birthday', now.format())
      expect(model1.get('birthday').format()).toBe now.format()


      



    
