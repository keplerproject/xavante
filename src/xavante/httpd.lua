-----------------------------------------------------------------------------
-- luahttpd : minimal http server
-- Author: Javier Guerra
-- 2005
-- HTTPEngine, work over Copas
-----------------------------------------------------------------------------
local url = require "socket.url"
require "coxpcall"
pcall  = copcall
xpcall = coxpcall

module ("httpd")

local _serversoftware = ""

local vhosts = {}
--local path_handler = {}

function sh_t (t)
	for k,v in pairs (t) do
		print (k,v)
	end
end

function strsplit (str)
	local words = {}
	
	for w in string.gfind (str, "%S+") do
		table.insert (words, w)
	end
	
	return words
end

--[[
do
	local envtable = {}
	local env_l = thread.newmutex ()
	
	-- returns a 'connection' table, tied to the thread
	-- user is free to modify it, but only from the 'owning' thread
	function cur_conn ()
		local id = thread.id ()
		env_l:lock ()
		local conn = envtable [id]
		if not conn then
			conn = {}
			envtable [id] = conn
		end
		env_l:unlock ()
		return conn
	end
end

--]]

-- Manages one connection, maybe several requests
-- params:
--		skt : client socket

function connection (skt)
--	print ("strt skt:", skt)
	local req = {
		rawskt = skt,
		copasskt = copas.wrap (skt),
	}
	req.socket = req.copasskt

    req.serversoftware = _serversoftware
--	local conn = cur_conn ()
--	conn.req = req
	
	while read_method (req) do
		read_headers (req)
		repeat
			parse_url (req)
			local res = make_response (req)
--			conn.res = res
		until handle_request (req, res) ~= "reparse"
		send_response (req, res)
		
		req.socket:flush ()
		if not res.keep_alive then
			break
		end
	end
	
--	print ("end skt:", skt)
--	skt:close ()
end

-- gets and parses the request line
-- params:
--		req: request object
-- returns:
--		true if ok
--		false if connection closed
-- sets:
--		req.cmd_mth: http method
--		req.cmd_url: url requested (as sent by the client)
--		req.cmd_version: http version (usually 'HTTP/1.1')
function read_method (req)
	local err
	req.cmdline, err = req.socket:receive ()
	
	if not req.cmdline then return nil end
	req.cmd_mth, req.cmd_url, req.cmd_version = unpack (strsplit (req.cmdline))
	req.cmd_mth = string.upper (req.cmd_mth)
	return true
end

-- gets and parses the request header fields
-- params:
--		req: request object
-- sets:
--		req.headers: table of header fields, as name => value
function read_headers (req)
	req.headers = req.headers or {}
	
	local prevname
	
	while 1 do
		local l,err = req.socket:receive ()
		if (not l or l == "") then return end
		local _,_, name, value = string.find (l, "^([^: ]+)%s*:%s*(.+)")
		if name then
			prevval = req.headers [name]
			if prevval then
				value = prevval .. "," .. value
			end
			req.headers [name] = value
			prevname = name
		elseif prevname then
			req.headers [prevname] = req.headers [prevname] .. l
		end
	end
end

-- this is a coroutine-based iterator:
-- path_perputer takes a path and yields once for each handler key to try
--		first is the full path
--		next, anything with the same extension on the same directory
--		next, anything on the directory
--		strips the last subdirectory from the path, and repeats the last two patterns
--		for example, if the query was /first/second/file.ext , tries:
--			/first/second/file.ext
--			/first/second/*.ext
--			/first/second/*
--			/first/*.ext
--			/first/*
--			/*.ext
--			/*
--		and, if the query was for a directory like /first/second/last/ , it tries:
--			/first/second/last/
--			/first/second/
--			/first/
--			/
function path_permuter (path)
	coroutine.yield (path)
	local _,_,ext = string.find (path, "%.([^.]*)$")
	local notdir = (string.sub (path, -1) ~= "/")
	
	while path ~= "" do
		path = string.gsub (path, "/[^/]*$", "")
		if notdir then
			if ext then
				coroutine.yield (path .."/*."..ext)
			end
			coroutine.yield (path .."/*")
		else
			coroutine.yield (path.."/")
		end
	end
end

-- given a path, returns an iterator to traverse all permutations
function path_iterator (path)
	return coroutine.wrap (function () path_permuter (path) end)
end

-- parses the url, and gets the appropiate handler function
-- starts with the full path, and goes up to the root
-- until it finds a handler for the request method
function parse_url (req)
	local hosthandlers = vhosts [req.headers.Host] or vhosts ["_"]
	local def_url = string.format ("http://%s%s", req.headers.Host, req.cmd_url)
	
	req.parsed_url = url.parse (def_url)
	req.built_url = url.build (req.parsed_url)
	
	local path = req.parsed_url.path
	local h, set
	for p in path_iterator (path) do
		h = hosthandlers [p]
		if h then break end
	end
	
	req.handler = h
end

-- calls the handler set up by http_read_method()
-- returns:
--		response object
function handle_request (req, res)
	h = req.handler or err_404
	return h (req, res)
end

function make_response (req)
	local res = {
		socket = req.socket,
		headers = default_headers (req),
	}
	return res
end

-- sets the default response headers
function default_headers (req)
	return  {	
		Date = os.date ("!%a, %d %b %Y %H:%M:%S GMT"),
		Server = _serversoftware,
	}
end

-- sends the response headers
-- params:
--		res: response object
-- uses:
--		res.sent_headers : if true, headers are already sent, does nothing
--		res.statusline : response status, if nil, sends 200 OK
--		res.headers : table of header fields to send
function send_res_headers (res)
	if (res.sent_headers) then
		return
	end
		
	res.statusline = res.statusline or "HTTP/1.1 200 OK\r\n"
	
	res.socket:send (res.statusline)
	for name, value in pairs (res.headers) do
		res.socket:send (string.format ("%s: %s\r\n", name, value))
	end
	res.socket:send ("\r\n")
	
	res.sent_headers = true;
end

-- sends content directly to client
--		sends headers first, if necesary
-- params:
--		res ; response object
--		data : content data to send
function send_res_data (res, data)

	if not data then
		return
	end

	if not res.sent_headers then
		send_res_headers (res)
	end
	
	res.socket:send (data)
end

-- sends prebuilt content to the client
-- 		if possible, sets Content-Length: header field
-- params:
--		req : request object
--		res : response object
-- uses:
--		res.content : content data to send
-- sets:
--		res.keep_alive : if possible to keep using the same connection
function send_response (req, res)

	if res.content then
		if not res.sent_headers then
			if (type (res.content) == "table") then
				res.content = table.concat (res.content)
			end
			if (type (res.content) == "string") then
				res.headers["Content-Length"] = string.len (res.content)
			end
		end
		
		send_res_data (res, res.content)
	end
	
	if (res.headers ["Content-Length"]) and
		req.headers ["Connection"] == "Keep-Alive"
	then
		res.keep_alive = true
	else
		res.keep_alive = nil
	end
end

function err_404 (req, res)
	res.statusline = "HTTP/1.1 404 Not Found\r\n"
	res.content = string.format ([[
<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML 2.0//EN">
<HTML><HEAD>
<TITLE>404 Not Found</TITLE>
</HEAD><BODY>
<H1>Not Found</H1>
The requested URL %s was not found on this server.<P>
</BODY></HTML>]], req.built_url);
	return res
end

function err_405 (req, res)
	res.statusline = "HTTP/1.1 405 Method Not Allowed\r\n"
	res.content = string.format ([[
<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML 2.0//EN">
<HTML><HEAD>
<TITLE>405 Method Not Allowed</TITLE>
</HEAD><BODY>
<H1>Not Found</H1>
The Method %s is not allowed for URL %s on this server.<P>
</BODY></HTML>]], req.cmd_mth, req.built_url);
	return res
end

function register (host, port, serversoftware)
	local _server = assert(socket.bind(host, port))
    _serversoftware = serversoftware
	copas.addserver(_server, connection)
end

function addHandler (host, urlpath, f)
	host = host or "_"
	if not vhosts [host] then
		vhosts [host] = {}
	end
	vhosts [host] [urlpath] = f
end

