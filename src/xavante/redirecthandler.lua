-------------------------------------------------------------------------------
-- Xavante redirect handler
--
-- Authors: Javier Guerra and Andre Carregal
-- Copyright (c) 2004-2006 Kepler Project
--
-- $Id: redirecthandler.lua,v 1.7 2006/08/05 04:28:33 carregal Exp $
-------------------------------------------------------------------------------
require "socket.url"

module ("xavante.redirecthandler", package.seeall)

-- dest can be of three kinds:
--	absolute: begins with '/', the match part of the path is replaced with dest
--	concat: begins with ':', dest is appended to the path
--	relative: dest is appended to the dirname of the path
local function redirect (req, res, dest)

	local path = req.parsed_url.path
	local pfx = string.sub (dest, 1,1)
	
	if pfx == "/" then
		path = string.gsub (path, "^("..req.match..")", dest)
	elseif pfx == ":" then
		path = path .. string.sub (dest, 2)
	else
		path = string.gsub (path, "/[^/]*$", "") .. "/" .. dest
	end
	
	req.parsed_url.path = path
	req.built_url = socket.url.build (req.parsed_url)
	req.cmd_url = string.gsub (req.built_url, "^[^:]+://[^/]+", "")
	
	return "reparse"
end

function makeHandler (params)
	return function (req, res)
		return redirect (req, res, params[1])
	end
end