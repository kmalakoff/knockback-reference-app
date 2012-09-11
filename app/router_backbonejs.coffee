window.RouterBackboneJS = Backbone.Router.extend({
  constructor: ->
    Backbone.Router.prototype.constructor.apply(@, arguments)
    @active_el = null

    @route('', null, =>
      @loadPage(kb.renderTemplate('home', {}))
    )

    @route('things', null, =>
      @loadPage(kb.renderTemplate('things_page', new ThingsPageViewModel()))
    )

    @route('things/:id', null, (id) =>
      model = app.collections.things.get(id) or new Backbone.ModelRef(app.collections.things, id)
      @loadPage(kb.renderTemplate('thing_page', new ThingCellViewModel(model)))
    )

  loadPage: (el) ->
    ko.removeNode(@active_el) if @active_el # remove previous

    # add new and activate
    $('.pane-navigator.page').append(@active_el = el)
    $(el).addClass('active')

  destroy: ->
    @active_el = null
    handlers = Backbone.history.handlers
    handlers.splice(0, handlers.length)  # remove routes
})