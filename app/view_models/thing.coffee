window.ThingViewModel = kb.ViewModel.extend({
  constructor: (model, options) ->
    _.bindAll(@, 'onSubmit', 'onDelete', 'onStartEdit', 'onCancelEdit') # bind functions so they can be called from templates

    # create the selectable things and required ViewModel observables
    kb.ViewModel.prototype.constructor.call(@, model, {
      requires: ['id', 'name', 'caption', 'my_owner', 'my_things'] # ensure all the neccessary kb.Observables exist so they can be bound even if the model is not loaded
      factories: {
        'my_owner': ThingLinkViewModel
        'my_things': ThingCollectionObservable
      }
      options: options
    })
    @selected_things = kb.collectionObservable(new Backbone.Collection(), {options: app.things_links.shareOptions()}) # used for selecting things but not updating 'my_things' until onSubmit is called (we don't want to break and restore other relationships during edit)
    @edit_mode = ko.observable() # start in edit if a new model
    @is_loaded = ko.observable() # loading spinner

    # helper syncronize view to the model
    previous_model = null
    @_syncViewToModel = ko.computed(=>
      if (current_model = @model()) # model is loaded
        # model changed
        if (changed = (previous_model isnt current_model))
          previous_model = current_model; @start_attributes = current_model.toJSON() # save attributes for restore
          @edit_mode(current_model.isNew()) # start in edit if a new model

        # set up the drop down selector
        @selected_things.collection().reset(current_model.get('my_things').models) if @edit_mode()

      @is_loaded(!!current_model) # loading spinner
    )
    return

  destroy: ->
    @[fn] = null for fn in ['onSubmit', 'onDelete', 'onStartEdit', 'onCancelEdit']
    @start_attributes = null
    kb.ViewModel.prototype.destroy.call(@)

  onSubmit: ->
    return unless model = @model() # not loaded

    # Workaround: Backbone-Relational doesn't clear reverse relations on reset
    # model.get('my_things').reset(@selected_things.collection().models) # update: sync 'my_things' with 'selected_things'
    my_things = model.get('my_things')
    my_things.remove(thing) for thing in my_things.models.slice()
    my_things.add(thing) for thing in @selected_things.collection().models

    # a new model so add to the collection and reset the view
    if model.isNew()
      app.collections.things.add(model) # add to the collection and set a new model
      @model(new Thing())

    # save this model and then once saved, save the rest (new models need ids to be saved)
    model.save(null, {success: -> _.defer(app.saveAllThings)})
    @edit_mode(false)

  onDelete: ->
    return unless model = @model() # not loaded
    (@model(new Thing()); return) if model.isNew() # a new model so start editing a new one

    # destroy then save all changed models after Backbone.Relational had a chance to update
    model.destroy({success: -> _.defer(app.saveAllThings)})
    kb.loadUrl('things') # redirect

  onStartEdit: -> @edit_mode(true)
  onCancelEdit: ->
    return unless model = @model() # not loaded
    (model.clear(); model.set(@start_attributes)) # reset loaded model
    @edit_mode(false)
})