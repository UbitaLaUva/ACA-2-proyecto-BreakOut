-- conf.lua · LÖVE lee este archivo ANTES de main.lua para configurar la ventana
function love.conf(t)
    t.identity = "breakout_aca2"
    t.window.title = "Breakout: Neon Blocks"
    t.window.width = 800
    t.window.height = 600
    t.window.resizable = false
end
