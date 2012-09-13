window.ThingLinkViewModel = kb.ViewModel.extend({
  constructor: (model, options) ->
    kb.ViewModel.prototype.constructor.call(@, model, {keys: ['name', 'id'], options: options})
    @
})