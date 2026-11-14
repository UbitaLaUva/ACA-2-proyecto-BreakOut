-- Paddle.lua · la paleta que controla el jugador.
local Paddle = {}
Paddle.__index = Paddle

local BASE_WIDTH = 100
local WIDE_WIDTH = 160     -- ancho con el power-up "paleta ancha"
local HEIGHT = 14
local SPEED = 480          -- píxeles por segundo
local TWEEN_SPEED = 10     -- qué tan rápido se anima el cambio de ancho

function Paddle.new(centerX, y)
    local self = setmetatable({}, Paddle)
    -- Caja pública para las colisiones AABB
    self.w, self.h = BASE_WIDTH, HEIGHT
    self.x = centerX - self.w / 2
    self.y = y
    -- Estado interno
    self._speed = SPEED
    self._targetWidth = BASE_WIDTH
    self._wideTimer = 0
    return self
end

function Paddle:moveLeft(dt)
    self.x = self.x - self._speed * dt
end

function Paddle:moveRight(dt)
    self.x = self.x + self._speed * dt
end

function Paddle:getCenterX()
    return self.x + self.w / 2
end

-- ¿En qué parte de la paleta pegó algo que está en pointX?
-- Devuelve t entre -1 (borde izquierdo), 0 (centro) y 1 (borde derecho).
function Paddle:impactFactor(pointX)
    local t = (pointX - self:getCenterX()) / (self.w / 2)
    return math.max(-1, math.min(1, t))
end

-- Power-up: ensancha la paleta durante 'seconds' segundos
function Paddle:widen(seconds)
    self._targetWidth = WIDE_WIDTH
    self._wideTimer = seconds
end

function Paddle:resetWidth()
    self._targetWidth = BASE_WIDTH
    self._wideTimer = 0
end

function Paddle:update(dt, areaWidth)
    -- 1) Entrada continua: isDown pregunta si la tecla ESTÁ presionada ahora
    if love.keyboard.isDown("left", "a") then self:moveLeft(dt) end
    if love.keyboard.isDown("right", "d") then self:moveRight(dt) end

    -- 2) Cuenta regresiva del power-up
    if self._wideTimer > 0 then
        self._wideTimer = self._wideTimer - dt
        if self._wideTimer <= 0 then self._targetWidth = BASE_WIDTH end
    end

    -- 3) Tween: el ancho se acerca poco a poco al ancho objetivo,
    --    manteniendo el centro en el mismo sitio
    local centerX = self:getCenterX()
    self.w = self.w + (self._targetWidth - self.w) * math.min(1, TWEEN_SPEED * dt)
    self.x = centerX - self.w / 2

    -- 4) No puede salirse de la pantalla
    self.x = math.max(0, math.min(areaWidth - self.w, self.x))
end

function Paddle:draw()
    love.graphics.setColor(0.35, 0.85, 1)
    love.graphics.rectangle("fill", self.x, self.y, self.w, self.h, 4, 4)
end

return Paddle
