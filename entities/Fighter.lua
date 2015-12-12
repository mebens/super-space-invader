Fighter = class("Fighter", Enemy)
Fighter.static.width = 20
Fighter.static.height = 15

function Fighter.static.sideSquadron(num, time, sides, guns, strafe)
  local y = Enemy.spawnY - Fighter.height
  local i = 1
  sides = sides or 0
  
  local function spawn()
    if sides == 0 or sides == 1 then
      ammo.world:add(Fighter:new(love.graphics.width - Enemy.padX - Fighter.width / 2, y, guns, strafe))
    end
    
    if sides == 0 or sides == -1 then
      ammo.world:add(Fighter:new(Enemy.padX + Fighter.width / 2, y, guns, strafe))
    end
    
    i = i + 1
    if i <= num then delay(time, spawn) end
  end
  
  spawn()
end

function Fighter:initialize(x, y, guns, strafe)
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
  
  self.guns = guns or 2
  self.shootInterval = 0.7
  self.shootTimer = self.shootInterval
  self.contactDamage = 50
  self.respawn = false
  self.color = { 220, 220, 0 }
end

function Fighter:update(dt)
  Enemy.update(self, dt)
  if self.dead then return end
  self.x = self.x + math.cos(self.angle) * self.speed * dt
  self.y = self.y + math.sin(self.angle) * self.speed * dt
  self.shape:moveTo(self.x, self.y)
  
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
  if self.guns == 1 or self.guns == 3 then
    self.world:add(FighterBullet:new(self.x, self.y, self.angle))
  end
  
  if self.guns == 2 or self.guns == 3 then
    self.world:add(FighterBullet:new(
      self.x + math.cos(self.angle + math.tau / 4) * self.width / 2, 
      self.y + math.sin(self.angle + math.tau / 4) * self.width / 2,
      self.angle
    ))
    
    self.world:add(FighterBullet:new(
      self.x + math.cos(self.angle - math.tau / 4) * self.width / 2, 
      self.y + math.sin(self.angle - math.tau / 4) * self.width / 2,
      self.angle
    ))
  end
end
