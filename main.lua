io.stdout:setvbuf("no")
collectgarbage("setpause", 100)

isMobile = love.system.getOS() == "Android" or love.system.getOS() == "iOS"
isWeb = love.system.getOS() == "Web"

-- Initializes the whole game to its base state.
function initEngine()
  inputHandler.init()
  control.init()
  globals = {}
  love.filesystem.load("requires.lua")()
  view.init(256, 224, 1)
  cscreen.init(view.w*view.scale, view.h*view.scale, true)
  
  megautils.runFile("core/commands.lua")
  
  -- Game globals.
  mmFont = love.graphics.newFont("assets/misc/mm.ttf", 8)
  globals.mainPlayer = nil
  globals.player = {"mega", "proto", "bass", "roll"}
  globals.allPlayers = {}
  globals.checkpoint = "start"
  globals.infiniteLives = false
  -- `globals.lifeSegements` is how big the player's healthbar is.
  globals.lifeSegments = 7
  globals.maxLifeSegments = 7
  globals.eTanks = 1
  globals.maxETanks = 10
  globals.wTanks = 1
  globals.maxWTanks = 10
  globals.lives = 2
  globals.maxLives = 10
  globals.startingLives = 2
  globals.playerCount = 1
  
  -- `globals.defeats` tells who you've defeated. Add to this to track what bosses you've defeated.
  globals.defeats = {}
  globals.defeats.stickMan = false
  
  megautils.resetGameObjectsFuncs.loadForEveryStage = function()
      megautils.runFile("entities/mechanics/bossdoor.lua")
      megautils.runFile("entities/mechanics/death.lua")
      megautils.runFile("entities/mechanics/ladder.lua")
      megautils.runFile("entities/mechanics/checkpoint.lua")
      megautils.runFile("entities/mechanics/solid.lua")
    end
  
  globals.keyboardCheck = {}
  globals.gamepadCheck = {}
  
  for k, v in pairs(megautils.cleanFuncs) do
    v()
  end
  megautils.unloadAllResources()
  for k, v in pairs(megautils.initEngineFuncs) do
    v()
  end
end

function love.load()
  love.keyboard.setKeyRepeat(true)
  love.graphics.setDefaultFilter("nearest", "nearest")
  consoleFont = love.graphics.getFont() -- needs to be preserved
  altEnterOnce = false
  scaleOnce = false
  deadZone = 0.8
  maxPlayerCount = 4
  useConsole = love.keyboard
  showFPS = false
  showEntityCount = false
  framerate = 1/60
  nesShader = not isWeb and not isMobile and love.graphics.getSupported().glsl3 and love.graphics.newShader("assets/nesLUT.glsl")
  if nesShader then nesShader:send("pal", love.graphics.newImage("assets/nesLUT.png")) end
  
  love.filesystem.load("requirelibs.lua")()
  
  console.init()
  initEngine()
  
  local data = save.load("main.sav") or {}
  if data.fullscreen then
    megautils.setFullscreen(true)
  end
  if data.scale then
    megautils.setScale(data.scale)
  end
  
  megautils.gotoState("states/disclaimer.state.lua")
  console.parse("exec autoexec")
end

function love.resize(w, h)
  cscreen.update(w, h)
  if console.state == 0 and console.y == -console.h then
    console.y = -math.huge
    console.update()
  end
  resized = true
end

function love.joystickadded(j)
  control.loadBinds()
end

function love.joystickremoved(j)
  control.loadBinds()
end

function love.keypressed(k, s, r)
  -- keypressed event must be hijacked for console to work
	if useConsole and console.state == 1 then
		if (k == "backspace") then
			console.backspace()
		end
		if (k == "return") then
			console.send()
		end
		if (k == "up" or k == "down") then
			console.cycle(k)
		end
		if (k == "tab" and #console.input > 0 and #console.getCompletion(console.input) > 0) then
			console.complete()
		end
    return
	end
  
  if not globals.keyboardCheck[k] then
    globals.lastKeyPressed = {"keyboard", k}
  end
  globals.keyboardCheck[k] = 5
  
  control.anyPressed = true
end

function love.gamepadpressed(j, b)
  if useConsole and console.state == 1 then return end
  
  if not globals.gamepadCheck[b] then
    globals.lastKeyPressed = {"gamepad", b, j:getName()}
  end
  globals.gamepadCheck[b] = 5
  control.anyPressed = true
end

function love.gamepadaxis(j, b, v)
  if useConsole and console.state == 1 then return end
  
  if not math.between(v, -deadZone, deadZone) then
    if not globals.gamepadCheck[b] then
      if (b == "leftx" or b == "lefty" or b == "rightx" or b == "righty") then
        globals.axisTmp = {}
        if b == "leftx" or b == "rightx" then
          globals.axisTmp.x = {"axis", b .. (v > 0 and "+" or "-"), v, j:getName()}
        elseif b == "lefty" or b == "righty" then
          globals.axisTmp.y = {"axis", b .. (v > 0 and "+" or "-"), v, j:getName()}
        end
      else
        globals.lastKeyPressed =  {"axis", b .. (v > 0 and "+" or "-"), j:getName()}
      end
    end
    globals.gamepadCheck[b] = 10
  end
end

function love.textinput(k)
  if useConsole then console.doInput(k) end
end

function love.update(dt)
  if love.keyboard and not (useConsole and console.state == 1) then
    if (love.keyboard.isDown("ralt") or love.keyboard.isDown("lalt")) and love.keyboard.isDown("return") then
      if not altEnterOnce then
        megautils.setFullscreen(not megautils.getFullscreen())
        local data = save.load("main.sav") or {}
        data.fullscreen = megautils.getFullscreen()
        save.save("main.sav", data)
      end
      altEnterOnce = 10
    end
    
    if altEnterOnce then
      altEnterOnce = altEnterOnce - 1
      if altEnterOnce == 0 then
        altEnterOnce = false
      end
      return
    end
    
    for i=1, 9 do
      local k = tostring(i)
      if love.keyboard.isDown(k) or love.keyboard.isDown("kp" .. k) then
        if view.w * i ~= love.graphics.getWidth() or
          view.h * i ~= love.graphics.getHeight() then
          if not scaleOnce then
            megautils.setScale(i)
            local data = save.load("main.sav") or {}
            data.scale = megautils.getScale()
            save.save("main.sav", data)
          end
          scaleOnce = 10
        end
      end
    end
    
    if scaleOnce then
      scaleOnce = scaleOnce - 1
      if scaleOnce == 0 then
        scaleOnce = false
      end
      return
    end
  end
  control.update()
  if useConsole then console.update(dt) end
  states.switched = false
  states.update(dt)
  control.flush()
  if love.joystick then
    if globals.axisTmp then
      if globals.axisTmp.x and (not globals.axisTmp.y or
        math.abs(globals.axisTmp.x[3]) > math.abs(globals.axisTmp.y[3])) then
        globals.lastKeyPressed = {globals.axisTmp.x[1], globals.axisTmp.x[2], globals.axisTmp.x[4]}
      elseif globals.axisTmp.y then
        globals.lastKeyPressed = {globals.axisTmp.y[1], globals.axisTmp.y[2], globals.axisTmp.y[4]}
      end
      globals.axisTmp = nil
    end
    for k, v in pairs(globals.gamepadCheck) do
      globals.gamepadCheck[k] = globals.gamepadCheck[k] - 1
      if globals.gamepadCheck[k] < 0 then
        globals.gamepadCheck[k] = nil
      end
    end
  end
  if love.keyboard then
    for k, v in pairs(globals.keyboardCheck) do
      globals.keyboardCheck[k] = globals.keyboardCheck[k] - 1
      if globals.keyboardCheck[k] < 0 then
        globals.keyboardCheck[k] = nil
      end
    end
  end
end

function love.draw(screen)
  love.graphics.push()
  states.draw()
  love.graphics.pop()
  if useConsole then console.draw() end
end

if isWeb then

  -- `love.filesystem.getInfo` doesn't exist in the current love.js, so here's an implementation.
  function love.filesystem.getInfo(str, arg1, arg2)
    if love.filesystem.exists(str) then
      local t = "other"
      if love.filesystem.isFile(str) then
        t = "file"
      elseif love.filesystem.isDirectory(str) then
        t = "directory"
      elseif love.filesystem.isSymlink(str) then
        t = "symlink"
      end
      
      local fCheck = true
      local result = (type(arg1) == "table") and arg1
      
      if type(arg1) == "string" then
        fCheck = arg1 == t
      elseif type(arg1) == "table" and type(arg2) == "string" then
        fCheck = arg2 == t
      end
      
      if fCheck then
        if not result then
          result = {}
        end
        result.type = t
        result.size = love.filesystem.getSize(str)
        result.modtime = love.filesystem.getLastModified(str)
      end
      
      return result
    end
  end
  
  -- Fullscreening is broken.
  function love.window.setFullscreen() end

else

  -- Love2D doesn't fire the resize event for several functions, so here's some hacks.
  local lf = love.window.setFullscreen
  local lsm = love.window.setMode
  local lum = love.window.updateMode

  function love.window.setFullscreen(s)
    lf(s)
    love.resize(love.graphics.getDimensions())
  end
  
  function love.window.setMode(w, h, f)
    lsm(w, h, f)
    love.resize(love.graphics.getDimensions())
  end
  
  function love.window.updateMode(w, h, f)
    lum(w, h, f)
    love.resize(love.graphics.getDimensions())
  end

end

if not isWeb then
  function love.run()
    if love.load then love.load(love.arg.parseGameArguments(arg), arg) end
    if love.timer then love.timer.step() end
    local dt = 0
    return function()
        if love.event then
          love.event.pump()
          for name, a,b,c,d,e,f in love.event.poll() do
            if name == "quit" then
              if not love.quit or not love.quit() then
                return a or 0
              end
            end
            love.handlers[name](a,b,c,d,e,f)
          end
        end
        if love.timer then
          love.timer.step()
          dt = love.timer.getDelta()
        end
        local bu = love.timer.getTime()
        if love.update then love.update(dt) end
        if love.graphics and love.graphics.isActive() then
          love.graphics.origin()
          love.graphics.clear(love.graphics.getBackgroundColor())
          if love.draw then love.draw() end
          love.graphics.present()
        end
        local delta = love.timer.getTime() - bu
        if delta < framerate then love.timer.sleep(framerate - delta) end
        resized = false
      end
  end
end