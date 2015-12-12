CannonShot = class("CannonShot", Entity)
CannonShot.static.radius = 3

function CannonShot:initialize(x, y, angle)
  Entity.initialize(self, x, y)
  self.type = "circle"
  self.layer = 4
  self.radius = CannonShot.radius
  self.angle = angle
  self.damage = 40
  self.speed = 600
  self.minSpeed = 100
  self.decel = 1500
  self.color = { 200, 200, 0 }
end

function CannonShot:added()
  self.shape = HC.circle(self.x, self.y, self.radius)
end

function CannonShot:removed()
  HC.remove(self.shape)
end

function CannonShot:update(dt)
  if self.speed > self.minSpeed then
    self.speed = self.speed - self.decel * dt
  end
  
  self.x = self.x + self.speed * math.cos(self.angle) * dt
  self.y = self.y + self.speed * math.sin(self.angle) * dt
  self.shape:moveTo(self.x, self.y)
  
  if self.y < -self.radius * 2 or self.y > love.graphics.height + self.radius * 2
    or self.x < -self.radius * 2 or self.x > love.graphics.width + self.radius * 2
  then
    self.world = nil
  end
  
  if self.shape:collidesWith(self.world.player.shape) then
    self.world.player:damage(self.damage)
    self:die()
  end
end

function CannonShot:draw()
  love.graphics.storeColor()
  love.graphics.setColor(self.color)
  love.graphics.circle("fill", self.x, self.y, self.radius)
  love.graphics.resetColor()
end

function CannonShot:die()
  self.world = nil
end
