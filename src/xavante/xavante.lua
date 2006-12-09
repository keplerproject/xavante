-------------------------------------------------------------------------------
-- Xavante main module
--
-- Handles HTTP 1.1 requests and responses with Copas.
-- Uses CGILua as native template engine.
--
-- See xavante/config.lua for configuration details.
--
-- Authors: Javier Guerra and Andre Carregal
-- Copyright (c) 2004-2006 Kepler Project
--
-- $Id: xavante.lua,v 1.4 2006/12/09 03:23:48 mascarenhas Exp $
-------------------------------------------------------------------------------
module ("xavante", package.seeall)

require "copas"
require "xavante.httpd"
require "string"
require "xavante.ruleshandler"
require "xavante.vhostshandler"

-- Meta information is public even begining with an "_"
_COPYRIGHT   = "Copyright (C) 2004-2006 Kepler Project"
_DESCRIPTION = "A Copas based Lua Web server with CGILua support"
_VERSION     = "Xavante 1.2"

local _startmessage = function (ports)
  print(string.format("Xavante started on port(s) %s", table.concat(ports, ", ")))
end

local function _buildRules(rules)
    local rules_table = {}
    for _, rule in ipairs(rules) do
        local handler
        if type (rule.with) == "function" then
	    if rule.params then
	      handler = rule.with(rule.params)
	    else
	      handler = rule.with
	    end
        elseif type (rule.with) == "table" then
            handler = rule.with.makeHandler(rule.params)
        else
            error("Error on config.lua. The rule has an invalid 'with' field.")
        end
        local match = rule.match
        if type(match) == "string" then
            match = {rule.match}
	end
        for _, mask in ipairs(match) do
	    rules_table[mask] = handler
        end
    end
    return rules_table
end

-------------------------------------------------------------------------------
-- Sets startup message
-------------------------------------------------------------------------------
function start_message(msg)
	_startmessage = msg
end

-------------------------------------------------------------------------------
-- Register the server configuration
-------------------------------------------------------------------------------
function HTTP(config)
    -- normalizes the configuration
    config.server = config.server or {host = "*", port = 80}
    
    local vhosts_table = {}

    if config.defaultHost then
        vhosts_table[""] = xavante.ruleshandler(_buildRules(config.defaultHost.rules))
    end

    if type(config.virtualhosts) == "table" then
        for hostname, host in pairs(config.virtualhosts) do
	    vhosts_table[hostname] = xavante.ruleshandler(_buildRules(host.rules))
        end
    end

    xavante.httpd.handle_request = xavante.vhostshandler(vhosts_table)
    xavante.httpd.register(config.server.host, config.server.port, _VERSION)
end

-------------------------------------------------------------------------------
-- Starts the server
-------------------------------------------------------------------------------
function start(isFinished, timeout)
    local res, err = pcall(require, "xavante.config")
    if not res then
        error("Error loading config.lua" .. err)
    end
    _startmessage(xavante.httpd.get_ports())
    while true do
      if isFinished and isFinished() then break end
      copas.step(timeout)
    end
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
