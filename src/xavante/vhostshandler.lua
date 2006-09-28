-----------------------------------------------------------------------------
-- Xavante virtual hosts handler
--
-- Authors: Javier Guerra
-- Copyright (c) 2006 Kepler Project
--
-- $Id: vhostshandler.lua,v 1.2 2006/09/28 17:00:10 jguerra Exp $
-----------------------------------------------------------------------------

function xavante.vhostshandler (vhosts)
	return function (req, res)
		local h = vhosts [req.headers.host] or vhosts [""]
		return h (req, res)
	end
end
