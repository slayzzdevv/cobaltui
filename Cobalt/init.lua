-- Cobalt/init.lua
local Window = require(script.Components.Window)
local Theme = require(script.Theme)
local Utility = require(script.Utility)

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
