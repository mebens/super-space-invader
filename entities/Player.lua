Player = class("Player", Entity)
Player.static.attackUpgrades = {
  { "Two Guns", "Double the trouble" },
  { "Faster Firerate", "30% more dak dak" },
  { "Faster Bullets", "50% more muzzle velocity" },
  { "Three Guns", "You can taste the freedom" },
  { "Homing Missiles", "In case bullets weren't enough" }
}

Player.static.defenceUpgrades = {
  { "+50 Health", "Give the ship a beer gut" },
  { "Faster Regen", "50% more limb regrowth" },
  { "Less Regen Delay", "40% less sick days" },
  { "Shield", "Toggle by pressing left and right together" },
  { "Shield Stamina", "It'll take an extra knock or two" },
  { "Shield Explosion", "The shield will take some fools with it when it blows" }
}

function Player:initialize()
  Entity.initialize(self)
  self.layer = 3
  self.width = 30
  self.height = 25
  self.padX = 5
  self.padY = 15
  
  self.x = love.graphics.width / 2
  self.y = love.graphics.height - self.height / 2 - self.padY
  self.maxSpeed = 300
  self.accel = 1500
  self.reverseAccel = 5000
  self.speed = 0
  
  self.guns = 1
  self.gunType = "bullet"
  self.shootInterval = 0.25
  self.shootTimer = self.shootInterval
  self.bulletSpeed = 400
  self.missiles = false
  self.missileTime = 2
  self.missileInterval = 0
  
  self.maxHealth = 100
  self.health = self.maxHealth
  self.regenRate = 10
  self.regenTime = 7
  self.regenTimer = 0
  
  self.shieldAllowed = false
  self.shieldEnabled = false
  self.shieldRegenTime = 10
  self.shieldRegenTimer = 0
  self.shieldMaxHealth = 50
  self.shieldHealth = self.shieldMaxHealth
  self.shieldExplosion = false
  self.shieldExplosionRange = 50
  
  self.attackLvl = 0
  self.defenceLvl = 0
  self.color = { 220, 0, 0 }
end

function Player:added()
  self.shape = HC.rectangle(self.x - self.width / 2, self.y - self.height / 2, self.width, self.height)
end

function Player:removed()
  HC.remove(self.shape)
end

function Player:update(dt)
  if self.dead then return end
  local axis = input.axisDown("left", "right")
  
  if axis ~= 0 then
    local accel = self.accel
    
    if self.speed ~= 0 and axis ~= math.sign(self.speed) then
      accel = self.reverseAccel
    end
    
    self.speed = self.speed + accel * axis * dt
    
    if math.abs(self.speed) > self.maxSpeed then
      self.speed = self.maxSpeed * math.sign(self.speed)
    end
  elseif self.speed ~= 0 then
    local amount = self.accel * dt
    
    if amount > math.abs(self.speed) then
      self.speed = 0
    else
      self.speed = self.speed + amount * (-math.sign(self.speed))
    end
  end

  if self.speed ~= 0 then
    self.x = self.x + self.speed * dt
    self.x = math.clamp(self.x, self.width / 2 + self.padX, love.graphics.width - self.width / 2 - self.padX)
    self.shape:moveTo(self.x, self.y)
  end
  
  if self.regenTimer > 0 then
    self.regenTimer = self.regenTimer - dt
  elseif self.health < self.maxHealth then
    self.health = math.min(self.health + self.regenRate * dt, self.maxHealth)
  end
  
  if self.world.inWave then
    if self.shootTimer <= 0 then
      self:shoot()
      self.shootTimer = self.shootInterval
    else
      self.shootTimer = self.shootTimer - dt
    end
    
    if self.missiles then
      if self.missileTimer <= 0 then
        self:fireMissile()
        self.missileTimer = self.missileInterval
      else
        self.missileTimer = self.missileTimer - dt
      end
    end
  end
end

function Player:draw()
  love.graphics.storeColor()
  love.graphics.setColor(self.color)
  love.graphics.rectangle("fill", self.x - self.width / 2, self.y - self.height / 2, self.width, self.height)
  love.graphics.resetColor()
end

function Player:shoot()
  if self.guns == 1 or self.guns == 3 then
    self.world:add(Bullet:new(self.x, self.y, self.bulletSpeed))
  end
  
  if self.guns == 2 or self.guns == 3 then
    self.world:add(Bullet:new(self.x + self.width / 2, self.y))
    self.world:add(Bullet:new(self.x - self.width / 2, self.y))
  end
end

function Player:fireMissile()
  self.world:add(Missile:new(self.x + self.width / 2, self.y))
  self.world:add(Missile:new(self.x - self.width / 2, self.y))
end

function Player:damage(amount)
  if self.dead then return end
  self.health = self.health - amount
  self.regenTimer = self.regenTime
  self.world.hud:takenDamage()
  if self.health <= 0 then self:die() end
end

function Player:applyLevels(attack, defence)
  if attack then self.attackLvl = attack end
  if defence then self.defenceLvl = defence end
  
  if self.attackLvl >= 1 then self.guns = 2 end
  if self.attackLvl >= 2 then self.shootInterval = 0.175 end
  if self.attackLvl >= 3 then self.bulletSpeed = 600 end
  if self.attackLvl >= 4 then self.guns = 3 end
  if self.attackLvl >= 5 then self.gunType = "laser" end
  
  if self.defenceLvl >= 1 then
    self.maxHealth = 150
    self.health = self.maxHealth
  end
  
  if self.defenceLvl >= 2 then self.regenRate = 15 end
  if self.defenceLvl >= 3 then self.regenTime = 4 end
  if self.defenceLvl >= 4 then self.shieldEnabled = true end
  
  if self.defenceLvl >= 5 then
    self.shieldMaxHealth = 100
    self.shieldHealth = self.shieldMaxHealth
  end
  
  if self.defenceLvl >= 6 then self.shieldExplosion = true end
end

function Player:reset()
  self.dead = false
  self.health = self.maxHealth
end

function Player:die()
  if not self.world.inWave then return end
  self.dead = true
  -- bad shit here
end
