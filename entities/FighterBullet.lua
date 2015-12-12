FighterBullet = class("FighterBullet", Entity)

function FighterBullet:initialize(x, y, angle)
  Entity.initialize(self, x, y)
  self.angle = angle
  self.layer = 4
  self.width = 1
  self.height = 10
  self.speed = 300
  self.damage = 40
  self.color = { 200, 200, 200 }
end

function FighterBullet:added()
  self.shape = HC.rectangle(self.x - self.width / 2, self.y - self.height / 2, self.width, self.height)
  self.shape:setRotation(self.angle + math.tau / 4)
end

function FighterBullet:removed()
  HC.remove(self.shape)
end

function FighterBullet:update(dt)
  self.x = self.x + math.cos(self.angle) * self.speed * dt
  self.y = self.y + math.sin(self.angle) * self.speed * dt
  self.shape:moveTo(self.x, self.y)
   
  if self.y < -self.height or self.y > love.graphics.height + self.height
    or self.x < -self.width or self.x > love.graphics.width + self.width
  then
    self.world = nil
  end
  
  if self.shape:collidesWith(self.world.player.shape) then
    self.world.player:damage(self.damage)
    self:die()
  end
end

function FighterBullet:draw()
  love.graphics.storeColor()
  love.graphics.setColor(self.color)
  self.shape:draw()
  --love.graphics.rectangle("fill", self.x - self.width / 2, self.y - self.height / 2, self.width, self.height)
  love.graphics.resetColor()
end

function FighterBullet:die()
  self.world = nil
end
