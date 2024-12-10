-- Skits_Deque.lua
Skits_Deque = {}
Skits_Deque.__index = Skits_Deque

-- Constructor to create a new deque instance
function Skits_Deque:New()
    local instance = {}
    setmetatable(instance, Skits_Deque)
    instance:Reset()
    return instance
end

-- Resets the Deque
function Skits_Deque:Reset()
    self.head = nil
    self.tail = nil
    self.mapValueToEle = {}
    self.size = 0
end

-- Function to initialize a deque with a list of values
function Skits_Deque:BuildDequeFromList(values)
    self:Reset()

    -- Build the deque from the list, first element is tail
    for _, value in ipairs(values) do
        self:AddToHead(value)
    end
end

-- Function to create a list of values from the deque, tail first
function Skits_Deque:CreateListFromDeque()
    local values = {}
    local current = self.tail

    while current do
        table.insert(values, current.value)
        current = current.prev
    end

    return values
end

-- Function to add a new object to the deque
function Skits_Deque:AddToHead(value)
    -- If the element exists, remove it from its current position
    if self.mapValueToEle[value] then
        self:Remove(value)
    end

    self.size = self.size + 1

    -- Create the new element
    local newElement = {
        value = value,
        prev = nil,
        next = self.head
    }

    -- Update head and the deque structure
    if self.head then
        self.head.prev = newElement
    else
        self.tail = newElement
    end
    self.head = newElement

    -- Add to the map
    self.mapValueToEle[value] = newElement
end

-- Function to remove an object from the deque by value
function Skits_Deque:Remove(value)
    local element = self.mapValueToEle[value]
    if not element then return end  -- Element not found

    self.size = self.size - 1

    -- Update links
    if element.prev then
        element.prev.next = element.next
    else
        self.tail = element.next
    end

    if element.next then
        element.next.prev = element.prev
    else
        self.head = element.prev
    end

    -- Remove from map
    self.mapValueToEle[value] = nil
end

-- Function to remove the first X elements from the deque (X from tail)
function Skits_Deque:RemoveFirstX(x)
    local removeds = {}

    for _ = 1, x do
        if not self.tail then 
            return removeds
        end

        local value = self.tail.value
        table.insert(removeds, value)
        self:Remove(value)
    end

    return removeds
end

-- Function to remove the last X elements from the deque (X from head)
function Skits_Deque:RemoveLastX(x)
    local removeds = {}

    for _ = 1, x do
        if not self.head then 
            return removeds 
        end

        local value = self.head.value
        table.insert(removeds, value)
        self:Remove(value)
    end

    return removeds
end

-- Function to add newValue after refValue in the deque
function Skits_Deque:AddAfter(refValue, newValue)
    -- Get the reference element
    local refElement = self.mapValueToEle[refValue]
    if not refElement then return end  -- If refValue doesn't exist, do nothing

    -- If newValue exists in the deque, remove it from its current position
    if self.mapValueToEle[newValue] then
        self:Remove(newValue)
    end

    -- Create the new element
    local newElement = {
        value = newValue,
        prev = refElement,
        next = refElement.next
    }

    -- Update links in the deque
    if refElement.next then
        refElement.next.prev = newElement
    else
        self.head = newElement  -- New element is the new head if refElement was the last element
    end
    refElement.next = newElement

    -- Add new element to the map
    self.mapValueToEle[newValue] = newElement
end

-- Function to add newValue before refValue in the deque
function Skits_Deque:AddBefore(refValue, newValue)
    -- Get the reference element
    local refElement = self.mapValueToEle[refValue]
    if not refElement then return end  -- If refValue doesn't exist, do nothing

    -- If newValue exists in the deque, remove it from its current position
    if self.mapValueToEle[newValue] then
        self:Remove(newValue)
    end

    -- Create the new element
    local newElement = {
        value = newValue,
        prev = refElement.prev,
        next = refElement
    }

    -- Update links in the deque
    if refElement.prev then
        refElement.prev.next = newElement
    else
        self.tail = newElement  -- New element is the new tail if refElement was the first element
    end
    refElement.prev = newElement

    -- Add new element to the map
    self.mapValueToEle[newValue] = newElement
end
