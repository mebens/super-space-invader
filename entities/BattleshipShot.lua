BattleshipShot = class("BattleshipShot", Entity)
BattleshipShot.static.radius = 3

function BattleshipShot:initialize(x, y, angle)
  Entity.initialize(self, x, y)
  self.layer = 3
  self.type = "circle"
  self.angle = angle
  self.radius = BattleshipShot.radius
  self.damage = 40
  self.speed = 200
  self.color = { 255, 200, 0 }
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
