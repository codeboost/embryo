express = require 'express'
$Conf = require '../server-config.coffee'
path = require 'path'
mongoose = require 'mongoose'
buildConfig = require '../build/config.coffee'

if process.argv[2] == 'production' or process.argv[2] == 'release'
	$Conf.server.production = true

#Return normalized path for (dir)
#dir - path relative to server root
$dir = (dir) ->
	path.normalize path.join __dirname, '../', dir

#returns the currently selected path for js and css files 
$getPath = (dir) ->
	
	currentDirs = if $Conf.server.production then $Conf.paths.release else $Conf.paths.debug

	retPath = $dir switch dir
		when 'js' then currentDirs.js
		when 'css' then currentDirs.css
		when '/app.js' then currentDirs.appJS
		when '/app.css' then currentDirs.appCSS
		when 'views' then $Conf.paths.views
		when 'assets' then $Conf.paths.assets
		when 'storage' then $Conf.paths.storage
		when 'userStorage' then $Conf.paths.userStorage
		when 'tmp' then $Conf.paths.tmp

	return retPath

#Global which contains the current full paths for all asset directories
$Path = {}
$Path[dir] = $getPath(dir) for dir in ['js' 
'css'
'/app.js'
'/app.css' 
'views'
'assets'
'storage'
'userStorage'
'tmp'
]
exports.$Path = $Path

init = ->
	console.log 'Current configuration: ', $Conf


	if $Conf.server.production
		console.log 'Starting server in PRODUCTION mode'
	else
		console.log 'Starting server in DEBUG mode'

	console.log 'Connecting to database: ', $Conf.db.path
	mongoose.connect $Conf.db.path

	mongoose.connection.on 'error', (err) ->
		console.log 'FATAL: Database connection error. Please check if mongodb is running or edit configuration in server_config.coffee'
		process.exit -1

	sessionStore = new require('./sessionStore')()

	app = express.createServer()
	app.configure ->
		app.use express.bodyParser()
		app.use express.cookieParser()
		app.use express.static $Path.assets
		app.use express.session
			secret: '*23hhU9$!7Np.'
			store: sessionStore
			cookie: 
				maxAge: 243600301000 #24 * 3600 * 30 * 1000
		app.set 'views', $Path.view
		app.set 'view engine', 'jade'
		app.set 'view options', layout: false

		app.dynamicHelpers
			isProduction: -> $Conf.server.production 

	app.get '/', (req, res) ->
		res.render 'index'

	app.get '/js/*', (req, res) ->
		res.sendfile path.join $Path['js'], req.params[0]

	app.get '/css/*', (req, res) ->
		fileName = 
		res.sendfile path.join $Path['css'], req.params[0]

	app.get '/app.js', (req, res) ->
		res.sendfile $Path['/app.js']

	app.get '/app.css', (req, res) ->
		res.sendFile $Path['/app.css']

	app.get '/assets/*', (req, res) ->
		res.sendfile path.join $Path['assets'], req.params[0]

	app.get '/tmp/*', (req, res) ->
		res.sendfile path.join $Path['tmp'], req.params[0]

	app.get '/storage/*', (req, res) ->
		res.sendfile path.join $Path['storage'], req.params[0]

	app.get '/storage/user/*', (req, res) ->
		res.sendfile path.join $Path['userStorage'], req.params[0]

	console.log "Listening on #{$Conf.server.listen.host}:#{$Conf.server.listen.port}"
	return app.listen $Conf.server.listen.port, $Conf.server.listen.host


exports.start = init
