-----------------------------------------------------------------------------
-- webThreads: Xavante resumable handlers framework
--
-- Author: Javier Guerra
-- Copyright (c) 2005 Kepler Project
-----------------------------------------------------------------------------

local session = require "xavante.session"

module (arg and arg[1])

local function _ortoroutines (err)
	err = err or error
	local _tag = {}
	print ("_tag:", _tag)
	return
		function (co, ...)
			local r,sts
			repeat
				print ("resume (", unpack (arg))
				r = { coroutine.resume (co, unpack (arg)) }
				sts = coroutine.status (co)
				
				print ("r=", unpack (r))
				if not r[1] then err (r[2]) end
				table.remove (r,1)
				
				if r[1] ~= _tag and sts == "suspended" then
					arg = { coroutine.yield (unpack (r)) }
				end
			until r[1] == _tag or sts == "dead"
			table.remove (r,1)
			return unpack (r)
		end,
		function (...)
			return coroutine.yield (_tag, unpack (arg))
		end
end

local function _error (res, err)
	res:send_data ("<h1>error:"..err.."</h1>")
end

--
-- use xavante.webtreads.resume() and xavante.webtreads.yield()
-- instead of coroutine.resume() and coroutine.yield()
--
resume, yield = _ortoroutines ()

--
-- creates a xavante handler
-- params:
--		name (string) : session name to use
--		h (function) :	thread to handle
--
function handler (name, h)
	return function (req, res)
		local sess = session.open (req, res, name)
		sess.coHandler = sess.coHandler or coroutine.create (h)
		
		resume (sess.coHandler, req, res)
	--	local ok, err = coroutine.resume (sess.coHandler, req, res)
		
	--	if not ok then _error (res, err) end
	
		print ("stat: ", coroutine.status (sess.coHandler))
		
		if coroutine.status (sess.coHandler) == "dead" then
			session.close (req, res, name)
		end
		
		return res
	end
end

--
-- gets user actions as events
-- params:
--		in_req (table) :	'req' parameter
--		sh_t (table) :		namesubhandlers
function event (in_req, sh_t, get_all)
	local req, res
	local subH, ret
	repeat
		req, res = yield ()
		subH = sh_t [req.relpath]
		if subH and type (subH) == "function" then
			ret = subH (req, res)
		end
		if ret == "refresh" then
--			xavante.httpd.redirect (res, string.gsub (req.parsed_url.path, "/[^/]*$", ""))
			xavante.httpd.redirect (res, in_req.parsed_url.path)
			req, res = yield ()
		end
	until not subH or get_all or ret == "refresh" 
	return req, res
end