-----------------------------------------------------------------------------
-- Xavante Cosmo handler
--
-- Author: Fabio Mascarenhas
--
-----------------------------------------------------------------------------

require "wsapi.xavante"
require "wsapi.common"

module ("xavante.cosmohandler", package.seeall)

local function cosmo_loader(wsapi_env)
  wsapi.common.normalize_paths(wsapi_env)
  local app = wsapi.common.load_isolated_launcher(wsapi_env.PATH_TRANSLATED, "wsapi.cosmo")
  return app(wsapi_env)
end 

-------------------------------------------------------------------------------
-- Returns the CGILua handler
-------------------------------------------------------------------------------
function makeHandler (diskpath)
   return wsapi.xavante.makeHandler(cosmo_loader, nil, diskpath)
end
