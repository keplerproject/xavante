#!LUA_INTERPRETER
-------------------------------------------------------------------------------
-- Starts the Xavante Web server.
--
-- See xavante/config.lua and the online documentation for configuration details.
--
-- Authors: Javier Guerra and Andre Carregal
-- Copyright (c) 2004-2006 Kepler Project
-------------------------------------------------------------------------------

--- compatibility code for Lua version 5.0 providing 5.1 behavior
if string.find (_VERSION, "Lua 5.0") and not _COMPAT51 then
	if not LUA_PATH then
		LUA_PATH = [[LUA_PATH]]
	end
	require"compat-5.1"
	package.cpath = [[LUA_CPATH]]
end

XAVANTE_WEB = XAVANTE_WEB or [[XAVANTE_WEB]]

require "xavante.server"

-------------------------------------------------------------------------------
-- Loads the configuration file and starts Xavante
--
-- XAVANTE_ISFINISHED and XAVANTE_TIMEOUT are optional globals that can
-- control how Xavante will behave when being externally controlled.
-- XAVANTE_ISFINISHED is a function to be called on every step of Xavante,
-- XAVANTE_TIMEOUT is the timeout to be used by Copas.
-------------------------------------------------------------------------------
xavante.start(XAVANTE_ISFINISHED, XAVANTE_TIMEOUT)
