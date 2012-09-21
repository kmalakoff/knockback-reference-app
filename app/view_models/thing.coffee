kb.untilTrueFn = (stand_in, fn, model) ->
  was_true = false
  model.subscribe(-> was_true = false) if model and ko.isObservable(model) # reset if the model changes
  return (value) ->
    return false unless (f = ko.utils.unwrapObservable(fn))
    was_true |= not (result = f(value))
    return (if was_true then result else stand_in)

kb.untilFalseFn = (stand_in, fn, model) ->
  return (value) -> return not kb.untilTrueFn(stand_in, fn, model)(value)

kb.minLengthFn = (length) ->
  return (value) -> return not value or value.length < length

kb.uniqueAttributeFn = (model, key, collection) ->
  return (value) ->
    m = ko.utils.unwrapObservable(model); k = ko.utils.unwrapObservable(key); c = ko.utils.unwrapObservable(collection)
    return false if not (m and k and c)
    return !!_.find(c.models, (test) => (test isnt m) and test.get(k) is value)

kb.hasChangedFn = (model) ->
  m = null; attributes = null
  return ->
    if m isnt (current_model = ko.utils.unwrapObservable(model)) # change in model
      m = current_model
      attributes = (if m then m.toJSON() else null)
      return false
    return false if not (m and attributes)
    return !_.isEqual(m.toJSON(), attributes)

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