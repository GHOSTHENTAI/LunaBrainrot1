
-- LunaBrainrot v1.8 — Full Build for Xeno Executor
-- Автор: Кира 🩷 (Xeno Ready, Discord Webhook Inject Notify)

-- ❗ Настройка Webhook для уведомления о запуске
local webhook = "https://discord.com/api/webhooks/XXXXXXXXX/XXXXXXXXXXXXXXXXXXXXX" -- ЗАМЕНИТЬ на свой

-- Уведомление при запуске
pcall(function()
    syn.request({
        Url = webhook,
        Method = "POST",
        Headers = {["Content-Type"] = "application/json"},
        Body = game:GetService("HttpService"):JSONEncode({
            content = "✅ **LunaBrainrot Injected!**\n👤 Игрок: " .. game.Players.LocalPlayer.Name .. "\n🕐 Время: " .. os.date("%d.%m.%Y %H:%M:%S"),
            username = "Luna Notify",
            avatar_url = "https://i.imgur.com/p3bSkqf.png"
        })
    })
end)

-- Службы
local srv = setmetatable({}, {__index = function(_, s) return game:GetService(s) end})
local plr = srv.Players.LocalPlayer
local chr = plr.Character or plr.CharacterAdded:Wait()
local hrp = chr:WaitForChild("HumanoidRootPart")
local hum = chr:WaitForChild("Humanoid")
local RS, TS, UIS, MS = srv.RunService, srv.TweenService, srv.UserInputService, plr:GetMouse()

-- UI
local ui = Instance.new("ScreenGui", game.CoreGui)
ui.Name = "LunaUI"
local frame = Instance.new("Frame", ui)
frame.Size = UDim2.new(0, 350, 0, 270)
frame.Position = UDim2.new(0.65, 0, 0.2, 0)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
frame.Active = true
frame.Draggable = true
frame.BorderSizePixel = 0

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 30)
title.Text = "🧠 LunaBrainrot v1.8"
title.TextColor3 = Color3.new(1,1,1)
title.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 20

-- Создание toggle-кнопок
local toggles = {}
local function makeToggle(name, ypos, callback)
    local btn = Instance.new("TextButton", frame)
    btn.Position = UDim2.new(0, 10, 0, ypos)
    btn.Size = UDim2.new(0, 330, 0, 30)
    btn.Text = "[ OFF ] " .. name
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 65)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.SourceSans
    btn.TextSize = 16
    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = (state and "[ ON  ] " or "[ OFF ] ") .. name
        callback(state)
    end)
    table.insert(toggles, btn)
end

-- Auto Grab
makeToggle("Auto Brain Grab", 40, function(on)
    if on then
        RS:BindToRenderStep("BrainGrab", Enum.RenderPriority.Character.Value, function()
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("ProximityPrompt") and v.Enabled and v.Parent then
                    local n = v.Parent.Name:lower()
                    if n:find("brain") or n:find("brainrot") or n:find("brainbox") then
                        local root = v.Parent:IsA("BasePart") and v.Parent or v.Parent:FindFirstChildWhichIsA("BasePart")
                        if root and (root.Position - hrp.Position).Magnitude <= 16 then
                            v.HoldDuration = 0
                            v:InputHoldBegin()
                            task.wait(0.04)
                            v:InputHoldEnd()
                        end
                    end
                end
            end
        end)
    else
        RS:UnbindFromRenderStep("BrainGrab")
    end
end)

-- TP-Walk
makeToggle("TP-Walk (M3)", 80, function(on)
    if not on then return end
    MS.Button3Down:Connect(function()
        local pos = MS.Hit.Position
        local aura = Instance.new("Part", workspace)
        aura.Anchored = true
        aura.CanCollide = false
        aura.Shape = Enum.PartType.Ball
        aura.Material = Enum.Material.Neon
        aura.Size = Vector3.new(2, 2, 2)
        aura.Color = Color3.fromRGB(200, 100, 255)
        aura.CFrame = CFrame.new(pos)
        game:GetService("Debris"):AddItem(aura, 0.6)

        TS:Create(hrp, TweenInfo.new((hrp.Position - pos).Magnitude / 100), {CFrame = CFrame.new(pos)}):Play()
    end)
end)

-- Noclip
makeToggle("NoClip Mode", 120, function(on)
    if on then
        RS:BindToRenderStep("noclip", 300, function()
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("BasePart") and not v:IsDescendantOf(chr) then
                    v.CanCollide = false
                end
            end
        end)
    else
        RS:UnbindFromRenderStep("noclip")
    end
end)

-- AntiStun
makeToggle("AntiStun + AntiFreeze", 160, function(on)
    if not on then return end
    RS.Heartbeat:Connect(function()
        if hum and hum.WalkSpeed < 10 then hum.WalkSpeed = 16 end
        hum.PlatformStand = false
    end)
end)

-- Обход ловушек и урона
for _, v in pairs(workspace:GetDescendants()) do
    if v:IsA("BasePart") and v.Name:lower():find("laser") or v.Name:lower():find("trap") then
        if v:FindFirstChildOfClass("TouchTransmitter") then v:FindFirstChildOfClass("TouchTransmitter"):Destroy() end
        for _, c in pairs(getconnections(v.Touched)) do c:Disable() end
    end
end

-- Готово
print("✅ LunaBrainrot v1.8 успешно загружен!")
