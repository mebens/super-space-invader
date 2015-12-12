function collide(e1, e2)
  return e1.x + e1.width / 2 > e2.x - e2.width / 2
    and e1.x - e1.width / 2 < e2.x + e2.width / 2
    and e1.y + e1.height / 2 > e2.y - e2.height / 2
    and e1.y - e1.height / 2 < e2.y + e2.height / 2
end

function circleToRect(e1, e2)
  local pointInRect = e1.x >= e2.x - e2.width / 2
    and e1.x <= e2.x + e2.width / 2
    and e1.y >= e2.y - e2.height / 2
    and e1.y <= e2.y + e2.height / 2
end
