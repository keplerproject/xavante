-----------------------------------------------------------------------------
-- Xavante File handler
--
-- Authors: Javier Guerra and Andre Carregal
-- Copyright (c) 2004-2006 Kepler Project
--
-- $Id: filehandler.lua,v 1.20 2007/02/13 19:30:55 carregal Exp $
----------------------------------------------------------------------------

local lfs = require "lfs"
local url = require "socket.url"
require "xavante.mime"
require "xavante.encoding"

xavante.mimetypes = xavante.mimetypes or {}
xavante.encodings = xavante.encodings or {}

-- gets the mimetype from the filename's extension
local function mimefrompath (path)
	local _,_,exten = string.find (path, "%.([^.]*)$")
	if exten then
		return xavante.mimetypes [exten]
	else
		return nil
	end
end

-- gets the encoding from the filename's extension
local function encodingfrompath (path)
	local _,_,exten = string.find (path, "%.([^.]*)$")
	if exten then
		return xavante.encodings [exten]
	else
		return nil
	end
end

-- on partial requests seeks the file to
-- the start of the requested range and returns
-- the number of bytes requested.
-- on full requests returns nil
local function getrange (req, f)
	local range = req.headers["range"]
	if not range then return nil end
	
	local s,e, r_A, r_B = string.find (range, "(%d*)%s*-%s*(%d*)")
	if s and e then
		r_A = tonumber (r_A)
		r_B = tonumber (r_B)
		
		if r_A then
			f:seek ("set", r_A)
			if r_B then return r_B + 1 - r_A end
		else
			if r_B then f:seek ("end", - r_B) end
		end
	end
	
	return nil
end

-- sends data from the open file f
-- to the response object res
-- sends only numbytes, or until the end of f
-- if numbytes is nil
local function sendfile (f, res, numbytes)
	local block
	local whole = not numbytes
	local left = numbytes
	local blocksize = 8192
	
	if not whole then blocksize = math.min (blocksize, left) end
	
	while whole or left > 0 do
		block = f:read (blocksize)
		if not block then return end
		if not whole then
			left = left - string.len (block)
			blocksize = math.min (blocksize, left)
		end
		res:send_data (block)
	end
end


-- main handler
local function filehandler (req, res, baseDir)

	if req.cmd_mth ~= "GET" and req.cmd_mth ~= "HEAD" then
		return xavante.httpd.err_405 (req, res)
	end

	local path = baseDir .."/".. req.relpath
	
	res.headers ["Content-Type"] = mimefrompath (path)
	res.headers ["Content-Encoding"] = encodingfrompath (path)
    
	local attr = lfs.attributes (path)
	if not attr then
		return xavante.httpd.err_404 (req, res)
	end
	assert (type(attr) == "table")
	
	if attr.mode == "directory" then
		req.parsed_url.path = req.parsed_url.path .. "/"
		res.statusline = "HTTP/1.1 301 Moved Permanently\r\n"
		res.headers["Location"] = url.build (req.parsed_url)
		res.content = "redirect"
		return res
	end
	
	res.headers["Content-Length"] = attr.size
	
	local f = io.open (path, "rb")
	if not f then
		return xavante.httpd.err_404 (req, res)
	end
		
	if req.cmd_mth == "GET" then
		local range_len = getrange (req, f)
		if range_len then
			res.statusline = "HTTP/1.1 206 Partial Content\r\n"
			res.headers["Content-Length"] = range_len
		end
		
		sendfile (f, res, range_len)
		f:close ()
	else
		res.content = ""
		res:send_headers ()
	end
	
	return res
end


function xavante.filehandler (baseDir)
	if type(baseDir) == "table" then baseDir = baseDir.baseDir end
	return function (req, res)
		return filehandler (req, res, baseDir)
	end
end
