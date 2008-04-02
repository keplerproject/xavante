-----------------------------------------------------------------------------
-- Xavante Cosmo handler
--
-- Author: Fabio Mascarenhas
--
-----------------------------------------------------------------------------

require "wsapi.xavante"
require "wsapi.common"
require "wsapi.ringer"

module ("xavante.cosmohandler", package.seeall)

local function cosmo_loader(wsapi_env)
  wsapi.common.normalize_paths(wsapi_env)
  wsapi_env.APP_PATH = wsapi.common.splitpath(wsapi_env.PATH_TRANSLATED)
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
  app = wsapi.ringer.new("wsapi.cosmo", bootstrap)
  return app(wsapi_env)
end 

-------------------------------------------------------------------------------
-- Returns the CGILua handler
-------------------------------------------------------------------------------
function makeHandler (diskpath)
   return wsapi.xavante.makeHandler(cosmo_loader, nil, diskpath)
end
