Building = class("Building", PhysicalEntity)

function Building:initialize(playerY, first)
  if first then
    self.type = "tunnel"
    self.width = self:roundSize(1000, 2000)
    self.tunnelHeight = self:roundSize(50, 100)
    self.objY = playerY
    self.x = self.width / 2
  else
    if math.random(1, 5) == 1 then
      self.type = "tunnel"
      self.width = self:roundSize(300, 2500)
      self.tunnelHeight = self:roundSize(40, 150)
      self.objY = playerY + self:roundSize(-love.graphics.height / 3, love.graphics.height / 3)
    else
      self.type = "roof"
      self.width = self:roundSize(100, 1500)
      self.objY = playerY + self:roundSize(-love.graphics.height / 3, love.graphics.height / 3)
    end
    
    self.x = love.graphics.width + 1 + self.width / 2
  end
  
  self.objY = math.clamp(self.objY, love.graphics.height / 8, love.graphics.height * (7/8))
  self.y = self.type == "tunnel" and self.objY or self.objY + (love.graphics.height - self.objY) / 2
  self.gap = math.random(150, 300)
  self.color = { 200, 200, 200 }
  PhysicalEntity.initialize(self)
end

function Building:added()
  self:setupBody()
  
  if self.type == "tunnel" then
    local topHeight = self.objY - self.tunnelHeight / 2
    local btmHeight = love.graphics.height - self.objY - self.tunnelHeight / 2
    self.top = self:addShape(love.physics.newRectangleShape(0, -topHeight / 2, self.width, topHeight))
    self.bottom = self:addShape(love.physics.newRectangleShape(0, btmHeight / 2, self.width, btmHeight))
  elseif self.type == "roof" then
    self.fixture = self:addShape(love.physics.newRectangleShape(self.width, love.graphics.height - self.objY))
  end
end

function Building:update(dt)
  if self.x < -self.width / 2 then
    self.world = nil
  end
end

function Building:draw()
  love.graphics.storeColor()
  love.graphics.setColor(self.color)
  
  if self.type == "tunnel" then
    love.graphics.polygon("fill", self:getWorldPoints(self.top:getShape():getPoints()))
    love.graphics.polygon("fill", self:getWorldPoints(self.bottom:getShape():getPoints()))
  else
    love.graphics.polygon("fill", self:getWorldPoints(self.fixture:getShape():getPoints()))
  end
  
  love.graphics.resetColor()
end
    

function Building:roundSize(size1, size2)
  if size2 ~= nil then
    return math.round(math.random(size1, size2) / TILE_SIZE) * TILE_SIZE
  else
    return math.round(size / TILE_SIZE) * TILE_SIZE
  end
end
