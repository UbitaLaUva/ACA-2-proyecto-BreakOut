-- states.lua · MÁQUINA DE ESTADOS. Cada estado es una tabla con sus callbacks:
--   enter(game)            se ejecuta una vez al entrar al estado
--   update(game, dt)       lógica de cada frame
--   draw(game)             qué se dibuja
--   keypressed(game, key)  qué teclas escucha
-- Game solo delega en el estado actual. TODAS las transiciones están en este
-- archivo, así que leerlo de arriba abajo equivale a leer el diagrama de estados.
local states = {}

local function isEnter(key)
    return key == "return" or key == "kpenter"
end

-- TITLE ----------------------------------------------------------------------
states.title = {
    draw = function(game)
        game:showMessage("BREAKOUT: NEON BLOCKS", "Presiona Enter para jugar")
        game:showHint("Mover: flechas o A / D   ·   Lanzar: Espacio   ·   Pausa: Esc")
    end,
    keypressed = function(game, key)
        if isEnter(key) then              -- Title -> Serve [Enter]
            game:startNewGame()
            game:changeState("serve")
        end
    end,
}

-- SERVE: la bola espera pegada a la paleta -----------------------------------
states.serve = {
    enter = function(game)
        game:prepareServe()
    end,
    update = function(game, dt)
        game:updateServe(dt)
    end,
    draw = function(game)
        game:drawWorld()
        game:showHint("Espacio para lanzar la bola")
    end,
    keypressed = function(game, key)
        if key == "space" then            -- Serve -> Play [Espacio] / lanzar bola
            game:launchBall()
            game:changeState("play")
        end
    end,
}

-- PLAY -----------------------------------------------------------------------
states.play = {
    update = function(game, dt)
        -- updatePlay avisa si pasó algo que obliga a cambiar de estado
        local event = game:updatePlay(dt)

        if event == "ball_lost" then
            if game:hasLives() then
                game:changeState("serve")          -- Play -> Serve [vidas > 0]
            else
                game:changeState("gameover")       -- Play -> GameOver [vidas == 0]
            end
        elseif event == "level_cleared" then
            if game:hasNextLevel() then
                game:changeState("levelcomplete")  -- Play -> LevelComplete [quedan niveles]
            else
                game:changeState("victory")        -- Play -> Victory [era el último nivel]
            end
        end
    end,
    draw = function(game)
        game:drawWorld()
    end,
    keypressed = function(game, key)
        if key == "escape" then           -- Play -> Pause [Esc]
            game:changeState("pause")
        end
    end,
}

-- PAUSE: no tiene update, por eso todo queda congelado -----------------------
states.pause = {
    draw = function(game)
        game:drawWorld()
        game:showMessage("PAUSA", "Esc para continuar")
    end,
    keypressed = function(game, key)
        if key == "escape" then           -- Pause -> Play [Esc]
            game:changeState("play")
        end
    end,
}

-- LEVEL COMPLETE -------------------------------------------------------------
states.levelcomplete = {
    update = function(game, dt)
        game:updateEffects(dt)            -- deja terminar partículas y sacudida
    end,
    draw = function(game)
        game:drawWorld()
        game:showMessage("NIVEL " .. game:getLevelNumber() .. " COMPLETADO",
            "Enter para el siguiente nivel")
    end,
    keypressed = function(game, key)
        if isEnter(key) then              -- LevelComplete -> Serve [Enter] / cargar nivel
            game:loadNextLevel()
            game:changeState("serve")
        end
    end,
}

-- GAME OVER ------------------------------------------------------------------
states.gameover = {
    update = function(game, dt)
        game:updateEffects(dt)
    end,
    draw = function(game)
        game:drawWorld()
        game:showMessage("GAME OVER",
            "Puntaje: " .. game:getScore() .. "   ·   R para volver al inicio")
    end,
    keypressed = function(game, key)
        if key == "r" then                -- GameOver -> Title [R]
            game:changeState("title")
        end
    end,
}

-- VICTORY --------------------------------------------------------------------
states.victory = {
    update = function(game, dt)
        game:updateEffects(dt)
    end,
    draw = function(game)
        game:drawWorld()
        game:showMessage("¡VICTORIA!",
            "Puntaje: " .. game:getScore() .. "   ·   R para volver al inicio")
    end,
    keypressed = function(game, key)
        if key == "r" then                -- Victory -> Title [R]
            game:changeState("title")
        end
    end,
}

return states
