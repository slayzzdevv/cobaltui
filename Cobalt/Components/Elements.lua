-- Cobalt/Components/Elements.lua
local Theme = require(script.Parent.Parent.Theme)
local Utility = require(script.Parent.Parent.Utility)
local UserInputService = game:GetService("UserInputService")

local Elements = {}

function Elements:Button(parent, text, callback)
    callback = callback or function() end
    
    local Button = Utility.Create("TextButton", {
        Name = text,
        Parent = parent,
        BackgroundColor3 = Theme.Tertiary,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 30),
        Font = Theme.Font.Medium,
        Text = text,
        TextColor3 = Theme.Text,
        TextSize = 12,
        AutoButtonColor = false,
    })
    Utility.Create("UICorner", {Parent = Button, CornerRadius = UDim.new(0, 4)})
    Utility.Create("UIStroke", {Parent = Button, Color = Theme.Outline, Thickness = 1})
    
    Button.MouseEnter:Connect(function() Utility.Tween(Button, 0.2, {BackgroundColor3 = Color3.fromRGB(45, 45, 45)}) end)
    Button.MouseLeave:Connect(function() Utility.Tween(Button, 0.2, {BackgroundColor3 = Theme.Tertiary}) end)
    Button.MouseButton1Click:Connect(function()
        Utility.Ripple(Button)
        callback()
    end)
    return Button
end

function Elements:Toggle(parent, text, default, callback)
    callback = callback or function() end
    local enabled = default or false
    
    local ToggleFrame = Utility.Create("TextButton", {
        Parent = parent,
        BackgroundColor3 = Theme.Tertiary,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 30),
        Text = "",
        AutoButtonColor = false,
    })
    Utility.Create("UICorner", {Parent = ToggleFrame, CornerRadius = UDim.new(0, 4)})
    Utility.Create("UIStroke", {Parent = ToggleFrame, Color = Theme.Outline, Thickness = 1})
    
    Utility.Create("TextLabel", {
        Parent = ToggleFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(1, -50, 1, 0),
        Font = Theme.Font.Medium,
        Text = text,
        TextColor3 = Theme.Text,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    
    local Indicator = Utility.Create("Frame", {
        Parent = ToggleFrame,
        BackgroundColor3 = enabled and Theme.Accent or Color3.fromRGB(60, 60, 60),
        BorderSizePixel = 0,
        Position = UDim2.new(1, -34, 0.5, -9),
        Size = UDim2.new(0, 28, 0, 18),
    })
    Utility.Create("UICorner", {Parent = Indicator, CornerRadius = UDim.new(1, 0)})
    
    local Circle = Utility.Create("Frame", {
        Parent = Indicator,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        Position = enabled and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7),
        Size = UDim2.new(0, 14, 0, 14),
    })
    Utility.Create("UICorner", {Parent = Circle, CornerRadius = UDim.new(1, 0)})
    
    ToggleFrame.MouseButton1Click:Connect(function()
        enabled = not enabled
        local targetColor = enabled and Theme.Accent or Color3.fromRGB(60, 60, 60)
        local targetPos = enabled and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
        
        Utility.Tween(Indicator, 0.2, {BackgroundColor3 = targetColor})
        Utility.Tween(Circle, 0.2, {Position = targetPos})
        callback(enabled)
    end)
    return ToggleFrame
end

function Elements:Slider(parent, text, min, max, default, callback)
    callback = callback or function() end
    default = math.clamp(default or min, min, max)
    
    local SliderFrame = Utility.Create("Frame", {
        Parent = parent,
        BackgroundColor3 = Theme.Tertiary,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 42),
    })
    Utility.Create("UICorner", {Parent = SliderFrame, CornerRadius = UDim.new(0, 4)})
    Utility.Create("UIStroke", {Parent = SliderFrame, Color = Theme.Outline, Thickness = 1})
    
    Utility.Create("TextLabel", {
        Parent = SliderFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 5),
        Size = UDim2.new(1, -20, 0, 15),
        Font = Theme.Font.Medium,
        Text = text,
        TextColor3 = Theme.Text,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    
    local ValueLabel = Utility.Create("TextLabel", {
        Parent = SliderFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -60, 0, 5),
        Size = UDim2.new(0, 50, 0, 15),
        Font = Theme.Font.Regular,
        Text = tostring(default),
        TextColor3 = Theme.TextDark,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Right,
    })
    
    local Bar = Utility.Create("Frame", {
        Parent = SliderFrame,
        BackgroundColor3 = Color3.fromRGB(20, 20, 20),
        BorderSizePixel = 0,
        Position = UDim2.new(0, 10, 0, 28),
        Size = UDim2.new(1, -20, 0, 4),
    })
    Utility.Create("UICorner", {Parent = Bar, CornerRadius = UDim.new(1, 0)})
    
    local Fill = Utility.Create("Frame", {
        Parent = Bar,
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
    })
    Utility.Create("UICorner", {Parent = Fill, CornerRadius = UDim.new(1, 0)})
    
    local DragBtn = Utility.Create("TextButton", {
        Parent = Bar,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Text = "",
    })
    
    local dragging = false
    local function Update(input)
        local pos = math.clamp((input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
        local value = math.floor(min + ((max - min) * pos))
        
        Utility.Tween(Fill, 0.05, {Size = UDim2.new(pos, 0, 1, 0)})
        ValueLabel.Text = tostring(value)
        callback(value)
    end
    
    DragBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            Update(input)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            Update(input)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    return SliderFrame
end

function Elements:Dropdown(parent, text, options, callback)
    callback = callback or function() end
    options = options or {}
    local open = false
    
    local DropFrame = Utility.Create("Frame", {
        Parent = parent,
        BackgroundColor3 = Theme.Tertiary,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 32),
        ClipsDescendants = true,
    })
    Utility.Create("UICorner", {Parent = DropFrame, CornerRadius = UDim.new(0, 4)})
    Utility.Create("UIStroke", {Parent = DropFrame, Color = Theme.Outline, Thickness = 1})
    
    local MainBtn = Utility.Create("TextButton", {
        Parent = DropFrame,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 32),
        Font = Theme.Font.Medium,
        Text = "  " .. text,
        TextColor3 = Theme.Text,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    
    local Arrow = Utility.Create("ImageLabel", {
        Parent = MainBtn,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -25, 0.5, -8),
        Size = UDim2.new(0, 16, 0, 16),
        Image = "rbxassetid://6034818372",
        ImageColor3 = Theme.TextDark,
    })
    
    local List = Utility.Create("ScrollingFrame", {
        Parent = DropFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 35),
        Size = UDim2.new(1, 0, 1, -35),
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = Theme.Accent,
        CanvasSize = UDim2.new(0, 0, 0, 0),
    })
    local ListLayout = Utility.Create("UIListLayout", {Parent = List, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 2)})
    
    ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        List.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y)
    end)
    
    for _, option in pairs(options) do
        local OptBtn = Utility.Create("TextButton", {
            Parent = List,
            BackgroundColor3 = Theme.Secondary,
            BorderSizePixel = 0,
            Size = UDim2.new(1, -10, 0, 25),
            Font = Theme.Font.Regular,
            Text = option,
            TextColor3 = Theme.TextDark,
            TextSize = 12,
        })
        Utility.Create("UICorner", {Parent = OptBtn, CornerRadius = UDim.new(0, 4)})
        OptBtn.MouseButton1Click:Connect(function()
            MainBtn.Text = "  " .. text .. ": " .. option
            callback(option)
            open = false
            Utility.Tween(DropFrame, 0.3, {Size = UDim2.new(1, 0, 0, 32)})
            Utility.Tween(Arrow, 0.3, {Rotation = 0})
        end)
    end
    
    MainBtn.MouseButton1Click:Connect(function()
        open = not open
        if open then
            local height = math.min(#options * 27 + 10, 150)
            Utility.Tween(DropFrame, 0.3, {Size = UDim2.new(1, 0, 0, 32 + height)})
            Utility.Tween(Arrow, 0.3, {Rotation = 180})
        else
            Utility.Tween(DropFrame, 0.3, {Size = UDim2.new(1, 0, 0, 32)})
            Utility.Tween(Arrow, 0.3, {Rotation = 0})
        end
    end)
    return DropFrame
end

function Elements:Textbox(parent, text, placeholder, callback)
    callback = callback or function() end
    
    local BoxFrame = Utility.Create("Frame", {
        Parent = parent,
        BackgroundColor3 = Theme.Tertiary,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 35),
    })
    Utility.Create("UICorner", {Parent = BoxFrame, CornerRadius = UDim.new(0, 4)})
    Utility.Create("UIStroke", {Parent = BoxFrame, Color = Theme.Outline, Thickness = 1})
    
    Utility.Create("TextLabel", {
        Parent = BoxFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(0.4, 0, 1, 0),
        Font = Theme.Font.Medium,
        Text = text,
        TextColor3 = Theme.Text,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    
    local Input = Utility.Create("TextBox", {
        Parent = BoxFrame,
        BackgroundColor3 = Theme.Secondary,
        BorderSizePixel = 0,
        Position = UDim2.new(0.45, 0, 0.15, 0),
        Size = UDim2.new(0.53, 0, 0.7, 0),
        Font = Theme.Font.Regular,
        Text = "",
        PlaceholderText = placeholder,
        PlaceholderColor3 = Color3.fromRGB(100, 100, 100),
        TextColor3 = Theme.Text,
        TextSize = 12,
    })
    Utility.Create("UICorner", {Parent = Input, CornerRadius = UDim.new(0, 4)})
    
    Input.FocusLost:Connect(function()
        callback(Input.Text)
    end)
    return BoxFrame
end

return Elements
