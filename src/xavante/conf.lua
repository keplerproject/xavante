-------------------------------------------------------------------------------
-- Xavante configuration file.
--
-- The configuration defines the Xavante environment
-- Commented fields are optional and assume default values
--
-- Xavante defines virtualhosts for each site running with Xavante.
-- Each virtualhost can define a set of aliases within it.
-- Each alias maps a virtual directory to a physical path, using a default page
-- when the URL does not specify one.
-- If the alias does not define a default page, the virtualhost default page is
-- used.
-- Each virtualhost can define the handlers for specific files extensions.
-- Xavante currently offers a fileHandler and a CGILuaHandler.
--
-- Xavante configuration can be redefined on the default file structure by the
-- optional /conf/xavante/conf.lua file. If it does not exist, Xavante loads
-- the default /bin/xavante/conf.lua file.
--
-- Author: Andre Carregal (carregal@keplerproject.org)
-- Copyright (c) 2004-2005 Kepler Project
-------------------------------------------------------------------------------
require "xavante.cgiluahandler"

xavante.register{
  server = {host = "*", port = 8899},

  virtualhosts = {
    localhost = {
      defaultPage = "index.html",
      handlers = {
        html = {contentType = "text/html"  , handler = xavante.fileHandler},
        htm  = {contentType = "text/html"  , handler = xavante.fileHandler},
        txt  = {contentType = "text/plain" , handler = xavante.fileHandler},
        gif  = {contentType = "image/gif"  , handler = xavante.fileHandler},
        jpg  = {contentType = "image/jpeg" , handler = xavante.fileHandler},
        css  = {contentType = "text/css"   , handler = xavante.fileHandler},
        lua  = {nil                        , handler = xavante.CGILuaHandler},
        lp   = {nil                        , handler = xavante.CGILuaHandler},
      },
      aliases = {
        {alias = "/"    , path = xavante.webdir().."/", defaultPage = "default.lp"},
      },
    }, -- localhost
  }, -- virtualhosts
}