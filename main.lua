require("lib.ammo")
require("lib.physics")
require("lib.assets")
require("lib.input")
require("lib.tweens")
require("lib.gfx")

slaxml = require("slaxdom")
require("misc.xmlUtils")

require("entities.Player")
require("entities.Building")
require("worlds.Running")

TILE_SIZE = 9 

function love.load()
  assets.loadFont("uni05.ttf", { 24, 16, 8 }, "main")
  
  input.define("jump", " ", "up", "z")
  input.define("shoot", "left", "x")
  input.define("pause", "p")
  
  postfx.init()
  postfx.scale = 2
  
  love.graphics.width = love.graphics.width / 2
  love.graphics.height = love.graphics.height / 2
  love.mouse.setVisible(false)
  ammo.world = Running:new()
end

function love.update(dt)
  postfx.update(dt)
  ammo.update(dt)
  input.update(dt)
end

function love.draw()
  postfx.start()
  ammo.draw()
  postfx.stop()
end

