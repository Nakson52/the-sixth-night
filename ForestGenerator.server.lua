-- THE SIXTH NIGHT | Quiet Edge forest visual prototype v0.3
-- Replace the code of ServerScriptService > ForestGenerator with this file.
-- The forest is generated in Play mode and disappears when you press Stop.

local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local rng = Random.new(6171986)

local previous = Workspace:FindFirstChild("TSN_PrototypeForest")
if previous then previous:Destroy() end

local world = Instance.new("Folder")
world.Name = "TSN_PrototypeForest"
world.Parent = Workspace

local function makePart(name, size, cf, color, material, parent, shape)
    local obj = Instance.new("Part")
    obj.Name = name
    obj.Anchored = true
    obj.Size = size
    obj.CFrame = cf
    obj.Color = color
    obj.Material = material
    obj.TopSurface = Enum.SurfaceType.Smooth
    obj.BottomSurface = Enum.SurfaceType.Smooth
    obj.CastShadow = true
    if shape then obj.Shape = shape end
    obj.Parent = parent or world
    return obj
end

-- The top of the earth is at Y=-0.5; the old road is a little higher.
makePart("ForestGround", Vector3.new(520, 3, 520), CFrame.new(0, -2, 0),
    Color3.fromRGB(35, 45, 37), Enum.Material.Ground)
makePart("OldRoad", Vector3.new(22, 0.22, 520), CFrame.new(0, -0.35, 0),
    Color3.fromRGB(46, 50, 53), Enum.Material.Asphalt)

-- Narrow gravel verges visually connect the asphalt and forest soil.
for _, side in ipairs({-1, 1}) do
    makePart("GravelVerge", Vector3.new(3.5, 0.1, 520),
        CFrame.new(side * 12.75, -0.42, 0),
        Color3.fromRGB(53, 55, 52), Enum.Material.Pebble)
end

-- Uneven old surface: fine cracks rather than large painted road markings.
for i = 1, 85 do
    local x = rng:NextNumber(-10, 10)
    local z = rng:NextNumber(-248, 248)
    local crack = makePart("RoadCrack", Vector3.new(rng:NextNumber(0.06, 0.13), 0.018,
        rng:NextNumber(0.7, 3.8)),
        CFrame.new(x, -0.23, z) * CFrame.Angles(0, math.rad(rng:NextInteger(-75, 75)), 0),
        Color3.fromRGB(26, 30, 32), Enum.Material.Slate)
    crack.CanCollide = false
    crack.CastShadow = false
end

local treeCount = 0
local function pine(x, z, scale)
    treeCount += 1
    local tree = Instance.new("Model")
    tree.Name = "Pine"
    tree.Parent = world

    local height = rng:NextNumber(17, 23) * scale
    local trunk = makePart("Trunk", Vector3.new(height, 1.3 * scale, 1.3 * scale),
        CFrame.new(x, -0.5 + height / 2, z) * CFrame.Angles(0, 0, math.rad(90)),
        Color3.fromRGB(55, 45, 38), Enum.Material.Wood, tree, Enum.PartType.Cylinder)
    trunk.CanCollide = true

    -- Layered ellipsoid needle clusters break up the blocky tree silhouette.
    local shade = rng:NextInteger(-4, 4)
    for tier = 1, 4 do
        local t = (tier - 1) / 3
        local width = (10.8 - 6.3 * t) * scale
        local y = -0.5 + height * (0.52 + 0.14 * (tier - 1))
        local foliage = makePart("Needles", Vector3.new(width, 5.5 * scale, width),
            CFrame.new(x, y, z),
            Color3.fromRGB(30 + shade, 55 + shade + tier, 43 + shade),
            Enum.Material.Grass, tree, Enum.PartType.Ball)
        foliage.CanCollide = false
        -- Off-centre branches give each tree a slightly different outline.
        if tier < 4 then
            for branch = 1, 2 do
                local angle = rng:NextNumber(0, math.pi * 2)
                local dist = width * rng:NextNumber(0.25, 0.36)
                local cluster = makePart("BranchNeedles", Vector3.new(width * 0.55, 2.6 * scale,
                    width * 0.43),
                    CFrame.new(x + math.cos(angle) * dist, y - 0.65 * scale,
                        z + math.sin(angle) * dist) * CFrame.Angles(0, angle, math.rad(rng:NextNumber(-16, 16))),
                    Color3.fromRGB(27 + shade, 50 + shade, 39 + shade),
                    Enum.Material.Grass, tree, Enum.PartType.Ball)
                cluster.CanCollide = false
            end
        end
    end
end

-- Trees grow close enough to frame the road, without blocking it.
for _, side in ipairs({-1, 1}) do
    local z = -245
    while z < 245 do
        local x = side * rng:NextNumber(21, 31)
        pine(x, z + rng:NextNumber(-4, 4), rng:NextNumber(0.75, 1.25))
        z += rng:NextNumber(10, 17)
    end
end

-- Irregular denser woodland behind the roadside trees.
for _ = 1, 240 do
    local x = rng:NextNumber(-250, 250)
    local z = rng:NextNumber(-250, 250)
    if math.abs(x) > 33 then
        pine(x, z, rng:NextNumber(0.72, 1.4))
    end
end

-- Rocks and small shrubs give the roadside a little surface detail.
for i = 1, 125 do
    local side = (i % 2 == 0) and -1 or 1
    local x = side * rng:NextNumber(15, 65)
    local z = rng:NextNumber(-250, 250)
    local size = rng:NextNumber(0.45, 2.5)
    local rock = makePart("ForestStone", Vector3.new(size, size * 0.6, size * 0.85),
        CFrame.new(x, -0.5 + size * 0.22, z) * CFrame.Angles(0,
            math.rad(rng:NextInteger(0, 180)), 0),
        Color3.fromRGB(49, 55, 51), Enum.Material.Slate, world, Enum.PartType.Ball)
    rock.CanCollide = false
end

-- Tiny roadside reflectors help players read the depth of the road at night.
for z = -210, 210, 42 do
    for _, side in ipairs({-1, 1}) do
        local x = side * 14.6
        makePart("RoadPost", Vector3.new(0.36, 2.25, 0.36),
            CFrame.new(x, 0.63, z),
            Color3.fromRGB(88, 92, 87), Enum.Material.Concrete)
        local reflector = makePart("Reflector", Vector3.new(0.43, 0.42, 0.12),
            CFrame.new(x, 1.19, z + 0.22),
            Color3.fromRGB(170, 150, 115), Enum.Material.Neon)
        reflector.CanCollide = false
    end
end

-- Keep the original spawn and move it onto the road.
local spawn = Workspace:FindFirstChildWhichIsA("SpawnLocation", true)
if not spawn then
    spawn = Instance.new("SpawnLocation")
    spawn.Parent = Workspace
end
spawn.Name = "PrototypeSpawn"
spawn.Size = Vector3.new(7, 1, 7)
spawn.CFrame = CFrame.new(0, 0.75, 0)
spawn.Anchored = true
spawn.Neutral = true
spawn.Transparency = 1
spawn.CanCollide = false
spawn.Duration = 0

-- Cinematic nighttime visibility: readable near silhouettes, distant uncertainty.
Lighting.ClockTime = 1.2
Lighting.Brightness = 2.5
Lighting.ExposureCompensation = 0.2
Lighting.Ambient = Color3.fromRGB(64, 77, 94)
Lighting.OutdoorAmbient = Color3.fromRGB(75, 87, 104)
Lighting.FogColor = Color3.fromRGB(45, 58, 65)
Lighting.FogStart = 30
Lighting.FogEnd = 185
Lighting.GlobalShadows = true

local atmosphere = Lighting:FindFirstChild("TSN_Atmosphere") or Instance.new("Atmosphere")
atmosphere.Name = "TSN_Atmosphere"
atmosphere.Density = 0.28
atmosphere.Offset = 0.03
atmosphere.Color = Color3.fromRGB(105, 125, 136)
atmosphere.Decay = Color3.fromRGB(43, 54, 69)
atmosphere.Glare = 0
atmosphere.Haze = 1.3
atmosphere.Parent = Lighting

local grade = Lighting:FindFirstChild("TSN_ColorGrade") or Instance.new("ColorCorrectionEffect")
grade.Name = "TSN_ColorGrade"
grade.Brightness = 0.01
grade.Contrast = 0.09
grade.Saturation = -0.22
grade.TintColor = Color3.fromRGB(214, 226, 240)
grade.Parent = Lighting

print(string.format("[THE SIXTH NIGHT] Forest v0.3 ready | Trees: %d", treeCount))
