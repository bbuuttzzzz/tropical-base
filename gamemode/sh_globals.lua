function GM:InitializeAmmo()
    -- first, create all of our necessary ammo types
    game.AddAmmoType({name = "dummy"}) -- dummy ammo
    game.AddAmmoType({name = "primary"}) -- ammo for people's primary weapon
    game.AddAmmoType({name = "scrap"}) -- scrap, used in build mode and for some crafting
end
