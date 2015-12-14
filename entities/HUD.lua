HUD = class("HUD", Entity)

function HUD:initialize()
  Entity.initialize(self)
  self.layer = 1
  self.hurtTimer = 0
  self.hurtTime = 0.3
  self.pad = 5
  self.lineSpace = 20
  self.healthImg = assets.images.healthIcon
  self.shieldImg = assets.images.shieldIcon
  self.clockMap = Spritemap:new(assets.images.clockIcon, 9, 9)
  self.clockMap:add("spin", { 1, 2, 3, 4, 5, 6, 7, 8 }, 20, true)
  self.clockMap:play("spin")
  self.hurtOverlay = 0
end

function HUD:update(dt)
  if self.hurtTimer > 0 then
    self.hurtTimer = self.hurtTimer - dt
  end
  
  if self.world.player.shieldRegenTimer > 0 then
    self.clockMap:update(dt)
  end
end

function HUD:draw()
  if self.hurtOverlay > 0 then
    love.graphics.setColor(255, 0, 0, self.hurtOverlay)
    love.graphics.rectangle("fill", -10, -10, love.graphics.width + 20, love.graphics.height + 20)
  end
  
  -- score
  love.graphics.setColor(255, 255, 255)
  love.graphics.setFont(assets.fonts.main[18])
  love.graphics.printf("Score", self.pad, self.pad, love.graphics.width - self.pad * 2, "right")
  
  love.graphics.setFont(assets.fonts.main[12])
  love.graphics.printf(self.world.score, self.pad, self.pad + self.lineSpace, love.graphics.width - self.pad * 2, "right")

  if not self.world.inWave then
    love.graphics.setFont(assets.fonts.main[18])
    love.graphics.print("Hiscore", self.pad, self.pad)
    
    love.graphics.setFont(assets.fonts.main[12])
    love.graphics.print(data.hiscore, self.pad, self.pad + self.lineSpace)
    return
  end
  
  love.graphics.setFont(assets.fonts.main[18])
  -- health
  love.graphics.setColor(255, 50, 50)
  love.graphics.draw(self.healthImg, self.pad, self.pad, 0, 2, 2)
  
  if self.world.player.health < self.world.player.maxHealth and self.world.player.regenTimer <= 0 then
    love.graphics.setColor(160, 255, 160)
  elseif self.hurtTimer > 0 then
    love.graphics.setColor(235, 35, 35)
  else
    love.graphics.setColor(255, 255, 255)
  end
  
  love.graphics.print(math.round(self.world.player.health), self.pad * 2 + self.healthImg:getWidth() * 2, self.pad)
  
  -- shield
  if self.world.player.shieldAllowed then
    love.graphics.setColor(255, 255, 255)
    local text, img, width
    
    if self.world.player.shieldEnabled then
      text = tostring(math.round(self.world.player.shieldHealth))
      img = self.shieldImg
      width = img:getWidth()
    elseif self.world.player.shieldRegenTimer > 0 then
      text = tostring(math.ceil(self.world.player.shieldRegenTimer))
      img = self.clockMap
      width = img.width
    else
      text = "Ready"
      img = self.shieldImg
      width = img:getWidth()
    end
    
    if img == self.clockMap then
      img:draw(self.pad, self.pad + self.lineSpace, 0, 2, 2)
    else
      love.graphics.draw(img, self.pad, self.pad + self.lineSpace, 0, 2, 2)
    end
    
    love.graphics.print(text, self.pad * 2 + width * 2, self.pad + self.lineSpace)
  end
end

function HUD:takenDamage()
  self.hurtTimer = self.hurtTime
  self.hurtOverlay = 100
  self:animate(0.2, { hurtOverlay = 0 });
end
