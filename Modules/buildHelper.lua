name="Build Helper"
description = "totally not a cheat"

importLib("vectors")
importLib("logger")
importLib("renderThreeD")

PLACEFARLIMIT = 10

function solidRaycast(startPos, endPos)
    
end

function lookAt(target)
    local px, py, pz = player.pposition()

    local vecToTarget = vec:new(px, py, pz):sub(target)
    local dirToTarget = vecToTarget:dir()

    player.setRotation(math.deg(dirToTarget[1])+90, math.deg(dirToTarget[2]))
end

function buildBlock(blockPos)
    if dimension.getBlock(blockPos.x, blockPos.y, blockPos.z).name ~= "air" then
        return nil --there's already a block here, make that known
    end

    local px, py, pz = player.pposition()
    local pVec = vec:new(px, py, pz)

    local blockCenter = blockPos:copy():add(vec:new(0.5, 0.5, 0.5))
    local potentialPlaceSpots = {}

    -- +x
    local pXEnd = vec:new(PLACEFARLIMIT, 0, 0):add(blockCenter)
    local pXHit = dimension.raycast(blockCenter.x, blockCenter.y, blockCenter.z, pXEnd.x, pXEnd.y, pXEnd.z)
    if pXHit.isBlock then table.insert(potentialPlaceSpots, vec:new(pXHit.px, pXHit.py, pXHit.pz)) end

    -- -x
    local nXEnd = vec:new(-PLACEFARLIMIT, 0, 0):add(blockCenter)
    local nXHit = dimension.raycast(blockCenter.x, blockCenter.y, blockCenter.z, nXEnd.x, nXEnd.y, nXEnd.z)
    if nXHit.isBlock then table.insert(potentialPlaceSpots, vec:new(nXHit.px, nXHit.py, nXHit.pz)) end

    -- +y
    local pYEnd = vec:new(0, PLACEFARLIMIT, 0):add(blockCenter)
    local pYHit = dimension.raycast(blockCenter.x, blockCenter.y, blockCenter.z, pYEnd.x, pYEnd.y, pYEnd.z)
    if pYHit.isBlock then table.insert(potentialPlaceSpots, vec:new(pYHit.px, pYHit.py, pYHit.pz)) end

    -- -y
    local nYEnd = vec:new(0, -PLACEFARLIMIT, 0):add(blockCenter)
    local nYHit = dimension.raycast(blockCenter.x, blockCenter.y, blockCenter.z, nYEnd.x, nYEnd.y, nYEnd.z)
    if nYHit.isBlock then table.insert(potentialPlaceSpots, vec:new(nYHit.px, nYHit.py, nYHit.pz)) end

    -- +z
    local pZEnd = vec:new(0, 0, PLACEFARLIMIT):add(blockCenter)
    local pZHit = dimension.raycast(blockCenter.x, blockCenter.y, blockCenter.z, pZEnd.x, pZEnd.y, pZEnd.z)
    if pZHit.isBlock then table.insert(potentialPlaceSpots, vec:new(pZHit.px, pZHit.py, pZHit.pz)) end

    -- -z
    local nZEnd = vec:new(0, 0, -PLACEFARLIMIT):add(blockCenter)
    local nZHit = dimension.raycast(blockCenter.x, blockCenter.y, blockCenter.z, nZEnd.x, nZEnd.y, nZEnd.z)
    if nZHit.isBlock then table.insert(potentialPlaceSpots, vec:new(nZHit.px, nZHit.py, nZHit.pz)) end

    local visiblePlaceSpots = {}

    log(#visiblePlaceSpots)

    for i = 1, #potentialPlaceSpots, 1 do
        local thisSpot = potentialPlaceSpots[i]
        local castToSpot = dimension.raycast(px, py, pz, thisSpot.x, thisSpot.y, thisSpot.z)
        if not castToSpot.isBlock then
            table.insert(visiblePlaceSpots, vec:new(castToSpot.px, castToSpot.py, castToSpot.pz))
        end
    end

    if #visiblePlaceSpots == 0 then --there's nowhere to place a block
        return false
    end

    local nearestDist = 10000
    local nearestSpot = vec:new(0, 0, 0)
    for i = 1, #visiblePlaceSpots, 1 do
        if visiblePlaceSpots[i]:dist(blockCenter) < nearestDist then
            nearestSpot = visiblePlaceSpots[i]
        end
    end

    lookAt(nearestSpot)
    return true
end

-- returns a table of blocks to build a wall
function buildWall(pos, direction) --direction is a 2d vec, pos is the middle block under the wall
    local output = {}

    local dirRight = direction:copy():rotateYaw(math.rad(90)):normalize()
    local dirRight3d = vec:new(dirRight.x, 0, dirRight.y)

    -- for i = -2, 2, 1 do
    --     for j = 1, 2, 1 do
    --         local thisPos = pos:copy():add(dirRight3d:copy():mult(i):add(vec:new(0, j, 0)))
    --         table.insert(output, vec:new(round(thisPos.x), round(thisPos.y), round(thisPos.z)))
    --     end
    -- end

    for i = -1, 1, 1 do
        local thisPos = pos:copy():add(dirRight3d:copy():mult(i):add(vec:new(0, 1, 0))):sub(vec:new(direction.x, 0, direction.y):div(1.2))
        table.insert(output, vec:new(round(thisPos.x), round(thisPos.y), round(thisPos.z)))
    end
    for i = -2, 2, 1 do
        local thisPos = pos:copy():add(dirRight3d:copy():mult(i):add(vec:new(0, 2, 0)))
        table.insert(output, vec:new(round(thisPos.x), round(thisPos.y), round(thisPos.z)))
    end

    return output
end

function buildQueue(queue)
    for i = 1, #queue, 1 do
        gfx.color(255, 255, 255, 100)
        cube(queue[i].x, queue[i].y, queue[i].z, 1)
    end
    for i = 1, #queue, 1 do
        if buildBlock(queue[i]) then return end
    end
end

function render3d()
    gfx.renderBehind(true)

    buildQueue(buildWall(vec:new(169, 103, 1375), vec:new(1, 0.3)))
end

function round(v)
    return math.floor(v+0.5)
end

-- ?prevent you from placing blocks anywhere except where it wants you to?