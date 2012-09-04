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

    # share the view models so the knockout select binding can transfer view_models
    @available_things = new ThingLinkCollectionObservable(app.collections.things, {sort_attribute: 'name'})

    # validations
    @validations_filter_count = ko.observable(2)
    @name_errors = ko.computed(=>
      if not (name = @name())
        errors = 'Things like names'
      else if _.find(app.collections.things.models, (test) -> test.get('name') is name)
        errors = "#{name} already taken"
      return if utils.decrementClampedObservable(@validations_filter_count) then '' else errors
    )
    @

  onAdd: ->
    $('*:focus').blur() # force focus change so validations occur
    @validations_filter_count(0)
    return if @name_errors() # errors

    # add to the collection and save
    model = kb.utils.wrappedObject(@)
    model.get('my_things').reset(_.map(@my_things_select(), (vm) -> kb.utils.wrappedModel(vm))) # add the relationships now that they are decided
    app.collections.things.add(model)
    model.save()

    # clear
    @onClear()

  onClear: ->
    # set a new model in our view model
    @validations_filter_count(3) # 3 = 1 for the view + 1 for the view_model + 1 to delay warnings
    @my_things_select([]) # clear selection
    @model(new Thing()) # create a new model to edit
})