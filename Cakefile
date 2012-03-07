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
	wfn = (fn) ->
		return (err) ->
			console.log 'Warning: ' + err if err
			fn?()

	exec 'rm -r build/debug/js/*', wfn ->
		exec 'rm -r build/debug/css/*', wfn ->
			exec 'rm -r build/release/*', wfn ->
				console.log 'All done.'

task 'build', 'Build application', (args) ->
	
	exec 'iced -c -o build/debug/js/ client/js', (err, stdout, stderr) ->
		return console.log 'Error: ', err if err

		exec 'stylus -c -o build/debug/css client/css'



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
