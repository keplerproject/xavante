-----------------------------------------------------------------------------
-- Xavante File handler
--
-- Authors: Javier Guerra and Andre Carregal
-- Copyright (c) 2004-2005 Kepler Project
----------------------------------------------------------------------------

local url = require ("socket.url")

module (arg and arg[1])

require "xavante.mime"

_mimetypes = {}

local function filehandler (req, res, params)
    params = params or {}
    local docroot = params.baseDir
	local path = docroot .. url.unescape (req.parsed_url.path)
	
	local _,_,exten = string.find (path, "%.([^.]*)$")
	exten = exten or ""
	local mimetype = _mimetypes [exten]
	if mimetype then
		res.headers ["Content-Type"] = mimetype
	end
		
	local f = io.open (path, "rb")
	if not f then
		return httpd.err_404 (req, res)
	end
	
	local fsize = f:seek ("end")
	f:seek ("set")
	res.headers["Content-Length"] = fsize
	
	local block
	repeat
		block = f:read (8192)
		if block then
			httpd.send_res_data (res, block)
		end
	until not block
	f:close ()
	
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