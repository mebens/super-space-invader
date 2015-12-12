Pawn = class("Pawn", Enemy)
Pawn.static.width = 20
Pawn.static.height = 20

function Pawn.static.line(cols, pos, ySpeed, padding)
  pos = pos or 1
  ySpeed = ySpeed or 100
  local y = Enemy.spawnY - pos * Pawn.height - (pos - 1) * (padding or 5)
  local x = Enemy.padX + Pawn.width / 2
  
  for i = 1, cols do
    local p = Pawn:new(x, y)
    p.ySpeed = ySpeed
    ammo.world:add(p)
    x = x + Pawn.width + (love.graphics.width - Enemy.padX * 2 - Pawn.width * cols) / (cols - 1)
  end
end

function Pawn.static.diagonal(num, dir, yDiff, xSpeed, ySpeed)
  yDiff = yDiff or Pawn.height
  dir = dir or 1
  xSpeed = xSpeed or 0
  ySpeed = ySpeed or 100
  
  local y = Enemy.spawnY - Pawn.height
  local x = dir == 1 and Enemy.padX + Pawn.width / 2 or love.graphics.width - Enemy.padX - Pawn.width / 2
  
  for i = 1, num do
    local p = Pawn:new(x, y)
    p.xSpeed = xSpeed
    p.ySpeed = ySpeed
    ammo.world:add(p)
    x = x + (Pawn.width + (love.graphics.width - Enemy.padX * 2 - Pawn.width * num) / (num - 1)) * dir
    y = y - yDiff
  end
end

function Pawn.static.circle(num, radius, x, rotateSpeed, ySpeed, xSpeed)
  x = x or love.graphics.width / 2
  rotateSpeed = rotateSpeed or math.tau / 2
  local y = Enemy.spawnY - radius - Pawn.width
  local anchor = Anchor:new(x, y, radius, ySpeed or 100, xSpeed or 0)
  ammo.world:add(anchor)
  local angle = 0
  
  for i = 1, num do
    local p = Pawn:new(x + math.cos(angle) * radius, y + math.sin(angle) * radius)
    p.anchorAngle = angle
    p.anchorSpeed = rotateSpeed
    p:setAnchor(anchor)
    ammo.world:add(p)
    angle = angle + math.tau / num
  end
  
  return anchor
end

function Pawn.static.crissCross(num, time, xSpeed, ySpeed)
  xSpeed = xSpeed or 100
  ySpeed = ySpeed or 100
  local y = Enemy.spawnY - Pawn.height
  local i = 1
  
  local function spawn()
    ammo.world:add(Pawn:new(Enemy.padX + Pawn.width / 2, y, xSpeed, ySpeed))
    ammo.world:add(Pawn:new(love.graphics.width - Enemy.padX - Pawn.width / 2, y, xSpeed, ySpeed))
    i = i + 1
    if i <= num then delay(time, spawn) end
  end
  
  spawn()
end

function Pawn:initialize(x, y, xSpeed, ySpeed)
  Enemy.initialize(self, x, y or Enemy.spawnY - Pawn.height)
  self.width = Pawn.width
  self.height = Pawn.height
  self.xSpeed = xSpeed or 0
  self.ySpeed = ySpeed or 100
  self.color = { 0, 220, 0 }
end
