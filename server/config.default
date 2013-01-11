$BuildConfig = require './build/config'

module.exports = 
	appName: 'My Project'
	appVersion: '0.1'
	pageTitle: 'My Project Web site'
	server:
		listen:
			host: '127.0.0.1'
			port: 80
	db:
		path:  'mongodb://localhost/myproject'

	paths:
		assets: 'assets'
		views: 'views'
		storage: 'storage'
		userStorage: 'storage/user'
		tmp: 'storage/tmp'

		debug:
			js: $BuildConfig.coffee.compile.output		#get '/js/*'
			css: $BuildConfig.stylus.compile.output		#get '/css/*'
			appJS: $BuildConfig.coffee.stitch.output	#get '/app.js'
			appCSS: $BuildConfig.stylus.stitch.output	#get '/app.css'

		release:
			js: $BuildConfig.coffee.compile.output		#'' = hide original source
			css: $BuildConfig.stylus.compile.output		#'' = hide original source
			appJS: $BuildConfig.coffee.minify.output	#get '/app.js'
			appCSS: $BuildConfig.stylus.minify.output #get '/app.css'



