# $Id: Makefile,v 1.6 2005/03/24 18:13:31 tomas Exp $

LUA_DIR= /usr/local/share/lua/5.0
LUA_LIBDIR= /usr/local/lib/lua/5.0
XAVANTE_HOME= /usr/local/xavante
XAVANTE_WEB= $(XAVANTE_HOME)/web
XAVANTE_BIN= $(XAVANTE_HOME)/bin
XAVANTE_LUADIR= $(LUA_DIR)/xavante
XAVANTE_LIBDIR= $(LUA_LIBDIR)
# OS extension for dynamic libraries
LIB_EXT= .so
#LIB_EXT= .dylib
# Lua paths
LUA_PATH= $(LUA_DIR)/?.lua;$(LUA_DIR)/?/?.lua
LUA_CPATH= $(XAVANTE_LIBDIR)/?$(LIB_EXT);$(XAVANTE_LIBDIR)/lib?$(LIB_EXT)

VERSION= 1.1b
PKG = xavante-$(VERSION)
DIST_DIR= $(PKG)
TAR_FILE= $(PKG).tar.gz
ZIP_FILE= $(PKG).zip

T_START= src/t_xavante_start.lua
XAVANTE_START= src/xavante_start.lua
COXPCALL_LUAS = src/coxpcall/coxpcall.lua
XAVANTE_LUAS= src/xavante/cgiluahandler.lua src/xavante/config.lua src/xavante/filehandler.lua src/xavante/httpd.lua src/xavante/mime.lua src/xavante/redirecthandler.lua src/xavante/server.lua
WEBS= web/index.lp web/loop.lp web/test.lp
DOCS= doc/us/index.html doc/us/license.html doc/us/manual.html doc/us/xavante.gif
IMGS= web/img/test.jpg web/img/xavante.gif

$(XAVANTE_START) build:
	sed -e "s|\[\[XAVANTE_HOME\]\]|\[\[$(XAVANTE_HOME)\]\]|" -e "s|\[\[XAVANTE_BIN\]\]|\[\[$(XAVANTE_BIN)\]\]|" -e "s|\[\[XAVANTE_WEB\]\]|\[\[$(XAVANTE_WEB)\]\]|" -e "s|\[\[LUA_PATH\]\]|\[\[$(LUA_PATH)\]\]|" -e "s|\[\[LUA_CPATH\]\]|\[\[$(LUA_CPATH)\]\]|" < $(T_START) > $(XAVANTE_START)
	chmod +x $(XAVANTE_START)

dist: dist_dir
	tar -czf $(TAR_FILE) $(DIST_DIR)
	zip -rq $(ZIP_FILE) $(DIST_DIR)/*
	rm -rf $(DIST_DIR)

dist_dir:
	mkdir $(DIST_DIR)
	cp Makefile config $(DIST_DIR)
	mkdir $(DIST_DIR)/coxpcall
	cp $(COXPCALL_LUAS) $(DIST_DIR)/coxpcall
	mkdir $(DIST_DIR)/xavante
	cp $(XAVANTE_LUAS) $(DIST_DIR)/xavante
	mkdir $(DIST_DIR)/web
	cp $(WEBS) $(DIST_DIR)/web
	mkdir $(DIST_DIR)/web/doc
	cp $(DOCS) $(DIST_DIR)/web/doc
	mkdir $(DIST_DIR)/web/img
	cp $(IMGS) $(DIST_DIR)/web/img

install: $(XAVANTE_START)
	mkdir -p $(LUA_DIR)
	mkdir -p $(XAVANTE_LUADIR)
	cp $(XAVANTE_LUAS) $(XAVANTE_LUADIR)
	mkdir -p $(XAVANTE_BIN)
	cp $(XAVANTE_START) $(XAVANTE_BIN)
	mkdir -p $(XAVANTE_WEB)
	cp $(WEBS) $(XAVANTE_WEB)
	mkdir -p $(XAVANTE_WEB)/doc
	cp $(DOCS) $(XAVANTE_WEB)/doc
	mkdir -p $(XAVANTE_WEB)/img
	cp $(IMGS) $(XAVANTE_WEB)/img

clean:
	rm -f $(XAVANTE_START)
