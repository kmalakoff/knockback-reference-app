window.ThingViewModel = kb.ViewModel.extend({
  constructor: (model, options) ->
    _.bindAll(@, 'onEdit', 'onDelete', 'onSubmit', 'onCancel') # bind functions so they can be called from templates

    # create the selectable things and required ViewModel observables
    @available_things = kb.collectionObservable(app.collections.things, {view_model: ThingLinkViewModel, filters: @id, sort_attribute: 'name'})
    @selected_things = ko.observableArray() # used for selecting things but not updating 'my_things' until onSubmit is called
    kb.ViewModel.prototype.constructor.call(@, null, {
      requires: ['id', 'name', 'caption', 'my_owner', 'my_things'] # ensure all the neccessary kb.Observables exist so they can be bound even if the model is not loaded
      factories: {
        'my_owner': ThingLinkViewModel
        'my_things': ThingLinkCollectionObservable
      }
      options: @available_things.shareOptions() # share ViewModels so Knockout options binding has same obeservables
    })

    # additional functionality - the links at the top of the page and the togglable edit mode
    @sorted_thing_links = kb.collectionObservable(app.collections.things, {view_model: ThingLinkViewModel, sort_attribute: 'name'})
    @edit_mode = ko.observable(!model) # start in edit if a new model

    # set up a new model, an existing model or a unloaded Backbone.ModelRef
    model = new Thing() unless model # a new model
    @is_loaded = ko.observable(model and model.isLoaded()) # loading spinner
    model.bindLoadingStates((model) =>
      @start_attributes = model.toJSON()
      @model(model)
      @selected_things(@my_things()) # update: sync 'selected_things' with 'my_things'

      # custom validations - make sure the model has changed and check for a unique name
      trigger = kb.triggeredObservable(model, 'change')
      @is_clean = ko.computed(=> trigger(); _.isEqual(model.toJSON(), @start_attributes))
      @nameTaken = => return !!_.find(app.collections.things.models, (test) => (test isnt model) and test.get('name') is @name())

      @is_loaded(true) # loading spinner
    )
    return

  onEdit: ->
    @selected_things(@my_things()) # update: sync 'selected_things' with 'my_things'
    @edit_mode(true)

  onDelete: ->
    return unless model = @model() # not loaded

    # a new model so just cancel
    if model.isNew()
      @onCancel()

    # destroy, then save all changed models since relationships may have been updated after Backbone.Relational had a chance to update
    else
      model.destroy(success: -> _.defer(app.saveAllThings))
      kb.loadUrl('things') # redirect

    return

  onSubmit: ->
    @edit_mode(false)
    return unless model = @model() # not loaded
    @my_things(@selected_things()) # update: sync 'my_things' with 'selected_things'

    # a new model so add to the collection and reset the view
    if model.isNew()
      app.collections.things.add(new_thing = new Thing(model.toJSON()))
      new_thing.save(null, {success: -> _.defer(app.saveAllThings)}) # first assign an id then save all changed models since relationships may have been updated
      @onCancel()

    # an existing model, just save and quit editing
    else
      app.saveAllThings() # save all changed models since relationships may have been updated

    return

  onCancel: ->
    @edit_mode(false)
    return unless model = @model() # not loaded

    model.clear(); model.set(@start_attributes)
    @selected_things(@my_things()) # revert: sync 'selected_things' with 'my_things'
    return
})