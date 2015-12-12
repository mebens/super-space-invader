Anchor = class("Anchor", Entity)

function Anchor:initialize(x, y, radius, ySpeed, xSpeed)
  Entity.initialize(self, x, y)
  self.originalY = y
  self.radius = radius
  self.ySpeed = ySpeed
  self.xSpeed = xSpeed or 0
  self.xDir = 1
  self.enemies = 0
end

function Anchor:update(dt)
  if self.enemies == 0 then self.world = nil end
  
  self.y = self.y + self.ySpeed * dt
  
  if self.y > love.graphics.height + self.radius + 50 then
    self.y = self.originalY
  end
  
  if self.xSpeed > 0 then
    self.x = self.x + self.xSpeed * self.xDir * dt
    self.x = math.clamp(self.x, self.padX + self.width / 2, love.graphics.width - self.padX - self.width / 2)
    
    if self.x == self.padX + self.width / 2 then
      self.xDir = 1
    elseif self.x == love.graphics.width - self.padX - self.width / 2 then
      self.xDir = -1
    end
  end
end
