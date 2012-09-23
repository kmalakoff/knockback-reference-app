window.ThingLinkViewModel = kb.ViewModel.extend({
  constructor: (model, options) ->
    kb.ViewModel.prototype.constructor.call(@, model, {keys: ['id', 'name'], options: options})
    return
})