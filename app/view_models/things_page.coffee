window.ThingsPageViewModel = ->
  @sorted_thing_links = kb.collectionObservable(app.collections.things, {view_model: ThingLinkViewModel, sort_attribute: 'name'})
  @things = kb.collectionObservable(app.collections.things, {view_model: ThingCellViewModel})
  @new_thing = new NewThingViewModel()
  @