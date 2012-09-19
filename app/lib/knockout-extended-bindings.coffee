ko.bindingHandlers['classes'] =
  update: (element, value_accessor) ->
    for key, state of ko.utils.unwrapObservable(value_accessor())
      if ko.utils.unwrapObservable(state) then $(element).addClass(key) else $(element).removeClass(key)
    return

ko.bindingHandlers['spinner'] =
  init: (element, value_accessor) ->
    element.spinner = new Spinner(ko.utils.unwrapObservable(value_accessor())).spin(element)
    ko.utils.domNodeDisposal.addDisposeCallback(element, ->
      if element.spinner
        (element.spinner.stop(); element.spinner = null)
    )

ko.bindingHandlers['fadeIn'] =
  update: (element, value_accessor) ->
    if !!ko.utils.unwrapObservable(value_accessor()) # fade when the parameter is true
      $(element).hide().fadeIn(500)