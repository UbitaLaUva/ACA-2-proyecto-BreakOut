-- Sound.lua · carga los efectos de sonido una sola vez y los reproduce por nombre.
local Sound = {}
Sound.__index = Sound

local FILES = {
    paddle = "assets/sounds/paddle.wav",
    wall = "assets/sounds/wall.wav",
    brick = "assets/sounds/brick.wav",
    powerup = "assets/sounds/powerup.wav",
    lose = "assets/sounds/lose.wav",
    win = "assets/sounds/win.wav",
}

function Sound.new()
    local self = setmetatable({}, Sound)
    self._sources = {}
    for name, path in pairs(FILES) do
        -- Si faltara un archivo, el juego sigue abriendo: solo no suena ese efecto
        if love.filesystem.getInfo(path) then
            self._sources[name] = love.audio.newSource(path, "static")
        end
    end
    return self
end

function Sound:play(name)
    local source = self._sources[name]
    if source then
        source:stop()    -- si ya estaba sonando, lo reinicia
        source:play()
    end
end

return Sound
