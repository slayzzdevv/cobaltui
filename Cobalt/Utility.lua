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
