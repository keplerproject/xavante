-----------------------------------------------------------------------------
-- Xavante File handler
--
-- Authors: Javier Guerra and Andre Carregal
-- Copyright (c) 2004-2006 Kepler Project
--
-- $Id: filehandler.lua,v 1.13 2006/09/28 16:49:36 jguerra Exp $
----------------------------------------------------------------------------

local lfs = require "lfs"
local url = require "socket.url"
require "xavante.mime"

local function filehandler (req, res, baseDir)

	if req.cmd_mth ~= "GET" and req.cmd_mth ~= "HEAD" then
		return httpd.err_405 (req, res)
	end

	local path = baseDir .."/".. req.relpath
	
	local _,_,exten = string.find (path, "%.([^.]*)$")
	exten = exten or ""
	local mimetype = xavante.mimetypes [exten]
	if mimetype then
		res.headers ["Content-Type"] = mimetype
	end
	
	local attr = lfs.attributes (path)
	if not attr then
		return xavante.httpd.err_404 (req, res)
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
				res:send_data (block)
			end
		until not block
		f:close ()
	end
	
	return res
end


function xavante.filehandler (baseDir)
	return function (req, res)
		return filehandler (req, res, baseDir)
	end
end
