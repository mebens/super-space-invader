Running = class("Running", PhysicalWorld)

function Running:initialize()
  PhysicalWorld.initialize(self)
  self.speed = 200
  self.player = Player:new(love.graphics.width / 4, love.graphics.height / 2)
  self:add(self.player)
  self.lastBuilding = Building:new(self.player.y, true)
  self:add(self.lastBuilding)
  self:setGravity(0, 500)
end

function Running:update(dt)
  PhysicalWorld.update(self, dt)
  
  for e in self:iterate() do
    if e ~= self.player then
      e.x = e.x - self.speed * dt
    end
  end
  
  local lb = self.lastBuilding
  
  if lb.x + lb.width / 2 + lb.gap <= love.graphics.width + 1 then
    self.lastBuilding = Building:new(self.player.y)
    self:add(self.lastBuilding)
  end
end
