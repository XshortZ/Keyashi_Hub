-- Keyashi Hub v1
-- เขียนโดย ChatGPT เพื่อใช้เป็น UI Library เหมือน Kavo UI

local KeyashiHub = {}
KeyashiHub.__index = KeyashiHub

-- 🖌 ตัวช่วยสร้าง Instance
local function create(class, props)
    local obj = Instance.new(class)
    for k, v in pairs(props) do
        obj[k] = v
    end
    return obj
end

-- 🌟 Main Window
function KeyashiHub:CreateMain(title)
    local screenGui = create("ScreenGui", {Name = title, Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")})
    local mainFrame = create("Frame", {
        Size = UDim2.new(0, 400, 0, 300),
        Position = UDim2.new(0.5, -200, 0.5, -150),
        BackgroundColor3 = Color3.fromRGB(30, 30, 30),
        BorderSizePixel = 0,
        Parent = screenGui
    })
    create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = mainFrame})

    local titleBar = create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundColor3 = Color3.fromRGB(40, 40, 40),
        Text = title,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Parent = mainFrame
    })
    create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = titleBar})

    local tabHolder = create("Frame", {
        Size = UDim2.new(0, 100, 1, -30),
        Position = UDim2.new(0, 0, 0, 30),
        BackgroundColor3 = Color3.fromRGB(35, 35, 35),
        Parent = mainFrame
    })

    local contentFrame = create("Frame", {
        Size = UDim2.new(1, -100, 1, -30),
        Position = UDim2.new(0, 100, 0, 30),
        BackgroundColor3 = Color3.fromRGB(25, 25, 25),
        Parent = mainFrame
    })

    create("UIListLayout", {Parent = tabHolder, SortOrder = Enum.SortOrder.LayoutOrder})

    self.MainFrame = mainFrame
    self.TabHolder = tabHolder
    self.ContentFrame = contentFrame
    self.Tabs = {}
    return self
end

-- 📂 สร้าง Tab
function KeyashiHub:CreateTab(tabName)
    local tabBtn = create("TextButton", {
        Size = UDim2.new(1, 0, 0, 30),
        Text = tabName,
        BackgroundColor3 = Color3.fromRGB(45, 45, 45),
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Parent = self.TabHolder
    })

    local tabFrame = create("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Visible = false,
        Parent = self.ContentFrame
    })
    create("UIListLayout", {Parent = tabFrame, Padding = UDim.new(0, 5)})

    tabBtn.MouseButton1Click:Connect(function()
        for _, t in pairs(self.Tabs) do
            t.Frame.Visible = false
        end
        tabFrame.Visible = true
    end)

    table.insert(self.Tabs, {Name = tabName, Button = tabBtn, Frame = tabFrame})

    return setmetatable({
        Frame = tabFrame
    }, {
        __index = function(_, key)
            return KeyashiHub[key]
        end
    })
end

-- 🔘 Add Button
function KeyashiHub:AddButton(text, callback)
    local btn = create("TextButton", {
        Size = UDim2.new(1, -10, 0, 30),
        BackgroundColor3 = Color3.fromRGB(50, 50, 50),
        Text = text,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Parent = self.Frame
    })
    btn.MouseButton1Click:Connect(function()
        if callback then pcall(callback) end
    end)
end

-- ✅ Add Toggle
function KeyashiHub:AddToggle(text, default, callback)
    local state = default or false
    local btn = create("TextButton", {
        Size = UDim2.new(1, -10, 0, 30),
        BackgroundColor3 = Color3.fromRGB(50, 50, 50),
        Text = text .. ": " .. tostring(state),
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Parent = self.Frame
    })
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = text .. ": " .. tostring(state)
        if callback then pcall(callback, state) end
    end)
end

-- 📏 Add Slider
function KeyashiHub:AddSlider(text, min, max, default, callback)
    local value = default or min
    local label = create("TextLabel", {
        Size = UDim2.new(1, -10, 0, 20),
        Text = text .. ": " .. tostring(value),
        TextColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        Parent = self.Frame
    })
    local slider = create("TextButton", {
        Size = UDim2.new(1, -10, 0, 20),
        BackgroundColor3 = Color3.fromRGB(70, 70, 70),
        Parent = self.Frame
    })
    slider.MouseButton1Down:Connect(function()
        local moveConn
        moveConn = game:GetService("UserInputService").InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement then
                local pos = math.clamp((input.Position.X - slider.AbsolutePosition.X) / slider.AbsoluteSize.X, 0, 1)
                value = math.floor((min + (max - min) * pos))
                label.Text = text .. ": " .. tostring(value)
                if callback then pcall(callback, value) end
            end
        end)
        game:GetService("UserInputService").InputEnded:Connect(function(endInput)
            if endInput.UserInputType == Enum.UserInputType.MouseButton1 then
                if moveConn then moveConn:Disconnect() end
            end
        end)
    end)
end

-- 📝 Add Textbox
function KeyashiHub:AddTextbox(placeholder, callback)
    local box = create("TextBox", {
        Size = UDim2.new(1, -10, 0, 30),
        PlaceholderText = placeholder or "",
        Text = "",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundColor3 = Color3.fromRGB(60, 60, 60),
        Parent = self.Frame
    })
    box.FocusLost:Connect(function(enter)
        if enter and callback then pcall(callback, box.Text) end
    end)
end

return setmetatable({}, KeyashiHub)
