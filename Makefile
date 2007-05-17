# $Id: Makefile,v 1.35 2007/05/17 23:06:43 hisham Exp $

CONFIG= ./config

include $(CONFIG)

T_START= src/t_xavante_start.lua
XAVANTE_START= src/xavante_start.lua
T_INIT= src/t_xavante_init.lua
INIT= src/xavante_init.lua
COXPCALL_LUAS = src/coxpcall/coxpcall.lua
SAJAX_LUAS = src/sajax/sajax.lua
ROOT_LUAS = src/xavante/xavante.lua 
XAVANTE_LUAS= src/xavante/cgiluahandler.lua src/xavante/config.lua src/xavante/encoding.lua src/xavante/filehandler.lua src/xavante/httpd.lua src/xavante/mime.lua src/xavante/redirecthandler.lua src/xavante/vhostshandler.lua src/xavante/indexhandler.lua src/xavante/urlhandler.lua src/xavante/ruleshandler.lua
XAVANTE_CONFIG = src/xavante/config.lua
WEBS= web/index.lp web/test.lp
DOCS= doc/us/index.html doc/us/license.html doc/us/manual.html doc/us/sajax.html doc/us/xavante.gif
IMGS= web/img/test.jpg web/img/xavante.gif

all: install

$(INIT): $(T_INIT)
	sed -e "s|\[\[LUABASE51\]\]|\[\[$(LUA_DIR)\]\]|" -e "s|\[\[LIBBASE51\]\]|\[\[$(LUA_LIBDIR)\]\]|" -e "s|\[\[XAVANTE_CONF\]\]|\[\[$(XAVANTE_CONF)\]\]|" -e "s|\[\[LIB_EXT\]\]|\[\[so\]\]|" -e "s|\[\[XAVANTE_WEB\]\]|\[\[$(XAVANTE_WEB)\]\]|" < $(T_INIT) > $(INIT)

$(XAVANTE_START): $(T_START) $(INIT)
	sed -e "s|\[\[XAVANTE_INIT\]\]|\[\[$(XAVANTE_INIT)\]\]|" < $(T_START) > $(XAVANTE_START)
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
	cp $(ROOT_LUAS) $(XAVANTE_LUAS) $(DIST_DIR)/src/xavante
	mkdir -p $(DIST_DIR)/web
	cp $(WEBS) $(DIST_DIR)/web
	mkdir -p $(DIST_DIR)/web/doc
	cp $(DOCS) $(DIST_DIR)/web/doc
	mkdir -p $(DIST_DIR)/web/img
	cp $(IMGS) $(DIST_DIR)/web/img

install:
	mkdir -p $(LUA_DIR)/xavante
	cp $(ROOT_LUAS) $(COXPCALL_LUAS) $(SAJAX_LUAS) $(LUA_DIR)
	cp $(XAVANTE_LUAS) $(LUA_DIR)/xavante

install-start: $(XAVANTE_START) 
	mkdir -p $(SYS_BINDIR)
	cp $(XAVANTE_START) $(SYS_BINDIR)

install-config:
	mkdir -p $(XAVANTE_CONF)/xavante
	if [ ! -e $(XAVANTE_CONF)/xavante/$(XAVANTE_CONFIG) ] ; then cp $(XAVANTE_CONFIG) $(XAVANTE_CONF)/xavante; fi
	ln -sf $(LUA_DIR) $(XAVANTE_LUA)

install-init: $(INIT)
	if [ ! -e $(XAVANTE_INIT) ] ; then cp $(INIT) $(XAVANTE_INIT); fi

install-web:
	cp -r web/ $(XAVANTE_WEB)
	mkdir -p $(XAVANTE_WEB)/doc
	cp $(DOCS) $(XAVANTE_WEB)/doc

standalone: install \
            install-start \
            install-config \
            install-init \
            install-web

clean:
	rm -f $(XAVANTE_START)
	rm -f $(INIT)

