function findChild(elem, name)
  for _, v in ipairs(elem.el) do
    if v.name == name then return v end
  end
end

function findChildren(elem, name)
  local ret = {}
  
  for _, v in ipairs(elem.el) do
    if v.name == name then ret[#ret + 1] = v end
  end
  
  return ret
end

function getText(elem, name)
  if name then elem = findChild(elem, name) end
  local ret
  
  for _, v in ipairs(elem.kids) do
    if v.type == "text" then ret = (ret or "") .. v.value end
  end
  
  return ret
end
