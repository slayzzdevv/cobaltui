-- Cobalt UI Library Bundled Release
local Modules = {}

Modules["Theme"] = function()
-- Cobalt/Theme.lua
return {
    Main = Color3.fromRGB(15, 15, 15), -- Very dark background
    Secondary = Color3.fromRGB(25, 25, 25), -- Sidebar/Topbar
    Tertiary = Color3.fromRGB(35, 35, 35), -- Elements
    Accent = Color3.fromRGB(255, 149, 0), -- Cobalt Orange
    Text = Color3.fromRGB(240, 240, 240),
    TextDark = Color3.fromRGB(150, 150, 150),
    Outline = Color3.fromRGB(45, 45, 45),
    Divisor = Color3.fromRGB(35, 35, 35),
    
    Font = {
        Regular = Enum.Font.Gotham,
        Medium = Enum.Font.GothamMedium,
        Bold = Enum.Font.GothamBold,
    },
    
    Icons = {
        Search = "rbxassetid://6031154871",
        Settings = "rbxassetid://6031280882",
        Close = "rbxassetid://6031094678", 
        Minimize = "rbxassetid://6035047409", 
        Lightning = "rbxassetid://6031091004", -- Generic active icon
        Folder = "rbxassetid://6031079194", -- Generic folder
    }
}

end

Modules["Utility"] = function()
-- Cobalt/Utility.lua
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")

local Utility = {}

function Utility.Create(class, properties)
    local instance = Instance.new(class)
    for k, v in next, properties do
        instance[k] = v
    end
    return instance
end

function Utility.Tween(instance, time, properties)
    local tween = TweenService:Create(instance, TweenInfo.new(time, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), properties)
    tween:Play()
    return tween
end

function Utility.Protect(gui)
    if syn and syn.protect_gui then
        syn.protect_gui(gui)
        gui.Parent = CoreGui
    elseif gethui then
        gui.Parent = gethui()
    elseif CoreGui:FindFirstChild("RobloxGui") then
        gui.Parent = CoreGui
    else
        -- Fallback for testing/Studio
        gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    end
end

function Utility.Ripple(button)
    spawn(function()
        local ripple = Utility.Create("ImageLabel", {
            Name = "Ripple",
            Parent = button,
            BackgroundTransparency = 1,
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Size = UDim2.new(0, 0, 0, 0),
            Image = "rbxassetid://266543268",
            ImageColor3 = Color3.fromRGB(255, 255, 255),
            ImageTransparency = 0.8,
            AnchorPoint = Vector2.new(0.5, 0.5),
            ClipsDescendants = true,
        })
        
        local tween = Utility.Tween(ripple, 0.5, {
            Size = UDim2.new(2, 0, 2, 0),
            ImageTransparency = 1
        })
        
        tween.Completed:Wait()
        ripple:Destroy()
    end)
end

function Utility.MakeDraggable(topbar, object)
    local dragging, dragInput, dragStart, startPos

    topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = object.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    topbar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            Utility.Tween(object, 0.05, {
                Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            })
        end
    end)
end

return Utility

end

Modules["Components/Elements"] = function()
-- Cobalt/Components/Elements.lua
local Theme = require("Theme")
local Utility = require("Utility")
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

end

Modules["Components/Window"] = function()
-- Cobalt/Components/Window.lua
local Theme = require("Theme")
local Utility = require("Utility")
local Elements = require("Components/Elements")

local Window = {}
Window.__index = Window

function Window.new(title)
    local self = setmetatable({}, Window)
    
    -- Main ScreenGui
    self.ScreenGui = Utility.Create("ScreenGui", {Name = "CobaltLibrary", ResetOnSpawn = false})
    Utility.Protect(self.ScreenGui)
    
    -- Blur Effect
    self.Blur = Utility.Create("BlurEffect", {Parent = game:GetService("Lighting"), Size = 0, Name = "CobaltBlur"})
    Utility.Tween(self.Blur, 0.8, {Size = 15})

    -- Main Container
    self.MainFrame = Utility.Create("Frame", {
        Name = "MainFrame",
        Parent = self.ScreenGui,
        BackgroundColor3 = Theme.Main,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, -350, 0.5, -250),
        Size = UDim2.new(0, 700, 0, 500),
        ClipsDescendants = true,
    })
    Utility.Create("UICorner", {Parent = self.MainFrame, CornerRadius = UDim.new(0, 6)})
    Utility.Create("UIStroke", {Parent = self.MainFrame, Color = Theme.Outline, Thickness = 1})

    -- Topbar
    local Topbar = Utility.Create("Frame", {
        Name = "Topbar",
        Parent = self.MainFrame,
        BackgroundColor3 = Theme.Secondary,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 40),
        ZIndex = 2
    })
    
    -- Topbar Title (Centered)
    Utility.Create("TextLabel", {
        Parent = Topbar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(0, 200, 1, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Font = Theme.Font.Medium,
        Text = title,
        TextColor3 = Theme.Text,
        TextSize = 16,
    })
    
    -- Topbar Icons (Right)
    local IconContainer = Utility.Create("Frame", {
        Parent = Topbar,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -10, 0, 0),
        Size = UDim2.new(0, 100, 1, 0),
        AnchorPoint = Vector2.new(1, 0)
    })
    local IconLayout = Utility.Create("UIListLayout", {
        Parent = IconContainer,
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        Padding = UDim.new(0, 10),
        VerticalAlignment = Enum.VerticalAlignment.Center
    })
    
    local function AddIcon(id, name)
        local btn = Utility.Create("ImageButton", {
            Name = name,
            Parent = IconContainer,
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 20, 0, 20),
            Image = id,
            ImageColor3 = Theme.TextDark,
        })
        return btn
    end
    
    AddIcon(Theme.Icons.Close, "Close").MouseButton1Click:Connect(function() self.ScreenGui:Destroy(); self.Blur:Destroy() end)
    AddIcon(Theme.Icons.Minimize, "Min")
    AddIcon(Theme.Icons.Settings, "Settings")
    AddIcon(Theme.Icons.Search, "Search")
    
    Utility.MakeDraggable(Topbar, self.MainFrame)

    -- Sidebar (Left)
    local Sidebar = Utility.Create("Frame", {
        Name = "Sidebar",
        Parent = self.MainFrame,
        BackgroundColor3 = Theme.Secondary,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 40),
        Size = UDim2.new(0, 220, 1, -40),
        ZIndex = 1
    })
    
    -- Sidebar Border
    Utility.Create("Frame", {
        Parent = Sidebar,
        BackgroundColor3 = Theme.Outline,
        BorderSizePixel = 0,
        Position = UDim2.new(1, -1, 0, 0),
        Size = UDim2.new(0, 1, 1, 0)
    })
    
    -- Category Switcher (Outgoing | Incoming)
    local Switcher = Utility.Create("Frame", {
        Name = "Switcher",
        Parent = Sidebar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 10),
        Size = UDim2.new(1, -20, 0, 30),
    })
    
    local SwitchBtn1 = Utility.Create("TextButton", {
        Parent = Switcher,
        BackgroundColor3 = Theme.Tertiary,
        BorderSizePixel = 0,
        Size = UDim2.new(0.5, -2, 1, 0),
        Font = Theme.Font.Medium,
        Text = "Outgoing",
        TextColor3 = Theme.Text,
        TextSize = 12,
    })
    Utility.Create("UICorner", {Parent = SwitchBtn1, CornerRadius = UDim.new(0, 4)})
    
    local SwitchBtn2 = Utility.Create("TextButton", {
        Parent = Switcher,
        BackgroundColor3 = Theme.Main, -- Inactive
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, 2, 0, 0),
        Size = UDim2.new(0.5, -2, 1, 0),
        Font = Theme.Font.Medium,
        Text = "Incoming",
        TextColor3 = Theme.TextDark,
        TextSize = 12,
    })
    Utility.Create("UICorner", {Parent = SwitchBtn2, CornerRadius = UDim.new(0, 4)})

    -- Tab Container List
    self.TabContainer = Utility.Create("ScrollingFrame", {
        Name = "TabContainer",
        Parent = Sidebar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 50),
        Size = UDim2.new(1, 0, 1, -50),
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = Theme.Accent,
    })
    Utility.Create("UIListLayout", {Parent = self.TabContainer, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 2)})
    Utility.Create("UIPadding", {Parent = self.TabContainer, PaddingTop = UDim.new(0, 10), PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10)})
    
    -- Pages Container (Right)
    self.Pages = Utility.Create("Frame", {
        Name = "Pages",
        Parent = self.MainFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 220, 0, 40),
        Size = UDim2.new(1, -220, 1, -40),
        ClipsDescendants = true,
    })
    
    self.Tabs = {}
    self.FirstTab = true
    
    return self
end

function Window:Tab(name, options)
    options = options or {}
    local icon = options.icon or "rbxassetid://6031091004" -- Generic bolt
    local count = options.count or ""
    
    local TabButton = Utility.Create("TextButton", {
        Name = name,
        Parent = self.TabContainer,
        BackgroundColor3 = Theme.Secondary,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 32),
        AutoButtonColor = false,
        Text = ""
    })
    
    -- Icon
    local IconImg = Utility.Create("ImageLabel", {
        Parent = TabButton,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 8, 0.5, -8),
        Size = UDim2.new(0, 16, 0, 16),
        Image = icon,
        ImageColor3 = Theme.Accent, -- Active by default for test
    })
    
    -- Title
    local Title = Utility.Create("TextLabel", {
        Parent = TabButton,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 32, 0, 0),
        Size = UDim2.new(1, -70, 1, 0),
        Font = Theme.Font.Medium,
        Text = name,
        TextColor3 = Theme.Text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    
    -- Count (Right side)
    if count ~= "" then
        Utility.Create("TextLabel", {
            Parent = TabButton,
            BackgroundTransparency = 1,
            Position = UDim2.new(1, -30, 0, 0),
            Size = UDim2.new(0, 30, 1, 0),
            Font = Theme.Font.Regular,
            Text = "x" .. count,
            TextColor3 = Theme.TextDark,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Right,
        })
    end
    
    -- Hover effect
    TabButton.MouseEnter:Connect(function()
        if TabButton.BackgroundColor3 ~= Theme.Tertiary then
            Utility.Tween(TabButton, 0.2, {BackgroundColor3 = Color3.fromRGB(30, 30, 30)})
        end
    end)
    TabButton.MouseLeave:Connect(function()
        if TabButton.BackgroundColor3 ~= Theme.Tertiary then
            Utility.Tween(TabButton, 0.2, {BackgroundColor3 = Theme.Secondary})
        end
    end)

    local Page = Utility.Create("ScrollingFrame", {
        Name = name .. "Page",
        Parent = self.Pages,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = Theme.Accent,
        BorderSizePixel = 0,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        Visible = false,
    })
    local PageLayout = Utility.Create("UIListLayout", {Parent = Page, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8)})
    Utility.Create("UIPadding", {Parent = Page, PaddingTop = UDim.new(0, 20), PaddingLeft = UDim.new(0, 20), PaddingRight = UDim.new(0, 20), PaddingBottom = UDim.new(0, 20)})

    PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Page.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 40)
    end)

    local function Activate()
        -- Reset all Layout Order or Backgrounds
        for _, t in pairs(self.TabContainer:GetChildren()) do
            if t:IsA("TextButton") then
                Utility.Tween(t, 0.2, {BackgroundColor3 = Theme.Secondary})
                -- Reset Text Color logic if implemented separate
            end
        end
        for _, p in pairs(self.Pages:GetChildren()) do
            p.Visible = false
        end
        
        -- Activate self
        Utility.Tween(TabButton, 0.2, {BackgroundColor3 = Theme.Tertiary}) -- Highlight
        Page.Visible = true
    end

    TabButton.MouseButton1Click:Connect(Activate)

    if self.FirstTab then
        self.FirstTab = false
        Activate()
    end
    
    -- Standard Elements Integration
    local TabLogic = {}
    function TabLogic:Section(title)
        -- Create a Section Divider look
        local SectionTitle = Utility.Create("TextLabel", {
            Parent = Page,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 25),
            Font = Theme.Font.Bold,
            Text = title,
            TextColor3 = Theme.Accent,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
        })
        
        local Container = Utility.Create("Frame", {
            Parent = Page,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 0),
        })
        local ContainerLayout = Utility.Create("UIListLayout", {Parent = Container, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 6)})
        ContainerLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Container.Size = UDim2.new(1, 0, 0, ContainerLayout.AbsoluteContentSize.Y)
        end)
        
        local SectionLogic = {}
        function SectionLogic:Button(text, cb) Elements:Button(Container, text, cb) end
        function SectionLogic:Toggle(text, def, cb) Elements:Toggle(Container, text, def, cb) end
        function SectionLogic:Slider(text, min, max, def, cb) Elements:Slider(Container, text, min, max, def, cb) end
        function SectionLogic:Dropdown(text, opts, cb) Elements:Dropdown(Container, text, opts, cb) end
        function SectionLogic:Textbox(text, ph, cb) Elements:Textbox(Container, text, ph, cb) end
        return SectionLogic
    end
    
    return TabLogic
end

return Window

end

Modules["init"] = function()
-- Cobalt/init.lua
local Window = require("Components/Window")
local Theme = require("Theme")
local Utility = require("Utility")

local Cobalt = {}

function Cobalt:Window(title)
    return Window.new(title)
end

function Cobalt:SetTheme(newTheme)
    for k, v in pairs(newTheme) do
        Theme[k] = v
    end
end

function Cobalt:Notification(title, text, duration)
    -- Simplified notification call re-using utility logic if needed, 
    -- but for now keeping it simple as part of the main module or a separate component.
    -- Ideally this should also be a component, but we'll inline a basic one for now.
    local CoreGui = game:GetService("CoreGui")
    local ScreenGui = CoreGui:FindFirstChild("CobaltNotifications")
    if not ScreenGui then
        ScreenGui = Utility.Create("ScreenGui", {Name = "CobaltNotifications", Parent = CoreGui})
    end
    
    local Container = ScreenGui:FindFirstChild("Container")
    if not Container then
        Container = Utility.Create("Frame", {
            Name = "Container",
            Parent = ScreenGui,
            BackgroundTransparency = 1,
            Position = UDim2.new(1, -320, 1, -20),
            Size = UDim2.new(0, 300, 1, 0),
            AnchorPoint = Vector2.new(0, 1)
        })
        Utility.Create("UIListLayout", {
            Parent = Container,
            SortOrder = Enum.SortOrder.LayoutOrder,
            VerticalAlignment = Enum.VerticalAlignment.Bottom,
            Padding = UDim.new(0, 10)
        })
    end

    local NotifyFrame = Utility.Create("Frame", {
        Name = "Notify",
        Parent = Container,
        BackgroundColor3 = Theme.Secondary,
        Size = UDim2.new(1, 0, 0, 60),
        BackgroundTransparency = 1,
    })
    Utility.Create("UICorner", {Parent = NotifyFrame, CornerRadius = UDim.new(0, 6)})
    Utility.Create("UIStroke", {Parent = NotifyFrame, Color = Theme.Outline, Thickness = 1})
    
    Utility.Create("Frame", {
        Parent = NotifyFrame,
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(0, 4, 1, 0),
    })

    local TitleLabel = Utility.Create("TextLabel", {
        Parent = NotifyFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 15, 0, 8),
        Size = UDim2.new(1, -20, 0, 20),
        Font = Theme.Font.Bold,
        Text = title,
        TextColor3 = Theme.Text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTransparency = 1
    })

    local DescLabel = Utility.Create("TextLabel", {
        Parent = NotifyFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 15, 0, 30),
        Size = UDim2.new(1, -20, 0, 20),
        Font = Theme.Font.Regular,
        Text = text,
        TextColor3 = Theme.TextDark,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTransparency = 1
    })
    
    Utility.Tween(NotifyFrame, 0.5, {BackgroundTransparency = 0})
    Utility.Tween(TitleLabel, 0.5, {TextTransparency = 0})
    Utility.Tween(DescLabel, 0.5, {TextTransparency = 0})
    
    task.delay(duration or 3, function()
        local out = Utility.Tween(NotifyFrame, 0.5, {BackgroundTransparency = 1})
        Utility.Tween(TitleLabel, 0.5, {TextTransparency = 1})
        Utility.Tween(DescLabel, 0.5, {TextTransparency = 1})
        out.Completed:Wait()
        NotifyFrame:Destroy()
    end)
end

return Cobalt

end

local function require(name)
    if Modules[name] then
        if type(Modules[name]) == "function" then
            Modules[name] = Modules[name]()
        end
        return Modules[name]
    end
    return error("Module not found: " .. tostring(name))
end

return require("init")