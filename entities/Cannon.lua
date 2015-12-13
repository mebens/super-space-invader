Cannon = class("Cannon", Enemy)
Cannon.static.width = 36
Cannon.static.height = 40

function Cannon:initialize(x, y)
  Enemy.initialize(self, x, y or Enemy.spawnY - Cannon.height)
  self.width = Cannon.width
  self.height = Cannon.height
  self.health = 350
  self.ySpeed = 50
  self.contactDamage = 150
  self.map = Spritemap:new(assets.images.cannon, 18, 20)
  self.map:add("fire", { 4, 7, 6, 5, 4, 3, 2, 1 }, 20, false)
  
  self.minShot = 5
  self.maxShot = 8
  self.shotRange = math.tau / 12
  self.shootInterval = 1.5
  self.shootTimer = self.shootInterval
  self.color = { 220, 220, 220 }
  self.factor = 9
  self.shakeAmount = 5
  self.shakeTime = 0.3
  self.explosionSize = "large"
end

function Cannon:added()
  Enemy.added(self)
  self.engine = playSound("cannon-engine")
  self.engine:setLooping(true)
end

function Cannon:update(dt)
  Enemy.update(self, dt)
  if self.dead then return end
  
  if self.shootTimer > 0 then
    self.shootTimer = self.shootTimer - dt
  else
    self.shootTimer = self.shootInterval
    self.map:play("fire")
    playRandom{"cannon-shot1", "cannon-shot2", "cannon-shot3"}
    
    for i = 1, math.random(self.minShot, self.maxShot) do
      local randomAngle = math.tau / 4 + self.shotRange * math.random() - self.shotRange / 2
      self.world:add(CannonShot:new(self.x, self.y + 6, randomAngle))
    end
  end
end

function Cannon:die(e, r)
  Enemy.die(self, e, r)
  self.engine:stop()
  self.engine = nil
end
  
