class("Trigger").extends(Actor)

function Trigger:init()
  Trigger.super.init(self)
  self:setGroups({Group.trigger})
end


function Trigger:perform() end
