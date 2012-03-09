
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


Server:
	mongoose
	socket.io
	skull.io
	express
	jade

Client:
	Backbone
	Stylus


