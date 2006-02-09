-----------------------------------------------------------------------------
-- Xavante CGILua handler
--
-- Authors: Javier Guerra and Andre Carregal
-- Copyright (c) 2004-2005 Kepler Project
-----------------------------------------------------------------------------

requests = requests or {}

module (arg and arg[1])

require "rings"
require "lfs"

-------------------------------------------------------------------------------
-- Implements SAPI
-------------------------------------------------------------------------------
local state_init = [[

local function select(n, ...)
  return arg[n]
end

local id_string = 'requests["' .. arg[1] .. '"]'

local function set_api ()
	local SAPI = {
		Response = {},
		Request = {},
	}
	-- Headers
	SAPI.Response.contenttype = function (s)
		dostring(id_string .. '.res.headers["Content-Type"] = arg[1]', s)
	end
	SAPI.Response.redirect = function (s)
                dostring(id_string .. '.res.headers["Location"] = arg[1]', s)
	end
	SAPI.Response.header = function (h, v)
                dostring(id_string .. ".res.headers[arg[1] ] = arg[2]", h, v)
	end
	-- Contents
	SAPI.Response.write = function (s)
                coroutine.yield("SEND_DATA", s)
	end
	SAPI.Response.errorlog = function (s) 
		dostring('io.stderr:write(arg[1])', s)
	end
	-- Input POST data
	SAPI.Request.getpostdata = function (n)
                return coroutine.yield("RECEIVE", n)
	end
	-- Input general information
	SAPI.Request.servervariable = function (n)
		return select(2, dostring('return ' .. id_string .. ".req.cgivars[arg[1] ]", n))
	end
	
	return SAPI
end

SAPI = set_api ()
_, LUA_PATH = dostring("return package.path")
require"compat-5.1"
_, package.cpath = dostring("return package.cpath")
require"coxpcall"
pcall = copcall
xpcall = coxpcall
require"cgilua"
main_coro = coroutine.wrap(function () cgilua.main() end)

]]

local function set_cgivars (req, diskpath)
	
	req.cgivars = {
		SERVER_SOFTWARE = req.serversoftware,
		SERVER_NAME = req.parsed_url.host,
		GATEWAY_INTERFACE = "CGI/1.1",
		SERVER_PROTOCOL = "HTTP/1.1",
		SERVER_PORT = req.parsed_url.port,
		REQUEST_METHOD = req.cmd_mth,
		PATH_INFO = "",
		PATH_TRANSLATED = diskpath .. "/"..req.relpath,
		SCRIPT_NAME = req.parsed_url.path,
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
end

local function cgiluahandler (req, res, diskpath)
	if not lfs.attributes (diskpath .. "/"..req.relpath) then
		return httpd.err_404 (req, res)
	end      
 
        requests[tostring(req)] = { req = req, res = res }	

	set_cgivars (req, diskpath)
        local new_state = rings.new()
        new_state:dostring(state_init, tostring(req))
        local coro_arg, status, op, arg
        repeat
        	status, op, arg = new_state:dostring("return main_coro(arg[1])", coro_arg)
        	if op == "SEND_DATA" then
        		res:send_data(arg)
        	elseif op == "RECEIVE" then
        		coro_arg = req.socket:receive(arg)
        	end
        until not op
end

-------------------------------------------------------------------------------
-- Returns the CGILua handler
-------------------------------------------------------------------------------
function makeHandler (diskpath)
	return function (req, res)
		return cgiluahandler (req, res, diskpath)
	end
end
