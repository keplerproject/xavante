-----------------------------------------------------------------------------
-- Xavante CGILua handler
--
-- Authors: Javier Guerra and Andre Carregal
-- Copyright (c) 2004-2007 Kepler Project
--
-- $Id: cgiluahandler.lua,v 1.44 2008/03/10 23:38:31 mascarenhas Exp $
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
  for _, global in ipairs(RINGS_CGILUA_GLOBALS) do
    bootstrap = bootstrap .. 
      "_, _G[\"" .. global .. "\"] = remotedostring(\"return _G['" ..
      global .. "']\")\n"
  end
  app = wsapi.ringer.new("wsapi.sapi", bootstrap)
  return app(wsapi_env)
end 

-------------------------------------------------------------------------------
-- Returns the CGILua handler
-------------------------------------------------------------------------------
function makeHandler (diskpath)
   return wsapi.xavante.makeHandler(sapi_loader, nil, diskpath, diskpath)
end
