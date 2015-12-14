Dart = class("Dart", Enemy)
Dart.static.width = 10
Dart.static.height = 30

function Dart.static.line(num, ySpeed)
  local y = Enemy.spawnY - Dart.height
  local x = Enemy.padX + Dart.width / 2
  
  for i = 1, num do
    local p = Dart:new(x, y, ySpeed)
    ammo.world:add(p)
    x = x + Dart.width + (love.graphics.width - Enemy.padX * 2 - Dart.width * num) / (num - 1)
  end
end

function Dart.static.firingSquad(cols, time, reps, ySpeed)
  local i = 1
  local y = Enemy.spawnY - Dart.height
  local x = Enemy.padX + Dart.width / 2
  reps = reps or 1
  
  local function fire()
    if not ammo.world.inWave then return end
    ammo.world:add(Dart:new(x, y, ySpeed))
    
    if i % cols == 0 then
      x = Enemy.padX + Dart.width / 2
    else
      x = x + Dart.width + (love.graphics.width - Enemy.padX * 2 - Dart.width * cols) / (cols - 1)
    end
    
    i = i + 1
    
    if i <= cols * reps then
      delay(time, fire)
    end
  end
  
  fire()
end

function Dart:initialize(x, y, ySpeed)
  Enemy.initialize(self, x, y)
  self.width = Dart.width
  self.height = Dart.height
  self.image = assets.images.dart
  self.ySpeed = ySpeed or 500
  self.health = 40
  self.respawn = false
  self.color = { 0, 180, 220 }
  self.factor = 3
  
  self.ps = love.graphics.newParticleSystem(Enemy.rageParticle, 200)
  self.ps:setLinearAcceleration(0, 50)
  self.ps:setDirection(0)
  self.ps:setSpread(math.tau)
  self.ps:setSpeed(3, 6)
  self.ps:setParticleLifetime(2, 3)
  self.ps:setEmissionRate(50)
  self.ps:setEmitterLifetime(-1)
  self.ps:setRelativeRotation(true)
  --self.ps:setAreaSpread("normal", self.width / 3, 0)
  local r, g, b = unpack(self.color)
  self.ps:setColors(r, g, b, 255, r, g, b, 0)
  self.ps:start()
  
  self.score = 20
end

function Dart:added()
  Enemy.added(self)
  self.engine = playSound("dart-engine")
end

function Dart:update(dt)
  if self.dead then
    self.ps:stop()
    self.haltRemoval = self.ps:getCount() > 0
  end
  
  self.ps:moveTo(self.x, self.y)
  self.ps:update(dt)
  Enemy.update(self, dt)
end

function Dart:draw()
  love.graphics.draw(self.ps)
  Enemy.draw(self)
end

function Dart:die(e, r)
  if self.dead then return end
  self.engine:stop()
  self.engine = nil
  Enemy.die(self, e, r)
end
