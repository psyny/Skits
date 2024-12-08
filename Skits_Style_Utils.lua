-- Skits_Style_Utils.lua

Skits_Style_Utils = {}

-- Enums

Skits_Style_Utils.enum_styles = {
    HIDDEN = "hidden",
    UNDEFINED = "undefined",
    WARCRAFT = "warcraft",
    TALES = "tales",
    NOTIFICATION = "notification",
}


-- Light Utils ---------------------------------------------------------------------

Skits_Style_Utils.fallbackId = 114599

Skits_Style_Utils.lightPresets = {}

Skits_Style_Utils.lightPresets.pitchblack = {
    omnidirectional = false,
    point = CreateVector3D(0, 0, -1),
    ambientIntensity = 0,
    ambientColor = CreateColor(0, 0, 0),
    diffuseIntensity = 0,
    diffuseColor = CreateColor(0, 0, 0),
}

Skits_Style_Utils.lightPresets.hidden = {
    omnidirectional = false,
    point = CreateVector3D(1, 0, -1),
    ambientIntensity = 1,
    ambientColor = CreateColor(0, 0, 0),
    diffuseIntensity = 1,
    diffuseColor = CreateColor(0.0, 0.1, 0.2),
}

Skits_Style_Utils.lightPresets.inactive = {
    omnidirectional = false,
    point = CreateVector3D(-1, 1, -1),
    ambientIntensity = 1,
    ambientColor = CreateColor(0.5, 0.5, 0.5),
    diffuseIntensity = 1,
    diffuseColor = CreateColor(0.5, 0.5, 0.5),
}

Skits_Style_Utils.lightPresets.neutral = {
    omnidirectional = false,
    point = CreateVector3D(-1, 1, -1),
    ambientIntensity = 1,
    ambientColor = CreateColor(0.5, 0.5, 0.5),
    diffuseIntensity = 1,
    diffuseColor = CreateColor(0.5, 0.5, 0.5),
}

Skits_Style_Utils.lightPresets.midday = {
    omnidirectional = false,
    point = CreateVector3D(-1, 1, -1),
    ambientIntensity = 1,
    ambientColor = CreateColor(0.5, 0.5, 0.6),
    diffuseIntensity = 1,
    diffuseColor = CreateColor(0.6, 0.6, 0.5),
}

Skits_Style_Utils.lightPresets.afternoon = {
    omnidirectional = false,
    point = CreateVector3D(-1, 1, -1),
    ambientIntensity = 1,
    ambientColor = CreateColor(0.5, 0.5, 0.6),
    diffuseIntensity = 1,
    diffuseColor = CreateColor(0.6, 0.5, 0.5),
}

Skits_Style_Utils.lightPresets.dusk = {
    omnidirectional = false,
    point = CreateVector3D(-1, 1, -1),
    ambientIntensity = 1,
    ambientColor = CreateColor(0.5, 0.5, 0.6),
    diffuseIntensity = 1,
    diffuseColor = CreateColor(0.6, 0.3, 0.3),
}

Skits_Style_Utils.lightPresets.midnight = {
    omnidirectional = false,
    point = CreateVector3D(-1, 1, -1),
    ambientIntensity = 1,
    ambientColor = CreateColor(0.5, 0.5, 0.6),
    diffuseIntensity = 1,
    diffuseColor = CreateColor(0.2, 0.3, 0.3),
}

function Skits_Style_Utils:PrintLight(light)
    print("[LIGHT DATA]")
    print(light.point:GetXYZ())
    print(light.ambientIntensity)
    print(light.ambientColor:GetRGB())
    print(light.diffuseIntensity)
    print(light.diffuseColor:GetRGB())
end


function Skits_Style_Utils:GetHourLight()
    local h, m = GetGameTime()
    local hour = h + (m / 60)

    -- Light Color
    local light1 = nil
    local light2 = nil
    local light = nil
    local lightRatio = 0

    if hour < 5 then
        light = Skits_Style_Utils.lightPresets.midnight
    elseif hour < 6 then
        light1 = Skits_Style_Utils.lightPresets.midnight
        light2 = Skits_Style_Utils.lightPresets.dusk
        lightRatio = Skits_Utils:Interpolation(0, 1, 5, 6, hour)
    elseif hour < 8 then
        light1 = Skits_Style_Utils.lightPresets.dusk
        light2 = Skits_Style_Utils.lightPresets.afternoon
        lightRatio = Skits_Utils:Interpolation(0, 1, 6, 8, hour) 
    elseif hour < 12 then
        light1 = Skits_Style_Utils.lightPresets.afternoon
        light2 = Skits_Style_Utils.lightPresets.midday
        lightRatio = Skits_Utils:Interpolation(0, 1, 8, 12, hour) 
    elseif hour < 16 then
        light1 = Skits_Style_Utils.lightPresets.midday
        light2 = Skits_Style_Utils.lightPresets.afternoon
        lightRatio = Skits_Utils:Interpolation(0, 1, 12, 16, hour)          
    elseif hour < 18 then
        light1 = Skits_Style_Utils.lightPresets.afternoon
        light2 = Skits_Style_Utils.lightPresets.dusk
        lightRatio = Skits_Utils:Interpolation(0, 1, 16, 18, hour)          
    elseif hour < 19 then
        light1 = Skits_Style_Utils.lightPresets.dusk
        light2 = Skits_Style_Utils.lightPresets.midnight
        lightRatio = Skits_Utils:Interpolation(0, 1, 18, 19, hour)                 
    else
        light = Skits_Style_Utils.lightPresets.midnight
    end

    if not light then
        local a1 = light1.ambientIntensity
        local a1r, a1g, a1b = light1.ambientColor:GetRGB()
        local a2 = light2.ambientIntensity
        local a2r, a2g, a2b = light2.ambientColor:GetRGB()
        local d1 = light1.diffuseIntensity
        local d1r, d1g, d1b = light1.diffuseColor:GetRGB()
        local d2 = light2.diffuseIntensity
        local d2r, d2g, d2b = light2.diffuseColor:GetRGB()

        local a3 = Skits_Utils:Interpolation(a1, a2, 0, 1, lightRatio)
        local a3r = Skits_Utils:Interpolation(a1r, a2r, 0, 1, lightRatio)
        local a3g = Skits_Utils:Interpolation(a1g, a2g, 0, 1, lightRatio)
        local a3b = Skits_Utils:Interpolation(a1b, a2b, 0, 1, lightRatio)

        local d3 = Skits_Utils:Interpolation(d1, d2, 0, 1, lightRatio)
        local d3r = Skits_Utils:Interpolation(d1r, d2r, 0, 1, lightRatio)
        local d3g = Skits_Utils:Interpolation(d1g, d2g, 0, 1, lightRatio)
        local d3b = Skits_Utils:Interpolation(d1b, d2b, 0, 1, lightRatio)     
        
        light = {
            omnidirectional = false,
            point = CreateVector3D(-1, 1, -1),
            ambientIntensity = a3,
            ambientColor = CreateColor(a3r, a3g, a3b),
            diffuseIntensity = d3,
            diffuseColor = CreateColor(d3r, d3g, d3b),
        }
    end

    -- Light Position
    local sunPos = 0
    local tSunPos = 0
    if hour < 5 then
        tSunPos = Skits_Utils:Interpolation(0, 1, 0, 5, hour)
        sunPos = tSunPos * -1
    elseif hour < 19 then
        tSunPos = Skits_Utils:Interpolation(-1, 1, 5, 19, hour)
        sunPos = tSunPos
    else
        tSunPos = Skits_Utils:Interpolation(0, 1, 19, 24, hour)
        sunPos = 1 - tSunPos
    end

    light.point = CreateVector3D(-1, sunPos, -1)
    return light
end
