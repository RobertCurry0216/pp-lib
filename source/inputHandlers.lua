class("InputBase").extends()

function InputBase:init(actor)
  self._actor = actor
  self._jump_last_pressed = 0
  self._left = false
  self._right = false
  self.dx = 0
  self.jump = false
  self.jump_pressed = false
  self.jump_buffered = false
end

function InputBase:update() end

class("InputDPadAndA").extends(InputBase)

function InputDPadAndA:update()
  self._left=playdate.buttonIsPressed(playdate.kButtonLeft)
  self._right=playdate.buttonIsPressed(playdate.kButtonRight)
  self.jump=playdate.buttonIsPressed(playdate.kButtonA)
  self.jump_pressed=playdate.buttonJustPressed(playdate.kButtonA)

  if self.jump_pressed then
    self._jump_last_pressed = playdate.getCurrentTimeMilliseconds()
  end

  local time_since_jump = playdate.getCurrentTimeMilliseconds() - self._jump_last_pressed
  self.jump_buffered = time_since_jump < self._actor.jump_buffer_time

  self.dx = (self._right and 1 or 0) - (self._left and 1 or 0)
end