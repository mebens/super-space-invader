HUD = class("HUD", Entity)

function HUD:initialize()
  Entity.initialize(self)
  self.hurtTimer = 0
  self.hurtTime = 0.3
end

function HUD:update(dt)
  if self.hurtTimer > 0 then
    self.hurtTimer = self.hurtTimer - dt
  end
end

function HUD:draw()
  if not self.world.inWave then return end
  
  if self.world.player.health < self.world.player.maxHealth and self.world.player.regenTimer <= 0 then
    love.graphics.setColor(160, 255, 160)
  elseif self.hurtTimer > 0 then
    love.graphics.setColor(235, 35, 35)
  else
    love.graphics.setColor(255, 255, 255)
  end
  
  love.graphics.setFont(assets.fonts.main[18])
  love.graphics.print(math.round(self.world.player.health), 5, 5)
end

function HUD:takenDamage()
  self.hurtTimer = self.hurtTime
end
