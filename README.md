Xavante
=======

Xavante is a Lua HTTP 1.1 Web server that uses a modular architecture based on
URI mapped handlers. Xavante currently offers a file handler, a redirect
handler and a WSAPI handler. Those are used for general files, URI remapping
and WSAPI applications respectively.

Xavante is free software and uses the same license as Lua.

You can install Xavante using LuaRocks:

    luarocks install xavante

The Xavante package provides just the Xavante libraries. To see Xavante in action
install wsapi-xavante from LuaRocks.

Dependencies
------------

Xavante dependencies can be separated by the used handlers:

* Lua 5.1, 5.2 or 5.3
* Copas 1.2.0
* LuaSocket 2.1
* LuaFileSystem 1.6 (file handler only)

The portability of Xavante is determined by its binary components
(LuaSocket and LuaFileSystem) and Lua itself. The other components are written
in Lua and are as portable as Lua itself.

Credits
-------

Xavante is maintained by Fábio Mascarenhas and the community of contributors.
See the GitHub logs for detailed credits.

Xavante circa 1.3 was implemented by Javier Guerra, André Carregal,
and Fabio Mascarenhas with the help of Ignacio Burgueño, Zachary P. Landau,
Mauricio Bomfim, Matthew Burke, Thomas Harning and others.

Xavante 1.2 was implemented by Javier Guerra, André Carregal,
Fabio Mascarenhas and Leonardo Godinho.

Xavante 1.1 was redesigned and implemented by Javier Guerra and André Carregal.
It merged Javier's work with luahttpd and André's work with Copas and Xavante 1.0.
luahttpd is now part of Xavante.

Xavante 1.0 was designed and implemented by André Carregal as part of the
Kepler Project with contributions from Renato Crivano and Danilo Tuler.
Xavante 1.0 development was sponsored by Fábrica Digital and Hands. 
