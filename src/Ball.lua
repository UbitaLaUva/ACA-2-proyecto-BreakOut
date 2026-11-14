-- Ball.lua · la bola. Solo sabe moverse y rebotar: NO conoce a la paleta
-- ni a los ladrillos. Quien le dice cuándo y cómo rebotar es Game.
local Ball = {}
Ball.__index = Ball

-- Ángulo máximo de salida (medido desde la vertical) al pegar en el borde de la paleta
local MAX_ANGLE = math.rad(60)

function Ball.new(size)
    local self = setmetatable({}, Ball)
    -- Caja pública para las colisiones AABB (por eso w y h en vez de radius)
    self.x, self.y = 0, 0
    self.w, self.h = size, size
    -- Estado interno: nadie de afuera toca la velocidad directamente
    self._vx, self._vy = 0, 0
    self._speed = 300
    return self
end

function Ball:setSpeed(speed)
    self._speed = speed
end

function Ball:getSpeed()
    return self._speed
end

function Ball:getCenter()
    return self.x + self.w / 2, self.y + self.h / 2
end

function Ball:isMovingDown()
    return self._vy > 0
end

-- Deja la bola quieta, centrada en centerX y apoyada sobre la altura surfaceY
function Ball:restOn(centerX, surfaceY)
    self.x = centerX - self.w / 2
    self.y = surfaceY - self.h
    self._vx, self._vy = 0, 0
end

-- Sale hacia arriba con un ángulo que depende de t:
-- t = -1 (60° a la izquierda) · t = 0 (recto hacia arriba) · t = 1 (60° a la derecha)
-- La rapidez total siempre es _speed; solo cambia la dirección.
function Ball:launch(t)
    local angle = t * MAX_ANGLE
    self._vx = self._speed * math.sin(angle)
    self._vy = -self._speed * math.cos(angle)
end

-- Rebote en la paleta: se reubica encima de la superficie y sale con ángulo t
function Ball:deflect(t, surfaceY)
    self.y = surfaceY - self.h
    self:launch(t)
end

-- Rebote contra bordes y ladrillos.
-- axis = "x" o "y" · push = píxeles para sacarla del obstáculo (con signo).
-- La velocidad queda apuntando hacia donde fue empujada, así nunca se queda pegada.
function Ball:bounce(axis, push)
    local direction = (push > 0) and 1 or -1
    if axis == "x" then
        self.x = self.x + push
        self._vx = direction * math.abs(self._vx)
    else
        self.y = self.y + push
        self._vy = direction * math.abs(self._vy)
    end
end

-- Movimiento: posición = posición + velocidad × dt
function Ball:update(dt)
    self.x = self.x + self._vx * dt
    self.y = self.y + self._vy * dt
end

function Ball:draw()
    local cx, cy = self:getCenter()
    love.graphics.setColor(1, 1, 1)
    love.graphics.circle("fill", cx, cy, self.w / 2)
end

return Ball
