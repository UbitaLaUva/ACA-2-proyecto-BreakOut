-- Shake.lua · sacudida de pantalla (screen shake).
-- Calcula un desplazamiento al azar que se va apagando con el tiempo.
local Shake = {}
Shake.__index = Shake

function Shake.new()
    local self = setmetatable({}, Shake)
    self._time = 0          -- segundos que le quedan a la sacudida
    self._duration = 1
    self._magnitude = 0     -- píxeles máximos de desplazamiento
    self._offsetX, self._offsetY = 0, 0
    return self
end

function Shake:start(duration, magnitude)
    self._time = duration
    self._duration = duration
    self._magnitude = magnitude
end

-- El desplazamiento se calcula aquí (en update), no al dibujar
function Shake:update(dt)
    if self._time <= 0 then
        self._offsetX, self._offsetY = 0, 0
        return
    end
    self._time = math.max(0, self._time - dt)
    local strength = self._magnitude * (self._time / self._duration)
    self._offsetX = (love.math.random() * 2 - 1) * strength
    self._offsetY = (love.math.random() * 2 - 1) * strength
end

function Shake:getOffset()
    return self._offsetX, self._offsetY
end

return Shake
