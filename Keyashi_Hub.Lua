-- Keyashi_HUB.lua
-- Roblox UI Library (Inspired by Kavo UI) - Fully Renamed Version
-- By: YourNameHere

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local Keyashi_HUB = {}
Keyashi_HUB.__index = Keyashi_HUB

local DefaultTheme = {
    Background = Color3.fromRGB(30, 30, 30),
    Side = Color3.fromRGB(22, 22, 22),
    Accent = Color3.fromRGB(98, 165, 255),
    Button = Color3.fromRGB(50, 50, 50),
    Text = Color3.fromRGB(235, 235, 235),
}

-- =====================
-- Helper Functions
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

local function makeDraggable(frame, dragger)
    dragger = dragger or frame
    frame.Active = true
    frame.Selectable = true
    local dragging, dragInput, mousePos, framePos

    local function update(input)
        local delta = input.Position - mousePos
        frame.Position = UDim2.new(
            framePos.X.Scale, framePos.X.Offset + delta.X,
            framePos.Y.Scale, framePos.Y.Offset + delta.Y
        )
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

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
end

-- =====================
-- Main UI Creation
-- =====================
function Keyashi_HUB:Create(title)
    local self = setmetatable({}, Keyashi_HUB)
    self.Title = title or "Keyashi_HUB"
    self.Theme = DefaultTheme
    self.Tabs = {}

    local screenGui = new("Keyashi_HUB_ScreenGui", "ScreenGui")
    screenGui.ResetOnSpawn = false
    screenGui.Parent = PlayerGui
    self.ScreenGui = screenGui

    local main = new("MainFrame", "Frame")
    main.Size = UDim2.new(0, 520, 0, 360)
    main.Position = UDim2.new(0.5, -260, 0.5, -180)
    main.AnchorPoint = Vector2.new(0.5, 0.5)
    main.BackgroundColor3 = self.Theme.Background
    main.Parent = screenGui
    applyCorner(main, 10)
    applyStroke(main, 1)

    local titleBar = new("TitleBar", "Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 36)
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

    local sideList = new("SideList", "UIListLayout")
    sideList.Parent = side
    sideList.SortOrder = Enum.SortOrder.LayoutOrder
    sideList.Padding = UDim.new(0, 6)

    self.Main = main
    self.TitleBar = titleBar
    self.Side = side
    self.Content = contentArea
    self.SideList = sideList

    makeDraggable(main, titleBar)
    return self
end

function Keyashi_HUB:CreateTab(tabName)
    local tab = {}
    tab.Name = tabName or "Tab"
    tab.Items = {}

    local btn = new(tabName .. "Button", "TextButton")
    btn.Size = UDim2.new(1, -12, 0, 34)
    btn.BackgroundColor3 = self.Theme.Button
    btn.Text = tabName
    btn.AutoButtonColor = false
    btn.Parent = self.Side
    applyCorner(btn, 6)
    setFont(btn)

    local frame = new(tabName .. "Frame", "ScrollingFrame")
    frame.Size = UDim2.new(1, -20, 1, -20)
    frame.BackgroundTransparency = 1
    frame.CanvasSize = UDim2.new(0, 0, 1, 0)
    frame.Visible = false
    frame.Parent = self.Content

    local layout = Instance.new("UIListLayout")
    layout.Parent = frame
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 8)

    btn.MouseButton1Click:Connect(function()
        for _, t in pairs(self.Tabs) do
            t.Frame.Visible = false
            t.Button.BackgroundColor3 = self.Theme.Button
        end
        frame.Visible = true
        btn.BackgroundColor3 = self.Theme.Accent
    end)

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

function Keyashi_HUB:CreateLabel(tab, text)
    local lbl = new("Label", "TextLabel")
    lbl.Size = UDim2.new(1, -18, 0, 26)
    lbl.BackgroundTransparency = 1
    lbl.Text = text or "Label"
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    setFont(lbl)
    lbl.Parent = tab.Frame
    return lbl
end

function Library:CreateSlider(tab, text, min, max, default, callback)
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Size = UDim2.new(1, -10, 0, 40)
    sliderFrame.BackgroundTransparency = 1
    sliderFrame.Parent = tab

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 20)
    label.BackgroundTransparency = 1
    label.Text = text .. ": " .. default
    label.Font = Enum.Font.SourceSans
    label.TextSize = 18
    label.TextColor3 = Color3.new(1,1,1)
    label.Parent = sliderFrame

    local slider = Instance.new("TextButton")
    slider.Size = UDim2.new(1, 0, 0, 20)
    slider.Position = UDim2.new(0, 0, 0, 20)
    slider.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    slider.Text = ""
    slider.Parent = sliderFrame

    local fill = Instance.new("Frame")
    fill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.Parent = slider

    local userInput = game:GetService("UserInputService")
    local dragging = false

    local function updateFill(x)
        local relative = math.clamp((x - slider.AbsolutePosition.X) / slider.AbsoluteSize.X, 0, 1)
        fill.Size = UDim2.new(relative, 0, 1, 0)
        local value = math.floor(min + (max - min) * relative)
        label.Text = text .. ": " .. value
        if callback then
            callback(value)
        end
    end

    slider.MouseButton1Down:Connect(function()
        dragging = true
    end)

    userInput.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    userInput.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateFill(input.Position.X)
        end
    end)

    -- ตั้งค่า default
    updateFill(slider.AbsolutePosition.X + slider.AbsoluteSize.X * ((default - min) / (max - min)))
end


function Keyashi_HUB:CreateButton(tab, text, callback)
    local btn = new("Button", "TextButton")
    btn.Size = UDim2.new(1, -18, 0, 32)
    btn.BackgroundColor3 = self.Theme.Button
    btn.Text = text or "Button"
    setFont(btn)
    applyCorner(btn, 6)
    applyStroke(btn, 1)
    btn.Parent = tab.Frame

    btn.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)
    return btn
end

function Keyashi_HUB:CreateToggle(tab, text, default, callback)
    local toggle = new("Toggle", "TextButton")
    toggle.Size = UDim2.new(1, -18, 0, 32)
    toggle.BackgroundColor3 = self.Theme.Button
    toggle.Text = ""
    toggle.AutoButtonColor = false
    applyCorner(toggle, 6)
    applyStroke(toggle, 1)
    toggle.Parent = tab.Frame

    local lbl = new("ToggleLabel", "TextLabel")
    lbl.Size = UDim2.new(1, -40, 1, 0)
    lbl.Position = UDim2.new(0, 8, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text or "Toggle"
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    setFont(lbl)
    lbl.Parent = toggle

    local indicator = new("Indicator", "Frame")
    indicator.Size = UDim2.new(0, 20, 0, 20)
    indicator.Position = UDim2.new(1, -28, 0.5, -10)
    indicator.BackgroundColor3 = default and self.Theme.Accent or Color3.fromRGB(80, 80, 80)
    applyCorner(indicator, 4)
    indicator.Parent = toggle

    local state = default or false
    toggle.MouseButton1Click:Connect(function()
        state = not state
        indicator.BackgroundColor3 = state and self.Theme.Accent or Color3.fromRGB(80, 80, 80)
        if callback then callback(state) end
    end)
    return toggle
end

function Keyashi_HUB:CreateTextbox(tab, placeholder, callback)
    local box = new("Textbox", "TextBox")
    box.Size = UDim2.new(1, -18, 0, 32)
    box.BackgroundColor3 = self.Theme.Button
    box.PlaceholderText = placeholder or "Enter text..."
    box.Text = ""
    setFont(box)
    applyCorner(box, 6)
    applyStroke(box, 1)
    box.ClearTextOnFocus = false
    box.Parent = tab.Frame

    box.FocusLost:Connect(function(enterPressed)
        if enterPressed and callback then
            callback(box.Text)
        end
    end)
    return box
end

function Keyashi_HUB:SetTheme(themeTable)
    for k, v in pairs(themeTable) do
        if self.Theme[k] then
            self.Theme[k] = v
        end
    end
end

return Keyashi_HUB
