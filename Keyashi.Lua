-- Keyashi Hub UI Library
local KeyashiHub = {}
KeyashiHub.__index = KeyashiHub

-- สร้างหน้าหลัก
function KeyashiHub:CreateMain(title)
    local self = setmetatable({}, KeyashiHub)

    -- ScreenGui
    self.gui = Instance.new("ScreenGui")
    self.gui.Name = "Keyashi_Hub"
    self.gui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

    -- Main Frame
    self.mainFrame = Instance.new("Frame")
    self.mainFrame.Size = UDim2.new(0, 500, 0, 300)
    self.mainFrame.Position = UDim2.new(0.5, -250, 0.5, -150)
    self.mainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    self.mainFrame.Active = true
    self.mainFrame.Draggable = true
    self.mainFrame.Parent = self.gui

    -- Title
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0, 40)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title or "Keyashi Hub"
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 20
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.Parent = self.mainFrame

    -- Tab Holder
    self.tabButtons = Instance.new("Frame")
    self.tabButtons.Size = UDim2.new(0, 120, 1, -40)
    self.tabButtons.Position = UDim2.new(0, 0, 0, 40)
    self.tabButtons.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    self.tabButtons.Parent = self.mainFrame

    self.contentFrame = Instance.new("Frame")
    self.contentFrame.Size = UDim2.new(1, -120, 1, -40)
    self.contentFrame.Position = UDim2.new(0, 120, 0, 40)
    self.contentFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    self.contentFrame.Parent = self.mainFrame

    self.tabs = {}

    return self
end

-- สร้างแท็บใหม่
function KeyashiHub:CreateTab(tabName)
    local tab = {}
    tab.name = tabName
    tab.frame = Instance.new("Frame")
    tab.frame.Size = UDim2.new(1, 0, 1, 0)
    tab.frame.BackgroundTransparency = 1
    tab.frame.Visible = false
    tab.frame.Parent = self.contentFrame

    -- ปุ่มแท็บ
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 0, 30)
    button.Text = tabName
    button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Parent = self.tabButtons

    button.MouseButton1Click:Connect(function()
        for _, t in pairs(self.tabs) do
            t.frame.Visible = false
        end
        tab.frame.Visible = true
    end)

    -- เพิ่มฟังก์ชันสร้างปุ่ม
    function tab:AddButton(text, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 200, 0, 30)
        btn.Position = UDim2.new(0, 10, 0, #tab.frame:GetChildren() * 35)
        btn.Text = text
        btn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Parent = tab.frame

        btn.MouseButton1Click:Connect(function()
            pcall(callback)
        end)
    end

    -- เพิ่มฟังก์ชันสร้าง Toggle
    function tab:AddToggle(text, default, callback)
        local toggleState = default or false
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 200, 0, 30)
        btn.Position = UDim2.new(0, 10, 0, #tab.frame:GetChildren() * 35)
        btn.Text = text .. ": " .. tostring(toggleState)
        btn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Parent = tab.frame

        btn.MouseButton1Click:Connect(function()
            toggleState = not toggleState
            btn.Text = text .. ": " .. tostring(toggleState)
            pcall(callback, toggleState)
        end)
    end

    table.insert(self.tabs, tab)
    if #self.tabs == 1 then
        tab.frame.Visible = true
    end

    return tab
end

return KeyashiHub
