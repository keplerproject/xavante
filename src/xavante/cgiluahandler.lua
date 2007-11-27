-----------------------------------------------------------------------------
-- Xavante CGILua handler
--
-- Authors: Javier Guerra and Andre Carregal
-- Copyright (c) 2004-2007 Kepler Project
--
-- $Id: cgiluahandler.lua,v 1.36 2007/11/27 15:49:55 carregal Exp $
-----------------------------------------------------------------------------

requests = requests or {}

module ("xavante.cgiluahandler", package.seeall)

require "rings"

-------------------------------------------------------------------------------
-- Implements SAPI
-------------------------------------------------------------------------------
-- returns the correct argument selector for Lua 5.0 or 5.1
local function argument(n)
    return "select("..tostring(n)..", ...)"
end

local function state_init(options)
    local init = [[
local select = select or function (n, ...) return arg[n] end


local id_string = 'requests["' ..]]..argument(1)..[[ .. '"]'

local function set_api ()
	local SAPI = {
		Response = {},
		Request = {},
        Info = {
            _COPYRIGHT = "Copyright (C) 2004-2007 Kepler Project",
		    _DESCRIPTION = "Xavante SAPI implementation",
		    _VERSION = "Xavante SAPI 1.4",
		    ispersistent = false,
		    ismapped = true,
		    isdirect = true,
        }
	}
	-- Headers
	SAPI.Response.contenttype = function (s)
		remotedostring(id_string .. '.res.headers["Content-Type"] = ]]..argument(1)..[[', s)
	end
	SAPI.Response.redirect = function (s)
		remotedostring(id_string .. '.res.headers["Location"] = ]]..argument(1)..[[', s)
		remotedostring(id_string .. [=[.res.statusline = "HTTP/1.1 302 Found\r\n"]=])
		remotedostring(id_string .. '.res.content = "redirect"')
	end
	SAPI.Response.header = function (h, v)
		remotedostring(id_string .. ".res:add_header (]]..argument(1)..[[, ]]..argument(2)..[[)", h, v)
	end
	-- Contents
	SAPI.Response.write = function (...)
        local args = { ... }
        for i = 1, select("#",...) do
            coroutine.yield("SEND_DATA", tostring(args[i]))
        end
	end
	SAPI.Response.errorlog = function (s) 
		remotedostring('io.stderr:write(]]..argument(1)..[[)', s)
	end
	-- Input POST data
	SAPI.Request.getpostdata = function (n)
		return coroutine.yield("RECEIVE", n)
	end
	-- Input general information
	SAPI.Request.servervariable = function (n)
		return select(2, remotedostring('return ' .. id_string .. ".req.cgivars[]]..argument(1)..[[]", n))
	end
	
	return SAPI
end

SAPI = set_api ()
_, package.path = remotedostring("return package.path")
_, package.cpath = remotedostring("return package.cpath")
require"coxpcall"
pcall = copcall
xpcall = coxpcall
]]

-- Alow the listed globals
for _, v in ipairs (options.globals) do
    init = init..[[_, ]]..v..[[ = remotedostring("return ]]..v..[[")]].."\n"
end

    init = init..[[
require"cgilua"
main_coro = coroutine.wrap(function () cgilua.main() end)

]]

    return init
end

local function cgiluahandler (req, res, diskpath, options)
    -- gets the script name without any path
	local name = string.match(req.relpath, "/([^/]+%.[^/]+)")
    local name = string.gsub(name, "%.", "%%%.")
    -- gets the script name with path (SCRIPT_NAME)
    local script_name = string.match(req.relpath, "^(.-"..name..")")
    -- the remaining is the PATH_INFO
    local path_info = string.match(req.relpath, name.."(.*)")
    script_name = script_name or ""
    path_info = path_info or ""
    if options.checkFiles then
        if not lfs.attributes (diskpath .. "/"..script_name) then
            return options[404] (req, res)
        end
    end
	requests[tostring(req)] = { req = req, res = res }

    res:add_header("Connection", "close")

	req.cgivars = {
		SERVER_SOFTWARE = req.serversoftware,
		SERVER_NAME = req.parsed_url.host,
		GATEWAY_INTERFACE = "CGI/1.1",
		SERVER_PROTOCOL = "HTTP/1.1",
		SERVER_PORT = req.parsed_url.port,
		REQUEST_METHOD = req.cmd_mth,
        DOCUMENT_ROOT = diskpath,
		PATH_INFO = path_info,
		PATH_TRANSLATED = diskpath..script_name,
		SCRIPT_NAME = script_name,
		QUERY_STRING = req.parsed_url.query,
		REMOTE_HOST = nil,
		REMOTE_ADDR = string.gsub (req.rawskt:getpeername (), ":%d*$", ""),
		AUTH_TYPE = nil,
		REMOTE_USER = nil,
		CONTENT_TYPE = req.headers ["content-type"],
		CONTENT_LENGTH = req.headers ["content-length"],
	}
	for n,v in pairs (req.headers) do
		req.cgivars ["HTTP_"..string.gsub (string.upper (n), "-", "_")] = v
	end
    
	local new_state = rings.new()
	assert(new_state:dostring(state_init(options), tostring(req)))
	local coro_arg, status, op, arg
	repeat
		status, op, arg = new_state:dostring("return main_coro("..argument(1)..")", coro_arg)
        if not status then
            error(op)
        end
		if op == "SEND_DATA" then
			res:send_data(arg)
		elseif op == "RECEIVE" then
			coro_arg = req.socket:receive(arg)
		end
	until not op
	-- release resources
	new_state:close()
	requests[tostring(req)] = nil
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
