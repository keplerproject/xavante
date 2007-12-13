-----------------------------------------------------------------------------
-- Xavante CGILua handler
--
-- Authors: Javier Guerra and Andre Carregal
-- Copyright (c) 2004-2007 Kepler Project
--
-- $Id: cgiluahandler.lua,v 1.40 2007/12/13 22:01:00 mascarenhas Exp $
-----------------------------------------------------------------------------

require "wsapi.xavante"
require "wsapi.ringer"

module ("xavante.cgiluahandler", package.seeall)

local bootstrap = [[

_, package.path = remotedostring("return package.path")
_, package.cpath = remotedostring("return package.cpath")

function print(...)
  remotedostring("print(...)", ...)
end

io.stdout = {
  write = function (...)
    remotedostring("io.write(...)", ...)
  end
}

io.stderr = {
  write = function (...)
    remotedostring("io.stderr(...)", ...)
  end
}

]]

local function cgiluahandler (req, res, diskpath, options)
    -- gets the script name without any path
    local name = string.match(req.relpath, "/([^/]+%.[^/]+)")
    local name = string.gsub(name, "%.", "%%%.")
    -- gets the script name with path (SCRIPT_NAME)
    local script_name = string.match(req.relpath, "^(.-"..name..")")
    script_name = script_name or ""
    if options.checkFiles then
        if not lfs.attributes (diskpath .. "/"..script_name) then
            return options[404] (req, res)
        end
    end
    req.diskpath = diskpath
    -- Bootstrap code for Rings
    local bootstrap = bootstrap
    for _, v in ipairs (options.globals) do
        bootstrap = bootstrap..[[_, ]]..v..[[ = remotedostring("return ]]..v..[[")]].."\n"
    end

    _G.CGILUA_ISDIRECT = true
    _G.RINGER_APP = "wsapi.sapi"
    _G.RINGER_BOOTSTRAP = bootstrap
    return (wsapi.xavante.makeHandler(wsapi.ringer.run, script_name))(req, res)
end

-------------------------------------------------------------------------------
-- Returns the CGILua handler
-------------------------------------------------------------------------------
function makeHandler (diskpath, options)
    options = options or {}
    if options.checkFiles == nil then
        options.checkFiles = true
    end
    options.globals = options.globals or RINGS_CGILUA_GLOBALS or {}
    options[404] = options[404] or xavante.httpd.err_404
    return function (req, res)
	return cgiluahandler (req, res, diskpath, options)
    end
end
