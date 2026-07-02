--========================================================
-- CONFIG VARIABLES (CUSTOMIZE HERE)
--========================================================

local COLLECT_DELAY  = 0.05
local BUY_DELAY      = 0.15
local CRATE_DELAY    = 1.0
local REBIRTH_DELAY  = 0.5
local LOOP_DELAY     = 0.05

local SNOW_ENABLED   = true
local SNOW_COLOR     = Color3.fromRGB(180, 80, 255)
local SNOW_DENSITY   = 35
local SNOW_SPEED     = 0.4
local SNOW_SIZE      = 3

local REBIRTH_COOLDOWN = false

--========================================================
-- SERVICES / PLAYER / TYCOON
--========================================================

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = game.Players.LocalPlayer
local tycoon = workspace.Tycoons[player.Name]

--========================================================
-- UI ROOT + MAIN WINDOW (SCALED)
--========================================================

local screen = Instance.new("ScreenGui")
screen.Name = "SynapseTycoonUI"
screen.IgnoreGuiInset = true
screen.ResetOnSpawn = false
screen.Parent = game:GetService("CoreGui")

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainWindow"
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
mainFrame.Size = UDim2.new(0.35, 0, 0.4, 0) -- scaled
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screen

local mainCorner = Instance.new("UICorner", mainFrame)
mainCorner.CornerRadius = UDim.new(0, 10)

local mainStroke = Instance.new("UIStroke", mainFrame)
mainStroke.Thickness = 2
mainStroke.Color = Color3.fromRGB(120, 120, 140)

-- draggable
do
    local dragging = false
    local dragStart, startPos

    mainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

--========================================================
-- PURPLE SNOW (UI-ONLY BACKGROUND)
--========================================================

local snowLayer = Instance.new("Frame")
snowLayer.Name = "SnowLayer"
snowLayer.BackgroundTransparency = 1
snowLayer.Size = UDim2.new(1, 0, 1, 0)
snowLayer.ClipsDescendants = true
snowLayer.Parent = mainFrame

local function spawnSnow()
    if not SNOW_ENABLED then return end

    task.spawn(function()
        while SNOW_ENABLED do
            for i = 1, SNOW_DENSITY do
                local flake = Instance.new("Frame")
                flake.Size = UDim2.new(0, SNOW_SIZE, 0, SNOW_SIZE)
                flake.BackgroundColor3 = SNOW_COLOR
                flake.BorderSizePixel = 0
                flake.BackgroundTransparency = 0.2
                flake.Position = UDim2.new(math.random(), 0, 0, -math.random(0, 50))
                flake.Parent = snowLayer

                task.spawn(function()
                    local life = 1 / SNOW_SPEED
                    local start = tick()
                    while tick() - start < life do
                        local pos = flake.Position
                        flake.Position = UDim2.new(pos.X.Scale, pos.X.Offset, pos.Y.Scale, pos.Y.Offset + 1)
                        task.wait(0.03)
                    end
                    flake:Destroy()
                end)
            end
            task.wait(0.5)
        end
    end)
end

spawnSnow()

--========================================================
-- HEADER + TABS
--========================================================

local header = Instance.new("Frame")
header.Name = "Header"
header.Size = UDim2.new(1, 0, 0.15, 0)
header.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
header.BorderSizePixel = 0
header.Parent = mainFrame

local headerCorner = Instance.new("UICorner", header)
headerCorner.CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextLabel")
title.Name = "Title"
title.BackgroundTransparency = 1
title.Size = UDim2.new(0.5, 0, 1, 0)
title.Position = UDim2.new(0.02, 0, 0, 0)
title.Font = Enum.Font.SourceSansBold
title.Text = "Tycoon Control Panel"
title.TextColor3 = Color3.fromRGB(220, 220, 230)
title.TextScaled = true
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

local rebirthLabel = Instance.new("TextLabel")
rebirthLabel.Name = "RebirthCounter"
rebirthLabel.BackgroundTransparency = 1
rebirthLabel.Size = UDim2.new(0.45, 0, 1, 0)
rebirthLabel.Position = UDim2.new(0.53, 0, 0, 0)
rebirthLabel.Font = Enum.Font.SourceSans
rebirthLabel.Text = "Rebirths: 0"
rebirthLabel.TextColor3 = Color3.fromRGB(200, 200, 210)
rebirthLabel.TextScaled = true
rebirthLabel.TextXAlignment = Enum.TextXAlignment.Right
rebirthLabel.Parent = header

local tabsFrame = Instance.new("Frame")
tabsFrame.Name = "Tabs"
tabsFrame.BackgroundTransparency = 1
tabsFrame.Size = UDim2.new(1, 0, 0.1, 0)
tabsFrame.Position = UDim2.new(0, 0, 0.15, 0)
tabsFrame.Parent = mainFrame

local settingsTab = Instance.new("TextButton")
settingsTab.Name = "SettingsTab"
settingsTab.Size = UDim2.new(0.5, 0, 1, 0)
settingsTab.Position = UDim2.new(0, 0, 0, 0)
settingsTab.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
settingsTab.BorderSizePixel = 0
settingsTab.Font = Enum.Font.SourceSansBold
settingsTab.Text = "Settings"
settingsTab.TextColor3 = Color3.fromRGB(230, 230, 240)
settingsTab.TextScaled = true
settingsTab.Parent = tabsFrame

local consoleTab = Instance.new("TextButton")
consoleTab.Name = "ConsoleTab"
consoleTab.Size = UDim2.new(0.5, 0, 1, 0)
consoleTab.Position = UDim2.new(0.5, 0, 0, 0)
consoleTab.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
consoleTab.BorderSizePixel = 0
consoleTab.Font = Enum.Font.SourceSansBold
consoleTab.Text = "Console"
consoleTab.TextColor3 = Color3.fromRGB(180, 180, 200)
consoleTab.TextScaled = true
consoleTab.Parent = tabsFrame

--========================================================
-- CONTENT FRAMES (SETTINGS + CONSOLE)
--========================================================

local contentFrame = Instance.new("Frame")
contentFrame.Name = "Content"
contentFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
contentFrame.BorderSizePixel = 0
contentFrame.Position = UDim2.new(0, 0, 0.25, 0)
contentFrame.Size = UDim2.new(1, 0, 0.75, 0)
contentFrame.Parent = mainFrame

local contentCorner = Instance.new("UICorner", contentFrame)
contentCorner.CornerRadius = UDim.new(0, 10)

local settingsFrame = Instance.new("Frame")
settingsFrame.Name = "SettingsFrame"
settingsFrame.BackgroundTransparency = 1
settingsFrame.Size = UDim2.new(1, 0, 1, 0)
settingsFrame.Parent = contentFrame

local consoleFrame = Instance.new("Frame")
consoleFrame.Name = "ConsoleFrame"
consoleFrame.BackgroundTransparency = 1
consoleFrame.Size = UDim2.new(1, 0, 1, 0)
consoleFrame.Visible = false
consoleFrame.Parent = contentFrame

local function setTab(active)
    if active == "Settings" then
        settingsFrame.Visible = true
        consoleFrame.Visible = false
        settingsTab.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
        consoleTab.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    else
        settingsFrame.Visible = false
        consoleFrame.Visible = true
        settingsTab.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
        consoleTab.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    end
end

settingsTab.MouseButton1Click:Connect(function()
    setTab("Settings")
end)

consoleTab.MouseButton1Click:Connect(function()
    setTab("Console")
end)

--========================================================
-- SLIDER CREATION HELPER
--========================================================

local function createSlider(parent, labelText, minValue, maxValue, initialValue, onChanged)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -20, 0, 40)
    container.BackgroundTransparency = 1
    container.Parent = parent

    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(0.5, 0, 0.5, 0)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.Font = Enum.Font.SourceSans
    label.Text = labelText
    label.TextColor3 = Color3.fromRGB(220, 220, 230)
    label.TextScaled = true
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container

    local valueLabel = Instance.new("TextLabel")
    valueLabel.BackgroundTransparency = 1
    valueLabel.Size = UDim2.new(0.5, 0, 0.5, 0)
    valueLabel.Position = UDim2.new(0.5, 0, 0, 0)
    valueLabel.Font = Enum.Font.SourceSans
    valueLabel.Text = string.format("%.3f", initialValue)
    valueLabel.TextColor3 = Color3.fromRGB(200, 200, 210)
    valueLabel.TextScaled = true
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Parent = container

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1, 0, 0, 8)
    bar.Position = UDim2.new(0, 0, 0.7, 0)
    bar.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    bar.BorderSizePixel = 0
    bar.Parent = container

    local barCorner = Instance.new("UICorner", bar)
    barCorner.CornerRadius = UDim.new(0, 4)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.AnchorPoint = Vector2.new(0.5, 0.5)
    knob.Position = UDim2.new((initialValue - minValue) / (maxValue - minValue), 0, 0.5, 0)
    knob.BackgroundColor3 = SNOW_COLOR
    knob.BorderSizePixel = 0
    knob.Parent = bar

    local knobCorner = Instance.new("UICorner", knob)
    knobCorner.CornerRadius = UDim.new(1, 0)

    local dragging = false

    knob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            local rel = (input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X
            rel = math.clamp(rel, 0, 1)
            knob.Position = UDim2.new(rel, 0, 0.5, 0)
            local value = minValue + (maxValue - minValue) * rel
            valueLabel.Text = string.format("%.3f", value)
            onChanged(value)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local rel = (input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X
            rel = math.clamp(rel, 0, 1)
            knob.Position = UDim2.new(rel, 0, 0.5, 0)
            local value = minValue + (maxValue - minValue) * rel
            valueLabel.Text = string.format("%.3f", value)
            onChanged(value)
        end
    end)

    return container
end

--========================================================
-- SETTINGS SLIDERS
--========================================================

local settingsList = Instance.new("UIListLayout", settingsFrame)
settingsList.Padding = UDim.new(0, 6)
settingsList.FillDirection = Enum.FillDirection.Vertical
settingsList.HorizontalAlignment = Enum.HorizontalAlignment.Center
settingsList.VerticalAlignment = Enum.VerticalAlignment.Top

createSlider(settingsFrame, "Collect Delay", 0.01, 0.5, COLLECT_DELAY, function(v)
    COLLECT_DELAY = v
end)

createSlider(settingsFrame, "Buy Delay", 0.01, 0.5, BUY_DELAY, function(v)
    BUY_DELAY = v
end)

createSlider(settingsFrame, "Crate Delay", 0.1, 3.0, CRATE_DELAY, function(v)
    CRATE_DELAY = v
end)

createSlider(settingsFrame, "Rebirth Delay", 0.1, 3.0, REBIRTH_DELAY, function(v)
    REBIRTH_DELAY = v
end)

createSlider(settingsFrame, "Loop Delay", 0.01, 0.2, LOOP_DELAY, function(v)
    LOOP_DELAY = v
end)

--========================================================
-- CONSOLE (EXECUTOR-STYLE)
--========================================================

local consoleOutput = Instance.new("ScrollingFrame")
consoleOutput.Name = "ConsoleOutput"
consoleOutput.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
consoleOutput.BorderSizePixel = 0
consoleOutput.Size = UDim2.new(1, -10, 0.8, -10)
consoleOutput.Position = UDim2.new(0, 5, 0, 5)
consoleOutput.ScrollBarThickness = 6
consoleOutput.Parent = consoleFrame

local consoleList = Instance.new("UIListLayout", consoleOutput)
consoleList.Padding = UDim.new(0, 2)
consoleList.FillDirection = Enum.FillDirection.Vertical
consoleList.HorizontalAlignment = Enum.HorizontalAlignment.Left
consoleList.VerticalAlignment = Enum.VerticalAlignment.Top
consoleList.SortOrder = Enum.SortOrder.LayoutOrder

consoleList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    consoleOutput.CanvasSize = UDim2.new(0, 0, 0, consoleList.AbsoluteContentSize.Y + 10)
end)

local consoleInput = Instance.new("TextBox")
consoleInput.Name = "ConsoleInput"
consoleInput.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
consoleInput.BorderSizePixel = 0
consoleInput.Size = UDim2.new(1, -10, 0.2, -5)
consoleInput.Position = UDim2.new(0, 5, 0.8, 0)
consoleInput.Font = Enum.Font.SourceSans
consoleInput.Text = ""
consoleInput.PlaceholderText = "Enter command (e.g. /set buy_delay 0.1)"
consoleInput.TextColor3 = Color3.fromRGB(220, 220, 230)
consoleInput.TextScaled = true
consoleInput.ClearTextOnFocus = false
consoleInput.Parent = consoleFrame

local function logConsole(text)
    local line = Instance.new("TextLabel")
    line.BackgroundTransparency = 1
    line.Size = UDim2.new(1, -4, 0, 18)
    line.Font = Enum.Font.SourceSans
    line.Text = text
    line.TextColor3 = Color3.fromRGB(200, 200, 210)
    line.TextXAlignment = Enum.TextXAlignment.Left
    line.TextScaled = false
    line.Parent = consoleOutput
end

logConsole("[Tycoon] Console ready.")

local function handleCommand(cmd)
    logConsole("> " .. cmd)

    local parts = string.split(cmd, " ")
    if #parts == 0 then return end

    if parts[1] == "/set" and #parts >= 3 then
        local varName = parts[2]
        local value = tonumber(parts[3])
        if not value then
            logConsole("[Error] Invalid value.")
            return
        end

        if varName == "collect_delay" then
            COLLECT_DELAY = value
        elseif varName == "buy_delay" then
            BUY_DELAY = value
        elseif varName == "crate_delay" then
            CRATE_DELAY = value
        elseif varName == "rebirth_delay" then
            REBIRTH_DELAY = value
        elseif varName == "loop_delay" then
            LOOP_DELAY = value
        else
            logConsole("[Error] Unknown variable: " .. varName)
            return
        end

        logConsole(string.format("[Set] %s = %.3f", varName, value))
    elseif parts[1] == "/log" then
        logConsole(table.concat(parts, " ", 2))
    else
        logConsole("[Error] Unknown command.")
    end
end

consoleInput.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        local text = consoleInput.Text
        if text ~= "" then
            handleCommand(text)
            consoleInput.Text = ""
        end
    end
end)

--========================================================
-- GAME LOGIC HELPERS
--========================================================

local function updateRebirth()
    rebirthLabel.Text = "Rebirths: " .. player.leaderstats.Rebirth.Value
end

local function waitForTycoonReload()
    local timeout = 10
    local start = tick()

    while tick() - start < timeout do
        local aux = tycoon:FindFirstChild("Auxiliary")
        local buttons = tycoon:FindFirstChild("Buttons")

        if aux and buttons and aux:FindFirstChild("Collector") then
            logConsole("[Tycoon] Reload complete.")
            return true
        end

        task.wait(0.1)
    end

    logConsole("[Tycoon] Reload timeout.")
    return false
end

local function autoCollect()
    local aux = tycoon:FindFirstChild("Auxiliary")
    if not aux then return end

    local collector = aux:FindFirstChild("Collector")
    if not collector then return end

    local collectPart = collector:FindFirstChild("Collect")
    if not collectPart then return end

    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp:PivotTo(collectPart.CFrame + Vector3.new(0, 2, 0))
    end

    task.wait(COLLECT_DELAY)
end

local function updateButtonLabels(buttonsFolder)
    -- you can hook this to your existing button UI if needed
end

local function autoBuy(buttonsFolder)
    local money = player.leaderstats.Money.Value

    for _, v in buttonsFolder:GetChildren() do
        if string.find(string.lower(v.Name), "dropper") then
            local price = v:GetAttribute("Price")
            if price and price <= money and v:FindFirstChild("Button") then
                player.Character:PivotTo(v.Button.CFrame + Vector3.new(0, 2, 0))
                logConsole("[Buy] " .. v.Name)
                task.wait(BUY_DELAY)
                return
            end
        end
    end

    for _, v in buttonsFolder:GetChildren() do
        local price = v:GetAttribute("Price")
        if price and price <= money and v:FindFirstChild("Button") then
            player.Character:PivotTo(v.Button.CFrame + Vector3.new(0, 2, 0))
            logConsole("[Buy] " .. v.Name)
            task.wait(BUY_DELAY)
            return
        end
    end
end

local function autoCrates()
    for _, crate in ipairs(workspace:GetChildren()) do
        if crate.Name == "BalloonCrate" and crate:IsA("Model") then
            local cratePart = crate:FindFirstChild("Crate")
            local prompt = cratePart and cratePart:FindFirstChildOfClass("ProximityPrompt")

            if prompt and player.leaderstats.Money.Value <= 100000 then
                local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hrp:PivotTo(cratePart.CFrame + Vector3.new(0, 1, 0))
                end

                task.wait(CRATE_DELAY)
                prompt:InputHoldBegin()
                task.wait(prompt.HoldDuration + 0.1)
                prompt:InputHoldEnd()
                logConsole("[Crate] Opened BalloonCrate.")
            end
        end
    end
end

local function autoRebirth()
    local aux = tycoon:FindFirstChild("Auxiliary")
    if not aux then return end

    local rebirth = aux:FindFirstChild("Rebirth")
    if not rebirth then return end

    local prompt = rebirth.Button:FindFirstChildOfClass("ProximityPrompt")
    if not prompt then return end

    REBIRTH_COOLDOWN = true
    logConsole("[Rebirth] Starting rebirth...")

    player.Character:PivotTo(rebirth.Button.CFrame + Vector3.new(0, 5, 0))
    task.wait(REBIRTH_DELAY)

    prompt:InputHoldBegin()
    task.wait(prompt.HoldDuration + 0.5)
    prompt:InputHoldEnd()

    waitForTycoonReload()
    REBIRTH_COOLDOWN = false
    logConsole("[Rebirth] Completed.")
end

--========================================================
-- MAIN LOOP
--========================================================

logConsole("[Tycoon] Automation started.")

while true do
    if not REBIRTH_COOLDOWN then
        local buttonsFolder = tycoon:FindFirstChild("Buttons")
        if buttonsFolder then
            autoCollect()
            updateButtonLabels(buttonsFolder)
            autoBuy(buttonsFolder)
            autoCrates()
            autoRebirth()
            updateRebirth()
        end
    end

    task.wait(LOOP_DELAY)
end
