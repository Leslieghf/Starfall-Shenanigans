local ManualControl = {}

ManualControl.HeldEntities = {}
ManualControl.WasActive = false

local function keyFor(ent)
    if not ent or not ent:isValid() then return nil end
    return ent:entIndex()
end

function ManualControl.isControlledPart(ent, propControl)
    return ent and ent:isValid() and propControl.isRegisteredProp(ent)
end

function ManualControl.pickup(ent)
    local key = keyFor(ent)
    if not key then return end

    ManualControl.HeldEntities[key] = true
end

function ManualControl.drop(ent)
    local key = keyFor(ent)
    if key then
        ManualControl.HeldEntities[key] = nil
    end
end

function ManualControl.clear(ent)
    local key = keyFor(ent)
    if key then
        ManualControl.HeldEntities[key] = nil
    end
end

function ManualControl.clearAll()
    ManualControl.HeldEntities = {}
    ManualControl.WasActive = false
end

function ManualControl.isActive()
    return next(ManualControl.HeldEntities) ~= nil
end

function ManualControl.consumeEndedTransition(active)
    local ended = ManualControl.WasActive and not active
    ManualControl.WasActive = active
    return ended
end

return ManualControl
