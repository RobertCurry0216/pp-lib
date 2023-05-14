-- based on - https://github.com/kyleconroy/lua-state-machine

class("State").extends()

function State:init() end
function State:onenter(name, from, to, ...) end
function State:onleave(name, from, to, ...) end
function State:update() end


class("Machine").extends()

local function call_handler(handler, params)
  if handler then
    return handler(table.unpack(params))
  end
end

local function create_transition(name)
  local can, to, from, params

  local function transition(self, ...)
    can, to = self:can(name)
    from = self.currentName

    if type(to) == "function" then
      to = to(self, name, from)
    end

    params = { self, name, from, to, ...}

    if not can then return end

    local beforeReturn = call_handler(self["onbefore" .. name], params)
    if beforeReturn == false then return end

    local leaveReturn = self:current():onleave(table.unpack(params))
    if leaveReturn == false then return end

    self.currentName = to

    self:current():onenter(table.unpack(params))

    call_handler(self["onafter" .. name] or self["on" .. name], params)
    call_handler(self["onstatechange"], params)
    call_handler(self["onevent"], params)
  end

  return transition
end

local function add_to_map(map, event)
  if type(event.from) == 'string' then
    map[event.from] = event.to
  else
    for _, from in ipairs(event.from) do
      map[from] = event.to
    end
  end
end

function Machine:init(options)
  options = options or {}
  self.options = options
  self.currentName = options.initial or 'none'
  self.events = {}

  for _, event in ipairs(options.events or {}) do
    self:addEvent(event)
  end
  
  for name, callback in pairs(options.callbacks or {}) do
    self:addCallback(callback)
  end

  self.states = options.states or {}
end

function Machine:addEvent(event)
  local name = event.name
  self[name] = self[name] or create_transition(name)
  self.events[name] = self.events[name] or { map = {} }
  add_to_map(self.events[name].map, event)
end

function Machine:addCallback(name, callback)
  self[name] = callback
end

function Machine:addState(name, state)
  self.states[name] = state
  if self.currentName == 'none' then
    self.currentName = name
  end
end

function Machine:current()
  return self.states[self.currentName]
end

function Machine:is(state)
  return self.currentName == state
end

function Machine:can(e)
  local event = self.events[e]
  local to = event and event.map[self.currentName] or event.map['*']
  return to ~= nil, to
end

function Machine:cannot(e)
  return not self:can(e)
end

function Machine:get(name)
  return self.states[name]
end
