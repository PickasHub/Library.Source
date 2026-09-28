local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Player = Players.LocalPlayer

local cloneref = cloneref or clonereference or function(instance)
    return instance
end

ReplicatedStorage = cloneref(ReplicatedStorage)

-- Load WindUI
local WindUI

do
    local ok, result = pcall(function()
        return require("./src/Init")
    end)

    if ok then
        WindUI = result
    elseif RunService:IsStudio() then
        WindUI = require(
            ReplicatedStorage
                :WaitForChild("WindUI")
                :WaitForChild("Init")
        )
    else
        WindUI = loadstring(
            game:HttpGet(
                "https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"
            )
        )()
    end
end

-- Default Colors
local DefaultPurple = Color3.fromRGB(157, 0, 255)
local AccentColor = DefaultPurple

local ButtonColor = Color3.fromRGB(22, 16, 25)
local TextColor = Color3.fromRGB(245, 240, 255)
local MutedColor = Color3.fromRGB(139, 122, 150)

-- Theme
local function ApplyTheme(color)
    AccentColor = color

    local dark = color:Lerp(
        Color3.new(0, 0, 0),
        0.88
    )

    local purple = color:Lerp(
        Color3.new(0, 0, 0),
        0.72
    )

    WindUI:AddTheme({
        Name = "PickasDynamic",

        Accent = color,

        Background = WindUI:Gradient({
            ["0"] = {
                Color = dark,
                Transparency = 0
            },

            ["50"] = {
                Color = purple,
                Transparency = 0
            },

            ["100"] = {
                Color = dark,
                Transparency = 0
            },
        }, {
            Rotation = 45
        }),

        Outline = color,

        Text = TextColor,

        Placeholder = MutedColor,

        Button = ButtonColor,

        Icon = color,
    })

    WindUI:SetTheme("PickasDynamic")
end

-- Force default purple before the window is created
ApplyTheme(DefaultPurple)

-- Main Window
local Window = WindUI:CreateWindow({
    Title = "PICKA'S HUB",

    Folder = "PICKAS_HUB",

    Icon = "rbxassetid://97703901466521",

    NewElements = true,

    HideSearchBar = false,

    OpenButton = {
        Title = "PICKA'S HUB",

        Icon = "rbxassetid://97703901466521",

        CornerRadius = UDim.new(1, 0),

        StrokeThickness = 3,

        Enabled = true,

        Draggable = true,

        OnlyMobile = false,

        Scale = 0.34,

        Color = ColorSequence.new(
            DefaultPurple,
            Color3.fromRGB(80, 0, 130)
        ),
    },

    Topbar = {
        Height = 48,

        ButtonsType = "Default",
    },

    User = {
        Enabled = true,

        Anonymous = false,

        Callback = function()
        end,
    },
})

-- Force purple again after Window creation
ApplyTheme(DefaultPurple)

-- Version Tag
Window:Tag({
    Title = "VERSION 00.00.1",

    Icon = "tag",

    Border = true,

    Color = AccentColor,
})

-- Info Tab
local InfoTab = Window:Tab({
    Title = "Info",

    Icon = "solar:info-square-bold",

    IconColor = AccentColor,

    IconThemed = true,

    IconShape = nil,

    Border = true,
})

-- Session
local SessionStart = os.clock()

local SessionParagraph = InfoTab:Paragraph({
    Title = "Session",

    Desc = "Time: 00:00:00",

    Icon = "clock",

    IconThemed = true,
})

-- Ping
local PingParagraph = InfoTab:Paragraph({
    Title = "Ping",

    Desc = "Checking...",

    Icon = "activity",

    IconThemed = true,
})

-- Executor
local ExecutorName = "Unknown"

pcall(function()
    if identifyexecutor then
        local name = identifyexecutor()

        if name and name ~= "" then
            ExecutorName = tostring(name)
        end
    elseif getexecutorname then
        local name = getexecutorname()

        if name and name ~= "" then
            ExecutorName = tostring(name)
        end
    end
end)

InfoTab:Paragraph({
    Title = "Executor",

    Desc = ExecutorName,

    Icon = "terminal",

    IconThemed = true,
})

-- Device
local DeviceName = "PC"

if UserInputService.TouchEnabled then
    DeviceName = "Mobile"
end

InfoTab:Paragraph({
    Title = "Device",

    Desc = DeviceName,

    Icon = "smartphone",

    IconThemed = true,
})

-- HWID
local HWID = "Unavailable"

pcall(function()
    if gethwid then
        local value = gethwid()

        if value then
            HWID = tostring(value)
        end
    elseif get_hwid then
        local value = get_hwid()

        if value then
            HWID = tostring(value)
        end
    end
end)

InfoTab:Paragraph({
    Title = "HWID",

    Desc = HWID,

    Icon = "fingerprint",

    IconThemed = true,
})

-- Game
local GameName = "Unknown Game"

pcall(function()
    local MarketplaceService =
        game:GetService("MarketplaceService")

    local info =
        MarketplaceService:GetProductInfo(game.PlaceId)

    if info and info.Name then
        GameName = info.Name
    end
end)

InfoTab:Paragraph({
    Title = "Game",

    Desc = GameName,

    Icon = "gamepad-2",

    IconThemed = true,
})

-- Settings Tab
local SettingsTab = Window:Tab({
    Title = "Settings",

    Icon = "settings",

    IconColor = AccentColor,

    IconThemed = true,

    IconShape = nil,

    Border = true,
})

-- Accent Color
SettingsTab:Colorpicker({
    Flag = "PickasAccentColor",

    Title = "Accent Color",

    Desc = "Change the PICKA'S HUB accent color.",

    Default = DefaultPurple,

    Transparency = 0,

    Callback = function(color)
        if typeof(color) ~= "Color3" then
            return
        end

        ApplyTheme(color)

        pcall(function()
            Window:EditOpenButton({
                Color = ColorSequence.new(
                    color,
                    color:Lerp(
                        Color3.new(0, 0, 0),
                        0.35
                    )
                ),
            })
        end)
    end,
})

-- Open Button Size
SettingsTab:Slider({
    Flag = "OpenButtonSize",

    Title = "Open Button Size",

    Desc = "Adjust the size of the floating PICKA'S HUB button.",

    Step = 0.01,

    Value = {
        Min = 0.20,
        Max = 0.50,
        Default = 0.34,
    },

    Callback = function(value)
        local scale = tonumber(value)

        if not scale then
            return
        end

        pcall(function()
            Window:EditOpenButton({
                Scale = scale,
            })
        end)
    end,
})

-- Config Manager
local ConfigManager = Window.ConfigManager

if ConfigManager then
    pcall(function()
        ConfigManager:Init(Window)
    end)
end

local ConfigName = "default"

-- Configure Name
local ConfigNameInput = SettingsTab:Input({
    Flag = "ConfigName",

    Title = "Configure Name",

    Placeholder = "Put Configure Name Here",

    Icon = "file-cog",

    Callback = function(value)
        if value and value ~= "" then
            ConfigName = value
        end
    end,
})

-- Select Configure
local ConfigDropdown = SettingsTab:Dropdown({
    Title = "Select Configure",

    Values =
        ConfigManager
        and ConfigManager:AllConfigs()
        or {},

    Icon = "folder",

    Callback = function(value)
        if value then
            ConfigName = value

            pcall(function()
                ConfigNameInput:Set(value)
            end)
        end
    end,
})

-- Save Config
SettingsTab:Button({
    Title = "Save Config",

    Icon = "save",

    IconAlign = "Left",

    Callback = function()
        if not ConfigManager then
            return
        end

        if ConfigName == "" then
            ConfigName = "default"
        end

        Window.CurrentConfig =
            ConfigManager:Config(ConfigName)

        local success = false

        pcall(function()
            success = Window.CurrentConfig:Save()
        end)

        if success then
            pcall(function()
                ConfigDropdown:Refresh(
                    ConfigManager:AllConfigs()
                )
            end)

            WindUI:Notify({
                Title = "Config Saved",

                Content =
                    "Config '" ..
                    ConfigName ..
                    "' saved successfully.",

                Icon = "check",

                Duration = 3,
            })
        else
            WindUI:Notify({
                Title = "Config Error",

                Content =
                    "Failed to save '" ..
                    ConfigName ..
                    "'.",

                Icon = "x",

                Duration = 3,
            })
        end
    end,
})

-- Load Config
SettingsTab:Button({
    Title = "Load Config",

    Icon = "folder-open",

    IconAlign = "Left",

    Callback = function()
        if not ConfigManager then
            return
        end

        if ConfigName == "" then
            ConfigName = "default"
        end

        Window.CurrentConfig =
            ConfigManager:CreateConfig(ConfigName)

        local success = false

        pcall(function()
            success = Window.CurrentConfig:Load()
        end)

        if success then
            WindUI:Notify({
                Title = "Config Loaded",

                Content =
                    "Config '" ..
                    ConfigName ..
                    "' loaded successfully.",

                Icon = "refresh-cw",

                Duration = 3,
            })
        else
            WindUI:Notify({
                Title = "Config Error",

                Content =
                    "Config '" ..
                    ConfigName ..
                    "' could not be loaded.",

                Icon = "x",

                Duration = 3,
            })
        end
    end,
})

-- Delete Config
SettingsTab:Button({
    Title = "Delete Config",

    Icon = "trash-2",

    IconAlign = "Left",

    Callback = function()
        if not ConfigManager then
            return
        end

        if ConfigName == "" then
            return
        end

        local success = false

        pcall(function()
            success =
                ConfigManager:DeleteConfig(
                    ConfigName
                )
        end)

        if success then
            pcall(function()
                ConfigDropdown:Refresh(
                    ConfigManager:AllConfigs()
                )
            end)

            WindUI:Notify({
                Title = "Config Deleted",

                Content =
                    "Config '" ..
                    ConfigName ..
                    "' deleted.",

                Icon = "trash-2",

                Duration = 3,
            })
        else
            WindUI:Notify({
                Title = "Config Error",

                Content =
                    "Unable to delete '" ..
                    ConfigName ..
                    "'.",

                Icon = "x",

                Duration = 3,
            })
        end
    end,
})

-- Discord Community
SettingsTab:Paragraph({
    Title = "PICKA'S HUB Community",

    Desc = "Official Discord community",

    Icon = "discord",

    IconThemed = true,

    Buttons = {
        {
            Title = "Join Discord",

            Icon = "external-link",

            Variant = "Tertiary",

            Callback = function()
                local Invite =
                    "https://discord.gg/BJRkszT8rM"

                pcall(function()
                    if setclipboard then
                        setclipboard(Invite)
                    end
                end)

                WindUI:Notify({
                    Title = "Discord",

                    Content =
                        "Invite link copied.",

                    Icon = "check",

                    Duration = 3,
                })
            end,
        },
    },
})

-- Session and Ping updater
task.spawn(function()
    while task.wait(1) do
        if not SessionParagraph then
            break
        end

        -- Session
        local elapsed =
            math.floor(
                os.clock() - SessionStart
            )

        local hours =
            math.floor(elapsed / 3600)

        local minutes =
            math.floor(
                (elapsed % 3600) / 60
            )

        local seconds =
            elapsed % 60

        local SessionText =
            string.format(
                "Time: %02d:%02d:%02d",
                hours,
                minutes,
                seconds
            )

        pcall(function()
            SessionParagraph:SetDesc(
                SessionText
            )
        end)

        -- Ping
        local PingText = "Unknown"

        pcall(function()
            local Stats =
                game:GetService("Stats")

            local Network =
                Stats:FindFirstChild("Network")

            if Network then
                local ServerStatsItem =
                    Network:FindFirstChild(
                        "ServerStatsItem"
                    )

                if ServerStatsItem then
                    local DataPing =
                        ServerStatsItem:FindFirstChild(
                            "Data Ping"
                        )

                    if DataPing then
                        PingText =
                            tostring(
                                math.floor(
                                    DataPing:GetValue()
                                )
                            ) .. " ms"
                    end
                end
            end
        end)

        pcall(function()
            PingParagraph:SetDesc(
                PingText
            )
        end)
    end
end)

-- Return
return Window
