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
-- Copyright (c) 2004-2005 Kepler Project
-------------------------------------------------------------------------------
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

xavante.start_message("Xavante started on port %i")

xavante.HTTP{
    server = {host = "*", port = 80},
    
    defaultHost = {
    	rules = simplerules
    },
}
