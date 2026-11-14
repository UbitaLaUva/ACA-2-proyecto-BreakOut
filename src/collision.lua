-- collision.lua · funciones de colisión entre rectángulos (AABB).
-- No es una clase: es un módulo de funciones puras. Cualquier tabla que tenga
-- x, y, w, h sirve como "caja" (bola, paleta, ladrillo, power-up).
local Collision = {}

-- DETECCION: dos cajas chocan si se solapan en X y en Y al mismo tiempo.
function Collision.aabb(a, b)
    return a.x < b.x + b.w and b.x < a.x + a.w
       and a.y < b.y + b.h and b.y < a.y + a.h
end

-- Cuántos píxeles se meten una dentro de la otra en cada eje.
-- (Solo tiene sentido llamarla si aabb(a, b) dio true.)
function Collision.overlap(a, b)
    local ox = math.min(a.x + a.w, b.x + b.w) - math.max(a.x, b.x)
    local oy = math.min(a.y + a.h, b.y + b.h) - math.max(a.y, b.y)
    return ox, oy
end

-- RESOLUCIÓN: decide por cuál eje debe rebotar 'a' y cuánto hay que empujarla
-- para sacarla de 'b'. Regla: se rebota por el eje de MENOR solapamiento.
-- Devuelve el eje ("x" o "y") y el empuje con signo (negativo = izquierda/arriba).
function Collision.resolve(a, b)
    local ox, oy = Collision.overlap(a, b)

    if ox < oy then
        -- entró por un costado: ¿'a' está a la izquierda o a la derecha de 'b'?
        local aCenter = a.x + a.w / 2
        local bCenter = b.x + b.w / 2
        local direction = (aCenter < bCenter) and -1 or 1
        return "x", ox * direction
    else
        -- entró por arriba o por abajo
        local aCenter = a.y + a.h / 2
        local bCenter = b.y + b.h / 2
        local direction = (aCenter < bCenter) and -1 or 1
        return "y", oy * direction
    end
end

return Collision
