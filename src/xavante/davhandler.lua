-----------------------------------------------------------------------------
-- Xavante webDAV handler
-- Author: Javier Guerra
-- Copyright (c) 2004-2005 Javier Guerra
-----------------------------------------------------------------------------
require "lxp.lom"
require "socket.url"

local url = socket.url

module (arg and arg[1])

-- returns a copy of the string without any
-- leading or trailing whitespace
local function trim (s)	
	return (string.gsub (string.gsub (s, "^%s*", ""), "%s*$", ""))
end

-- reverts a LOM-style attribute array to XML form
local function attrstostr (a)
	local out = {}
	for i,attr in ipairs (a) do
		table.insert (out, string.format ('%s = "%s"', attr,  a[attr]))
	end
	return table.concat (out, " ")
end

-- outputs a LOM XML object back in XML text form
-- params:
-- 		x: LOM XML object
--		of: output function, uses print() if not given
local function lomtoxml (x, of)
	if type (x) == "string" then
		return of (x)
	end
	of = of or print
	local attrs = ""
	-- does it have any attributes?
	if x.attr [1] then
		attrs = " " .. attrstostr (x.attr)
	end
	
	-- is there any content?
	if x[1] then
		of ("<" .. x.tag .. attrs .. ">")
		for i in ipairs (x) do
			lomtoxml (x[i], of)
		end
		of ("</".. x.tag .. ">")
	else
		of ("<" .. x.tag .. attrs .. "/>")
	end
end

-- gets request content, and parses it as XML
-- returns LOM object
local function req_xml (req)
	local sz = req.headers ["Content-Length"]
	local indata
	if sz then
		indata = req.socket:receive (sz)
	else
		indata = function () return req.socket:receive () end
	end
	
	return lxp.lom.parse (indata)
end

-- expands namespace tags in-situ
-- returns the same LOM object after processing
local function xml_ns (x, dict)
	if not x then return end
	if type (x) == "string" then return x end
	
	dict = dict or {}
	
	-- adds any new namespace to the dictionary
	for i,attr_name in ipairs (x.attr) do
		local _,_, ns_var = string.find (attr_name, "xmlns:(.*)$")
		if ns_var then
			dict [ns_var] = x.attr [attr_name]
		end
	end
	
	-- modifies this node's tag
	local _,_, ns = string.find (x.tag, "^(.*):")
	if ns and dict [ns] then
		local pat = string.format ("^%s:", ns)
		x.tag = string.gsub (x.tag, pat, dict[ns])
	end
	
	-- recurses to child nodes
	for _, sub in ipairs (x) do
		xml_ns (sub, dict)
	end

	return x
end

-- iterator for traversing all elements in a LOM object
-- whith a given tagname (at any depth).
local function lomElementsByTagName (x, tagname)
	local function gen (x)
		for _,elem in ipairs (x) do
			if type(elem) == "table" then
				if elem.tag and elem.tag == tagname then
					coroutine.yield (elem)
				end
				gen (elem)
			end
		end
	end

	return coroutine.wrap (function () gen (x) end)
end

-- iterates on the childs of a LOM node
-- use as:
-- for subnode, tagname in lomChilds (node) do ... end
local function lomChilds (x)
	local function gen ()
		for _, elem in ipairs (x) do
			if type (elem) == "table" and elem.tag then
				coroutine.yield (elem, elem.tag)
			end
		end
	end
	return coroutine.wrap (gen)
end

-- returns a table member of a table, creates it if needed
-- params:
--		t: table
--		k: key
local function maketabletable (t,k)
	t[k] = t[k] or {}
	return t[k]
end

-- if a tagname has inconvenient characters
-- replaces part of if with a (possibly new)
-- namespace reference
-- params:
--		ns:	namespace dictionary
--		name:	tagname to reduce
-- returns new tagname, ns is modified in-place if needed
local function reducename (ns, name)
	if string.find (name, "[:/]") then
		local _,_,pfx,sfx = string.find (name, "(.*%W)(%w+)")
		local n = 0
		for k,v in pairs (ns) do
			n = n+1
			if v == pfx then
				return string.format ("%s:%s", k, sfx)
			end
		end
		local newns = "lm"..n
		ns [newns] = pfx
		return string.format ("%s:%s", newns, sfx)
	end
end

-- returns a XML attr string encoding a namespace dictionary
local function nsattr (ns)
	local attr = {}
	for k,v in pairs (ns) do
		table.insert (attr, string.format ([[xmlns:%s="%s"]], k, v))
	end
	return table.concat (attr, " ")
end

local function dav_propfind (req, res, repos)
	res.statusline = "HTTP/1.1 207 Multi-Status\r\n"
	res.headers ["Content-Type"] = 'text/xml; charset="utf-8"'

	local depth = req.headers.Depth
	local path = url.unescape (req.parsed_url.path)
	local data = xml_ns (req_xml (req))

--	print ("path:", path)
--	print ("depth:", depth)

	local resource_q = repos:getResource (path)

--	if (not repos:existResource (path)) then
	if not resource_q then
		return httpd.err_404 (req, res)
	end

	local content = {}

	table.insert (content, [[<?xml version="1.0" encoding="utf-8" ?>]])
	table.insert (content, [[<D:multistatus xmlns:D="DAV:">]])

	local propval
	for resource in resource_q:getItems (depth) do
	--	print ("resource:", resource.path)
		local propstat = {}
		local namespace = {D="DAV:"}
		for propgroup in lomElementsByTagName (data, "DAV:prop") do
			for _,propname in lomChilds (propgroup) do
				local propval = resource:getProp (propname)
				local shortname = reducename (namespace, propname)
				if propval then
					local propentry = maketabletable (propstat, "HTTP/1.1 200 OK")
					if propval == "" then
						table.insert (propentry, string.format ([[<%s />]], shortname))
					else
						table.insert (propentry, 
							string.format ([[<%s>%s</%s>]], 
								shortname, propval, shortname))
					end
				else
					local propentry = maketabletable (propstat, "HTTP/1.1 404 NotFound")
					table.insert (propentry, string.format ([[<%s />]], shortname))
				end
			end
		end

		table.insert (content, string.format ([[<D:response %s>]], nsattr (namespace)))
		table.insert (content, string.format ([[<D:href>%s</D:href>]], resource.path))
		for stat,props in pairs (propstat) do
			table.insert (content, [[<D:propstat>]])
			table.insert (content, [[<D:prop>]])
			for _,prop in ipairs (props) do
				table.insert (content, prop)
			end
			table.insert (content, [[</D:prop>]])
			table.insert (content, string.format ([[<D:status>%s</D:status>]], stat))
			table.insert (content, [[</D:propstat>]])
		end

		table.insert (content, [[</D:response>]])
	end
	
	table.insert (content, [[</D:multistatus>]])

--	for _,l in ipairs (content) do print (l) end

	res.content = content
	return res

end

local function dav_proppatch (req, res, repos)
	local data = xml_ns (req_xml (req))
--	print ("como xml:") lomtoxml (data) print ()
	return res
end

local function dav_options (req, res, repos)
	res.headers ["DAV"] = "1,2"
	res.content = ""
	return res
end

local function dav_get (req, res, repos)
--	local path = url.unescape (req.parsed_url.path)
	local resource = repos:getResource (url.unescape (req.parsed_url.path))
--	if (not repos:existResource (path)) then
	if not resource then
		return httpd.err_404 (req, res)
	end

	res.headers ["Content-Type"] = resource:getContentType ()
	res.headers ["Content-Length"] = resource:getContentSize () or 0

--	for k,v in pairs (res.headers) do print (k,v) end
	httpd.send_res_headers (res)
	for block in resource:getResourceData () do
		httpd.send_res_data (res, block)
	end
	return res
end


function makeHandler (repos)
	local dav_cmd_dispatch = {
		PROPFIND = function (req, res) return dav_propfind (req, res, repos) end,
		PROPPATCH = function (req, res) return dav_proppatch (req, res, repos) end,
		OPTIONS = function (req, res) return dav_options (req, res, repos) end,
		GET = function (req, res) return dav_get (req, res, repos) end,
	}

	return function (req, res)
	--	print (req.cmd_mth, req.parsed_url.path)
	--	for k,v in pairs (req.headers) do print (k,v) end

		local dav_handler = dav_cmd_dispatch [req.cmd_mth]
		if dav_handler then
			return dav_handler (req, res)
		end
	end
end
