Bullet = class("Bullet", Entity)
Bullet.static.all = LinkedList:new("_nextBullet", "_prevBullet")

function Bullet:initialize(x, y, speed)
  Entity.initialize(self, x, y)
  self.layer = 4
  self.width = 1
  self.height = 10
  self.speed = speed or 400
  self.damage = 50
  self.color = { 200, 200, 200 }
end

function Bullet:added()
  Bullet.all:push(self)
  self.shape = HC.rectangle(self.x - self.width / 2, self.y - self.height / 2, self.width, self.height)
end

function Bullet:removed()
  Bullet.all:remove(self)
  HC.remove(self.shape)
end

function Bullet:update(dt)
  self.y = self.y - self.speed * dt
  self.shape:moveTo(self.x, self.y)
  if self.y < -self.height / 2 then self.world = nil end
  -- check for collision with enemies
end

function Bullet:draw()
  love.graphics.storeColor()
  love.graphics.setColor(self.color)
  self.shape:draw()
  love.graphics.resetColor()
end

function Bullet:die()
  self.world = nil
end
