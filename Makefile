LUA_DIR= /usr/local/share/lua/5.0
XAVANTE_HOME= /usr/local/xavante
XAVANTE_WEB= $(XAVANTE_HOME)/web
XAVANTE_LOGS= $(XAVANTE_HOME)/logs
XAVANTE_CONF= $(XAVANTE_HOME)/conf
XAVANTE_BIN= $(XAVANTE_HOME)/bin
XAVANTE_LUADIR= $(LUA_DIR)/xavante
XAVANTE_LIBDIR= /usr/local/lib/lua/5.0
# OS extension for dynamic libraries
LIB_EXT= .so
#LIB_EXT= .dylib
# Lua paths
LUA_PATH= $(XAVANTE_CONF)/?.lua;$(LUA_DIR)/?.lua;$(LUA_DIR)/?/?.lua
LUA_CPATH= $(XAVANTE_LIBDIR)/?$(LIB_EXT);$(XAVANTE_LIBDIR)/lib?$(LIB_EXT)

VERSION= 1.1b
PKG = xavante-$(VERSION)
DIST_DIR= $(PKG)
TAR_FILE= $(PKG).tar.gz
ZIP_FILE= $(PKG).zip
LUAS= coxpcall/coxpcall.lua
XAVANTE_LUAS= xavante/cgiluahandler.lua xavante/conf.lua xavante/filehandler.lua xavante/httpd.lua xavante/mime.lua xavante/server.lua
XAVANTE_START= xavante_start.lua
T_START= t_xavante_start.lua
WEBS= web/default.lp web/loop.lp web/test.lp
DOCS= web/doc/index.html web/doc/license.html
IMGS= web/img/test.jpg web/img/xavante.gif
SRCS= Makefile $(LUAS) $(XAVANTE_LUAS) $(DOCS) \
	xavante_start.bat $(XAVANTE_START)

$(XAVANTE_START):
	sed -e "s|\[\[XAVANTE_HOME\]\]|\[\[$(XAVANTE_HOME)\]\]|" -e "s|\[\[XAVANTE_BIN\]\]|\[\[$(XAVANTE_BIN)\]\]|" -e "s|\[\[XAVANTE_CONF\]\]|\[\[$(XAVANTE_CONF)\]\]|" -e "s|\[\[XAVANTE_LOGS\]\]|\[\[$(XAVANTE_LOGS)\]\]|" -e "s|\[\[XAVANTE_WEB\]\]|\[\[$(XAVANTE_WEB)\]\]|" -e "s|\[\[LUA_PATH\]\]|\[\[$(LUA_PATH)\]\]|" -e "s|\[\[LUA_CPATH\]\]|\[\[$(LUA_CPATH)\]\]|" < $(T_START) > $(XAVANTE_START)
	chmod +x $(XAVANTE_START)

dist: dist_dir
	tar -czf $(TAR_FILE) $(DIST_DIR)
	zip -rq $(ZIP_FILE) $(DIST_DIR)/*
	rm -rf $(DIST_DIR)

dist_dir:
	mkdir $(DIST_DIR)
	cp Makefile xavante.bat $(LUAS) $(T_START) $(DIST_DIR)
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
	cp $(LUAS) $(LUA_DIR)
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
	mkdir -p $(XAVANTE_LOGS)
	mkdir -p $(XAVANTE_CONF)
	mkdir -p $(XAVANTE_CONF)/xavante

clean:
	rm -f $(XAVANTE_START)
