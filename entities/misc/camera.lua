camera = entity:extend()

addobjects.register("megacam", function(v)
  if v.properties["checkpoint"] == globals.checkpoint then
    megautils.add(camera(v.x, v.y, v.properties["doScrollX"], v.properties["doScrollY"]))
    camera.once = false
  end
end, -1)

addobjects.register("megacam", function(v)
  if v.properties["checkpoint"] == globals.checkpoint and not camera.once and camera.main then
    camera.once = true
    camera.main:updateBounds()
  end
end, 2)

megautils.resetStateFuncs["camera"] = function() camera.main = nil end

function camera:new(x, y, doScrollX, doScrollY)
  camera.super.new(self)
  self.transform.y = y
  self.transform.x = x
  self:setRectangleCollision(view.w, view.h)
  self.transition = false
  self.transitiondirection = "right"
  self.doShift = false
  self.freeze = true
  self.updateSections = true
  self.shiftX = 0
  self.shiftY = 0
  self.scrollx = 0
  self.scrollw = 0
  self.scrolly = 0
  self.scrollh = 0
  self.lockx = 0
  self.locky = 0
  self.lockw = 0
  self.lockh = 0
  self.locked = false
  self.curLock = ""
  self.doScrollY = doScrollY == nil and true or doScrollY
  self.doScrollX = doScrollX == nil and true or doScrollX
  self.transX = 0
  self.transY = 0
  self.speed = 1
  self.toSection = nil
  self.once = false
  self.updateOnce = false
  self.transitionDone = false
  camera.main = self
  self.player = nil
  view.x, view.y = self.transform.x, self.transform.y
  self.funcs = {}
end

function camera:updateBounds()
  if not self.toSection then
    self.toSection = self:collisionTable(megautils.state().sectionHandler.sections)[1]
    local tmp = self:collisionTable(megautils.groups()["lock"])
    self.curLock = #tmp ~= 0 and tmp[1].name
  end
  if self.toSection then
    if self.toSection:is(lockSection) then
      self.toSection = self.toSection.section
    end
    megautils.state().sectionHandler.next = self.toSection
    megautils.state().sectionHandler:updateAll()
    self.scrollx = self.toSection.transform.x
    self.scrollw = self.toSection.collisionShape.w
    self.scrolly = self.toSection.transform.y
    self.scrollh = self.toSection.collisionShape.h
  else
    self.scrollx = -math.huge
    self.scrollw = math.huge
    self.scrolly = -math.huge
    self.scrollh = math.huge
  end
end

function camera:updateCam()
  if self.transition then
    self.transitionDone = false
    if not self.preTrans then
      if not self.toPos then
        if self.transitiondirection == "up" or self.transitiondirection == "down" then
          self.toPos = math.round(self.player.transform.x) - (view.w/2) + (self.player.collisionShape.w/2)
          self.toPos = math.clamp(self.toPos, self.scrollx, self.scrollx+self.scrollw-view.w)
        elseif self.transitiondirection == "left" or self.transitiondirection == "right" then
          self.toPos = math.round(self.player.transform.y) - (view.h/2) + (self.player.collisionShape.h/2)
          self.toPos = math.clamp(self.toPos+(self.player.slide and -3 or 0), self.scrolly, self.scrolly+self.scrollh-view.h)
        end
      end
      if self.transitiondirection == "up" or self.transitiondirection == "down" then
        self.transform.x = math.approach(self.transform.x, self.toPos, 4)
        if self.transform.x == self.toPos then
          self.toPos = nil
          self.preTrans = true
        end
      elseif self.transitiondirection == "left" or self.transitiondirection == "right" then
        self.transform.y = math.approach(self.transform.y, self.toPos, 4)
        if self.transform.y == self.toPos then
          self.toPos = nil
          self.preTrans = true
        end
      end
      camera.main.transform.x = math.round(camera.main.transform.x)
      camera.main.transform.y = math.round(camera.main.transform.y)
      view.x, view.y = math.round(camera.main.transform.x), math.round(camera.main.transform.y)
      camera.main:updateFuncs()
    elseif not self.once then
      if megautils.groups()["removeOnTransition"] then
        for k, v in pairs(megautils.groups()["removeOnTransition"]) do
          if not v.dontRemove then
            megautils.remove(v, true)
          end
        end
      end
      if self.freeze then
        megautils.freeze(globals.allPlayers)
        for k, v in pairs(globals.allPlayers) do
          v.control = false
        end
      end 
      if self.player then
        if not self.toSection then self.toSection = megautils.state().sectionHandler.current end
        for k, v in pairs(self.toSection.group) do
          if v.spawnEarlyDuringTransition and not v.isAdded then
            megautils.add(v)
          end
        end
        local sx, sy, sw, sh = self.toSection.transform.x, self.toSection.transform.y,
          self.toSection.collisionShape.w, self.toSection.collisionShape.h
        if self.transitiondirection == "right" then
          if self.doScrollY then
            self.tween = tween.new(self.speed, self.transform, {x=self.transform.x+self.collisionShape.w,
              y=math.clamp(self.player.transform.y
              - (view.h/2) + (self.player.collisionShape.h/2)+(self.player.slide and -3 or 0), sy, (sy+sh)-view.h)})
          else
            self.tween = tween.new(self.speed, self.transform, {x=self.transform.x+self.collisionShape.w})
          end
          self.tween2 = {}
          for i=1, #globals.allPlayers do
            self.tween2[i] = tween.new(self.speed, globals.allPlayers[i].transform, {x=self.transX, y=self.player.transform.y})
          end
        elseif self.transitiondirection == "left" then
          if self.doScrollY then
            self.tween = tween.new(self.speed, self.transform, {x=self.transform.x-self.collisionShape.w,
              y=math.clamp(self.player.transform.y
              - (view.h/2) + (self.player.collisionShape.h/2)+(self.player.slide and -3 or 0), sy, (sy+sh)-view.h)})
          else
            self.tween = tween.new(self.speed, self.transform, {x=self.transform.x-self.collisionShape.w})
          end
          self.tween2 = {}
          for i=1, #globals.allPlayers do
            self.tween2[i] = tween.new(self.speed, globals.allPlayers[i].transform, {x=self.transX, y=self.player.transform.y})
          end
        elseif self.transitiondirection == "down" then
          if self.doScrollX then
            self.tween = tween.new(self.speed, self.transform, {y=self.transform.y+self.collisionShape.h,
              x=math.clamp(self.player.transform.x
              - (view.w/2) + (self.player.collisionShape.w/2)+(self.player.slide and -3 or 0), sx, (sx+sw)-view.w)})
          else
            self.tween = tween.new(self.speed, self.transform, {y=self.transform.y+self.collisionShape.h})
          end
          self.tween2 = {}
          for i=1, #globals.allPlayers do
            self.tween2[i] = tween.new(self.speed, globals.allPlayers[i].transform, {x=self.player.transform.x, y=self.transY})
          end
        elseif self.transitiondirection == "up" then
          if self.doScrollX then
            self.tween = tween.new(self.speed, self.transform, {y=self.transform.y-self.collisionShape.h,
              x=math.clamp(self.player.transform.x
              - (view.w/2) + (self.player.collisionShape.w/2)+(self.player.slide and -3 or 0), sx, (sx+sw)-view.w)})
          else
            self.tween = tween.new(self.speed, self.transform, {y=self.transform.y-self.collisionShape.h})
          end
          self.tween2 = {}
          for i=1, #globals.allPlayers do
            self.tween2[i] = tween.new(self.speed, globals.allPlayers[i].transform, {x=self.player.transform.x, y=self.transY})
          end
        end
      end
      if self.player.onMovingFloor then
        self.flx = self.player.onMovingFloor.transform.x - self.player.transform.x
      end
      self.once = true
      megautils.state().system.afterUpdate = function(s)
        for i=1, #globals.allPlayers do
          camera.main.tween2[i]:update(1/60)
        end
        if camera.main.tween:update(1/60) then
          camera.main.transition = false
          camera.main.once = false
          camera.main.scrollx, camera.main.scrolly, camera.main.scrollw, camera.main.scrollh = camera.main.toSection.transform.x,
            camera.main.toSection.transform.y, camera.main.toSection.collisionShape.w, camera.main.toSection.collisionShape.h
          if camera.main.updateSections then
            camera.main:updateBounds()
            camera.main.toSection = nil
            if camera.main.freeze then
              megautils.unfreeze(globals.allPlayers)
              for k, v in pairs(globals.allPlayers) do
                v.control = true
              end
            end
            if camera.main.player and camera.main.player.onMovingFloor then
              camera.main.player.onMovingFloor.dontRemove = nil
            end
          end
          for i=1, #globals.allPlayers do
            if globals.allPlayers[i] ~= camera.main.player then
              camera.main.player:transferState(globals.allPlayers[i])
            end
          end
          camera.main.tween = nil
          camera.main.tween2 = nil
          camera.main.transitionDone = true
          megautils.state().system.afterUpdate = nil
          camera.main.preTrans = nil
          camera.main.locked = nil
          camera.main.curLock = ""
        end
        if camera.main.player and camera.main.player.onMovingFloor then
          camera.main.player.onMovingFloor.transform.x = camera.main.player.transform.x + camera.main.flx
          camera.main.player.onMovingFloor.transform.y = camera.main.player.transform.y + camera.main.player.collisionShape.h
        end
        camera.main.transform.x = math.round(camera.main.transform.x)
        camera.main.transform.y = math.round(camera.main.transform.y)
        view.x, view.y = math.round(camera.main.transform.x), math.round(camera.main.transform.y)
        camera.main:updateFuncs()
      end
    end
  else
    self:doView()
  end
end

function camera:doView(without)
  if #globals.allPlayers <= 1 then
    local o = globals.allPlayers[1]
    if self.doScrollX then
      self.transform.x = math.round(o.transform.x) - (view.w/2) + (o.collisionShape.w/2)
      self.transform.x = math.clamp(self.transform.x, self.scrollx, self.scrollx+self.scrollw-view.w)
    end
    if self.doScrollY then
      self.transform.y = math.round(o.transform.y) - (view.h/2) + (o.collisionShape.h/2)
      self.transform.y = math.clamp(self.transform.y+(o.slide and -3 or 0), self.scrolly, self.scrolly+self.scrollh-view.h)
    end
  else
    local avx, avy = 0, 0
    for i=1, #globals.allPlayers do
      local p = globals.allPlayers[i]
      if not p.rise and not p.drop and p ~= without then
        if self.doScrollX then
          avx = avx+(p.transform.x - (view.w/2) + (p.collisionShape.w/2))
        end
        if self.doScrollY then
          avy = avy+(p.transform.y+(p.slide and -3 or 0) - (view.h/2) + (p.collisionShape.h/2))
        end
      end
    end
    if self.doScrollX then
      self.transform.x = (avx/#globals.allPlayers)
      self.transform.x = math.clamp(self.transform.x, self.scrollx, self.scrollx+self.scrollw-view.w)
    end
    if self.doScrollY then
      self.transform.y = (avy/#globals.allPlayers)
      self.transform.y = math.clamp(self.transform.y, self.scrolly, self.scrolly+self.scrollh-view.h)
    end
  end
  if megautils.groups()["lock"] then
    self.locked = self:collisionTable(megautils.groups()["lock"])
    if #self.locked == 0 then self.locked = nil end
    local result = false
    for i=1, #self.locked do
      local v = self.locked[i]
      if not v.name then
        break
      elseif v.name == self.curLock then
        self.lockx = v.transform.x
        self.locky = v.transform.y
        self.lockw = v.collisionShape.w
        self.lockh = v.collisionShape.h
        result = true
        break
      end
    end
    if not result then self.locked = nil end
  else
    self.locked = nil
  end
  if self.locked then
    self.transform.x = math.clamp(self.transform.x, self.lockx, self.lockx+self.lockw)
    self.transform.y = math.clamp(self.transform.y, self.locky, self.locky+self.lockh)
  end
  view.x, view.y = math.round(self.transform.x), math.round(self.transform.y)
  self:updateFuncs()
end

function camera:updateFuncs()
  for k, v in pairs(self.funcs) do
    v(self)
  end
end