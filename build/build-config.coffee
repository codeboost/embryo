#No trailing / after directory name!

dirs = exports.dirs = 
	release: 'build/release'
	debug: 'build/debug'

# Compile CoffeeScript
exports.coffee = 
	#1. Compile javascript: compiles .coffee files to javascript
	compile: 
		source: ['client/js']
		output: "#{dirs.debug}/js"

	#2. Stitch: dependency files 
	stitch:
		source: compile.output
		deps:[
			'assets/lib/js/jquery-1.7.1.min.js'
			'assets/lib/js/underscore.js'
			'assets/lib/js/backbone-0.9.1.js'
			'assets/lib/js/socket.io-0.8.7.js'
			'assets/lib/js/skull-client.js'
			'assets/lib/js/console-dummy.js'
		]
		output: "#{dirs.debug}/app.js"

	#3. Minify: minify app.js to app.min.js. Source is compile.output
	minify:
		source: stitch.output
		output: "#{dirs.release}/app.min.js"
		remove_source: true


# Compile Stylus 
exports.stylus = 
	#1. Compile stylus -> css
	compile:
		source: ['client/css']
		output: "#{dirs.debug}/css"

	#2. Stitch: CSS dependencies files. Inserted before the client CSS
	stitch: 
		source: compile.output
		deps: [
			'assets/lib/css/bootstrap-2.0.0.min.css'
		]
		output: "#{dirs.debug}/app.css"

	#3. Minify and output
	minify:
		source: stitch.output
		output: "{dirs.release}/app.min.css"
		remove_source: true
