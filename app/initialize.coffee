$ ->
  # create the application state
  window.app = new Application()
  app.initialize()

  # Load the things later to demonstrate Backbone.ModelRef
  _.delay((-> app.collections.things.fetch()), 600)
