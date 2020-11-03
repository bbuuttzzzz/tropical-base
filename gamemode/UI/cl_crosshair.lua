function DrawCrosshairCircle(degRadius, tColor)
    if degRadius < 0 then return end
    tColor = tColor or MySelf:GetCrosshairColor()

    local x = ScrW() * 0.5
    local y = ScrH() * 0.5

    local iPixelRadius = math.max(3,math.floor(degRadius / MySelf:GetFOV() * ScrH()))

    surface.DrawCircle( x, y, iPixelRadius, tColor)
end
