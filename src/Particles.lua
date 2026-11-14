-- Particles.lua · chispas que saltan cuando se rompe un ladrillo.
local Particles = {}
Particles.__index = Particles

local LIFETIME = 0.5     -- segundos que vive cada partícula
local GRAVITY = 500
local SIZE = 4

function Particles.new()
    local self = setmetatable({}, Particles)
    self._list = {}
    return self
end

-- Crea 'count' partículas en (x, y) que salen disparadas en direcciones al azar
function Particles:burst(x, y, color, count)
    for _ = 1, count or 12 do
        local angle = love.math.random() * 2 * math.pi
        local speed = 60 + love.math.random() * 160
        table.insert(self._list, {
            x = x,
            y = y,
            vx = math.cos(angle) * speed,
            vy = math.sin(angle) * speed,
            life = LIFETIME,
            color = color,
        })
    end
end

function Particles:update(dt)
    -- Se recorre de atrás hacia adelante para poder borrar sin saltarse elementos
    for i = #self._list, 1, -1 do
        local p = self._list[i]
        p.vy = p.vy + GRAVITY * dt
        p.x = p.x + p.vx * dt
        p.y = p.y + p.vy * dt
        p.life = p.life - dt
        if p.life <= 0 then
            table.remove(self._list, i)
        end
    end
end

function Particles:draw()
    for _, p in ipairs(self._list) do
        -- la transparencia baja a medida que se le acaba la vida
        love.graphics.setColor(p.color[1], p.color[2], p.color[3], p.life / LIFETIME)
        love.graphics.rectangle("fill", p.x - SIZE / 2, p.y - SIZE / 2, SIZE, SIZE)
    end
end

return Particles
