-----------------------------------------------------------------------------
-- luahttpd : minimal http server
-- Author: Javier Guerra
-- 2005
-- filehandler: serves static files
-----------------------------------------------------------------------------

local url = require ("socket.url")

module (arg and arg[1])

require "xavante.mime"

_mimetypes = {}

--[[
local function readmimefile (filename)
	mimetypes = {}
	for line in io.lines (filename) do
		if line ~= "" and not string.find (line, "^%s*#") then
			local _,_,mtyp, exts = string.find (line, "^%s*(%S+)%s+(.*)$")
			if (mtyp and exts) then
				for ext in string.gfind (exts, "%S+") do
					mimetypes [ext] = mtyp
				end
			end
		end
	end
	
	return mimetypes
end
--]]

local function filehandler (req, res, docroot)
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


function makeHandler (diskPath)
	return function (req, res)
		return filehandler (req, res, diskPath)
	end
end

function mimetypes (types)
    _mimetypes = types
end