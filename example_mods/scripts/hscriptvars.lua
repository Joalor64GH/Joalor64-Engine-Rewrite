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
        local addedCode = ''
        setProperty('luaVarHolder', vars)
        for k,v in pairs(vars) do
          addedCode = addedCode.."var "..k.." = getVar('luaVarHolder')."..k..";\n"
        end
        rh(addedCode..'\n'..code)
        setProperty('luaVarHolder', nil)
      end
    end
  end