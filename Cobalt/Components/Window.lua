-- Cobalt/Components/Window.lua
local Theme = require(script.Parent.Parent.Theme)
local Utility = require(script.Parent.Parent.Utility)
local Elements = require(script.Parent.Elements)

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
    
    AddIcon(Theme.Icons.Close, "Close"):MouseButton1Click:Connect(function() self.ScreenGui:Destroy(); self.Blur:Destroy() end)
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
