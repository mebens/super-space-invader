RageBuffer = class("RageBuffer", Entity)

function RageBuffer:initialize()
  self.layer = 5
  self.canvas = love.graphics.newCanvas(love.graphics.width, love.graphics.height)
  self.rate = 255
end

function RageBuffer:update(dt)
  self.canvas:renderTo(function() 
    love.graphics.setColor(0, 0, 0, self.rate * dt)
    love.graphics.rectangle("fill", 0, 0, love.graphics.width, love.graphics.height)
  end)
end

function RageBuffer:draw()
  love.graphics.draw(self.canvas, 0, 0)
end

function RageBuffer:drawTo(enemy, alpha)
  local oldAlpha
  
  if enemy.color then
    oldAlpha = enemy.color[4]
    enemy.color[4] = alpha or 150
  end
  
  self.canvas:renderTo(function() 
    if not enemy.color then love.graphics.setColor(255, 255, 255, alpha) end
    enemy:draw()
  end)
  
  if enemy.color then enemy.color[4] = oldAlpha end
end
