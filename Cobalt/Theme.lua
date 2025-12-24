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
