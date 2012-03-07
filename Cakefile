{exec} = require 'child_process'

createDirectories = (structure) ->
	fs = require 'fs'
	dlist = structure.split '\n'

	for dir in dlist
		console.log 'Creating ', dir
		#let it crash on error
		try
			fs.mkdirSync dir 
			console.log '..success!'
		catch e
			console.log '..failed: ', e

task 'mkdirs', 'Create the directory structure', ->
  fs = require 'fs'

  structure = '''
		build
		build/debug
		build/release
		build/debug/css
		build/debug/js
		assets
		assets/lib
		assets/lib/css
		assets/lib/js
		assets/images
		client
		client/css
		client/js
		server
		server/models
		views
		storage 
  '''
  createDirectories structure

task 'clean', 'Clean build output', ->
	#rm -r build/debug/js/*
	#rm -r build/debug/css/*
	#rm -r build/release/*
	

task 'build', 'Build application', (args) ->
	#iced -c client/js -> build/debug/js/
	#stylus -c client/css -> build/debug/css



task 'init', 'Initialize a new app instance', (args) ->
	#Copy server/config.default to ../config.coffee

	dirs = '''
		storage
		storage/user
		storage/tmp
	'''

	console.log 'Creating storage folders'
	createDirectories dirs

	exec 'cp server/config.default ./config.coffee', (err, stdout, stderr) ->
		throw err if err

		console.log 'Installing dependencies...'
		exec 'npm install', (err) ->
			throw err if err
			console.log 'init done.'
			console.log 'Next step: edit config.coffee'
			console.log 'And after you can: ./go'
