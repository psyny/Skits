-- Skits_UI_Utils.lua
Skits_UI_Utils = {}

function Skits_UI_Utils:RemoveFrame(frame) 
    frame:Hide()
    frame:ClearAllPoints()
    frame:SetParent(nil)
end