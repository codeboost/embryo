require 'iced-coffee-script'
{exec} = require 'child_process'
Config = require './build/build-config.coffee'
_ = require 'underscore'
fs = require 'fs'
stitch = require 'stitch'
path = require 'path'

bail = (msg) ->
	console.log msg
	process.exit -1

wfn = (fn) ->
	(err) ->
		if err
			console.log "Error: " + err 
			process.exit -1
		fn?.apply this, arguments

#stitch files in array appFiles and save as destFilename
stitch_files = (appFiles, destFilename, callback) ->
 appContents = new Array remaining = appFiles.length
  for file, index in appFiles then do (file, index) ->
    fs.readFile file, 'utf8', (err, fileContents) ->
      return callback(err) if err
      appContents[index] = fileContents
      process() if --remaining is 0
  process = ->
  	console.log "Saving to #{destFilename}"
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



task 'clean', 'Clean build output', ->

	console.log 'Cleaning build output directories...'

	clean = (conf, callback) ->

		await exec "rm -r #{conf.client.output}", defer(err)
		console.log err if err

		await exec "rm -r #{conf.minify.output}", defer(err)
		console.log err if err

		callback()

	await clean Config.coffee, defer()

	await clean Config.stylus, defer()

	console.log 'Done.'


class BuildStep
	constructor: (@config) ->

	build: (callback) ->
		@clean ->
			@compile callback

	clean: (callback) -> callback?()
	compile: (callback) -> callback?()

	die: (err) ->
		console.log 'Fatal: ' + err
		process.exit -1

	warn: (err) ->
		console.log 'Warning: ' + err

class BuildJS extends BuildStep
	clean: (callback) ->
		await exec 'rm -r #{@config.output}/*.js', defer(err)
		@warn err if err
		callback?()

	compile: (callback) ->
		await exec 'mkdir -p #{config.output}', defer(err)
		@die err if err
		src = if _.isArray source then source else [source]
		sources = @config.source.join ' '
		await exec "iced -c -o #{conf.client.output} #{sources}", defer(err)
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
		@warn err if err
		callback?()

	compile: (callback) ->
		spawn = require('child_process').spawn
		ret = spawn 'uglifyjs', ['-o', conf.minify.output, conf.minify.source]
		ret.on 'exit', (code) =>
			@die 'uglifyjs not found. use `npm install -g uglifyjs` to install.' if code is 127
			@die code if code isnt 0
			callback?()

class CompileStylus extends BuildStep
	clean: (callback) ->
		await exec "rm -r #{config.output}/*", defer(err)
		@warn err if err

	compile: (callback) ->
		await exec "mkdir -p #{config.output}", defer(err)
		@die err if err
		


# Javascript build
compile_js = (callback) ->
	conf = Config.coffee
	console.log 'Compiling Coffee-script'
	sources = conf.client.source.join ' '
	exec "iced -c -o #{conf.client.output} #{sources}", wfn callback

stitch_js = (callback) ->
	conf = Config.coffee
	console.log 'Stitching files'
	pkgc = 
		paths: [conf.client.output]
		dependencies: conf.deps

	pkg = stitch.createPackage pkgc

	pkg.compile wfn (err, source) ->
		filename = conf.minify.source
		fs.writeFile conf.minify.source, source, wfn callback

minify_js = (callback) ->
	conf = Config.coffee
	console.log 'Minifying'
	spawn = require('child_process').spawn
	#exec doesn't seem to work for uglify...
	ret = spawn 'uglifyjs', ['-o', conf.minify.output, conf.minify.source]
	ret.on 'exit', (code) ->
		if code != 0
			if code == 127
				console.log 'uglifyjs not found. use `npm install -g uglifyjs` to install.'
			else
				console.log 'Uglify error: ', code
			process.exit -1
			return 
		if conf.minify.remove_source 
			console.log 'Removing ', conf.minify.source
			fs.unlinkSync conf.minify.source
		callback?()

build_js = (callback) ->
	await compile_js defer()
	await stitch_js defer()
	await minify_js defer()
	callback?()


#Stylus build

compile_stylus = (callback) ->
	conf = Config.stylus
	console.log 'Compiling stylus files'
	sources = conf.client.source.join ' '
	exec "stylus -o #{conf.client.output} #{sources}", wfn callback

stitch_css = (callback) ->
	conf = Config.stylus

	await all_files conf.deps, defer(err, allDepFiles)
	return bail err if err

	await all_files conf.client.output, defer(err, allClientFiles)
	return bail err if err

	allFiles = allDepFiles.concat allClientFiles

	console.log conf.minify.source
	dest = path.join __dirname, conf.minify.source

	console.log 'dest is ', dest
	
	#stitch all files into conf.minify.source (build/release/css)
	stitch_files allFiles, dest, callback


#Stylus build 
build_stylus = (callback) ->
	conf = Config.stylus

	await compile_stylus defer(err)
	return console.log err if err

	await stitch_css defer(err)


create_build_dirs: ->
	structure = []
	structure.push 'build/release'
	structure.push Config.coffee.client.output
	structure.push Config.stylus.client.output


task 'build', 'Build application', (args) ->

	console.log 'Building coffeescript...'
	await build_js defer()

	console.log 'Building stylus...'

	await build_stylus defer()

	console.log 'Done.'

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

make_dirs = (structure) ->
	#create directories
	dlist = structure.split '\n'

	for dir in dlist
		console.log 'Creating ', dir

		try
			fs.mkdirSync dir 
		catch e
			console.log '..failed: ', e

task 'mkdirs', 'Create the directory structure', ->

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
	make_dirs structure








