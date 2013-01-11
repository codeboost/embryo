Embryo is a template for web applications.

It includes the directory structure, libraries, a skeleton server implementation as well as a script
which can build the client-side files and produce a single minified .js and .css file.

This project template is mostly for my personal use, specifically designed for realtime web applications
built with Backbone.js, socket.io and templated with Stylus. Node.js + mongodb backend.


The server can run the debug or release version of the site.
In debug mode, javascript and CSS files (compiled from coffee and stylus files) are accessible
in the browser.

Usage:
Clone this repository and remove the .git directory. 

	mkdir myproject
	git clone git@github.com:codeboost/embryo.git .
	rm -r .git/


Install the global tools (iced-coffee-script and uglify-js@1) and dependencies:
	npm install -g iced-coffee-script uglify-js@1
	npm install

Initialize the project (creates the directories and configurations):
	
	iced cake init


Now you can edit server-config.coffee and adjust the parameters. This file is not tracked by git (.gitignore) so you
can have different server-config.coffee files on different machines.


Finally, create the git repository for your new project:

	git init
	git add -A
	git commit -m 'Initial'


To build the client application, run:

	iced cake build


To start the server in release mode:

	iced server

To start the server in debug mode:

	iced server debug

Directory Structure:

	build
	  debug
	    js
	      javascript files, compiled from client/*.coffee
	    css
	      css files, compiled from client/css/*.stylus
	  release
	    app.css
	    app.js
	assets
	  lib
	    js
	      javascript libraries
	    css
	      stylesheet libraries
	  images
	    application specific images
	client
	  css 
	    Stylus files
	      "release: build/site/app.css
	      debug: build/site/css/*.css"
	  js 
	    coffee sources
	      "debug: compiled to /build/debug/js
	      release: compiled to /build/app.js"
	server
	  models
	    "symlinked to ../meeting/models"
	views
	storage
	  tmp
	  user
	    userId
	      small.jpg
	      large.jpg
	      files
