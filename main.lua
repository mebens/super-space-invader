require("lib.ammo")
require("lib.assets")
require("lib.input")
require("lib.tweens")
require("lib.gfx")
HC = require("lib.hc")

require("misc.utils")
require("misc.Text")
require("modules.bloom")
require("modules.noise")
require("modules.data")

require("entities.UI")
require("entities.HUD")
require("entities.Player")
require("entities.Bullet")
require("entities.Missile")
require("entities.Enemy")
require("entities.Pawn")
require("entities.Dart")
require("entities.Fighter")
require("entities.FighterBullet")
require("entities.Cannon")
require("entities.CannonShot")
require("entities.Anchor")
require("entities.Background")
require("entities.RageBuffer")
require("worlds.Game")

TILE_SIZE = 9 

function love.load()
  assets.loadFont("square.ttf", { 70, 24, 18, 12 }, "main")
  assets.loadShader("noise.frag")
  assets.loadShader("bloom.frag")
  
  assets.loadImage("pawn.png")
  assets.loadImage("fighter.png")
  assets.loadImage("dart.png")
  assets.loadImage("cannon.png")
  assets.loadImage("player.png")
  assets.loadImage("gun.png")
  assets.loadImage("shield.png")
  assets.loadImage("missile.png")
  for _, v in pairs(assets.images) do v:setFilter("nearest", "nearest") end
  
  input.define{"left", key = { "left", "a" }, mouse = "l"}
  input.define{"right", key = { "right", "d" }, mouse = "r"}
  input.define("select", "return", " ")
  
  postfx.init()
  postfx.scale = 2
  postfx.add(bloom)
  postfx.add(noise)
  
  data.init()
  love.graphics.width = love.graphics.width / 2
  love.graphics.height = love.graphics.height / 2
  love.mouse.setVisible(false)
  ammo.world = Game:new()
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
  
  love.graphics.setFont(assets.fonts.main[12])
  love.graphics.printf(love.timer.getFPS(), 4, 4, love.graphics.width * 2 - 8, "right")
end
