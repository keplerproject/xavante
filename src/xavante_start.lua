-------------------------------------------------------------------------------
-- Starts the Xavante Web server.
--
-- See xavante/xavante.conf for configuration details.
--
-- Author: Andre Carregal (carregal@keplerproject.org)
--
-- Copyright (c) 2004-2005 Kepler Project
-------------------------------------------------------------------------------

-- Library extension for the platform used
local LIB_EXT      = [[.dll]]

-- Physical location of Xavante file structure. The default structure assumes
-- that the bin, conf, log and web directories are under the same directory
local XAVANTE_HOME = [[d:/xavante]]
local XAVANTE_BIN  = XAVANTE_HOME..[[/bin]]  -- used by require
local XAVANTE_CONF = XAVANTE_HOME..[[/conf]] -- configuration files
local XAVANTE_WEB  = XAVANTE_HOME..[[/web]]  -- documents and scripts

-- compatibility code for Lua version 5.0 providing 5.1 behavior
if string.find (_VERSION, "Lua 5.0") and not package then
	if not LUA_PATH then
		LUA_PATH = XAVANTE_CONF.."/?.lua;"..XAVANTE_BIN.."/?.lua;"..XAVANTE_BIN.."/?/?.lua"
	end
	require"compat-5.1"
	package.cpath = XAVANTE_BIN.."/?"..LIB_EXT..";"..
	                XAVANTE_BIN.."/lib?"..LIB_EXT
end

require "xavante.server"

xavante.setwebdir(XAVANTE_WEB)

-------------------------------------------------------------------------------
-- Loads the configuration file and starts Xavante
-------------------------------------------------------------------------------
xavante.start()
