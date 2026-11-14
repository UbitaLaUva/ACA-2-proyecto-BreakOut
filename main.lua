-- main.lua · punto de entrada. LÖVE busca aquí las funciones love.*
-- No es una clase y no contiene lógica del juego: solo conecta LÖVE con Game.
local Game = require("src.Game")

local game

-- Se ejecuta una sola vez al abrir el juego
function love.load()
    game = Game.new()
end

-- 1) ENTRADA: una tecla fue presionada
function love.keypressed(key)
    game:handleInput(key)
end

-- 2) ACTUALIZACIÓN: dt = segundos que pasaron desde el frame anterior
function love.update(dt)
    game:update(dt)
end

-- 3) RENDER: solo dibuja, nunca mueve nada
function love.draw()
    game:draw()
end
