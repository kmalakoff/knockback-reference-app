window.NewThingViewModel = kb.ViewModel.extend({
  constructor: ->
    # bind functions so they can be called from templates
    _.bindAll(@, 'onSubmit', 'onClear')

    kb.ViewModel.prototype.constructor.call(@, model = new Thing(), {
      requires: ['id', 'name', 'caption']
      excludes: ['my_things']
    })
    # use a temporary collection so to not disturb the existing my_owner relationships during selection (one unique owner per model)
    @my_things_select = ko.observableArray()
    @available_things = kb.collectionObservable(app.collections.things, {sort_attribute: 'name', view_model: ThingLinkViewModel})

    # validations
    @start_attributes = @model().toJSON()
    trigger = kb.triggeredObservable(@model(), 'change')
    @is_clean = ko.computed(=> trigger(); _.isEqual(@model().toJSON(), @start_attributes))
    @nameTaken = => return !!_.find(app.collections.things.models, (test) => (test isnt @model()) and test.get('name') is @name())
    return

  onSubmit: ->
    # create a new model, add to the collection and save
    new_model = new Thing(@model().toJSON())
    new_model.get('my_things').reset(_.map(@my_things_select(), (vm) -> kb.utils.wrappedModel(vm))) # add the relationships now that they are decided
    app.collections.things.add(new_model)
    new_model.save(null, {success: -> _.defer(app.saveAllThings)}) # save new model to assign an id, then save all after Backbone.Relational had a chance to update

    # clear
    @onClear()

  onClear: ->
    @my_things_select([]) # clear selection
    @model().clear()
    @model().set(@start_attributes) # create a new model to edit
})