window.ThingsPageViewModel = ->
  @things = kb.collectionObservable(app.collections.things, {view_model: ThingViewModel})
  @new_thing = new ThingViewModel()
  return