local pd <const> = playdate
local gfx <const> = pd.graphics

local screen_width <const>, screen_height <const> = pd.display.getWidth(), pd.display.getHeight()
local center_x <const>, center_y <const> = screen_width / 2, screen_height / 2

local function merge_configs(d, c)
  for k,v in pairs(d) do
    if c[k] == nil then
      c[k] = d[k]
    end
  end
  return c
end

local function clipBounds(bounds, x, y)
  local _x, _y = x, y
  if x > -bounds.x then
    _x = -bounds.x
  elseif _x - screen_width < -bounds.x - bounds.width then
    _x = -bounds.x - bounds.width + screen_width
  end

  if y > -bounds.y then
    _y = -bounds.y
  elseif _y - screen_height < -bounds.y - bounds.height then
    _y = -bounds.y - bounds.height + screen_height
  end

  return _x, _y
end

-- follow functions

-- lock
local _lock_config <const> = {
  target_x_offset = center_x,
  target_y_offset = center_y,
  lerp = 0.2
}

local function _lock(self, lerp_override)
  local target = self.target
  local config = self.config
  local lerp = lerp_override or config.lerp
  if target then
    self.offset_x += (target.x - config.target_x_offset - self.offset_x) * lerp
    self.offset_y += (target.y - config.target_y_offset - self.offset_y) * lerp
    return -self.offset_x, -self.offset_y
  end
  return -self.offset_x, -self.offset_y
end


-- box
local _box_config <const> = {
  top = 100,
  bottom = 180,
  left = 150,
  right = 250,
  lerp = 0.2
}

local function _constrain_x(cam, left, right, lerp)
  local target = cam.target
  local config = cam.config
  if target then
    if target.x < left then
      cam.offset_x += (target.x - left) * lerp
    elseif target.x > right then
      cam.offset_x += (target.x - right) * lerp
    end
  end
  return cam.offset_x
end

local function _constrain_y(cam, top, bottom, lerp)
  local target = cam.target
  local config = cam.config
  if target then
    if target.y < top then
      cam.offset_y += (target.y - top) * lerp
    elseif target.y > bottom then
      cam.offset_y += (target.y - bottom) * lerp
    end
  end
  return cam.offset_y
end

local function _box(self, lerp_override)
  local target = self.target
  local config = self.config
  local lerp = lerp_override or config.lerp
  if target then
    self.offset_x = _constrain_x(self, self.offset_x + config.left, self.offset_x + config.right, lerp)
    self.offset_y = _constrain_y(self, self.offset_y + config.top, self.offset_y + config.bottom, lerp)
  end
  return -self.offset_x, -self.offset_y
end

-- hlock
local _hlock_config <const> = {
  target_x_offset = center_x,
  top = 100,
  bottom = 180,
  lerp = 0.2
}

local function _hlock(self, lerp_override)
  local target = self.target
  local config = self.config
  local lerp = lerp_override or config.lerp
  if target then
    self.offset_x += (target.x - config.target_x_offset - self.offset_x) * lerp
    self.offset_y = _constrain_y(self, self.offset_y + config.top, self.offset_y + config.bottom, lerp)
    return -self.offset_x, -self.offset_y
  end
  return -self.offset_x, -self.offset_y
end

-- look ahead

local _lookahead_config <const> = {
  look_distance = 60,
  top = 100,
  bottom = 180,
  lerp = 0.1
}

local function _lookahead(self, lerp_override)
  local target = self.target
  local config = self.config
  local lerp = lerp_override or config.lerp
  if target then
    local look = config.look_distance
    if target._image_flip ~= playdate.graphics.kImageUnflipped then
      look = look * -1
    end
    self.offset_x += (target.x - center_x + look - self.offset_x) * lerp
    self.offset_y = _constrain_y(self, self.offset_y + config.top, self.offset_y + config.bottom, lerp)
    return -self.offset_x, -self.offset_y
  end
  return -self.offset_x, -self.offset_y
end

-- Camera class

class("FollowCamera").extends()

CameraMode = {
  lock = "lock",
  hlock = "hlock",
  box = "box",
  look_ahead = "look_ahead"
}

function FollowCamera:init(mode, config)
  -- std params
  self.target = nil
  self.bounds = nil
  self.offset_x = 0
  self.offset_y = 0

  -- shake params
  self._shake_amount = 0
  self._shake_decay = 0
  self._shake_time = 0

  -- config
  self:setMode(mode, config)
end

function FollowCamera:setMode(mode, config)
  mode = mode or CameraMode.hlock
  self.mode = mode
  if mode == CameraMode.lock then
    self._updateFollow = _lock
    self.config = merge_configs(_lock_config, config or {})
  elseif mode == CameraMode.box then
    self._updateFollow = _box
    self.config = merge_configs(_box_config, config or {})
  elseif mode == CameraMode.hlock then
    self._updateFollow = _hlock
    self.config = merge_configs(_hlock_config, config or {})
  elseif mode == CameraMode.look_ahead then
    self._updateFollow = _lookahead
    self.config = merge_configs(_lookahead_config, config or {})
  else
    assert(false, "invalid camera mode provided: "..tostring(mode))
  end
end

function FollowCamera:shake(amount, time)
  self._shake_amount = amount
  self._shake_time = time or amount
  self._shake_decay = self._shake_amount / self._shake_time
end

function FollowCamera:setTarget(target, ignore_snap)
  self.target = target
  if ignore_snap == true then return end

  -- snap camera to player
  self:_updateFollow(1)
end

function FollowCamera:clearTarget()
  self.target = nil
end

function FollowCamera:setBounds(bounds)
  if type(bounds.getBoundsRect) == "function" then
    rect = bounds:getBoundsRect()
  else
    rect = bounds
  end
  self.bounds = rect
end

function FollowCamera:_updateShake()
  if self._shake_time > 0 then
    local shake_amount = self._shake_amount
    local shake_angle = math.random() * math.pi * 2
    local shake_x = math.floor(math.cos(shake_angle) * shake_amount)
    local shake_y = math.floor(math.sin(shake_angle) * shake_amount)
    self._shake_time -= 1
    self._shake_amount -= self._shake_decay
    return shake_x, shake_y
  end
  return 0, 0
end

function FollowCamera:update()
  local _shake_x, _shake_y = self:_updateShake()
  local _offset_x, _offset_y = self:_updateFollow()
  if self.bounds ~= nil then
    _offset_x, _offset_y = clipBounds(self.bounds, _offset_x , _offset_y)
  end
  gfx.setDrawOffset(_offset_x + _shake_x, _offset_y + _shake_y)
end
