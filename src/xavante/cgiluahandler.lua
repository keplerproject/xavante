-------------------------------------------------------------------------------
-- Xavante CGILua Handler module
--
-- Author: Andre Carregal (carregal@keplerproject.org)
-- Copyright (c) 2004-2005 Kepler Project
-------------------------------------------------------------------------------
module "xavante"
require "copas"

-------------------------------------------------------------------------------
-- Xavante SAPI implementation does not use a global table SAPI because
-- concurrent access would not work with a single table. Instead it uses one
-- table for each connection.
--
-- @returns the SAPI.Request and SAPI.Response objects for the current context.
-- @see CGILuaHandler
-------------------------------------------------------------------------------
local function _getSAPI(request)
	local client = request.client
  local variables = {
    -- name and version of the information server software
    SERVER_SOFTWARE  = request.serversoftware,
    -- server's hostname, DNS alias, or IP address.
    SERVER_NAME = request.headers.Host,
    -- revision of the CGI specification to which this server complies.
    GATEWAY_INTERFACE =  "CGI/1.1",
    -- name and revision of the information protocol.
    SERVER_PROTOCOL = "HTTP/1.0",
    -- port number to which the request was sent.
    SERVER_PORT = request.port,
    -- HTTP method ("GET", "HEAD", "POST" etc).
    REQUEST_METHOD = request.method,
    -- extra path information, as given by the client.
    PATH_INFO = "",
    -- virtual to physical translated version of PATH_INFO
    PATH_TRANSLATED = request.filepath,
    -- virtual path to the script being executed.
    SCRIPT_NAME = request.uriTable.path,
    -- information which follows the ? in the URL.
    QUERY_STRING = request.uriTable.query,
    -- hostname making the request.
    REMOTE_HOST = request.peername,
    -- client IP address.
    REMOTE_ADDR = request.peername,
    -- client IP port.
    REMOTE_PORT = request.peerport,
    -- Authentication method used to validate the user.
    AUTH_TYPE = "Not implemented",
    -- authenticated user.
    REMOTE_USER = "Not implemented",
    -- remote user name retrieved from the server.
    REMOTE_IDENT = "Not implemented",
    -- content type of the HTTP POST and PUT data.
    CONTENT_TYPE = request.headers["content-type"],
    -- content length of the HTTP POST and PUT data.
    CONTENT_LENGTH = request.headers["content-length"],
    -- cookies
    HTTP_COOKIE = request.headers["cookie"],
  }
	local req = {}
  -- returns the POST data
  req.getpostdata = function (n) return copas.receive(client, n) end
  -- returns a HTTP server variable based on http://www.w3.org/CGI/
  req.servervariable = function (name) return variables[string.upper(name)] or "" end
	
	local resp = {}
  -- sends data to the client
  resp.write = function(text) copas.send(client, text) end
  -- sends HTTP headers to the client
  resp.header = function(h, v) resp.write (string.format ("%s: %s\n", h, v)) end
  -- logs an error
  resp.errorlog = function(msg) error(msg) end
  -- sends the Content Type
  resp.contenttype = function(ct) resp.write("Content-type: "..ct.."\n\n") end
  -- redirects the response to an URL
  resp.redirect = function(url) resp.write("Location: "..url.."\n\n") end

	return req, resp
end

-------------------------------------------------------------------------------
-- Handles a CGILua request using Xavante SAPI.
--
-- @see _getSAPI
-------------------------------------------------------------------------------
function CGILuaHandler(request)
  require "stable"
  beginResponse(request, "200 OK") -- CGILua handles the errors
  venv (function ()
          SAPI = {}
          SAPI.Request, SAPI.Response = _getSAPI(request)
          require "cgilua"
          cgilua.seterrorhandler(print)
          cgilua.main()
        end)()
end