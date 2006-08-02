-------------------------------------------------------------------------------
-- Xavante configuration file.
--
-- The configuration defines the Xavante environment
-- Commented fields are optional and assume default values
--
-- Xavante defines virtualhosts for each site running with Xavante.
-- Each virtualhost can define the handlers for specific files extensions.
-- Xavante currently offers a fileHandler and a CGILuaHandler.
--
-- Xavante configuration can be redefined on the default file structure by the
-- the use of LUA_PATH, see more details in the online documentation.
--
-- Authors: Javier Guerra and Andre Carregal
-- Copyright (c) 2004-2006 Kepler Project
---
-- $Id: config.lua,v 1.21 2006/08/02 13:30:07 carregal Exp $
------------------------------------------------------------------------------
require "xavante.filehandler"
require "xavante.cgiluahandler"
require "xavante.redirecthandler"

-- Define here where HTML and CGILua scripts are located
local webDir = XAVANTE_WEB

local simplerules = {
    { -- URL remapping example
    match = "/",
    with = xavante.redirecthandler,
    params = {"index.lp"}
    }, 

    
    { -- filehandler example
    match = "/*",
    with = xavante.filehandler,
    params = {baseDir = webDir}
    },
     
    { -- cgiluahandler example
    match = {"/*.lp", "/*.lua"},
    with = xavante.cgiluahandler.makeHandler (webDir)
    },
}

xavante.start_message(function (ports)
    local date = os.date("[%Y-%m-%d %H:%M:%S]")
    print(string.format("%s Xavante started on port(s) %s",
      date, table.concat(ports, ", ")))
  end)

xavante.HTTP{
    server = {host = "*", port = 80},
    
    defaultHost = {
    	rules = simplerules
    },
}
