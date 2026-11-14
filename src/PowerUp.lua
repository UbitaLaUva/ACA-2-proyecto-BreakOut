-- PowerUp.lua · objeto que cae de un ladrillo destruido. Si la paleta lo atrapa,
-- aplica su efecto. El efecto es una FUNCIÓN guardada en el objeto: el power-up
-- no necesita saber qué hace, solo la ejecuta.
local PowerUp = {}
PowerUp.__index = PowerUp

local SIZE = 18
local FALL_SPEED = 150

-- Catálogo de power-ups. Uno nuevo = una entrada nueva.
local KINDS = {
    {   -- paleta ancha
        label = "W",
        color = { 0.35, 0.85, 1.00 },
        effect = function(game) game:widenPaddle() end,
    },
    {   -- vida extra
        label = "+",
        color = { 1.00, 0.45, 0.60 },
        effect = function(game) game:addLife() end,
    },
}

function PowerUp.new(centerX, centerY, kind)
    local self = setmetatable({}, PowerUp)
    -- Caja pública para las colisiones AABB
    self.w, self.h = SIZE, SIZE
    self.x = centerX - SIZE / 2
    self.y = centerY - SIZE / 2
    -- Estado interno
    self._label = kind.label
    self._color = kind.color
    self._effect = kind.effect
    return self
end

-- Crea un power-up de un tipo al azar
function PowerUp.random(centerX, centerY)
    local kind = KINDS[love.math.random(#KINDS)]
    return PowerUp.new(centerX, centerY, kind)
end

function PowerUp:update(dt)
    self.y = self.y + FALL_SPEED * dt
end

function PowerUp:applyTo(game)
    self._effect(game)
end

function PowerUp:draw()
    love.graphics.setColor(self._color)
    love.graphics.rectangle("fill", self.x, self.y, self.w, self.h, 5, 5)
    love.graphics.setColor(0.06, 0.07, 0.12)
    love.graphics.printf(self._label, self.x, self.y + 1, self.w, "center")
end

return PowerUp
