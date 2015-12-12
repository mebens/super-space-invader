data = {}
data.file = "data"

function data.init()
  data.reset()
  
  if love.filesystem.exists(data.file) then
    local dataTable = loadstring(love.filesystem.read(data.file))()
    data.wave = dataTable.wave
    data.attack = dataTable.attack
    data.defence = dataTable.defence
  end
end

function data.reset()
  data.wave = 0
  data.attack = 0
  data.defence = 0
end

function data.save(wave, attack, defence)
  if wave then data.wave = wave end
  if attack then data.attack = attack end
  if defence then data.defence = defence end
  
  local code = "return { wave = " .. tostring(data.wave) .. ", "
  code = code .. "attack = " .. tostring(data.attack) .. ", "
  code = code .. "defence = " .. tostring(data.defence) .. " }"
  love.filesystem.write(data.file, code)
end
