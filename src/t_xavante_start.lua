#!/usr/local/bin/lua
-------------------------------------------------------------------------------
-- Starts the Xavante Web server.
--
-- See /bin/xavante/config.lua for configuration details.
--
-- Authors: Javier Guerra and Andre Carregal
-- Copyright (c) 2004-2005 Kepler Project
-------------------------------------------------------------------------------

-- Physical location of Xavante file structure. The default structure assumes
-- that the bin, conf and web directories are under the same directory
local XAVANTE_HOME = [[XAVANTE_HOME]]
local XAVANTE_BIN  = [[XAVANTE_BIN]]  -- used by require
local XAVANTE_CONF = [[XAVANTE_CONF]] -- configuration files
local XAVANTE_WEB  = [[XAVANTE_WEB]]  -- documents and scripts

-- compatibility code for Lua version 5.0 providing 5.1 behavior
if string.find (_VERSION, "Lua 5.0") and not package then
	if not LUA_PATH then
		LUA_PATH = [[LUA_PATH]]
	end
	require"compat-5.1"
	package.cpath = [[LUA_CPATH]]
end

require "xavante.server"

xavante.setwebdir(XAVANTE_WEB)

-------------------------------------------------------------------------------
-- Loads the configuration file and starts Xavante
-------------------------------------------------------------------------------
xavante.start(check_exit)
