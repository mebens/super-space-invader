Player = class("Player", PhysicalEntity)

function Player:initialize(x, y)
  PhysicalEntity.initialize(self, x, y, "dynamic")
  self.layer = 3
  self.width = 8
  self.height = 16
  self.jumpImpulse = 1000
  self.color = { 200, 0, 0 }
  self.health = 100
  self.dead = false
  self.shootTimer = 0
  self.shootTime = 0.25
end

function Player:added()
  self:setupBody()
  self.fixture = self:addShape(love.physics.newRectangleShape(self.width, self.height))
  self:setMass(2)
  --self:setLinearDamping(5)
end

function Player:update(dt)
  PhysicalEntity.update(self, dt)
  self:setAngularVelocity(0)
  
  if self.vely ~= 0 and input.pressed("jump") then
    self:applyLinearImpulse(0, -self.jumpImpulse)
  end
  
  if self.shootTimer > 0 then
    self.shootTimer = self.shootTimer - dt
  elseif input.pressed("shoot") then
    self.shootTimer = self.shootInterval
    self:shoot()
  end
end

function Player:draw()
  love.graphics.storeColor()
  love.graphics.setColor(self.color)
  love.graphics.polygon("fill", self:getWorldPoints(self.fixture:getShape():getPoints()))
  love.graphics.resetColor()
end

function Player:shoot()
  self.world:add(Bullet:new(self.x, self.y))
end

function Player:damage(health)
  if self.dead then return end
  self.health = self.health - health
  -- flash red, play sound
  if self.health <= 0 then self:die() end
end

function Player:die()
  if self.dead then return end
  self.dead = true
end
