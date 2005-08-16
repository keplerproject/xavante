-----------------------------------------------------------------------------
-- Xavante resumable handlers framework
--
-- Author: Javier Guerra
-- Copyright (c) 2005 Kepler Project
-----------------------------------------------------------------------------

local session = require "xavante.session"

module (arg and arg[1])

local function _error (res, err)
	res:send_data ("<h1>error:"..err.."</h1>")
end

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

function event (in_req, sh_t, get_all)
	local req, res
	local subH, ret
	repeat
		req, res = coroutine.yield ()
		subH = sh_t [req.relpath]
		if subH and type (subH) == "function" then
			ret = subH (req, res)
		end
		if ret == "refresh" then
--			xavante.httpd.redirect (res, string.gsub (req.parsed_url.path, "/[^/]*$", ""))
			xavante.httpd.redirect (res, in_req.parsed_url.path)
			req, res = coroutine.yield ()
		end
	until not subH or get_all or ret == "refresh" 
	return req, res
end