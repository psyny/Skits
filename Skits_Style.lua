-- Skits_Style.lua

Skits_Style = {}
Skits_Style.ativeStyles = {}

local styleIdToFunc = {
    [Skits_Style_Utils.enum_styles.HIDDEN] = Skits_Style_Hidden,
    [Skits_Style_Utils.enum_styles.UNDEFINED] = Skits_Style_Hidden,
    [Skits_Style_Utils.enum_styles.WARCRAFT] = Skits_Style_Warcraft,
    [Skits_Style_Utils.enum_styles.TALES] = Skits_Style_Tales,
    [Skits_Style_Utils.enum_styles.NOTIFICATION] = Skits_Style_Notification,
}

local function styleNameToObj(styleName, allowNil)
    local styleObj = styleIdToFunc[styleName]
    if not styleObj and not allowNil then
        styleObj = styleIdToFunc[Skits_Style_Utils.enum_styles.HIDDEN]
    end

    return styleObj
end

local function initialize_aux_addActiveStyleByName(styleName)
    local styleObj = styleNameToObj(styleName, true)
    if styleObj then
        Skits_Style.ativeStyles[styleObj.name] = styleObj
        styleObj:ResetLayout()
        styleObj:CloseSkit()
    else
        if not styleName then
            styleName = "<nil>"
        end
        Skits_Utils:PrintError("Skit Style Not Found: " .. styleName, false)
    end
end

function Skits_Style:Initialize()
    local options = Skits_Options.db

    -- Add styles defined on options
    Skits_Style.ativeStyles = {}
    initialize_aux_addActiveStyleByName(options.style_general_styleonsituation_explore)
    initialize_aux_addActiveStyleByName(options.style_general_styleonsituation_combat)
    initialize_aux_addActiveStyleByName(options.style_general_styleonsituation_instance_solo)
    initialize_aux_addActiveStyleByName(options.style_general_styleonsituation_instance_group)
end

function Skits_Style:NewSpeak(creatureData, textData)
    Skits_Style:ShowSituationSkit(false)

    for _, style in pairs(self.ativeStyles) do
        style:NewSpeak(creatureData, textData)
    end
end

function Skits_Style:StyleToDisplay()
    local options = Skits_Options.db

    local style = Skits_Style_Utils.enum_styles.UNDEFINED

    -- Check if we are in a solo instance, and if solo instance display is enabled
    if Skits_Utils:IsInInstanceSolo() then
        style = options.style_general_styleonsituation_instance_solo
        if style ~= Skits_Style_Utils.enum_styles.UNDEFINED then
            return styleNameToObj(style, false)
        end
    end

    -- Check if we are in a group instance, and if group instance display is enabled
    if Skits_Utils:IsInInstanceGroup() then
        style = options.style_general_styleonsituation_instance_group
        if style ~= Skits_Style_Utils.enum_styles.UNDEFINED then
            return styleNameToObj(style, false)
        end
    end

    -- Check if we are in combat, and if combat display is enabled
    if Skits_Utils:IsInCombat() then
        style = options.style_general_styleonsituation_combat
        if style ~= Skits_Style_Utils.enum_styles.UNDEFINED then
            return styleNameToObj(style, false)
        end
    end

    -- If nothing else, set to exploration
    style = options.style_general_styleonsituation_explore

    return styleNameToObj(style, false)
end

function Skits_Style:ShowSkitStyle(styleToShow, onlyIfActive)
    for _, style in pairs(self.ativeStyles) do
        local shouldShow = false
        if style.name == styleToShow.name then
            if style:ShouldDisplay() then
                if not onlyIfActive or style:IsActive() then
                    shouldShow = true
                end
            end
        end

        if shouldShow then
            style:ShowSkit()
        else
            style:HideSkit()
        end
    end
end

function Skits_Style:ShowSituationSkit(onlyIfActive)  
    local styleToShow = Skits_Style:StyleToDisplay()
    Skits_Style:ShowSkitStyle(styleToShow, onlyIfActive)
end