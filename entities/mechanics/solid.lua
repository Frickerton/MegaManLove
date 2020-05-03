collision = {}

collision.noSlope = false
collision.maxSlope = 1

function collision.doGrav(self, noSlope)
  noSlope = noSlope or collision.noSlope
  collision.checkGround(self, noSlope)
  if self.grav then self:grav() end
end

function collision.doCollision(self, noSlope)
  noSlope = noSlope or collision.noSlope
  if self.blockCollision then
    collision.generalCollision(self, noSlope)
  else
    self.transform.x = self.transform.x + self.velocity.velx
    self.transform.y = self.transform.y + self.velocity.vely
  end
  collision.entityPlatform(self)
  collision.checkGround(self, noSlope)
end

function collision.getTable(self, dx, dy, noSlope)
  noSlope = noSlope or collision.noSlope
  
  local xs = dx or 0
  local ys = dy or 0
  local solid = {}
  
  local cgrav = self.gravity == 0 and 1 or math.sign(self.gravity or 1)
  
  local all = self.blockCollisionAgainst or megautils.state().system.all
  
  for i=1, #all do
    local v = all[i]
    if (not v.exclusivelySolidFor or table.contains(v.exclusivelySolidFor, self)) and
      (not v.excludeSolidFor or not table.contains(v.excludeSolidFor, self)) and
      (v.isSolid == 1 or v.isSolid == 2) then
      if v.isSolid ~= 2 or ((ys == 0 and 1 or math.sign(ys)) == cgrav and not v:collision(self, 0, cgrav) and v:collision(self, 0, -ys)) then
        solid[#solid+1] = v
      end
    end
  end
  
  local ret = {}
  for i=1, #solid do
    if self:collision(solid[i], xs, ys) then
      ret[#ret+1] = solid[i]
    elseif not noSlope and xs ~= 0 and ys == 0 then
      if #self:collisionTable(solid, xs, math.min(4, math.ceil(math.abs(xs)) * collision.maxSlope)) ~= 0 or
        #self:collisionTable(solid, xs, -math.max(-4, math.ceil(math.abs(xs)) * collision.maxSlope)) ~= 0 then
        ret[#ret+1] = solid[i]
      end
    end
  end
  return ret
end

function collision.checkSolid(self, dx, dy, noSlope)
  noSlope = noSlope or collision.noSlope
  
  local xs = dx or 0
  local ys = dy or 0
  local solid = {}
  
  local cgrav = self.gravity == 0 and 1 or math.sign(self.gravity or 1)
  
  local all = self.blockCollisionAgainst or megautils.state().system.all
  
  for i=1, #all do
    local v = all[i]
    if (not v.exclusivelySolidFor or table.contains(v.exclusivelySolidFor, self)) and
      (not v.excludeSolidFor or not table.contains(v.excludeSolidFor, self)) and
      (v.isSolid == 1 or v.isSolid == 2) then
      if v.isSolid ~= 2 or ((ys == 0 and 1 or math.sign(ys)) == cgrav and not v:collision(self, 0, cgrav) and v:collision(self, 0, -ys)) then
        solid[#solid+1] = v
      end
    end
  end
  
  local ret = true
  if #self:collisionTable(solid, xs, ys) == 0 then
    ret = false
  elseif not noSlope and xs ~= 0 and ys == 0 then
    if #self:collisionTable(solid, xs, math.min(4, math.ceil(math.abs(xs)) * collision.maxSlope)) == 0 or
      #self:collisionTable(solid, xs, -math.max(-4, math.ceil(math.abs(xs)) * collision.maxSlope)) == 0 then
      ret = false
    end
  end
  return ret
end

function collision.entityPlatform(self)
  if self.isSolid ~= 0 and self.collisionShape then
    if self.transform.x ~= self.epX or self.transform.y ~= self.epY then
      local all = megautils.state().system.all
      if self.exclusivelySolidFor then
        all = self.exclusivelySolidFor
      end
      
      local resolid = self.isSolid
      self.isSolid = 0
      local xypre
      
      local epCanCrush = true
      
      local myyspeed = self.transform.y - self.epY
      local myxspeed = self.transform.x - self.epX
      self.transform.x = self.epX
      self.transform.y = self.epY
      
      if myyspeed ~= 0 then
        for i=1, #all do
          local v = all[i]
          if v ~= self and v.blockCollision and v.collisionShape and
            (not self.exclusivelySolidFor or table.contains(self.exclusivelySolidFor, v)) and
            (not self.excludeSolidFor or not table.contains(self.excludeSolidFor, v)) then
            local epDir = math.sign(self.transform.y + (self.collisionShape.h/2) -
              (v.transform.y + (v.collisionShape.h/2)))
            
            if not v:collision(self) then
              local epIsPassenger = v:collision(self, 0, (v.gravity >= 0 and 1 or -1)*(v.ground and 1 or 0))
              local epWillCollide = self:collision(v, 0, myyspeed)
              
              if epIsPassenger or epWillCollide then
                self.transform.y = self.transform.y + myyspeed
                
                xypre = v.transform.y
                if epIsPassenger then
                  v.transform.y = v.transform.y + myyspeed
                end
                
                if resolid == 1 or (resolid == 2 and (epDir*(v.gravity >= 0 and 1 or -1))>0) then
                  if v:collision(self) then
                    v.transform.y = math.round(v.transform.y)
                    v.transform.y = v.transform.y + (epDir*-0.5)
                  end
                  local rpts = math.max(32, math.abs(self.collisionShape.h)*2)
                  for i=0, rpts do
                    if v:collision(self) then
                      v.transform.y = v.transform.y + (epDir*-0.5)
                    else
                      break
                    end
                  end
                end
                xypre = xypre - v.transform.y
                v.transform.y = v.transform.y + xypre
                
                collision.shiftObject(v, 0, -xypre, true)
                
                if resolid == 1 then
                  if epCanCrush and v:collision(self) then
                    for k2, _ in pairs(v.canBeInvincible) do
                      v.canBeInvincible[k2] = false
                    end
                    v.iFrame = v.maxIFrame
                    v:hurt({v}, -99999)
                  end
                end
                
                if v.velocity.vely == 0 and epDir == (v.gravity >= 0 and 1 or -1) then
                  v.ground = true
                  v.onMovingFloor = self
                end
                
                self.transform.y = self.transform.y - myyspeed
              end
            end
          end
        end
      end
      
      self.transform.y = self.transform.y + myyspeed
        
      if myxspeed ~= 0 then
        for i=1, #all do
          local v = all[i]
          local continue = false
          if v ~= self and v.blockCollision and v.collisionShape and v.crushed ~= self and
            (not self.exclusivelySolidFor or table.contains(self.exclusivelySolidFor, v)) and
            (not self.excludeSolidFor or not table.contains(self.excludeSolidFor, v)) then
            if not v:collision(self) then
              local epIsOnPlat = false
              local epDir = math.sign((self.transform.x + (self.collisionShape.w/2)) -
                (v.transform.x + (v.collisionShape.w/2)))
              
              if v:collision(self, 0, (v.gravity >= 0 and 1 or -1)*(v.ground and 1 or 0)) then
                collision.shiftObject(v, myxspeed, 0, true)
                epIsOnPlat = true
                v.onMovingFloor = self
              end
              
              if resolid == 1 then
                self.transform.x = self.transform.x + myxspeed
                
                if not epIsOnPlat and v:collision(self) then
                  xypre = v.transform.x
                  v.transform.x = v.transform.x + (myxspeed + (2 * math.sign(epDir)))
                  local rpts = math.max(32, math.abs(self.collisionShape.w)*2)
                  for i=0, rpts do
                    if v:collision(self) then
                      v.transform.x = v.transform.x + (epDir * -0.5)
                    else
                      break
                    end
                  end
                  
                  xypre = xypre - v.transform.x
                  v.transform.x = v.transform.x + xypre
                  
                  collision.shiftObject(v, -xypre, 0, true)
                  
                  if epCanCrush and v:collision(self) then
                    v.crushed = self
                    v.iFrame = v.maxIFrame
                    v:hurt({v}, -999)
                  end
                end
                
                self.transform.x = self.transform.x - myxspeed
              end
            else
              continue = true
            end
          end
          if not continue then
            epIsOnPlat = false
          end
        end
      end
      
      self.transform.x = self.transform.x + myxspeed
      
      self.isSolid = resolid
      
      self.epX = self.transform.x
      self.epY = self.transform.y
    end
  end
end

function collision.shiftObject(self, dx, dy, checkforcol, ep, noSlope)
  noSlope = noSlope or collision.noSlope
  
  local xsub = self.velocity.velx
  local ysub = self.velocity.vely
  
  self.velocity.velx = dx
  self.velocity.vely = dy
  
  self.epX = self.transform.x
  self.epY = self.transform.y
  
  if checkforcol then
    self.canStandSolid.global = false
    collision.generalCollision(self, noSlope)
    self.canStandSolid.global = true
  else
    self.transform.x = self.transform.x + self.velocity.velx
    self.transform.y = self.transform.y + self.velocity.vely
  end
  
  if ep == nil or ep then
    collision.entityPlatform(self)
  end
  
  self.velocity.velx = xsub
  self.velocity.vely = ysub
end

function collision.checkGround(self, noSlope)
  if not self.ground then self.onMovingFloor = nil self.inStandSolid = nil return end
  
  noSlope = noSlope or collision.noSlope
  
  local solid = {}
  local cgrav = self.gravity == 0 and 1 or math.sign(self.gravity or 1)
  
  local slp = math.ceil(math.abs(self.velocity.velx)) + 1
  
  local all = megautils.state().system.all
  for i=1, #all do
    local v = all[i]
    if v ~= self and v.collisionShape and
      (not self.exclusivelySolidFor or table.contains(self.exclusivelySolidFor, v)) and
      (not self.excludeSolidFor or not table.contains(self.excludeSolidFor, v)) then
      if v.isSolid == 1 or v.isSolid == 2 then
        if not v:collision(self, 0, cgrav) and (v.isSolid ~= 2 or v:collision(self, 0, -cgrav * slp)) then
          solid[#solid+1] = v
        end
      elseif v.isSolid == 3 then
        solid[#solid+1] = v
      end
    end
  end
  if #self:collisionTable(solid) == 0 then
    local i = cgrav
    while math.abs(i) <= slp do
      if #self:collisionTable(solid, 0, i) == 0 then
        self.ground = false
        self.onMovingFloor = nil
        self.inStandSolid = nil
      elseif self.velocity.vely * cgrav >= 0 then
        self.ground = true
        self.transform.y = math.round(self.transform.y+cgrav) + (i - cgrav)
        local dec = 0
        while true do
          local tmp = self:collisionTable(solid)
          if #tmp ~= 0 then
            dec = (cgrav >= 0) and 0 or 1
            for k, v in ipairs(tmp) do
              local nd = v.transform.y - math.floor(v.transform.y)
              if cgrav >= 0 and nd > dec then
                dec = nd
              elseif cgrav < 0 and nd < dec then
                dec = nd
              end
            end
            self.transform.y = self.transform.y - cgrav
          else
            break
          end
        end
        if dec ~= 0 then
          if cgrav >= 0 then
            self.transform.y = self.transform.y + dec
          elseif cgrav < 0 then
            self.transform.y = self.transform.y - (1 - dec)
          end
        end
        break
      end
      if noSlope then
        break
      end
      i = i + cgrav
    end
  end
end

function collision.generalCollision(self, noSlope)
  noSlope = noSlope or collision.noSlope
  
  self.xcoll = 0
  self.ycoll = 0
  
  local xprev = self.transform.x
  local solid = {}
  local stand = {}
  local cgrav = self.gravity == 0 and 1 or math.sign(self.gravity or 1)
  
  local all = megautils.state().system.all
  for i=1, #all do
    local v = all[i]
    if v ~= self and v.collisionShape and (not v.exclusivelySolidFor or table.contains(v.exclusivelySolidFor, self)) and
      (not v.excludeSolidFor or not table.contains(v.excludeSolidFor, self)) then
      if v.isSolid == 1 then
        if not v:collision(self, math.sign(self.velocity.velx), math.sign(self.velocity.vely)) and not table.contains(solid, v) then
          solid[#solid+1] = v
        end
      elseif v.isSolid == 3 then
        stand[#stand+1] = v
      end
    end
  end
  
  if self.velocity.velx ~= 0 then
    local slp = math.ceil(math.abs(self.velocity.velx)) * collision.maxSlope * cgrav
    if not noSlope and slp ~= 0 then
      for i=1, #all do
        local v = all[i]
        if v ~= self and v.collisionShape and not table.contains(solid, v) and
          (not v.exclusivelySolidFor or table.contains(v.exclusivelySolidFor, self)) and
          (not v.excludeSolidFor or not table.contains(v.excludeSolidFor, self)) then
          if v.isSolid == 2 and v:collision(self, -self.velocity.velx, 0) and
            not v:collision(self, -self.velocity.velx, slp) and not v:collision(self, math.sign(self.velocity.velx), math.sign(self.velocity.vely)) then
            solid[#solid+1] = v
          end
        end
      end
    end
      
    self.transform.x = self.transform.x + self.velocity.velx
    
    if #self:collisionTable(solid) ~= 0 then
      self.xcoll = -math.sign(self.velocity.velx)
      self.transform.x = math.round(self.transform.x-self.xcoll)
      
      for ii=0, math.max(32, math.abs(self.velocity.velx) * 4) do
        if #self:collisionTable(solid) ~= 0 then
          self.transform.x = self.transform.x + self.xcoll
        else
          break
        end
      end
      
      self.xcoll = self.velocity.velx
      self.velocity.velx = 0
      
      if not noSlope and self.xcoll ~= 0 and slp ~= 0 then
        local xsl = self.xcoll - (self.transform.x - xprev)
        if math.sign(self.xcoll) == math.sign(xsl) then
          local iii=1
          while iii <= math.ceil(math.abs(xsl)) * collision.maxSlope do
            if #self:collisionTable(solid, xsl, -iii) == 0 then
              self.transform.x = self.transform.x + xsl
              self.transform.y = self.transform.y - iii
              self.velocity.velx = self.xcoll
              self.xcoll = 0
              break
            elseif #self:collisionTable(solid, xsl, iii) == 0 then
              self.transform.x = self.transform.x + xsl
              self.transform.y = self.transform.y + iii
              self.velocity.velx = self.xcoll
              self.xcoll = 0
              break
            end
            iii = iii + 1
          end
        end
      end
    end
  end
  
  if self.velocity.vely ~= 0 then
    if self.velocity.vely * cgrav > 0 then
      for i=1, #all do
        local v = all[i]
        if v ~= self and v.collisionShape and v.isSolid == 2 and
          (not v.exclusivelySolidFor or table.contains(v.exclusivelySolidFor, self)) and
          (not v.excludeSolidFor or not table.contains(v.excludeSolidFor, self)) then
          table.removevaluearray(solid, v)
          if not v:collision(self, math.sign(self.velocity.velx), math.sign(self.velocity.vely)) then
            solid[#solid+1] = v
          end
        end
      end
    end
    
    self.transform.y = self.transform.y + self.velocity.vely
    
    if #self:collisionTable(solid) ~= 0 then
      self.ycoll = -math.sign(self.velocity.vely)
      self.transform.y = math.round(self.transform.y-self.ycoll)
      
      for i=0, math.max(32, math.abs(self.velocity.vely) * 4) do
        if #self:collisionTable(solid) ~= 0 then
          self.transform.y = self.transform.y + self.ycoll
        else
          break
        end
      end
      
      self.ycoll = self.velocity.vely
      if self.velocity.vely * cgrav > 0 then
        self.ground = true
      end
      
      self.velocity.vely = 0
    end
  end
  
  if self:checkFalse(self.canStandSolid) then
    local ss = self:collisionTable(stand, 0, cgrav)
    if #ss ~= 0 then
      if self.velocity.vely * cgrav > 0 then
        self.ground = true
        self.ycoll = self.velocity.vely
        self.velocity.vely = 0
      end
      self.inStandSolid = ss[1]
    end
  end
end

solid = basicEntity:extend()

addobjects.register("solid", function(v)
  megautils.add(solid, v.x, v.y, v.width, v.height)
end)

function solid:new(x, y, w, h)
  solid.super.new(self)
  self.transform.y = y
  self.transform.x = x
  self:setRectangleCollision(w, h)
  self.isSolid = 1
  self.added = function(self)
    self:addToGroup("despawnable")
    self:makeStatic()
  end
end

sinkIn = basicEntity:extend()

addobjects.register("sinkIn", function(v)
  megautils.add(sinkIn, v.x, v.y, v.width, v.height, v.properties.speed)
end)

function sinkIn:new(x, y, w, h, s)
  sinkIn.super.new(self)
  self.transform.y = y
  self.transform.x = x
  self:setRectangleCollision(w, h)
  self.sink = s or 0.125
  self.isSolid = 3
  self.added = function(self)
    self:addToGroup("despawnable")
    self:addToGroup("freezable")
  end
end

function sinkIn:update(dt)
  for i=1, #globals.allPlayers do
    local p = globals.allPlayers[i]
    if p:collision(self, 0, (p.gravity >= 0 and 1 or -1)) or p:collision(self) then
      collision.shiftObject(p, 0, self.sink * (p.gravity >= 0 and 1 or -1), true)
    end
  end
end

slope = basicEntity:extend()

addobjects.register("slope", function(v)
  megautils.add(slope, v.x, v.y, megautils.getResource(v.properties.mask))
end)

function slope:new(x, y, mask)
  slope.super.new(self)
  self.transform.x = x
  self.transform.y = y
  self:setImageCollision(mask)
  self.isSolid = 1
  self.added = function(self)
    self:addToGroup("despawnable")
    self:makeStatic()
  end
end

addobjects.register("oneway", function(v)
  megautils.add(solid, v.x, v.y, v.width, v.height).isSolid = 2
end)