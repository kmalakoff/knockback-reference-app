window.NewThingViewModel = kb.ViewModel.extend({
  constructor: ->
    # bind functions so they can be called from templates
    _.bindAll(@, 'onAdd', 'onClear')

    kb.ViewModel.prototype.constructor.call(@, model = new Thing(), {
      requires: ['id', 'name', 'caption']
      excludes: ['my_things']
    })
    # use a temporary collection so to not disturb the existing my_owner relationships during selection (one unique owner per model)
    @my_things_select = ko.observableArray()
    @available_things = kb.collectionObservable(app.collections.things, {sort_attribute: 'name', view_model: ThingLinkViewModel})

    # validations
    @validations_filter_count = ko.observable(2)
    @name_errors = ko.computed(=>
      if not (name = @name())
        errors = 'Things like names'
      else if _.find(app.collections.things.models, (test) -> test.get('name') is name)
        errors = "#{name} already taken"
      return if utils.decrementClampedObservable(@validations_filter_count) then '' else errors
    )
    return

  onAdd: ->
    @validations_filter_count(0)
    return if @name_errors() # errors

    # add to the collection and save
    model = kb.utils.wrappedObject(@)
    model.get('my_things').reset(_.map(@my_things_select(), (vm) -> kb.utils.wrappedModel(vm))) # add the relationships now that they are decided
    app.collections.things.add(model)

    # save new model to assign an id, then save all after Backbone.Relational had a chance to update
    model.save(null, {success: -> _.defer(app.saveAllThings)})

    # clear
    @onClear()

  onClear: ->
    # set a new model in our view model
    @validations_filter_count(3) # 3 = 1 for the view + 1 for the view_model + 1 to delay warnings
    @my_things_select([]) # clear selection
    @model(new Thing()) # create a new model to edit
})