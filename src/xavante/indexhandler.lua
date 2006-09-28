-----------------------------------------------------------------------------
-- Xavante index handler
--
-- Authors: Javier Guerra
-- Copyright (c) 2006 Kepler Project
--
-- $Id: indexhandler.lua,v 1.1 2006/09/28 16:59:27 jguerra Exp $
-----------------------------------------------------------------------------

local function indexhandler (req, res, indexname)
	local indexUrl = string.gsub (req.cmd_url, "/[^/]*$", indexname)
	indexUrl = string.format ("http://%s%s", req.headers.host or "", indexUrl)
	
	res:add_header ("Location", indexUrl)
	res.statusline = "HTTP/1.1 302 Found\r\n"
	res.content = ""

	res:send_headers()
	return res
end

function xavante.indexhandler (indexname)
	return function (req, res)
		return indexhandler (req, res, indexname)
	end
end