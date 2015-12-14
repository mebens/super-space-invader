Fighter = class("Fighter", Enemy)
Fighter.static.width = 20
Fighter.static.height = 14

function Fighter.static.sideSquadron(num, time, sides, strafe)
  local y = Enemy.spawnY - Fighter.height
  local i = 1
  sides = sides or 0
  
  local function spawn()
    if not ammo.world.inWave then return end
    if sides == 0 or sides == 1 then
      ammo.world:add(Fighter:new(love.graphics.width - Enemy.padX - Fighter.width / 2, y, strafe))
    end
    
    if sides == 0 or sides == -1 then
      ammo.world:add(Fighter:new(Enemy.padX + Fighter.width / 2, y, strafe))
    end
    
    i = i + 1
    if i <= num then delay(time, spawn) end
  end
  
  spawn()
end

function Fighter.static.line(num, ySpeed, strafe)
  ySpeed = ySpeed or 150
  local y = Enemy.spawnY - Fighter.height
  local x = Enemy.padX + Fighter.width / 2
  
  for i = 1, num do
    local p = Fighter:new(x, y)
    p.ySpeed = ySpeed
    if strafe == false then p.strafe = false end
    ammo.world:add(p)
    x = x + Fighter.width + (love.graphics.width - Enemy.padX * 2 - Fighter.width * num) / (num - 1)
  end
end

function Fighter.static.circle(num, radius, x, rotateSpeed, ySpeed, xSpeed)
  x = x or love.graphics.width / 2
  rotateSpeed = rotateSpeed or math.tau / 2
  local y = Enemy.spawnY - radius - Fighter.width
  local anchor = Anchor:new(x, y, radius, ySpeed or 100, xSpeed or 0)
  ammo.world:add(anchor)
  local angle = 0
  
  for i = 1, num do
    local p = Fighter:new(x + math.cos(angle) * radius, y + math.sin(angle) * radius, false)
    p.anchorAngle = angle
    p.anchorSpeed = rotateSpeed
    p:setAnchor(anchor)
    ammo.world:add(p)
    angle = angle + math.tau / num
  end
  
  return anchor
end

function Fighter:initialize(x, y, strafe)
  Enemy.initialize(self, x, y)
  self.width = Fighter.width
  self.height = Fighter.height
  self.speed = speed or 150
  self.ySpeed = 0
  self.angle = math.tau / 4
  
  self.strafe = strafe or true
  self.strafeTimer = 0.5
  self.strafeTime = 0.8
  self.strafing = false
  
  self.shootInterval = 0.7
  self.shootTimer = self.shootInterval
  self.contactDamage = 50
  self.respawn = false
  self.color = { 220, 220, 0 }
  self.factor = 4
  self.drawPerpAngle = true
  
  self.map = Spritemap:new(assets.images.fighter, 10, 7)
  self.map:add("fire", { 2, 3, 3, 2, 2, 1 }, 20, false)
  
  self.score = 30
end

function Fighter:update(dt)
  Enemy.update(self, dt)
  if self.dead then return end
  
  if not self.anchor then
    self.x = self.x + math.cos(self.angle) * self.speed * dt
    self.y = self.y + math.sin(self.angle) * self.speed * dt
    self.shape:moveTo(self.x, self.y)
  end
    
  if self.strafe then
    if self.strafeTimer > 0 then
      self.strafeTimer = self.strafeTimer - dt
      
      if self.strafing then
        local playerAngle = math.angle(self.x, self.y, self.world.player.x, self.world.player.y)
        self.angle = math.lerp(self.angle, playerAngle, .3)
        self.shape:setRotation(self.angle + math.tau / 4)
      end
    elseif self.strafing then
      self.strafe = false
      self.speed = self.speed * 1.3
    else
      self.strafing = true
      self.strafeTimer = self.strafeTime
    end
  end
  
  if self.shootTimer > 0 then
    self.shootTimer = self.shootTimer - dt
  else
    self.shootTimer = self.shootInterval
    self:shoot()
  end
end

function Fighter:shoot()
  self.world:add(FighterBullet:new(
    self.x + math.cos(self.angle + math.tau / 4) * (self.width / 2 - 1), 
    self.y + math.sin(self.angle + math.tau / 4) * (self.width / 2 - 1), 
    self.angle
  ))
  
  self.world:add(FighterBullet:new(
    self.x + math.cos(self.angle - math.tau / 4) * (self.width / 2 - 1), 
    self.y + math.sin(self.angle - math.tau / 4) * (self.width / 2 - 1),
    self.angle
  ))
  
  self.map:play("fire")
  playRandom{"shoot1", "shoot2", "shoot3", "shoot4", "shoot5"}
end
