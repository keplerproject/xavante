-------------------------------------------------------------------------------
-- Xavante main module
--
-- Handles HTTP 1.1 requests and responses with Copas
-- Uses CGILua as native template engine.
--
-- See xavante/config.lua for configuration details.
--
-- Author: Andre Carregal and Javier Guerra
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

local function _addRules(rules, hostname)
    for _, rule in ipairs(rules) do
        local handler
        if type (rule.with) == "function" then
            handler = rule.with
        else
            handler = rule.with.makeHandler(rule.params)
        end
        local match = rule.match
        if type(match) == "string" then
            match = {rule.match}
        end
        for _, mask in ipairs(match) do
            httpd.addHandler (hostname, mask, handler)
        end
    end
end
-------------------------------------------------------------------------------
-- Register the server configuration
-------------------------------------------------------------------------------
function HTTP(config)
    config.server = config.server or {host = "*", port = 80}
    xavante.httpd.register(config.server.host, config.server.port, _NAME.."/".._VERSION)
    if config.defaultHost then
        _addRules(config.defaultHost.rules, "_")
    end
    for hostname, host in pairs(config.virtualhosts) do
        _addRules(host.rules, hostname)
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