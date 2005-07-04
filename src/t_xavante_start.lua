#!/usr/local/bin/lua50
-------------------------------------------------------------------------------
-- Starts the Xavante Web server.
--
-- See xavante/config.lua for configuration details.
--
-- Authors: Javier Guerra and Andre Carregal
-- Copyright (c) 2004-2005 Kepler Project
-------------------------------------------------------------------------------

--- compatibility code for Lua version 5.0 providing 5.1 behavior
if string.find (_VERSION, "Lua 5.0") and not _COMPAT51 then
	if not LUA_PATH then
		LUA_PATH = [[LUA_PATH]]
	end
	require"compat-5.1"
	package.cpath = [[LUA_CPATH]]
end

require "xavante.server"

xavante.setwebdir([[XAVANTE_WEB]])

-------------------------------------------------------------------------------
-- Loads the configuration file and starts Xavante
--
-- XAVANTE_ISFINISHED and XAVANTE_TIMEOUT are optional globals that can
-- control how Xavante will behave when externally controlled.
-------------------------------------------------------------------------------
xavante.start(XAVANTE_ISFINISHED, XAVANTE_TIMEOUT)
