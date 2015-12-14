BattleshipGuns = class("BattleshipGuns", Entity)

function BattleshipGuns:initialize(ship)
  Entity.initialize(self)
  self.layer = 2
  self.ship = ship
end

function BattleshipGuns:draw()
  if self.ship.dead then return end
  love.graphics.setColor(self.ship.gunColor)
  
  for i = 1, 4 do
    local x, y = self.ship:getGunCoords(i)
    self.ship.gunMap:draw(
      x, y,
      math.angle(self.world.player.x, self.world.player.y, x, y) + math.tau / 2,
      2, 2,
      self.ship.gunMap.width / 2, self.ship.gunMap.height / 2
    ) 
  end
end
