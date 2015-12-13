HUD = class("HUD", Entity)

function HUD:initialize()
  Entity.initialize(self)
  self.hurtTimer = 0
  self.hurtTime = 0.3
  self.pad = 5
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
  
  local text = tostring(math.round(self.world.player.health))
  
  if self.world.player.shieldAllowed then
    text = text .. "\n"
    
    if self.world.player.shieldEnabled then
      text = text .. math.round(self.world.player.shieldHealth)
    elseif self.world.player.shieldRegenTimer > 0 then
      text = text .. math.ceil(self.world.player.shieldRegenTimer) .. "s"
    else
      text = text .. "Ready"
    end
  end
  
  love.graphics.setFont(assets.fonts.main[18])
  love.graphics.printf(text, self.pad, self.pad, love.graphics.width - self.pad * 2, "left")
end

function HUD:takenDamage()
  self.hurtTimer = self.hurtTime
end
