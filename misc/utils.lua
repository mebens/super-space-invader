function playSound(sound, volume, pan)
  if type(sound) == "string" then sound = assets.sfx[sound] end
  return sound:play(volume, pan)
end

function playRandom(sounds, volume, pan)
  return playSound(sounds[math.random(1, #sounds)], volume, pan)
end

function Entity:drawImage(image, x, y, color, ox, oy)
  image = image or self.image
  color = color or self.color
  if color then love.graphics.setColor(color) end
  local imageScale = self.imageScale or 2
  local scale = imageScale * self.scale
  angle = self.angle
  if self.drawPerpAngle then angle = angle + math.tau / 4 end

  love.graphics.draw(
    image,
    x or self.x,
    y or self.y,
    angle,
    scale,
    scale,
    ox or image:getWidth() / 2,
    oy or image:getHeight() / 2
  )
end

function Entity:drawMap(map, x, y, color, ox, oy)
  map = map or self.map
  color = color or self.color
  angle = self.angle
  if self.drawPerpAngle then angle = angle + math.tau / 4 end
  if color then love.graphics.setColor(color) end
  local imageScale = self.imageScale or 2
  local scale = imageScale * self.scale
  map:draw(x or self.x, y or self.y, angle, scale, scale, ox or map.width / 2, oy or map.height / 2)
end
