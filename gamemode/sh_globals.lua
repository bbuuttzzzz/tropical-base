COLOR_RED = Color(255, 0, 0, 255)

function GM:InitializeAmmo()
    -- we can override this function in a child gamemode to replace ammo types
    -- for now heres some defaults
    game.AddAmmoType({name = "dummy"}) -- dummy ammo
    game.AddAmmoType({name = "light"}) -- pistol ammo
    game.AddAmmoType({name = "medium"}) -- assault ammo
    game.AddAmmoType({name = "long"}) -- sniper ammo
    game.AddAmmoType({name = "shell"}) -- shotgun ammo
    game.AddAmmoType({name = "rocket"}) -- explosive ammo
end
