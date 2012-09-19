# template source
class TemplateSource
  constructor: (@template_text, @binding_context={}) ->

  text: ->
    throw 'kbi.TemplateSource: unexpected writing to template source' if (arguments.length > 0)
    return @template_text

# template engine
class window.TemplateEngine extends ko.nativeTemplateEngine
  constructor: ->
    @allowTemplateRewriting = false
    @templates = {}

  makeTemplateSource: (template_name) ->
    return new TemplateSource(@templates[template_name]) if @templates.hasOwnProperty(template_name)
    return super

ko.setTemplateEngine(window.template_engine = new TemplateEngine()) # register the template engine that holds View strings