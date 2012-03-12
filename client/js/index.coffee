module?.enter 'index'



exports.start = ->
	class MyView extends Backbone.View
		initialize: ->
			console.log 'View initialized.'

	$ ->
		console.log 'Ready'
