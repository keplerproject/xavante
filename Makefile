# $Id: Makefile,v 1.42 2007/11/17 14:15:23 carregal Exp $

CONFIG= ./config

include $(CONFIG)

XAVANTE_START= src/xavante_start
COXPCALL_LUAS = src/coxpcall/coxpcall.lua
SAJAX_LUAS = src/sajax/sajax.lua
ROOT_LUAS = src/xavante/xavante.lua 
XAVANTE_LUAS= src/xavante/cgiluahandler.lua src/xavante/encoding.lua src/xavante/filehandler.lua src/xavante/httpd.lua src/xavante/mime.lua src/xavante/patternhandler.lua src/xavante/redirecthandler.lua src/xavante/vhostshandler.lua src/xavante/indexhandler.lua src/xavante/urlhandler.lua src/xavante/ruleshandler.lua
DOCS= doc/us/index.html doc/us/license.html doc/us/manual.html doc/us/sajax.html doc/us/xavante.gif

all:

install:
	mkdir -p $(LUA_DIR)/xavante
	cp $(ROOT_LUAS) $(COXPCALL_LUAS) $(SAJAX_LUAS) $(LUA_DIR)
	cp $(XAVANTE_LUAS) $(LUA_DIR)/xavante

clean: