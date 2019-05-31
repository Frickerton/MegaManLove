protoSemiBuster = basicEntity:extend()

function protoSemiBuster:new(x, y, dir, wpn)
  protoSemiBuster.super.new(self)
  self.added = function(self)
    self:addToGroup("protoBuster")
    self:addToGroup("protoBuster" .. wpn.id)
    self:addToGroup("freezable")
    self:addToGroup("removeOnTransition")
  end
  self.transform.y = y
  self.transform.x = x
  self:setRectangleCollision(10, 10)
  self.tex = loader.get("proto_buster")
  self.quad = love.graphics.newQuad(0, 0, 10, 10, 68, 10)
  self.dink = false
  self.velocity = velocity()
  self.velocity.velx = dir * 5
  self.side = dir
  self.wpn = wpn
  mmSfx.play("semi_charged")
  self:setLayer(1)
end

function protoSemiBuster:update(dt)
  if not self.dink then
    self:hurt(self:collisionTable(megautils.groups()["hurtable"]), -1, 2)
  else
    self.velocity.vely = -4
    self.velocity.velx = 4*-self.side
  end
  self.transform.x = self.transform.x + self.velocity.velx
  self.transform.y = self.transform.y + self.velocity.vely
  if megautils.outside(self) or self.wpn.currentSlot ~= 0 then
    megautils.remove(self, true)
  end
end

function protoSemiBuster:draw()
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.draw(self.tex, self.quad, math.round(self.transform.x), math.round(self.transform.y)-3)
end

protoChargedBuster = entity:extend()

function protoChargedBuster:new(x, y, dir, wpn)
  protoChargedBuster.super.new(self)
  self.added = function(self)
    self:addToGroup("protoChargedBuster")
    self:addToGroup("protoChargedBuster" .. wpn.id)
    self:addToGroup("freezable")
    self:addToGroup("removeOnTransition")
  end
  self.tex = loader.get("proto_buster")
  self.anim = anim8.newAnimation(loader.get("proto_buster_grid")("1-2", 1), 1/20)
  self.transform.y = y
  self.transform.x = x
  self:setRectangleCollision(29, 8)
  self.dink = false
  self.velocity = velocity()
  self.spd = 4
  self.velocity.velx = dir * 6
  self.side = dir
  self.wpn = wpn
  mmSfx.play("proto_charged")
  self:face(-self.side)
  self:setLayer(1)
end

function protoChargedBuster:face(n)
  self.anim.flippedH = (n == 1) and true or false
end

function protoChargedBuster:update(dt)
  self.anim:update(1/60)
  if not self.dink then
    self:hurt(self:collisionTable(megautils.groups()["hurtable"]), -2, 2)
  else
    self.velocity.vely = -4
    self.velocity.velx = 4*-self.side
  end
  self.transform.x = self.transform.x + self.velocity.velx
  self.transform.y = self.transform.y + self.velocity.vely
  if megautils.outside(self) or self.wpn.currentSlot ~= 0 then
    megautils.remove(self, true)
  end
end

function protoChargedBuster:draw()
  love.graphics.setColor(1, 1, 1, 1)
  self.anim:draw(self.tex, math.round(self.transform.x), math.round(self.transform.y-1))
end

rollBuster = basicEntity:extend()

function rollBuster:new(x, y, dir, wpn)
  rollBuster.super.new(self)
  self.added = function(self)
    self:addToGroup("rollBuster")
    self:addToGroup("rollBuster" .. wpn.id)
    self:addToGroup("freezable")
    self:addToGroup("removeOnTransition")
  end
  self.transform.y = y
  self.transform.x = x
  self:setRectangleCollision(6, 6)
  self.tex = loader.get("bass_buster")
  self.dink = false
  self.side = dir
  self.velocity = velocity()
  self.velocity.velx = self.side * 6
  self.wpn = wpn
  self:setLayer(1)
  mmSfx.play("buster")
end

function rollBuster:update(dt)
  if not self.dink then
    self:hurt(self:collisionTable(megautils.groups()["hurtable"]), -1, 2)
  else
    self.velocity.vely = -4
    self.velocity.velx = 4*-self.side
  end
  self.transform.x = self.transform.x + self.velocity.velx
  self.transform.y = self.transform.y + self.velocity.vely
  if megautils.outside(self) or (self.wpn.currentSlot ~= 0 and self.wpn.currentSlot ~= 9
    and self.wpn.currentSlot ~= 10) then
    megautils.remove(self, true)
  end
end

function rollBuster:draw()
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.draw(self.tex, math.round(self.transform.x-1), math.round(self.transform.y-1))
end

bassBuster = basicEntity:extend()

function bassBuster:new(x, y, dir, wpn)
  bassBuster.super.new(self)
  self.added = function(self)
    self:addToGroup("bassBuster")
    self:addToGroup("bassBuster" .. wpn.id)
    self:addToGroup("freezable")
    self:addToGroup("removeOnTransition")
  end
  self.transform.y = y
  self.transform.x = x
  self:setRectangleCollision(6, 6)
  self.tex = loader.get("bass_buster")
  self.dink = false
  self.velocity = velocity()
  self.velocity.velx = megautils.calcX(dir) * 5
  self.velocity.vely = megautils.calcY(dir) * 5
  self.side = self.velocity.velx < 0 and -1 or 1
  self.wpn = wpn
  self:setLayer(1)
  mmSfx.play("buster")
end

function bassBuster:update(dt)
  if not self.dink then
    self:hurt(self:collisionTable(megautils.groups()["hurtable"]), -0.5, 2)
  else
    self.velocity.vely = -4
    self.velocity.velx = 4*-self.side
  end
  self.transform.x = self.transform.x + self.velocity.velx
  self.transform.y = self.transform.y + self.velocity.vely
  if megautils.outside(self) or (self.wpn.currentSlot ~= 0 and self.wpn.currentSlot ~= 9
    and self.wpn.currentSlot ~= 10) or collision.checkSolid(self) or #self:collisionTable(megautils.groups()["boss_door"]) ~= 0 then
    megautils.remove(self, true)
  end
end

function bassBuster:draw()
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.draw(self.tex, math.round(self.transform.x-1), math.round(self.transform.y-1))
end

megaBuster = basicEntity:extend()

function megaBuster:new(x, y, dir, wpn)
  megaBuster.super.new(self)
  self.added = function(self)
    self:addToGroup("megaBuster")
    self:addToGroup("megaBuster" .. wpn.id)
    self:addToGroup("freezable")
    self:addToGroup("removeOnTransition")
  end
  self.transform.y = y
  self.transform.x = x
  self:setRectangleCollision(8, 6)
  self.tex = loader.get("buster_tex")
  self.quad = love.graphics.newQuad(0, 31, 8, 6, 133, 47)
  self.dink = false
  self.velocity = velocity()
  self.velocity.velx = dir * 5
  self.side = dir
  self.wpn = wpn
  self:setLayer(1)
  mmSfx.play("buster")
end

function megaBuster:update(dt)
  if not self.dink then
    self:hurt(self:collisionTable(megautils.groups()["hurtable"]), -1, 2)
  else
    self.velocity.vely = -4
    self.velocity.velx = 4*-self.side
  end
  self.transform.x = self.transform.x + self.velocity.velx
  self.transform.y = self.transform.y + self.velocity.vely
  if megautils.outside(self) or (self.wpn.currentSlot ~= 0 and self.wpn.currentSlot ~= 9
    and self.wpn.currentSlot ~= 10) then
    megautils.remove(self, true)
  end
end

function megaBuster:draw()
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.draw(self.tex, self.quad, math.round(self.transform.x), math.round(self.transform.y))
end

megaSemiBuster = basicEntity:extend()

function megaSemiBuster:new(x, y, dir, wpn)
  megaSemiBuster.super.new(self)
  self.added = function(self)
    self:addToGroup("megaBuster")
    self:addToGroup("megaBuster" .. wpn.id)
    self:addToGroup("freezable")
    self:addToGroup("removeOnTransition")
  end
  self.transform.y = y
  self.transform.x = x
  self:setRectangleCollision(16, 10)
  self.tex = loader.get("buster_tex")
  self.anim = anim8.newAnimation(loader.get("small_charge_grid")("1-2", 1), 1/12)
  self.dink = false
  self.velocity = velocity()
  self.velocity.velx = dir * 5
  self.side = dir
  self.wpn = wpn
  mmSfx.play("semi_charged")
  self:face(-self.side)
  self:setLayer(1)
end

function megaSemiBuster:face(n)
  self.anim.flippedH = (n == 1) and true or false
end

function megaSemiBuster:update(dt)
  self.anim:update(1/60)
  if not self.dink then
    self:hurt(self:collisionTable(megautils.groups()["hurtable"]), -1, 2)
  else
    self.velocity.vely = -4
    self.velocity.velx = 4*-self.side
  end
  self.transform.x = self.transform.x + self.velocity.velx
  self.transform.y = self.transform.y + self.velocity.vely
  if megautils.outside(self) or self.wpn.currentSlot ~= 0 then
    megautils.remove(self, true)
  end
end

function megaSemiBuster:draw()
  love.graphics.setColor(1, 1, 1, 1)
  self.anim:draw(self.tex, math.round(self.transform.x), math.round(self.transform.y)-3)
end

megaChargedBuster = basicEntity:extend()

function megaChargedBuster:new(x, y, dir, wpn)
  megaChargedBuster.super.new(self)
  self.added = function(self)
    self:addToGroup("megaChargedBuster")
    self:addToGroup("megaChargedBuster" .. wpn.id)
    self:addToGroup("freezable")
    self:addToGroup("removeOnTransition")
  end
  self.tex = loader.get("buster_tex")
  self.anim = anim8.newAnimation(loader.get("charge_grid")("1-4", 1), 1/20)
  self.transform.y = y
  self.transform.x = x
  self:setRectangleCollision(24, 24)
  self.dink = false
  self.velocity = velocity()
  self.spd = 4
  self.velocity.velx = dir * 5.5
  self.side = dir
  self.wpn = wpn
  mmSfx.play("charged")
  self:face(-self.side)
  self:setLayer(1)
end

function megaChargedBuster:face(n)
  self.anim.flippedH = (n == 1) and true or false
end

function megaChargedBuster:update(dt)
  self.anim:update(1/60)
  if not self.dink then
    self:hurt(self:collisionTable(megautils.groups()["hurtable"]), -2, 2)
  else
    self.velocity.vely = -4
    self.velocity.velx = 4*-self.side
  end
  self.transform.x = self.transform.x + self.velocity.velx
  self.transform.y = self.transform.y + self.velocity.vely
  if megautils.outside(self) or self.wpn.currentSlot ~= 0 then
    megautils.remove(self, true)
  end
end

function megaChargedBuster:draw()
  love.graphics.setColor(1, 1, 1, 1)
  self.anim:draw(self.tex, math.round(self.transform.x)-8, math.round(self.transform.y)-3)
end

rushJet = entity:extend()

function rushJet:new(x, y, side, player, wpn)
  rushJet.super.new(self)
  self.added = function(self)
    self:addToGroup("rushJet")
    self:addToGroup("rushJet" .. wpn.id)
    self:addToGroup("freezable")
    self:addToGroup("removeOnTransition")
  end
  self.transform.x = x
  self.transform.y = view.y-8
  self.toY = y
  self:setRectangleCollision(27, 8)
  self.tex = loader.get("rush")
  self.c = "spawn"
  self.anims = {}
  self.anims["spawn"] = anim8.newAnimation(loader.get("rush_grid")(1, 1), 1)
  self.anims["spawn_land"] = anim8.newAnimation(loader.get("rush_grid")("2-3", 1, 2, 1), 1/20)
  self.anims["jet"] = anim8.newAnimation(loader.get("rush_grid")("2-3", 2), 1/8)
  self.side = side
  self.s = 0
  self.velocity = velocity()
  self.wpn = wpn
  self.timer = 0
  self.isSolid = 2
  self.blockCollision = true
  self:setLayer(2)
  self.player = player
  self.playerOn = false
end

function rushJet:face(n)
  self.anims[self.c].flippedH = (n ~= 1) and true or false
end

function rushJet:update(dt)
  self.anims[self.c]:update(1/60)
  if self.s == -1 then
    self:moveBy(0, 8)
  elseif self.s == 0 then
    self.transform.y = math.min(self.transform.y+8, self.toY)
    if self.transform.y == self.toY then
      if not collision.checkSolid(self) then
        self.c = "spawn_land"
        self.s = 1
      else
        self.s = -1
      end
    end
  elseif self.s == 1 then
    if self.anims["spawn_land"].looped then
      mmSfx.play("start")
      self.c = "jet"
      self.s = 2
    end
  elseif self.s == 2 then
    if self.player:collision(self, 0, 1) and self.player.transform.y == self.transform.y - self.player.collisionShape.h then
      self.s = 3
      self.velocity.velx = self.side
      self.player.canWalk = false
      self.playerOn = true
    end
    self:moveBy(self.velocity.velx, self.velocity.vely)
    collision.doCollision(self)
  elseif self.s == 3 then
    if self.playerOn then
      if control.upDown[self.player.player] then
        self.velocity.vely = -1
      elseif control.downDown[self.player.player] then
        self.velocity.vely = 1
      else
        self.velocity.vely = 0
      end
    else
      self.velocity.vely = 0
      if self.player:collision(self, 0, 1) and self.player.transform.y == self.transform.y - self.player.collisionShape.h then
        self.s = 3
        self.velocity.velx = self.side
        self.player.canWalk = false
        self.playerOn = true
      end
    end
    collision.doCollision(self)
    if self.playerOn and self.player.transform.y ~= self.transform.y - self.player.collisionShape.h then
      self.player.canWalk = true
      self.playerOn = false
    end
    if self.xcoll ~= 0 or
      (self.playerOn and collision.checkSolid(self, 0, -self.player.collisionShape.h-4)) then
      if self.playerOn then self.player.canWalk = true self.player.onMovingFloor = nil end
      self.c = "spawn_land"
      self.anims["spawn_land"]:gotoFrame(1)
      self.s = 4
      self.isSolid = 0
      mmSfx.play("ascend")
    end
    self.timer = math.min(self.timer+1, 60)
    if self.timer == 60 then
      self.timer = 0
      self.wpn.energy[self.wpn.currentSlot] = self.wpn.energy[self.wpn.currentSlot] - 1
    end
  elseif self.s == 4 then
    if self.anims["spawn_land"].looped then
      self.s = 5
      self.c = "spawn"
    end
  elseif self.s == 5 then
    self:moveBy(0, -8)
  end
  self:face(self.side)
  if megautils.outside(self) or self.wpn.currentSlot ~= 10 then
    megautils.remove(self, true)
  end
end

function rushJet:removed()
  self.player.canWalk = true
end

function rushJet:draw()
  love.graphics.setColor(1, 1, 1, 1)
  if self.c == "spawn" or self.c == "spawn_land" then
    self.anims[self.c]:draw(self.tex, math.round(self.transform.x-4), math.round(self.transform.y-16))
  else
    self.anims[self.c]:draw(self.tex, math.round(self.transform.x-4), math.round(self.transform.y-12))
  end
end

rushCoil = entity:extend()

function rushCoil:new(x, y, side, w)
  rushCoil.super.new(self)
  self.added = function(self)
    self:addToGroup("rushCoil")
    self:addToGroup("rushCoil" .. w.id)
    self:addToGroup("freezable")
    self:addToGroup("removeOnTransition")
  end
  self.transform.x = x
  self.transform.y = view.y-16
  self.toY = y
  self:setRectangleCollision(20, 19)
  self.tex = loader.get("rush")
  self.c = "spawn"
  self.anims = {}
  self.anims["spawn"] = anim8.newAnimation(loader.get("rush_grid")(1, 1), 1)
  self.anims["spawn_land"] = anim8.newAnimation(loader.get("rush_grid")("2-3", 1, 2, 1), 1/20)
  self.anims["idle"] = anim8.newAnimation(loader.get("rush_grid")(4, 1, 1, 2), 1/8)
  self.anims["coil"] = anim8.newAnimation(loader.get("rush_grid")(4, 2), 1)
  self.side = side
  self.s = 0
  self.timer = 0
  self.velocity = velocity()
  self.wpn = w
  self.blockCollision = true
  self:setLayer(2)
end

function rushCoil:face(n)
  self.anims[self.c].flippedH = (n ~= 1) and true or false
end

function rushCoil:update(dt)
  self.anims[self.c]:update(1/60)
  if self.s == -1 then
    self:moveBy(0, 8)
  elseif self.s == 0 then
    self.transform.y = math.min(self.transform.y+8, self.toY)
    if self.transform.y == self.toY then
      if not collision.checkSolid(self) then
        self.s = 1
        self.velocity.vely = 8
      else
        self.s = -1
      end
    end
  elseif self.s == 1 then
    collision.doCollision(self)
    if self.ground then
      self.c = "spawn_land"
      self.s = 2
    end
  elseif self.s == 2 then
    if self.anims["spawn_land"].looped then
      mmSfx.play("start")
      self.c = "idle"
      self.s = 3
    end
  elseif self.s == 3 then
    for i=1, globals.playerCount do
      local player = globals.allPlayers[i]
      if not player.climb and player.velocity.vely > 0 and
        math.between(player.transform.x+player.collisionShape.w/2, self.transform.x, self.transform.x+self.collisionShape.w) and
        player:collision(self) then
        player.canStopJump = false
        player.velocity.vely = -7
        player.step = false
        player.stepTime = 0
        player.ground = false
        player.currentLadder = nil
        player.wallJumping = false
        player.dashJump = false
        if player.slide then
          local lh = self.collisionShape.h
          player:regBox()
          player.transform.y = player.transform.y - (player.collisionShape.h - lh)
          player.slide = false
        end
        self.s = 4
        self.c = "coil"
        self.wpn.energy[self.wpn.currentSlot] = self.wpn.energy[self.wpn.currentSlot] - 7
        break
      end
    end
  elseif self.s == 4 then
    self.timer = math.min(self.timer+1, 40)
    if self.timer == 40 then
      self.s = 5
      self.c = "spawn_land"
      self.anims["spawn_land"]:gotoFrame(1)
      mmSfx.play("ascend")
    end
  elseif self.s == 5 then
    if self.anims["spawn_land"].looped then
      self.s = 6
      self.c = "spawn"
    end
  elseif self.s == 6 then
    self:moveBy(0, -8)
  end
  self:face(self.side)
  if megautils.outside(self) or self.wpn.currentSlot ~= 9 then
    megautils.remove(self, true)
  end
end

function rushCoil:draw()
  love.graphics.setColor(1, 1, 1, 1)
  self.anims[self.c]:draw(self.tex, math.round(self.transform.x-8), math.round(self.transform.y-12))
end

stickWeapon = entity:extend()

function stickWeapon:new(x, y, dir, wpn)
  stickWeapon.super.new(self)
  self.added = function(self)
    self:addToGroup("stickWeapon")
    self:addToGroup("freezable")
    self:addToGroup("removeOnTransition")
  end
  self.transform.y = y
  self.transform.x = x
  self:setRectangleCollision(8, 6)
  self.tex = loader.get("stick_weapon")
  self.dink = false
  self.velocity = velocity()
  self.velocity.velx = dir * 5
  self.side = dir
  self.wpn = wpn
  self:setLayer(1)
  mmSfx.play("buster")
end

function stickWeapon:update(dt)
  if not self.dink then
    self:hurt(self:collisionTable(megautils.groups()["hurtable"]), -8, 1)
  else
    self.velocity.vely = -4
    self.velocity.velx = 4*-self.side
  end
  self:moveBy(self.velocity.velx, self.velocity.vely)
  if megautils.outside(self) or self.wpn.currentSlot ~= 1 then
    megautils.remove(self, true)
  end
end

function stickWeapon:draw()
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.draw(self.tex, math.round(self.transform.x), math.round(self.transform.y))
end