class window.ApplicationViewModel
  constructor: ->
    # bind functions so they can be called from ko
    _.bindAll(@, 'afterRender')

    # create the header
    @mode = 'Tutorial' unless @mode
    @header = new HeaderViewModel(@mode)

  # render header and set up router after the page is loaded
  afterRender: (nodes) =>
    @router = new RouterBackboneJS() unless @router