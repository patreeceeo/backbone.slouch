# BACKBONE.SLOUCH
Ship code faster by making it obvious when you probably made a mistake. 

When you Instantiate a `Slouch.Model`, the initial attributes, whether they come from the `defaults` object or from the argued attributes object, serve as the specification for what the model's attributes should always look like.

### Example Instantiations
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

### Slouch.Model knows what it should know and what it shouldn't know.

    model1.get('name')) # is 'tobias'
    model2.get('age')) # is 34

    model1.set('hair', true) # throws Error
    new Actor {occupation: true} # throws Error
    model2.set {poof: 'magazine', self_esteem: -400} # throws Error

    model1.get('hair') # throws Error
    model2.get('teeth') # throws Error

### Slouch.Model knows what the "types" of its attributes should be

    model1.set('name', 5) # throws Error
    model2.set('age', 'is just a number') # throws Error

### Slouch.Model currently will serialize and de-serialize using its type knowledge
Aside: it might be good to extract this into a separate project.

    model1.set('coach', {color: 'gold', name: 'Carl', age: 56}) # Everything's cool.
    model1.get('coach').get('name') # is 'Carl'
    model1.toJSON().coach.name # also 'Carl'

    now = moment()
    model1.set('birthday', now.format())
    model1.get('birthday').format() # is now.format()

## Dependencies (Production)
  backbone.js (http://backbonejs.org)
  underscore.js (http://underscorejs.org)

      



    

