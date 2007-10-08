-----------------------------------------------------------------------------
-- Xavante URL patterns handler
--
-- Authors: Fabio Mascarenhas
-- Copyright (c) 2006 Kepler Project
--
-- $Id: patternhandler.lua,v 1.1 2007/10/08 23:03:57 carregal Exp $
-----------------------------------------------------------------------------

local function path_iterator (path)
	return path_p, path
end

local function match_url (req, conf)
	local path = req.relpath
	for _, rule in ipairs(conf) do
	  for _, pat in ipairs(rule.pattern) do
	    	if string.find(path, pat) then
		  req.handler = rule.handler
		  return
		end
	  end
	end
end

function xavante.patternhandler (conf)
	if not conf or type (conf) ~= "table" then return nil end
	
	return function (req, res)
		match_url (req, conf)
		local h = req.handler or xavante.httpd.err_404
		return h (req, res)
	end
end
