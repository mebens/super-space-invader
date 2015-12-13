BattleshipShot = class("BattleshipShot", Entity)
BattleshipShot.static.radius = 5

function BattleshipShot:initialize(x, y, angle)
  Entity.initialize(self, x, y)
  self.layer = 4
  self.type = "circle"
  self.angle = angle
  self.damage = 40
  self.speed = 300
  self.color = { 220, 120, 0 }
end

function BattleshipShot:added()
  self.shape = HC.circle(self.x, self.y, self.radius)
end

function BattleshipShot:removed()
  HC.remove(self.shape)
end

function BattleshipShot:update(dt)
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

function BattleshipShot:draw()
  love.graphics.storeColor()
  love.graphics.setColor(self.color)
  love.graphics.circle("fill", self.x, self.y, self.radius)
  love.graphics.resetColor()
end

function BattleshipShot:die()
  self.world = nil
end
