bloom = {}
bloom.active = true

function bloom:init()
  self.supported = postfx.fxSupported
  self.effect = assets.shaders.bloom
  if self.supported then self:reset() end
end

function bloom:draw(canvas)
  love.graphics.setCanvas(postfx.alternate)
  love.graphics.setColor(0, 0, 0)
  love.graphics.rectangle("fill", 0, 0, love.graphics.width, love.graphics.height)
  love.graphics.setColor(255, 255, 255)
  love.graphics.draw(canvas, 0, 0)
  postfx.swap()
  
  love.graphics.setCanvas(postfx.alternate)
  love.graphics.setShader(self.effect)
  love.graphics.draw(postfx.canvas, 0, 0)
  love.graphics.setShader()
  postfx.swap()
end

function bloom:reset()
  self.effect:send("size", { love.graphics.width, love.graphics.height })
end
