-----------------------------------------------------------------------------
-- luahttpd : minimal http server
-- Author: Javier Guerra
-- 2005
-- CGILuaHandler: launches CGILua
--		heavily based on CGILua-5.0b/launcher/_cgi/t_cgi.lua
-----------------------------------------------------------------------------

---------------------------------------------------------------------
module (arg and arg[1])

-- Setting the Basic API.
local function set_api (req, res)
	local SAPI = {
		Response = {},
		Request = {},
	}
	-- Headers
	SAPI.Response.contenttype = function (s)
		res.headers ["Content-Type"] = s
	end
	SAPI.Response.redirect = function (s)
		res.headers ["Location"] = s
	end
	SAPI.Response.header = function (h, v)
		res.headers [h] = v
	end
	-- Contents
	SAPI.Response.write = function (s)
		httpd.send_res_data (res, s)
	end
	SAPI.Response.errorlog = function (s) io.stderr:write (s) end
	-- Input POST data
	SAPI.Request.getpostdata = function (n)
		return req.socket:receive (n)
	end
	-- Input general information
	SAPI.Request.servervariable = function (n)
		return req.cgivars[n]
	end
	
	return SAPI
end

require "venv"
require "lfs"
require "helper"
require "stable"

local function set_cgivars (req, diskpath)
	
	req.cgivars = {
		SERVER_SOFTWARE = req.serversoftware,
		SERVER_NAME = req.parsed_url.host,
		GATEWAY_INTERFACE = "CGI/1.1",
		SERVER_PROTOCOL = "HTTP/1.1",
		SERVER_PORT = req.parsed_url.port,
		REQUEST_METHOD = req.cmd_mth,
		PATH_INFO = "",
		PATH_TRANSLATED = diskpath .. req.parsed_url.path,
		SCRIPT_NAME = req.parsed_url.path,
		QUERY_STRING = req.parsed_url.query,
		REMOTE_HOST = nil,
		REMOTE_ADDR = string.gsub (req.rawskt:getpeername (), ":%d*$", ""),
		AUTH_TYPE = nil,
		REMOTE_USER = nil,
		CONTENT_TYPE = req.headers ["Content-Type"],
		CONTENT_LENGTH = req.headers ["Content-Length"],
	}
	for n,v in pairs (req.headers) do
		req.cgivars ["HTTP_"..string.gsub (string.upper (n), "-", "_")] = v
	end
	
--	print ("cgivars:")
--	for k,v in pairs (req.cgivars) do
--		print (k,v)
--	end
end

local function cgiluahandler (req, res, diskpath)
	set_cgivars (req, diskpath)
	helper.bg (req, res, venv (function ()
		SAPI = set_api (req, res)
		require "cgilua"
		pcall (cgilua.main)
	end ))
end

set_api ()

function makeHandler (diskpath)
	return function (req, res)
		return cgiluahandler (req, res, diskpath)
	end
end