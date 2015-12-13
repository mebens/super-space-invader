Missile = class("Missile", Entity)
Missile.static.width = 10
Missile.static.height = 3.75
Missile.static.all = LinkedList:new("_nextMissile", "_prevMissile")

function Missile:initialize(x, y)
  Entity.initialize(self, x, y)
  self.layer = 4
  self.angle = math.tau * .75
  self.speed = 250
  self.damage = 150
  self.imageScale = 1.25
  self.width = Missile.width
  self.height = Missile.height
  self.image = assets.images.missile
  self.scale = 1
  self.detectRange = 100
  
  self.ps = love.graphics.newParticleSystem(Enemy.rageParticle, 200)
  self.ps:setSpeed(100, 200)
  self.ps:setLinearDamping(3)
  self.ps:setSpread(math.tau / 16)
  self.ps:setColors(255, 60, 0, 255, 255, 0, 0, 0)
  self.ps:setParticleLifetime(0.5, 0.8)
  self.ps:setEmitterLifetime(-1)
  self.ps:setEmissionRate(50)
  self.ps:setRelativeRotation(true)
  self.ps:start()
end

function Missile:added()
  Missile.all:push(self)
  self.shape = HC.rectangle(self.x - self.width / 2, self.y - self.height / 2, self.width, self.height)
  self.fireSound = playRandom{"fire-missile1", "fire-missile2"}
end

function Missile:removed()
  Missile.all:remove(self)
  HC.remove(self.shape)
end

function Missile:update(dt)
  self.ps:update(dt)
  
  if self.dead then
    if self.deathPS then self.deathPS:update(dt) end
    
    if ((not self.deathPS) or self.deathPS:getCount() == 0) and self.ps:getCount() == 0 then
      self.world = nil
    end
    
    return
  end
  
  if not self.engineSound and self.fireSound:tell() > 1 then
    self.engineSound = playSound("missile-engine")
  end
  
  if self.target then
    if self.target.dead then
      self.target = nil
    else
      self.angle = math.angle(self.x, self.y, self.target.x, self.target.y)
      self.shape:setRotation(self.angle + math.tau / 4)
    end
  else
    local enemy
    local dist = math.huge
    
    for e in Enemy.all:iterate() do
      local d = math.distance(self.x, self.y, e.x, e.y)
      
      if d <= self.detectRange and d < dist then
        enemy = e
        dist = d
      end
    end
    
    if enemy then self.target = enemy end
  end
  
  self.x = self.x + math.cos(self.angle) * self.speed * dt
  self.y = self.y + math.sin(self.angle) * self.speed * dt
  self.shape:moveTo(self.x, self.y)
  
  self.ps:moveTo(self.x, self.y)
  self.ps:setDirection(self.angle - math.tau / 2)
  
  if self.y < -self.height or self.y > love.graphics.height + self.height
    or self.x < -self.width or self.x > love.graphics.width + self.width
  then
    self:die(false)
  end
end

function Missile:draw()
  if self.deathPS then love.graphics.draw(self.deathPS) end
  love.graphics.draw(self.ps)
  if not self.dead then self:drawImage() end
end

function Missile:die(explosion)
  self.dead = true
  self.fireSound:stop()
  if self.engineSound then self.engineSound:stop() end
  self.ps:stop()
  if explosion == nil then explosion = true end
  
  if explosion then
    self.deathPS = love.graphics.newParticleSystem(Enemy.deathParticle, 100)
    self.deathPS:setDirection(0)
    self.deathPS:setSpread(math.tau)
    self.deathPS:setSpeed(100, 400)
    self.deathPS:setLinearDamping(3)
    self.deathPS:setParticleLifetime(0.6, 1.1)
    self.deathPS:setEmitterLifetime(0)
    self.deathPS:setSizes(1.1, 0.8, 0.4)
    self.deathPS:setRelativeRotation(true)
    self.deathPS:setColors(255, 60, 0, 255, 255, 220, 0, 0)
    self.deathPS:setPosition(self.x, self.y)
    self.deathPS:emit(math.random(60, 100))
    
    playRandom{"small-explosion1", "small-explosion2", "small-explosion3", "small-explosion4", "small-explosion5"}
  end
end
