local PropControl = {}

PropControl.Registry = {}

function PropControl.startup()
    local ent = chip()
    local pos = ent:getPos()
    local ang = ent:getAngles()
    local model = "models/props_phx/carseat3.mdl"
    local frozen = true

    local seat = prop.createSeat(pos + Vector(0, 0, 11), ang, model, frozen)
    constraint.weld(seat, ent)
    
    PropControl.addPropToRegistry(seat, "seat")
end

function PropControl.addPropToRegistry(ent, name)
    PropControl.Registry[name] = {ent = ent, mass = ent:getMass()}
end

return PropControl