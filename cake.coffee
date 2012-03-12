{exec} = require 'child_process'
Config = require './build/config'
_ = require 'underscore'
fs = require 'fs'
stitch = require 'stitch'
path = require 'path'
spawn = require('child_process').spawn
require 'colors'

console.log 'Embryo builder'.green.bold


#stitch files in array appFiles and save as destFilename
stitch_files = (appFiles, destFilename, callback) ->
 appContents = new Array remaining = appFiles.length
  for file, index in appFiles then do (file, index) ->
    fs.readFile file, 'utf8', (err, fileContents) ->
      return callback(err) if err
      appContents[index] = fileContents
      process() if --remaining is 0
  process = ->
  	fs.writeFile destFilename, appContents.join('\n\n'), 'utf8', callback

#process srcPaths, recurse directories and gather a list of all files
all_files = (srcPaths, callback) ->
	allFiles = []

	srcPaths = [srcPaths] if typeof srcPaths == 'string'

	for file in srcPaths

		await fs.realpath file, defer(err, truePath)
		return callback? "cannot determine real path for: " + file + '; err = '+ err if err

		file = truePath

		await fs.stat file, defer(err, stat)
		return callback? "cannot stat #{file}" if err

		if stat.isDirectory()
			await fs.readdir file, defer(err, dirFiles)

			dirFiles = _.map dirFiles, (dirFile) ->
				path.join file, dirFile

			await all_files dirFiles, defer(err, newFiles)
			return callback? "Error reading directory #{file}: " + err if err
			allFiles = allFiles.concat newFiles
		else
			allFiles.push file
	
	callback? null, allFiles


class BuildStep
	constructor: (@config, @stepName) ->

	build: (callback) ->
		console.log @stepName || 'Untitled step'
		@clean =>
			@compile callback

	clean: (callback) -> callback?()
	compile: (callback) -> callback?()

	die: (err) ->
		console.log 'Fatal: ' + err
		process.exit -1

	warn: (err) ->
		#console.log 'Warning: ' + err

class CompileJS extends BuildStep
	clean: (callback) ->
		await exec "rm -r #{@config.output}/*.js", defer(err)
		callback?()

	compile: (callback) ->
		await exec "mkdir -p #{@config.output}", defer(err)
		@die err if err
		src = if _.isArray @config.source then @config.source else [@config.source]
		sources = src.join ' '
		await exec "iced -c -o #{@config.output} #{sources}", defer(err)
		@die err if err
		callback?()

class StitchJS extends BuildStep
	clean: (callback) ->
		await fs.unlink @config.output, defer(err)
		@warn err if err
		callback?()

	compile: (callback) ->
		pkg = 
			paths: [@config.source]
			dependencies: @config.deps

		pkg = stitch.createPackage pkg
		await pkg.compile defer(err, source)
		@die err if err

		await fs.writeFile @config.output, source, defer(err)
		@die err if err
		callback?()

class MinifyJS extends BuildStep
	clean: (callback) ->
		await fs.unlink @config.output, defer(err)
		callback?()

	compile: (callback) ->
		ret = spawn 'uglifyjs', ['-o', @config.output, @config.source]
		ret.on 'exit', (code) =>
			@die 'uglifyjs not found. use `npm install -g uglifyjs` to install.' if code is 127
			@die code if code isnt 0
			
			if @config.remove_source 
				await fs.unlink @config.source, defer(err)

			callback?()

class CompileStylus extends BuildStep
	clean: (callback) ->
		await exec "rm -r #{@config.output}/*", defer(err)
		@warn err if err
		callback?()

	compile: (callback) ->
		await exec "mkdir -p #{@config.output}", defer(err)
		@die err if err

		src = if _.isArray @config.source then @config.source else [@config.source]
		sources = src.join ' '
		await exec "stylus -o #{@config.output} #{sources}", defer(err)
		@die err if err 
		callback?()

class StitchCSS extends BuildStep
	clean: (callback) ->
		await fs.unlink "#{@config.output}", defer err
		@warn err if err
		callback?()

	compile: (callback) ->
		await all_files @config.deps, defer(err, allDepFiles)
		@die err if err

		await all_files @config.source, defer(err, allClientFiles)
		@die err if err

		allFiles = allDepFiles.concat allClientFiles

		await stitch_files allFiles, @config.output, defer(err)
		@die err if err
		callback?()

class MinifyCSS extends BuildStep
	clean: (callback) ->
		await fs.unlink @config.output, defer(err)
		callback?()

	compile: (callback) ->
		await exec "cp #{@config.source} #{@config.output}", defer(err)
		@die err if err
		if @config.remove_source 
			await fs.unlink @config.source, defer(err)

class Builder 
	constructor: (@tasks) ->

	execute: (taskName, callback) ->
		for task in @tasks
			await task[taskName] defer()
		callback?()

	compile: (callback) -> @execute 'compile', callback
	build: (callback) -> @execute 'build', callback
	clean: (callback) -> @execute 'clean', callback

BuildJS = (config) -> new Builder [
	new CompileJS config.compile, 'Building coffee script.'.yellow
	new StitchJS config.stitch, 'Stiching dependencies and javascript.'.yellow
	new MinifyJS config.minify, 'Minifying javascript.'.yellow.bold
]

BuildCSS = (config) -> new Builder [
	new CompileStylus config.compile, 'Compiling stylus.'.blue
	new StitchCSS config.stitch, 'Stitching CSS files together.'.blue
	new MinifyCSS config.minify, 'Minifying CSS.'.blue.bold
]


Tasks = {}

task = (name, description, callback) ->
	Tasks[name] = 
		name: name
		description: description
		run: callback


task 'build', 'Build application', (args) ->

	await exec "mkdir -p #{Config.dirs.debug}", defer(err)	
	await exec "mkdir -p #{Config.dirs.release}", defer(err)

	console.log 'Building JS'.yellow
	await BuildJS(Config.coffee).build defer()
	
	console.log 'Building CSS'.blue
	await BuildCSS(Config.stylus).build defer()

	console.log "Done."

task 'clean', 'Clean build output', (args) ->
	console.log 'Cleaning JS'.yellow
	await new BuildJS(Config.coffee).clean defer()

	console.log 'Cleaning CSS'.green
	await new BuildCSS(Config.stylus).clean defer()

	console.log 'Done.'

task 'init', 'Initialize project', ->

	console.log 'Initializing server configuration'
	await exec 'cp server/config.default ./server-config.coffee', defer(err)

	return console.log err if err

	console.log 'Creating storage directory'

	await exec 'mkdir -p storage/user storage/tmp', defer(err)
	return console.log err if err

	await exec 'chmod -R 777 storage', defer(err)
	return console.log err if err

	console.log 'Installing dependencies...'

	await exec 'npm install', defer(err)

	return console.log err if err

	console.log 'Project initialized. '
	console.log 'Now edit server-config.coffee and ./go'


spawn_process = (command, cbStruct) ->
	parts = command.split(' ')

	name = parts.shift()

	proc = spawn name, parts
	proc.on 'exit', (code) ->
		console.log "Process #{name} has exited with exit code #{code}"
		cbStruct.exit(code)

	proc.stdout.on 'data', (data) ->
		cbStruct.stdout(data)

	proc.stderr.on 'data', (data) ->
		cbStruct.err(data)

	return proc

task 'watch', 'Watch application files for change and recompile', (args) ->

	ps = spawn_process "iced -c -w -o #{Config.coffee.compile.output} #{Config.coffee.compile.source}", 
		exit: -> 
			process.exit 0

		err: (data) -> 
			console.log 'Error: ' + data

		stdout: (data) ->
			console.log data.toString().yellow

	console.log 'Started coffee compiler. pid = ', ps.pid


	config = Config.stylus.compile
	src = if _.isArray config.source then config.source else [config.source]
	sources = src.join ' '


	ps = spawn_process "stylus -w -o #{Config.stylus.compile.output} #{sources}", 
		exit: ->
			process.exit 0
		
		err: (data) ->
			console.log ("Error: " + data).red

		stdout: (data) ->
			console.log data.toString().blue

#	await exec 'stylus -o #{Config.stylus.compile.output} #{sources} &', defer(err)

#	return console.log "Error starting stylus compiler: " + err

#	console.log 'Started with pid = ' + process.pid


task = Tasks[process.argv[2]]

if not task
	console.log 'Available tasks: '

	for key, task of Tasks
		console.log task.name + '\t' + task.description
	process.exit 0

console.log 'Executing task: '.green, process.argv[2].green.bold

task.run()





















