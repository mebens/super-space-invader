Missile = class("Missile", Entity)
Missile.static.width = 3
Missile.static.height = 12
Missile.static.all = LinkedList:new("_nextMissile", "_prevMissile")

function Missile:initialize(x, y)
  Entity.initialize(self, x, y)
  self.angle = math.tau * .75
  self.speed = 300
  self.damage = 150
  self.width = Missile.width
  self.height = Missile.height
end

function Missile:added()
  Missile.all:push(self)
  self.shape = HC.rectangle(self.x - self.width / 2, self.y - self.height / 2, self.width, self.height)
end

function Missile:removed()
  Missile.all:remove(self)
  HC.remove(self.shape)
end

function Missile:update(dt)
  if self.target then
  end
end
