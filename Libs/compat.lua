local compat = {}
compat.strsplit = function(sep,s)
    local sep, fields = sep or ":", {}
    local pattern = string.format("([^%s]+)", sep)
    string.gsub(s, pattern, function(c) fields[table.getn(fields)+1] = c end)
    return unpack(fields)
end
compat.select = function(index,...)
  assert(tonumber(index) or index=="#","Invalid argument #1 to select(). Usage: select(\"#\"|int,...)")
  if index == "#" then return arg.n end
  local sub = {}
  for i=index,arg.n do
    sub[table.getn(sub)+1] = arg[i]
  end
  return unpack(sub)
end
compat.__index = function(t,k)
  local v = compat[k]
  if v then
    --rawset(t,k,v)
    return v
  else
    return nil
  end
end
local _G = getfenv(0)
if not (select and strsplit 
  and type(select) == "function"
  and type(strsplit) == "function") then
  setmetatable(_G,compat)
end