
Embryo is a template for web applications.
It includes the directory structure, libraries, a skeleton server implementation as well as a script
which can build the client-side files and produce a single minified .js and .css file.

The server can run the debug or release version of the site.
In debug mode, javascript and CSS files (compiled from coffee and stylus files) are accessible
in the browser.

Usage:
Clone this repository and remove the .git directory. 

	mkdir myproject
	git clone git@github.com:codeboost/embryo.git .
	rm -r .git/

Initialize the new project: Will install basic dependencies, create directories and create the server-config.coffee

	./init.sh


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