-- Game.lua · el coordinador de la partida. Es dueño de las entidades, lleva
-- puntaje / vidas / nivel, delega cada frame en el estado actual y coordina
-- las colisiones. La lógica de cada cosa vive en su propia clase.
local Ball = require("src.Ball")
local Paddle = require("src.Paddle")
local Level = require("src.Level")
local PowerUp = require("src.PowerUp")
local UI = require("src.UI")
local Sound = require("src.Sound")
local Particles = require("src.Particles")
local Shake = require("src.Shake")
local Collision = require("src.collision")
local states = require("src.states")
local levels = require("data.levels")

local Game = {}
Game.__index = Game

local START_LIVES = 3
local MAX_LIVES = 5
local BALL_SIZE = 12
local PLAY_TOP = 44            -- techo del área de juego (arriba va el HUD)
local MAX_DT = 1 / 30          -- si un frame tarda demasiado, se recorta
local MAX_STEP = 4             -- píxeles máximos que avanza la bola por sub-paso
local SERVE_SPREAD = 0.35      -- qué tan inclinado puede salir el saque
local POWERUP_CHANCE = 0.2     -- probabilidad de que un ladrillo suelte power-up
local WIDE_SECONDS = 10

function Game.new()
    local self = setmetatable({}, Game)
    self._areaWidth, self._areaHeight = love.graphics.getDimensions()

    self._score = 0
    self._lives = START_LIVES
    self._levelIndex = 1

    -- Composición: Game crea estas piezas y viven lo mismo que él
    self._ui = UI.new()
    self._sound = Sound.new()
    self._particles = Particles.new()
    self._shake = Shake.new()
    self._paddle = Paddle.new(self._areaWidth / 2, self._areaHeight - 60)
    self._ball = Ball.new(BALL_SIZE)
    self._powerUps = {}

    love.graphics.setBackgroundColor(0.06, 0.07, 0.12)
    self:loadLevel(1)
    self:changeState("title")
    return self
end

-- ============================================================================
-- BUCLE DE JUEGO: entrada -> actualización -> render. Game delega en el estado.
-- ============================================================================

function Game:changeState(name)
    assert(states[name], "Estado desconocido: " .. tostring(name))
    self._state = states[name]
    if self._state.enter then self._state.enter(self) end
end

function Game:handleInput(key)
    if self._state.keypressed then self._state.keypressed(self, key) end
end

function Game:update(dt)
    dt = math.min(dt, MAX_DT)
    if self._state.update then self._state.update(self, dt) end
end

function Game:draw()
    self._state.draw(self)
end

-- ============================================================================
-- ACCIONES Y CONSULTAS que usan los estados (src/states.lua)
-- ============================================================================

function Game:startNewGame()
    self._score = 0
    self._lives = START_LIVES
    self:loadLevel(1)
end

function Game:loadLevel(index)
    self._levelIndex = index
    self._level = Level.new(index, levels[index], self._areaWidth)
    self._ball:setSpeed(self._level:getBallSpeed())
    self._paddle:resetWidth()
    self._powerUps = {}
end

function Game:loadNextLevel()
    self:loadLevel(self._levelIndex + 1)
end

function Game:hasNextLevel()
    return self._levelIndex < #levels
end

function Game:hasLives()
    return self._lives > 0
end

function Game:getScore()
    return self._score
end

function Game:getLevelNumber()
    return self._level:getNumber()
end

-- Estado Serve: la bola espera sobre la paleta y la sigue
function Game:prepareServe()
    self._powerUps = {}
    self._ball:restOn(self._paddle:getCenterX(), self._paddle.y)
end

function Game:updateServe(dt)
    self._paddle:update(dt, self._areaWidth)
    self._ball:restOn(self._paddle:getCenterX(), self._paddle.y)
    self:updateEffects(dt)
end

function Game:launchBall()
    local t = (love.math.random() * 2 - 1) * SERVE_SPREAD
    self._ball:launch(t)
    self._sound:play("paddle")
end

-- Estado Play. Devuelve un evento ("ball_lost", "level_cleared") o nil.
function Game:updatePlay(dt)
    self._paddle:update(dt, self._areaWidth)
    self:_updatePowerUps(dt)
    self:updateEffects(dt)

    -- Anti-tunneling: en vez de mover la bola de un solo salto, se mueve en
    -- sub-pasos de máximo MAX_STEP píxeles y se revisan colisiones en cada uno.
    local distance = self._ball:getSpeed() * dt
    local steps = math.max(1, math.ceil(distance / MAX_STEP))
    local stepDt = dt / steps

    for _ = 1, steps do
        self._ball:update(stepDt)
        local event = self:checkCollisions()
        if event then return event end
    end
    return nil
end

function Game:updateEffects(dt)
    self._particles:update(dt)
    self._shake:update(dt)
end

-- Efectos de los power-ups (los llama PowerUp a través de su función 'effect')
function Game:widenPaddle()
    self._paddle:widen(WIDE_SECONDS)
end

function Game:addLife()
    self._lives = math.min(MAX_LIVES, self._lives + 1)
end

-- ============================================================================
-- COLISIONES: Game coordina; cada objeto solo sabe responder por sí mismo.
-- ============================================================================

function Game:checkCollisions()
    self:_collideWalls()
    self:_collidePaddle()
    self:_collideBricks()

    if self._ball.y > self._areaHeight then
        self:_loseLife()
        return "ball_lost"
    end
    if self._level:isCompleted() then
        self._sound:play("win")
        return "level_cleared"
    end
    return nil
end

-- Bola contra bordes: izquierda, derecha y techo rebotan. Abajo no hay pared.
function Game:_collideWalls()
    local ball = self._ball
    local hit = false

    if ball.x < 0 then
        ball:bounce("x", -ball.x)
        hit = true
    elseif ball.x + ball.w > self._areaWidth then
        ball:bounce("x", self._areaWidth - (ball.x + ball.w))
        hit = true
    end

    if ball.y < PLAY_TOP then
        ball:bounce("y", PLAY_TOP - ball.y)
        hit = true
    end

    if hit then self._sound:play("wall") end
end

-- Bola contra paleta: el ángulo de salida depende de DÓNDE pegó
function Game:_collidePaddle()
    local ball, paddle = self._ball, self._paddle

    -- Solo cuenta si la bola viene bajando (evita que rebote dos veces seguidas)
    if ball:isMovingDown() and Collision.aabb(ball, paddle) then
        local ballCenterX = ball:getCenter()
        local t = paddle:impactFactor(ballCenterX)
        ball:deflect(t, paddle.y)
        self._sound:play("paddle")
    end
end

-- Bola contra ladrillos
function Game:_collideBricks()
    local ball = self._ball
    local brick = self._level:findHit(ball)
    if not brick then return end

    -- 1) rebote por el eje de menor solapamiento
    ball:bounce(Collision.resolve(ball, brick))

    -- 2) POLIMORFISMO: no se pregunta qué tipo de ladrillo es, él responde
    self._score = self._score + brick:onHit()

    -- 3) efectos
    if brick:isDead() then
        local x, y = brick:getCenter()
        self._sound:play("brick")
        self._particles:burst(x, y, brick:getColor())
        self._shake:start(0.12, 3)
        if love.math.random() < POWERUP_CHANCE then
            table.insert(self._powerUps, PowerUp.random(x, y))
        end
    else
        self._sound:play("wall")
    end
end

function Game:_loseLife()
    self._lives = self._lives - 1
    self._shake:start(0.35, 9)
    self._sound:play("lose")
end

-- Power-ups: caen, y si tocan la paleta aplican su efecto
function Game:_updatePowerUps(dt)
    for i = #self._powerUps, 1, -1 do
        local powerUp = self._powerUps[i]
        powerUp:update(dt)

        if Collision.aabb(powerUp, self._paddle) then
            powerUp:applyTo(self)
            self._sound:play("powerup")
            table.remove(self._powerUps, i)
        elseif powerUp.y > self._areaHeight then
            table.remove(self._powerUps, i)
        end
    end
end

-- ============================================================================
-- DIBUJO: Game pide a cada objeto que se dibuje; los textos los hace UI.
-- ============================================================================

function Game:drawWorld()
    -- La sacudida mueve todo el mundo, pero no el HUD
    love.graphics.push()
    love.graphics.translate(self._shake:getOffset())

    self._level:draw()
    self._paddle:draw()
    self._ball:draw()
    for _, powerUp in ipairs(self._powerUps) do
        powerUp:draw()
    end
    self._particles:draw()

    love.graphics.pop()

    self._ui:drawScore(self._score)
    self._ui:drawLevel(self._level:getNumber(), self._level:getName())
    self._ui:drawLives(self._lives)
end

function Game:showMessage(title, subtitle)
    self._ui:drawOverlay()
    self._ui:drawMessage(title, subtitle)
end

function Game:showHint(text)
    self._ui:drawHint(text)
end

return Game
