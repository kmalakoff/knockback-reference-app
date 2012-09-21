window.ThingViewModel = kb.ViewModel.extend({
  constructor: (model, options) ->
    _.bindAll(@, 'onSubmit', 'onDelete', 'onStartEdit', 'onCancelEdit') # bind functions so they can be called from templates

    # create the selectable things and required ViewModel observables
    kb.ViewModel.prototype.constructor.call(@, null, {
      requires: ['id', 'name', 'caption', 'my_owner', 'my_things'] # ensure all the neccessary kb.Observables exist so they can be bound even if the model is not loaded
      factories: {
        'my_owner': ThingLinkViewModel
        'my_things': ThingCollectionObservable
      }
      options: _.defaults({no_share: true}, options) # because we are starting as null and then setting the model later, don't share with 'null constants' ViewModels
    })
    @selected_things = kb.collectionObservable(new Backbone.Collection(), app.things_links.shareOptions()) # used for selecting things but not updating 'my_things' until onSubmit is called (we don't want to break and restore other relationships during edit)
    @edit_mode = ko.observable(!model) # start in edit if a new model

    # helper syncronize view to the model
    @syncViewToModel = ko.computed(=>
      return unless (current_model = @model())
      @start_attributes = current_model.toJSON()
      @selected_things(current_model.get('my_things').models)
    )

    # set up a new model, an existing model or a unloaded Backbone.ModelRef
    model or (model = new Thing()) # a new model
    @is_loaded = ko.observable(model and model.isLoaded()) # loading spinner
    model.bindLoadingStates((model) =>
      @model(model)
      @onStartEdit() if @edit_mode()
      @is_loaded(true) # loading spinner
    )
    return

  onSubmit: ->
    @edit_mode(false)
    return unless model = @model() # not loaded
    @my_things(@selected_things.collection().models) # update: sync 'my_things' with 'selected_things'

    # a new model so add to the collection and reset the view
    if model.isNew()
      app.collections.things.add(model) # add to the collection and set a new model
      @model(new Thing())

    # an existing model, just save and quit editing
    model.save(null, {success: -> _.defer(app.saveAllThings)})

  onDelete: ->
    return unless model = @model() # not loaded
    (@model(new Thing()); return) if model.isNew() # a new model so start editing a new one

    # destroy then save all changed models after Backbone.Relational had a chance to update
    model.destroy(success: -> _.defer(app.saveAllThings))
    kb.loadUrl('things') # redirect

  onStartEdit: ->
    @edit_mode(true)
    @syncViewToModel()

  onCancelEdit: ->
    @edit_mode(false)
    (model.clear(); model.set(@start_attributes)) if (model = @model()) # reset loaded model
    @syncViewToModel()
})