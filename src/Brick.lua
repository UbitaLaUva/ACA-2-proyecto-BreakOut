-- Brick.lua · CLASE BASE de los ladrillos. Es el ladrillo normal: muere de un golpe.
-- Los subtipos (StrongBrick, UnbreakableBrick) heredan de aquí y sobrescriben
-- solo lo que cambia.
local Brick = {}
Brick.__index = Brick

-- Un color por fila para que el nivel se vea ordenado
local ROW_COLORS = {
    { 1.00, 0.36, 0.42 },
    { 1.00, 0.62, 0.26 },
    { 1.00, 0.86, 0.30 },
    { 0.36, 0.90, 0.56 },
    { 0.30, 0.72, 1.00 },
}

function Brick.new(x, y, w, h, row)
    local self = setmetatable({}, Brick)
    -- Caja pública para las colisiones AABB
    self.x, self.y, self.w, self.h = x, y, w, h
    -- Estado interno (guion bajo = "no me toques desde afuera")
    self._dead = false
    self._color = ROW_COLORS[((row or 1) - 1) % #ROW_COLORS + 1]
    return self
end

-- La bola me golpeó. Cada tipo de ladrillo responde a su manera (polimorfismo).
-- Devuelve los puntos que otorga el golpe.
function Brick:onHit()
    self._dead = true
    return 10
end

function Brick:isDead()
    return self._dead
end

-- ¿Hay que destruirme para completar el nivel?
function Brick:isBreakable()
    return true
end

function Brick:getColor()
    return self._color
end

function Brick:getCenter()
    return self.x + self.w / 2, self.y + self.h / 2
end

function Brick:draw()
    if self._dead then return end
    love.graphics.setColor(self:getColor())
    love.graphics.rectangle("fill", self.x, self.y, self.w, self.h, 3, 3)
end

return Brick
