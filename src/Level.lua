-- Level.lua · un nivel: convierte los datos de data/levels.lua en objetos ladrillo
-- y es el dueño de esos ladrillos (composición: sin nivel no hay ladrillos).
local Brick = require("src.Brick")
local StrongBrick = require("src.StrongBrick")
local UnbreakableBrick = require("src.UnbreakableBrick")
local Collision = require("src.collision")

local Level = {}
Level.__index = Level

-- Qué clase corresponde a cada número de la matriz.
-- Un tipo nuevo de ladrillo = una línea nueva aquí, sin tocar el resto.
local BRICK_TYPES = {
    [1] = Brick,
    [2] = StrongBrick,
    [3] = UnbreakableBrick,
}

local BRICK_WIDTH = 70
local BRICK_HEIGHT = 22
local GAP = 6        -- separación entre ladrillos
local TOP = 70       -- altura donde empieza la primera fila

-- number = número de nivel · data = una entrada de data/levels.lua
function Level.new(number, data, areaWidth)
    local self = setmetatable({}, Level)
    self._number = number
    self._name = data.name
    self._ballSpeed = data.ballSpeed
    self._bricks = {}
    self:loadBricks(data.layout, areaWidth)
    return self
end

-- Recorre la matriz fila por fila y crea un ladrillo por cada número distinto de 0
function Level:loadBricks(layout, areaWidth)
    for row, columns in ipairs(layout) do
        -- centra la fila en la pantalla sin importar cuántas columnas tenga
        local rowWidth = #columns * BRICK_WIDTH + (#columns - 1) * GAP
        local left = (areaWidth - rowWidth) / 2

        for col, code in ipairs(columns) do
            local BrickClass = BRICK_TYPES[code]
            if BrickClass then
                local x = left + (col - 1) * (BRICK_WIDTH + GAP)
                local y = TOP + (row - 1) * (BRICK_HEIGHT + GAP)
                table.insert(self._bricks, BrickClass.new(x, y, BRICK_WIDTH, BRICK_HEIGHT, row))
            end
        end
    end
end

function Level:getNumber()
    return self._number
end

function Level:getName()
    return self._name
end

function Level:getBallSpeed()
    return self._ballSpeed
end

-- ¿Contra qué ladrillo vivo choca esta caja? Si toca dos a la vez (justo en la
-- unión), devuelve el que MÁS toca: así el rebote sale por el eje correcto.
function Level:findHit(box)
    local best, bestArea = nil, 0
    for _, brick in ipairs(self._bricks) do
        if not brick:isDead() and Collision.aabb(box, brick) then
            local ox, oy = Collision.overlap(box, brick)
            if ox * oy > bestArea then
                best, bestArea = brick, ox * oy
            end
        end
    end
    return best
end

-- El nivel termina cuando no queda ningún ladrillo rompible con vida
function Level:isCompleted()
    for _, brick in ipairs(self._bricks) do
        if brick:isBreakable() and not brick:isDead() then
            return false
        end
    end
    return true
end

function Level:draw()
    for _, brick in ipairs(self._bricks) do
        brick:draw()
    end
end

return Level
