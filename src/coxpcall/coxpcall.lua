-------------------------------------------------------------------------------
-- Coroutine safe xpcall and pcall versions
--
-- Encapsulates the protected calls with a coroutine based loop, so errors can
-- be dealed without the usual Lua 5.0 pcall/xpcall issues with coroutines
-- yielding inside the call to pcall or xpcall.
--
-- Authors: Roberto Ierusalimschy and Andre Carregal 
--
-- Copyright 2005-2006 - Kepler Project (www.keplerproject.org)
--
-- $Id: coxpcall.lua,v 1.7 2006/08/02 13:30:07 carregal Exp $
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Implements xpcall with coroutines
-------------------------------------------------------------------------------
function coxpcall(f, err)
  local co = coroutine.create(f)
  local arg = {}
  while true do
    local results = {coroutine.resume(co, unpack(arg))}
    local status = results[1]
    table.remove (results, 1) -- remove status of coroutine.resume
    if not status then
      return false, err(unpack(results))
    end
    if coroutine.status(co) == "suspended" then
      arg = {coroutine.yield(unpack(results))}
    else
      return true, unpack(results)
    end
  end
end

-------------------------------------------------------------------------------
-- Implements pcall with coroutines
-------------------------------------------------------------------------------
function copcall(f, ...)
  return coxpcall(function() return f(unpack(arg)) end, error) 
end