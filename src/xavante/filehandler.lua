-----------------------------------------------------------------------------
-- Xavante File handler
--
-- Authors: Javier Guerra and Andre Carregal
-- Copyright (c) 2004-2005 Kepler Project
----------------------------------------------------------------------------

require "lfs"
require "socket.url"
local url = socket.url

module (arg and arg[1])

require "xavante.mime"

_mimetypes = {}

local function filehandler (req, res, params)

	if req.cmd_mth ~= "GET" and req.cmd_mth ~= "HEADERS" then
		return httpd.err_405 (req, res)
	end

	params = params or {}
	local docroot = params.baseDir
	local path = docroot .. url.unescape (req.parsed_url.path)
	
	local _,_,exten = string.find (path, "%.([^.]*)$")
	exten = exten or ""
	local mimetype = _mimetypes [exten]
	if mimetype then
		res.headers ["Content-Type"] = mimetype
	end
	
	local attr = lfs.attributes (path)
	if not attr then
		return httpd.err_404 (req, res)
	end
	assert (type(attr) == "table")
	
	if attr.mode == "directory" then
		req.parsed_url.path = req.parsed_url.path .. "/"
		res.statusline = "HTTP/1.1 301 Moved Permanently\r\n"
		res.headers["Location"] = url.build (req.parsed_url)
		return res
	end
	
	res.headers["Content-Length"] = attr.size
	
	local f = io.open (path, "rb")
	if not f then
		return httpd.err_404 (req, res)
	end
		
	if req.cmd_mth == "GET" then
		local block
		repeat
			block = f:read (8192)
			if block then
				httpd.send_res_data (res, block)
			end
		until not block
		f:close ()
	end
	
	return res
end


function makeHandler (params)
	return function (req, res)
		return filehandler (req, res, params)
	end
end

function mimetypes (types)
    _mimetypes = types
end