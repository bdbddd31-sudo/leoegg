-- // =============================================
-- // StealAnEgg | leoegg v1.0
-- // Game: Steal An Egg | PlaceID: 107778070777162
-- // Executor: Delta | Author: Hacking Everything
-- // =============================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local Humanoid = Character:WaitForChild("Humanoid")

-- // =============================================
-- // CONFIG
-- // =============================================
local CONFIG = {
    AutoSteal = false,
    SlowDistance = 18,        -- distance to start slowing down (before detection line)
    SafeDistance = 20,         -- distance to stop completely (avoid red text trigger)
    StealSpeed = 36,           -- walk speed when going to egg
    SlowSpeed = 8,             -- speed when near detection zone
    ReturnSpeed = 50,          -- speed when returning to base
    TargetEgg = nil,           -- will be auto-detected
    StealCooldown = 1.2,
}

-- // =============================================
-- // GUI BUILD - Yuta Okkotsu Theme (JJK)
-- // =============================================

-- cleanup old GUI
pcall(function()
    if LocalPlayer.PlayerGui:FindFirstChild("leoegg_GUI") then
        LocalPlayer.PlayerGui.leoegg_GUI:Destroy()
    end
end)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "leoegg_GUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = LocalPlayer.PlayerGui

-- // Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 320, 0, 400)
MainFrame.Position = UDim2.new(0.03, 0, 0.12, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(8, 8, 14)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

-- purple-blue border glow (Yuta's cursed energy)
local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(120, 60, 220)
MainStroke.Thickness = 1.5
MainStroke.Transparency = 0.2
MainStroke.Parent = MainFrame

-- // Header
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 90)
Header.BackgroundColor3 = Color3.fromRGB(14, 10, 28)
Header.BorderSizePixel = 0
Header.Parent = MainFrame

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 10)
HeaderCorner.Parent = Header

-- fix bottom corners of header
local HeaderFix = Instance.new("Frame")
HeaderFix.Size = UDim2.new(1, 0, 0.5, 0)
HeaderFix.Position = UDim2.new(0, 0, 0.5, 0)
HeaderFix.BackgroundColor3 = Color3.fromRGB(14, 10, 28)
HeaderFix.BorderSizePixel = 0
HeaderFix.Parent = Header

-- Yuta avatar image
local YutaImage = Instance.new("ImageLabel")
YutaImage.Size = UDim2.new(0, 60, 0, 60)
YutaImage.Position = UDim2.new(0, 15, 0, 15)
YutaImage.BackgroundColor3 = Color3.fromRGB(20, 12, 40)
YutaImage.BorderSizePixel = 0
-- Yuta Okkotsu official Roblox decal (JJK) — using closest available asset
-- Note: replace with your preferred Yuta image ID if you have one uploaded
YutaImage.Image = "rbxassetid://14978437619" -- Yuta JJK character decal
YutaImage.ScaleType = Enum.ScaleType.Fit
YutaImage.Parent = Header

local YutaCorner = Instance.new("UICorner")
YutaCorner.CornerRadius = UDim.new(1, 0)
YutaCorner.Parent = YutaImage

local YutaStroke = Instance.new("UIStroke")
YutaStroke.Color = Color3.fromRGB(140, 80, 255)
YutaStroke.Thickness = 2
YutaStroke.Parent = YutaImage

-- Title
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(0, 200, 0, 28)
TitleLabel.Position = UDim2.new(0, 85, 0, 14)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "leoegg"
TitleLabel.TextColor3 = Color3.fromRGB(200, 160, 255)
TitleLabel.TextSize = 18
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = Header

local SubLabel = Instance.new("TextLabel")
SubLabel.Size = UDim2.new(0, 200, 0, 20)
SubLabel.Position = UDim2.new(0, 85, 0, 42)
SubLabel.BackgroundTransparency = 1
SubLabel.Text = "Steal An Egg | by Hacking Everything"
SubLabel.TextColor3 = Color3.fromRGB(120, 90, 180)
SubLabel.TextSize = 10
SubLabel.Font = Enum.Font.Gotham
SubLabel.TextXAlignment = Enum.TextXAlignment.Left
SubLabel.Parent = Header

-- close button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 26, 0, 26)
CloseBtn.Position = UDim2.new(1, -34, 0, 8)
CloseBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 80)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 13
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.BorderSizePixel = 0
CloseBtn.Parent = Header

local CloseBtnCorner = Instance.new("UICorner")
CloseBtnCorner.CornerRadius = UDim.new(0, 6)
CloseBtnCorner.Parent = CloseBtn

CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- // Divider
local Divider = Instance.new("Frame")
Divider.Size = UDim2.new(0.9, 0, 0, 1)
Divider.Position = UDim2.new(0.05, 0, 0, 95)
Divider.BackgroundColor3 = Color3.fromRGB(80, 40, 160)
Divider.BorderSizePixel = 0
Divider.Parent = MainFrame

-- // Helper: create toggle button
local function CreateToggle(parent, labelText, yPos, callback)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(0.9, 0, 0, 44)
    ToggleFrame.Position = UDim2.new(0.05, 0, 0, yPos)
    ToggleFrame.BackgroundColor3 = Color3.fromRGB(18, 12, 35)
    ToggleFrame.BorderSizePixel = 0
    ToggleFrame.Parent = parent

    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(0, 8)
    ToggleCorner.Parent = ToggleFrame

    local ToggleLabel = Instance.new("TextLabel")
    ToggleLabel.Size = UDim2.new(0.72, 0, 1, 0)
    ToggleLabel.Position = UDim2.new(0.04, 0, 0, 0)
    ToggleLabel.BackgroundTransparency = 1
    ToggleLabel.Text = labelText
    ToggleLabel.TextColor3 = Color3.fromRGB(210, 190, 240)
    ToggleLabel.TextSize = 12
    ToggleLabel.Font = Enum.Font.Gotham
    ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
    ToggleLabel.Parent = ToggleFrame

    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Size = UDim2.new(0, 46, 0, 24)
    ToggleBtn.Position = UDim2.new(1, -54, 0.5, -12)
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 30, 80)
    ToggleBtn.Text = "OFF"
    ToggleBtn.TextColor3 = Color3.fromRGB(180, 140, 220)
    ToggleBtn.TextSize = 10
    ToggleBtn.Font = Enum.Font.GothamBold
    ToggleBtn.BorderSizePixel = 0
    ToggleBtn.Parent = ToggleFrame

    local ToggleBtnCorner = Instance.new("UICorner")
    ToggleBtnCorner.CornerRadius = UDim.new(0, 12)
    ToggleBtnCorner.Parent = ToggleBtn

    local state = false
    ToggleBtn.MouseButton1Click:Connect(function()
        state = not state
        if state then
            ToggleBtn.BackgroundColor3 = Color3.fromRGB(100, 50, 200)
            ToggleBtn.Text = "ON"
            ToggleBtn.TextColor3 = Color3.fromRGB(220, 200, 255)
        else
            ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 30, 80)
            ToggleBtn.Text = "OFF"
            ToggleBtn.TextColor3 = Color3.fromRGB(180, 140, 220)
        end
        callback(state)
    end)

    return ToggleFrame, ToggleBtn
end

-- // Status label
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(0.9, 0, 0, 26)
StatusLabel.Position = UDim2.new(0.05, 0, 0, 105)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "⬡  Status: Idle"
StatusLabel.TextColor3 = Color3.fromRGB(140, 100, 200)
StatusLabel.TextSize = 11
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.Parent = MainFrame

local function SetStatus(text, color)
    StatusLabel.Text = "⬡  Status: " .. text
    StatusLabel.TextColor3 = color or Color3.fromRGB(140, 100, 200)
end

-- // Toggles
CreateToggle(MainFrame, "🥚  Auto Steal Egg", 138, function(on)
    CONFIG.AutoSteal = on
    if on then
        SetStatus("Hunting egg...", Color3.fromRGB(160, 120, 255))
    else
        SetStatus("Idle", Color3.fromRGB(140, 100, 200))
    end
end)

CreateToggle(MainFrame, "⚡  Max Speed (Treadmill)", 192, function(on)
    if on then
        Humanoid.WalkSpeed = 100
        SetStatus("Speed boosted", Color3.fromRGB(200, 160, 255))
    else
        Humanoid.WalkSpeed = 16
        SetStatus("Normal speed", Color3.fromRGB(140, 100, 200))
    end
end)

CreateToggle(MainFrame, "🔁  Auto Return to Base", 246, function(on)
    CONFIG.AutoReturn = on
end)

-- // Teleport to Base button
local TeleportBtn = Instance.new("TextButton")
TeleportBtn.Size = UDim2.new(0.9, 0, 0, 38)
TeleportBtn.Position = UDim2.new(0.05, 0, 0, 300)
TeleportBtn.BackgroundColor3 = Color3.fromRGB(70, 30, 140)
TeleportBtn.Text = "⬡  Teleport to My Base"
TeleportBtn.TextColor3 = Color3.fromRGB(220, 200, 255)
TeleportBtn.TextSize = 12
TeleportBtn.Font = Enum.Font.GothamBold
TeleportBtn.BorderSizePixel = 0
TeleportBtn.Parent = MainFrame

local TeleportBtnCorner = Instance.new("UICorner")
TeleportBtnCorner.CornerRadius = UDim.new(0, 8)
TeleportBtnCorner.Parent = TeleportBtn

-- // Footer
local FooterLabel = Instance.new("TextLabel")
FooterLabel.Size = UDim2.new(1, 0, 0, 26)
FooterLabel.Position = UDim2.new(0, 0, 1, -28)
FooterLabel.BackgroundTransparency = 1
FooterLabel.Text = "leoegg v1.0  |  JJK: Yuta Okkotsu"
FooterLabel.TextColor3 = Color3.fromRGB(80, 55, 120)
FooterLabel.TextSize = 10
FooterLabel.Font = Enum.Font.Gotham
FooterLabel.Parent = MainFrame

-- dragging
local dragging, dragInput, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

-- // =============================================
-- // CORE LOGIC - Auto Steal with slow-approach
-- // =============================================

-- Find the closest unowned egg in the map
local function FindClosestEgg()
    local closestEgg = nil
    local closestDist = math.huge

    -- eggs can be in workspace under various folders
    -- common naming in StealAnEgg: Eggs folder or loose Parts named *Egg*
    local folders = {"Eggs", "World", "Bases", "Map"}
    local workspace = game:GetService("Workspace")

    local function scanDescendants(parent)
        for _, v in ipairs(parent:GetDescendants()) do
            if v:IsA("BasePart") or v:IsA("Model") then
                local name = v.Name:lower()
                if name:find("egg") and not name:find("mine") then
                    local pos
                    if v:IsA("Model") and v.PrimaryPart then
                        pos = v.PrimaryPart.Position
                    elseif v:IsA("BasePart") then
                        pos = v.Position
                    end
                    if pos then
                        local dist = (HumanoidRootPart.Position - pos).Magnitude
                        if dist < closestDist then
                            closestDist = dist
                            closestEgg = v
                        end
                    end
                end
            end
        end
    end

    scanDescendants(workspace)
    return closestEgg, closestDist
end

-- Find player's own base (spawn point or base part)
local function FindMyBase()
    local workspace = game:GetService("Workspace")
    -- look for base associated with LocalPlayer's name or "SpawnLocation"
    for _, v in ipairs(workspace:GetDescendants()) do
        local name = v.Name:lower()
        if (name:find("spawn") or name:find("base") or name:find("start")) then
            if v:IsA("BasePart") or v:IsA("SpawnLocation") then
                return v
            end
        end
    end
    -- fallback: player's team base by proximity at game start
    return nil
end

-- Smooth move toward a position with speed control
local function MoveToward(targetPos, speed)
    Humanoid.WalkSpeed = speed
    Humanoid:MoveTo(targetPos)
end

-- State machine
local StealState = "idle"  -- idle | approaching | stealing | returning
local lastSteal = 0
local MyBase = nil

-- Teleport to base button logic
TeleportBtn.MouseButton1Click:Connect(function()
    local base = FindMyBase()
    if base then
        HumanoidRootPart.CFrame = CFrame.new(base.Position + Vector3.new(0, 5, 0))
        SetStatus("Teleported to base", Color3.fromRGB(160, 220, 160))
    else
        -- fallback: teleport to spawn
        local spawn = game:GetService("Workspace"):FindFirstChildOfClass("SpawnLocation")
        if spawn then
            HumanoidRootPart.CFrame = CFrame.new(spawn.Position + Vector3.new(0, 5, 0))
        end
        SetStatus("No base found, used spawn", Color3.fromRGB(220, 200, 120))
    end
end)

-- // MAIN LOOP
RunService.Heartbeat:Connect(function()
    -- refresh refs on respawn
    Character = LocalPlayer.Character
    if not Character then return end
    HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
    Humanoid = Character:FindFirstChildOfClass("Humanoid")
    if not HumanoidRootPart or not Humanoid then return end

    if not CONFIG.AutoSteal then
        StealState = "idle"
        return
    end

    local now = tick()
    local egg, dist = FindClosestEgg()

    if StealState == "idle" or StealState == "approaching" then
        if not egg then
            SetStatus("No egg found...", Color3.fromRGB(140, 100, 200))
            return
        end

        local eggPos
        if egg:IsA("Model") and egg.PrimaryPart then
            eggPos = egg.PrimaryPart.Position
        elseif egg:IsA("BasePart") then
            eggPos = egg.Position
        else
            return
        end

        StealState = "approaching"

        -- // KEY MECHANIC: slow down before the detection line
        -- dist > SafeDistance: full speed
        -- SlowDistance > dist > SafeDistance: gradually slow (lerp)
        -- dist <= SafeDistance: creep at SlowSpeed to avoid red text

        if dist > CONFIG.SlowDistance then
            -- far away, run fast
            MoveToward(eggPos, CONFIG.StealSpeed)
            SetStatus("Running to egg... " .. math.floor(dist) .. "m", Color3.fromRGB(160, 120, 255))
        elseif dist > CONFIG.SafeDistance then
            -- in the danger zone: lerp speed down
            local t = (dist - CONFIG.SafeDistance) / (CONFIG.SlowDistance - CONFIG.SafeDistance)
            local blendSpeed = CONFIG.SlowSpeed + (CONFIG.StealSpeed - CONFIG.SlowSpeed) * t
            MoveToward(eggPos, math.floor(blendSpeed))
            SetStatus("Slowing down... " .. math.floor(dist) .. "m", Color3.fromRGB(220, 180, 80))
        else
            -- inside safe zone, creep in
            -- stop just at edge, wait a tick, then step to pick up
            Humanoid.WalkSpeed = CONFIG.SlowSpeed
            MoveToward(eggPos, CONFIG.SlowSpeed)
            SetStatus("Creeping to egg...", Color3.fromRGB(220, 160, 60))

            -- if close enough to pick up
            if dist < 6 and now - lastSteal > CONFIG.StealCooldown then
                lastSteal = now
                StealState = "stealing"
                -- fire the egg interaction remotely
                -- StealAnEgg typically uses a ProximityPrompt or a RemoteEvent "StealEgg"
                -- Try both approaches:
                local remotes = game:GetService("ReplicatedStorage")
                -- method 1: ProximityPrompt trigger
                local function triggerProximity(obj)
                    for _, v in ipairs(obj:GetDescendants()) do
                        if v:IsA("ProximityPrompt") then
                            fireproximityprompt(v)
                            return true
                        end
                    end
                    return false
                end

                if not triggerProximity(egg) then
                    -- method 2: RemoteEvent
                    local stealRemote = remotes:FindFirstChild("StealEgg")
                        or remotes:FindFirstChild("Steal")
                        or remotes:FindFirstChild("PickupEgg")
                    if stealRemote and stealRemote:IsA("RemoteEvent") then
                        stealRemote:FireServer(egg)
                    end
                end

                SetStatus("🥚 Egg stolen! Returning...", Color3.fromRGB(120, 220, 120))
                StealState = "returning"
            end
        end

    elseif StealState == "returning" then
        -- // RETURN: fast teleport toward own base
        local base = FindMyBase()
        if base then
            MyBase = base
        end

        if MyBase then
            local baseDist = (HumanoidRootPart.Position - MyBase.Position).Magnitude
            if baseDist > 10 then
                MoveToward(MyBase.Position, CONFIG.ReturnSpeed)
                SetStatus("Returning fast... " .. math.floor(baseDist) .. "m", Color3.fromRGB(100, 200, 255))
            else
                -- arrived at base
                Humanoid.WalkSpeed = 16
                StealState = "idle"
                SetStatus("✔ Delivered! Ready.", Color3.fromRGB(140, 240, 160))
            end
        else
            -- no base found, reset
            Humanoid.WalkSpeed = 16
            StealState = "idle"
            SetStatus("Base not found. Idle.", Color3.fromRGB(200, 140, 80))
        end
    end
end)

-- // =============================================
-- // NOTIFY ON LOAD
-- // =============================================
SetStatus("Loaded. Toggle to start.", Color3.fromRGB(160, 120, 255))

-- Optional: game notification if supported
pcall(function()
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "leoegg";
        Text = "StealAnEgg script loaded ✓";
        Duration = 4;
    })
end)

print("[leoegg] StealAnEgg hack loaded. PlaceID: 107778070777162")

-- // =============================================
-- // GOJO SATORU - EGG ATLAS PANEL (top-right)
-- // =============================================

-- // Egg database - all known eggs/pets with rarity, size, income
local EGG_DATA = {
    -- Forest
    { name="Chicken",              rarity="Common",    biome="Forest",     size="Small",  income="$1/s"    },
    { name="Dog",                  rarity="Common",    biome="Forest",     size="Small",  income="$2/s"    },
    { name="Bird",                 rarity="Uncommon",  biome="Forest",     size="Small",  income="$8/s"    },
    { name="Owl",                  rarity="Rare",      biome="Forest",     size="Medium", income="$35/s"   },
    { name="Raccoon",              rarity="Rare",      biome="Forest",     size="Medium", income="$45/s"   },
    { name="Fox",                  rarity="Epic",      biome="Forest",     size="Medium", income="$180/s"  },
    { name="Brr Brr Patapim",      rarity="Legendary", biome="Forest",     size="Large",  income="$1.8K/s" },
    -- Lake
    { name="Frog",                 rarity="Common",    biome="Lake",       size="Small",  income="$3/s"    },
    { name="Catfish",              rarity="Uncommon",  biome="Lake",       size="Small",  income="$12/s"   },
    { name="Turtle",               rarity="Rare",      biome="Lake",       size="Medium", income="$60/s"   },
    { name="Trulimero Trulicina",  rarity="Epic",      biome="Lake",       size="Large",  income="$260/s"  },
    -- Desert
    { name="Jerboa",               rarity="Common",    biome="Desert",     size="Small",  income="$6/s"    },
    { name="Camel",                rarity="Rare",      biome="Desert",     size="Large",  income="$75/s"   },
    { name="Sand Spider",          rarity="Mythic",    biome="Desert",     size="Large",  income="$16K/s"  },
    -- Jungle
    { name="Toucan",               rarity="Rare",      biome="Jungle",     size="Small",  income="$110/s"  },
    { name="Chimpanzee",           rarity="Rare",      biome="Jungle",     size="Medium", income="$90/s"   },
    { name="Crocodile",            rarity="Epic",      biome="Jungle",     size="Large",  income="$420/s"  },
    { name="Gorilla",              rarity="Legendary", biome="Jungle",     size="Large",  income="$4.8K/s" },
    { name="Orangutini Ananassini",rarity="Legendary", biome="Jungle",     size="Large",  income="$5.5K/s" },
    { name="Spider",               rarity="Mythic",    biome="Jungle",     size="Large",  income="$22K/s"  },
    -- Snow
    { name="Walrus",               rarity="Epic",      biome="Snow",       size="Large",  income="$600/s"  },
    { name="Polar Bear",           rarity="Legendary", biome="Snow",       size="Large",  income="$7K/s"   },
    { name="Sabertooth Tiger",     rarity="Mythic",    biome="Snow",       size="Huge",   income="$35K/s"  },
    { name="Mammoth",              rarity="Mythic",    biome="Snow",       size="Huge",   income="$42K/s"  },
    -- Volcano
    { name="Lava Lizard",          rarity="Rare",      biome="Volcano",    size="Medium", income="$200/s"  },
    { name="Phoenix",              rarity="Legendary", biome="Volcano",    size="Large",  income="$9K/s"   },
    { name="Fire Dragon",          rarity="Mythic",    biome="Volcano",    size="Huge",   income="$55K/s"  },
    -- Abyss Ocean
    { name="Shark",                rarity="Epic",      biome="Abyss",      size="Large",  income="$1.2K/s" },
    { name="Leviathan",            rarity="Legendary", biome="Abyss",      size="Huge",   income="$12K/s"  },
    { name="Mosasaurus",           rarity="Mythic",    biome="Abyss",      size="Huge",   income="$80K/s"  },
    -- Prehistoric
    { name="Ankylosaurus",         rarity="Legendary", biome="Prehistoric",size="Huge",   income="$18K/s"  },
    { name="Bronto",               rarity="Mythic",    biome="Prehistoric",size="Huge",   income="$100K/s" },
    -- Cosmic
    { name="Unicorn",              rarity="Legendary", biome="Cosmic",     size="Large",  income="$25K/s"  },
    { name="Ice Dragon",           rarity="Mythic",    biome="Cosmic",     size="Huge",   income="$150K/s" },
    -- Titan Temple
    { name="Cerberus",             rarity="Divine",    biome="TitanTemple",size="Huge",   income="$8M/s"   },
    { name="King Snake",           rarity="Mythic",    biome="TitanTemple",size="Huge",   income="$500K/s" },
    { name="Gorilla King",         rarity="Legendary", biome="TitanTemple",size="Huge",   income="$200K/s" },
    { name="Royal Sphinx",         rarity="Mythic",    biome="TitanTemple",size="Huge",   income="$350K/s" },
    { name="El Maja",              rarity="Divine",    biome="TitanTemple",size="Huge",   income="$5M/s"   },
}

-- rarity → color
local RARITY_COLOR = {
    Common    = Color3.fromRGB(180, 180, 180),
    Uncommon  = Color3.fromRGB(80,  200, 80),
    Rare      = Color3.fromRGB(60,  140, 240),
    Epic      = Color3.fromRGB(160, 60,  240),
    Legendary = Color3.fromRGB(255, 180, 30),
    Mythic    = Color3.fromRGB(255, 80,  80),
    Divine    = Color3.fromRGB(255, 220, 255),
}

-- // Atlas Panel Frame (top-right corner)
local AtlasOpen = false

-- Gojo button (icon, top-right)
local GojoBtn = Instance.new("ImageButton")
GojoBtn.Name = "GojoBtn"
GojoBtn.Size = UDim2.new(0, 58, 0, 58)
GojoBtn.Position = UDim2.new(1, -70, 0, 10)
GojoBtn.BackgroundColor3 = Color3.fromRGB(6, 6, 20)
GojoBtn.BorderSizePixel = 0
GojoBtn.Image = "rbxassetid://14345636268" -- Gojo Satoru JJK face decal
GojoBtn.ScaleType = Enum.ScaleType.Fit
GojoBtn.Parent = ScreenGui

local GojoBtnCorner = Instance.new("UICorner")
GojoBtnCorner.CornerRadius = UDim.new(1, 0)
GojoBtnCorner.Parent = GojoBtn

local GojoBtnStroke = Instance.new("UIStroke")
GojoBtnStroke.Color = Color3.fromRGB(0, 200, 255)
GojoBtnStroke.Thickness = 2.5
GojoBtnStroke.Parent = GojoBtn

-- tooltip
local GojoTip = Instance.new("TextLabel")
GojoTip.Size = UDim2.new(0, 90, 0, 20)
GojoTip.Position = UDim2.new(1, -168, 0, 24)
GojoTip.BackgroundTransparency = 1
GojoTip.Text = "🥚 Egg Atlas"
GojoTip.TextColor3 = Color3.fromRGB(0, 200, 255)
GojoTip.TextSize = 11
GojoTip.Font = Enum.Font.GothamBold
GojoTip.Parent = ScreenGui

-- Atlas panel
local AtlasFrame = Instance.new("Frame")
AtlasFrame.Name = "AtlasFrame"
AtlasFrame.Size = UDim2.new(0, 400, 0, 520)
AtlasFrame.Position = UDim2.new(1, -415, 0, 76)
AtlasFrame.BackgroundColor3 = Color3.fromRGB(5, 7, 20)
AtlasFrame.BorderSizePixel = 0
AtlasFrame.ClipsDescendants = true
AtlasFrame.Visible = false
AtlasFrame.Parent = ScreenGui

local AtlasCorner = Instance.new("UICorner")
AtlasCorner.CornerRadius = UDim.new(0, 12)
AtlasCorner.Parent = AtlasFrame

local AtlasStroke = Instance.new("UIStroke")
AtlasStroke.Color = Color3.fromRGB(0, 180, 255)
AtlasStroke.Thickness = 1.5
AtlasStroke.Transparency = 0.2
AtlasStroke.Parent = AtlasFrame

-- Atlas header
local AtlasHeader = Instance.new("Frame")
AtlasHeader.Size = UDim2.new(1, 0, 0, 54)
AtlasHeader.BackgroundColor3 = Color3.fromRGB(8, 10, 30)
AtlasHeader.BorderSizePixel = 0
AtlasHeader.Parent = AtlasFrame

local AtlasHeaderCorner = Instance.new("UICorner")
AtlasHeaderCorner.CornerRadius = UDim.new(0, 12)
AtlasHeaderCorner.Parent = AtlasHeader

local AtlasHeaderFix = Instance.new("Frame")
AtlasHeaderFix.Size = UDim2.new(1, 0, 0.5, 0)
AtlasHeaderFix.Position = UDim2.new(0, 0, 0.5, 0)
AtlasHeaderFix.BackgroundColor3 = Color3.fromRGB(8, 10, 30)
AtlasHeaderFix.BorderSizePixel = 0
AtlasHeaderFix.Parent = AtlasHeader

local AtlasTitle = Instance.new("TextLabel")
AtlasTitle.Size = UDim2.new(0.8, 0, 1, 0)
AtlasTitle.Position = UDim2.new(0.05, 0, 0, 0)
AtlasTitle.BackgroundTransparency = 1
AtlasTitle.Text = "🥚  Egg Atlas  —  Gojo Edition"
AtlasTitle.TextColor3 = Color3.fromRGB(0, 220, 255)
AtlasTitle.TextSize = 14
AtlasTitle.Font = Enum.Font.GothamBold
AtlasTitle.TextXAlignment = Enum.TextXAlignment.Left
AtlasTitle.Parent = AtlasHeader

-- close atlas
local AtlasClose = Instance.new("TextButton")
AtlasClose.Size = UDim2.new(0, 26, 0, 26)
AtlasClose.Position = UDim2.new(1, -34, 0.5, -13)
AtlasClose.BackgroundColor3 = Color3.fromRGB(180, 50, 80)
AtlasClose.Text = "✕"
AtlasClose.TextColor3 = Color3.fromRGB(255, 255, 255)
AtlasClose.TextSize = 12
AtlasClose.Font = Enum.Font.GothamBold
AtlasClose.BorderSizePixel = 0
AtlasClose.Parent = AtlasHeader

local AtlasCloseCorner = Instance.new("UICorner")
AtlasCloseCorner.CornerRadius = UDim.new(0, 6)
AtlasCloseCorner.Parent = AtlasClose

-- column labels
local ColBar = Instance.new("Frame")
ColBar.Size = UDim2.new(1, 0, 0, 26)
ColBar.Position = UDim2.new(0, 0, 0, 54)
ColBar.BackgroundColor3 = Color3.fromRGB(10, 14, 40)
ColBar.BorderSizePixel = 0
ColBar.Parent = AtlasFrame

local function MakeColLabel(text, xScale, wScale)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(wScale, 0, 1, 0)
    l.Position = UDim2.new(xScale, 0, 0, 0)
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextColor3 = Color3.fromRGB(0, 180, 255)
    l.TextSize = 10
    l.Font = Enum.Font.GothamBold
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = ColBar
end

MakeColLabel("  Pet / Egg",  0,    0.32)
MakeColLabel("Rarity",       0.32, 0.18)
MakeColLabel("Biome",        0.50, 0.16)
MakeColLabel("Size",         0.66, 0.12)
MakeColLabel("Income",       0.78, 0.14)
MakeColLabel("Steal",        0.92, 0.08)

-- Scrolling list
local AtlasScroll = Instance.new("ScrollingFrame")
AtlasScroll.Size = UDim2.new(1, 0, 1, -82)
AtlasScroll.Position = UDim2.new(0, 0, 0, 82)
AtlasScroll.BackgroundTransparency = 1
AtlasScroll.BorderSizePixel = 0
AtlasScroll.ScrollBarThickness = 4
AtlasScroll.ScrollBarImageColor3 = Color3.fromRGB(0, 160, 220)
AtlasScroll.CanvasSize = UDim2.new(0, 0, 0, #EGG_DATA * 40 + 10)
AtlasScroll.Parent = AtlasFrame

local ListLayout = Instance.new("UIListLayout")
ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
ListLayout.Padding = UDim.new(0, 2)
ListLayout.Parent = AtlasScroll

-- Build rows
for i, egg in ipairs(EGG_DATA) do
    local rowBg = (i % 2 == 0)
        and Color3.fromRGB(10, 10, 26)
        or  Color3.fromRGB(14, 14, 34)

    local Row = Instance.new("Frame")
    Row.Size = UDim2.new(1, -8, 0, 38)
    Row.BackgroundColor3 = rowBg
    Row.BorderSizePixel = 0
    Row.LayoutOrder = i
    Row.Parent = AtlasScroll

    local RowCorner = Instance.new("UICorner")
    RowCorner.CornerRadius = UDim.new(0, 6)
    RowCorner.Parent = Row

    -- pet name
    local NameLbl = Instance.new("TextLabel")
    NameLbl.Size = UDim2.new(0.32, 0, 1, 0)
    NameLbl.Position = UDim2.new(0, 6, 0, 0)
    NameLbl.BackgroundTransparency = 1
    NameLbl.Text = egg.name
    NameLbl.TextColor3 = Color3.fromRGB(220, 220, 240)
    NameLbl.TextSize = 10
    NameLbl.Font = Enum.Font.Gotham
    NameLbl.TextXAlignment = Enum.TextXAlignment.Left
    NameLbl.TextTruncate = Enum.TextTruncate.AtEnd
    NameLbl.Parent = Row

    -- rarity
    local RarityLbl = Instance.new("TextLabel")
    RarityLbl.Size = UDim2.new(0.18, 0, 1, 0)
    RarityLbl.Position = UDim2.new(0.32, 0, 0, 0)
    RarityLbl.BackgroundTransparency = 1
    RarityLbl.Text = egg.rarity
    RarityLbl.TextColor3 = RARITY_COLOR[egg.rarity] or Color3.fromRGB(200, 200, 200)
    RarityLbl.TextSize = 9
    RarityLbl.Font = Enum.Font.GothamBold
    RarityLbl.TextXAlignment = Enum.TextXAlignment.Left
    RarityLbl.Parent = Row

    -- biome
    local BiomeLbl = Instance.new("TextLabel")
    BiomeLbl.Size = UDim2.new(0.16, 0, 1, 0)
    BiomeLbl.Position = UDim2.new(0.50, 0, 0, 0)
    BiomeLbl.BackgroundTransparency = 1
    BiomeLbl.Text = egg.biome
    BiomeLbl.TextColor3 = Color3.fromRGB(140, 180, 220)
    BiomeLbl.TextSize = 9
    BiomeLbl.Font = Enum.Font.Gotham
    BiomeLbl.TextXAlignment = Enum.TextXAlignment.Left
    BiomeLbl.Parent = Row

    -- size
    local SizeLbl = Instance.new("TextLabel")
    SizeLbl.Size = UDim2.new(0.12, 0, 1, 0)
    SizeLbl.Position = UDim2.new(0.66, 0, 0, 0)
    SizeLbl.BackgroundTransparency = 1
    SizeLbl.Text = egg.size
    SizeLbl.TextColor3 = Color3.fromRGB(160, 200, 160)
    SizeLbl.TextSize = 9
    SizeLbl.Font = Enum.Font.Gotham
    SizeLbl.TextXAlignment = Enum.TextXAlignment.Left
    SizeLbl.Parent = Row

    -- income
    local IncomeLbl = Instance.new("TextLabel")
    IncomeLbl.Size = UDim2.new(0.14, 0, 1, 0)
    IncomeLbl.Position = UDim2.new(0.78, 0, 0, 0)
    IncomeLbl.BackgroundTransparency = 1
    IncomeLbl.Text = egg.income
    IncomeLbl.TextColor3 = Color3.fromRGB(100, 240, 140)
    IncomeLbl.TextSize = 9
    IncomeLbl.Font = Enum.Font.GothamBold
    IncomeLbl.TextXAlignment = Enum.TextXAlignment.Left
    IncomeLbl.Parent = Row

    -- steal button
    local StealBtn = Instance.new("TextButton")
    StealBtn.Size = UDim2.new(0, 36, 0, 24)
    StealBtn.Position = UDim2.new(0.92, 0, 0.5, -12)
    StealBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
    StealBtn.Text = "GO"
    StealBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    StealBtn.TextSize = 10
    StealBtn.Font = Enum.Font.GothamBold
    StealBtn.BorderSizePixel = 0
    StealBtn.Parent = Row

    local StealBtnCorner = Instance.new("UICorner")
    StealBtnCorner.CornerRadius = UDim.new(0, 6)
    StealBtnCorner.Parent = StealBtn

    -- on press: target this egg by name and enable auto steal
    local eggName = egg.name
    StealBtn.MouseButton1Click:Connect(function()
        CONFIG.TargetEggName = eggName
        CONFIG.AutoSteal = true
        StealState = "approaching"
        SetStatus("Targeting: " .. eggName, Color3.fromRGB(0, 220, 255))
        -- flash button
        StealBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
        StealBtn.Text = "✓"
        task.delay(1.2, function()
            StealBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
            StealBtn.Text = "GO"
        end)
    end)
end

-- toggle atlas panel
GojoBtn.MouseButton1Click:Connect(function()
    AtlasOpen = not AtlasOpen
    AtlasFrame.Visible = AtlasOpen
    GojoTip.Visible = not AtlasOpen
end)

AtlasClose.MouseButton1Click:Connect(function()
    AtlasOpen = false
    AtlasFrame.Visible = false
    GojoTip.Visible = true
end)

-- // Update FindClosestEgg to respect TargetEggName if set
-- Overrides the previous function with name-filter support
local _origFind = FindClosestEgg
FindClosestEgg = function()
    if not CONFIG.TargetEggName then
        return _origFind()
    end
    local targetName = CONFIG.TargetEggName:lower()
    local closestEgg = nil
    local closestDist = math.huge
    local workspace = game:GetService("Workspace")

    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") or v:IsA("Model") then
            if v.Name:lower():find(targetName) then
                local pos
                if v:IsA("Model") and v.PrimaryPart then
                    pos = v.PrimaryPart.Position
                elseif v:IsA("BasePart") then
                    pos = v.Position
                end
                if pos then
                    local dist = (HumanoidRootPart.Position - pos).Magnitude
                    if dist < closestDist then
                        closestDist = dist
                        closestEgg = v
                    end
                end
            end
        end
    end
    -- fallback to any egg if named one not found in map
    if not closestEgg then
        return _origFind()
    end
    return closestEgg, closestDist
end
