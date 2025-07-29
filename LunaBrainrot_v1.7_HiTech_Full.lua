
-- LunaBrainrot v1.7 | Hi-Tech + Aura TP + AntiStun + Bypass + Debug | by Кира

-- Bypass & AntiCheat Obfuscation Layer
local function secure(f) return newcclosure(f) end
local rawget = secure(rawget)
local rawset = secure(rawset)
local getgc = secure(getgc)
local getconnections = secure(getconnections)
local hookmetamethod = secure(hookmetamethod)
local getnamecallmethod = secure(getnamecallmethod)
local setnamecallmethod = secure(setnamecallmethod)
local isnetworkowner = secure(isnetworkowner or function() return true end)

-- Initialization
local srv = setmetatable({}, {__index = function(_, s) return game:GetService(s) end})
local plr = srv.Players.LocalPlayer
local chr = plr.Character or plr.CharacterAdded:Wait()
local hrp = chr:WaitForChild("HumanoidRootPart")
local UIS, RS, TS, MS = srv.UserInputService, srv.RunService, srv.TweenService, plr:GetMouse()
local hum = chr:FindFirstChildWhichIsA("Humanoid")
local aura = nil

-- UI - Hi-Tech Style
local ui = Instance.new("ScreenGui", game.CoreGui)
ui.Name = "LunaHiTech"

local frame = Instance.new("Frame", ui)
frame.Size = UDim2.new(0, 360, 0, 280)
frame.Position = UDim2.new(0.65, 0, 0.25, 0)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 30)
title.Text = "LunaBrainrot v1.7"
title.BackgroundColor3 = Color3.fromRGB(35, 35, 60)
title.TextColor3 = Color3.fromRGB(120, 200, 255)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 20

local function createToggle(label, yPos, callback)
    local btn = Instance.new("TextButton", frame)
    btn.Position = UDim2.new(0, 10, 0, yPos)
    btn.Size = UDim2.new(0, 340, 0, 30)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.SourceSans
    btn.TextSize = 16
    local state = false
    btn.Text = "[ OFF ] " .. label
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = (state and "[ ON  ] " or "[ OFF ] ") .. label
        callback(state)
    end)
end

-- AutoBrainGrab
createToggle("Auto Grab Brainrots", 40, function(enabled)
    RS:BindToRenderStep("BrainGrab", Enum.RenderPriority.Input.Value, function()
        if not enabled then return end
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("ProximityPrompt") and v.Enabled and v.Parent then
                local p = v.Parent
                local root = p:IsA("BasePart") and p or p:FindFirstChildWhichIsA("BasePart")
                if root and (root.Position - hrp.Position).Magnitude <= 18 then
                    local n = p.Name:lower()
                    if n:find("brain") or n:find("brainrot") or n:find("brainbox") then
                        p.HoldDuration = 0
                        v:InputHoldBegin()
                        task.wait(0.04)
                        v:InputHoldEnd()
                    end
                end
            end
        end
    end)
end)

-- TP Walk + Aura
createToggle("TP Walk (M3)", 80, function(state)
    if not state then return end
    MS.Button3Down:Connect(function()
        if aura then aura:Destroy() end
        local pos = MS.Hit and MS.Hit.p
        aura = Instance.new("Part", workspace)
        aura.Anchored = true
        aura.CanCollide = false
        aura.Shape = Enum.PartType.Ball
        aura.Material = Enum.Material.Neon
        aura.Color = Color3.fromRGB(150, 150, 255)
        aura.Size = Vector3.new(1.5,1.5,1.5)
        aura.CFrame = CFrame.new(pos)
        game:GetService("Debris"):AddItem(aura, 0.5)

        local dist = (hrp.Position - pos).Magnitude
        TS:Create(hrp, TweenInfo.new(dist / 100, Enum.EasingStyle.Linear), {CFrame = CFrame.new(pos)}):Play()
    end)
end)

-- AntiStun
createToggle("AntiStun / AntiSlow", 120, function(state)
    if not state then return end
    RS.Heartbeat:Connect(function()
        if hum then
            if hum.WalkSpeed < 10 then hum.WalkSpeed = 16 end
            if hum.JumpPower < 10 then hum.JumpPower = 50 end
            hum.PlatformStand = false
        end
    end)
end)

-- Noclip
createToggle("Full Noclip Mode", 160, function(state)
    if state then
        RS:BindToRenderStep("noclip", 201, function()
            for _, v in ipairs(workspace:GetDescendants()) do
                if v:IsA("BasePart") and not v:IsDescendantOf(chr) then
                    v.CanCollide = false
                end
            end
        end)
    else
        RS:UnbindFromRenderStep("noclip")
    end
end)

-- Trap Bypass
for _, v in pairs(workspace:GetDescendants()) do
    if v:IsA("BasePart") and (v.Name:lower():find("laser") or v.Name:lower():find("trap")) then
        v.CanTouch = false
        if v:FindFirstChildOfClass("TouchTransmitter") then v:FindFirstChildOfClass("TouchTransmitter"):Destroy() end
        for _, c in pairs(getconnections(v.Touched)) do c:Disable() end
    end
end

-- Debug: Show Object ID + Name (hovered)
local highlightGui = Instance.new("BillboardGui", game.CoreGui)
highlightGui.Size = UDim2.new(0, 200, 0, 50)
highlightGui.AlwaysOnTop = true
highlightGui.Enabled = false

local label = Instance.new("TextLabel", highlightGui)
label.Size = UDim2.new(1, 0, 1, 0)
label.TextColor3 = Color3.new(1, 1, 1)
label.BackgroundTransparency = 1
label.TextScaled = true

RS.RenderStepped:Connect(function()
    local closest = nil
    local dist = math.huge
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") and (v.Position - hrp.Position).Magnitude < dist then
            dist = (v.Position - hrp.Position).Magnitude
            closest = v
        end
    end
    if closest and dist < 15 then
        highlightGui.Enabled = true
        highlightGui.Adornee = closest
        label.Text = "ID: " .. closest:GetDebugId() .. "\n" .. closest:GetFullName()
    else
        highlightGui.Enabled = false
    end
end)
