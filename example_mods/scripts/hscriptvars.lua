function onCreate()
  fixRH()
end
function fixRH()
  local rh = runHaxeCode
  rh("setVar('luaVarHolder', null);")
  runHaxeCode = function(code, vars)
    if not vars then
      return rh(code)
    else
      setProperty('luaVarHolder', vars)
      local stringVars = {}
      for k,v in pairs(vars) do
          table.insert(stringVars, "var "..k.." = getVar('luaVarHolder')."..k..";")
      end
      local ret = rh(table.concat(stringVars, '\n')..'\n'..code)
      setProperty('luaVarHolder', nil)
      return ret
    end
  end
end