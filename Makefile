# $Id: Makefile,v 1.12 2005/07/05 20:05:26 carregal Exp $

include ./config

T_START= src/t_xavante_start.lua
XAVANTE_START= src/xavante_start.lua
COXPCALL_LUAS = src/coxpcall/coxpcall.lua
SAJAX_LUAS = src/sajax/sajax.lua
XAVANTE_LUAS= src/xavante/cgiluahandler.lua src/xavante/config.lua src/xavante/filehandler.lua src/xavante/httpd.lua src/xavante/mime.lua src/xavante/redirecthandler.lua src/xavante/server.lua
XAVANTE_CONFIG = src/xavante/config.lua
WEBS= web/index.lp web/test.lp
DOCS= doc/us/index.html doc/us/license.html doc/us/manual.html doc/us/sajax.html doc/us/xavante.gif
IMGS= web/img/test.jpg web/img/xavante.gif

$(XAVANTE_START) build:
	sed -e "s|\[\[LUA_PATH\]\]|\[\[$(LUA_PATH)\]\]|" -e "s|\[\[LUA_CPATH\]\]|\[\[$(LUA_CPATH)\]\]|" -e "s|\[\[XAVANTE_WEB\]\]|\[\[$(XAVANTE_WEB)\]\]|" < $(T_START) > $(XAVANTE_START)
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
	mkdir $(DIST_DIR)/sajax
	cp $(SAJAX_LUAS) $(DIST_DIR)/sajax
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
	mkdir -p $(LUA_DIR)/coxpcall
	cp $(COXPCALL_LUAS) $(LUA_DIR)/coxpcall
	mkdir -p $(LUA_DIR)/sajax
	cp $(SAJAX_LUAS) $(LUA_DIR)/sajax
	mkdir -p $(LUA_DIR)/xavante
	cp $(XAVANTE_LUAS) $(LUA_DIR)/xavante
	cp $(XAVANTE_START) $(LUA_DIR)
	mkdir -p $(XAVANTE_CONF)
	cp $(XAVANTE_CONFIG) $(XAVANTE_CONF)
	mkdir -p $(XAVANTE_WEB)
	cp $(WEBS) $(XAVANTE_WEB)
	mkdir -p $(XAVANTE_WEB)/doc
	cp $(DOCS) $(XAVANTE_WEB)/doc
	mkdir -p $(XAVANTE_WEB)/img
	cp $(IMGS) $(XAVANTE_WEB)/img
	ln -sf $(LUA_DIR) $(XAVANTE_LUA)

clean:
	rm -f $(XAVANTE_START)
