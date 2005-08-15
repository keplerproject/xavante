-----------------------------------------------------------------------------
-- Xavante resumable handlers framework
--
-- Author: Javier Guerra
-- Copyright (c) 2005 Kepler Project
-----------------------------------------------------------------------------

local session = require "xavante.session"

module (arg and arg[1])

function coroHandler (name, h)
	return function (req, res)
		local sess = session.open (req, res, name)
		sess.coHandler = sess.coHandler or coroutine.create (h)
		
		local ok, err = coroutine.resume (sess.coHandler, req, res)
		
		
		if not ok then _error (res, err) end
		
		if coroutine.status (sess.coHandler) == "dead" then
			session.close (req, res, name)
		end
		
		return res
	end
end

function event (sh_t, get_all)
	local req, res
	local subH
	repeat
		req, res = coroutine.yield ()
		subH = sh_t [req.relpath]
		if subH and type (subH) == "function" then
			subH (req, res)
		end
	until not subH or get_all
	return req, res
end