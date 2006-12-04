#!/usr/bin/env lua
-------------------------------------------------------------------------------
-- Starts the Xavante Web server.
--
-- See xavante/config.lua and the online documentation for configuration details.
--
-- Authors: Javier Guerra and Andre Carregal
-- Copyright (c) 2004-2006 Kepler Project
--
-- $Id: t_xavante_start.lua,v 1.23 2006/12/04 16:52:30 mascarenhas Exp $
-------------------------------------------------------------------------------

-- Kepler bootstrap
local bootstrap, err = loadfile(os.getenv("KEPLER_INIT") or [[KEPLER_INIT]])
if bootstrap then
  bootstrap()
else
  io.stderr:write(tostring(err))
  return nil
end

require "xavante"

-------------------------------------------------------------------------------
-- Loads the configuration file and starts Xavante
--
-- XAVANTE_ISFINISHED and XAVANTE_TIMEOUT are optional globals that can
-- control how Xavante will behave when being externally controlled.
-- XAVANTE_ISFINISHED is a function to be called on every step of Xavante,
-- XAVANTE_TIMEOUT is the timeout to be used by Copas.
-------------------------------------------------------------------------------
xavante.start(XAVANTE_ISFINISHED, XAVANTE_TIMEOUT)
