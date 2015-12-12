Enemy = class("Enemy", Entity)
Enemy.static.spawnY = -10
Enemy.static.padX = 5
Enemy.static.all = LinkedList:new("_nextEnemy", "_prevEnemy")

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
end

function Enemy:added()
  if self.type == "circle" then
    self.shape = HC.circle(self.x, self.y, self.radius)
  else
    self.shape = HC.rectangle(self.x - self.width / 2, self.y - self.height / 2, self.width, self.height)
  end
  
  Enemy.all:push(self)
end

function Enemy:removed()
  Enemy.all:remove(self)
end

function Enemy:update(dt)
  if self.dead then return end
  
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
end

function Enemy:draw()
  if self.dead then
    -- do explosion
    return
  end
  
  if self.image then
    love.graphics.draw(self.image, self.x, self.y, self.angle, self.scale, self.scale, self.width / 2, self.height / 2)
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
  -- homing to player, red/fire effect, etc.
end

function Enemy:placeAtSpawn()
  self.y = Enemy.spawnY - self.height
end

function Enemy:damage(amount)
  if self.dead then return end
  self.health = self.health - amount
  if self.health <= 0 then self:die() end
end

function Enemy:die(explosion)
  if self.dead then return end
  HC.remove(self.shape)
  self.dead = true
  if self.anchor then self:unsetAnchor() end
  if explosion == nil then explosion = true end
  -- kaboom
  self.world = nil -- tmp
end

function Enemy:setAnchor(anchor)
  self.anchor = anchor
  anchor.enemies = anchor.enemies + 1
end

function Enemy:unsetAnchor()
  self.anchor.enemies = self.anchor.enemies - 1
end
  
