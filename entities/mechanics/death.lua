death = basicEntity:extend()

addobjects.register("death", function(v)
  megautils.add(death, v.x, v.y, v.width, v.height, v.properties["harm"])
end)

function death:new(x, y, w, h, harm)
  death.super.new(self, true)
  self.transform.y = y
  self.transform.x = x
  self:setRectangleCollision(w, h)
  self:setLayer(-5)
  self.harm = harm or -99
  self.harm = -math.abs(self.harm)
  self.isSolid = 1
  self.added = function(self)
    self:addToGroup("despawnable")
    self:addToGroup("death")
  end
end