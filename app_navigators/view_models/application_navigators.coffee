class window.ApplicationNavigatorsViewModel extends ApplicationViewModel
  #########################
  # Routing
  #########################
  createRouter: (el) ->
    page_navigator = new kb.PageNavigatorPanes($(el).find('.pane-navigator.page')[0])
    clearFilter = ko.computed(=> # use the active page observable to track page changes
      app.things_links.filters(null) if (page_navigator.activePage()?.url is 'things') # remove filter
      @loadApp(!!page_navigator.activePage())
    )

    router = new Backbone.Router()
    router.route('', null, page_navigator.dispatcher(->
      page_navigator.loadPage({
        create: -> kb.renderTemplate('home', {})
        transition: {name: 'FadeIn', slow: true}
      })
    ))

    router.route('things', null, page_navigator.dispatcher(->
      page_navigator.loadPage({
        create: -> kb.renderTemplate('things_page', new ThingsPageViewModel())
        transition: 'Slide'
      })
    ))

    router.route('things/:id', null, page_navigator.dispatcher((id)->
      page_navigator.loadPage({
        create: ->
          model = app.collections.things.get(id) or new Backbone.ModelRef(app.collections.things, id)
          view_model = new ThingViewModel(model)
          app.things_links.filters(view_model.id) # add a filter to the available models
          kb.renderTemplate('thing_page', view_model)
        transition: 'SlideUp'
      })
    ))

    router.route('no_app', null, => page_navigator.clear())

    return router