-- Skits_Style_Hidden.lua

Skits_Style_Hidden = {}
Skits_Style_Hidden.name = Skits_Style_Utils.enum_styles.HIDDEN

-- EXTERNAL: Speak --------------------------------------------------------------------------------------------------------------
function Skits_Style_Hidden:NewSpeak(creatureData, textData)
    return
end

function Skits_Style_Hidden:ResetLayout()
    return
end

function Skits_Style_Hidden:CloseSkit()
    self:HideSkit() 
end

function Skits_Style_Hidden:HideSkit()
    return
end

function Skits_Style_Hidden:ShowSkit()
    return
end

function Skits_Style_Hidden:ShouldDisplay()
    return false
end

function Skits_Style_Hidden:IsActive()
    return false
end

function Skits_Style_Hidden:CancelSpeaker(creatureData)
    return
end