Background = class("Background", Entity)

function Background:initialize()
  Entity.initialize(self)
  self.layer = 6
  self.far1 = love.graphics.newCanvas(love.graphics.width, love.graphics.height)
  self.far2 = love.graphics.newCanvas(love.graphics.width, love.graphics.height)
  self.mid1 = love.graphics.newCanvas(love.graphics.width, love.graphics.height)
  self.mid2 = love.graphics.newCanvas(love.graphics.width, love.graphics.height)
  self.close1 = love.graphics.newCanvas(love.graphics.width, love.graphics.height)
  self.close2 = love.graphics.newCanvas(love.graphics.width, love.graphics.height)
  self.farRate = 7
  self.midRate = 30
  self.closeRate = 80
  self.farOffset = 0
  self.midOffset = 0
  self.closeOffset = 0
  
  self:drawStars(self.far1)
  self:drawStars(self.far2)
  self:drawStars(self.mid1)
  self:drawStars(self.mid2)
  self:drawStars(self.close1, true)
  self:drawStars(self.close2, true)
end

function Background:newFar()
  self.farOffset = 0
  self.far2 = self.far1
  self.far1 = love.graphics.newCanvas(love.graphics.width, love.graphics.height)
  self:drawStars(self.far1)
end  

function Background:newMid()
  self.midOffset = 0
  self.mid2 = self.mid1
  self.mid1 = love.graphics.newCanvas(love.graphics.width, love.graphics.height)
  self:drawStars(self.mid1)
end

function Background:newClose()
  self.closeOffset = 0
  self.close2 = self.close1
  self.close1 = love.graphics.newCanvas(love.graphics.width, love.graphics.height)
  self:drawStars(self.close1, true)
end

function Background:drawStars(canvas, sparse)
  love.graphics.storeColor() 
  love.graphics.setColor(255, 255, 255)
  
  canvas:renderTo(function()
    local max = sparse and math.random(30, 60) or math.random(50, 200)
    for i = 1, max do
      love.graphics.point(math.random(0, love.graphics.width) + .5, math.random(0, love.graphics.height) + .5)
    end
  end)
end

function Background:update(dt)
  self.farOffset = self.farOffset + self.farRate * dt
  self.midOffset = self.midOffset + self.midRate * dt
  self.closeOffset = self.closeOffset + self.closeRate * dt
  if self.farOffset >= love.graphics.height then self:newFar() end
  if self.midOffset >= love.graphics.height then self:newMid() end
  if self.closeOffset >= love.graphics.height then self:newClose() end
end

function Background:draw()
  love.graphics.draw(self.far1, 0, self.farOffset - love.graphics.height)
  love.graphics.draw(self.far2, 0, self.farOffset)
  love.graphics.draw(self.mid1, 0, self.midOffset - love.graphics.height)
  love.graphics.draw(self.mid2, 0, self.midOffset)
  love.graphics.draw(self.close1, 0, self.closeOffset - love.graphics.height)
  love.graphics.draw(self.close2, 0, self.closeOffset)
end
