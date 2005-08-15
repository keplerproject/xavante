-----------------------------------------------------------------------------
-- Xavante CodeWeb
--
-- Author: Javier Guerra
-- Copyright (c) 2005 Kepler Project
-----------------------------------------------------------------------------

require "cgilua.prep"
module (arg and arg[1])

function addModule (host, urlpath, m)
	if m.__main then
		xavante.httpd.addHandler (host, urlpath, m.__main)
	end
	for k,v in pairs (m) do
		if	type (k) == "string" and
			string.sub (k,1,1) ~= "_" and
			type (v) == "function"
		then
			xavante.httpd.addHandler (host, urlpath.."/"..k, v)
		end
	end
end

function load_cw (fname)
	local fh = assert (io.open (fname))
	local prog = fh:read("*a")
	fh:close()
	cgilua.prep.setoutfunc ("res:send_data")
	prog = cgilua.prep.translate (prog, "file "..fname)
	prog = "return function (req,res,...)\n" .. prog .. "\nend"
	if prog then
		local f, err = loadstring (prog, "@"..fname)
		if f then
			return f()
		else
			error (err)
		end
	end
end

