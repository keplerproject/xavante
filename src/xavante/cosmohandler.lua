-----------------------------------------------------------------------------
-- Xavante Cosmo handler
--
-- Author: Fabio Mascarenhas
--
-----------------------------------------------------------------------------

require "wsapi.xavante"
require "wsapi.common"
require "wsapi.ringer"
require "wsapi.cosmo"

module ("xavante.cosmohandler", package.seeall)

local function cosmo_loader(wsapi_env)
  wsapi.common.normalize_paths(wsapi_env)
  return wsapi.cosmo.run(wsapi_env)
end 

-------------------------------------------------------------------------------
-- Returns the CGILua handler
-------------------------------------------------------------------------------
function makeHandler (diskpath)
   return wsapi.xavante.makeHandler(cosmo_loader, nil, diskpath)
end
