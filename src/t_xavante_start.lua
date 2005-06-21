#!/usr/local/bin/lua50
-------------------------------------------------------------------------------
-- Starts the Xavante Web server.
--
-- See xavante/config.lua for configuration details.
--
-- Authors: Javier Guerra and Andre Carregal
-- Copyright (c) 2004-2005 Kepler Project
-------------------------------------------------------------------------------

local LIB_EXT      = [[LIB_EXT]]
local XAVANTE_HOME = [[XAVANTE_HOME]]
local XAVANTE_BIN  = XAVANTE_HOME.."/bin/"  
local XAVANTE_CONF = XAVANTE_HOME.."/conf/"
local XAVANTE_LUA  = XAVANTE_HOME.."/lua/"
local XAVANTE_WEB  = XAVANTE_HOME.."/web/"

--- compatibility code for Lua version 5.0 providing 5.1 behavior
if string.find (_VERSION, "Lua 5.0") and not _COMPAT51 then
	if not LUA_PATH then
		LUA_PATH = XAVANTE_CONF.."?.lua;"..
                   XAVANTE_LUA.."?.lua;"..
                   XAVANTE_LUA.."?/?.lua;"..
                   XAVANTE_LUA.."?/init.lua;"
	end
	require"compat-5.1"
	package.cpath = XAVANTE_BIN.."?."..LIB_EXT
end

require "xavante.server"

xavante.setwebdir(XAVANTE_WEB)

-------------------------------------------------------------------------------
-- Loads the configuration file and starts Xavante
--
-- XAVANTE_ISFINISHED and XAVANTE_TIMEOUT are optional globals that can
-- control how Xavante will behave when externally controlled.
-------------------------------------------------------------------------------
xavante.start(XAVANTE_ISFINISHED, XAVANTE_TIMEOUT)
