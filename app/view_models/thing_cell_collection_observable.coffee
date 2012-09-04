window.ThingCellCollectionObservable = kb.CollectionObservable.extend({
  constructor: (collection, options) ->
    return kb.CollectionObservable.prototype.constructor.call(@, collection, {view_model: ThingCellViewModel, options: options})
})