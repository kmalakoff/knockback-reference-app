window.ThingCellViewModel = kb.ViewModel.extend({
  constructor: (model, options) ->
    kb.ViewModel.prototype.constructor.call(@, model, {
      requires: ['id', 'name', 'caption', 'my_things', 'my_owner']
      factories:
        'my_things': ThingCellCollectionObservable
        'my_owner': ThingLinkViewModel
      options: options
    })
    # use filtered view_models so to not disturb the existing my_owner relationships during selection (one unique owner per model)
    @my_things_select = ko.observableArray(@my_things())
    @my_things.subscribe((value)=> @my_things_select(value)) # if the relationship changes, sync us

    # share the view models so the knockout select binding can transfer view_models
    @available_things = new ThingCellCollectionObservable(app.collections.things, {filters: @id, sort_attribute: 'name', options: @my_things.value().shareOptions()}) # use value() because the kb.CollectionObservable is wrapped by a kb.Observable

    @sorted_thing_links = kb.collectionObservable(app.collections.things, {view_model: ThingLinkViewModel, sort_attribute: 'name'})
    @edit_mode = ko.observable(false)
    @goTo = => window.location.hash = "#things/#{@id()}"
    @goBack = -> kb.loadUrl('#things', {name: 'NavigationSlide', inverse: true})

    # validations
    @name_errors = ko.computed(=>
      if not (name = @name())
        return 'Things like names'
      else if _.find(app.collections.things.models, (test) => (test.get('name') == name) and (test.get('id') isnt @id()))
        return "#{name} already taken"
    )

    # allow for loading spinner
    @my_model = model
    @is_loaded = ko.observable(model and model.isLoaded())
    @_onModelLoaded = (m) => @start_attributes = m.toJSON(); @is_loaded(true)
    not model or model.bindLoadingStates(@_onModelLoaded)
    @

  destroy: ->
    @my_model?.unbindLoadingStates(@_onModelLoaded)
    kb.ViewModel.prototype.destroy.call(@)

  onEdit: ->
    @my_things_select(@my_things())
    @edit_mode(true)

  onDelete: ->
    model.destroy() if (model = kb.utils.wrappedObject(@))

  onSubmit: ->
    return if @name_errors() # errors
    if (model = kb.utils.wrappedObject(@))
      model.get('my_things').reset(_.map(@my_things_select(), (vm) -> kb.utils.wrappedModel(vm))) # add the relationships now that they are decided
      model.save()
    @edit_mode(false)

  onCancel: ->
    model.set(@start_attributes) if (model = kb.utils.wrappedObject(@)) # restore saved attributes
    @edit_mode(false)
})