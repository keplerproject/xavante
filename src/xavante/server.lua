-------------------------------------------------------------------------------
-- Xavante main module
--
-- Handles HTTP 1.0 requests and responses, uses CGILua as the native
-- template engine.
--
-- See xavante/xavante.conf for configuration details.
--
-- Author: Andre Carregal (carregal@keplerproject.org)
-- Copyright (c) 2004-2005 Kepler Project
-------------------------------------------------------------------------------
module ("xavante")

require "copas"
require "coxpcall"

pcall  = copcall
xpcall = coxpcall

require "venv"

require "socket"
require "socket.url"
require "socket.http"

-- Meta information is public even begining with an "_"
_COPYRIGHT   = "Copyright (C) 2004-2005 Kepler Project"
_DESCRIPTION = "A coroutine based Lua HTTP server with CGILua support"
_NAME        = "Xavante"
_VERSION     = "1.0"

-- Private functions and atributes begin with a "_"
local _serversoftware = _NAME.."/".._VERSION -- Used by SAPI
local _running = false
local _defaulthost = "localhost"
local _server
local _host
local _port
local _http
local _virtualhosts

-- Messages text
local STR_MSG_FILEHANDLER_404 = [[<HTML><HEAD><TITLE>File not found</TITLE></HEAD>
                          <BODY><H1>File not found</H1>
                          The requested URL %s was not found on this server
                          <P></BODY></HTML>]]

-------------------------------------------------------------------------------
-- Register the server configuration
-------------------------------------------------------------------------------
function register(config)
  config.server = config.server or {host = "*", port = 8899}
  _host = config.server.host
  _port = config.server.port
  _http = config.http or {cachecontrol = {maxage = 600}}
  _virtualhosts = config.virtualhosts or {}
end

-------------------------------------------------------------------------------
-- Starts the server
-------------------------------------------------------------------------------
function start()
  if _running == false then
    _running = true
  else
    return
  end
  require "xavante.conf"
  _server = assert(socket.bind(_host, _port))
  xavante.copas.addserver(_server, HTTPhandler)
  xavante.copas.loop()
end

-------------------------------------------------------------------------------
-- Methods to define and return Xavante directory structure
-------------------------------------------------------------------------------

function webdir()
  return _webdir
end

function setwebdir(dir)
  _webdir = dir
end

-------------------------------------------------------------------------------
-- Constructs the Request and Response objects for a client connection
-------------------------------------------------------------------------------
local function _request(client)
  local request = {}
  local line, msg

  -- Get HTTP Method
  line, msg = xavante.copas.receive(client)
  if msg then
  else
    request.client = client
    -- parses the HTTP method
    local _, _, method, uri, version = string.find(line or "", "(%S*) (%S*) (%S*)")
    if method then
      -- Get HTTP Headers
      local headers = {}
      line, msg = xavante.copas.receive(client)
      while not msg and line ~= "" do
        local _, _, name, value = string.find(line or "", "([^:]*):%s*([^:]*)")
        headers[string.lower(name)] = value
        line, msg = xavante.copas.receive(client)
      end
      request.port = _port
      request.method = method
      request.uri = uri
      request.version = version
      request.headers = headers
      request.headers.Host = request.headers.Host or _defaulthost
      request.peername, request.peerport = client:getpeername()
      request.serversoftware = _serversoftware
      request.handlers = {}
      -- Find the correct Virtual Host
      local host = _virtualhosts[request.headers.Host]
      if host then
        request.handlers = host.handlers
        request.aliases = host.aliases
        request.defaultPage = host.defaultPage
      end
    else
      --msg = msg or ""
    end
  end
  return request
end

-------------------------------------------------------------------------------
-- Translates an URI to a filepath
-------------------------------------------------------------------------------
local function _translateURI(request)
  local filepath -- translated file path
  local defaultPage

  for i, entry in ipairs(request.aliases) do
    -- Tries to match an Alias
    filepath = string.gsub(request.uriTable.path, "^("..entry.alias..")", entry.path)
    filepath = string.gsub(filepath, "//", "/")
    if filepath ~= request.uriTable.path then
      defaultPage = entry.defaultPage or request.defaultPage
      break
    end
  end
  request.filepath = filepath
  request.defaultPage = defaultPage
end


function beginResponse(request, msg)
	local client = request.client
	xavante.copas.send(client, request.version.." "..msg.."\n")
	xavante.copas.send(client, "Server: ".._serversoftware.."\n")
	xavante.copas.send(client, "Date: "..os.date().."\n")
	xavante.copas.send(client, "Connection: Close\n")
end

-------------------------------------------------------------------------------
-- Handles a HTTP request from a client
-------------------------------------------------------------------------------
local function _handle(request)
  local client = request.client
  if string.find (request.uri, "%.") == nil and
     string.find (request.uri, "/$") == nil then
    -- canonicalizes directory names, redirecting the browser
		beginResponse(request, "301 Moved Permanently")
    xavante.copas.send(client, "Location: ".. request.uri.."/".."\n\n")
  else
    -- tries to translate the original request
    local uriTable = socket.url.parse(request.uri)
    local pathTable = socket.url.parse_path(uriTable.path)
    request.uriTable = uriTable
    _translateURI(request)
    local filename = pathTable[table.getn(pathTable)]
    local _, extension
    _, _, extension = string.find(filename or "", "%.([^%.]*)")
    if filename == nil or extension == nil then
      -- uses the default page when the first translation failed
      filename = request.defaultPage
      request.uri = request.uri..filename
      uriTable = socket.url.parse(request.uri)
      pathTable = socket.url.parse_path(uriTable.path)
      request.uriTable = uriTable
      _translateURI(request)
    end
    _, _, extension = string.find(filename, "%.([^%.]*)")
    if extension then
      local requestHandled = false
      extension = string.lower(extension)
      request.filename = filename
      request.extension = extension
      if request.handlers[extension] then
      -- handles the file according to the extension
        local handler = request.handlers[extension].handler
        if handler then
	      handler(request)
    	  requestHandled = true
        end
      end
      if requestHandled == false then
      end
    end
  end
end


-------------------------------------------------------------------------------
-- Handles a HTTP client
-------------------------------------------------------------------------------
function HTTPhandler(client)
  return _handle(_request(client))
end


-------------------------------------------------------------------------------
-- Handles a file
-- The HTTP response contains the file Content Type and Body
-------------------------------------------------------------------------------
function fileHandler(request)
  if request.filepath then
    local client = request.client
    local file, msg = io.open(request.filepath, "rb")
    if msg then
      beginResponse(request, "404 Not Found")
     	xavante.copas.send(client, "Content-type: text/html\n")
      xavante.copas.send(client, "\n")
      xavante.copas.send(client, string.format(STR_MSG_FILEHANDLER_404, request.uri))
    elseif file then
      if string.upper(request.method) == "GET" then
    		beginResponse(request, "200 OK")
      	local contentType = request.handlers[request.extension].contentType
       	xavante.copas.send(client, "Content-type: "..contentType.."\n")
	      local body = file:read("*a")
        xavante.copas.send(client, "Content-Length: ".. string.len(body) .."\n")
        local cacheTime = _http.cachecontrol.maxage + os.time()
        xavante.copas.send(client, "Expires: "..os.date("!%a, %d %b %Y, %H:%M:%S GMT\n",
              cacheTime))
        xavante.copas.send(client, "\n")
        xavante.copas.send(client, body)
        file:close()
      else
        -- Handle Unknown Method Error
      end
    end
  else
    -- Handle URL malformed rror
  end
end