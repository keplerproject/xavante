-------------------------------------------------------------------------------
-- Xavante main module
--
-- Handles HTTP 1.1 requests and responses with Copas
-- Uses CGILua as native template engine.
--
-- See xavante/config.lua for configuration details.
--
-- Author: Andre Carregal, Javier Guerra
-- Copyright (c) 2004-2005 Kepler Project
-------------------------------------------------------------------------------
module ("xavante")

require "copas"
require "coxpcall"

pcall  = copcall
xpcall = coxpcall

require "xavante.httpd"

-- Meta information is public even begining with an "_"
_COPYRIGHT   = "Copyright (C) 2004-2005 Kepler Project"
_DESCRIPTION = "A coroutine based Lua HTTP server with CGILua support"
_NAME        = "Xavante"
_VERSION     = "1.1 Beta"

local _defaulthost = "localhost"

-------------------------------------------------------------------------------
-- Register the server configuration
-------------------------------------------------------------------------------
function register(config)
  config.server = config.server or {host = "*", port = 8899}
  xavante.httpd.register(config.server.host, config.server.port, _NAME.."/".._VERSION)
  for hostname, host in pairs(config.virtualhosts) do
    for _, rule in ipairs(host.rules) do
        httpd.addHandler (nil, rule.match, rule.handler)
    end
  end
end

-------------------------------------------------------------------------------
-- Starts the server
-------------------------------------------------------------------------------
function start()
  require "xavante.config"
  copas.loop()
end

-------------------------------------------------------------------------------
-- Methods to define and return Xavante directory structure
-------------------------------------------------------------------------------

function webdir()
  return _webdir
end

function setwebdir(dir)
  _webdir = dir
end