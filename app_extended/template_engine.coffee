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
    @views =
      # extensions to existing views
      thing_view_extended: ThingViewExtendedView

      # application management
      app_management: AppManagementView
      credits: CreditsView
      statistics: StatisticsView

  makeTemplateSource: (template_name) ->
    return new TemplateSource(@views[template_name]) if @views.hasOwnProperty(template_name)
    return super