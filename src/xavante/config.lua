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
-- optional /conf/xavante/config.lua file. If it does not exist, Xavante loads
-- the default /bin/xavante/config.lua file.
--
-- Authors: Javier Guerra and Andre Carregal
-- Copyright (c) 2004-2005 Kepler Project
-------------------------------------------------------------------------------
require "xavante.filehandler"
require "xavante.cgiluahandler"
require "xavante.redirecthandler"
require "xavante.davhandler"
require "xavante.davFileRepository"
require "xavante.davFileProps"

local davSource = xavante.davFileRepository.makeSource {
	rootDir = "/home/javier/davserver/",
}

local davProps = xavante.davFileProps.makeProps {
	rootDir = "/home/javier/davserver/.PROPS/",
}

local simplerules = {
    -- URL remapping example
    {match = "/", with = xavante.redirecthandler, params = {"index.lp"}}, 
    -- filehandler example
    {match = "/*", with = xavante.filehandler, params = {baseDir = xavante.webdir()}},
    -- cgiluahandler example
    {match = {"/*.lp", "/*.lua"},  with = xavante.cgiluahandler.makeHandler (xavante.webdir())},

	-- davhandler example
	{match = {"/dav/", "/dav/*"}, with = xavante.davhandler.makeHandler (davSource, davProps) },
}

xavante.HTTP{
    server = {host = "*", port = 80},
    
    defaultHost = {
    	rules = simplerules
    },
}