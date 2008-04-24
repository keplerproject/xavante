-----------------------------------------------------------------------------
-- Xavante CGILua handler
--
-- Authors: Javier Guerra and Andre Carregal
-- Copyright (c) 2004-2007 Kepler Project
--
-- $Id: cgiluahandler.lua,v 1.45 2008/04/24 17:07:52 mascarenhas Exp $
-----------------------------------------------------------------------------

require "wsapi.xavante"
require "wsapi.common"
require "kepler_init"

module ("xavante.cgiluahandler", package.seeall)

local function sapi_loader(wsapi_env)
  wsapi.common.normalize_paths(wsapi_env)
  local bootstrap = [[
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
  local app = wsapi.common.load_isolated_launcher(wsapi_env.PATH_TRANSLATED, "wsapi.sapi", bootstrap)
  return app(wsapi_env)
end 

-------------------------------------------------------------------------------
-- Returns the CGILua handler
-------------------------------------------------------------------------------
function makeHandler (diskpath)
   return wsapi.xavante.makeHandler(sapi_loader, nil, diskpath, diskpath)
end
