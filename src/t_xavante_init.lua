-- Lua 5.1 init file for Xavante
--
-- Prepares the paths for Lua and C modules using three parameters:
--    conf    - configuration files (optional, checked before the Lua modules)
--    luabase - Lua modules
--    libbase - C modules
--
-- (the paths should not end in /)
--
-- $Id: t_xavante_init.lua,v 1.2 2006/12/19 22:00:55 carregal Exp $

-- Lua 5.1 paths
local conf51    = [[XAVANTE_CONF]]
local luabase51 = [[LUABASE51]]
local libbase51 = [[LIBBASE51]]

-- Library extension used in the system (dll, so etc)
local libext = [[LIB_EXT]]

XAVANTE_WEB = [[XAVANTE_WEB]]

--------- end of parameters ------------

local function expandPath(base, conf)
  local path = ""
  if conf and conf ~= "" then
    path = path..conf..[[/?.lua;]]
  end
  path = path..base..[[/?.lua;]]..base..[[/?/?.lua;]]..base..[[/?/init.lua]]
  return path
end

local function expandCPath(base)
  return base..[[/?.]]..libext..[[;]]..base..[[/l?.]]..libext..[[;]]..base..[[/?/l?.]]..libext
end

if string.find (_VERSION, "Lua 5.1") then
  package.path = expandPath(luabase51, conf51)
  package.cpath = expandCPath(libbase51)
else
  error("This init file works only with Lua 5.1")
end
