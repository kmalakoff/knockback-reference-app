window.ThingCollectionObservable = kb.CollectionObservable.extend({
  constructor: (collection, options) ->
    return kb.CollectionObservable.prototype.constructor.call(@, collection, {view_model: ThingViewModel, options: options})
})