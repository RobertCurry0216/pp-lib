class("Solid").extends(Actor)

function Solid:init(x, y)
  Solid.super.init(self)
  self.mask = 0x1111
  self:setGroups({Group.solid})
end

function Solid:isSolid()
  return self.mask == 0x1111
end

function Solid:setSidePassthrough(side, passable)
  if passable then
    self.mask = self.mask & ~side
  else
    self.mask = self.mask | side
  end
end

function Solid:getSidePassthrough(side)
  return (self.mask & side) == 0
end

function Solid:stops(actor, col)
  if self:isSolid() then return true end

  -- only check on first frame of overlap
  if col.overlaps then return false end

  local x, y = col.normal.x, col.normal.y
  return (
    (x > 0 and not self:getSidePassthrough(Side.right) ) or
    (x < 0 and not self:getSidePassthrough(Side.left)) or
    (y > 0 and not self:getSidePassthrough(Side.bottom)) or
    (y < 0 and not self:getSidePassthrough(Side.top))
  )
end

function Solid:resolveCollision(actor, col)
  -- if fully solid let bump handle it
  if self:isSolid() then return end

  local bx, by, bw, bh = actor:getCollideBounds()
  local ax, ay, aw, ah = actor:getBounds()
  local tx, ty = col.touch.x, col.touch.y
  local cx, cy = self:getCenter()

  local horiz = col.normal.x == 0 and 0 or 1
  local vert = col.normal.y == 0 and 0 or 1

  actor:moveBy((tx-ax-bx-(self.width*cx))*horiz, (ty-ay-by-(self.height*cy))*vert)
end


function Solid.addEmptyCollisionSprite(x, y, w, h)
  local solid = Solid()
  solid:setSize(w, h)
  solid:setCenter(0,0)
  solid:moveTo(x, y)
  solid:setCollideRect(0,0,w,h)
  solid:setVisible(false)
  solid:setUpdatesEnabled(false)
  return solid
end