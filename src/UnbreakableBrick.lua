-- UnbreakableBrick.lua · ladrillo irrompible: la bola rebota pero nunca muere.
local Brick = require("src.Brick")

local UnbreakableBrick = setmetatable({}, { __index = Brick })
UnbreakableBrick.__index = UnbreakableBrick

local COLOR = { 0.45, 0.48, 0.56 }

function UnbreakableBrick.new(x, y, w, h, row)
    local self = Brick.new(x, y, w, h, row)
    return setmetatable(self, UnbreakableBrick)
end

-- POLIMORFISMO: recibe el golpe, no muere y no da puntos
function UnbreakableBrick:onHit()
    return 0
end

-- No cuenta para completar el nivel (si no, el nivel sería imposible)
function UnbreakableBrick:isBreakable()
    return false
end

function UnbreakableBrick:getColor()
    return COLOR
end

-- Reutiliza el dibujo del padre y le suma un borde para distinguirlo
function UnbreakableBrick:draw()
    Brick.draw(self)
    love.graphics.setColor(1, 1, 1, 0.55)
    love.graphics.rectangle("line", self.x + 1, self.y + 1, self.w - 2, self.h - 2, 3, 3)
end

return UnbreakableBrick
