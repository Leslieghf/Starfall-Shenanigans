--@name Prop Voxel Builder
--@shared

local MODEL = "models/hunter/blocks/cube025x025x025.mdl"
local GRID = 12
local DIST = 1000

local function worldToGrid(v)
    return Vector(
        math.floor(v.x / GRID + 0.5),
        math.floor(v.y / GRID + 0.5),
        math.floor(v.z / GRID + 0.5)
    )
end

local function gridToWorld(v)
    return v * GRID
end

local function key(v)
    return v.x .. "_" .. v.y .. "_" .. v.z
end

-- ================= SERVER =================
if SERVER then

    local blocks = {}

    hook.add("think", "voxel_logic", function()

        local ply = owner()
        if not ply:isValid() then return end

        local tr = trace.line(
            ply:getEyePos(),
            ply:getEyePos() + ply:getAimVector() * DIST,
            ply
        )

        if not tr or not tr.Hit then return end

        local hitGrid = worldToGrid(tr.HitPos - tr.HitNormal * (GRID / 2))
        local breakGrid = hitGrid

        local n = tr.HitNormal
        local offset = Vector(
            math.abs(n.x) > 0.5 and math.sign(n.x) or 0,
            math.abs(n.y) > 0.5 and math.sign(n.y) or 0,
            math.abs(n.z) > 0.5 and math.sign(n.z) or 0
        )

        local placeGrid = hitGrid + offset
        local placePos = gridToWorld(placeGrid)

        local rmb = ply:keyDown(IN_KEY.ATTACK2)
        local lmb = ply:keyDown(IN_KEY.ATTACK)

        -- PLACE
        if rmb and not ply._lastRMB then
            local k = key(placeGrid)
            if not blocks[k] then
                local prop = prop.create(placePos, Angle(), MODEL, true)
                if prop then
                    prop:enableMotion(false)
                    blocks[k] = prop
                end
            end
        end

        -- BREAK
        if lmb and not ply._lastLMB then
            local k = key(breakGrid)
            if blocks[k] then
                blocks[k]:remove()
                blocks[k] = nil
            end
        end

        ply._lastRMB = rmb
        ply._lastLMB = lmb
    end)

end


-- ================= CLIENT =================
if CLIENT then

    hook.add("renderoffscreen", "voxel_highlight", function()

        render.enableDepth(true)

        local ply = player()
        if not ply:isValid() then return end

        local tr = trace.line(
            ply:getEyePos(),
            ply:getEyePos() + ply:getAimVector() * DIST,
            ply
        )

        if not tr or not tr.Hit then return end

        local hitGrid = worldToGrid(tr.HitPos - tr.HitNormal * (GRID / 2))
        local center = gridToWorld(hitGrid)

        local half = (GRID / 2) * 5

        render.setColor(Color(255,255,255,255))

        render.draw3DWireframeBox(
            center,
            Angle(),
            Vector(-half, -half, -half),
            Vector(half, half, half)
        )

        render.enableDepth(false)
    end)

end