name = "Ray Tracing Test"
description = "how bad can it possibly be"

importLib("logger")
importLib("vectors")

ResolutionW = 500
ResolutionH = math.ceil(ResolutionW * (9 / 16))

gameFov = 100.40

verticalFov = math.rad(gameFov)
fov = 2 * math.atan((16 / 9) * (math.tan(verticalFov / 2)))

squareSpacing = 640 / ResolutionW

testBtn = client.settings.addNamelessKeybind("test button", 0x22)

currentlyRayTracing = false
event.listen("KeyboardInput", function(key, down)
    if key == testBtn.value and down then
        raytraceScene()
    end
end)


outputBuffer = {}

time = 0
function render2(dt)
    px, py, pz = player.pposition()
    pyaw, ppitch = player.rotation()

    if #outputBuffer > 0 then
        for x = 0, ResolutionW - 1, 1 do
            for y = 0, ResolutionH - 1, 1 do
                -- for x = 0, #outputBuffer - 1 do --*
                --     for y = 0, #outputBuffer[#outputBuffer] - 1 do --*
                local col = outputBuffer[x + 1][y + 1]

                -- *normals
                -- local facingDir = col[2]
                -- local dirToCol = {}
                -- dirToCol[-1] = { 0, 0, 0, 0 }
                -- dirToCol[0] = { 0, 127, 0, 255 }
                -- dirToCol[1] = { 0, 255, 0, 255 }
                -- dirToCol[2] = { 0, 0, 127, 255 }
                -- dirToCol[3] = { 0, 0, 255, 255 }
                -- dirToCol[4] = { 127, 0, 0, 255 }
                -- dirToCol[5] = { 255, 0, 0, 255 }
                -- local thisColor = dirToCol[facingDir]
                -- gfx2.color(thisColor[1], thisColor[2], thisColor[3], 100)

                -- *shadows
                -- local shadowAmount = col[3]
                -- gfx2.color(0, 0, 0, shadowAmount * 100)
                -- gfx2.fillRect(x * squareSpacing, y * squareSpacing, squareSpacing, squareSpacing)

                -- *water shine (old)
                -- local isWater = col[4]
                -- gfx2.color(117, 170, 235, isWater * 200)
                -- gfx2.fillRect(x * squareSpacing, y * squareSpacing, squareSpacing, squareSpacing)

                -- *fog
                -- if col[1] == 1 then
                -- else
                --     gfx2.color(120, 220, 255, (col[1] ^ 2 / 1.2) * 255)
                --     gfx2.fillRect(x * squareSpacing, y * squareSpacing, squareSpacing, squareSpacing)
                -- end

                -- *dof
                -- gfx2.blur(x * squareSpacing, y * squareSpacing, squareSpacing, squareSpacing, col[5] / 75)

                -- *clouds
                -- local a = col[6][1] * (255 / 0.7)
                -- local b = 255 - (col[6][2] * (255 / 1.5))
                -- gfx2.color(b, b, b, a)
                -- gfx2.fillRect(x * squareSpacing, y * squareSpacing, squareSpacing + 0.1, squareSpacing + 0.1)

                -- *water reflections
                -- gfx2.color(col[4][1], col[4][2], col[4][3], col[4][4])
                -- gfx2.fillRect(x * squareSpacing, y * squareSpacing, squareSpacing + 0.1, squareSpacing + 0.1)

                -- *water shine
                -- gfx2.color(255, 255, 255, col[7] * 150)
                -- gfx2.fillRect(x * squareSpacing, y * squareSpacing, squareSpacing + 0.1, squareSpacing + 0.1)

                --*water shadows
                -- gfx2.color(0, 0, 0, col[8] * 80)
                -- gfx2.fillRect(x * squareSpacing, y * squareSpacing, squareSpacing + 0.1, squareSpacing + 0.1)

                --*UVs
                gfx2.color(col[9][1] * 255, col[9][2] * 255, 0, 255)
                gfx2.fillRect(x * squareSpacing, y * squareSpacing, squareSpacing + 0.1, squareSpacing + 0.1)

                -- gfx2.fillRect(x * squareSpacing, y * squareSpacing, squareSpacing + 0.1, squareSpacing + 0.1)
            end
        end
    end


    ---- 3d fbm demo
    -- time = time + dt
    -- for i = 1, 20, 1 do
    --     for j = 1, 20, 1 do
    --         local val = contrast(fbmNoise3d(i, j, time * 2), 0.75) * 255
    --         gfx2.color(val, val, val)
    --         gfx2.fillRect(i * 10, j * 10, 10, 10)
    --     end
    -- end
end

-- function update()
--     log(factorRamp(px, { { 200, 0 }, { 220, 1 }, { 280, 1 }, { 300, 0 } }))
-- end

-- function render3d()
--     local playerToOrigin = vec:new(-px, -py, -pz)
--     local reflected = reflectVector3d(playerToOrigin, vec:new(1, 1, 0))
--     gfx.line(px, py, pz, 0, 0, 0)
--     gfx.line(0, 0, 0, reflected.x, reflected.y, reflected.z)
-- end

function screenPixelToDirection(x, y)
    local tanF2 = math.tan(fov / 2)
    local tanZ2 = math.tan(verticalFov / 2)

    local xCoord = mapRange(x, 0, ResolutionW - 1, -tanF2, tanF2)
    local yCoord = mapRange(y, 0, ResolutionH - 1, tanZ2, -tanZ2)

    return vec:new(xCoord, yCoord, 1)
end

function pixelDirToWorldDir(pixelDir)
    local newPitch = math.atan(pixelDir.y) - math.rad(ppitch)
    local ZandYMagnitude = math.sqrt(pixelDir.y ^ 2 + 1)

    pixelDir:setComponent("y", ZandYMagnitude * math.sin(newPitch))
    pixelDir:setComponent("z", ZandYMagnitude * math.cos(newPitch))

    local xzPlaneOfDir = vec:new(pixelDir.x, pixelDir.z):rotate(math.rad(-pyaw - 180))
    pixelDir:setComponent("x", xzPlaneOfDir.x)
    pixelDir:setComponent("z", -xzPlaneOfDir.y)

    pixelDir:normalize()

    return pixelDir
end

_depth = false
_normal = false
_sunShadows = false
_waterReflections = false
_dof = false
_clouds = false
_waterShine = false
_waterShadows = false
_textureUVs = true
function raytracePixel(x, y)
    local worldDir = pixelDirToWorldDir(screenPixelToDirection(x, y)):normalize()
    local dist = 1000

    local output = {}

    local hit = dimension.raycast(px, py, pz, px + worldDir.x * dist, py + worldDir.y * dist, pz + worldDir.z * dist)
    local hitW = dimension.raycast(px, py, pz, px + worldDir.x * dist, py + worldDir.y * dist, pz + worldDir.z * dist,
        dist, false, false, true)
    local sunDir = getSunDirection()

    --DEPTH-- [1]
    if _depth then
        local distToCam = vec:new(hit.px, hit.py, hit.pz):dist(vec:new(px, py, pz))
        if hit.isBlock then
            output[1] = distToCam / dist
        else
            output[1] = 1
        end
    end

    --NORMAL (in the form of the block face number)-- [2]
    if _normal then
        if hit.isBlock then
            output[2] = hit.blockFace
        else
            output[2] = -1
        end
    end

    --SUN SHADOWS-- [3]
    if _sunShadows then
        if hit.isBlock then
            local shadowDist = 100
            local toSunRaycast = dimension.raycast(
                hit.px, hit.py, hit.pz,
                hit.px + sunDir.x * shadowDist, hit.py + sunDir.y * shadowDist, hit.pz + sunDir.z * shadowDist
            )
            if toSunRaycast.isBlock then
                output[3] = 1
            else
                output[3] = 0
            end
        else
            output[3] = 0
        end
    end

    --WATER REFLECTIONS-- [4]
    if _waterReflections then
        if hitW.isBlock then
            if dimension.getBlock(hitW.x, hitW.y, hitW.z).name == "water" then
                local waterNormal = fbmNoiseNormal2d(hitW.px * 4, hitW.pz * 4, 2)
                local reflected = reflectVector3d(worldDir, waterNormal)
                local reflectedHit = dimension.raycast(
                    hitW.px, hitW.py, hitW.pz,
                    hitW.px + reflected.x * dist,
                    hitW.py + reflected.y * dist,
                    hitW.pz + reflected.z * dist
                )
                if reflectedHit.isBlock then
                    local hitR, hitG, hitB = dimension.getMapColor(reflectedHit.x, reflectedHit.y, reflectedHit.z)
                    output[4] = { hitR, hitG, hitB, 75 }
                else
                    output[4] = { 0, 0, 0, 0 }
                end
            else
                output[4] = { 0, 0, 0, 0 }
            end
        else
            output[4] = { 0, 0, 0, 0 }
        end
    end

    --DEPTH OF FIELD BLUR MASK-- [5]
    if _dof then
        local focalDistance = 100
        output[5] = math.abs(output[1] * dist - focalDistance)
    end

    --CLOUD MAP-- [6]
    if _clouds then
        local cloudBottomBound = 200
        local cloudTopBound = 350

        if (py < cloudBottomBound and worldDir.y < 0) or (py > cloudTopBound and worldDir.y > 0) then
            output[6] = { 0, 0 }
        else
            local cloudRay
            if py < cloudTopBound and py > cloudBottomBound then
                cloudRay = vec:new(px, py, pz)
            elseif py < cloudBottomBound then
                local xStart = ((cloudBottomBound - py) / worldDir.y) * worldDir.x + px
                local zStart = ((cloudBottomBound - py) / worldDir.y) * worldDir.z + pz
                cloudRay = vec:new(xStart, cloudBottomBound, zStart)
            elseif py > cloudTopBound then
                local xStart = ((cloudTopBound - py) / worldDir.y) * worldDir.x + px
                local zStart = ((cloudTopBound - py) / worldDir.y) * worldDir.z + pz
                cloudRay = vec:new(xStart, cloudTopBound, zStart)
            end

            local density = 0
            local darkening = 0
            local worldDirMult = vec:new(worldDir.x, worldDir.y, worldDir.z):mult(16)

            local numSteps = 25
            for i = 1, numSteps, 1 do
                if cloudRay.y > cloudTopBound + 1 or cloudRay.y < cloudBottomBound - 1 then break end
                local thisDensity = factorRamp(cloudRay.y,
                        {
                            { cloudBottomBound,   0 }, { cloudBottomBound + 10, 1 },
                            { cloudTopBound - 10, 1 }, { cloudTopBound, 0 }
                        })
                    * contrast(fbmNoise3d(cloudRay.x / 10, cloudRay.y / 10, cloudRay.z / 10), 0.9)
                density = density + thisDensity

                darkening = darkening + thisDensity * mapRange(cloudRay.y, cloudBottomBound, cloudTopBound, 1, 0)

                cloudRay:add(worldDirMult)
            end
            output[6] = { density / numSteps, darkening / numSteps }
        end
    end

    --WATER SHINE-- [7]
    if _waterShine then
        if hitW.isBlock then
            if dimension.getBlock(hitW.x, hitW.y, hitW.z).name == "water" and output[4][4] == 0 then --hit water and reflects into the sky
                local waterNormal = fbmNoiseNormal2d(hitW.px * 4, hitW.pz * 4, 1)
                local reflected = reflectVector3d(worldDir:copy(), waterNormal)
                reflected:setComponent("y", -reflected.y)

                output[7] = factorRamp(reflected:normalize():dot(sunDir), { { 0, 0 }, { 0.994, 0 },
                    { 1, 1 } })
            else
                output[7] = 0
            end
        else
            output[7] = 0
        end
    end

    --WATER SHADOWS-- [8]
    if _waterShadows then
        if hitW.isBlock then
            if dimension.getBlock(hitW.x, hitW.y, hitW.z).name == "water" then
                local waterNormal = fbmNoiseNormal2d(hitW.px * 4, hitW.pz * 4, 0.2)
                local reflected = reflectVector3d(worldDir:copy(), waterNormal)
                reflected:setComponent("y", -reflected.y)

                local dot = worldDir.x * reflected.x + worldDir.y * reflected.y + worldDir.z * reflected.z

                output[8] = math.min((1 - dot) * 5, 1)
            else
                output[8] = 0
            end
        else
            output[8] = 0
        end
    end

    --TEXTURE UVS-- [9]
    if _textureUVs then
        local blockFract = vec:new(fract(hitW.px), fract(hitW.py), fract(hitW.pz))
        local uv = vec:new(0, 0)
        if hitW.blockFace == 0 or hitW.blockFace == 1 then
            uv.u = blockFract.x
            uv.v = blockFract.z
        end
        if hitW.blockFace == 2 or hitW.blockFace == 3 then
            uv.u = blockFract.x
            uv.v = blockFract.y
        end
        if hitW.blockFace == 4 or hitW.blockFace == 5 then
            uv.u = blockFract.y
            uv.v = blockFract.z
        end
        output[9] = { uv.u, uv.v }
    end

    return output
end

function raytraceScene()
    outputBuffer = {}
    for x = 0, ResolutionW - 1, 1 do
        table.insert(outputBuffer, {})
        for y = 0, ResolutionH - 1, 1 do
            table.insert(outputBuffer[x + 1], raytracePixel(x, y))
        end
    end
end

function getSunDirection()
    local time = -dimension.time() * 2 * math.pi
    return vec:new(math.sin(time), math.cos(time), 0)
end

function mapRange(value, inMin, inMax, outMin, outMax)
    return (outMax - outMin) * (value - inMin) / (inMax - inMin) + outMin
end

function fract(x)
    return x - math.floor(x)
end

function mix(val1, val2, factor)
    return val1 * (1 - factor) + val2 * factor
end

-- {x, y}
function factorRamp(x, points)
    for i = 1, #points do
        if x < points[1][1] then return points[1][2] end
        if x > points[#points][1] then return points[#points][2] end
        if x >= points[i][1] and x < points[i + 1][1] then
            return mapRange(x, points[i][1], points[i + 1][1], points[i][2], points[i + 1][2])
        end
    end
end

-- might not need
function reflectVector3d(vec, normal)
    normal:normalize()
    local dot = vec:dot(normal)

    return vec:copy():sub(normal:mult(2 * dot))
end

-- takes a number from 0-1, contrast is (0-1), 1 being black and white, 0 being all gray
function contrast(x, contrast)
    local n = -1.2 * math.log(contrast, 0.2) + 0.5

    return (0.5 / (0.5 - n)) * x - (0.5 * n) / (0.5 - n)
end

function pseudoRandom(x)
    function f(a)
        return 50.343 * fract(x * 0.3180 + 0.113)
    end

    return fract(f(x) ^ 2 * fract((f(x) * f(f(x)))))
end

function pseudoRandom2d(x, y)
    return pseudoRandom((pseudoRandom(x) + pseudoRandom(pseudoRandom(y))) / 2)
end

function pseudoRandom3d(x, y, z)
    return pseudoRandom(
        (
            pseudoRandom(x) + pseudoRandom(pseudoRandom(y)) + pseudoRandom(pseudoRandom(pseudoRandom(z)))
        ) / 3
    )
end

function valueNoise2d(x, y)
    local i = vec:new(math.floor(x), math.floor(y))
    local f = vec:new(fract(x), fract(y))
    -- local u = f:mult(f):mult(f:mult(-2):add(vec:new(3, 3))) --! this might be better, but it's broken
    local u = f

    return mix(
        mix(pseudoRandom2d(i.x + 0, i.y + 0), pseudoRandom2d(i.x + 1, i.y + 0), u.x),
        mix(pseudoRandom2d(i.x + 0, i.y + 1), pseudoRandom2d(i.x + 1, i.y + 1), u.x),
        u.y
    )
end

function valueNoise3d(x, y, z)
    local i = vec:new(math.floor(x), math.floor(y), math.floor(z))
    local f = vec:new(fract(x), fract(y), fract(z))
    local u = f

    return mix(
        mix(
            mix(pseudoRandom3d(i.x + 0, i.y + 0, i.z), pseudoRandom3d(i.x + 1, i.y + 0, i.z), u.x),
            mix(pseudoRandom3d(i.x + 0, i.y + 1, i.z), pseudoRandom3d(i.x + 1, i.y + 1, i.z), u.x),
            u.y
        ),
        mix(
            mix(pseudoRandom3d(i.x + 0, i.y + 0, i.z + 1), pseudoRandom3d(i.x + 1, i.y + 0, i.z + 1), u.x),
            mix(pseudoRandom3d(i.x + 0, i.y + 1, i.z + 1), pseudoRandom3d(i.x + 1, i.y + 1, i.z + 1), u.x),
            u.y
        ),
        u.z
    )
end

function fbmNoise2d(x, y)
    return (0.5 * valueNoise2d(x / 8, y / 8) + 0.25 * valueNoise2d(x / 4, y / 4) + 0.125 * valueNoise2d(x / 2, y / 2) + 0.0625 * valueNoise2d(x, y))
end

function fbmNoise3d(x, y, z)
    return (
        0.5 * valueNoise3d(x / 8, y / 8, z / 8) +
        0.25 * valueNoise3d(x / 4, y / 4, z / 4) +
        0.125 * valueNoise3d(x / 2, y / 2, z / 2) +
        0.0625 * valueNoise3d(x, y, z)
    )
end

-- might not need
function fbmNoiseNormal2d(x, y, strength)
    local dx = (fbmNoise2d(x + 1, y) - fbmNoise2d(x - 1, y)) / 2
    local dy = (fbmNoise2d(x, y + 1) - fbmNoise2d(x, y - 1)) / 2

    return vec:new(-dx, -strength, -dy):normalize()
end

--[[
    blockFace:
        0: -y / no block
        1: +y
        2: -z
        3: +z
        4: -x
        5: +x
]]

--? smooth shadows
--   five+ differnent sun directions, shadows are added together
-- volumetric clouds
-- torch shadows
-- textured water reflections
-- iron mirror reflections
-- sun color with depending on time with water reflection
-- normal maps on all blocks
-- water refraction
-- distort fbm by shifting pixels by other fbm

-- ?when reflecting, recurvisely call the raytrace function
--      give it the input of the direction and the output of each map at that pixel
