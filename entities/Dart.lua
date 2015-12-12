Dart = class("Dart", Enemy)
Dart.static.width = 10
Dart.static.height = 30

function Dart.static.firingSquad(cols, time, reps, ySpeed)
  local i = 1
  local y = Enemy.spawnY - Dart.height
  local x = Enemy.padX + Dart.width / 2
  
  local function fire()
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
  self.ySpeed = ySpeed or 500
  self.health = 40
  self.respawn = false
  self.color = { 0, 0, 220 }
end
