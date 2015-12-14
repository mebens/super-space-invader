Anchor = class("Anchor", Entity)

function Anchor:initialize(x, y, radius, ySpeed, xSpeed)
  Entity.initialize(self, x, y)
  self.originalY = y
  self.radius = radius
  self.ySpeed = ySpeed or 100
  self.xSpeed = xSpeed or 0
  self.xDir = 1
  self.enemies = 0
end

function Anchor:removed()
  if self.anchor then self.anchor.enemies = self.anchor.enemies - 1 end
end

function Anchor:update(dt)
  if self.enemies == 0 then self.world = nil end
  
  if self.anchor then
    self.anchorAngle = (self.anchorAngle + self.ySpeed * dt) % math.tau
    self.x = self.anchor.x + math.cos(self.anchorAngle) * self.anchor.radius
    self.y = self.anchor.y + math.sin(self.anchorAngle) * self.anchor.radius
  else
    self.y = self.y + self.ySpeed * dt
    
    if self.y > love.graphics.height + self.radius + 50 then
      self.y = self.originalY
    end
    
    if self.xSpeed > 0 then
      self.x = self.x + self.xSpeed * self.xDir * dt
      self.x = math.clamp(self.x, Enemy.padX + self.radius, love.graphics.width - Enemy.padX - self.radius)
      
      if self.x <= Enemy.padX + self.radius then
        self.xDir = 1
      elseif self.x >= love.graphics.width - Enemy.padX - self.radius then
        self.xDir = -1
      end
    end
  end
end

function Anchor:setAnchor(anchor, angle, speed)
  self.anchor = anchor
  self.anchorAngle = angle or 0
  anchor.enemies = anchor.enemies + 1
  if speed then self.ySpeed = speed end
end
