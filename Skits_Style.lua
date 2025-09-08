-- Skits_Style.lua

Skits_Style = {}
Skits_Style.ativeStyles = {}

Skits_Style.inImmersive = false
Skits_Style.inCombat = false
Skits_Style.inCombatDelayedHandler = nil

local inInstance, instanceType, playerCount, maxPlayers = Skits_Utils:IsInInstance()

local styleIdToFunc = {
    [Skits_Style_Utils.enum_styles.HIDDEN] = Skits_Style_Hidden,
    [Skits_Style_Utils.enum_styles.UNDEFINED] = Skits_Style_Hidden,
    [Skits_Style_Utils.enum_styles.WARCRAFT] = Skits_Style_Warcraft,
    [Skits_Style_Utils.enum_styles.TALES] = Skits_Style_Tales,
    [Skits_Style_Utils.enum_styles.NOTIFICATION] = Skits_Style_Notification,
    [Skits_Style_Utils.enum_styles.DEPARTURE] = Skits_Style_Departure,
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
    initialize_aux_addActiveStyleByName(options.style_general_styleonsituation_immersive)
    initialize_aux_addActiveStyleByName(options.style_general_styleonsituation_explore)
    initialize_aux_addActiveStyleByName(options.style_general_styleonsituation_combat)
    initialize_aux_addActiveStyleByName(options.style_general_styleonsituation_instance_solo)
    initialize_aux_addActiveStyleByName(options.style_general_styleonsituation_instance_group)

    Skits_QuestFrame:Initialize()
end

function Skits_Style:NewSpeak(creatureData, textData)
    Skits_Style:ShowSituationSkit(false)

    for _, style in pairs(self.ativeStyles) do
        style:NewSpeak(creatureData, textData)
    end
end

function Skits_Style:CancelSpeaker(creatureData)
    for _, style in pairs(self.ativeStyles) do
        style:CancelSpeaker(creatureData)
    end
end

function Skits_Style:CloseSkit()
    for _, style in pairs(self.ativeStyles) do
        style:CloseSkit()
    end
end

function Skits_Style:StyleToDisplay()
    local options = Skits_Options.db

    local style = Skits_Style_Utils.enum_styles.UNDEFINED

    -- Check if we are in immersive mode
    if Skits_Style.inImmersive then
        style = options.style_general_styleonsituation_immersive
        if style ~= Skits_Style_Utils.enum_styles.UNDEFINED then
            return styleNameToObj(style, false)
        end
    end

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
    if self.inCombat then
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
    local lInInstance, lInstanceType, lPlayerCount, lMaxPlayers = Skits_Utils:IsInInstance()
    inInstance = lInInstance
    instanceType = lInstanceType
    playerCount = lPlayerCount
    maxPlayers = lMaxPlayers

    local styleToShow = Skits_Style:StyleToDisplay()
    Skits_Style:ShowSkitStyle(styleToShow, onlyIfActive)
end

function Skits_Style:GetInstanceInformation()
    return inInstance, instanceType, playerCount, maxPlayers
end

function Skits_Style:SituationEnterCombat(onlyIfActive)
    local options = Skits_Options.db

    self.inCombat = true
    if not options.combat_easy_in then
        self:ShowSituationSkit(onlyIfActive)
    end

    -- Stop delayed combat checks
    if self.inCombatDelayedHandler then
        self.inCombatDelayedHandler:Cancel()
    end
    self.inCombatDelayedHandler = nil    
end

function Skits_Style:DelayedCombatExit(onlyIfActive)
    local options = Skits_Options.db

    self.inCombat = Skits_Utils:IsInCombat()

    if not options.combat_easy_out then
        self:ShowSituationSkit(onlyIfActive)
    end    

    -- Stop delayed combat checks
    if self.inCombatDelayedHandler then
        self.inCombatDelayedHandler:Cancel()
    end
    self.inCombatDelayedHandler = nil
end

function Skits_Style:SituationExitCombat(onlyIfActive)
    local options = Skits_Options.db

    if options.combat_exit_delay <= 0 then
        -- Update combat status now
        self:DelayedCombatExit(onlyIfActive)
    else
        -- Start a timer to recheck combat status
        if self.inCombatDelayedHandler then
            self.inCombatDelayedHandler:Cancel()
        end
        local tOnlyIfActive = onlyIfActive
        self.inCombatDelayedHandler = C_Timer.NewTimer(options.combat_exit_delay, function()        
            self:DelayedCombatExit(tOnlyIfActive)
        end)   
    end
end

function Skits_Style:SituationMoveExitExploration(onlyIfActive)
    local options = Skits_Options.db

    if options.move_exit_exploration_for <= 0 then
        return
    end

    self:ChangeToCombatWithDelayedExit(onlyIfActive, options.move_exit_exploration_for)
end

function Skits_Style:ChangeToCombatWithDelayedExit(onlyIfActive, delayExitTimer)
    local options = Skits_Options.db

    -- Set for inCombat (the effects are the same as we only have Combat and Exploration)
    self.inCombat = true
    self:ShowSituationSkit(onlyIfActive)

    if delayExitTimer > 0 then
        -- Start a timer to recheck combat status
        if self.inCombatDelayedHandler then
            self.inCombatDelayedHandler:Cancel()
        end
        local tOnlyIfActive = onlyIfActive
        self.inCombatDelayedHandler = C_Timer.NewTimer(delayExitTimer, function()        
            self:DelayedCombatExit(tOnlyIfActive)
        end) 
    end
end

function Skits_Style:MouseClickAction(clickAction, skitStyle)
    if clickAction == "CLOSE" then
        self:CloseSkit()

    elseif clickAction == "HIDE" then
        self:ShowSkitStyle(Skits_Style_Utils.enum_styles.HIDDEN, true)    

    elseif clickAction == "NEXT" then
        local hadNext = Skits_SpeakQueue:ShowNext()
        if hadNext == false then
            self:CloseSkit()    
        end

    elseif clickAction == "GOTOCOMBAT" then
        self:ChangeToCombatWithDelayedExit(true, 30)

    end
end

function Skits_Style:SituationAreaChanged(onlyIfActive)
    self:ShowSituationSkit(onlyIfActive)
end

-- Immersive Toggle
SLASH_SkitsImmersive1 = "/SkitsImmersive"
SlashCmdList["SkitsImmersive"] = function()   
    Skits_Style.inImmersive = not Skits_Style.inImmersive
    if Skits_Style.inImmersive then
        print("Skits: Immersive mode is now enabled")
    else
        print("Skits: Immersive mode is now disabled")
    end
end