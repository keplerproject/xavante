-------------------------------------------------------------------------------
-- Xavante configuration file.
--
-- The configuration defines the Xavante environment
-- Commented fields are optional and assume default values
--
-- Xavante defines virtualhosts for each site running with Xavante.
-- Each virtualhost can define the handlers for specific files extensions.
-- Xavante currently offers a fileHandler and a CGILuaHandler.
--
-- Xavante configuration can be redefined on the default file structure by the
-- optional /conf/xavante/conf.lua file. If it does not exist, Xavante loads
-- the default /bin/xavante/conf.lua file.
--
-- Author: Andre Carregal and Javier Guerra
-- Copyright (c) 2004-2005 Kepler Project
-------------------------------------------------------------------------------
require "xavante.filehandler"
require "xavante.cgiluahandler"

xavante.register{
  server = {host = "*", port = 80},
  virtualhosts = {
    localhost = {
      defaultPages = {"index.html", "index.lp", "index.lua"},
      rules = {
        {match = "/", handler = xavante.filehandler.makeHandler (xavante.webdir())},
        {match = "/*.lp", handler = xavante.cgiluahandler.makeHandler (xavante.webdir())},
        {match = "/*.lua", handler = xavante.cgiluahandler.makeHandler (xavante.webdir())},
      },
    }, -- localhost
  }, -- virtualhosts
}