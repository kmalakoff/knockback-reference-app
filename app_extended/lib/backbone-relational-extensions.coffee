Backbone.Store::clear = ->
  for collection in @_collections

    # unbind collection
    collection.unbind('relational:remove', collection._modelRemovedFromCollection);
    collection.unbind('relational:add', collection._relatedModelAdded)
    collection.unbind('relational:remove', collection._relatedModelRemoved);

    # unbind models
    for model in _.clone(collection.models)
      continue unless model instanceof Backbone.RelationalModel

      # remove from store
      @unregister(model)

      # remove the queue
      model._queue = null

      # clean up relations
      for relation in model._relations
        if relation.related
          relation.related.unbind('relational:add', relation.handleAddition)
          relation.related.unbind('relational:remove', relation.handleRemoval)
          relation.related.unbind('relational:reset', relation.handleReset)
          model.unbind('relational:change:' + relation.key, relation.onChange)
        relation.destroy()
      model._relations = []

      # clear up attributes
      model._previousAttributes = {}
      model.attributes = {}
    collection.models = []

  @_collections = []
  @_reverseRelations = []
