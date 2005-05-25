-----------------------------------------------------------------------------
-- Xavante CGILua handler
--
-- Authors: Javier Guerra and Andre Carregal
-- Copyright (c) 2004-2005 Kepler Project
-----------------------------------------------------------------------------

module (arg and arg[1])

require "venv"
require "lfs"
require "stable"

-------------------------------------------------------------------------------
-- Implements SAPI
-------------------------------------------------------------------------------
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
		res:send_data (s)
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
	
	set_cgivars (req, diskpath)
	venv (function ()
		local t = {
			xavante.httpd.addHandler,
			xavante.httpd.err_404
		}
		t = nil
		SAPI = set_api (req, res)
		require "cgilua"
		pcall (cgilua.main)
	end )()
end

set_api ()

-------------------------------------------------------------------------------
-- Returns the CGILua handler
-------------------------------------------------------------------------------
function makeHandler (diskpath)
	return function (req, res)
		return cgiluahandler (req, res, diskpath)
	end
end