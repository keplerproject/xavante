# $Id: Makefile,v 1.29 2006/12/10 00:52:23 mascarenhas Exp $

CONFIG= ./config

include $(CONFIG)

T_START= src/t_xavante_start.lua
XAVANTE_START= src/xavante_start.lua
T_INIT= src/t_kepler_init.lua
INIT= src/kepler_init.lua
COXPCALL_LUAS = src/coxpcall/coxpcall.lua
SAJAX_LUAS = src/sajax/sajax.lua
XAVANTE_LUAS= src/xavante/cgiluahandler.lua src/xavante/config.lua src/xavante/filehandler.lua src/xavante/httpd.lua src/xavante/mime.lua src/xavante/redirecthandler.lua src/xavante/xavante.lua src/xavante/vhostshandler.lua src/xavante/indexhandler.lua src/xavante/urlhandler.lua
XAVANTE_CONFIG = src/xavante/config.lua
WEBS= web/index.lp web/test.lp
DOCS= doc/us/index.html doc/us/license.html doc/us/manual.html doc/us/sajax.html doc/us/xavante.gif
IMGS= web/img/test.jpg web/img/xavante.gif

all: $(INIT) $(XAVANTE_START)

$(INIT): $(T_INIT)
	sed -e "s|\[\[LUABASE51\]\]|\[\[$(LUA_DIR)\]\]|" -e "s|\[\[LIBBASE51\]\]|\[\[$(LUA_LIBDIR)\]\]|" -e "s|\[\[XAVANTE_CONF\]\]|\[\[$(XAVANTE_CONF)\]\]|" -e "s|\[\[LIB_EXT\]\]|\[\[so\]\]|" -e "s|\[\[XAVANTE_WEB\]\]|\[\[$(XAVANTE_WEB)\]\]|" < $(T_INIT) > $(INIT)

$(XAVANTE_START) build: $(T_START) $(INIT)
	sed -e "s|\[\[KEPLER_INIT\]\]|\[\[$(KEPLER_INIT)\]\]|" < $(T_START) > $(XAVANTE_START)
	chmod +x $(XAVANTE_START)

dist: dist_dir
	tar -czf $(TAR_FILE) $(DIST_DIR)
	zip -rq $(ZIP_FILE) $(DIST_DIR)/*
	rm -rf $(DIST_DIR)

dist_dir:
	mkdir -p $(DIST_DIR)
	cp Makefile config $(DIST_DIR)
	mkdir -p $(DIST_DIR)/src
	cp $(T_START) $(DIST_DIR)/src
	mkdir -p $(DIST_DIR)/src/coxpcall
	cp $(COXPCALL_LUAS) $(DIST_DIR)/src/coxpcall
	mkdir -p $(DIST_DIR)/src/sajax
	cp $(SAJAX_LUAS) $(DIST_DIR)/src/sajax
	mkdir -p $(DIST_DIR)/src/xavante
	cp $(XAVANTE_LUAS) $(DIST_DIR)/src/xavante
	mkdir -p $(DIST_DIR)/web
	cp $(WEBS) $(DIST_DIR)/web
	mkdir -p $(DIST_DIR)/web/doc
	cp $(DOCS) $(DIST_DIR)/web/doc
	mkdir -p $(DIST_DIR)/web/img
	cp $(IMGS) $(DIST_DIR)/web/img

install:
	mkdir -p $(LUA_DIR)
	mkdir -p $(LUA_DIR)/coxpcall
	cp $(COXPCALL_LUAS) $(LUA_DIR)/coxpcall
	mkdir -p $(LUA_DIR)/sajax
	cp $(SAJAX_LUAS) $(LUA_DIR)/sajax
	mkdir -p $(LUA_DIR)/xavante
	cp $(XAVANTE_LUAS) $(LUA_DIR)/xavante

standalone: $(XAVANTE_START) $(INIT)
	mkdir -p $(LUA_DIR)
	mkdir -p $(LUA_DIR)/coxpcall
	cp $(COXPCALL_LUAS) $(LUA_DIR)/coxpcall
	mkdir -p $(LUA_DIR)/sajax
	cp $(SAJAX_LUAS) $(LUA_DIR)/sajax
	mkdir -p $(LUA_DIR)/xavante
	cp $(XAVANTE_LUAS) $(LUA_DIR)/xavante
	mkdir -p $(SYS_BINDIR)
	cp $(XAVANTE_START) $(SYS_BINDIR)
	mkdir -p $(XAVANTE_CONF)/xavante
	if [ ! -e $(XAVANTE_CONF)/xavante/$(XAVANTE_CONFIG) ] ; then cp $(XAVANTE_CONFIG) $(XAVANTE_CONF)/xavante; fi
	cp -r web/ $(XAVANTE_WEB)
	mkdir -p $(XAVANTE_WEB)/doc
	cp $(DOCS) $(XAVANTE_WEB)/doc
	ln -sf $(LUA_DIR) $(XAVANTE_LUA)
	if [ ! -e $(KEPLER_INIT) ] ; then cp $(INIT) $(KEPLER_INIT); fi

clean:
	rm -f $(XAVANTE_START)
	rm -f $(INIT)

