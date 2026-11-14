-- UI.lua · todo el texto que se ve en pantalla pasa por aquí.
-- Game le entrega los datos (puntaje, vidas, mensaje) y UI decide cómo mostrarlos.
local UI = {}
UI.__index = UI

local MARGIN = 16
local HUD_Y = 14

function UI.new()
    local self = setmetatable({}, UI)
    self._bigFont = love.graphics.newFont(44)
    self._midFont = love.graphics.newFont(20)
    self._smallFont = love.graphics.newFont(15)
    love.graphics.setFont(self._smallFont)   -- fuente por defecto del juego
    return self
end

function UI:drawScore(score)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Puntos: " .. score, MARGIN, HUD_Y)
end

function UI:drawLives(lives)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Vidas: " .. lives, 0, HUD_Y, love.graphics.getWidth() - MARGIN, "right")
end

function UI:drawLevel(number, name)
    love.graphics.setColor(0.7, 0.75, 0.9)
    love.graphics.printf("Nivel " .. number .. " · " .. name, 0, HUD_Y, love.graphics.getWidth(), "center")
end

-- Texto pequeño de ayuda en la parte baja de la pantalla
function UI:drawHint(text)
    local width, height = love.graphics.getDimensions()
    love.graphics.setColor(0.7, 0.75, 0.9)
    love.graphics.printf(text, 0, height - 28, width, "center")
end

-- Oscurece lo que haya detrás para que el mensaje se lea bien
function UI:drawOverlay()
    local width, height = love.graphics.getDimensions()
    love.graphics.setColor(0.03, 0.04, 0.08, 0.72)
    love.graphics.rectangle("fill", 0, 0, width, height)
end

-- Mensaje grande centrado (título, pausa, game over, victoria...)
function UI:drawMessage(title, subtitle)
    local width, height = love.graphics.getDimensions()
    local y = height * 0.36

    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(self._bigFont)
    love.graphics.printf(title, 0, y, width, "center")

    love.graphics.setColor(0.7, 0.75, 0.9)
    love.graphics.setFont(self._midFont)
    love.graphics.printf(subtitle, 0, y + 70, width, "center")

    love.graphics.setFont(self._smallFont)   -- deja la fuente por defecto
end

return UI
