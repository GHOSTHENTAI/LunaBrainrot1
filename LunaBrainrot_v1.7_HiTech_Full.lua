
-- Energy Assault: LunaSoft Silent Aim + GlowESP v1.0
-- Автор: Кира 💙

-- ✅ Настрой: Aim работает только по ПКМ
-- ✅ Не целится сквозь стены и не по мертвым
-- ✅ Glow ESP только на врагов

-- Конфиг
local config = {
    fov = 90,
    aimBind = Enum.UserInputType.MouseButton2, -- ПКМ
    teamCheck = true,
    deadCheck = true,
    wallCheck = true,
    glowEnabled = true
}

-- Службы
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Функции
local function isAlive(player)
    local character = player.Character
    if not character then return false end
    local humanoid = character:FindFirstChildWhichIsA("Humanoid")
    return humanoid and humanoid.Health > 0
end

local function isVisible(pos)
    local ray = Ray.new(Camera.CFrame.Position, (pos - Camera.CFrame.Position).Unit * 999)
    local hit = workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character})
    return not hit or (hit.Transparency > 0.3 and hit.CanCollide == false)
end

local function getClosestPlayer()
    local closest, dist = nil, config.fov
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
            if config.teamCheck and player.Team == LocalPlayer.Team then continue end
            if config.deadCheck and not isAlive(player) then continue end

            local pos, onScreen = Camera:WorldToViewportPoint(player.Character.Head.Position)
            if not onScreen then continue end

            local mag = (Vector2.new(pos.X, pos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
            if mag < dist then
                if config.wallCheck and not isVisible(player.Character.Head.Position) then continue end
                closest, dist = player, mag
            end
        end
    end
    return closest
end

-- Silent Aim Hook
local mt = getrawmetatable(game)
setreadonly(mt, false)
local oldNamecall = mt.__namecall
mt.__namecall = newcclosure(function(self, ...)
    local args = {...}
    local method = getnamecallmethod()
    if method == "FindPartOnRayWithIgnoreList" and config.aiming then
        local target = getClosestPlayer()
        if target and target.Character then
            local head = target.Character:FindFirstChild("Head")
            if head then
                args[1] = Ray.new(Camera.CFrame.Position, (head.Position - Camera.CFrame.Position).Unit * 999)
                return oldNamecall(self, unpack(args))
            end
        end
    end
    return oldNamecall(self, ...)
end)

-- Glow ESP
if config.glowEnabled then
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local chr = player.Character or player.CharacterAdded:Wait()
            for _, part in pairs(chr:GetChildren()) do
                if part:IsA("BasePart") then
                    local glow = Instance.new("BoxHandleAdornment")
                    glow.Adornee = part
                    glow.AlwaysOnTop = true
                    glow.ZIndex = 5
                    glow.Size = part.Size + Vector3.new(0.1, 0.1, 0.1)
                    glow.Transparency = 0.3
                    glow.Color3 = Color3.fromRGB(255, 100, 255)
                    glow.Parent = part
                end
            end
        end
    end
end

-- FOV-отрисовка
local fovCircle = Drawing.new("Circle")
fovCircle.Radius = config.fov
fovCircle.Thickness = 1
fovCircle.Position = Vector2.new(Mouse.X, Mouse.Y + 36)
fovCircle.Visible = true
fovCircle.Color = Color3.fromRGB(255, 100, 255)
fovCircle.Transparency = 0.6
fovCircle.Filled = false

-- Aiming Detect
config.aiming = false
game:GetService("UserInputService").InputBegan:Connect(function(i)
    if i.UserInputType == config.aimBind then config.aiming = true end
end)
game:GetService("UserInputService").InputEnded:Connect(function(i)
    if i.UserInputType == config.aimBind then config.aiming = false end
end)
