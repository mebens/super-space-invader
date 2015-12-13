data = {}
data.file = "data"
data.hiscore = 0

function data.init()
  data.reset()
  
  if love.filesystem.exists(data.file) then
    local dataTable = loadstring(love.filesystem.read(data.file))()
    data.wave = dataTable.wave
    data.score = dataTable.score
    data.attack = dataTable.attack
    data.defence = dataTable.defence
    data.hiscore = dataTable.hiscore
  end
end

function data.reset()
  data.wave = 0
  data.score = 0
  data.attack = 0
  data.defence = 0
end

function data.save(wave, score, attack, defence)
  if wave then data.wave = wave end
  if attack then data.attack = attack end
  if defence then data.defence = defence end
  
  if score then
    data.score = score
    if score > data.hiscore then data.hiscore = score end
  end
  
  data.outputFile()
end

function data.outputFile()
  local code = "return { wave = " .. tostring(data.wave) .. ", "
  code = code .. "score = " .. tostring(data.score) .. ", "
  code = code .. "attack = " .. tostring(data.attack) .. ", "
  code = code .. "defence = " .. tostring(data.defence) .. ", "
  code = code .. "hiscore = " .. tostring(data.hiscore) .. " }"
  love.filesystem.write(data.file, code)
end

function data.saveHiscore(score)
  if score > data.hiscore then
    data.hiscore = score
    data.outputFile()
  end
end
