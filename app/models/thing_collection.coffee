window.ThingCollection = Backbone.Collection.extend({
  localStorage: new Store('things-knockback') # Save all of the things under the "things-knockback" namespace.
  model: Thing
})