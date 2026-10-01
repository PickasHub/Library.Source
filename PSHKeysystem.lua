----- Picka's Hub Main.lua

local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local HttpService = game:GetService("HttpService")

local Player = Players.LocalPlayer

----- Settings
local SUPPORT_URL =
    "https://raw.githubusercontent.com/PickasHub/Library.Source/refs/heads/main/Support-games"

local JUNKIE_SERVICE = "Picka's Hub"
local JUNKIE_IDENTIFIER = "1187031"
local JUNKIE_PROVIDER = "Picka"

local function notify(title, message)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = title,
            Text = message,
            Duration = 4
        })
    end)
end

----- Load supported games
local Supported

local function loadSupported()
    local ok, result = pcall(function()
        return loadstring(game:HttpGet(SUPPORT_URL))()
    end)

    if ok and type(result) == "table" then
        return result
    end

    return {
        Keysystem = {},
        Keyless = {},
        Both = {}
    }
end

Supported = loadSupported()

local Keysystem = Supported.Keysystem or {}
local Keyless = Supported.Keyless or {}
local Both = Supported.Both or {}

local PlaceId = game.PlaceId

----- Detect mode
local hasKeysystem = Keysystem[PlaceId] ~= nil
local hasKeyless = Keyless[PlaceId] ~= nil

local mode

if Both[PlaceId] == true then
    mode = "Keyless & Key System"
elseif hasKeysystem and hasKeyless then
    mode = "Keyless & Key System"
elseif hasKeyless then
    mode = "Keyless Only"
elseif hasKeysystem then
    mode = "Key System Only"
else
    mode = "Not Supported"
end

----- Get game name
local GameName = "Unknown Game"

pcall(function()
    local info = MarketplaceService:GetProductInfo(PlaceId)
    if info and info.Name then
        GameName = info.Name
    end
end)

----- Load game script
local function loadGameScript(url)
    if type(url) ~= "string" or url == "" then
        notify("Picka's Hub", "Script link is missing.")
        return false
    end

    local ok, response = pcall(function()
        return game:HttpGet(url)
    end)

    if not ok then
        notify("Picka's Hub", "Failed to download the script.")
        return false
    end

    local compileOk, scriptFunction = pcall(function()
        return loadstring(response)
    end)

    if not compileOk or type(scriptFunction) ~= "function" then
        notify("Picka's Hub", "The downloaded script is invalid.")
        return false
    end

    local runOk, runError = pcall(scriptFunction)

    if not runOk then
        warn("[Picka's Hub] Script error:", runError)
        notify("Picka's Hub", "The script failed to run.")
        return false
    end

    return true
end

----- Keyless Mode?.
local function startKeyless()
    if not hasKeyless then
        notify(
            "Picka's Hub",
            "No Keyless mode please get a key and submit it!"
        )
        return
    end

    notify("Picka's Hub", "Starting Keyless Mode...")

    task.spawn(function()
        loadGameScript(Keyless[PlaceId])
    end)
end

----- Jnkie
local Junkie

pcall(function()
    Junkie = loadstring(
        game:HttpGet("https://jnkie.com/sdk/library.lua")
    )()

    Junkie.service = JUNKIE_SERVICE
    Junkie.identifier = JUNKIE_IDENTIFIER
    Junkie.provider = JUNKIE_PROVIDER
end)

----- Verify key
local function verifyKey(key)
    if not hasKeysystem then
        notify(
            "Picka's Hub",
            "No key needed! Click Keyless mode!"
        )
        return false
    end

    if not Junkie then
        notify(
            "Picka's Hub",
            "Jnkie failed to initialize."
        )
        return false
    end

    if type(key) ~= "string" or key == "" then
        notify(
            "Picka's Hub",
            "Please enter your key."
        )
        return false
    end

    local ok, result = pcall(function()
        return Junkie.check_key(key)
    end)

    if not ok or type(result) ~= "table" then
        notify(
            "Picka's Hub",
            "Unable to verify the key."
        )
        return false
    end

    if result.valid then
        if result.message == "KEYLESS" then
            getgenv().SCRIPT_KEY = "KEYLESS"

            notify(
                "Picka's Hub",
                "Keyless access verified."
            )

            return true
        end

        if result.message == "KEY_VALID" then
            getgenv().SCRIPT_KEY = key

            notify(
                "Picka's Hub",
                "Key verified successfully."
            )

            task.spawn(function()
                loadGameScript(Keysystеm[PlaceId])
            end)

            return true
        end
    end

    notify(
        "Picka's Hub",
        result.message or "Invalid key."
    )

    return false
end

----- Get Jnkie key link
local function getKeyLink()
    if not Junkie then
        notify(
            "Picka's Hub",
            "Jnkie failed to initialize."
        )
        return nil
    end

    local ok, link = pcall(function()
        return Junkie.get_key_link()
    end)

    if not ok or type(link) ~= "string" then
        notify(
            "Picka's Hub",
            "Failed to get key link."
        )
        return nil
    end

    if setclipboard then
        pcall(function()
            setclipboard(link)
        end)

        notify(
            "Picka's Hub",
            "Key link copied!"
        )
    else
        notify(
            "Picka's Hub",
            link
        )
    end

    return link
end

----- UI
local Gui = Instance.new("ScreenGui")
Gui.Name = "PICKAS_HUB"
Gui.ResetOnSpawn = false
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

pcall(function()
    Gui.Parent = game:GetService("CoreGui")
end)

if not Gui.Parent then
    Gui.Parent = Player:WaitForChild("PlayerGui")
end

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.fromOffset(500, 330)
Main.Position = UDim2.new(0.5, -250, 0.5, -165)
Main.BackgroundColor3 = Color3.fromRGB(18, 8, 27)
Main.BorderSizePixel = 0
Main.Parent = Gui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = Main

local Stroke = Instance.new("UIStroke")
Stroke.Color = Color3.fromRGB(157, 0, 255)
Stroke.Transparency = 0.35
Stroke.Parent = Main

----- Title
local Title = Instance.new("TextLabel")
Title.BackgroundTransparency = 1
Title.Position = UDim2.fromOffset(20, 15)
Title.Size = UDim2.fromOffset(300, 28)
Title.Font = Enum.Font.GothamBold
Title.Text = "Picka's Hub"
Title.TextColor3 = Color3.fromRGB(245, 240, 255)
Title.TextSize = 20
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Main

local Description = Instance.new("TextLabel")
Description.BackgroundTransparency = 1
Description.Position = UDim2.fromOffset(20, 43)
Description.Size = UDim2.fromOffset(300, 22)
Description.Font = Enum.Font.Gotham
Description.Text = "Key System"
Description.TextColor3 = Color3.fromRGB(170, 150, 185)
Description.TextSize = 12
Description.TextXAlignment = Enum.TextXAlignment.Left
Description.Parent = Main

----- Game Card
local GameCard = Instance.new("Frame")
GameCard.Position = UDim2.fromOffset(20, 82)
GameCard.Size = UDim2.fromOffset(460, 65)
GameCard.BackgroundColor3 = Color3.fromRGB(27, 13, 38)
GameCard.BorderSizePixel = 0
GameCard.Parent = Main

local CardCorner = Instance.new("UICorner")
CardCorner.CornerRadius = UDim.new(0, 9)
CardCorner.Parent = GameCard

local GameTitle = Instance.new("TextLabel")
GameTitle.BackgroundTransparency = 1
GameTitle.Position = UDim2.fromOffset(15, 9)
GameTitle.Size = UDim2.fromOffset(260, 23)
GameTitle.Font = Enum.Font.GothamBold
GameTitle.Text = GameName
GameTitle.TextColor3 = Color3.fromRGB(245, 240, 255)
GameTitle.TextSize = 14
GameTitle.TextXAlignment = Enum.TextXAlignment.Left
GameTitle.Parent = GameCard

local GameIdText = Instance.new("TextLabel")
GameIdText.BackgroundTransparency = 1
GameIdText.Position = UDim2.fromOffset(15, 34)
GameIdText.Size = UDim2.fromOffset(260, 20)
GameIdText.Font = Enum.Font.Gotham
GameIdText.Text = "Place ID: " .. tostring(PlaceId)
GameIdText.TextColor3 = Color3.fromRGB(140, 125, 155)
GameIdText.TextSize = 11
GameIdText.TextXAlignment = Enum.TextXAlignment.Left
GameIdText.Parent = GameCard

local Status = Instance.new("TextLabel")
Status.BackgroundTransparency = 1
Status.Position = UDim2.fromOffset(285, 20)
Status.Size = UDim2.fromOffset(160, 25)
Status.Font = Enum.Font.GothamBold
Status.Text = mode
Status.TextColor3 =
    mode == "Not Supported"
    and Color3.fromRGB(255, 100, 100)
    or Color3.fromRGB(180, 100, 255)
Status.TextSize = 12
Status.TextXAlignment = Enum.TextXAlignment.Right
Status.Parent = GameCard

----- Key box
local KeyBox = Instance.new("TextBox")
KeyBox.Position = UDim2.fromOffset(20, 162)
KeyBox.Size = UDim2.fromOffset(460, 43)
KeyBox.BackgroundColor3 = Color3.fromRGB(27, 13, 38)
KeyBox.BorderSizePixel = 0
KeyBox.ClearTextOnFocus = false
KeyBox.Font = Enum.Font.Gotham
KeyBox.PlaceholderText = "Paste your key here"
KeyBox.PlaceholderColor3 = Color3.fromRGB(120, 105, 135)
KeyBox.Text = ""
KeyBox.TextColor3 = Color3.fromRGB(245, 240, 255)
KeyBox.TextSize = 13
KeyBox.Parent = Main

local KeyCorner = Instance.new("UICorner")
KeyCorner.CornerRadius = UDim.new(0, 8)
KeyCorner.Parent = KeyBox

local KeyPadding = Instance.new("UIPadding")
KeyPadding.PaddingLeft = UDim.new(0, 12)
KeyPadding.PaddingRight = UDim.new(0, 12)
KeyPadding.Parent = KeyBox

----- Submit
local Submit = Instance.new("TextButton")
Submit.Position = UDim2.fromOffset(20, 216)
Submit.Size = UDim2.fromOffset(220, 42)
Submit.BackgroundColor3 = Color3.fromRGB(75, 25, 105)
Submit.BorderSizePixel = 0
Submit.Font = Enum.Font.GothamBold
Submit.Text = "Verify Key"
Submit.TextColor3 = Color3.fromRGB(255, 255, 255)
Submit.TextSize = 13
Submit.Parent = Main

local SubmitCorner = Instance.new("UICorner")
SubmitCorner.CornerRadius = UDim.new(0, 8)
SubmitCorner.Parent = Submit

----- Get Key
local GetKey = Instance.new("TextButton")
GetKey.Position = UDim2.fromOffset(260, 216)
GetKey.Size = UDim2.fromOffset(220, 42)
GetKey.BackgroundColor3 = Color3.fromRGB(39, 19, 51)
GetKey.BorderSizePixel = 0
GetKey.Font = Enum.Font.GothamBold
GetKey.Text = "Get a key"
GetKey.TextColor3 = Color3.fromRGB(245, 240, 255)
GetKey.TextSize = 13
GetKey.Parent = Main

local GetCorner = Instance.new("UICorner")
GetCorner.CornerRadius = UDim.new(0, 8)
GetCorner.Parent = GetKey

----- Keyless Mode?.
local KeylessButton = Instance.new("TextButton")
KeylessButton.Position = UDim2.fromOffset(20, 270)
KeylessButton.Size = UDim2.fromOffset(460, 38)
KeylessButton.BackgroundColor3 = Color3.fromRGB(39, 19, 51)
KeylessButton.BorderSizePixel = 0
KeylessButton.Font = Enum.Font.GothamBold
KeylessButton.Text = "Keyless Mode?."
KeylessButton.TextColor3 = Color3.fromRGB(205, 165, 255)
KeylessButton.TextSize = 12
KeylessButton.Parent = Main

local KeylessCorner = Instance.new("UICorner")
KeylessCorner.CornerRadius = UDim.new(0, 8)
KeylessCorner.Parent = KeylessButton

----- Buttons
Submit.MouseButton1Click:Connect(function()
    verifyKey(KeyBox.Text)
end)

GetKey.MouseButton1Click:Connect(function()
    getKeyLink()
end)

KeylessButton.MouseButton1Click:Connect(function()
    startKeyless()
end)

----- Dragging
local UserInputService = game:GetService("UserInputService")

local dragging = false
local dragStart
local startPosition

Title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

        dragging = true
        dragStart = input.Position
        startPosition = Main.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if not dragging then
        return
    end

    if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then

        local delta = input.Position - dragStart

        Main.Position = UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset + delta.X,
            startPosition.Y.Scale,
            startPosition.Y.Offset + delta.Y
        )
    end
end)

----- Initial status
if mode == "Not Supported" then
    notify(
        "Picka's Hub",
        "This game is not supported."
    )
end
