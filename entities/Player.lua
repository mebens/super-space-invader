Player = class("Player", Entity)
Player.static.attackUpgrades = {
  { "Two Guns", "Double the trouble" },
  { "Faster Firerate", "50% more bullets" },
  { "Homing Missiles", "In case bullets weren't enough" },
  { "Faster Bullets", "Double the muzzle velocity" },
  { "More Missiles", "50% faster firerate" },
  { "Three Guns", "You can taste the freedom" }
}

Player.static.defenceUpgrades = {
  { "Double Health", "Give the ship a beer gut" },
  { "Shield", "Toggle by pressing left and right together" },
  { "Less Regen Delay", "40% less dicking around" },
  { "Faster Regen", "50% less sick days" },
  { "Health and Shield", "+100 shield health\n+50 health" },
  { "Shield Regen", "50% less time in the open" },
  { "Shield Explosion", "The shield will take some fools with it when it blows" }
}

Player.static.jetParticle = love.graphics.newCanvas(3, 3)
Player.jetParticle:renderTo(function()
  love.graphics.setColor(255, 255, 255, 150)
  love.graphics.rectangle("fill", 0, 0, 3, 3)
  love.graphics.setColor(255, 255, 255, 255)
  love.graphics.point(1, 1)
end)

function Player:initialize()
  Entity.initialize(self)
  self.layer = 3
  self.width = 30
  self.height = 20
  self.scale = 1
  self.padX = 5
  self.padY = 15
  self.map = Spritemap:new(assets.images.player, 15, 10)
  self.gunMap = Spritemap:new(assets.images.gun, 3, 5)
  self.gunMap:add("fire", { 2, 3, 1 }, 15, false)
  self.shieldImg = assets.images.shield
  
  self.x = love.graphics.width / 2
  self.y = love.graphics.height - self.height / 2 - self.padY
  self.speed = 0
  
  self.midGunOffsetX = 0
  self.midGunOffsetY = -8
  self.sideGunOffsetX = self.width / 2 - 4
  self.sideGunOffsetY = -1
  self.shieldOffsetY = -self.height / 2 - 3
  
  self.attackLvl = 0
  self.defenceLvl = 0
  self.color = { 220, 220, 220 }
  self.gunColor = { 220, 0, 0 }
  self.shieldColor = { 0, 166, 255 }
  
  self:settingDefaults()
  
  for i = 1, 2 do
    local ps = love.graphics.newParticleSystem(Player.jetParticle, 40)
    ps:setDirection(math.tau / 4)
    ps:setSpread(math.tau / 8)
    ps:setSpeed(100, 150)
    ps:setParticleLifetime(0.15, 0.2)
    ps:setEmitterLifetime(-1)
    ps:setEmissionRate(80)
    ps:setColors(157, 0, 255, 255, 255, 60, 0, 255, 255, 0, 0, 255)
    ps:setRelativeRotation(true)
    ps:start()
    self["jetPS" .. i] = ps
  end
  
  self.engine = playSound("player-engine")
  self.engine:setLooping(true)
end

function Player:settingDefaults()
  self.maxSpeed = 300
  self.accel = 1500
  self.reverseAccel = 5000
  
  self.guns = 1
  self.gunType = "bullet"
  self.shootInterval = 0.25
  self.shootTimer = self.shootInterval
  self.bulletSpeed = 400
  self.missiles = false
  self.missileInterval = 5
  self.missileTimer = 0
  
  self.maxHealth = 100
  self.health = self.maxHealth
  self.regenRate = 10
  self.regenTime = 5
  self.regenTimer = 0
  
  self.shieldAllowed = false
  self.shieldEnabled = false
  self.shieldRegenTime = 10
  self.shieldRegenTimer = 0
  self.shieldMaxHealth = 150
  self.shieldHealth = self.shieldMaxHealth
  self.shieldExplosion = false
  self.shieldExplosionRange = 150
  
  self.shieldSound = playSound("shield-running")
  self.shieldSound:stop()
  self.shieldSound:setLooping(true)
end

function Player:added()
  self.shape = HC.rectangle(self.x - self.width / 2, self.y - self.height / 2, self.width, self.height)
end

function Player:removed()
  HC.remove(self.shape)
end

function Player:update(dt)
  self.jetPS1:update(dt)
  self.jetPS2:update(dt)
  
  if self.dead then
    self.deathPS:update(dt)
    return
  end
  
  local axis = input.axisDown("left", "right")
  
  -- accel/decel
  if axis ~= 0 then
    local accel = self.accel
    
    if self.speed ~= 0 and axis ~= math.sign(self.speed) then
      accel = self.reverseAccel
    end
    
    self.speed = self.speed + accel * axis * dt
    
    if math.abs(self.speed) > self.maxSpeed then
      self.speed = self.maxSpeed * math.sign(self.speed)
    end
    
    if axis == -1 then self.map.frame = 2 end
    if axis == 1 then self.map.frame = 3 end
  elseif self.speed ~= 0 then
    self.map.frame = 1
    local amount = self.accel * dt
    
    if amount > math.abs(self.speed) then
      self.speed = 0
    else
      self.speed = self.speed + amount * (-math.sign(self.speed))
    end
  end

  -- movement
  if self.speed ~= 0 then
    self.x = self.x + self.speed * dt
    self.x = math.clamp(self.x, self.width / 2 + self.padX, love.graphics.width - self.width / 2 - self.padX)
    self.shape:moveTo(self.x, self.y)
  end
  
  -- health regen
  if self.regenTimer > 0 then
    self.regenTimer = self.regenTimer - dt
  elseif self.health < self.maxHealth then
    self.health = math.min(self.health + self.regenRate * dt, self.maxHealth)
  end

  self.gunMap:update(dt)
  
  -- shooting
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
  
  -- shield
  if self.shieldAllowed then
    local activated = (input.down("left") and input.pressed("right")) or (input.pressed("left") and input.down("right"))
    
    if self.shieldRegenTimer > 0 then
      self.shieldRegenTimer = self.shieldRegenTimer - dt
      if self.shieldRegenTimer <= 0 and self.world.inWave then playSound("voice-shield-ready") end
    elseif activated then
      self.shieldEnabled = not self.shieldEnabled
      
      if self.shieldEnabled then
        self.shieldPS:start()
        self.shieldSound:play()
      end
    end
    
    if not self.shieldEnabled then
      if self.shieldPS then self.shieldPS:stop() end
      self.shieldSound:stop()
    end
  end
  
  if self.shieldPS then
    self.shieldPS:moveTo(self.x, self.y + self.shieldOffsetY)
    self.shieldPS:update(dt)
  elseif self.shieldAllowed then
    self.shieldPS = love.graphics.newParticleSystem(Enemy.rageParticle, 300)
    self:shieldSparkMode("idle")
    self.shieldPS:setEmitterLifetime(-1)
    self.shieldPS:setEmissionRate(35)
    self.shieldPS:setAreaSpread("normal", self.width / 3, 0)
    self.shieldPS:setRelativeRotation(true)
    local r, g, b = unpack(self.shieldColor)
    self.shieldPS:setColors(r, g, b, 255, r, g, b, 50)
    self.shieldPS:stop()
  end
end

function Player:draw()
  love.graphics.draw(self.jetPS1, self.x - 5.5, self.y + self.height / 2 - 3)
  love.graphics.draw(self.jetPS2, self.x + 3.5, self.y + self.height / 2 - 3)
  
  if self.dead then
    love.graphics.draw(self.deathPS)
    return
  end
  
  if self.guns == 1 or self.guns == 3 then
    self:drawMap(self.gunMap, self.x + self.midGunOffsetX, self.y + self.midGunOffsetY, self.gunColor)
  end
  
  if self.guns == 2 or self.guns == 3 then
    self:drawMap(self.gunMap, self.x - self.sideGunOffsetX, self.y + self.sideGunOffsetY, self.gunColor)
    self:drawMap(self.gunMap, self.x + self.sideGunOffsetX, self.y + self.sideGunOffsetY, self.gunColor)
  end
  
  self:drawMap()
  
  if self.shieldEnabled then
    self:drawImage(self.shieldImg, self.x, self.y + self.shieldOffsetY, self.shieldColor)
  end
  
  if self.shieldPS then love.graphics.draw(self.shieldPS) end
  -- love.graphics.setColor(self.color)
  -- love.graphics.rectangle("fill", self.x - self.width / 2, self.y - self.height / 2, self.width, self.height)
end

function Player:shoot()
  self.gunMap:play("fire")
  playRandom{"shoot1", "shoot2", "shoot3", "shoot4", "shoot5"}
  
  if self.guns == 1 or self.guns == 3 then
    self.world:add(Bullet:new(self.x + self.midGunOffsetX, self.y + self.midGunOffsetY, self.bulletSpeed))
  end
  
  if self.guns == 2 or self.guns == 3 then
    self.world:add(Bullet:new(self.x - self.sideGunOffsetX, self.y + self.sideGunOffsetY, self.bulletSpeed))
    self.world:add(Bullet:new(self.x + self.sideGunOffsetX, self.y + self.sideGunOffsetY, self.bulletSpeed))
  end
end

function Player:fireMissile()
  self.world:add(Missile:new(self.x + self.width / 2, self.y))
  self.world:add(Missile:new(self.x - self.width / 2, self.y))
end

function Player:damage(amount)
  if self.dead then return end
  
  if self.shieldEnabled then
    self.shieldHealth = self.shieldHealth - amount
    self:shieldSparkMode("hit")
    self.shieldPS:emit(amount)
    self:shieldSparkMode("idle")
    playRandom{"shield-hit1", "shield-hit2"}
    
    if self.shieldHealth <= 0 then
      self.shieldEnabled = false
      self.shieldRegenTimer = self.shieldRegenTime
      self.shieldHealth = self.shieldMaxHealth
      self.shieldSound:stop()
      playSound("voice-shield-broken")
      if self.shieldExplosion then self:explodeShield() end
    end
  else
    self.health = self.health - amount
    self.regenTimer = self.regenTime
    self.world.hud:takenDamage()
    
    if self.health <= 0 then
      self:die()
    else
      playRandom{"hit1", "hit2", "hit3"}
    end
  end
  
  if not self.dead then
    self.world:shake(amount > 40 and 2 or 1, 0.05)
  end
end

function Player:applyLevels(attack, defence)
  if attack then self.attackLvl = attack end
  if defence then self.defenceLvl = defence end
  self:settingDefaults()
  
  if self.attackLvl >= 1 then self.guns = 2 end
  if self.attackLvl >= 2 then self.shootInterval = 0.125 end
  if self.attackLvl >= 3 then self.missiles = true end
  if self.attackLvl >= 4 then self.bulletSpeed = 800 end
  if self.attackLvl >= 5 then self.missileInterval = 2.5 end
  if self.attackLvl >= 6 then self.guns = 3 end
  
  if self.defenceLvl >= 1 then
    self.maxHealth = 200
    self.health = self.maxHealth
  end
  
  if self.defenceLvl >= 2 then self.shieldAllowed = true end
  if self.defenceLvl >= 3 then self.regenTime = 3 end
  if self.defenceLvl >= 4 then self.regenRate = 25 end
  
  if self.defenceLvl >= 5 then
    self.shieldMaxHealth = 250
    self.shieldHealth = self.shieldMaxHealth
    self.maxHealth = 250
    self.health = self.maxHealth
  end
  
  if self.defenceLvl >= 6 then self.shieldRegenTime = 5 end
  if self.defenceLvl >= 7 then self.shieldExplosion = true end
end

function Player:reset()
  self.dead = false
  self.health = self.maxHealth
  self.shieldRegenTimer = 0
  self.jetPS1:start()
  self.jetPS2:start()
  self.engine:resume()
end

function Player:die()
  if not self.world.inWave then return end
  self.dead = true
  self.world:onDeath()
  self.jetPS1:stop()
  self.jetPS2:stop()
  self.engine:pause()
  self.shieldSound:stop()
  playRandom{"large-explosion1", "large-explosion2", "large-explosion3", "large-explosion4"}
  
  self.deathPS = love.graphics.newParticleSystem(Enemy.deathParticle, 300)
  self.deathPS:setDirection(0)
  self.deathPS:setSpread(math.tau)
  self.deathPS:setSpeed(500, 750)
  self.deathPS:setLinearDamping(7)
  self.deathPS:setParticleLifetime(0.6, 1.1)
  self.deathPS:setEmitterLifetime(0)
  self.deathPS:setSizes(1.5, 1.3, 0.4)
  self.deathPS:setRelativeRotation(true)
  self.deathPS:setAreaSpread("normal", self.width / 3, self.height / 3)
  self.deathPS:setColors(unpack(self.color))
  self.deathPS:setPosition(self.x, self.y)
  self.deathPS:emit(math.random(150, 250))
end

function Player:explodeShield()
  self:shieldSparkMode("explosion")
  self.shieldPS:emit(150)
  self:shieldSparkMode("idle")
  self.world:shake(0.3, 5)
  playRandom{"large-explosion1", "large-explosion2", "large-explosion3", "large-explosion4"}
  
  for e in Enemy.all:iterate() do
    if math.distance(self.x, self.y, e.x, e.y) <= self.shieldExplosionRange then
      e:die(true, true)
    end
  end
end

function Player:shieldSparkMode(mode)
  if mode == "idle" then
    self.shieldPS:setDirection(math.tau * .75)
    self.shieldPS:setSpread(math.tau)
    self.shieldPS:setSpeed(10, 20)
    self.shieldPS:setLinearDamping(0)
    self.shieldPS:setParticleLifetime(1.5, 2.5)
    self.shieldPS:setSizes(0.8, 0.6, 0.2)
  elseif mode == "hit" then
    self.shieldPS:setDirection(math.tau * .75)
    self.shieldPS:setSpread(math.tau / 4)
    self.shieldPS:setSpeed(150, 250)
    self.shieldPS:setLinearDamping(3)
    self.shieldPS:setParticleLifetime(0.7, 1.2)
    self.shieldPS:setSizes(0.8, 0.6, 0.2)
  elseif mode == "explosion" then
    self.shieldPS:setDirection(math.tau * .75)
    self.shieldPS:setSpread(math.tau / 2)
    self.shieldPS:setSpeed(500, 700)
    self.shieldPS:setLinearDamping(5)
    self.shieldPS:setParticleLifetime(1, 1.5)
    self.shieldPS:setSizes(1.3, 1.0, 0.5)
  end
end
