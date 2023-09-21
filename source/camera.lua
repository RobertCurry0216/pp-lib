local pd <const> = playdate
local gfx <const> = pd.graphics

local screen_width, screen_height = pd.display.getWidth(), pd.display.getHeight()
local center_x <const>, center_y <const> = screen_width / 2, screen_height / 2
local shake_x, shake_y = 0, 0
local shake_amount = 0
local shake_angle = 0
local offset_x, offset_y = 0, 0
local target = nil
local bounds = nil
local target_x_offset, target_y_offset = 0, 0
local lerp_amount = 0.15

local function clipBounds(x, y)
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

Camera = {}

function Camera.shake(_amount)
    shake_amount = _amount
end

function Camera.setTarget(_target, _x_offset, _y_offset, snap)
    target = _target
    target_x_offset = _x_offset or 0
    target_y_offset = _y_offset or 0

    if snap then
        offset_x = target.x - center_x
        offset_y = target.y - center_y
    elseif target == nil then
        gfx.setDrawOffset(0, 0)
    end
end

function Camera.setBounds(rect)
    bounds = rect
end

function Camera.update()
    -- Shaking is handled seperately
    if shake_amount > 0 then
        shake_angle = math.random() * math.pi * 2
        shake_x = math.floor(math.cos(shake_angle) * shake_amount)
        shake_y = math.floor(math.sin(shake_angle) * shake_amount)
        shake_amount -= 1
        playdate.display.setOffset(shake_x, shake_y)
    else
        playdate.display.setOffset(0, 0)
    end

    -- If there is no target, we don't have to check for bounds
    if target then
        offset_x += (target.x - offset_x - center_x) * lerp_amount
        offset_y += (target.y - offset_y - center_y) * lerp_amount
        local _offset_x, _offset_y = -offset_x + target_x_offset, -offset_y + target_y_offset
        if bounds ~= nil then
            _offset_x, _offset_y = clipBounds(_offset_x , _offset_y)
        end
        gfx.setDrawOffset(_offset_x, _offset_y)
        gfx.sprite.redrawBackground()
    end
end
