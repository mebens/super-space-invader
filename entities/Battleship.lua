Battleship = class("Battleship", Enemy)
Battleship.static.width = 50
Battleship.static.height = 100

function Battleship:initialize(x, health)
  Enemy.initialize(self, x)
  self.layer = 4  
  self.width = Battleship.width
  self.height = Battleship.height
  self.image = assets.images.battleship
  self.gunMap = Spritemap:new(assets.images.battleshipGun, 21, 4)
  self.gunMap:add("fire", { 3, 5, 4, 3, 2, 1 }, 20, false)
  
  self.maxHealth = health or 3000
  self.health = self.maxHealth
  self.ySpeed = 100
  self.contactDamage = 300
  self.shakeAmount = 8
  self.shakeTime = 0.8
  self.explosionSize = "large"
  self.factor = 12
  self.score = 200
  
  self.gunOffsetX = 10
  self.gunOffsetY1 = 5
  self.gunOffsetY2 = -20
  
  self.shootInterval = 0.5
  self.shootTimer = self.shootInterval
  self.color = { 220, 220, 220 }
  self.gunColor = { 100, 100, 100 }
  
  self.healthBarWidth = 100
  
  self.drifting = false
  self.driftRange = love.graphics.width / 2 - Enemy.padX - self.width / 2
  self.driftSpeed = 20
  self.driftDir = 1
  self.driftTimer = 0
end

function Battleship:added()
  Enemy.added(self)
  self.guns = BattleshipGuns:new(self)
  self.world:add(self.guns)
end

function Battleship:removed()
  Enemy.removed(self)
  self.world:remove(self.guns)
end

function Battleship:update(dt)
  Enemy.update(self, dt)
  if self.dead then return end
  self.gunMap:update(dt)
  
  if self.y >= love.graphics.height / 2 then
    self.ySpeed = 0
    self.drifting = true
  end
  
  if self.drifting then
    self.x = self.x + self.driftSpeed * self.driftDir * dt
    self.shape:moveTo(self.x, self.y)
    
    if self.x <= love.graphics.width / 2 - self.driftRange then
      self.driftDir = 1
    elseif self.x >= love.graphics.width / 2 + self.driftRange then
      self.driftDir = -1
    end
    
    if self.driftTimer > 0 then
      self.driftTimer = self.driftTimer - dt
    else
      self.driftDir = 1 - 2 * math.random(0, 1)
      self.driftTimer = math.random(30, 250) / 10
    end
  end
  
  if self.shootTimer > 0 then
    self.shootTimer = self.shootTimer - dt
  else
    self.shootTimer = self.shootInterval
    self:shoot()
  end
  
  if self.health < self.maxHealth / 3 then
    self.shootInterval = 0.3
  end
end

function Battleship:draw()
  Enemy.draw(self)
  if self.dead then return end
  love.graphics.setColor(255, 255, 255, 100)
  local y = self.y - self.height / 2 - 10
  love.graphics.line(self.x - self.healthBarWidth / 2, y, self.x + self.healthBarWidth / 2, y)
  
  love.graphics.setColor(255, 50, 0, 255)
  love.graphics.line(
    self.x - self.healthBarWidth / 2, y,
    self.x - self.healthBarWidth / 2 + self.healthBarWidth * (self.health / self.maxHealth), y
  )
end

function Battleship:shoot(index)
  self.gunMap:play("fire")
  playRandom{"cannon-shot1", "cannon-shot2", "cannon-shot3"}
  
  for i = 1, 4 do
    local x, y = self:getGunCoords(i)
    self.world:add(BattleshipShot:new(x, y, math.angle(self.world.player.x, self.world.player.y, x, y) + math.tau / 2))
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
