-- Skits_SpeakQueue.lua

Skits_SpeakQueue = {}

Skits_SpeakQueue.queuedSpeaks = {}
Skits_SpeakQueue.currentSpeakHandler = nil
Skits_SpeakQueue.currentSpeakData = nil

function Skits_SpeakQueue:ShowNext()
    if #self.queuedSpeaks == 0 then
        self:clearHandler()
        return false
    end

    -- Pop Next Speak
    if self.currentSpeakHandler ~= nil then
        self:clearHandler()
    end
    local nextSpeakData = Skits_SpeakQueue.queuedSpeaks[1]
    self.currentSpeakData = nextSpeakData
    table.remove(self.queuedSpeaks, 1)

    -- Time its end
    self.currentSpeakHandler = C_Timer.NewTimer(nextSpeakData.duration, function()        
        Skits_SpeakQueue:CurrentTimesUp()
    end)

    -- Show speak
    if nextSpeakData.isPause == false then
        Skits:ChatEvent(nextSpeakData.creatureData, nextSpeakData.textData, false)
    end    

    return true
end

function Skits_SpeakQueue:clearHandler()
    if self.currentSpeakHandler == nil then
        return
    end

    self.currentSpeakHandler:Cancel()    
    self.currentSpeakHandler = nil
    self.currentSpeakData = nil
end


function Skits_SpeakQueue:CurrentTimesUp()
    self:clearHandler()
    self:ShowNext()
end

function Skits_SpeakQueue:AddSpeaker(creatureData, textData, duration, priority)
    -- Build speaker data
    local speakData = {
        isPause = false,        
        creatureData = creatureData,
        textData = textData,
        duration = duration,
        priority = priority,
    }

    table.insert(self.queuedSpeaks, speakData)

    -- Show next if no queued speak is currently shown
    if self.currentSpeakHandler == nil then
        self:ShowNext()
    end
end

function Skits_SpeakQueue:AddPause(duration)
    -- Build speaker data
    local speakData = {
        isPause = true,
        duration = duration,
    }

    table.insert(self.queuedSpeaks, speakData)

    -- Show next if no queued speak is currently shown
    if self.currentSpeakHandler == nil then
        self:ShowNext()
    end
end

function Skits_SpeakQueue:RemoveByName(creatureName)
    local newQueue = {}

    for idx, speakerData in ipairs(self.queuedSpeaks) do
        if speakerData.isPause == false then
            if speakerData.creatureData.name ~= creatureName then
                table.insert(newQueue, speakerData)
            end
        end 
    end
    
    self.queuedSpeaks = newQueue

    if self.currentSpeakData and self.currentSpeakData.creatureData then
        if self.currentSpeakData.creatureData.name == creatureName then
            self:clearHandler()
        end
    end
end

function Skits_SpeakQueue:Clear()
    self:clearHandler()
    self.queuedSpeaks = {}
end


