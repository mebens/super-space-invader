Game = class("Game", World)

function Game:initialize()
  World.initialize(self)
  self.player = Player:new()
  self.ui = UI:new()
  self.hud = HUD:new()
  self.bg = Background:new()
  self:add(self.player, self.ui, self.hud, self.bg)
  
  self.wait = 0
  self.repetitions = 0
  self.inWave = false
  self:setupLayers{
    [1] = { 1, pre = postfx.exclude, post = postfx.include }, -- UI
    [2] = 1, -- particles
    [3] = 1, -- player / enemies
    [4] = 1, -- bullets
    [6] = 1 -- background
  }
end

function Game:start()
  for v in self._layers[1]:iterate() do print(v) end
  self.ui:welcome()
end

function Game:update(dt)
  World.update(self, dt)
  
  if self.inWave then
    if self.wait == "enemies" then
      if Enemy.all.length == 0 then self.wait = 0 end
    elseif self.wait > 0 then
      self.wait = self.wait - dt
    else
      local index, rep = self["wave" .. self.waveNum](self, self.waveIndex, self.repetitions)
      
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
  self.ui:display(1, "Wave " .. num, function()
    self.ui:startCountdown(function()
      self.inWave = true
      self.waveIndex = 1
      self.waveNum = num
      self.player:reset()
    end)
  end)
end

function Game:nextWave()
  if self["wave" .. (self.waveNum + 1)] then
    self:startWave(self.waveNum + 1)
  end
end

function Game:endWave()
  self.inWave = false
  self.ui:upgrades()
end

function Game:completeUpgrade(attack, defence)
  if attack then self.player.attackLvl = attack end
  if defence then self.player.defenceLvl = defence end
  self.player:applyLevels()
  data.save(self.waveNum + 1, self.player.attackLvl, self.player.defenceLvl)
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
    Pawn.crissCross(3, 0.5)
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
    
    if r < 9 then
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
    
    if r < 3 then
      return 2, 1
    else
      return 3, 0
    end
  elseif i == 3 then
    Pawn.circle(10, 60, love.graphics.width / 2)
    return 4
  elseif i == 4 then
    Dart.firingSquad(5, 0.5, 1)
    
    if r < 3 then
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
  
