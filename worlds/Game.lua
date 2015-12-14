Game = class("Game", World)

function Game:initialize()
  World.initialize(self)
  self.player = Player:new()
  self.ui = UI:new()
  self.hud = HUD:new()
  self.bg = Background:new()
  self:add(self.player, self.ui, self.hud, self.bg)
  
  self.score = 0
  self.shakeTimer = 0
  self.wait = 0
  self.repetitions = 0
  self.inWave = false
  
  self:setupLayers{
    [1] = { 1, pre = postfx.exclude, post = postfx.include }, -- UI
    [2] = 1, -- battleship guns
    [3] = 1, -- player / enemies
    [4] = 1, -- bullets
    [5] = 1, -- blank
    [6] = 1 -- background
  }
end

function Game:start()
  self.ui:welcome()  
  self.menuMusic = assets.music.menu:loop()
  self.waveMusic = assets.music.wave:loop()
  self.menuVolume = 1
  self.waveVolume = 0
  self.waveMusic:stop()
end

function Game:update(dt)
  World.update(self, dt)
  self.menuMusic:setVolume(self.menuVolume)
  self.waveMusic:setVolume(self.waveVolume)
  
  if self.shakeTimer > 0 then
    self.shakeTimer = self.shakeTimer - dt
    
    if self.camera.x == 0 then
      self.camera.x = self.shakeAmount * (1 - 2 * math.random(0, 1))
      self.camera.y = self.shakeAmount * (1 - 2 * math.random(0, 1))
    else
      self.camera.x = 0
      self.camera.y = 0
    end
  else
    self.camera.x = 0
    self.camera.y = 0
  end
      
  if self.inWave then
    if self.wait == "enemies" then
      if Enemy.all.length == 0 then self.wait = 0 end
    elseif self.wait > 0 then
      self.wait = self.wait - dt
    else
      local index, rep
      
      if self.waveNum < 13 then
        index, rep = self["wave" .. self.waveNum](self, self.waveIndex, self.repetitions)
      else
        index, rep = self:waveInfinite(self.waveIndex, self.repetitions)
      end
      
      if index == nil then
        self:endWave()
      elseif index then
        self.waveIndex = index
      end
      
      if rep == 0 then
        self.repetitions = 0
      elseif rep then
        self.repetitions = self.repetitions + 1
      end
    end
  end
end

function Game:startWave(num)
  for e in Enemy.all:iterate() do e:die(true, true) end
  self.player:reset()
  if num == 13 then self.player:applyLevels(6, 7) end
  
  local text
  
  if num < 13 then
    text = "Wave " .. num
  else
    text = "Infinite Wave"
  end
  
  self.ui:display(1, text, function()
    delay(2.5, self.fadeMusic, self)
    
    self.ui:startCountdown(function()
      self.player:reset()
      self.inWave = true
      self.waveIndex = 1
      self.repetitions = 0
      self.wait = 0
      self.waveNum = num
    end)
  end)
end

function Game:nextWave()
  local waveNum = self.waveNum + 1
  if waveNum > 13 then waveNum = 13 end
  self:startWave(waveNum)
end

function Game:endWave()
  self.inWave = false
  self.ui:upgrades()
  self:fadeMusic()
  data.saveHiscore(self.score)
end

function Game:startSandbox()
  self.sandbox = true
  self:startWave(13)
end

function Game:onDeath()
  if self.sandbox then
    self.ui:welcome()
    self.sandbox = false
  else
    self.ui:death()
  end
  
  self:shake(0.5, 4)
  self.inWave = false
  self:fadeMusic()
  data.saveHiscore(self.score)
end

function Game:addScore(amount)
  if not self.inWave then return end
  self.score = self.score + amount
end

function Game:completeUpgrade(attack, defence)
  if attack then self.player.attackLvl = attack end
  if defence then self.player.defenceLvl = defence end
  self.player:applyLevels()
  data.save(self.waveNum + 1, self.score, self.player.attackLvl, self.player.defenceLvl)
end

function Game:shake(time, amount)
  amount = amount or 2
  if self.shakeTimer <= 0 or amount >= self.shakeAmount then
    self.shakeTimer = time
    self.shakeAmount = amount
  end
end

function Game:fadeMusic()
  local sound1, sound2
  
  if self.menuVolume > 0 then
    sound1 = "menu"
    sound2 = "wave"
  else
    sound1 = "wave"
    sound2 = "menu"
  end
  
  self[sound2 .. "Music"]:play()
  tween(self, 0.5, { [sound2 .. "Volume"] = 1 }, nil, function()
    tween(self, 0.5, { [sound1 .. "Volume"] = 0 })
  end)
end

function Game:randomX(class)
  if class then
    return math.random(Enemy.padX + class.width / 2, love.graphics.width - Enemy.padX - class.width / 2)
  else 
    return math.random(Enemy.padX, love.graphics.width - Enemy.padX)
  end
end

function Game:wave1(i, r)
  if i == 0 then
    return 1
  elseif i == 1 then
    self:add(Pawn:new(self:randomX(Pawn)))
    self.wait = math.random(15, 20) / 10
    
    if r < 7 then
      return 1, 1
    else
      return 2, 0
    end
  elseif i == 2 then
    Pawn.crissCross(3, 1)
    self.wait = "enemies"
    return 3
  elseif i == 3 then
    self:add(Cannon:new(love.graphics.width / 2))
    self.wait = "enemies"
    return 4
  elseif i == 4 then
    return nil
  end
end

function Game:wave2(i, r)
  if i == 0 then
    return 1
  elseif i == 1 then
    self:add(Pawn:new(self:randomX(Pawn)))
    self.wait = math.random(9, 15) / 10
    
    if r < 7 then
      return 1, 1
    else
      return 2, 0
    end
  elseif i == 2 then
    if math.random(1, 2) == 2 then
      Pawn.crissCross(3, 0.7)
    else
      Pawn.line(5)
    end
    
    self.wait = "enemies"
    
    if r < 2 then
      return 2, 1
    else
      return 3, 0
    end
  elseif i == 3 then
    Pawn.circle(10, 60, love.graphics.width / 2)
    return 4
  elseif i == 4 then
    Dart.firingSquad(5, 0.5, 1)
    
    if r < 2 then
      self.wait = 5
      return 4, 1
    else
      self.wait = "enemies"
      return 5, 0
    end
  elseif i == 5 then
    Pawn.crissCross(3, 1.5)
    self:add(Cannon:new(love.graphics.width / 2))
    self.wait = "enemies"
    return 6
  elseif i == 6 then
    return nil
  end
end

function Game:wave3(i, r)
  if i == 0 then
    return 1
  elseif i == 1 then
    Fighter.sideSquadron(5, 2)
    self.wait = "enemies"
    return 2
  elseif i == 2 then
    if math.random(1, 2) == 1 then
      Pawn.line(6, 1, 40)
      Pawn.line(6, 2, 40)
    else
      Pawn.circle(6, 50, love.graphics.width * .25, math.tau * .6, 60)
      Pawn.circle(6, 50, love.graphics.width * .75, math.tau * .6, 60)
    end
    
    self.wait = "enemies"
    
    if r < 3 then
      return 2, 1
    else
      return 3, 0
    end
  elseif i == 3 then
    if math.random(1, 2) == 1 then
      Fighter.sideSquadron(1, 1)
    else
      Dart.firingSquad(3, 1, 2)
    end
    
    self:add(Cannon:new(love.graphics.width * .2))
    self:add(Cannon:new(love.graphics.width * .8))
    self.wait = "enemies"
    return 4
  elseif i == 4 then
    return nil
  end
end

function Game:wave4(i, r)
  if i == 0 then
    return 1
  elseif i == 1 then
    Pawn.line(8, 1, 30)
    Pawn.line(8, 3, 30)
    self.wait = "enemies"
    return 2
  elseif i == 2 then
    Fighter.sideSquadron(5, 3)
    return 3
  elseif i == 3 then
    Dart.line(math.random(4, 6))
    self.wait = 5
    
    if r < 3 then
      return 3, 1
    else
      return 4, 0
    end
  elseif i == 4 then
    Pawn.diagonal(6, 1, Pawn.height * 2)
    Pawn.diagonal(6, -1, Pawn.height * 2)
    return 5
  elseif i == 5 then
    self:add(Fighter:new(math.random(Enemy.padX * 2, love.graphics.width - Enemy.padX * 2)))
    self.wait = 2
    
    if r < 4 then
      return 5, 1
    else
      return 6, 0
    end
  elseif i == 6 then
    Fighter.sideSquadron(3, 1)
    self.wait = "enemies"
    return 7
  elseif i == 7 then
    return nil
  end
end

function Game:wave5(i, r)
  if i == 0 then
    return 1
  elseif i == 1 then
    Pawn.crissCross(10, 1)
    return 2
  elseif i == 2 then
    if math.random(1, 2) == 1 then
      Dart.line(5)
    else
      Dart.firingSquad(5, 0.5)
    end
    
    if r < 3 then
      self.wait = 2
      return 2, 1
    else
      self.wait = "enemies"
      return 3, 0
    end
  elseif i == 3 then
    self:add(Battleship:new(love.graphics.width / 2))
    self.wait = "enemies"
    return 4
  end
end

function Game:wave6(i, r)
  if i == 0 then
    return 1
  elseif i == 1 then
    Pawn.crissCross(5, 1)
    self.wait = 3
    return 2
  elseif i == 2 then
    Pawn.circle(15, love.graphics.width * .7, love.graphics.width / 2, math.tau / 4)
    self.wait = 6
    return 3
  elseif i == 3 then
    Fighter.sideSquadron(5, 3)
    return 4
  elseif i == 4 then
    Fighter.circle(6, 60, love.graphics.width / 2, math.tau * .75, 100, 100)
    self.wait = 6
    
    if r < 2 then
      return 4, 1
    else
      return 5, 0
    end
  elseif i == 5 then
    self:add(Cannon:new(love.graphics.width * .25))
    self:add(Cannon:new(love.graphics.width * .75))
    self.wait = "enemies"
    return 6
  end
end

function Game:wave7(i, r)
  if i == 0 then
    return 1
  elseif i == 1 then
    Fighter.circle(5, 60, love.graphics.width * .25)
    Fighter.circle(5, 60, love.graphics.width * .75)
    return 2
  elseif i == 2 then
    local p = Pawn:new(self:randomX(Pawn))
    p.ySpeed = 150
    self:add(p)
    
    if r < 7 then
      self.wait = math.random(5, 10) / 10
      return 2, 1
    else
      self.wait = "enemies"
      return 3, 0
    end
  elseif i == 3 then
    local c = Cannon:new(love.graphics.width * .5)
    c.health = 500
    self:add(c)
    Fighter.sideSquadron(6, 1.5)
    self.wait = "enemies"
    return 4
  elseif i == 4 then
    Dart.firingSquad(8, 0.5)
    self.wait = 1
    return 5
  elseif i == 5 then
    local a = Anchor:new(love.graphics.width / 2, Enemy.spawnY - 150, 150, 50)
    local a1 = Pawn.circle(10, 50)
    local a2 = Pawn.circle(10, 50)
    local a3 = Pawn.circle(10, 50)
    a1:setAnchor(a, 0, math.tau / 4)
    a2:setAnchor(a, math.tau / 3, math.tau / 4)
    a3:setAnchor(a, math.tau * (2/3), math.tau / 4)
    self:add(a)
    self.wait = "enemies"
    return 6
  end
end

function Game:wave8(i, r)
  if i == 0 then
    return 1
  elseif i == 1 then
    Pawn.crissCross(30, 1, 100, 150)
    return 2
  elseif i == 2 then
    self:add(Cannon:new(love.graphics.width * .5, nil, 100))
    
    if r < 5 then
      self.wait = 7
      return 2, 1
    else
      self.wait = "enemies"
      return 3, 0
    end
  elseif i == 3 then
    local a = Anchor:new(love.graphics.width / 2, Enemy.spawnY - 150, 150, 50)
    local a1 = Pawn.circle(10, 50)
    local a2 = Pawn.circle(10, 50)
    a1:setAnchor(a, 0, math.tau / 4)
    a2:setAnchor(a, math.tau / 2, math.tau / 4)
    self:add(a)
    return 4
  elseif i == 4 then
    self:add(Cannon:new(love.graphics.width * .5, nil, 100))
    
    if r < 3 then
      self.wait = 6
      return 4, 1
    else
      self.wait = "enemies"
      return 5, 0
    end
  elseif i == 5 then
    Fighter.line(5, 100, math.random(0, 1) == 1 and true or false)
    Pawn.crissCross(3, 1, 100, 150)
    
    if r < 3 then
      self.wait = 5
      return 5, 1
    else
      self.wait = "enemies"
      return 6
    end
  end
end

function Game:wave9(i, r)
  if i == 0 then
    return 1
  elseif i == 1 then
    Pawn.crissCross(20, 1, 100, 100)
    return 2
  elseif i == 2 then
    if math.random(0, 1) == 0 then
      Fighter.circle(8, 60)
    else
      Fighter.line(4)
    end
    
    if r < 6 then
      self.wait = 3
      return 2, 1
    else
      self.wait = "enemies"
      return 3, 0
    end
  elseif i == 3 then
    self:add(Cannon:new(love.graphics.width * .25, nil, 100))
    self:add(Cannon:new(love.graphics.width * .75, nil, 100))
    self.wait = 1
    return 4
  elseif i == 4 then
    Dart.firingSquad(6)
    
    if r < 4 then
      self.wait = 5
      return 3, 1
    else
      return 5, 0
    end
  elseif i == 5 then
    Pawn.crissCross(10, 0.75, 100, 150)
    self.wait = "enemies"
    return 6
  end
end

function Game:wave10(i, r)
  if i == 0 then
    return 1
  elseif i == 1 then
    Fighter.line(4)
    Pawn.diagonal(8, 1 - 2 * math.random(0, 1))
    
    if r < 4 then
      self.wait = 5
      return 1, 1
    else
      self.wait = "enemies"
      return 2, 0
    end
  elseif i == 2 then
    self:add(Cannon:new(love.graphics.width * .25, nil, 70))
    self:add(Cannon:new(love.graphics.width * .75, nil, 70))
    self.wait = 3
    
    if r < 3 then
      return 2, 1
    else
      return 3, 0
    end
  elseif i == 3 then
    local a = Anchor:new(love.graphics.width / 2, Enemy.spawnY - 150, 150, 50)
    local a1 = Fighter.circle(7, 50)
    local a2 = Fighter.circle(7, 50)
    a1:setAnchor(a, 0, math.tau / 4)
    a2:setAnchor(a, math.tau / 2, math.tau / 4)
    self:add(a)
    self.wait = "enemies"
    return 4
  elseif i == 4 then
    self.wait = 2
    return 5
  elseif i == 5 then
    local bs = Battleship:new(love.graphics.width / 2, 5000)
    self:add(bs)
    self.wait = "enemies"
    return 6
  end
end

function Game:wave11(i, r)
  if i == 0 then
    return 1
  elseif i == 1 then
    Pawn.crissCross(30, 0.6, 100, 100)
    self.wait = 2
    return 2
  elseif i == 2 then
    Fighter.line(5)
    self.wait = 5
    
    if r < 4 then
      return 2, 1
    else 
      return 3, 0
    end
  elseif i == 3 then
    self:add(Cannon:new(love.graphics.width * .25, nil, 100))
    self:add(Cannon:new(love.graphics.width * .5, nil, 100))
    self:add(Cannon:new(love.graphics.width * .75, nil, 100))
    self.wait = "enemies"
    return 4
  elseif i == 4 then
    local t = math.random(1, 4)
    
    if t == 1 then
      Fighter.circle(10, 70)
    elseif t == 2 then
      Pawn.line(10, 1, 120)
      Pawn.line(10, 3, 120)
    elseif t == 3 then
      local a = Anchor:new(love.graphics.width / 2, Enemy.spawnY - 150, 150, 50)
      local a1 = Pawn.circle(10, 50)
      local a2 = Pawn.circle(10, 50)
      a1:setAnchor(a, 0, math.tau / 4)
      a2:setAnchor(a, math.tau / 2, math.tau / 4)
      self:add(a)
    elseif t == 4 then
      Dart.line(5)
    end
    
    if r < 8 then
      self.wait = 4
      return 4, 1
    else
      self.wait = "enemies"
      return 5, 0
    end
  elseif i == 5 then
    self.wait = 2
    return 6
  elseif i == 6 then
    self:add(Pawn:new(self:randomX(Pawn)))
    self.wait = "enemies"
    return 7
  end
end

function Game:wave12(i, r)
  if i == 0 then
    return 1
  elseif i == 1 then
    Pawn.line(10, 1, 120)
    Pawn.line(10, 3, 120)
    
    if r > 2 then
      local a = Anchor:new(love.graphics.width / 2, Enemy.spawnY - 150, 150, 50)
      local a1 = Fighter.circle(6, 60)
      local a2 = Fighter.circle(6, 60)
      a1:setAnchor(a, 0, math.tau / 4)
      a2:setAnchor(a, math.tau / 2, math.tau / 4)
      self:add(a)
    else
      Fighter.circle(10, 70, love.graphics.width / 3)
      Fighter.circle(10, 70, love.graphics.width * (2/3))
    end
    
    if r < 3 then
      self.wait = 10
      return 1, 1
    else
      self.wait = "enemies"
      return 2, 0
    end
  elseif i == 2 then
    self:add(Cannon:new(love.graphics.width * .25, nil, 100))
    self:add(Cannon:new(love.graphics.width * .5, nil, 100))
    self:add(Cannon:new(love.graphics.width * .75, nil, 100))
    
    if math.random(1, 2) == 1 then
      Fighter.line(2)
    else
      Dart.line(8)
    end
    
    if r < 2 then
      self.wait = 5
      return 2, 1
    else
      self.wait = "enemies"
      return 3, 0
    end
  elseif i == 3 then
    Pawn.crissCross(15, 1)
    return 4
  elseif i == 4 then
    self:add(Cannon:new(love.graphics.width * .25, nil, 100))
    self:add(Cannon:new(love.graphics.width * .75, nil, 100))
    
    if r < 2 then
      self.wait = 4
      return 4, 1
    else
      self.wait = "enemies"
      return 5, 0
    end
  elseif i == 5 then
    self.bs = Battleship:new(love.graphics.width / 2, 5000)
    self:add(self.bs)
    return 6
  elseif i == 6 then
    if self.bs.dead then
      for e in Enemy.all:iterate() do
        e:die(true, true)
      end
      
      self.bs = nil
      return 7
    end
    
    if math.random(1, 2) == 1 then
      Fighter.sideSquadron(1, 1)
    else
      Dart.firingSquad(5)
    end
    
    self.wait = 5
    return 6
  elseif i == 7 then
    self.wait = 2
    return 8
  end
end

function Game:waveInfinite(i, r)
  if i == 0 then
    return 1
  elseif i == 1 then
    local t = math.random(1, 3)
    
    if t == 1 then
      Pawn.crissCross(12, 0.5, 100, 120)
    elseif t == 2 then
      Pawn.line(10, 1, 120)
      Pawn.line(10, 2, 120)
      Pawn.line(10, 3, 120)
    elseif t == 3 then
      Pawn.diagonal(10, 1, nil, 0, 120)
      Pawn.diagonal(10, -1, nil, 0, 120)
    end
    
    self.wait = 7
    
    if r < 4 then
      return 1, 1
    else
      return 2, 0
    end
  elseif i == 2 then
    local t = math.random(1, 4)
    
    if t == 1 then
      Pawn.line(10, 1, 120)
      if math.random(1, 2) == 1 then Pawn.line(10, 3, 120) end
      
      if math.random(1, 2) == 1 then
        local a = Anchor:new(love.graphics.width / 2, Enemy.spawnY - 150, 150, 50)
        local a1 = Fighter.circle(6, 60)
        local a2 = Fighter.circle(6, 60)
        a1:setAnchor(a, 0, math.tau / 4)
        a2:setAnchor(a, math.tau / 2, math.tau / 4)
        self:add(a)
      else
        Fighter.circle(10, 70, love.graphics.width / 3)
        Fighter.circle(10, 70, love.graphics.width * (2/3))
      end
    elseif t == 2 then
      if math.random(1, 2) == 1 then
        Fighter.circle(10, 70)
      else
        Dart.firingSquad(8)
      end
      
      local a = Anchor:new(love.graphics.width / 2, Enemy.spawnY - 150, 150, 50)
      local a1 = Pawn.circle(10, 50)
      local a2 = Pawn.circle(10, 50)
      a1:setAnchor(a, 0, math.tau / 4)
      a2:setAnchor(a, math.tau / 2, math.tau / 4)
      self:add(a)
    elseif t == 3 then
      Fighter.sideSquadron(10, 1)
      Dart.firingSquad(5, 0.6, 3)
    elseif t == 4 then
      Pawn.circle(10, 50, love.graphics.width / 4)
      Pawn.circle(10, 50, love.graphics.width * .75)
      Fighter.sideSquadron(3, 1)
    end
    
    if r < 10 then
      if r % 3 == 0 then
        self.wait = "enemies"
      else
        self.wait = 8
      end
      
      return 2, 1
    else
      self.wait = "enemies"
      return 3, 0
    end
  elseif i == 3 then
    local t = math.random(1, 3)
    
    self:add(Cannon:new(love.graphics.width * .25, nil, 100))
    self:add(Cannon:new(love.graphics.width * .5, nil, 100))
    self:add(Cannon:new(love.graphics.width * .75, nil, 100))
    
    if math.random(1, 2) == 1 then
      Pawn.crissCross(8, 0.7)
    else
      Dart.firingSquad(5, 0.6, 2)
    end
    
    if t == 1 then
      Fighter.sideSquadron(5, 1)
    elseif t == 2 then
      Fighter.line(4)
    elseif t == 3 then
      Fighter.circle(8, 60)
    end
    
    if r < 3 then
      self.wait = 8
      return 3, 1
    else
      self.wait = "enemies"
      return 4, 0
    end
  elseif i == 4 then
    self.bs = Battleship:new(love.graphics.width / 2, 5000)
    self:add(self.bs)
    return 5
  elseif i == 5 then
    if self.bs.dead then
      self.bs = nil
      return 2
    end
    
    local t = math.random(1, 4)
    
    if t == 1 then
      Fighter.sideSquadron(1, 1)
    elseif t == 2 then
      Dart.firingSquad(6, 0.5)
    elseif t == 3 then
      Dart.line(6)
    elseif t == 4 then
      Fighter.line(4, 100, false)
    end
    
    self.wait = 5
    return 5
  end
end
  
