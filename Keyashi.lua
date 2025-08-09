-- MyKavoUI.lua
-- A single-file, lightweight Kavo-inspired UI library for Roblox (LocalScript)
-- Drop this into StarterPlayerScripts or StarterGui as a LocalScript

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- =====================
-- CONFIG / THEME
-- =====================
local MyKavo = {}
MyKavo.__index = MyKavo

local DefaultTheme = {
    Background = Color3.fromRGB(30, 30, 30),
    Side = Color3.fromRGB(22, 22, 22),
    Accent = Color3.fromRGB(98, 165, 255),
    Button = Color3.fromRGB(50, 50, 50),
    Text = Color3.fromRGB(235, 235, 235),
}

-- =====================
-- Utility helpers
-- =====================
local function new(name, class)
    local obj = Instance.new(class)
    obj.Name = name
    return obj
end

local function applyCorner(inst, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 6)
    c.Parent = inst
    return c
end

local function applyStroke(inst, thickness)
    local s = Instance.new("UIStroke")
    s.Thickness = thickness or 1
    s.Parent = inst
    return s
end

local function setFont(obj)
    obj.Font = Enum.Font.Gotham
    obj.TextSize = 14
    obj.TextColor3 = DefaultTheme.Text
end

-- Make frame draggable
local function makeDraggable(frame, dragger)
    dragger = dragger or frame
    frame.Active = true
    frame.Selectable = true
    local dragging = false
    local dragInput, mousePos, framePos

    local function update(input)
        local delta = input.Position - mousePos
        frame.Position = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)
    end

    dragger.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            mousePos = input.Position
            framePos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    dragger.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
end

-- =====================
-- UI Creation
-- =====================
function MyKavo:Create(title)
    local self = setmetatable({}, MyKavo)
    self.Title = title or "MyKavo UI"
    self.Theme = DefaultTheme
    self.Tabs = {}

    -- Root ScreenGui
    local screenGui = new("MyKavoScreenGui", "ScreenGui")
    screenGui.ResetOnSpawn = false
    screenGui.Parent = PlayerGui
    self.ScreenGui = screenGui

    -- Main frame
    local main = new("MainFrame", "Frame")
    main.Size = UDim2.new(0, 520, 0, 360)
    main.Position = UDim2.new(0.5, -260, 0.5, -180)
    main.AnchorPoint = Vector2.new(0.5, 0.5)
    main.BackgroundColor3 = self.Theme.Background
    main.Parent = screenGui
    applyCorner(main, 10)
    applyStroke(main, 1)

    -- Title bar
    local titleBar = new("TitleBar", "Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 36)
    titleBar.Position = UDim2.new(0, 0, 0, 0)
    titleBar.BackgroundTransparency = 1
    titleBar.Parent = main

    local titleLabel = new("TitleLabel", "TextLabel")
    titleLabel.Size = UDim2.new(1, -16, 1, 0)
    titleLabel.Position = UDim2.new(0, 8, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = self.Title
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    setFont(titleLabel)
    titleLabel.TextSize = 16
    titleLabel.Parent = titleBar

    -- Container for side tabs + content
    local side = new("SidePanel", "Frame")
    side.Size = UDim2.new(0, 120, 1, -36)
    side.Position = UDim2.new(0, 0, 0, 36)
    side.BackgroundColor3 = self.Theme.Side
    side.Parent = main
    applyCorner(side, 8)

    local contentArea = new("ContentArea", "Frame")
    contentArea.Size = UDim2.new(1, -120, 1, -36)
    contentArea.Position = UDim2.new(0, 120, 0, 36)
    contentArea.BackgroundTransparency = 1
    contentArea.Parent = main

    -- Layout for side buttons
    local sideList = new("SideList", "UIListLayout")
    sideList.Parent = side
    sideList.SortOrder = Enum.SortOrder.LayoutOrder
    sideList.Padding = UDim.new(0, 6)

    -- store refs
    self.Main = main
    self.TitleBar = titleBar
    self.Side = side
    self.Content = contentArea
    self.SideList = sideList

    -- Make draggable with title bar
    makeDraggable(main, titleBar)

    return self
end

-- Create Tab
function MyKavo:CreateTab(tabName)
    local tab = {}
    tab.Name = tabName or "Tab"
    tab.Items = {}

    -- side button
    local btn = new(tabName .. "Button", "TextButton")
    btn.Size = UDim2.new(1, -12, 0, 34)
    btn.Position = UDim2.new(0, 6, 0, 6)
    btn.BackgroundColor3 = self.Theme.Button
    btn.Text = tabName
    btn.AutoButtonColor = false
    btn.Parent = self.Side
    applyCorner(btn, 6)
    setFont(btn)

    -- content frame
    local frame = new(tabName .. "Frame", "ScrollingFrame")
    frame.Size = UDim2.new(1, -20, 1, -20)
    frame.Position = UDim2.new(0, 10, 0, 10)
    frame.BackgroundTransparency = 1
    frame.CanvasSize = UDim2.new(0, 0, 1, 0)
    frame.Visible = false
    frame.Parent = self.Content

    local layout = Instance.new("UIListLayout")
    layout.Parent = frame
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 8)

    -- show/hide logic
    btn.MouseButton1Click:Connect(function()
        -- hide other frames
        for _, t in pairs(self.Tabs) do
            t.Frame.Visible = false
            t.Button.BackgroundColor3 = self.Theme.Button
        end
        frame.Visible = true
        btn.BackgroundColor3 = self.Theme.Accent
    end)

    -- default: show if first tab
    if #self.Tabs == 0 then
        frame.Visible = true
        btn.BackgroundColor3 = self.Theme.Accent
    end

    tab.Button = btn
    tab.Frame = frame
    tab.Layout = layout

    table.insert(self.Tabs, tab)
    return tab
end

-- Create common UI elements inside a tab
function MyKavo:CreateLabel(tab, text)
    local lbl = new("Label", "TextLabel")
    lbl.Size = UDim2.new(1, -18, 0, 26)
    lbl.BackgroundTransparency = 1
    lbl.Text = text or "Label"
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    setFont(lbl)
    lbl.Parent = tab.Frame
    return lbl
end

function MyKavo:CreateButtonElement(tab, text, callback)
    local btn = new("Button", "TextButton")
    btn.Size = UDim2.new(1, -18, 0, 32)
    btn.BackgroundColor3 = self.Theme.Button
    btn.Text = text or "Button"
    setFont(btn)
    applyCorner(btn, 6)
    applyStroke(btn, 1)
    btn.Parent = tab.Frame

    btn.MouseButton1Click:Connect(function()
        if callback then
            callback()
        end
    end)
    return btn
end

function MyKavo:CreateToggle(tab, text, default, callback)
    local container = new("ToggleContainer", "Frame")
    container.Size = UDim2.new(1, -18, 0, 34)
    container.BackgroundTransparency = 1
    container.Parent = tab.Frame

    local label = new("Label", "TextLabel")
    label.Size = UDim2.new(1, -50, 1, 0)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text or "Toggle"
    label.TextXAlignment = Enum.TextXAlignment.Left
    setFont(label)
    label.Parent = container

    local toggleBtn = new("ToggleBtn", "TextButton")
    toggleBtn.Size = UDim2.new(0, 36, 0, 20)
    toggleBtn.Position = UDim2.new(1, -40, 0.5, -10)
    toggleBtn.AnchorPoint = Vector2.new(0, 0)
    toggleBtn.BackgroundColor3 = self.Theme.Button
    toggleBtn.Text = default and "ON" or "OFF"
    toggleBtn.Parent = container
    applyCorner(toggleBtn, 6)
    setFont(toggleBtn)

    local state = default and true or false
    toggleBtn.MouseButton1Click:Connect(function()
        state = not state
        toggleBtn.Text = state and "ON" or "OFF"
        if callback then callback(state) end
    end)

    return {Container = container, GetState = function() return state end}
end

function MyKavo:CreateSlider(tab, text, min, max, default, callback)
    local container = new("SliderContainer", "Frame")
    container.Size = UDim2.new(1, -18, 0, 44)
    container.BackgroundTransparency = 1
    container.Parent = tab.Frame

    local label = new("Label", "TextLabel")
    label.Size = UDim2.new(1, -18, 0, 18)
    label.BackgroundTransparency = 1
    label.Text = (text or "Slider") .. " : " .. tostring(default or min)
    label.TextXAlignment = Enum.TextXAlignment.Left
    setFont(label)
    label.Parent = container

    local bar = new("Bar", "Frame")
    bar.Size = UDim2.new(1, -18, 0, 16)
    bar.Position = UDim2.new(0, 9, 0, 22)
    bar.BackgroundColor3 = self.Theme.Button
    bar.Parent = container
    applyCorner(bar, 6)

    local fill = new("Fill", "Frame")
    fill.Size = UDim2.new(0, 0, 1, 0)
    fill.Position = UDim2.new(0, 0, 0, 0)
    fill.BackgroundColor3 = self.Theme.Accent
    fill.Parent = bar
    applyCorner(fill, 6)

    local dragging = false
    local function setValueFromX(x)
        local absX = math.clamp(x - bar.AbsolutePosition.X, 0, bar.AbsoluteSize.X)
        local ratio = absX / bar.AbsoluteSize.X
        local value = math.floor((min + (max - min) * ratio) * 100) / 100
        fill.Size = UDim2.new(ratio, 0, 1, 0)
        label.Text = (text or "Slider") .. " : " .. tostring(value)
        if callback then callback(value) end
    end

    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            setValueFromX(input.Position.X)
        end
    end)
    bar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            setValueFromX(input.Position.X)
        end
    end)

    -- set default visually
    local ratio = 0
    if max and min and default then
        ratio = (default - min) / (max - min)
        fill.Size = UDim2.new(ratio, 0, 1, 0)
    end

    return {Container = container}
end

-- Simple textbox (input)
function MyKavo:CreateTextbox(tab, placeholder, callback)
    local container = new("TextboxContainer", "Frame")
    container.Size = UDim2.new(1, -18, 0, 36)
    container.BackgroundTransparency = 1
    container.Parent = tab.Frame

    local box = new("Box", "TextBox")
    box.Size = UDim2.new(1, -18, 1, 0)
    box.Position = UDim2.new(0, 9, 0, 0)
    box.ClearTextOnFocus = false
    box.PlaceholderText = placeholder or "Enter text..."
    setFont(box)
    box.BackgroundColor3 = self.Theme.Button
    box.Parent = container
    applyCorner(box, 6)

    box.FocusLost:Connect(function(enter)
        if enter and callback then callback(box.Text) end
    end)

    return box
end

-- Theme applying (updates colors)
function MyKavo:ApplyTheme(themeTable)
    for k, v in pairs(themeTable) do
        self.Theme[k] = v
    end
    -- update visuals
    if self.Main then
        self.Main.BackgroundColor3 = self.Theme.Background
        self.Side.BackgroundColor3 = self.Theme.Side
        for _, tab in pairs(self.Tabs) do
            tab.Button.BackgroundColor3 = self.Theme.Button
            if tab.Frame.Visible then
                tab.Button.BackgroundColor3 = self.Theme.Accent
            end
        end
    end
end

-- =====================
-- Example usage (build UI automatically)
-- =====================
local ui = MyKavo:Create("MyKavo - Custom UI")

local tab1 = ui:CreateTab("Main")
ui:CreateLabel(tab1, "Welcome to your custom UI!")
ui:CreateButtonElement(tab1, "Print Hello", function()
    print("Hello from MyKavo UI!")
end)
local tog = ui:CreateToggle(tab1, "Enable Feature", false, function(state)
    print("Toggle is now", state)
end)
ui:CreateSlider(tab1, "Speed", 0, 100, 25, function(val)
    -- val is numeric
end)
ui:CreateTextbox(tab1, "Type something...", function(text)
    print("You typed:", text)
end)

local tab2 = ui:CreateTab("Settings")
ui:CreateLabel(tab2, "Theme")
ui:CreateButtonElement(tab2, "Switch to Light Theme", function()
    ui:ApplyTheme({
        Background = Color3.fromRGB(240, 240, 240),
        Side = Color3.fromRGB(220, 220, 220),
        Button = Color3.fromRGB(200, 200, 200),
        Text = Color3.fromRGB(20, 20, 20),
        Accent = Color3.fromRGB(80, 120, 255),
    })
end)
ui:CreateButtonElement(tab2, "Switch to Dark Theme", function()
    ui:ApplyTheme({
        Background = Color3.fromRGB(30, 30, 30),
        Side = Color3.fromRGB(22, 22, 22),
        Button = Color3.fromRGB(50, 50, 50),
        Text = Color3.fromRGB(235, 235, 235),
        Accent = Color3.fromRGB(98, 165, 255),
    })
end)

-- End of file
return MyKavo
