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
require("entities.Battleship")
require("entities.BattleshipShot")
require("entities.BattleshipGuns")
require("entities.Anchor")
require("entities.Background")
require("worlds.Game")

TILE_SIZE = 9 

function love.load()
  assets.loadFont("square.ttf", { 70, 24, 18, 12, 8 }, "main")
  assets.loadShader("noise.frag")
  assets.loadShader("bloom.frag")
  
  assets.loadImage("pawn.png")
  assets.loadImage("fighter.png")
  assets.loadImage("dart.png")
  assets.loadImage("cannon.png")
  assets.loadImage("battleship.png")
  assets.loadImage("battleship-gun.png", "battleshipGun")
  assets.loadImage("player.png")
  assets.loadImage("gun.png")
  assets.loadImage("shield.png")
  assets.loadImage("missile.png")
  assets.loadImage("health-icon.png", "healthIcon")
  assets.loadImage("shield-icon.png", "shieldIcon")
  assets.loadImage("clock-icon.png", "clockIcon")
  for _, v in pairs(assets.images) do v:setFilter("nearest", "nearest") end
  
  assets.loadSfx("player-engine.ogg", 0.5)
  assets.loadSfx("cannon-engine.ogg", 0.2)
  assets.loadSfx("cannon-shot1.ogg")
  assets.loadSfx("cannon-shot2.ogg")
  assets.loadSfx("cannon-shot3.ogg")
  assets.loadSfx("dart-engine.ogg")
  assets.loadSfx("fire-missile1.ogg")
  assets.loadSfx("fire-missile2.ogg")
  assets.loadSfx("missile-engine.ogg")
  assets.loadSfx("hit1.ogg")
  assets.loadSfx("hit2.ogg")
  assets.loadSfx("hit3.ogg")
  assets.loadSfx("shoot1.ogg", 0.5)
  assets.loadSfx("shoot2.ogg", 0.5)
  assets.loadSfx("shoot3.ogg", 0.5)
  assets.loadSfx("shoot4.ogg", 0.5)
  assets.loadSfx("shoot5.ogg", 0.5)
  assets.loadSfx("large-explosion1.ogg")
  assets.loadSfx("large-explosion2.ogg")
  assets.loadSfx("large-explosion3.ogg")
  assets.loadSfx("large-explosion4.ogg")
  assets.loadSfx("small-explosion1.ogg")
  assets.loadSfx("small-explosion2.ogg")
  assets.loadSfx("small-explosion3.ogg")
  assets.loadSfx("small-explosion4.ogg")
  assets.loadSfx("small-explosion5.ogg")
  assets.loadSfx("select1.ogg")
  assets.loadSfx("select2.ogg")
  assets.loadSfx("selecting.ogg")
  assets.loadSfx("make-selection.ogg", 0.7)
  assets.loadSfx("shield-running.ogg", 1.5)
  assets.loadSfx("shield-hit1.ogg", 0.7)
  assets.loadSfx("shield-hit2.ogg", 0.7)
  assets.loadSfx("voice-shield-ready.ogg", 0.7)
  assets.loadSfx("voice-shield-broken.ogg", 0.8)
  assets.loadSfx("voice-1.ogg", 0.4)
  assets.loadSfx("voice-2.ogg", 0.4)
  assets.loadSfx("voice-3.ogg", 0.4)
  
  assets.loadMusic("menu.mp3")
  assets.loadMusic("wave.mp3")

  input.define{"left", key = { "left", "a" }, mouse = "l"}
  input.define{"right", key = { "right", "d" }, mouse = "r"}
  input.define("select", "return", " ")
  input.define("quit", "q")
  input.define("pause", "p")
  
  postfx.init()
  postfx.scale = 2
  postfx.add(bloom)
  postfx.add(noise)
  
  data.init()
  love.graphics.width = love.graphics.width / 2
  love.graphics.height = love.graphics.height / 2
  love.mouse.setVisible(false)
  ammo.world = Game:new()
  
  paused = false
end

function love.update(dt)
  if paused then return end

  postfx.update(dt)
  ammo.update(dt)
  if input.released("quit") then love.event.quit() end
  input.update(dt)
end

function love.draw()
  postfx.start()
  ammo.draw()
  postfx.stop()
  
  if paused then
    love.graphics.setFont(assets.fonts.main[24])
    love.graphics.printf("Paused", 0, love.graphics.height, love.graphics.width * 2, "center")
  end
end

function love.keypressed(key)
  input.keypressed(key)
  if key == "p" then paused = not paused end
end
