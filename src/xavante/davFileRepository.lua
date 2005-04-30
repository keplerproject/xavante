-----------------------------------------------------------------------------
-- Xavante webDAV file repository
-- Author: Javier Guerra
-- Copyright (c) 2004-2005 Javier Guerra
-----------------------------------------------------------------------------

require "lfs"
require "xavante.mime"

module (arg and arg[1])

local source_mt = { __index = {} }
local source = source_mt.__index

local resource_mt = { __index = {} }
local resource = resource_mt.__index

function source:getPath ()
	return self.diskPath
end

function source:getRootUrl ()
	return self.rootUrl
end

function source:getResource (path)
	local attr = lfs.attributes (self.diskPath .. path)
	if not attr then return end
	
	return setmetatable ({source = self, path = path, attr = attr}, resource_mt)
end

local _liveprops = {}

_liveprops["DAV:creationdate"] = function (self)
--	path = self.diskPath .. path
--	local attr = assert (lfs.attributes (path))
	return os.date ("!%a, %d %b %Y %H:%M:%S GMT", self.attr.change)
end

_liveprops["DAV:displayname"] = function (self)
	local name = ""
	for part in string.gfind (self.path, "[^/]+") do
		name = part
	end
	return name
end

_liveprops["DAV:source"] = function (self)
	return self:getHRef ()
end

--[[
_liveprops["DAV:supportedlock"] = function (self)
	return [[<D:lockentry>
<D:lockscope><D:exclusive/></D:lockscope>
<D:locktype><D:write/></D:locktype>
</D:lockentry>
<D:lockentry>
<D:lockscope><D:shared/></D:lockscope>
<D:locktype><D:write/></D:locktype>
</D:lockentry>]]
end
--]]

_liveprops["DAV:getlastmodified"] = function (self)
--	path = self.diskPath .. path
--	local attr = assert (lfs.attributes (path))
	return os.date ("!%a, %d %b %Y %H:%M:%S GMT", self.attr.modification)
end

_liveprops["DAV:resourcetype"] = function (self)
--	path = self.diskPath .. path
--	local attr = assert (lfs.attributes (path))
	if self.attr.mode == "directory" then
		return "<DAV:collection/>"
	else
		return ""
	end
end

_liveprops["DAV:getcontenttype"] = function (self)
	return self:getContentType ()
end
_liveprops["DAV:getcontentlength"] = function (self)
	return self:getContentSize ()
end

--function source:existResource (path)
--	if lfs.attributes (self.diskPath .. path) then
--		return true
--	end
--end

function resource:getContentType ()
	local path = self.path

	if string.sub (path, -1) == "/" then
		return "httpd/unix-directory"
	end
	local _,_,exten = string.find (path, "%.([^.]*)$")
	exten = exten or ""
	return xavante.mimetypes [exten]
end

function resource:getContentSize ()
--	attr = assert (lfs.attributes (self.diskPath .. path))
	if self.attr.mode == "file" then
		return self.attr.size
	end
end

function resource:getResourceData ()
--	local path = self.diskPath .. path
	local path = self.source.diskPath .. self.path

	local function gen ()
		local f = io.open (path, "rb")
		if not f then
			return
		end

		local block
		repeat
			block = f:read (8192)
			if block then
				coroutine.yield (block)
			end
		until not block
		f:close ()
	end

	return coroutine.wrap (gen)
end

function resource:getItems (depth)
	local gen
	local path = self.path
	local diskPath = self.source.diskPath

	if depth == "0" then
		gen = function () coroutine.yield (self) end

	elseif depth == "1" then
		gen = function ()
				if self.attr.mode == "directory" then
					if string.sub (path, -1) ~= "/" then
						path = path .."/"
					end
					for entry in lfs.dir (diskPath .. path) do
						if string.sub (entry, 1,1) ~= "." then
							coroutine.yield (self.source:getResource (path..entry))
						end
					end
				end
				coroutine.yield (self)
			end

	else
		local function recur (p)
			local attr = assert (lfs.attributes (diskPath .. p))
			if attr.mode == "directory" then
				for entry in lfs.dir (diskPath .. p) do
					if string.sub (entry, 1,1) ~= "." then
						recur (p.."/"..entry)
					end
				end
			coroutine.yield (self.source:getResource (p))
			end
		end
		gen = function () recur (path) end
	end
	
	if gen then return coroutine.wrap (gen) end
end

function resource:getHRef ()
	return self.source.rootUrl .. self.path
end

function resource:getAllProps ()
end

function resource:getProp (propname)
	local liveprop = _liveprops [propname]
	if liveprop then
		return liveprop (self)
	end
end

function resource:setProp (propname, value)
end

function makeSource (params)
	params = params or {}
	params.diskPath = params.diskPath or "."
	params.rootUrl = params.rootUrl or "http://localhost/"

	return setmetatable (params, source_mt)
end