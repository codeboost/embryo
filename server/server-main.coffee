express = require 'express'
conf = require '../server-config.coffee'
path = require 'path'

if process.argv[2] == 'production'
	conf.server.production = true

$dir = (dir) ->
	path.normalize __dirname + '/..' + dir

init = ->

	if conf.server.production
		console.log 'Starting server in PRODUCTION mode'
		buildDir = $dir '/build/debug'

	else
		console.log 'Starting server in DEBUG mode'
		buildDir = $dir '/build/release'

	console.log 'Current configuration: ', conf

	app = express.createServer()
	app.configure ->
		app.use express.bodyParser()
		app.use express.cookieParser()
		app.use express.static $$ '/assets'
		app.use express.session
			secret: '*23hhU9$!7Np.'
			store: sessionStore
			cookie: 
				maxAge: 243600301000 #24 * 3600 * 30 * 1000
		app.set 'views', $dir '/views'
		app.set 'view engine', 'jade'
		app.set 'view options', layout: false

		app.dynamicHelpers
			isProduction: -> conf.server.production 

	app.get '/js/*', (req, res) ->
		res.sendfile buildDir + '/' + req.params[0]

	app.get '/css/*', (req, res) ->
		res.sendfile buildDir + '/' + req.params[0]