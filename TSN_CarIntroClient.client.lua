-- THE SIXTH NIGHT | Chapter I / Free-look vehicle intro / CLIENT v0.2
-- Place this LocalScript in StarterPlayer > StarterPlayerScripts.
-- Disable the OLD Chapter1_FirstBeat while testing this scene.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local legacy = player:WaitForChild("PlayerScripts"):FindFirstChild("Chapter1_FirstBeat")
if legacy and legacy:IsA("LocalScript") and legacy.Enabled then
    warn("[TSN] КОНФЛИКТ: Chapter1_FirstBeat включён! Останови Play и выключи его в StarterPlayerScripts.")
end
local event = ReplicatedStorage:WaitForChild("TSN_CarIntroEvent", 15)
local car = Workspace:WaitForChild("TSN_IntroCar", 15)
if not event or not car then
    warn("[TSN] Intro server missing: check TSN_CarIntro Script in ServerScriptService")
    return
end

local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local camera = Workspace.CurrentCamera
local oldSpeed = humanoid.WalkSpeed
local oldJumpPower = humanoid.JumpPower
local oldJumpHeight = humanoid.JumpHeight
local oldFov = camera.FieldOfView

-- Cinematic HUD, created locally for each participant.
local previousHUD = player:WaitForChild("PlayerGui"):FindFirstChild("TSN_CarIntroHUD")
if previousHUD then previousHUD:Destroy() end
local gui = Instance.new("ScreenGui")
gui.Name = "TSN_CarIntroHUD"
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false
gui.DisplayOrder = 110
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = player:WaitForChild("PlayerGui")

local function label(name, position, size, fontSize, font, color)
    local item = Instance.new("TextLabel")
    item.Name = name
    item.Position = position
    item.Size = size
    item.BackgroundTransparency = 1
    item.TextColor3 = color or Color3.fromRGB(230, 233, 235)
    item.TextStrokeColor3 = Color3.new(0, 0, 0)
    item.TextStrokeTransparency = 0.4
    item.TextTransparency = 1
    item.Font = font or Enum.Font.Gotham
    item.TextSize = fontSize
    item.TextWrapped = true
    item.Parent = gui
    return item
end

local chapter = label("Chapter", UDim2.fromScale(0.16, 0.25), UDim2.fromScale(0.68, 0.24),
    28, Enum.Font.GothamMedium)
chapter.Text = "ГЛАВА I\nПОСЛЕДНИЙ ВЕЧЕР"
chapter.TextXAlignment = Enum.TextXAlignment.Center
local subtitleBack = Instance.new("Frame")
subtitleBack.Name = "SubtitlePanel"
subtitleBack.AnchorPoint = Vector2.new(0.5, 1)
subtitleBack.Position = UDim2.fromScale(0.5, 0.93)
subtitleBack.Size = UDim2.fromScale(0.78, 0.105)
subtitleBack.BackgroundColor3 = Color3.fromRGB(8, 12, 17)
subtitleBack.BackgroundTransparency = 0.25
subtitleBack.BorderSizePixel = 0
subtitleBack.Visible = false
subtitleBack.Parent = gui
local rounded = Instance.new("UICorner")
rounded.CornerRadius = UDim.new(0, 7)
rounded.Parent = subtitleBack
local subtitle = label("Subtitle", UDim2.fromScale(0.04, 0.06), UDim2.fromScale(0.92, 0.88),
    19, Enum.Font.Gotham)
subtitle.Parent = subtitleBack
subtitle.TextXAlignment = Enum.TextXAlignment.Center
local hint = label("Hint", UDim2.fromScale(0.51, 0.08), UDim2.fromScale(0.45, 0.06),
    15, Enum.Font.Gotham)
hint.Text = "ВЕДИ МЫШЬЮ, ЧТОБЫ ОСМАТРИВАТЬСЯ"
hint.TextXAlignment = Enum.TextXAlignment.Right

local overlay = Instance.new("Frame")
overlay.Name = "FadeOverlay"
overlay.Size = UDim2.fromScale(1, 1)
overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
overlay.BackgroundTransparency = 0
-- The fade is drawn above the subtitles only during scene transitions.
overlay.ZIndex = 10
overlay.Parent = gui

local function fadeText(item, transparency, duration)
    TweenService:Create(item, TweenInfo.new(duration), {TextTransparency = transparency}):Play()
end
local function fadeScreen(transparency, duration)
    local tween = TweenService:Create(overlay, TweenInfo.new(duration), {BackgroundTransparency = transparency})
    tween:Play()
    tween.Completed:Wait()
end

local lines = {
    {at = 3.8, speaker = "ДАНЯ", text = "Ну и кто сказал, что это хорошая идея — ночью ехать в лес?"},
    {at = 8, speaker = "ЛЕРА", text = "Ты сам больше всех хотел сюда попасть."},
    {at = 12, speaker = "АРТЁМ", text = "...Мы уже проезжали этот поворот."},
    {at = 17, speaker = "МАКС", text = "Артём, ты чего? Мы здесь первый раз."},
    {at = 21, speaker = "АРТЁМ", text = "Тогда почему часы снова показывают 03:17?"},
    {at = 25.4, speaker = "ДАНЯ", text = "Подождите. Что-то с двигателем..."},
}

local active = false
local yaw = 0
local pitch = 0
local anchor = nil
local startTime = 0
local duration = 0
local lastLine = 0
local subtitleToken = 0
local stopRequested = false
local restored = false

local function restoreCamera()
    if restored then return end
    restored = true
    active = false
    camera.CameraType = Enum.CameraType.Custom
    camera.CameraSubject = humanoid
    camera.FieldOfView = oldFov
    humanoid.WalkSpeed = oldSpeed
    humanoid.JumpPower = oldJumpPower
    humanoid.JumpHeight = oldJumpHeight
    UserInputService.MouseIconEnabled = true
    pcall(function() RunService:UnbindFromRenderStep("TSN_CarIntroCamera") end)
    UserInputService.MouseBehavior = Enum.MouseBehavior.Default
end

UserInputService.InputChanged:Connect(function(input)
    if not active then return end
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        yaw = math.clamp(yaw - input.Delta.X * 0.0024, math.rad(-135), math.rad(135))
        pitch = math.clamp(pitch - input.Delta.Y * 0.0024, math.rad(-48), math.rad(57))
    end
end)

local function begin(seatNumber, when, timeLength)
    if active or restored then return end
    anchor = car:WaitForChild("CameraAnchors"):WaitForChild("Seat" .. tostring(seatNumber))
    startTime = when
    duration = timeLength
    active = true
    humanoid.WalkSpeed = 0
    humanoid.JumpPower = 0
    humanoid.JumpHeight = 0
    camera.CameraType = Enum.CameraType.Scriptable
    camera.FieldOfView = 73
    UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
    UserInputService.MouseIconEnabled = false
    print("[THE SIXTH NIGHT] Car intro client STARTED | seat " .. tostring(seatNumber))
    task.spawn(function()
        fadeScreen(1, 1.5)
        fadeText(chapter, 0, 1)
        task.wait(2.8)
        fadeText(chapter, 1, 0.7)
        fadeText(hint, 0, 0.3)
        task.wait(3)
        fadeText(hint, 1, 0.7)
    end)
end

event.OnClientEvent:Connect(function(action, a, b, c)
    if action == "Begin" then
        begin(a, b, c)
    elseif action == "Exited" then
        restoreCamera()
        task.spawn(function()
            fadeScreen(1, 1.2)
            task.wait(1.5)
            gui:Destroy()
        end)
        print("[THE SIXTH NIGHT] Car intro FINISHED; free walking restored")
    end
end)

RunService:BindToRenderStep("TSN_CarIntroCamera", Enum.RenderPriority.Camera.Value + 1, function()
    if not active or not anchor then return end
    UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
    camera.CFrame = anchor.CFrame * CFrame.Angles(pitch, yaw, 0)
    camera.Focus = camera.CFrame * CFrame.new(0, 0, -25)
    local elapsed = Workspace:GetServerTimeNow() - startTime
    if elapsed >= 0 then
        for index, item in ipairs(lines) do
            if index > lastLine and elapsed >= item.at then
                lastLine = index
                subtitleToken += 1
                local token = subtitleToken
                subtitleBack.Visible = true
                subtitle.TextTransparency = 1
                subtitle.Text = item.speaker .. ":  " .. item.text
                fadeText(subtitle, 0, 0.25)
                task.delay(3.1, function()
                    if subtitleToken ~= token then return end
                    local fade = TweenService:Create(subtitle, TweenInfo.new(0.3), {TextTransparency = 1})
                    fade:Play()
                    fade.Completed:Wait()
                    if subtitleToken == token then subtitleBack.Visible = false end
                end)
                break
            end
        end
    end
    if elapsed >= duration and not stopRequested then
        stopRequested = true
        task.spawn(function()
            subtitleToken += 1
            subtitleBack.Visible = true
            subtitle.TextTransparency = 1
            subtitle.Text = "Двигатель заглох. За окном — абсолютная тишина."
            fadeText(subtitle, 0, 0.3)
            task.wait(2.7)
            fadeScreen(0, 1)
            event:FireServer("Exit")
            -- Fail-safe: don't lock the player in an intro forever if the server fails.
            task.wait(4)
            if not restored then
                warn("[TSN] No exit acknowledgement. Restoring local camera.")
                restoreCamera()
                fadeScreen(1, 1)
            end
        end)
    end
end)

-- Wait until all client UI, anchors and camera code are ready before starting.
event:FireServer("Start")
print("[THE SIXTH NIGHT] Car intro client v0.2 READY")
