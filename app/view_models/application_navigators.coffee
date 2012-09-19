class window.ApplicationNavigatorsViewModel extends ApplicationViewModel
  #########################
  # Routing
  #########################
  createRouter: (el) ->
    page_navigator = new kb.PageNavigatorPanes($(el).find('.pane-navigator.page')[0])

    router = new Backbone.Router()
    router.route('', null, page_navigator.dispatcher(->
      page_navigator.loadPage({
        create: -> kb.renderTemplate('home', {})
        transition: {name: 'FadeIn', duration: 1000}
      })
    ))

    router.route('things', null, page_navigator.dispatcher(->
      page_navigator.loadPage({
        create: -> kb.renderTemplate('things_page', new ThingsPageViewModel())
        transition: 'NavigationSlide'
      })
    ))

    router.route('things/:id', null, page_navigator.dispatcher((id)->
      model = app.collections.things.get(id) or new Backbone.ModelRef(app.collections.things, id)
      page_navigator.loadPage({
        create: -> kb.renderTemplate('thing_page', new ThingCellViewModel(model))
        transition: 'CoverVertical'
      })
    ))
    return router