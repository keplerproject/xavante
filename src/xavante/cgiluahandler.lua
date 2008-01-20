-----------------------------------------------------------------------------
-- Xavante CGILua handler
--
-- Authors: Javier Guerra and Andre Carregal
-- Copyright (c) 2004-2007 Kepler Project
--
-- $Id: cgiluahandler.lua,v 1.42 2008/01/20 14:45:20 mascarenhas Exp $
-----------------------------------------------------------------------------

require "wsapi.xavante"
require "wsapi.common"
require "wsapi.ringer"

module ("xavante.cgiluahandler", package.seeall)

local function sapi_loader(wsapi_env)
  wsapi.common.normalize_paths(wsapi_env)
  local bootstrap = [[
    _, package.path = remotedostring("return package.path")
    _, package.cpath = remotedostring("return package.cpath")

    pcall(require, "luarocks.require")

    require "kepler_init"

    function print(...)
       remotedostring("print(...)", ...)
    end
    
    io.stdout = {
       write = function (...)
		  remotedostring("io.write(...)", ...)
	       end
    }

    io.stderr = {
       write = function (...)
		  remotedostring("io.stderr(...)", ...)
	       end
    }
  ]]
  app = wsapi.ringer.new("wsapi.sapi", bootstrap)
  return app(wsapi_env)
end 

-------------------------------------------------------------------------------
-- Returns the CGILua handler
-------------------------------------------------------------------------------
function makeHandler (diskpath)
   return wsapi.xavante.makeHandler(sapi_loader, nil, diskpath)
end
