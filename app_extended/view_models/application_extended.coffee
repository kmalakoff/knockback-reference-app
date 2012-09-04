class window.ApplicationViewModelExtended extends ApplicationViewModel
  constructor: (@options) ->
    if not @options.has_panes
      @mode ='P'
    else if @options.no_history
      @mode = 'A'
    else if not @options.no_cache
      @mode = 'A+H'
    else
      @mode = 'A+H+NC'
    super

  afterRender: (nodes) =>
    # set up the page navigator
    page_navigator_el = $(nodes[0].parentNode).find('.pane-navigator.page')[0]
    if not @options.has_panes
      @page_navigator = new kb.PageNavigatorSimple(page_navigator_el, @options)
    else
      @page_navigator = new kb.PageNavigatorPanes(page_navigator_el, @options)

    if not @options.no_cache
      @router = new RouterBackboneJSExtended(@page_navigator)
    else
      @router = new RouterBackboneJSExtendedNoCache(@page_navigator)
    super