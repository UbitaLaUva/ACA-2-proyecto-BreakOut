-- levels.lua · los niveles son DATOS, no código.
-- Cada número de la matriz es un tipo de ladrillo:
--   0 = vacío · 1 = normal · 2 = resistente (2 golpes) · 3 = irrompible
-- Para agregar un nivel nuevo basta con agregar otra tabla a esta lista.
return {
    {
        name = "El Inicio",
        ballSpeed = 400,
        layout = {
            { 1, 1, 1, 1, 1, 1, 1, 1 },
            { 1, 2, 1, 1, 1, 1, 2, 1 },
            { 0, 1, 1, 2, 2, 1, 1, 0 },
        },
    },
    {
        name = "Muralla",
        ballSpeed = 450,
        layout = {
            { 2, 1, 2, 1, 1, 2, 1, 2 },
            { 1, 1, 1, 1, 1, 1, 1, 1 },
            { 1, 3, 1, 2, 2, 1, 3, 1 },
            { 0, 1, 1, 3, 3, 1, 1, 0 },
        },
    },
}
