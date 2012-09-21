window.Thing = Backbone.RelationalModel.extend({
  url: -> return "things/#{@get('id')}"
  relations:[
    type: 'HasMany', key: 'my_things', includeInJSON: 'id', relatedModel: 'Thing',
    reverseRelation: {key: 'my_owner', includeInJSON: 'id'}
  ]
})