Enemy = class("Enemy", Entity)
Enemy.static.spawnY = -10
Enemy.static.padX = 5
Enemy.static.all = LinkedList:new("_nextEnemy", "_prevEnemy")
Enemy.static.rageParticle = love.graphics.newCanvas(3, 1)
Enemy.static.deathParticle = love.graphics.newCanvas(2, 2)

Enemy.rageParticle:renderTo(function() 
  love.graphics.setColor(255, 255, 255)
  love.graphics.rectangle("fill", 0, 0, 3, 1)
end)

Enemy.deathParticle:renderTo(function()
  love.graphics.setColor(255, 255, 255)
  love.graphics.rectangle("fill", 0, 0, 2, 2)
end)

function Enemy:initialize(x, y)
  Entity.initialize(self, x, y)
  self.layer = 3
  self.angle = 0
  self.scale = 1
  if not y then self:placeAtSpawn() end
  
  self.padX = Enemy.padX
  self.xDir = 1
  self.xSpeed = 0
  self.ySpeed = 100
  self.health = 100
  self.contactDamage = 50
  self.respawn = "rage"
  self.rageMode = false
  self.rageRatio = 2
  self.shakeAmount = 2
  self.shakeTime = 0.15
  self.explosionSize = "small"
  self.score = 10
end

function Enemy:added()
  if self.type == "circle" then
    self.shape = HC.circle(self.x, self.y, self.radius)
  else
    self.shape = HC.rectangle(self.x - self.width / 2, self.y - self.height / 2, self.width, self.height)
  end
  
  Enemy.all:push(self)
end

function Enemy:update(dt)
  if self.ragePS then
    self.ragePS:moveTo(self.x, self.y)
    self.ragePS:setColors(unpack(self.color))
    self.ragePS:setLinearAcceleration(self.xSpeed * self.xDir, self.ySpeed)
    self.ragePS:update(dt)
    if self.dead or not self.rageMode then self.ragePS:stop() end
  end
  
  if self.dead then
    if self.deathPS then self.deathPS:update(dt) end
    
    if not self.haltRemoval
      and ((not self.deathPS) or self.deathPS:getCount() == 0)
      and ((not self.ragePS) or self.ragePS:getCount() == 0)
    then
      self.world = nil
    end
    
    return
  end
  
  if self.map then self.map:update(dt) end
  
  if self.anchor then
    self.anchorAngle = (self.anchorAngle + self.anchorSpeed * dt) % math.tau
    self.x = self.anchor.x + math.cos(self.anchorAngle) * self.anchor.radius
    self.y = self.anchor.y + math.sin(self.anchorAngle) * self.anchor.radius
    self.angle = self.anchorAngle
    self.shape:setRotation(self.angle)
  else
    self.y = self.y + self.ySpeed * dt
    
    if self.xSpeed > 0 then
      self.x = self.x + self.xSpeed * self.xDir * dt
      self.x = math.clamp(self.x, self.padX + self.width / 2, love.graphics.width - self.padX - self.width / 2)
      
      if self.x == self.padX + self.width / 2 then
        self.xDir = 1
      elseif self.x == love.graphics.width - self.padX - self.width / 2 then
        self.xDir = -1
      end
    end
  end
  
  self.shape:moveTo(self.x, self.y)
    
  if self.y > love.graphics.height + self.height then
    if not self.respawn then
      self:die(false)
    else
      if self.respawn == "rage" then self:enableRage() end
      if not self.anchor then self:placeAtSpawn() end
    end  
  end
  
  if self.shape:collidesWith(self.world.player.shape) then
    self.world.player:damage(self.contactDamage)
    self:die()
  end
  
  for b in Bullet.all:iterate() do
    if self.shape:collidesWith(b.shape) then
      self:damage(b.damage)
      b:die()
    end
  end
  
  for m in Missile.all:iterate() do
    if self.shape:collidesWith(m.shape) then
      self:damage(m.damage)
      m:die()
    end
  end
end

function Enemy:draw()
  if self.deathPS then love.graphics.draw(self.deathPS, self.x, self.y) end
  if self.ragePS then love.graphics.draw(self.ragePS) end
  
  if self.dead then
    -- do explosion
    return
  end
  
  if self.image then
    self:drawImage()
  elseif self.map then
    self:drawMap()
  else
    self.shape:draw()
    love.graphics.storeColor()
    love.graphics.setColor(self.color)
    love.graphics.rectangle("fill", self.x - self.width / 2, self.y - self.height / 2, self.width, self.height)
    love.graphics.resetColor()
  end
end

function Enemy:enableRage()
  if self.rageMode then return end
  self.rageMode = true
  self.ySpeed = self.ySpeed * self.rageRatio
  self.xSpeed = self.xSpeed * self.rageRatio
  tween(self.color, 1, { [1] = 220, [2] = 0, [3] = 0 })
  
  self.ragePS = love.graphics.newParticleSystem(Enemy.rageParticle, 100)
  self.ragePS:setDirection(math.tau * 0.75)
  self.ragePS:setSpread(math.tau / 8)
  self.ragePS:setSpeed(50, 100)
  self.ragePS:setLinearDamping(4)
  self.ragePS:setParticleLifetime(0.5, 1.5)
  self.ragePS:setEmissionRate(40)
  self.ragePS:setEmitterLifetime(-1)
  self.ragePS:setSizes(1, 0.8, 0.2)
  self.ragePS:setRelativeRotation(true)
  self.ragePS:setAreaSpread("normal", self.width / 3, self.height / 3)
  self.ragePS:start()
end

function Enemy:placeAtSpawn()
  self.y = Enemy.spawnY - self.class.height
end

function Enemy:damage(amount)
  if self.dead then return end
  self.health = self.health - amount
  
  if self.health <= 0 then
    self:die()
  else
    playRandom({"hit1", "hit2", "hit3"}, 0.6)
  end
end

function Enemy:die(explosion, delayRemove)
  if self.dead then return end
  HC.remove(self.shape)
  self.world:addScore(self.score + (self.rageMode and 5 or 0))
  
  if delayRemove then
    delay(0, Enemy.all.remove, Enemy.all, self)
  else
    Enemy.all:remove(self)
  end
  
  self.dead = true
  if self.anchor then self:unsetAnchor() end
  if explosion == nil then explosion = true end
  
  if explosion then
    local factor = self.factor or 5
    self.deathPS = love.graphics.newParticleSystem(Enemy.deathParticle, 300)
    self.deathPS:setDirection(0)
    self.deathPS:setSpread(math.tau)
    self.deathPS:setSpeed(100 * factor, 150 * factor)
    self.deathPS:setLinearDamping(7)
    self.deathPS:setLinearAcceleration(self.xSpeed * self.xDir, self.ySpeed)
    self.deathPS:setParticleLifetime(0.6, 1.1)
    self.deathPS:setEmitterLifetime(0)
    self.deathPS:setSizes(.25 * factor, 0.2 * factor, 0.05 * factor)
    self.deathPS:setRelativeRotation(true)
    self.deathPS:setAreaSpread("normal", self.width / 3, self.height / 3)
    self.deathPS:setColors(unpack(self.color))
    self.deathPS:emit(math.random(12, 22) * factor)
    
    self.world:shake(self.shakeTime, self.shakeAmount)
    
    if self.explosionSize == "large" then
      playRandom{"large-explosion1", "large-explosion2", "large-explosion3", "large-explosion4"}
    else
      playRandom{"small-explosion1", "small-explosion2", "small-explosion3", "small-explosion4", "small-explosion5"}
    end
  end
end

function Enemy:setAnchor(anchor)
  self.anchor = anchor
  anchor.enemies = anchor.enemies + 1
end

function Enemy:unsetAnchor()
  self.anchor.enemies = self.anchor.enemies - 1
end
  
