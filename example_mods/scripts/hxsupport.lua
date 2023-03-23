baseLua = {}
for k,v in pairs(_G) do
  table.insert(baseLua, k)
end

hscripts = {}
function onCreate(path)
  fixRH()
  luaDebugMode = true
  addHaxeLibrary 'FunkinLua'
  addHaxeLibrary 'HScript'
  addHaxeLibrary('Lua_helper', 'llua')
  addHaxeLibrary 'Reflect'
  addHaxeLibrary 'Type'
  runHaxeCode([[
  hscripts = [
    'map' => 'map'
  ];
  hscripts.remove('map');
  ]])
  ----debugPrint 'hello im the origingal script'
  --global scripts
  for i,script in pairs(directoryFileList('mods/'..currentModDirectory..'/scripts')) do
    if script:endsWith('.hx') then
      addScript(('scripts/'..currentModDirectory..'/'..script):gsub('//', '/'))
    end
  end
  if #currentModDirectory > 0 then
    for i,script in pairs(directoryFileList('mods/scripts')) do
      if script:endsWith('.hx') then
        addScript('scripts/'..script)
      end
    end
  end
  --stage script
  if checkFileExists('stages/'..curStage..'.hx') then
    addScript('stages/'..curStage..'.hx')
  end
  --character scripts
  local chars = {boyfriendName, dadName, gfName}
  for i,char in pairs(chars) do
    if checkFileExists('scripts/characters/'..char..'.hx') then
      addScript('characters/'..char..'.hx')
    end
  end
  if #hscripts == 0 then --wacky stuff happens when thers no hscripts for some reason
    close();
    return;
  end
  updateLuaVars()
end
events = {}
noteTypes = {}
function onCreatePost()
  --notetypes and event scripts
  for i=0,getProperty('unspawnNotes.length')-1 do
    local has = false
    for k,v in pairs(noteTypes) do
      if v == getPropertyFromGroup('unspawnNotes', i, 'noteType') then
        has = true
      end
    end
    if not has and #getPropertyFromGroup('unspawnNotes', i, 'noteType') > 0 then
      table.insert(noteTypes, getPropertyFromGroup('unspawnNotes', i, 'noteType'))
    end
  end
  for k,v in pairs(noteTypes) do
    if checkFileExists('custom_notetypes/'..v..'.hx') then
      addScript('custom_notetypes/'..v..'.hx')
    end
  end
  for i=0,getProperty('eventNotes.length')-1 do
    local has = false
    for k,v in pairs(events) do
      if v == getPropertyFromGroup('eventNotes', i, 'event') then
        has = true
      end
    end
    if not has then
      --debugPrint(getPropertyFromGroup('eventNotes', i, 'event'))
      table.insert(events, getPropertyFromGroup('eventNotes', i, 'event'))
    end
  end
  for k,v in pairs(events) do
    if checkFileExists('custom_events/'..v..'.hx') then
      addScript('custom_events/'..v..'.hx')
    end
  end
end
function string.startsWith(self, a) return stringStartsWith(self, a) end
function string.endsWith(self, a) return stringEndsWith(self, a) end
function string.split(self, sep)
    local inputstr = self
    if sep == nil then
            sep = "%s"
    end
    local t={}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
            table.insert(t, str)
    end
    return t
end
function addScript(path)
  table.insert(hscripts, path)
  --debugPrint('added hscript: ', path)
  local code = getTextFromFile(path)
  local lines = {} --split everything into lines to detect import lines
  local imports = {}
  for i,line in pairs(code:split('\n')) do
    if not line:startsWith 'import ' then --check for imports
      table.insert(lines, line)
    else
      local nospace = line:split()[2]:gsub(';', '') --get rid of spaces and colons
      local stuff = nospace:split('.') --get the actual modules and packages
      local ok;
      if #stuff > 1 then --see if its in a package
        ok = {}
        for i=1,#stuff-1 do
          table.insert(ok, stuff[i])
        end
      end
      table.insert(imports, {
        name = stuff[#stuff],
        full = nospace
      })
      table.insert(lines, '') --so the error messages line up
    end
  end
  runHaxeCode([[
  var cool = new HScript();
  for(i in Lua_helper.callbacks.keys()) //adds lua callbacks
    cool.interp.variables.set(i, Lua_helper.callbacks.get(i));
  cool.interp.variables.set('Reflect', Reflect); //adds some cool stuff
  cool.interp.variables.set('Type', Type);
  cool.interp.variables.set('this', cool);
  cool.interp.variables.set('HScriptName', path);
  cool.interp.variables.set('code', code);
  cool.interp.variables.set('hscripts', hscripts);
  cool.interp.variables.set('setScriptVariable', function(script, variable, value) {
    if(hscripts.exists(script))
      hscripts.get(script).interp.variables.set(variable, value);
    else
      game.addTextToDebug('Script doesnt existsssss' + script);
  });
  cool.interp.variables.set('getScriptVariable', function(script, variable) {
    if(hscripts.exists(script))
      return hscripts.get(script).interp.variables.get(variable);
    else
      game.addTextToDebug('Script doesnt existsssss' + script);
  });
  //add all the stuff you WANT!!
  if(imports.length > 0)
  {
    for(thing in imports)
      cool.interp.variables.set(thing.name, Type.resolveClass(thing.full));
  }
  cool.execute(code);
  hscripts.set(path, cool);
  if(cool.interp.variables.exists('onCreate'))
    Reflect.callMethod(null, cool.interp.variables.get('onCreate'), []);
  ]], {code = table.concat(lines, '\n'), path = path, imports = imports})
end
function callOnHaxe(func, args)
    local ret = runHaxeCode([[
    var ret = null;
    for(hscript in hscripts)
    {
      if(hscript.interp.variables.exists(func))
      {
        var coolRet = Reflect.callMethod(null, hscript.interp.variables.get(func), args);
        if(coolRet != null)
          ret = coolRet;
      }
    }
    return ret;
    ]], {
      func = func,
      args = args
    })
    return ret
end
function onUpdate()
  updateLuaVars()
end
function setOnHaxe(variable, value)
  runHaxeCode([[
  for(hscript in hscripts)
    hscript.interp.variables.set(variable, value);
  ]], {variable = variable, value = value})
end
function onDestroy()
  callOnHaxe('onDestroy', {})
  runHaxeCode([[
  for(hscript in hscripts)
    hscript = null;
  hscripts = null;
  ]])
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

--this appends every callback to also call on haxe, dont touch this basically lol
callbacks = {
  'onCreatePost', 'onTweenCompleted', 'onTimerCompleted', 'onCustomSubstateCreate', 'onCustomSubstateCreatePost', 'onCustomSubstateUpdate', 'onCustomSubstateUpdatePost',
  'onGameOverStart', 'onGameOverConfirm',  'onGameOver', 'onStartCountdown', 'onCountdownStarted', 'onUpdateScore', 'onNextDialogue', 'onSkipDialogue', 'onSongStart', 'onResume', 'onPause', 
  'onSpawnNote', 'onUpdate', 'onUpdatePost', 'onEvent', 'eventEarlyTrigger', 'onMoveCamera', 'onKeyPress', 'onKeyRelease', 'noteMiss', 'noteMissPress', 'onGhostTap', 'opponentNoteHit', 'goodNoteHit', 'onStepHit', 
  'onBeatHit', 'onSectionHit', 'onRecalculateRating'
}
for i,func in pairs(callbacks) do
  local old = _G[func] --get the orig function
  _G[func] = function(...) --... = args
    if old then --check if there was an orig function
      old(...)
    end
    return callOnHaxe(func, {...})
  end
end
function updateLuaVars()
  for k,v in pairs(_G) do
    local has = false
    for i,o in pairs(baseLua) do
      if o == k then
        has = true
      end
    end
    if not has and type(v) ~= 'function' then
      if type(v) == 'table' then
        local function removeFunctions(inp)
          for k,v in pairs(inp) do
            if type(v) == 'table' then
              inp[k] = removeFunctions(v)
            elseif type(v) == 'function' then
              inp[k] = nil
            end
          end
          return inp
        end
        v = removeFunctions(v)
      end
      setOnHaxe(k, v)
    end
  end
end