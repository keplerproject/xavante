#!LUA_INTERPRETER
-------------------------------------------------------------------------------
-- Starts the Xavante Web server.
--
-- See xavante/config.lua and the online documentation for configuration details.
--
-- Authors: Javier Guerra and Andre Carregal
-- Copyright (c) 2004-2006 Kepler Project
--
-- $Id: t_xavante_start.lua,v 1.16 2006/08/07 02:08:57 carregal Exp $
-------------------------------------------------------------------------------

dofile(os.getenv("KEPLER_INIT"))

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