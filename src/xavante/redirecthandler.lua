-------------------------------------------------------------------------------
-- Xavante redirect handler
--
-- Authors: Javier Guerra and Andre Carregal
-- Copyright (c) 2004-2005 Kepler Project
-------------------------------------------------------------------------------
module (arg and arg[1])

local function redirect (req, res, dest)
    req.cmd_url = string.gsub (req.cmd_url, "^("..req.match..")", dest)
    return "reparse"
end

function makeHandler (params)
	return function (req, res)
		return redirect (req, res, params[1])
	end
end