Battleship = class("Battleship", Enemy)
Battleship.static.width = 50
Battleship.static.height = 100

function Battleship:initialize(x)
  Enemy.initialize(self, x)
  self.width = Battleship.width
  self.height = Battleship.height
  self.image = assets.images.battleship
  self.gunMap = Spritemap:new(assets.images.battleshipGun, 21, 5)
  self.gunMap:add("fire", { 3, 5, 4, 3, 2, 1 }, 20, false)
  
  self.health = 1500
  self.ySpeed = 50
  self.contactDamage = 300
  self.shakeAmount = 8
  self.shakeTime = 0.6
  self.explosionSize = "large"
  self.factor = 14
  self.score = 200
  
  self.gunOffsetX = 5
  self.gunOffsetY1 = 0
  self.gunOffsetY2 = -9
  
  self.shootInterval = 2
  self.shootTimer = self.shootInterval
end

function Battleship:update(dt)
  Enemy.update(self, dt)
  if self.dead then return end
  if self.y >= love.graphics.height / 2 then self.ySpeed = 0 end
  
  if self.shootTimer > 0 then
    self.shootTimer = self.shootTimer - dt
  else
    self.shootTimer = self.shootInterval
    self:shoot()
  end
end

function Battleship:draw()
  Enemy.draw(self)
  
  for i = 1, 4 do
    local x, y = self:getGunCoords(i)
    self.gunMap:draw(
      x, y,
      math.angle(self.world.player.x, self.world.player.y, x, y),
      2, 2,
      self.gunMap.width / 4, self.gunMap.height / 4
    ) 
  end
end

function Battleship:shoot()
  self.gunMap:play("fire")
  playRandom{"cannon-shot1", "cannon-shot2", "cannon-shot3"}
  
  for i = 1, 4 do
    local x, y = self:getGunCoords(i)
    self.world:add(BattleshipShot:new(x, y, math.angle(self.world.player.x, self.world.player.y, x, y)))
  end
end

function Battleship:getGunCoords(gun)
  if gun == 1 then
    return self.x - self.gunOffsetX, self.y + self.gunOffsetY1
  elseif gun == 2 then
    return self.x + self.gunOffsetX, self.y + self.gunOffsetY1
  elseif gun == 3 then
    return self.x - self.gunOffsetX, self.y + self.gunOffsetY2
  elseif gun == 4 then
    return self.x + self.gunOffsetX, self.y + self.gunOffsetY2
  end
end

function Battleship:getGunAngle(gun)
  return math.angle(self.world.player.x, self.world.player.y, self:getGunCoords(gun))
end
