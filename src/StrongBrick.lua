-- StrongBrick.lua · ladrillo resistente: aguanta 2 golpes.
-- HERENCIA: todo lo que no esté definido aquí se busca en Brick.
local Brick = require("src.Brick")

local StrongBrick = setmetatable({}, { __index = Brick })
StrongBrick.__index = StrongBrick

local COLOR_INTACT = { 0.62, 0.42, 0.98 }
local COLOR_DAMAGED = { 0.82, 0.72, 1.00 }

function StrongBrick.new(x, y, w, h, row)
    local self = Brick.new(x, y, w, h, row)   -- 1) lo construye el padre
    self._hp = 2                              -- 2) se agrega lo propio
    return setmetatable(self, StrongBrick)    -- 3) se re-etiqueta como StrongBrick
end

-- POLIMORFISMO: misma firma que Brick:onHit(), otra conducta
function StrongBrick:onHit()
    self._hp = self._hp - 1
    if self._hp <= 0 then self._dead = true end
    return 20
end

-- Cambia de color cuando ya recibió un golpe (Brick:draw() usa este método)
function StrongBrick:getColor()
    if self._hp >= 2 then return COLOR_INTACT end
    return COLOR_DAMAGED
end

return StrongBrick
