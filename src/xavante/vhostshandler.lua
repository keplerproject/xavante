
function xavante.vhostshandler (vhosts)
	return function (req, res)
		local h = vhosts [req.headers.host] or vhosts [""]
		return h (req, res)
	end
end
