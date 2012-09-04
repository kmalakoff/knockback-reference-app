window.RouterBackboneJSExtendedNoCache = Backbone.Router.extend({
  constructor: (page_navigator) ->
    Backbone.Router.prototype.constructor.apply(@, arguments)

    @route('', null, page_navigator.dispatcher(->
      page_navigator.loadPage({
        create: -> kb.renderAutoReleasedTemplate('home', {})
        transition: {name: 'FadeIn', duration: 1000}
      })
    ))

    @route('things', null, page_navigator.dispatcher(->
      page_navigator.loadPage({
        create: -> kb.renderAutoReleasedTemplate('things_page', new ThingsPageViewModel())
        transition: 'NavigationSlide'
      })
    ))

    @route('things/:id', null, page_navigator.dispatcher((id)->
      model = app.collections.things.get(id) or new Backbone.ModelRef(app.collections.things, id)
      page_navigator.loadPage({
        create: -> kb.renderAutoReleasedTemplate('thing_page', new ThingCellViewModel(model))
        transition: 'CoverVertical'
      })
    ))

  destroy: ->
    @active_el = null
    handlers = Backbone.history.handlers
    handlers.splice(0, handlers.length)  # remove routes
})