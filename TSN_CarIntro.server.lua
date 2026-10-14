-- THE SIXTH NIGHT | Chapter I / Vehicle intro prototype / SERVER v0.2
-- Place this Script in ServerScriptService.
-- Keep ForestGenerator v0.3 enabled. Disable the previous Chapter1_FirstBeat LocalScript.
-- This is a moving cinematic prop, not a driveable car.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local DURATION = 29
local BEGIN_Z = 180
local END_Z = 42
local START_Y = 0

local old = Workspace:FindFirstChild("TSN_IntroCar")
if old then old:Destroy() end

local remote = ReplicatedStorage:FindFirstChild("TSN_CarIntroEvent")
if not remote then
    remote = Instance.new("RemoteEvent")
    remote.Name = "TSN_CarIntroEvent"
    remote.Parent = ReplicatedStorage
end

local car = Instance.new("Model")
car.Name = "TSN_IntroCar"
car.Parent = Workspace

local function part(name, size, position, color, material, parent, shape)
    local p = Instance.new("Part")
    p.Name = name
    p.Size = size
    p.CFrame = CFrame.new(position)
    p.Color = color
    p.Material = material or Enum.Material.SmoothPlastic
    p.Anchored = true
    p.CanCollide = false -- cinematic prop; characters are repositioned after the sequence
    p.CastShadow = true
    if shape then p.Shape = shape end
    p.Parent = parent or car
    return p
end

local metal = Color3.fromRGB(26, 31, 36)
local trim = Color3.fromRGB(12, 15, 19)
local interior = Color3.fromRGB(43, 43, 44)

-- Model coordinates are local to the origin, then PivotTo moves the whole car.
local pivot = part("Root", Vector3.new(1, 1, 1), Vector3.new(0, 2, 0), metal)
pivot.Transparency = 1
car.PrimaryPart = pivot

part("Floor", Vector3.new(9.1, 0.35, 12.7), Vector3.new(0, 1.35, 0), trim)
part("Roof", Vector3.new(9.3, 0.32, 9.4), Vector3.new(0, 5.85, 0.75), metal)
part("RearWall", Vector3.new(9.1, 3.75, 0.3), Vector3.new(0, 3.5, 6.2), metal)
part("LeftDoorLower", Vector3.new(0.27, 1.75, 10.9), Vector3.new(-4.4, 2.25, 0), metal)
part("RightDoorLower", Vector3.new(0.27, 1.75, 10.9), Vector3.new(4.4, 2.25, 0), metal)
part("FrontHood", Vector3.new(9.1, 0.45, 3.1), Vector3.new(0, 2.12, -6.0), metal)
part("Dash", Vector3.new(8.55, 0.65, 1.25), Vector3.new(0, 2.68, -3.85), interior)
part("WindshieldTop", Vector3.new(9.05, 0.2, 0.25), Vector3.new(0, 5.42, -4.35), trim)
part("WindshieldLeft", Vector3.new(0.27, 3, 0.34), Vector3.new(-4.3, 4.07, -4.35), trim)
part("WindshieldRight", Vector3.new(0.27, 3, 0.34), Vector3.new(4.3, 4.07, -4.35), trim)
part("WindshieldBottom", Vector3.new(8.9, 0.25, 0.25), Vector3.new(0, 2.72, -4.35), trim)

-- Rear and side window pillars give something to see when looking around.
for _, x in ipairs({-4.35, 4.35}) do
    part("DoorPillar", Vector3.new(0.26, 3.55, 0.3), Vector3.new(x, 4.01, 1.2), trim)
    part("RearPillar", Vector3.new(0.32, 3.5, 0.3), Vector3.new(x, 4.01, 4.9), trim)
end

for _, x in ipairs({-2.45, 2.45}) do
    for _, z in ipairs({-0.1, 3.2}) do
        part("SeatBase", Vector3.new(3, 0.5, 2.2), Vector3.new(x, 2.1, z), interior)
        part("SeatBack", Vector3.new(3, 2.45, 0.45), Vector3.new(x, 3.22, z + 0.88), interior)
        part("Headrest", Vector3.new(1.35, 0.8, 0.5), Vector3.new(x, 4.8, z + 0.88), interior)
    end
end

-- Wheels rotated so their axle points across the vehicle.
for _, x in ipairs({-4.55, 4.55}) do
    for _, z in ipairs({-4.45, 4.4}) do
        local wheel = part("Tire", Vector3.new(1.05, 2.25, 2.25), Vector3.new(x, 1.1, z),
            Color3.fromRGB(12, 13, 14), Enum.Material.Rubber, car, Enum.PartType.Cylinder)
        wheel.CFrame = CFrame.new(x, 1.1, z) * CFrame.Angles(0, 0, math.rad(90))
    end
end

local dial = part("DashboardClock", Vector3.new(1.1, 0.4, 0.08), Vector3.new(2.1, 3.07, -4.22),
    Color3.fromRGB(25, 65, 70), Enum.Material.Neon)
dial.CastShadow = false
local clockSurface = Instance.new("SurfaceGui")
clockSurface.Name = "ClockFace"
clockSurface.Face = Enum.NormalId.Back -- faces passengers inside the cabin
clockSurface.PixelsPerStud = 100
clockSurface.LightInfluence = 0
clockSurface.Parent = dial
local digits = Instance.new("TextLabel")
digits.BackgroundTransparency = 1
digits.Size = UDim2.fromScale(1, 1)
digits.Text = "03:17"
digits.Font = Enum.Font.Code
digits.TextScaled = true
digits.TextColor3 = Color3.fromRGB(166, 230, 218)
digits.Parent = clockSurface

-- Two headlights add depth to the dark road.
for _, x in ipairs({-3.1, 3.1}) do
    local lamp = part("Headlight", Vector3.new(1.55, 0.5, 0.17), Vector3.new(x, 2.35, -7.52),
        Color3.fromRGB(255, 228, 185), Enum.Material.Neon)
    lamp.CastShadow = false
    local spot = Instance.new("SpotLight")
    spot.Angle = 65
    spot.Range = 60
    spot.Brightness = 6
    spot.Color = Color3.fromRGB(248, 220, 180)
    spot.Face = Enum.NormalId.Front
    spot.Parent = lamp
end

-- Simple silhouette placeholders for nearby friends. Custom models come later.
local function friend(name, x, z, shirt)
    local group = Instance.new("Model")
    group.Name = "TEMP_" .. name
    group.Parent = car
    part("Body", Vector3.new(1.65, 1.75, 0.82), Vector3.new(x, 3.25, z), shirt,
        Enum.Material.Fabric, group)
    local head = part("Head", Vector3.new(0.78, 0.85, 0.78), Vector3.new(x, 4.55, z - 0.06),
        Color3.fromRGB(174, 134, 111), Enum.Material.SmoothPlastic, group, Enum.PartType.Ball)
    head.CanCollide = false
    return group
end
-- Seat 1 is the front passenger (no placeholder), the other three
-- occupied seats hide their NPC stand-ins when a human joins.
local driverNPC = friend("Driver_Danya", -2.35, -2.35, Color3.fromRGB(40, 48, 53))
local leraNPC = friend("Lera", -2.55, 3.65, Color3.fromRGB(75, 45, 55))
local sonyaNPC = friend("Sonya", 2.45, 3.65, Color3.fromRGB(53, 62, 65))
friend("Artem", 0, 5.35, Color3.fromRGB(48, 48, 39))
local npcForSeat = {[2] = driverNPC, [3] = sonyaNPC, [4] = leraNPC}
local function setNPCVisible(npc, visible)
    if not npc then return end
    for _, obj in ipairs(npc:GetDescendants()) do
        if obj:IsA("BasePart") then obj.Transparency = visible and 0 or 1 end
    end
end

local anchors = Instance.new("Folder")
anchors.Name = "CameraAnchors"
anchors.Parent = car
local seats = {
    Vector3.new(2.35, 4.34, -1.5), -- front passenger
    Vector3.new(-2.35, 4.34, -1.5), -- driver, prototype only
    Vector3.new(2.35, 4.34, 2.25), -- rear right
    Vector3.new(-2.35, 4.34, 2.25), -- rear left
}
for index, pos in ipairs(seats) do
    local anchor = part("Seat" .. index, Vector3.new(0.2, 0.2, 0.2), pos,
        Color3.fromRGB(255, 255, 255), Enum.Material.SmoothPlastic, anchors)
    anchor.Transparency = 1
end

local function atZ(z)
    return CFrame.new(0, START_Y, z)
end
car:PivotTo(atZ(BEGIN_Z))
car:SetAttribute("IntroState", "Waiting")
car:SetAttribute("Duration", DURATION)

local startTime = nil
local assigned = {}
local nextSeat = 1

local function elapsed()
    if not startTime then return 0 end
    return math.max(0, Workspace:GetServerTimeNow() - startTime)
end

remote.OnServerEvent:Connect(function(player, action)
    if action == "Start" then
        if assigned[player] then return end
        if nextSeat > 4 then
            warn("[TSN] Car intro prototype currently supports up to four human seats")
            return
        end
        local seat = nextSeat
        nextSeat += 1
        assigned[player] = seat
        setNPCVisible(npcForSeat[seat], false)
        if not startTime then
            startTime = Workspace:GetServerTimeNow() + 2.5
            car:SetAttribute("StartTime", startTime)
            car:SetAttribute("IntroState", "Driving")
        end
        remote:FireClient(player, "Begin", seat, startTime, DURATION)
    elseif action == "Exit" and assigned[player] then
        if elapsed() < DURATION - 0.6 then return end
        local character = player.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")
        if root then
            root.CFrame = CFrame.new(8, 3.5, END_Z + 1)
        end
        remote:FireClient(player, "Exited")
    end
end)

Players.PlayerRemoving:Connect(function(player)
    local seat = assigned[player]
    assigned[player] = nil
    if seat then setNPCVisible(npcForSeat[seat], true) end
end)

RunService.Heartbeat:Connect(function()
    if not startTime then return end
    local t = math.clamp(elapsed() / DURATION, 0, 1)
    -- The last seconds slow down as the engine dies.
    local distanceProgress = (t < 0.8)
        and (0.93 * (t / 0.8))
        or (0.93 + 0.07 * (1 - (1 - (t - 0.8) / 0.2) ^ 3))
    local z = BEGIN_Z + (END_Z - BEGIN_Z) * distanceProgress
    car:PivotTo(atZ(z))
    if t >= 1 and car:GetAttribute("IntroState") ~= "Stopped" then
        car:SetAttribute("IntroState", "Stopped")
        print("[THE SIXTH NIGHT] Car reached breakdown point")
    end
end)

print("[THE SIXTH NIGHT] Intro car server v0.2 READY")
