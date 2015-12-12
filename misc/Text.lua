Text = class("Text")
Text._mt = {}

function Text._mt:__index(key)
  return rawget(self, "_" .. key) or self.class.__instanceDict[key]
end

function Text._mt:__newindex(key, value)
  if key == "text" then
    self._text = value
    if self._font then self._fontWidth = self._font:getWidth(value) end
  elseif key == "font" then
    self._font = value
    self:_setFontValues()
  elseif key == "lineHeight" then
    self._lineHeight = value
    self._font:setLineHeight(value)
  else
    rawset(self, key, value)
  end
end
  
function Text:initialize(t)
  self.x = t.x or 0
  self.y = t.y or 0
  self.align = t.align or "left"
  self.width = t.width or love.graphics.width
  self.color = t.color or { 255, 255, 255, 255 }
  self._text = t[1] or t.text or ""
    
  if t.font then
    self._font = t.font
    self:_setFontValues()
  end
  
  self:applyAccessors()
end

function Text:draw(x, y)
  local prevFont = love.graphics.getFont()
  if self._font then love.graphics.setFont(self._font) end
  love.graphics.storeColor()
  love.graphics.setColor(self.color)
  love.graphics.printf(self._text, x or self.x, y or self.y, self.width, self.align)
  love.graphics.resetColor()
  if prevFont then love.graphics.setFont(prevFont) end
end

function Text:_setFontValues()
  self._lineHeight = self._font:getLineHeight()
  self._fontWidth = self._font:getWidth(self._text)
  self._fontHeight = self._font:getHeight()
end
