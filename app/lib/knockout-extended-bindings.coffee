ko.bindingHandlers['classes'] =
  update: (element, value_accessor) ->
    for key, state of ko.utils.unwrapObservable(value_accessor())
      $(element)[if ko.utils.unwrapObservable(state) then 'addClass' else 'removeClass'](key)
    return

ko.bindingHandlers['spinner'] =
  init: (element, value_accessor) ->
    element.spinner = new Spinner(ko.utils.unwrapObservable(value_accessor())).spin(element)
    ko.utils.domNodeDisposal.addDisposeCallback(element, ->
      not element.spinner or (element.spinner.stop(); element.spinner = null)
      return
    )

ko.bindingHandlers['fadeIn'] =
  update: (element, value_accessor) ->
    not ko.utils.unwrapObservable(value_accessor()) or $(element).hide().fadeIn(500)
    return