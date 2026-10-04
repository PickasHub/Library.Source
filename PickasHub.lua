--[[
    PICKA'S HUB UI Library v2  (Roblox / Luau)
    Dark purple glass, animated aurora + rainbow, glowing borders, music player, user card.
    Mobile + Desktop. Everything follows Library.Theme.Accent (Theme Color) live.

    local Library = loadstring(game:HttpGet("RAW_LINK"))()
    local Window  = Library:CreateWindow({ Title = "Picka's Hub" })
    local Tab = Window:AddTab({ Title = "Main", Icon = "house" })
    local Sub = Tab:AddSubTab({ Title = "Farm", Icon = "sprout" })
    Sub:AddToggle({ Title = "Auto Farm", Flag = "AutoFarm", Callback = function(v) end })

    Music:  Library.Music:AddSong({ Title = "Name", Artist = "Artist", Id = 123456789, Thumb = 123456 })
            Library.Music:Play(1) :Pause() :Next() :Prev() :SetVolume(0-1) :SetLoop(bool) :SetShuffle(bool)
    Icons:  Lucide icons from Footagesus/Icons (Icon = "house"). "bolt" is drawn in code.
]]

local TS = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local Players = game:GetService("Players")
local HS = game:GetService("HttpService")
local Market = game:GetService("MarketplaceService")
local SoundService = game:GetService("SoundService")
local LP = Players.LocalPlayer
local setclip = setclipboard or toclipboard or (syn and syn.write_clipboard) or function() end

local Library = {
    Version = "2.0.0", Flags = {}, Icons = {}, Theme = { Accent = Color3.fromRGB(150, 85, 255) },
    _acc = {}, _set = {}, _rot = {}, _spin = {}, _aur = {}, _glass = {}, _corn = {}, _tick = {}, _folder = "PickasHub/Configs",
    Rainbow = false, Smooth = true, Radius = 16, GlassDelta = 0,
    LowFx = (UIS.TouchEnabled and not UIS.KeyboardEnabled) and true or false,
}

local C = {
    Text = Color3.fromRGB(240, 235, 255), Sub = Color3.fromRGB(170, 160, 205),
    Glass = Color3.fromRGB(46, 26, 92), Dark1 = Color3.fromRGB(28, 12, 60), Dark2 = Color3.fromRGB(7, 3, 18),
    Off = Color3.fromRGB(62, 46, 104),
    Success = Color3.fromRGB(80, 220, 140), Warning = Color3.fromRGB(255, 190, 70),
    Error = Color3.fromRGB(255, 90, 110), Info = Color3.fromRGB(110, 170, 255),
}
local FULL = UDim.new(1, 0)
local Y = Enum.AutomaticSize.Y
local X = Enum.AutomaticSize.X
local MB1, TCH, MMV = Enum.UserInputType.MouseButton1, Enum.UserInputType.Touch, Enum.UserInputType.MouseMovement

---------------------------------------------------------------- helpers
local function New(cls, props, kids)
    local o = Instance.new(cls)
    local parent
    for k, v in pairs(props or {}) do if k == "Parent" then parent = v else o[k] = v end end
    for _, c in ipairs(kids or {}) do c.Parent = o end
    if parent then o.Parent = parent end
    return o
end
local function Corner(r, reg)
    local u = New("UICorner", { CornerRadius = r and UDim.new(0, reg and (r * Library.Radius / 16) or r) or FULL })
    if reg and r then table.insert(Library._corn, { u = u, f = r / 16 }) end
    return u
end
local function Pad(n) return New("UIPadding", { PaddingTop = UDim.new(0, n), PaddingBottom = UDim.new(0, n), PaddingLeft = UDim.new(0, n), PaddingRight = UDim.new(0, n) }) end
local function List(p, dir) return New("UIListLayout", { Padding = UDim.new(0, p or 6), SortOrder = Enum.SortOrder.LayoutOrder, FillDirection = dir or Enum.FillDirection.Vertical, VerticalAlignment = Enum.VerticalAlignment.Center }) end
local function Tween(o, p, t, st, d) local tw = TS:Create(o, TweenInfo.new(t or .2, st or Enum.EasingStyle.Quint, d or Enum.EasingDirection.Out), p) tw:Play() return tw end
local function Bind(fn) table.insert(Library._acc, fn) fn(Library.Theme.Accent) end
local function Accent2() local h, s, v = Library.Theme.Accent:ToHSV() return Color3.fromHSV((h + .08) % 1, s, v) end
local function AccSeq()
    if Library.Rainbow then
        local t, pts = os.clock() * .15, {}
        for i = 0, 4 do pts[#pts + 1] = ColorSequenceKeypoint.new(i / 4, Color3.fromHSV((t + i * .2) % 1, .65, 1)) end
        return ColorSequence.new(pts)
    end
    return ColorSequence.new({ ColorSequenceKeypoint.new(0, Library.Theme.Accent), ColorSequenceKeypoint.new(.5, Accent2()), ColorSequenceKeypoint.new(1, Library.Theme.Accent) })
end
function Library:SetAccent(c) Library.Theme.Accent = c for _, f in ipairs(Library._acc) do pcall(f, c) end end
local function GlassReg(f, base)
    f.BackgroundTransparency = math.clamp(base + Library.GlassDelta, 0, 1)
    table.insert(Library._glass, { f = f, b = base })
end
function Library:SetGlass(t)
    Library.GlassDelta = t - .2
    for i = #Library._glass, 1, -1 do
        local g = Library._glass[i]
        if g.f.Parent then g.f.BackgroundTransparency = math.clamp(g.b + Library.GlassDelta, 0, 1) else table.remove(Library._glass, i) end
    end
end
function Library:SetRadius(n)
    Library.Radius = n
    for i = #Library._corn, 1, -1 do
        local c = Library._corn[i]
        if c.u.Parent then c.u.CornerRadius = UDim.new(0, n * c.f) else table.remove(Library._corn, i) end
    end
end

local function Txt(p, t, s, props)
    local l = New("TextLabel", { BackgroundTransparency = 1, Text = t or "", TextSize = s or 13, Font = Enum.Font.GothamMedium, TextColor3 = C.Text,
        TextXAlignment = Enum.TextXAlignment.Left, Size = UDim2.new(1, 0, 0, (s or 13) + 4), Parent = p })
    for k, v in pairs(props or {}) do l[k] = v end
    return l
end
local function Click(o, cb)
    local b = New("TextButton", { BackgroundTransparency = 1, Text = "", Size = UDim2.fromScale(1, 1), Parent = o })
    b.MouseButton1Click:Connect(function() if cb then cb() end end)
    return b
end
local function Glow(parent, th, tr)
    local s = New("UIStroke", { Thickness = th or 1.5, Transparency = tr or .2, Color = Color3.new(1, 1, 1), ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = parent })
    local g = New("UIGradient", { Parent = s })
    Bind(function() g.Color = AccSeq() end)
    table.insert(Library._rot, g)
    return s
end
local function Drag(obj, fn, state)
    local on = false
    local function upd(i)
        local p, s = obj.AbsolutePosition, obj.AbsoluteSize
        fn(math.clamp((i.Position.X - p.X) / math.max(s.X, 1), 0, 1), math.clamp((i.Position.Y - p.Y) / math.max(s.Y, 1), 0, 1))
    end
    obj.InputBegan:Connect(function(i) if i.UserInputType == MB1 or i.UserInputType == TCH then on = true if state then state(true) end upd(i) end end)
    UIS.InputChanged:Connect(function(i) if on and (i.UserInputType == MMV or i.UserInputType == TCH) then upd(i) end end)
    UIS.InputEnded:Connect(function(i) if on and (i.UserInputType == MB1 or i.UserInputType == TCH) then on = false if state then state(false) end end end)
end
local function DragDelta(h, onStart, onMove, onEnd)
    local on, start = false, nil
    h.InputBegan:Connect(function(i) if i.UserInputType == MB1 or i.UserInputType == TCH then on = true start = i.Position if onStart then onStart() end end end)
    UIS.InputChanged:Connect(function(i) if on and (i.UserInputType == MMV or i.UserInputType == TCH) then onMove(Vector2.new(i.Position.X - start.X, i.Position.Y - start.Y)) end end)
    UIS.InputEnded:Connect(function(i) if on and (i.UserInputType == MB1 or i.UserInputType == TCH) then on = false if onEnd then onEnd() end end end)
end

-- Icons: Footagesus/Icons (Lucide) with a drawn Thunder -----------------------------
local Lucide
pcall(function() Lucide = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/Icons/main/Main-v2.lua"))() end)
local ALIAS = { home = "house", discord = "message-circle", telegram = "send", trash = "trash-2", dot = "circle" }
local icache = {}
local function LucideIcon(name)
    if not Lucide then return nil end
    name = ALIAS[name] or name
    if icache[name] ~= nil then return icache[name] or nil end
    local ok, a, b, c = pcall(Lucide.GetIcon, name)
    if not ok or a == nil then ok, a, b, c = pcall(Lucide.GetIcon, Lucide, name) end
    local res = (ok and a ~= nil) and (type(a) == "table" and a or { a, b, c }) or false
    icache[name] = res
    return res or nil
end
local function applyIcon(img, d)
    if type(d) == "number" then img.Image = "rbxassetid://" .. d return end
    if type(d) == "string" then img.Image = d:find("rbx") and d or ("rbxassetid://" .. d) return end
    local id = d.Image or d.Id or d.image or d[1]
    id = tostring(id)
    img.Image = id:find("rbx") and id or ("rbxassetid://" .. id)
    local off, sz = d.ImageRectOffset or d.ImageRectPosition or d[2], d.ImageRectSize or d[3]
    if typeof(off) == "Vector2" then img.ImageRectOffset = off end
    if typeof(sz) == "Vector2" then img.ImageRectSize = sz end
end
local function Ico(p, name, s, col, fb)
    s, col = s or 16, col or C.Text
    local h = New("Frame", { Name = "Ic", BackgroundTransparency = 1, Size = UDim2.fromOffset(s, s), Parent = p })
    if name == "bolt" then
        local function part(w, hh, x, y, r)
            return New("Frame", { AnchorPoint = Vector2.new(.5, .5), Size = UDim2.fromOffset(w * s, hh * s), Position = UDim2.fromOffset(x * s, y * s),
                Rotation = r, BackgroundColor3 = col, BorderSizePixel = 0, Parent = h }, { Corner(2) })
        end
        part(.24, .58, .56, .30, 24) part(.24, .58, .44, .70, 24) part(.55, .17, .5, .5, 0)
        return h
    end
    local def = Library.Icons[name] or (type(name) == "string" and name:find("rbx") and name) or LucideIcon(name)
    if def then
        local img = New("ImageLabel", { BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ImageColor3 = col, Parent = h })
        applyIcon(img, def)
    elseif fb then
        New("TextLabel", { BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Text = fb, TextColor3 = col, Font = Enum.Font.GothamBold, TextSize = math.max(10, s * .8), Parent = h })
    else
        New("Frame", { AnchorPoint = Vector2.new(.5, .5), Position = UDim2.fromScale(.5, .5), Size = UDim2.fromScale(.4, .4), BackgroundColor3 = col, Parent = h }, { Corner() })
    end
    return h
end
Library.Icon = Ico

local function GlassBtn(p, text, icon, cb, size)
    local b = New("TextButton", { AutoButtonColor = false, Text = "", BackgroundColor3 = Library.Theme.Accent, BackgroundTransparency = .35,
        Size = size or UDim2.fromOffset(86, 28), ClipsDescendants = true, Parent = p }, { Corner(7, true), New("UIStroke", { Color = Color3.new(1, 1, 1), Transparency = .65 }) })
    Bind(function(c) b.BackgroundColor3 = c end)
    local l = Txt(b, text, 12, { Size = UDim2.fromScale(1, 1), TextXAlignment = Enum.TextXAlignment.Center, Font = Enum.Font.GothamBold })
    if icon then
        local i = Ico(b, icon, 14) i.Position = UDim2.new(0, 9, .5, -7)
        l.Position = UDim2.fromOffset(12, 0) l.Size = UDim2.new(1, -12, 1, 0)
    end
    local shine = New("Frame", { AnchorPoint = Vector2.new(.5, .5), Position = UDim2.new(-.3, 0, .5, 0), Size = UDim2.new(.3, 0, 2, 0), Rotation = 20, BackgroundColor3 = Color3.fromRGB(255, 235, 255),
        BackgroundTransparency = .84, BorderSizePixel = 0, Parent = b })
    b.MouseEnter:Connect(function()
        Tween(b, { BackgroundTransparency = .15 }, .15)
        if not Library.LowFx then shine.Position = UDim2.new(-.3, 0, .5, 0) Tween(shine, { Position = UDim2.new(1.3, 0, .5, 0) }, .55, Enum.EasingStyle.Sine) end
    end)
    b.MouseLeave:Connect(function() Tween(b, { BackgroundTransparency = .35 }, .15) end)
    b.MouseButton1Down:Connect(function(mx, my)
        Tween(b, { BackgroundTransparency = .02 }, .08)
        if Library.LowFx then return end
        local rel = Vector2.new(mx, my) - b.AbsolutePosition
        local r = New("Frame", { AnchorPoint = Vector2.new(.5, .5), Position = UDim2.fromOffset(rel.X, rel.Y), Size = UDim2.fromOffset(0, 0), BackgroundColor3 = Color3.fromRGB(255, 235, 255), BackgroundTransparency = .6, BorderSizePixel = 0, Parent = b }, { Corner() })
        local big = math.max(b.AbsoluteSize.X, b.AbsoluteSize.Y) * 2.2
        Tween(r, { Size = UDim2.fromOffset(big, big), BackgroundTransparency = 1 }, .5)
        task.delay(.55, function() r:Destroy() end)
    end)
    b.MouseButton1Click:Connect(function() if cb then task.spawn(cb) end end)
    return b, l
end
local function IconBtn(p, icon, fb, cb, size, round)
    size = size or 28
    local b = New("TextButton", { Text = "", AutoButtonColor = false, BackgroundColor3 = C.Glass, BackgroundTransparency = .55, Size = UDim2.fromOffset(size, size), Parent = p },
        { round and Corner() or Corner(8, true), New("UIStroke", { Color = Library.Theme.Accent, Transparency = .75 }) })
    local ic = Ico(b, icon, size * .55, C.Text, fb) ic.AnchorPoint = Vector2.new(.5, .5) ic.Position = UDim2.fromScale(.5, .5)
    b.MouseEnter:Connect(function() Tween(b, { BackgroundColor3 = Library.Theme.Accent, BackgroundTransparency = .3 }, .15) end)
    b.MouseLeave:Connect(function() Tween(b, { BackgroundColor3 = C.Glass, BackgroundTransparency = .55 }, .15) end)
    b.MouseButton1Down:Connect(function() Tween(b, { Size = UDim2.fromOffset(size - 3, size - 3) }, .08) end)
    b.MouseButton1Up:Connect(function() Tween(b, { Size = UDim2.fromOffset(size, size) }, .25, Enum.EasingStyle.Back) end)
    b.MouseButton1Click:Connect(function() if cb then cb() end end)
    return b
end
local function SetIcon(btn, icon, fb, size)
    local old = btn:FindFirstChild("Ic") if old then old:Destroy() end
    local ic = Ico(btn, icon, size, C.Text, fb) ic.AnchorPoint = Vector2.new(.5, .5) ic.Position = UDim2.fromScale(.5, .5)
end

---------------------------------------------------------------- global loop
local t0, fc = os.clock(), 0
RS.Heartbeat:Connect(function(dt)
    fc = fc + 1
    local t = os.clock() - t0
    if fc % (Library.LowFx and 4 or 1) == 0 then
        local rb = Library.Rainbow
        for i = #Library._rot, 1, -1 do
            local g = Library._rot[i]
            if g.Parent then g.Rotation = (t * 45) % 360 if rb then g.Color = AccSeq() end else table.remove(Library._rot, i) end
        end
        local h, s, v = Library.Theme.Accent:ToHSV()
        if rb then h = (h + t * .04) % 1 end
        for _, a in ipairs(Library._aur) do
            if a.f.Parent then
                a.f.Position = UDim2.new(.5 + math.sin(t * a.sx + a.p) * .18, 0, a.y + math.sin(t * a.sy + a.p) * .12, 0)
                a.f.Rotation = a.r + math.sin(t * .3 + a.p) * 12
                a.g.Offset = Vector2.new(0, math.sin(t * .5 + a.p) * .25)
                a.f.BackgroundColor3 = Color3.fromHSV((h + a.o) % 1, math.max(s, .55), math.max(v, .85))
            end
        end
    end
    for i = #Library._spin, 1, -1 do local g = Library._spin[i] if g.Parent then g.Rotation = (t * 360) % 360 else table.remove(Library._spin, i) end end
    for _, f in ipairs(Library._tick) do f(dt, t) end
end)

---------------------------------------------------------------- tooltip / notify / toast
function Library:Tip(obj, text)
    obj.MouseEnter:Connect(function() if Library._tip then Library._tip.Text = text Library._tip.Visible = true end end)
    obj.MouseLeave:Connect(function() if Library._tip then Library._tip.Visible = false end end)
end

function Library:Notify(o)
    if not Library._notes then return end
    o = type(o) == "string" and { Content = o } or o
    local col = C[o.Type or ""] or Library.Theme.Accent
    local dur = o.Duration or 4
    local w = New("Frame", { Size = UDim2.fromOffset(210, 0), AutomaticSize = Y, BackgroundTransparency = 1, Parent = Library._notes })
    local card = New("Frame", { Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Y, Position = UDim2.fromOffset(240, 0), BackgroundColor3 = C.Dark1,
        BackgroundTransparency = .12, Parent = w }, { Corner(8), Pad(8), List(3), New("UIStroke", { Color = col, Transparency = .25, Thickness = 1.2 }) })
    local head = New("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 16), LayoutOrder = 1, Parent = card })
    local ic = Ico(head, o.Icon or "bolt", 13, col)
    Txt(head, o.Title or "Notification", 12, { Position = UDim2.fromOffset(19, 0), Size = UDim2.new(1, -19, 1, 0), Font = Enum.Font.GothamBold })
    if o.Content then Txt(card, o.Content, 11, { LayoutOrder = 2, TextWrapped = true, AutomaticSize = Y, Size = UDim2.new(1, 0, 0, 0), TextColor3 = C.Sub }) end
    local bar = New("Frame", { LayoutOrder = 3, Size = UDim2.new(1, 0, 0, 2), BackgroundColor3 = col, BorderSizePixel = 0, Parent = card }, { Corner() })
    Tween(card, { Position = UDim2.fromOffset(0, 0) }, .35, Enum.EasingStyle.Back)
    Tween(bar, { Size = UDim2.new(0, 0, 0, 2) }, dur, Enum.EasingStyle.Linear)
    task.delay(dur, function()
        Tween(card, { Position = UDim2.fromOffset(240, 0) }, .3)
        task.wait(.32) w:Destroy()
    end)
end

function Library:Toast(text, dur)
    if not Library._toasts then return end
    local f = New("Frame", { AutomaticSize = X, Size = UDim2.fromOffset(0, 28), BackgroundColor3 = C.Dark1, BackgroundTransparency = 1, Parent = Library._toasts },
        { Corner(), New("UIStroke", { Color = Library.Theme.Accent, Transparency = 1 }), New("UIPadding", { PaddingLeft = UDim.new(0, 14), PaddingRight = UDim.new(0, 14) }) })
    local l = Txt(f, text, 12, { AutomaticSize = X, Size = UDim2.new(0, 0, 1, 0), TextTransparency = 1 })
    Tween(f, { BackgroundTransparency = .15 }, .25) Tween(f.UIStroke, { Transparency = .3 }, .25) Tween(l, { TextTransparency = 0 }, .25)
    task.delay(dur or 2.5, function()
        Tween(f, { BackgroundTransparency = 1 }, .25) Tween(f.UIStroke, { Transparency = 1 }, .25) Tween(l, { TextTransparency = 1 }, .25)
        task.wait(.3) f:Destroy()
    end)
end

---------------------------------------------------------------- element base
local Elements = {}
local function Row(self, h, title, tip)
    self._n = (self._n or 0) + 1
    local f = New("Frame", { Name = "Row", Size = UDim2.new(1, 0, 0, h or 38), BackgroundColor3 = C.Glass,
        BorderSizePixel = 0, LayoutOrder = self._n, Parent = self._c },
        { Corner(8, true), New("UIStroke", { Color = Color3.fromRGB(190, 160, 255), Transparency = .78, Thickness = 1 }) })
    GlassReg(f, .45)
    f:SetAttribute("Search", (title or ""):lower())
    if tip then Library:Tip(f, tip) end
    return f
end
local function AutoRow(self, title, tip)
    local r = Row(self, 0, title, tip)
    r.AutomaticSize = Y r.Size = UDim2.new(1, 0, 0, 0)
    New("UIPadding", { PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8), PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10), Parent = r })
    New("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder, Parent = r })
    return r
end
local function Wrap(r, t)
    t = t or {}
    t.Frame = r
    t.SetVisible = function(_, v) r.Visible = v end
    t.Destroy = function() r:Destroy() end
    t.SetTitle = function(_, x) if t._tl then t._tl.Text = x end r:SetAttribute("Search", tostring(x):lower()) end
    return t
end
local function Title(r, text, w)
    return Txt(r, text, 13, { Position = UDim2.fromOffset(10, 0), Size = UDim2.new(w or 1, w and 0 or -20, 1, 0) })
end
local function Reg(o, get, set) if o.Flag then Library._set[o.Flag] = set Library.Flags[o.Flag] = get() end end
local function Fire(o, v) if o.Flag then Library.Flags[o.Flag] = v end if o.Callback then task.spawn(o.Callback, v) end end
local function Container(parent, pad)
    return New("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Y, Parent = parent }, { List(6), pad and Pad(pad) or nil })
end
local function Scroll(parent, pos, size)
    local s = New("ScrollingFrame", { BackgroundTransparency = 1, BorderSizePixel = 0, Position = pos or UDim2.new(), Size = size or UDim2.fromScale(1, 1),
        CanvasSize = UDim2.new(), AutomaticCanvasSize = Y, ScrollBarThickness = 3, ScrollBarImageColor3 = Library.Theme.Accent, Parent = parent },
        { List(6), Pad(6) })
    s.UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Top
    Bind(function(c) s.ScrollBarImageColor3 = c end)
    return s
end
local function Sub(obj, c) obj._c = c return setmetatable(obj, { __index = Elements }) end

-- Basic ------------------------------------------------------------
function Elements:AddButton(o)
    local r = Row(self, 38, o.Title, o.Tooltip)
    local b, l = GlassBtn(r, o.Title or "Button", o.Icon, o.Callback, UDim2.new(1, -12, 0, 28)) b.Position = UDim2.fromOffset(6, 5)
    return Wrap(r, { _tl = l })
end
function Elements:AddLabel(o)
    o = type(o) == "string" and { Title = o } or o
    local r = Row(self, 30, o.Title) local l = Title(r, o.Title) l.TextColor3 = o.Color or C.Text
    return Wrap(r, { _tl = l, Set = function(_, x) l.Text = x end })
end
function Elements:AddParagraph(o)
    local r = AutoRow(self, o.Title)
    local t = Txt(r, o.Title or "", 13, { Font = Enum.Font.GothamBold, LayoutOrder = 1, AutomaticSize = Y, Size = UDim2.new(1, 0, 0, 0), TextWrapped = true })
    local b = Txt(r, o.Content or "", 12, { LayoutOrder = 2, TextWrapped = true, AutomaticSize = Y, Size = UDim2.new(1, 0, 0, 0), TextColor3 = C.Sub })
    return Wrap(r, { _tl = t, Set = function(_, x) b.Text = x end })
end
function Elements:AddSection(o)
    o = type(o) == "string" and { Title = o } or o
    local r = Row(self, 24, o.Title) r.BackgroundTransparency = 1 r.UIStroke.Enabled = false
    local l = Txt(r, o.Title, 12, { Font = Enum.Font.GothamBold, TextColor3 = Library.Theme.Accent, AutomaticSize = X, Size = UDim2.new(0, 0, 1, 0), Position = UDim2.fromOffset(2, 0) })
    Bind(function(c) l.TextColor3 = c end)
    local line = New("Frame", { AnchorPoint = Vector2.new(0, .5), Position = UDim2.new(0, 0, .5, 0), Size = UDim2.new(1, 0, 0, 1), BackgroundColor3 = Library.Theme.Accent,
        BackgroundTransparency = .6, BorderSizePixel = 0, ZIndex = 0, Parent = r })
    l.BackgroundTransparency = 0 l.BackgroundColor3 = C.Dark1 l.Position = UDim2.fromOffset(8, 0)
    New("UIPadding", { PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 4), Parent = l })
    return Wrap(r, { _tl = l })
end
function Elements:AddDivider(o)
    local r = Row(self, 6) r.BackgroundTransparency = 1 r.UIStroke.Enabled = false
    New("Frame", { AnchorPoint = Vector2.new(0, .5), Position = UDim2.fromScale(0, .5), Size = UDim2.new(1, 0, 0, 1), BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = .85, BorderSizePixel = 0, Parent = r })
    return Wrap(r)
end
Elements.AddSeparator = Elements.AddDivider

function Elements:AddToggle(o)
    local r = Row(self, 38, o.Title, o.Tooltip) local tl = Title(r, o.Title, 1) tl.Size = UDim2.new(1, -70, 1, 0)
    local sw = New("Frame", { AnchorPoint = Vector2.new(1, .5), Position = UDim2.new(1, -10, .5, 0), Size = UDim2.fromOffset(38, 20), BackgroundColor3 = C.Off, Parent = r }, { Corner() })
    local k = New("Frame", { Size = UDim2.fromOffset(14, 14), Position = UDim2.fromOffset(3, 3), BackgroundColor3 = Color3.new(1, 1, 1), Parent = sw }, { Corner() })
    local v = o.Default or false
    local function set(x, silent)
        v = x and true or false
        Tween(sw, { BackgroundColor3 = v and Library.Theme.Accent or C.Off }, .15) Tween(k, { Position = UDim2.fromOffset(v and 21 or 3, 3) }, .15)
        if not silent then Fire(o, v) end
    end
    Bind(function(c) if v then sw.BackgroundColor3 = c end end)
    set(v, true) Reg(o, function() return v end, set) Click(r, function() set(not v) end)
    return Wrap(r, { _tl = tl, Set = function(_, x) set(x) end, Get = function() return v end })
end
function Elements:AddCheckbox(o)
    local r = Row(self, 38, o.Title, o.Tooltip) local tl = Title(r, o.Title, 1) tl.Position = UDim2.fromOffset(38, 0) tl.Size = UDim2.new(1, -48, 1, 0)
    local box = New("Frame", { AnchorPoint = Vector2.new(0, .5), Position = UDim2.new(0, 10, .5, 0), Size = UDim2.fromOffset(20, 20), BackgroundColor3 = C.Off, Parent = r }, { Corner(5) })
    local fill = New("Frame", { AnchorPoint = Vector2.new(.5, .5), Position = UDim2.fromScale(.5, .5), Size = UDim2.fromOffset(0, 0), BackgroundColor3 = Library.Theme.Accent, Parent = box }, { Corner(3) })
    Bind(function(c) fill.BackgroundColor3 = c end)
    local v = o.Default or false
    local function set(x, silent) v = x and true or false Tween(fill, { Size = v and UDim2.fromOffset(12, 12) or UDim2.fromOffset(0, 0) }, .15, Enum.EasingStyle.Back) if not silent then Fire(o, v) end end
    set(v, true) Reg(o, function() return v end, set) Click(r, function() set(not v) end)
    return Wrap(r, { _tl = tl, Set = function(_, x) set(x) end, Get = function() return v end })
end
function Elements:AddRadio(o)
    local opts = o.Options or {}
    local r = Row(self, 30 + #opts * 28, o.Title, o.Tooltip) Txt(r, o.Title, 13, { Position = UDim2.fromOffset(10, 6), Size = UDim2.new(1, -20, 0, 18) })
    local v, dots = o.Default or opts[1], {}
    local function set(x, silent) v = x for n, d in pairs(dots) do Tween(d, { Size = n == x and UDim2.fromOffset(8, 8) or UDim2.fromOffset(0, 0) }, .12) end if not silent then Fire(o, v) end end
    for i, n in ipairs(opts) do
        local line = New("Frame", { BackgroundTransparency = 1, Position = UDim2.fromOffset(10, 28 + (i - 1) * 28), Size = UDim2.new(1, -20, 0, 26), Parent = r })
        local ring = New("Frame", { AnchorPoint = Vector2.new(0, .5), Position = UDim2.fromScale(0, .5), Size = UDim2.fromOffset(18, 18), BackgroundColor3 = C.Off, Parent = line }, { Corner() })
        dots[n] = New("Frame", { AnchorPoint = Vector2.new(.5, .5), Position = UDim2.fromScale(.5, .5), Size = UDim2.fromOffset(0, 0), BackgroundColor3 = Library.Theme.Accent, Parent = ring }, { Corner() })
        Bind(function(c) dots[n].BackgroundColor3 = c end)
        Txt(line, tostring(n), 12, { Position = UDim2.fromOffset(26, 0), Size = UDim2.new(1, -26, 1, 0), TextColor3 = C.Sub })
        Click(line, function() set(n) end)
    end
    set(v, true) Reg(o, function() return v end, set)
    return Wrap(r, { Set = function(_, x) set(x) end, Get = function() return v end })
end

-- Value inputs -------------------------------------------------------
function Elements:AddSlider(o)
    local mn, mx, st = o.Min or 0, o.Max or 100, o.Step or 1
    local r = Row(self, 50, o.Title, o.Tooltip) local tl = Txt(r, o.Title, 13, { Position = UDim2.fromOffset(10, 6), Size = UDim2.new(.6, 0, 0, 18) })
    local vl = Txt(r, "", 12, { AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -10, 0, 6), Size = UDim2.new(.4, 0, 0, 18), TextXAlignment = Enum.TextXAlignment.Right, TextColor3 = C.Sub })
    local tr = New("Frame", { Position = UDim2.new(0, 10, 1, -16), Size = UDim2.new(1, -20, 0, 6), BackgroundColor3 = C.Off, Parent = r }, { Corner() })
    local fl = New("Frame", { Size = UDim2.fromScale(0, 1), BackgroundColor3 = Library.Theme.Accent, Parent = tr }, { Corner() })
    local kn = New("Frame", { AnchorPoint = Vector2.new(.5, .5), Position = UDim2.fromScale(0, .5), Size = UDim2.fromOffset(14, 14), BackgroundColor3 = Color3.new(1, 1, 1), Parent = tr }, { Corner() })
    Bind(function(c) fl.BackgroundColor3 = c end)
    local v = o.Default or mn
    local function set(x, silent)
        x = math.clamp(math.floor((x - mn) / st + .5) * st + mn, mn, mx) x = math.floor(x * 10000 + .5) / 10000 v = x
        local a = (x - mn) / math.max(mx - mn, 1e-9)
        fl.Size = UDim2.fromScale(a, 1) kn.Position = UDim2.fromScale(a, .5) vl.Text = tostring(x) .. (o.Suffix or "")
        if not silent then Fire(o, v) end
    end
    Drag(tr, function(a) set(mn + (mx - mn) * a) end, function(on) Tween(kn, { Size = on and UDim2.fromOffset(19, 19) or UDim2.fromOffset(14, 14) }, .18, Enum.EasingStyle.Back) end)
    set(v, true) Reg(o, function() return v end, set)
    return Wrap(r, { _tl = tl, Set = function(_, x) set(x) end, Get = function() return v end })
end
function Elements:AddRangeSlider(o)
    local mn, mx = o.Min or 0, o.Max or 100
    local r = Row(self, 50, o.Title, o.Tooltip) local tl = Txt(r, o.Title, 13, { Position = UDim2.fromOffset(10, 6), Size = UDim2.new(.6, 0, 0, 18) })
    local vl = Txt(r, "", 12, { AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -10, 0, 6), Size = UDim2.new(.4, 0, 0, 18), TextXAlignment = Enum.TextXAlignment.Right, TextColor3 = C.Sub })
    local tr = New("Frame", { Position = UDim2.new(0, 10, 1, -16), Size = UDim2.new(1, -20, 0, 6), BackgroundColor3 = C.Off, Parent = r }, { Corner() })
    local fl = New("Frame", { BackgroundColor3 = Library.Theme.Accent, Size = UDim2.fromScale(1, 1), Parent = tr }, { Corner() })
    Bind(function(c) fl.BackgroundColor3 = c end)
    local function knob() return New("Frame", { AnchorPoint = Vector2.new(.5, .5), Size = UDim2.fromOffset(14, 14), BackgroundColor3 = Color3.new(1, 1, 1), Parent = tr }, { Corner() }) end
    local k1, k2 = knob(), knob()
    local lo, hi = (o.Default or {})[1] or mn, (o.Default or {})[2] or mx
    local function draw(silent)
        local a, b = (lo - mn) / (mx - mn), (hi - mn) / (mx - mn)
        fl.Position = UDim2.fromScale(a, 0) fl.Size = UDim2.fromScale(b - a, 1) k1.Position = UDim2.fromScale(a, .5) k2.Position = UDim2.fromScale(b, .5)
        vl.Text = lo .. " - " .. hi if not silent then Fire(o, { lo, hi }) end
    end
    Drag(tr, function(a)
        local x = math.floor(mn + (mx - mn) * a + .5)
        if math.abs(x - lo) <= math.abs(x - hi) then lo = math.min(x, hi) else hi = math.max(x, lo) end draw()
    end)
    draw(true) Reg(o, function() return { lo, hi } end, function(t) lo, hi = t[1], t[2] draw() end)
    return Wrap(r, { _tl = tl, Set = function(_, a, b) lo, hi = a, b draw() end, Get = function() return { lo, hi } end })
end

local function InputBox(r, o, multi)
    local box = New("Frame", { Position = UDim2.new(0, 10, 0, multi and 28 or 0), Size = multi and UDim2.new(1, -20, 1, -36) or UDim2.new(.5, 0, 0, 26),
        BackgroundColor3 = C.Dark2, BackgroundTransparency = .35, Parent = r }, { Corner(6), New("UIStroke", { Color = Library.Theme.Accent, Transparency = .6 }), Pad(5) })
    if not multi then box.AnchorPoint = Vector2.new(1, .5) box.Position = UDim2.new(1, -10, .5, 0) end
    local tb = New("TextBox", { BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Text = o.Default or "", PlaceholderText = o.Placeholder or "", PlaceholderColor3 = C.Sub,
        TextColor3 = C.Text, Font = Enum.Font.Gotham, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = multi and Enum.TextYAlignment.Top or Enum.TextYAlignment.Center,
        ClearTextOnFocus = false, MultiLine = multi or false, TextWrapped = multi or false, Parent = box })
    local stroke = box:FindFirstChildOfClass("UIStroke")
    tb.Focused:Connect(function() Tween(stroke, { Transparency = .05, Thickness = 1.8 }, .2) end)
    tb.FocusLost:Connect(function() Tween(stroke, { Transparency = .6, Thickness = 1 }, .25) end)
    return tb
end
function Elements:AddInput(o)
    local r = Row(self, 38, o.Title, o.Tooltip) local tl = Title(r, o.Title, .4)
    local tb = InputBox(r, o)
    tb.FocusLost:Connect(function() Fire(o, tb.Text) end)
    Reg(o, function() return tb.Text end, function(x) tb.Text = x Fire(o, x) end)
    return Wrap(r, { _tl = tl, Set = function(_, x) tb.Text = x end, Get = function() return tb.Text end, Box = tb })
end
function Elements:AddTextbox(o)
    local r = Row(self, o.Height or 96, o.Title, o.Tooltip) local tl = Txt(r, o.Title, 13, { Position = UDim2.fromOffset(10, 6), Size = UDim2.new(1, -20, 0, 18) })
    local tb = InputBox(r, o, true)
    tb.FocusLost:Connect(function() Fire(o, tb.Text) end)
    Reg(o, function() return tb.Text end, function(x) tb.Text = x Fire(o, x) end)
    return Wrap(r, { _tl = tl, Set = function(_, x) tb.Text = x end, Get = function() return tb.Text end, Box = tb })
end
function Elements:AddKeybind(o)
    local r = Row(self, 38, o.Title, o.Tooltip) local tl = Title(r, o.Title, .5)
    local key = o.Default or Enum.KeyCode.Unknown local listening = false
    local b, l = GlassBtn(r, "", nil, nil, UDim2.fromOffset(90, 26)) b.AnchorPoint = Vector2.new(1, .5) b.Position = UDim2.new(1, -8, .5, 0)
    local function show() l.Text = listening and "..." or (key == Enum.KeyCode.Unknown and "None" or key.Name) end
    local function set(k, silent) key = type(k) == "string" and Enum.KeyCode[k] or k show() if not silent then Fire(o, key) end end
    b.MouseButton1Click:Connect(function() listening = true show() end)
    UIS.InputBegan:Connect(function(i, gp)
        if listening and i.UserInputType == Enum.UserInputType.Keyboard then
            listening = false set(i.KeyCode == Enum.KeyCode.Escape and Enum.KeyCode.Unknown or i.KeyCode)
        elseif not listening and not gp and key ~= Enum.KeyCode.Unknown and i.KeyCode == key and o.OnPress then task.spawn(o.OnPress) end
    end)
    show() Reg(o, function() return key end, set)
    return Wrap(r, { _tl = tl, Set = function(_, k) set(k) end, Get = function() return key end })
end

function Elements:AddDropdown(o)
    local r = Row(self, 38, o.Title, o.Tooltip) r.ClipsDescendants = true
    local multi, opts, sel = o.Multi, o.Options or {}, {}
    local tl = Title(r, o.Title, .45)
    local shown = Txt(r, "", 12, { AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -28, 0, 0), Size = UDim2.new(.5, -20, 0, 38), TextXAlignment = Enum.TextXAlignment.Right,
        TextColor3 = C.Sub, TextTruncate = Enum.TextTruncate.AtEnd })
    local arrow = Txt(r, "v", 11, { AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -10, 0, 0), Size = UDim2.fromOffset(14, 38), TextXAlignment = Enum.TextXAlignment.Center, TextColor3 = C.Sub })
    local list = New("ScrollingFrame", { Position = UDim2.fromOffset(6, 42), Size = UDim2.new(1, -12, 0, 0), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 3,
        CanvasSize = UDim2.new(), AutomaticCanvasSize = Y, Parent = r }, { List(3) })
    list.UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Top
    local open, btns = false, {}
    local function get() if multi then local t = {} for _, x in ipairs(opts) do if sel[x] then t[#t + 1] = x end end return t end for k in pairs(sel) do return k end end
    local function refresh()
        for n, b in pairs(btns) do Tween(b, { BackgroundTransparency = sel[n] and .25 or .75, BackgroundColor3 = sel[n] and Library.Theme.Accent or C.Glass }, .1) end
        local g = get() shown.Text = multi and (#g == 0 and "None" or table.concat(g, ", ")) or (g or "None")
    end
    local function resize()
        local h = 42 + math.min(#opts, 5) * 29 + 4
        Tween(r, { Size = UDim2.new(1, 0, 0, open and h or 38) }, .2) list.Size = UDim2.new(1, -12, 0, math.min(#opts, 5) * 29) arrow.Text = open and "^" or "v"
    end
    local function build()
        for _, c in ipairs(list:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end btns = {}
        for i, n in ipairs(opts) do
            local b = New("TextButton", { AutoButtonColor = false, Text = tostring(n), TextSize = 12, Font = Enum.Font.Gotham, TextColor3 = C.Text, BackgroundColor3 = C.Glass,
                BackgroundTransparency = .75, Size = UDim2.new(1, 0, 0, 26), LayoutOrder = i, Parent = list }, { Corner(6) })
            btns[n] = b
            b.MouseButton1Click:Connect(function()
                if multi then sel[n] = not sel[n] or nil refresh() Fire(o, get()) else sel = { [n] = true } refresh() Fire(o, n) open = false resize() end
            end)
        end
        refresh() resize()
    end
    local function set(v, silent)
        sel = {}
        if multi then for _, x in ipairs(type(v) == "table" and v or {}) do sel[x] = true end elseif v ~= nil then sel[v] = true end
        refresh() if not silent then Fire(o, multi and get() or v) end
    end
    local hb = New("TextButton", { BackgroundTransparency = 1, Text = "", Size = UDim2.new(1, 0, 0, 38), Parent = r })
    hb.MouseButton1Click:Connect(function()
        open = not open resize()
        if open and not Library.LowFx then
            for i, n in ipairs(opts) do
                local b = btns[n]
                if b then b.TextTransparency = 1 task.delay(i * .035, function() Tween(b, { TextTransparency = 0 }, .25) end) end
            end
        end
    end)
    set(o.Default, true) build() Reg(o, get, set)
    return Wrap(r, { _tl = tl, Set = function(_, v) set(v) end, Get = get, SetOptions = function(_, t) opts = t local g = get() build() end })
end
function Elements:AddMultiDropdown(o) o.Multi = true return self:AddDropdown(o) end

function Elements:AddColorpicker(o)
    local r = Row(self, 38, o.Title, o.Tooltip) r.ClipsDescendants = true local tl = Title(r, o.Title, .6)
    local h, s, v = (o.Default or Color3.fromRGB(150, 85, 255)):ToHSV()
    local sw = New("Frame", { AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -10, 0, 7), Size = UDim2.fromOffset(40, 24), Parent = r }, { Corner(6), New("UIStroke", { Color = Color3.new(1, 1, 1), Transparency = .5 }) })
    local sv = New("Frame", { Position = UDim2.fromOffset(10, 44), Size = UDim2.new(1, -52, 0, 96), BackgroundColor3 = Color3.fromHSV(h, 1, 1), Parent = r }, { Corner(6) })
    local wf = New("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(1, 1, 1), Parent = sv }, { Corner(6), New("UIGradient", { Transparency = NumberSequence.new(0, 1) }) })
    local bf = New("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(0, 0, 0), Parent = sv }, { Corner(6), New("UIGradient", { Rotation = 90, Transparency = NumberSequence.new(1, 0) }) })
    local sk = New("Frame", { AnchorPoint = Vector2.new(.5, .5), Size = UDim2.fromOffset(10, 10), BackgroundTransparency = 1, Parent = sv }, { Corner(), New("UIStroke", { Color = Color3.new(1, 1, 1), Thickness = 2 }) })
    local hue = New("Frame", { AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -10, 0, 44), Size = UDim2.fromOffset(24, 96), BackgroundColor3 = Color3.new(1, 1, 1), Parent = r }, { Corner(6),
        New("UIGradient", { Rotation = 90, Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, Color3.fromHSV(0, 1, 1)), ColorSequenceKeypoint.new(.17, Color3.fromHSV(.17, 1, 1)),
            ColorSequenceKeypoint.new(.33, Color3.fromHSV(.33, 1, 1)), ColorSequenceKeypoint.new(.5, Color3.fromHSV(.5, 1, 1)), ColorSequenceKeypoint.new(.67, Color3.fromHSV(.67, 1, 1)),
            ColorSequenceKeypoint.new(.83, Color3.fromHSV(.83, 1, 1)), ColorSequenceKeypoint.new(1, Color3.fromHSV(1, 1, 1)) }) }) })
    local hk = New("Frame", { AnchorPoint = Vector2.new(.5, .5), Size = UDim2.new(1, 4, 0, 4), BackgroundColor3 = Color3.new(1, 1, 1), Parent = hue }, { Corner() })
    local function draw(silent)
        local c = Color3.fromHSV(h, s, v) sw.BackgroundColor3 = c sv.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
        sk.Position = UDim2.fromScale(s, 1 - v) hk.Position = UDim2.fromScale(.5, h) if not silent then Fire(o, c) end
    end
    Drag(sv, function(x, y) s, v = x, 1 - y draw() end) Drag(hue, function(_, y) h = y draw() end)
    local open = false
    local hb = New("TextButton", { BackgroundTransparency = 1, Text = "", Size = UDim2.new(1, 0, 0, 38), Parent = r })
    hb.MouseButton1Click:Connect(function() open = not open Tween(r, { Size = UDim2.new(1, 0, 0, open and 150 or 38) }, .2) end)
    draw(true) Reg(o, function() return Color3.fromHSV(h, s, v) end, function(c) if type(c) == "table" then c = Color3.new(c[1], c[2], c[3]) end h, s, v = c:ToHSV() draw() end)
    return Wrap(r, { _tl = tl, Set = function(_, c) h, s, v = c:ToHSV() draw() end, Get = function() return Color3.fromHSV(h, s, v) end })
end

function Elements:AddSearchbar(o)
    o = o or {}
    local r = Row(self, 38) Ico(r, "search", 14, C.Sub).Position = UDim2.new(0, 10, .5, -7)
    local tb = New("TextBox", { BackgroundTransparency = 1, Position = UDim2.fromOffset(32, 0), Size = UDim2.new(1, -40, 1, 0), Text = "", PlaceholderText = o.Placeholder or "Search...",
        PlaceholderColor3 = C.Sub, TextColor3 = C.Text, Font = Enum.Font.Gotham, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false, Parent = r })
    tb:GetPropertyChangedSignal("Text"):Connect(function()
        local q = tb.Text:lower()
        for _, c in ipairs(self._c:GetChildren()) do
            local sa = c:GetAttribute("Search")
            if sa ~= nil and c ~= r then c.Visible = (q == "" or sa:find(q, 1, true) ~= nil) end
        end
        if o.Callback then task.spawn(o.Callback, tb.Text) end
    end)
    return Wrap(r, { Get = function() return tb.Text end })
end

-- Display --------------------------------------------------------------
function Elements:AddProgressBar(o)
    local r = Row(self, 44, o.Title) local tl = Txt(r, o.Title, 13, { Position = UDim2.fromOffset(10, 5), Size = UDim2.new(.6, 0, 0, 18) })
    local vl = Txt(r, "", 12, { AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -10, 0, 5), Size = UDim2.new(.4, 0, 0, 18), TextXAlignment = Enum.TextXAlignment.Right, TextColor3 = C.Sub })
    local tr = New("Frame", { Position = UDim2.new(0, 10, 1, -15), Size = UDim2.new(1, -20, 0, 7), BackgroundColor3 = C.Off, Parent = r }, { Corner() })
    local fl = New("Frame", { Size = UDim2.fromScale(0, 1), BackgroundColor3 = Library.Theme.Accent, Parent = tr }, { Corner(), New("UIGradient", { Color = ColorSequence.new(Library.Theme.Accent, Color3.new(1, 1, 1)) }) })
    Bind(function(c) fl.BackgroundColor3 = c end)
    local function set(x) x = math.clamp(x, 0, 100) Tween(fl, { Size = UDim2.fromScale(x / 100, 1) }, .25) vl.Text = math.floor(x) .. "%" end
    set(o.Value or 0)
    return Wrap(r, { _tl = tl, Set = function(_, x) set(x) end })
end
function Elements:AddLoadingBar(o)
    o = o or {}
    local r = Row(self, 30, o.Title) local tr = New("Frame", { AnchorPoint = Vector2.new(0, .5), Position = UDim2.new(0, 10, .5, 0), Size = UDim2.new(1, -20, 0, 6), BackgroundColor3 = C.Off, ClipsDescendants = true, Parent = r }, { Corner() })
    local fl = New("Frame", { Size = UDim2.fromScale(.35, 1), BackgroundColor3 = Library.Theme.Accent, Parent = tr }, { Corner() })
    Bind(function(c) fl.BackgroundColor3 = c end)
    TS:Create(fl, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), { Position = UDim2.fromScale(.65, 0) }):Play()
    return Wrap(r)
end
function Elements:AddSpinner(o)
    o = o or {}
    local s = o.Size or 28 local r = Row(self, s + 16, o.Title)
    local ring = New("Frame", { AnchorPoint = Vector2.new(.5, .5), Position = UDim2.fromScale(.5, .5), Size = UDim2.fromOffset(s, s), BackgroundTransparency = 1, Parent = r }, { Corner() })
    local st = New("UIStroke", { Thickness = 3, Color = Library.Theme.Accent, Parent = ring })
    Bind(function(c) st.Color = c end)
    local g = New("UIGradient", { Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(.6, 1), NumberSequenceKeypoint.new(1, 1) }), Parent = st })
    table.insert(Library._spin, g)
    return Wrap(r)
end
function Elements:AddStatus(o)
    local r = Row(self, 32, o.Title) local dot = New("Frame", { AnchorPoint = Vector2.new(0, .5), Position = UDim2.new(0, 12, .5, 0), Size = UDim2.fromOffset(9, 9), Parent = r }, { Corner() })
    local l = Txt(r, o.Text or "", 13, { Position = UDim2.fromOffset(28, 0), Size = UDim2.new(1, -36, 1, 0) })
    local cols = { Online = C.Success, Idle = C.Warning, Busy = C.Error, Offline = Color3.fromRGB(120, 110, 150) }
    local function set(st) dot.BackgroundColor3 = cols[st] or C.Info end set(o.State or "Online")
    return Wrap(r, { _tl = l, SetState = function(_, s) set(s) end, Set = function(_, t) l.Text = t end })
end
function Elements:AddBadge(o)
    local r = Row(self, 30) r.BackgroundTransparency = 1 r.UIStroke.Enabled = false
    local b = New("Frame", { AnchorPoint = Vector2.new(0, .5), Position = UDim2.new(0, 2, .5, 0), AutomaticSize = X, Size = UDim2.fromOffset(0, 22), BackgroundColor3 = o.Color or Library.Theme.Accent, BackgroundTransparency = .3, Parent = r },
        { Corner(), New("UIStroke", { Color = o.Color or Library.Theme.Accent, Transparency = .3 }), New("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10) }) })
    local l = Txt(b, o.Text or "Badge", 11, { AutomaticSize = X, Size = UDim2.new(0, 0, 1, 0), Font = Enum.Font.GothamBold })
    return Wrap(r, { _tl = l, Set = function(_, x) l.Text = x end })
end
function Elements:AddImage(o)
    local r = Row(self, o.Height or 120) New("ImageLabel", { BackgroundTransparency = 1, Image = o.Image or "", ScaleType = Enum.ScaleType.Fit, Size = UDim2.new(1, -12, 1, -12), Position = UDim2.fromOffset(6, 6), Parent = r }, { Corner(6) })
    return Wrap(r)
end
function Elements:AddIcon(o)
    local r = Row(self, (o.Size or 20) + 18) local i = Ico(r, o.Icon, o.Size or 20, o.Color) i.AnchorPoint = Vector2.new(.5, .5) i.Position = UDim2.fromScale(.5, .5)
    return Wrap(r)
end
function Elements:AddLink(o)
    local r = Row(self, 34, o.Text) local l = Txt(r, o.Text or o.Url, 13, { Position = UDim2.fromOffset(10, 0), Size = UDim2.new(1, -20, 1, 0), TextColor3 = Library.Theme.Accent })
    Bind(function(c) l.TextColor3 = c end)
    Click(r, function() setclip(o.Url or "") Library:Toast("Link copied") end)
    return Wrap(r, { _tl = l })
end
function Elements:AddAlert(o)
    local col = C[o.Type or "Info"] or C.Info
    local r = AutoRow(self, o.Title) r.BackgroundColor3 = col r.BackgroundTransparency = .8 r.UIStroke.Color = col r.UIStroke.Transparency = .3
    local t = Txt(r, o.Title or "Alert", 13, { Font = Enum.Font.GothamBold, TextColor3 = col, LayoutOrder = 1 })
    if o.Content then Txt(r, o.Content, 12, { LayoutOrder = 2, TextWrapped = true, AutomaticSize = Y, Size = UDim2.new(1, 0, 0, 0), TextColor3 = C.Text }) end
    return Wrap(r, { _tl = t })
end
function Elements:AddCodeBlock(o)
    local r = AutoRow(self, "code") r.BackgroundColor3 = C.Dark2 r.BackgroundTransparency = .25
    local code = o.Code or ""
    local head = New("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 22), LayoutOrder = 1, Parent = r })
    Txt(head, o.Language or "lua", 11, { TextColor3 = C.Sub, Size = UDim2.new(.5, 0, 1, 0) })
    local cb = GlassBtn(head, "Copy", "copy", function() setclip(code) Library:Toast("Copied") end, UDim2.fromOffset(64, 22)) cb.AnchorPoint = Vector2.new(1, 0) cb.Position = UDim2.fromScale(1, 0)
    local body = Txt(r, code, 12, { Font = Enum.Font.Code, LayoutOrder = 2, TextWrapped = true, AutomaticSize = Y, Size = UDim2.new(1, 0, 0, 0), TextColor3 = Color3.fromRGB(205, 190, 255) })
    return Wrap(r, { Set = function(_, x) code = x body.Text = x end })
end
function Elements:AddConsole(o)
    o = o or {}
    local r = Row(self, o.Height or 130) r.BackgroundColor3 = C.Dark2 r.BackgroundTransparency = .2
    local sc = Scroll(r) sc.UIListLayout.Padding = UDim.new(0, 2)
    local n = 0
    local obj = Wrap(r)
    function obj:Log(text, kind)
        n = n + 1
        local col = ({ Info = C.Text, Success = C.Success, Warning = C.Warning, Error = C.Error })[kind or "Info"]
        Txt(sc, os.date("[%H:%M:%S] ") .. tostring(text), 11, { Font = Enum.Font.Code, TextColor3 = col, LayoutOrder = n, TextWrapped = true, AutomaticSize = Y, Size = UDim2.new(1, 0, 0, 0) })
        task.defer(function() sc.CanvasPosition = Vector2.new(0, 1e6) end)
    end
    function obj:Clear() for _, c in ipairs(sc:GetChildren()) do if c:IsA("TextLabel") then c:Destroy() end end end
    return obj
end
function Elements:AddTable(o)
    local cols = o.Columns or {}
    local r = AutoRow(self, "table") r.UIPadding.PaddingLeft = UDim.new(0, 6) r.UIPadding.PaddingRight = UDim.new(0, 6)
    local n = 0
    local function line(vals, head)
        n = n + 1
        local f = New("Frame", { Size = UDim2.new(1, 0, 0, 24), BackgroundColor3 = head and Library.Theme.Accent or C.Dark2, BackgroundTransparency = head and .45 or (n % 2 == 0 and .7 or .85), LayoutOrder = n, Parent = r }, { Corner(5) })
        for i = 1, #cols do Txt(f, tostring(vals[i] or ""), 11, { Position = UDim2.new((i - 1) / #cols, 6, 0, 0), Size = UDim2.new(1 / #cols, -8, 1, 0), Font = head and Enum.Font.GothamBold or Enum.Font.Gotham, TextTruncate = Enum.TextTruncate.AtEnd }) end
        return f
    end
    line(cols, true) for _, rw in ipairs(o.Rows or {}) do line(rw) end
    local obj = Wrap(r)
    function obj:AddRow(v) line(v) end
    function obj:Clear() for _, c in ipairs(r:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end n = 0 line(cols, true) end
    return obj
end
function Elements:AddList(o)
    local r = Row(self, o.Height or 120, o.Title) local sc = Scroll(r) local sel
    local function build(items)
        for _, c in ipairs(sc:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
        for i, it in ipairs(items) do
            local b = New("TextButton", { AutoButtonColor = false, Text = tostring(it), TextSize = 12, Font = Enum.Font.Gotham, TextColor3 = C.Text, BackgroundColor3 = C.Glass, BackgroundTransparency = .7, Size = UDim2.new(1, 0, 0, 26), LayoutOrder = i, Parent = sc }, { Corner(6) })
            b.MouseButton1Click:Connect(function()
                for _, c in ipairs(sc:GetChildren()) do if c:IsA("TextButton") then c.BackgroundTransparency = .7 c.BackgroundColor3 = C.Glass end end
                b.BackgroundColor3 = Library.Theme.Accent b.BackgroundTransparency = .3 sel = it Fire(o, it)
            end)
        end
    end
    build(o.Items or {})
    return Wrap(r, { SetItems = function(_, t) build(t) end, Get = function() return sel end })
end
function Elements:AddAvatar(o)
    local s = o.Size or 48 local r = Row(self, s + 16)
    New("ImageLabel", { AnchorPoint = Vector2.new(.5, .5), Position = UDim2.fromScale(.5, .5), Size = UDim2.fromOffset(s, s), BackgroundColor3 = C.Dark2,
        Image = "rbxthumb://type=AvatarHeadShot&id=" .. (o.UserId or LP.UserId) .. "&w=150&h=150", Parent = r }, { Corner(o.Square and 8 or nil), New("UIStroke", { Color = Library.Theme.Accent, Thickness = 2 }) })
    return Wrap(r)
end
function Elements:AddProfile(o)
    local r = Row(self, 64) local id = o.UserId or LP.UserId
    New("ImageLabel", { Position = UDim2.fromOffset(10, 10), Size = UDim2.fromOffset(44, 44), BackgroundColor3 = C.Dark2, Image = "rbxthumb://type=AvatarHeadShot&id=" .. id .. "&w=150&h=150", Parent = r }, { Corner(), New("UIStroke", { Color = Library.Theme.Accent, Thickness = 2 }) })
    Txt(r, o.Display or LP.DisplayName, 14, { Position = UDim2.fromOffset(64, 11), Size = UDim2.new(1, -74, 0, 18), Font = Enum.Font.GothamBold })
    Txt(r, "@" .. (o.Name or LP.Name), 12, { Position = UDim2.fromOffset(64, 29), Size = UDim2.new(1, -74, 0, 16), TextColor3 = C.Sub })
    if o.Status then Txt(r, o.Status, 11, { Position = UDim2.fromOffset(64, 45), Size = UDim2.new(1, -74, 0, 14), TextColor3 = Library.Theme.Accent }) end
    return Wrap(r)
end

-- Navigation -------------------------------------------------------------
function Elements:AddBreadcrumb(o)
    local r = Row(self, 32) local f = New("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, -20, 1, 0), Position = UDim2.fromOffset(10, 0), Parent = r }, { List(6, Enum.FillDirection.Horizontal) })
    for i, n in ipairs(o.Items or {}) do
        local last = i == #o.Items
        local b = Txt(f, n, 12, { AutomaticSize = X, Size = UDim2.new(0, 0, 1, 0), LayoutOrder = i * 2, TextColor3 = last and C.Text or Library.Theme.Accent })
        if not last then Txt(f, "/", 12, { AutomaticSize = X, Size = UDim2.new(0, 0, 1, 0), LayoutOrder = i * 2 + 1, TextColor3 = C.Sub }) end
        if o.Callback then Click(b, function() o.Callback(i, n) end) end
    end
    return Wrap(r)
end
function Elements:AddPagination(o)
    local total, cur = o.Total or 5, o.Current or 1
    local r = Row(self, 38) local f = New("Frame", { BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Parent = r }, { List(4, Enum.FillDirection.Horizontal) })
    f.UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    local function draw()
        for _, c in ipairs(f:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
        local function b(t, i, order, act)
            local x = New("TextButton", { Text = t, TextSize = 12, Font = Enum.Font.GothamBold, TextColor3 = C.Text, AutoButtonColor = false, Size = UDim2.fromOffset(26, 26), LayoutOrder = order,
                BackgroundColor3 = act and Library.Theme.Accent or C.Glass, BackgroundTransparency = act and .25 or .6, Parent = f }, { Corner(6) })
            x.MouseButton1Click:Connect(function() cur = math.clamp(i, 1, total) draw() if o.Callback then task.spawn(o.Callback, cur) end end)
        end
        b("<", cur - 1, 0) for i = 1, total do b(tostring(i), i, i, i == cur) end b(">", cur + 1, total + 1)
    end
    draw()
    return Wrap(r, { Set = function(_, n) cur = n draw() end, Get = function() return cur end })
end
function Elements:AddStepper(o)
    local steps, cur = o.Steps or {}, o.Current or 1
    local r = Row(self, 58) local f = New("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, -20, 1, 0), Position = UDim2.fromOffset(10, 0), Parent = r })
    local dots, lbls = {}, {}
    local function draw()
        for i, d in ipairs(dots) do
            local on = i <= cur Tween(d, { BackgroundColor3 = on and Library.Theme.Accent or C.Off }, .2) lbls[i].TextColor3 = i == cur and C.Text or C.Sub
        end
    end
    for i, n in ipairs(steps) do
        local a = (i - .5) / #steps
        dots[i] = New("TextLabel", { AnchorPoint = Vector2.new(.5, 0), Position = UDim2.new(a, 0, 0, 8), Size = UDim2.fromOffset(22, 22), BackgroundColor3 = C.Off, Text = tostring(i), TextSize = 11, Font = Enum.Font.GothamBold, TextColor3 = Color3.new(1, 1, 1), Parent = f }, { Corner() })
        lbls[i] = Txt(f, n, 11, { AnchorPoint = Vector2.new(.5, 0), Position = UDim2.new(a, 0, 0, 33), Size = UDim2.new(1 / #steps, 0, 0, 14), TextXAlignment = Enum.TextXAlignment.Center })
    end
    draw()
    local function set(n) cur = math.clamp(n, 1, #steps) draw() if o.Callback then task.spawn(o.Callback, cur) end end
    return Wrap(r, { Set = function(_, n) set(n) end, Next = function() set(cur + 1) end, Prev = function() set(cur - 1) end, Get = function() return cur end })
end

-- Date / time ----------------------------------------------------------------
local function Spinner(p, x, label, mn, mx, val, cb, fmt)
    local f = New("Frame", { BackgroundTransparency = 1, Position = UDim2.new(x, 0, 0, 0), Size = UDim2.new(.33, 0, 0, 62), Parent = p })
    Txt(f, label, 11, { Size = UDim2.new(1, 0, 0, 14), TextXAlignment = Enum.TextXAlignment.Center, TextColor3 = C.Sub })
    local v = val
    local l = Txt(f, "", 13, { Position = UDim2.fromOffset(0, 18), Size = UDim2.new(1, 0, 0, 20), TextXAlignment = Enum.TextXAlignment.Center, Font = Enum.Font.GothamBold })
    local function draw() l.Text = fmt and fmt(v) or tostring(v) end draw()
    local function step(d) v = v + d if v > mx then v = mn elseif v < mn then v = mx end draw() cb(v) end
    local a = GlassBtn(f, "-", nil, function() step(-1) end, UDim2.new(.4, -4, 0, 20)) a.Position = UDim2.new(.05, 0, 0, 40)
    local b = GlassBtn(f, "+", nil, function() step(1) end, UDim2.new(.4, -4, 0, 20)) b.Position = UDim2.new(.55, 0, 0, 40)
    return { Set = function(x) v = x draw() end }
end
function Elements:AddDatePicker(o)
    local d = o.Default or os.date("*t")
    local m, dy, y = d.month, d.day, d.year
    local r = Row(self, 38, o.Title, o.Tooltip) r.ClipsDescendants = true local tl = Title(r, o.Title, .5)
    local vl = Txt(r, "", 12, { AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -10, 0, 0), Size = UDim2.new(.5, -10, 0, 38), TextXAlignment = Enum.TextXAlignment.Right, TextColor3 = C.Sub })
    local function get() return string.format("%04d-%02d-%02d", y, m, dy) end
    local function upd(silent) vl.Text = get() if not silent then Fire(o, get()) end end
    local pn = New("Frame", { BackgroundTransparency = 1, Position = UDim2.fromOffset(6, 42), Size = UDim2.new(1, -12, 0, 62), Parent = r })
    local sm = Spinner(pn, 0, "Month", 1, 12, m, function(v) m = v upd() end)
    local sd = Spinner(pn, .335, "Day", 1, 31, dy, function(v) dy = v upd() end)
    local sy = Spinner(pn, .67, "Year", 1970, 2100, y, function(v) y = v upd() end)
    local open = false
    local hb = New("TextButton", { BackgroundTransparency = 1, Text = "", Size = UDim2.new(1, 0, 0, 38), Parent = r })
    hb.MouseButton1Click:Connect(function() open = not open Tween(r, { Size = UDim2.new(1, 0, 0, open and 110 or 38) }, .2) end)
    upd(true) Reg(o, get, function(s) local a, b, c = tostring(s):match("(%d+)-(%d+)-(%d+)") if a then y, m, dy = tonumber(a), tonumber(b), tonumber(c) sm.Set(m) sd.Set(dy) sy.Set(y) upd() end end)
    return Wrap(r, { _tl = tl, Get = get })
end
function Elements:AddTimePicker(o)
    local t = o.Default or os.date("*t")
    local h, mi, pm = (t.hour % 12 == 0) and 12 or t.hour % 12, t.min, t.hour >= 12
    local r = Row(self, 38, o.Title, o.Tooltip) r.ClipsDescendants = true local tl = Title(r, o.Title, .5)
    local vl = Txt(r, "", 12, { AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -10, 0, 0), Size = UDim2.new(.5, -10, 0, 38), TextXAlignment = Enum.TextXAlignment.Right, TextColor3 = C.Sub })
    local function get() return string.format("%02d:%02d %s", h, mi, pm and "PM" or "AM") end
    local function upd(silent) vl.Text = get() if not silent then Fire(o, get()) end end
    local pn = New("Frame", { BackgroundTransparency = 1, Position = UDim2.fromOffset(6, 42), Size = UDim2.new(1, -12, 0, 62), Parent = r })
    local sh = Spinner(pn, 0, "Hour", 1, 12, h, function(v) h = v upd() end)
    local sm = Spinner(pn, .335, "Minute", 0, 59, mi, function(v) mi = v upd() end, function(v) return string.format("%02d", v) end)
    Spinner(pn, .67, "AM/PM", 0, 1, pm and 1 or 0, function(v) pm = v == 1 upd() end, function(v) return v == 1 and "PM" or "AM" end)
    local open = false
    local hb = New("TextButton", { BackgroundTransparency = 1, Text = "", Size = UDim2.new(1, 0, 0, 38), Parent = r })
    hb.MouseButton1Click:Connect(function() open = not open Tween(r, { Size = UDim2.new(1, 0, 0, open and 110 or 38) }, .2) end)
    upd(true) Reg(o, get, function() end)
    return Wrap(r, { _tl = tl, Get = get })
end

-- Containers -------------------------------------------------------------------
local function Box(self, o, kind)
    local r = Row(self, 0, o.Title) r.AutomaticSize = Y r.Size = UDim2.new(1, 0, 0, 0)
    New("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Parent = r })
    local head = New("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 32), LayoutOrder = 0, Parent = r })
    local tx = 10
    if o.Icon then Ico(head, o.Icon, 15, Library.Theme.Accent).Position = UDim2.new(0, 10, .5, -7) tx = 31 end
    local tl = Txt(head, o.Title or "", 13, { Position = UDim2.fromOffset(tx, 0), Size = UDim2.new(1, -tx - 28, 1, 0), Font = Enum.Font.GothamBold })
    local body = New("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Y, LayoutOrder = 1, Parent = r }, { List(6), Pad(6) })
    body.UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Top
    local obj = Wrap(r, { _tl = tl })
    if kind == "collapsible" then
        local ar = Txt(head, "v", 11, { AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -8, 0, 0), Size = UDim2.fromOffset(16, 32), TextXAlignment = Enum.TextXAlignment.Center, TextColor3 = C.Sub })
        local open = o.Open ~= false body.Visible = open ar.Text = open and "^" or "v"
        Click(head, function() open = not open body.Visible = open ar.Text = open and "^" or "v" end)
        function obj:Toggle(v) open = v == nil and not open or v body.Visible = open ar.Text = open and "^" or "v" end
    end
    return Sub(obj, body)
end
function Elements:AddGroupbox(o) return Box(self, o, "group") end
function Elements:AddCard(o)
    local c = Box(self, o, "card")
    if o.Content then c:AddLabel({ Title = o.Content }).Frame.UIStroke.Enabled = false end
    return c
end
function Elements:AddCollapsible(o) return Box(self, o, "collapsible") end
function Elements:AddScrollArea(o)
    local r = Row(self, o.Height or 140, o.Title) local sc = Scroll(r) sc.ScrollBarThickness = 5
    return Sub(Wrap(r), sc)
end
Elements.AddScrollbar = Elements.AddScrollArea

-- Dual / info / community / game card (used by General, reusable anywhere) -------
function Elements:AddInfo(o)
    local r = Row(self, 36, o.Title) local tl = Title(r, o.Title, .35)
    local vl = Txt(r, tostring(o.Value or ""), 12, { AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, o.Copy and -62 or -10, 0, 0), Size = UDim2.new(.6, -10, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Right, TextColor3 = C.Sub, TextTruncate = Enum.TextTruncate.AtEnd })
    if o.Copy then local b = GlassBtn(r, "", "copy", function() setclip(vl.Text) Library:Toast("Copied") end, UDim2.fromOffset(44, 24)) b.AnchorPoint = Vector2.new(1, .5) b.Position = UDim2.new(1, -8, .5, 0) end
    return Wrap(r, { _tl = tl, Set = function(_, x) vl.Text = tostring(x) end, Get = function() return vl.Text end })
end
function Elements:AddDual(o)
    local r = Row(self, 40, o.Left.Title) local ls = {}
    for i, side in ipairs({ o.Left, o.Right }) do
        local f = New("Frame", { BackgroundTransparency = 1, Position = UDim2.new((i - 1) * .5, 0, 0, 0), Size = UDim2.fromScale(.5, 1), Parent = r })
        Txt(f, side.Title, 11, { Position = UDim2.fromOffset(10, 4), Size = UDim2.new(1, -20, 0, 14), TextColor3 = C.Sub })
        ls[i] = Txt(f, tostring(side.Value or ""), 13, { Position = UDim2.fromOffset(10, 19), Size = UDim2.new(1, -20, 0, 16), Font = Enum.Font.GothamBold, TextTruncate = Enum.TextTruncate.AtEnd })
    end
    New("Frame", { Position = UDim2.fromScale(.5, .2), Size = UDim2.new(0, 1, .6, 0), BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = .8, BorderSizePixel = 0, Parent = r })
    return Wrap(r, { SetLeft = function(_, x) ls[1].Text = tostring(x) end, SetRight = function(_, x) ls[2].Text = tostring(x) end })
end
function Elements:AddGameCard(o)
    o = o or {}
    local pid = o.PlaceId or game.PlaceId local r = Row(self, 76, "game")
    New("ImageLabel", { Position = UDim2.fromOffset(8, 8), Size = UDim2.fromOffset(60, 60), BackgroundColor3 = C.Dark2, Image = "rbxthumb://type=GameIcon&id=" .. game.GameId .. "&w=150&h=150", Parent = r }, { Corner(8), New("UIStroke", { Color = Library.Theme.Accent, Transparency = .3 }) })
    local nm = Txt(r, o.Name or "Loading...", 14, { Position = UDim2.fromOffset(78, 10), Size = UDim2.new(1, -150, 0, 18), Font = Enum.Font.GothamBold, TextTruncate = Enum.TextTruncate.AtEnd })
    Txt(r, "Place ID: " .. pid, 12, { Position = UDim2.fromOffset(78, 32), Size = UDim2.new(1, -150, 0, 16), TextColor3 = C.Sub })
    local b = GlassBtn(r, "Copy", "copy", function() setclip(tostring(pid)) Library:Toast("Place ID copied") end, UDim2.fromOffset(64, 26)) b.AnchorPoint = Vector2.new(1, .5) b.Position = UDim2.new(1, -8, .5, 0)
    if not o.Name then task.spawn(function() local ok, i = pcall(Market.GetProductInfo, Market, pid) if ok and i then nm.Text = i.Name end end) end
    return Wrap(r, { Set = function(_, x) nm.Text = x end })
end
function Elements:AddCommunityCard(o)
    local r = Row(self, 70, o.Title) local tl
    local ib = New("Frame", { Position = UDim2.fromOffset(8, 11), Size = UDim2.fromOffset(48, 48), BackgroundColor3 = o.Color or Library.Theme.Accent, BackgroundTransparency = .3, Parent = r }, { Corner(10) })
    Ico(ib, o.Icon, 26).Position = UDim2.fromOffset(11, 11)
    tl = Txt(r, o.Title, 14, { Position = UDim2.fromOffset(66, 12), Size = UDim2.new(1, -150, 0, 18), Font = Enum.Font.GothamBold })
    Txt(r, o.Link, 11, { Position = UDim2.fromOffset(66, 34), Size = UDim2.new(1, -150, 0, 16), TextColor3 = C.Sub, TextTruncate = Enum.TextTruncate.AtEnd })
    local function join()
        local code = tostring(o.Link):match("discord%.gg/([%w%-_]+)")
        if code and request then
            pcall(request, { Url = "http://127.0.0.1:6463/rpc?v=1", Method = "POST", Headers = { ["Content-Type"] = "application/json", Origin = "https://discord.com" },
                Body = HS:JSONEncode({ cmd = "INVITE_BROWSER", args = { code = code }, nonce = HS:GenerateGUID(false) }) })
        end
        setclip(o.Link) Library:Notify({ Title = "Invite", Content = "Link copied, paste it in your browser if it did not open.", Type = "Info", Icon = o.Icon })
    end
    local j = GlassBtn(r, "Join", "link", join, UDim2.fromOffset(72, 26)) j.AnchorPoint = Vector2.new(1, 0) j.Position = UDim2.new(1, -8, 0, 10)
    local c = GlassBtn(r, "Copy", "copy", function() setclip(o.Link) Library:Toast("Link copied") end, UDim2.fromOffset(72, 26)) c.AnchorPoint = Vector2.new(1, 0) c.Position = UDim2.new(1, -8, 0, 38)
    return Wrap(r, { _tl = tl })
end

---------------------------------------------------------------- Tabs / SubTabs
local Tab = setmetatable({}, { __index = Elements }) Tab.__index = Tab
local SubTab = setmetatable({}, { __index = Elements }) SubTab.__index = SubTab
local Window = {} Window.__index = Window

local function Page(parent, pos, size)
    local wrap = New("CanvasGroup", { BackgroundTransparency = 1, Position = pos, Size = size, Visible = false, Parent = parent })
    return { wrap = wrap, scroll = Scroll(wrap), pos = pos }
end
local function ShowPage(pg, anim)
    pg.wrap.Visible = true
    if not anim or Library.LowFx then pg.wrap.GroupTransparency = 0 pg.wrap.Position = pg.pos return end
    pg.wrap.GroupTransparency = 1
    pg.wrap.Position = UDim2.new(pg.pos.X.Scale, pg.pos.X.Offset, pg.pos.Y.Scale, pg.pos.Y.Offset + 16)
    Tween(pg.wrap, { GroupTransparency = 0, Position = pg.pos }, .38)
end
local function styleBtn(b, on)
    Tween(b, { BackgroundTransparency = on and .3 or .85, BackgroundColor3 = on and Library.Theme.Accent or C.Glass }, .2)
    b.UIStroke.Transparency = on and .15 or 1
end

function Tab:_moveInd(st)
    task.defer(function()
        RS.Heartbeat:Wait()
        if not (st._btn and st._btn.Parent and self._ind.Parent) then return end
        local bp, pp = st._btn.AbsolutePosition, self._page.AbsolutePosition
        Tween(self._ind, { Position = UDim2.fromOffset(bp.X - pp.X, 40), Size = UDim2.fromOffset(st._btn.AbsoluteSize.X, 3) }, .35, Enum.EasingStyle.Quint)
    end)
end
function Tab:_show(anim)
    if self._hasSub then
        local pick = self._subs[1]
        for _, s in ipairs(self._subs) do if s._on then pick = s end end
        for _, s in ipairs(self._subs) do if s ~= pick then s._pg.wrap.Visible = false end end
        ShowPage(pick._pg, anim) self:_moveInd(pick)
    else ShowPage(self._main, anim) end
end
function Tab:AddSubTab(o)
    if not self._hasSub then self._hasSub = true self._row.Visible = true self._ind.Visible = true self._main.wrap.Visible = false end
    local st = setmetatable({ _tab = self, _n = 0 }, SubTab)
    st._pg = Page(self._page, UDim2.fromOffset(0, 46), UDim2.new(1, 0, 1, -46)) st._c = st._pg.scroll
    st._btn = New("TextButton", { AutoButtonColor = false, Text = "", BackgroundColor3 = C.Glass, BackgroundTransparency = .85, AutomaticSize = X, Size = UDim2.fromOffset(0, 30),
        LayoutOrder = #self._subs + 1, Parent = self._row }, { Corner(8, true), New("UIStroke", { Color = Library.Theme.Accent, Transparency = 1 }), New("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 12) }) })
    New("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 6), VerticalAlignment = Enum.VerticalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder, Parent = st._btn })
    Ico(st._btn, o.Icon or "dot", 14).LayoutOrder = 0
    Txt(st._btn, o.Title, 12, { AutomaticSize = X, Size = UDim2.new(0, 0, 1, 0), LayoutOrder = 1, Font = Enum.Font.GothamBold })
    st._btn.MouseButton1Click:Connect(function() st:Select() end)
    st._btn.MouseEnter:Connect(function() if not st._on then Tween(st._btn, { BackgroundTransparency = .65 }, .15) end end)
    st._btn.MouseLeave:Connect(function() if not st._on then Tween(st._btn, { BackgroundTransparency = .85 }, .15) end end)
    Bind(function(c) if st._on then st._btn.BackgroundColor3 = c end end)
    table.insert(self._subs, st)
    if #self._subs == 1 then st:Select() end
    return st
end
function SubTab:Select()
    local tab = self._tab
    local visible = tab._win._cur == tab
    for _, s in ipairs(tab._subs) do
        s._on = s == self styleBtn(s._btn, s == self)
        if s ~= self then s._pg.wrap.Visible = false end
    end
    if visible or #tab._subs > 1 then ShowPage(self._pg, visible) end
    if not visible then self._pg.wrap.Visible = true end
    tab:_moveInd(self)
end
function Tab:Select() self._win:_select(self) end

function Window:_select(tab)
    for _, t in ipairs(self._tabs) do
        local on = t == tab
        t._page.Visible = on
        t._btn.BackgroundColor3 = on and Library.Theme.Accent or C.Glass
        Tween(t._btn, { BackgroundTransparency = on and .3 or .85 }, .2) t._btn.UIStroke.Transparency = on and .15 or 1
        Tween(t._bar, { Size = UDim2.fromOffset(3, on and 18 or 0) }, .3, Enum.EasingStyle.Back)
    end
    self._cur = tab
    tab:_show(true)
end
function Window:AddTab(o)
    local tab = setmetatable({ _win = self, _n = 0, _subs = {}, Title = o.Title }, Tab)
    tab._btn = New("TextButton", { AutoButtonColor = false, Text = "", BackgroundColor3 = C.Glass, BackgroundTransparency = .85, Size = UDim2.new(1, 0, 0, 36), LayoutOrder = #self._tabs + 1, Parent = self._tabsList },
        { Corner(10, true), New("UIStroke", { Color = Library.Theme.Accent, Transparency = 1 }) })
    tab._bar = New("Frame", { AnchorPoint = Vector2.new(0, .5), Position = UDim2.new(0, 3, .5, 0), Size = UDim2.fromOffset(3, 0), BackgroundColor3 = Library.Theme.Accent, BorderSizePixel = 0, Parent = tab._btn }, { Corner() })
    Bind(function(c) tab._bar.BackgroundColor3 = c if self._cur == tab then tab._btn.BackgroundColor3 = c end end)
    Ico(tab._btn, o.Icon or "dot", 16).Position = UDim2.new(0, 14, .5, -8)
    Txt(tab._btn, o.Title, 12, { Position = UDim2.fromOffset(38, 0), Size = UDim2.new(1, -42, 1, 0), Font = Enum.Font.GothamBold, TextTruncate = Enum.TextTruncate.AtEnd })
    tab._btn.MouseEnter:Connect(function() if self._cur ~= tab then Tween(tab._btn, { BackgroundTransparency = .65 }, .15) end end)
    tab._btn.MouseLeave:Connect(function() if self._cur ~= tab then Tween(tab._btn, { BackgroundTransparency = .85 }, .15) end end)
    tab._page = New("Frame", { BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Visible = false, Parent = self._content })
    tab._row = New("ScrollingFrame", { BackgroundTransparency = 1, BorderSizePixel = 0, Position = UDim2.fromOffset(8, 8), Size = UDim2.new(1, -16, 0, 32), CanvasSize = UDim2.new(), AutomaticCanvasSize = X,
        ScrollBarThickness = 0, ScrollingDirection = Enum.ScrollingDirection.X, Visible = false, Parent = tab._page }, { New("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 6), VerticalAlignment = Enum.VerticalAlignment.Center }) })
    tab._ind = New("Frame", { Position = UDim2.fromOffset(8, 40), Size = UDim2.fromOffset(0, 3), BackgroundColor3 = Library.Theme.Accent, BorderSizePixel = 0, Visible = false, Parent = tab._page }, { Corner() })
    Bind(function(c) tab._ind.BackgroundColor3 = c end)
    tab._main = Page(tab._page, UDim2.new(), UDim2.fromScale(1, 1)) tab._c = tab._main.scroll
    tab._btn.MouseButton1Click:Connect(function() self:_select(tab) end)
    table.insert(self._tabs, tab)
    if #self._tabs == 1 then self:_select(tab) end
    return tab
end
function Window:_filter(q)
    q = (q or ""):lower()
    local tab = self._cur if not tab then return end
    local c = tab._c
    if tab._hasSub then for _, s in ipairs(tab._subs) do if s._on then c = s._c end end end
    for _, r in ipairs(c:GetChildren()) do
        local sa = r:GetAttribute("Search")
        if sa ~= nil then r.Visible = (q == "" or sa:find(q, 1, true) ~= nil) end
    end
end

function Window:SetTag(text, color)
    self._tag.Text = text or "" self._tagf.BackgroundColor3 = color or Library.Theme.Accent self._tagf.Visible = text ~= nil and text ~= ""
end
function Window:SetTitle(t) self._title.Text = t end
function Window:SetVisible(v)
    self._vis = v
    local sc = self._scale
    if v then self._main.Visible = true sc.Scale = .88 Tween(sc, { Scale = 1 }, .45, Enum.EasingStyle.Back)
    else Tween(sc, { Scale = .88 }, .18) task.delay(.18, function() if not self._vis then self._main.Visible = false end end) end
end
function Window:Toggle() self:SetVisible(not self._vis) end
function Window:SetOpenSize(n)
    n = math.clamp(n, 30, 90) self._os = n
    self._float.Size = UDim2.fromOffset(n, n)
    if self._fic then self._fic:Destroy() end
    local ic = Ico(self._float, "bolt", n * .5, Library.Theme.Accent) ic.AnchorPoint = Vector2.new(.5, .5) ic.Position = UDim2.fromScale(.5, .5) self._fic = ic
end
function Window:SetUserCard(o)
    o = o or {}
    local id = o.UserId or LP.UserId
    self._uav.Image = "rbxthumb://type=AvatarHeadShot&id=" .. id .. "&w=150&h=150"
    self._unm.Text = o.Display or LP.DisplayName self._uus.Text = "@" .. (o.Name or LP.Name)
    if o.Status then self._ust.Text = o.Status end
end
function Window:ToggleMusic() if self._mpanel then self._mpanel:Set(not self._mpanel.open) end end
function Window:Modal(o)
    local ov = New("TextButton", { Text = "", AutoButtonColor = false, BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ZIndex = 50, Parent = self._main })
    Tween(ov, { BackgroundTransparency = .45 }, .2)
    local p = New("Frame", { AnchorPoint = Vector2.new(.5, .5), Position = UDim2.fromScale(.5, .5), Size = UDim2.fromOffset(o.Width or 270, 0), AutomaticSize = Y, BackgroundColor3 = C.Dark1,
        BackgroundTransparency = .1, ZIndex = 51, Parent = ov }, { Corner(14, true), Pad(10), List(6), New("UIScale", { Scale = .9 }) })
    Glow(p, 1.5, .25) Tween(p.UIScale, { Scale = 1 }, .25, Enum.EasingStyle.Back)
    Txt(p, o.Title or "Modal", 15, { Font = Enum.Font.GothamBold, LayoutOrder = 0 })
    if o.Content then Txt(p, o.Content, 12, { TextWrapped = true, AutomaticSize = Y, Size = UDim2.new(1, 0, 0, 0), TextColor3 = C.Sub, LayoutOrder = 1 }) end
    local body = Container(p) body.LayoutOrder = 2
    local m = Sub({}, body)
    function m:Close() Tween(ov, { BackgroundTransparency = 1 }, .15) task.delay(.15, function() ov:Destroy() end) p.Visible = false end
    for _, d in ipairs(p:GetDescendants()) do if d:IsA("GuiObject") then d.ZIndex = 52 end end
    p.DescendantAdded:Connect(function(d) if d:IsA("GuiObject") then d.ZIndex = 52 end end)
    return m
end
function Window:Dialog(o)
    local m = self:Modal({ Title = o.Title, Content = o.Content, Width = o.Width })
    local f = New("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 30), Parent = m._c }, { List(6, Enum.FillDirection.Horizontal) })
    f.UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    for _, b in ipairs(o.Buttons or { { Text = "OK" } }) do
        GlassBtn(f, b.Text, b.Icon, function() m:Close() if b.Callback then b.Callback() end end, UDim2.fromOffset(80, 28))
    end
    for _, d in ipairs(f:GetDescendants()) do if d:IsA("GuiObject") then d.ZIndex = 53 end end
    return m
end
function Window:Destroy() self._gui:Destroy() end

---------------------------------------------------------------- config system
local function enc(v)
    local t = typeof(v)
    if t == "Color3" then return { __t = "c", v.R, v.G, v.B } elseif t == "EnumItem" then return { __t = "k", v.Name } end
    return v
end
local function dec(v)
    if type(v) == "table" and v.__t == "c" then return Color3.new(v[1], v[2], v[3]) elseif type(v) == "table" and v.__t == "k" then return Enum.KeyCode[v[1]] end
    return v
end
function Library:ListConfigs()
    local out = {}
    pcall(function()
        for _, f in ipairs(listfiles(Library._folder)) do local n = f:match("([^/\\]+)%.json$") if n then out[#out + 1] = n end end
    end)
    return out
end
function Library:SaveConfig(name)
    if not name or name == "" then return false end
    local ok = pcall(function()
        if not isfolder("PickasHub") then makefolder("PickasHub") end
        if not isfolder(Library._folder) then makefolder(Library._folder) end
        local d = {} for k, v in pairs(Library.Flags) do d[k] = enc(v) end
        writefile(Library._folder .. "/" .. name .. ".json", HS:JSONEncode(d))
    end)
    return ok
end
function Library:LoadConfig(name)
    local ok = pcall(function()
        local d = HS:JSONDecode(readfile(Library._folder .. "/" .. name .. ".json"))
        for k, v in pairs(d) do if Library._set[k] then Library._set[k](dec(v)) end end
    end)
    return ok
end
function Library:DeleteConfig(name) return pcall(function() delfile(Library._folder .. "/" .. name .. ".json") end) end

---------------------------------------------------------------- device
local function Device()
    local ok, p = pcall(function() return UIS:GetPlatform() end)
    if ok then
        if p == Enum.Platform.IOS then return "iOS" elseif p == Enum.Platform.Android then return "Android" elseif p == Enum.Platform.OSX then return "Mac"
        elseif p == Enum.Platform.Windows or p == Enum.Platform.UWP or p == Enum.Platform.Linux then return "Desktop" end
    end
    return "Neo"
end

---------------------------------------------------------------- Music engine
local function fmt(s) s = math.max(0, math.floor(tonumber(s) or 0)) return string.format("%d:%02d", math.floor(s / 60), s % 60) end
local Music = { songs = {}, idx = 0, playing = false, loop = false, shuffle = false, volume = .6 }
Library.Music = Music

local function resolve(song)
    if song.Id then
        local id = tostring(song.Id)
        return id:find("rbx") and id or ("rbxassetid://" .. id:gsub("%D", ""))
    end
    if song.Url and writefile and getcustomasset then
        local ok, res = pcall(function()
            pcall(makefolder, "PickasHub") pcall(makefolder, "PickasHub/music")
            local name = "PickasHub/music/" .. #song.Url .. "_" .. tostring(song.Url:gsub("%W", "")):sub(-24) .. ".mp3"
            if not (isfile and isfile(name)) then writefile(name, game:HttpGet(song.Url)) end
            return getcustomasset(name)
        end)
        if ok and res then return res end
    end
    return nil
end
local function sound()
    if not Music._s then
        local s = Instance.new("Sound") s.Name = "PickasHubMusic" s.Volume = Music.volume s.Parent = SoundService
        s.Ended:Connect(function() Music:_ended() end)
        Music._s = s
    end
    return Music._s
end
function Music:_notify() if self._onChange then pcall(self._onChange) end end
function Music:AddSong(s) table.insert(self.songs, s) if self._onList then pcall(self._onList) end return #self.songs end
function Music:Remove(i) table.remove(self.songs, i) if self.idx == i then self.idx = 0 self.playing = false if self._s then self._s:Stop() end end if self._onList then pcall(self._onList) end self:_notify() end
function Music:Clear() self.songs = {} self.idx = 0 self.playing = false if self._s then self._s:Stop() end if self._onList then pcall(self._onList) end self:_notify() end
function Music:Current() return self.songs[self.idx] end
function Music:Play(i)
    i = i or (self.idx > 0 and self.idx) or 1
    local s = self.songs[i] if not s then return end
    local src = resolve(s)
    if not src then Library:Notify({ Title = "Music", Content = "This song has no audio source (Id or Url).", Type = "Error" }) return end
    self.idx = i
    local snd = sound() snd:Stop()
    snd.SoundId = src snd.Volume = self.volume snd.Looped = self.loop snd.TimePosition = 0 snd:Play()
    self.playing = true self:_notify()
end
function Music:Pause() if self._s then self._s:Pause() end self.playing = false self:_notify() end
function Music:Resume() if self._s and self._s.SoundId ~= "" and self.idx > 0 then self._s:Resume() self.playing = true self:_notify() else self:Play() end end
function Music:Toggle() if self.playing then self:Pause() else self:Resume() end end
function Music:Next()
    local n = #self.songs if n == 0 then return end
    local i
    if self.shuffle and n > 1 then repeat i = math.random(1, n) until i ~= self.idx else i = (self.idx % n) + 1 end
    self:Play(i)
end
function Music:Prev()
    local n = #self.songs if n == 0 then return end
    if self._s and self._s.TimePosition > 3 then self._s.TimePosition = 0 return end
    self:Play(self.idx <= 1 and n or self.idx - 1)
end
function Music:Seek(t) if self._s then self._s.TimePosition = math.clamp(t, 0, math.max(self._s.TimeLength, 0)) end end
function Music:SetVolume(v) self.volume = math.clamp(v, 0, 1) if self._s then self._s.Volume = self.volume end end
function Music:SetLoop(b) self.loop = b and true or false if self._s then self._s.Looped = self.loop end self:_notify() end
function Music:SetShuffle(b) self.shuffle = b and true or false self:_notify() end
function Music:_ended() if not self.loop then self:Next() end end

---------------------------------------------------------------- Music card (header) + side panel
local function BuildMusicCard(W, bar)
    local mc = New("TextButton", { Text = "", AutoButtonColor = false, BackgroundColor3 = C.Glass, AnchorPoint = Vector2.new(1, .5), Position = UDim2.new(1, -84, .5, 0),
        Size = UDim2.fromOffset(190, 38), Parent = bar }, { Corner(10, true), New("UIStroke", { Color = Library.Theme.Accent, Transparency = .55 }) })
    GlassReg(mc, .55) Bind(function(c) mc.UIStroke.Color = c end)
    local ic = Ico(mc, "music", 15, Library.Theme.Accent, "~") ic.Position = UDim2.fromOffset(8, 4)
    local title = Txt(mc, "No song playing", 11, { Position = UDim2.fromOffset(28, 3), Size = UDim2.new(1, -96, 0, 16), Font = Enum.Font.GothamBold, TextTruncate = Enum.TextTruncate.AtEnd })
    local time = Txt(mc, "0:00 - 0:00", 10, { AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -8, 0, 4), Size = UDim2.fromOffset(62, 14), TextXAlignment = Enum.TextXAlignment.Right, TextColor3 = C.Sub })
    local hold = New("Frame", { BackgroundTransparency = 1, Position = UDim2.fromOffset(9, 22), Size = UDim2.new(1, -18, 0, 12), Parent = mc })
    local bars, nb = {}, 18
    for i = 1, nb do
        local f = New("Frame", { AnchorPoint = Vector2.new(0, 1), Position = UDim2.new((i - 1) / nb, 0, 1, 0), Size = UDim2.new(1 / nb, -2, .12, 0), BackgroundColor3 = Library.Theme.Accent, BorderSizePixel = 0, Parent = hold }, { Corner(2) })
        Bind(function(c) f.BackgroundColor3 = c end)
        bars[i] = { f = f, h = .12 }
    end
    mc.MouseEnter:Connect(function() Tween(mc, { BackgroundTransparency = .35 }, .15) end)
    mc.MouseLeave:Connect(function() Tween(mc, { BackgroundTransparency = math.clamp(.55 + Library.GlassDelta, 0, 1) }, .15) end)
    mc.MouseButton1Click:Connect(function() W:ToggleMusic() end)
    local last = ""
    table.insert(Library._tick, function(dt, t)
        if not mc.Parent then return end
        local s = Music._s
        local playing = s and s.IsPlaying
        local loud = playing and math.clamp(s.PlaybackLoudness / 380, 0, 1) or 0
        local k = math.min(1, dt * 14)
        for i, b in ipairs(bars) do
            local tgt = playing and (.14 + loud * (.25 + .75 * math.abs(math.sin(t * 5 + i * 1.3)))) or .1
            b.h = b.h + (tgt - b.h) * k
            b.f.Size = UDim2.new(1 / nb, -2, math.clamp(b.h, .08, 1), 0)
        end
        local txt = fmt(s and s.TimePosition or 0) .. " - " .. fmt(s and s.TimeLength or 0)
        if txt ~= last then last = txt time.Text = txt end
    end)
    return { SetTitle = function(x) title.Text = x end }
end

local function BuildMusicPanel(W)
    local P = { open = false }
    local panel = New("CanvasGroup", { Size = UDim2.fromOffset(252, 330), BackgroundColor3 = C.Dark1, Visible = false, GroupTransparency = 1, Parent = W._gui }, { Corner(16, true), New("UIScale", { Scale = .92 }) })
    GlassReg(panel, .12) Glow(panel, 1.8, .15)
    local scale = panel.UIScale
    local hd = New("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 36), Parent = panel })
    Ico(hd, "music", 16, Library.Theme.Accent, "~").Position = UDim2.fromOffset(12, 10)
    Txt(hd, "Music", 14, { Position = UDim2.fromOffset(36, 0), Size = UDim2.new(1, -80, 1, 0), Font = Enum.Font.GothamBold })
    local cl = IconBtn(hd, "x", "x", function() P:Set(false) end, 24) cl.AnchorPoint = Vector2.new(1, .5) cl.Position = UDim2.new(1, -8, .5, 0)
    local body = Scroll(panel, UDim2.fromOffset(0, 36), UDim2.new(1, 0, 1, -36))

    -- artwork
    local tb = New("Frame", { Size = UDim2.new(1, 0, 0, 122), BackgroundTransparency = 1, LayoutOrder = 1, Parent = body })
    local art = New("Frame", { AnchorPoint = Vector2.new(.5, .5), Position = UDim2.fromScale(.5, .5), Size = UDim2.fromOffset(110, 110), BackgroundColor3 = C.Glass, Parent = tb }, { Corner(18, true) })
    Glow(art, 2, .1)
    local artImg = New("ImageLabel", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ScaleType = Enum.ScaleType.Crop, Image = "", Parent = art }, { Corner(18, true) })
    local artIc = Ico(art, "music", 40, Library.Theme.Accent, "~") artIc.AnchorPoint = Vector2.new(.5, .5) artIc.Position = UDim2.fromScale(.5, .5)
    local nm = Txt(body, "No song playing", 14, { LayoutOrder = 2, Size = UDim2.new(1, 0, 0, 20), TextXAlignment = Enum.TextXAlignment.Center, Font = Enum.Font.GothamBold, TextTruncate = Enum.TextTruncate.AtEnd })
    local ar = Txt(body, "Add songs with Library.Music:AddSong", 11, { LayoutOrder = 3, Size = UDim2.new(1, 0, 0, 16), TextXAlignment = Enum.TextXAlignment.Center, TextColor3 = C.Sub, TextTruncate = Enum.TextTruncate.AtEnd })

    -- progress
    local pr = New("Frame", { Size = UDim2.new(1, 0, 0, 34), BackgroundTransparency = 1, LayoutOrder = 4, Parent = body })
    local ptr = New("Frame", { Position = UDim2.fromOffset(4, 6), Size = UDim2.new(1, -8, 0, 6), BackgroundColor3 = C.Off, Parent = pr }, { Corner() })
    local pf = New("Frame", { Size = UDim2.fromScale(0, 1), BackgroundColor3 = Library.Theme.Accent, Parent = ptr }, { Corner() })
    local pk = New("Frame", { AnchorPoint = Vector2.new(.5, .5), Position = UDim2.fromScale(0, .5), Size = UDim2.fromOffset(12, 12), BackgroundColor3 = Color3.new(1, 1, 1), Parent = ptr }, { Corner() })
    Bind(function(c) pf.BackgroundColor3 = c end)
    local t1 = Txt(pr, "0:00", 11, { Position = UDim2.fromOffset(4, 16), Size = UDim2.new(.5, 0, 0, 14), TextColor3 = C.Sub })
    local t2 = Txt(pr, "0:00", 11, { AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -4, 0, 16), Size = UDim2.new(.5, 0, 0, 14), TextXAlignment = Enum.TextXAlignment.Right, TextColor3 = C.Sub })
    Drag(ptr, function(a) local s = Music._s if s and s.TimeLength > 0 then s.TimePosition = a * s.TimeLength end end,
        function(on) Tween(pk, { Size = on and UDim2.fromOffset(17, 17) or UDim2.fromOffset(12, 12) }, .18, Enum.EasingStyle.Back) end)

    -- transport
    local tr = New("Frame", { Size = UDim2.new(1, 0, 0, 48), BackgroundTransparency = 1, LayoutOrder = 5, Parent = body }, { List(10, Enum.FillDirection.Horizontal) })
    tr.UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    local bShuf = IconBtn(tr, "shuffle", "s", function() Music:SetShuffle(not Music.shuffle) end, 32, true) bShuf.LayoutOrder = 1
    local bPrev = IconBtn(tr, "skip-back", "<", function() Music:Prev() end, 34, true) bPrev.LayoutOrder = 2
    local bPlay = IconBtn(tr, "play", ">", function() Music:Toggle() end, 44, true) bPlay.LayoutOrder = 3
    local bNext = IconBtn(tr, "skip-forward", ">", function() Music:Next() end, 34, true) bNext.LayoutOrder = 4
    local bLoop = IconBtn(tr, "repeat", "o", function() Music:SetLoop(not Music.loop) end, 32, true) bLoop.LayoutOrder = 5

    -- volume
    local vr = New("Frame", { Size = UDim2.new(1, 0, 0, 26), BackgroundTransparency = 1, LayoutOrder = 6, Parent = body })
    Ico(vr, "volume-2", 16, C.Sub, "v").Position = UDim2.fromOffset(6, 5)
    local vt = New("Frame", { Position = UDim2.new(0, 32, .5, -3), Size = UDim2.new(1, -44, 0, 6), BackgroundColor3 = C.Off, Parent = vr }, { Corner() })
    local vf = New("Frame", { Size = UDim2.fromScale(Music.volume, 1), BackgroundColor3 = Library.Theme.Accent, Parent = vt }, { Corner() })
    Bind(function(c) vf.BackgroundColor3 = c end)
    Drag(vt, function(a) Music:SetVolume(a) vf.Size = UDim2.fromScale(a, 1) end)

    -- search + playlist
    local sb = New("Frame", { Size = UDim2.new(1, 0, 0, 30), BackgroundColor3 = C.Dark2, BackgroundTransparency = .4, LayoutOrder = 7, Parent = body }, { Corner(8, true), New("UIStroke", { Color = Library.Theme.Accent, Transparency = .65 }) })
    Ico(sb, "search", 14, C.Sub, "?").Position = UDim2.fromOffset(9, 8)
    local sbx = New("TextBox", { BackgroundTransparency = 1, Position = UDim2.fromOffset(30, 0), Size = UDim2.new(1, -36, 1, 0), Text = "", PlaceholderText = "Search song...", PlaceholderColor3 = C.Sub,
        TextColor3 = C.Text, Font = Enum.Font.Gotham, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false, Parent = sb })
    local pl = New("Frame", { Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Y, BackgroundTransparency = 1, LayoutOrder = 8, Parent = body }, { List(4) })
    pl.UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Top
    local items = {}
    local function thumbOf(song, img)
        if song.Thumb then pcall(applyIcon, img, song.Thumb) end
    end
    local function rebuild()
        for _, c in ipairs(pl:GetChildren()) do if c:IsA("GuiObject") then c:Destroy() end end items = {}
        if #Music.songs == 0 then
            Txt(pl, "Playlist is empty.", 11, { Size = UDim2.new(1, 0, 0, 24), TextXAlignment = Enum.TextXAlignment.Center, TextColor3 = C.Sub })
        end
        for i, song in ipairs(Music.songs) do
            local it = New("TextButton", { AutoButtonColor = false, Text = "", BackgroundColor3 = C.Glass, BackgroundTransparency = .8, Size = UDim2.new(1, 0, 0, 42), LayoutOrder = i, Parent = pl }, { Corner(10, true) })
            it:SetAttribute("Search", ((song.Title or "") .. " " .. (song.Artist or "")):lower())
            local th = New("ImageLabel", { Position = UDim2.fromOffset(6, 6), Size = UDim2.fromOffset(30, 30), BackgroundColor3 = C.Dark2, ScaleType = Enum.ScaleType.Crop, Image = "", Parent = it }, { Corner(8) })
            if song.Thumb then thumbOf(song, th) else local ic = Ico(th, "music", 14, Library.Theme.Accent, "~") ic.AnchorPoint = Vector2.new(.5, .5) ic.Position = UDim2.fromScale(.5, .5) end
            Txt(it, song.Title or "Untitled", 12, { Position = UDim2.fromOffset(44, 5), Size = UDim2.new(1, -52, 0, 16), Font = Enum.Font.GothamBold, TextTruncate = Enum.TextTruncate.AtEnd })
            Txt(it, song.Artist or "", 10, { Position = UDim2.fromOffset(44, 21), Size = UDim2.new(1, -52, 0, 14), TextColor3 = C.Sub, TextTruncate = Enum.TextTruncate.AtEnd })
            it.MouseButton1Click:Connect(function() Music:Play(i) end)
            it.MouseEnter:Connect(function() if Music.idx ~= i then Tween(it, { BackgroundTransparency = .6 }, .15) end end)
            it.MouseLeave:Connect(function() if Music.idx ~= i then Tween(it, { BackgroundTransparency = .8 }, .15) end end)
            items[i] = it
        end
    end
    sbx:GetPropertyChangedSignal("Text"):Connect(function()
        local q = sbx.Text:lower()
        for _, it in ipairs(items) do local s = it:GetAttribute("Search") it.Visible = q == "" or (s and s:find(q, 1, true) ~= nil) end
    end)

    local function styleToggle(b, on) Tween(b, { BackgroundColor3 = on and Library.Theme.Accent or C.Glass, BackgroundTransparency = on and .25 or .55 }, .2) end
    Music._onList = function() rebuild() if Music._onChange then Music._onChange() end end
    Music._onChange = function()
        local s = Music:Current()
        nm.Text = s and (s.Title or "Untitled") or "No song playing"
        ar.Text = s and (s.Artist or "") or "Add songs with Library.Music:AddSong"
        if W._mcard then W._mcard.SetTitle(s and (s.Title or "Untitled") or "No song playing") end
        artImg.Image = "" if s and s.Thumb then pcall(applyIcon, artImg, s.Thumb) end
        artIc.Visible = not (s and s.Thumb)
        SetIcon(bPlay, Music.playing and "pause" or "play", Music.playing and "||" or ">", 24)
        styleToggle(bShuf, Music.shuffle) styleToggle(bLoop, Music.loop)
        for i, it in ipairs(items) do Tween(it, { BackgroundTransparency = Music.idx == i and .45 or .8, BackgroundColor3 = Music.idx == i and Library.Theme.Accent or C.Glass }, .25) end
    end
    rebuild() Music._onChange()

    function P:Set(v)
        if v == P.open then return end
        P.open = v
        if v then panel.Visible = true Tween(panel, { GroupTransparency = 0 }, .3) Tween(scale, { Scale = 1 }, .45, Enum.EasingStyle.Back)
        else Tween(panel, { GroupTransparency = 1 }, .2) Tween(scale, { Scale = .92 }, .2) task.delay(.22, function() if not P.open then panel.Visible = false end end) end
    end
    table.insert(Library._tick, function()
        if not panel.Parent then return end
        local s = Music._s
        local pos, len = s and s.TimePosition or 0, s and s.TimeLength or 0
        local a = len > 0 and math.clamp(pos / len, 0, 1) or 0
        pf.Size = UDim2.fromScale(a, 1) pk.Position = UDim2.fromScale(a, .5)
        t1.Text = fmt(pos) t2.Text = fmt(len)
        if P.open then
            local mp, ms = W._main.AbsolutePosition, W._main.AbsoluteSize
            local vp = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1280, 720)
            local w, h = 252, math.max(ms.Y, 300)
            local x = mp.X + ms.X + 8
            if x + w > vp.X - 6 then x = mp.X - w - 8 if x < 6 then x = math.max(6, vp.X - w - 6) end end
            panel.Position = UDim2.fromOffset(x, mp.Y) panel.Size = UDim2.fromOffset(w, h)
        end
    end)
    return P
end
function Window:Destroy() if Music._s then Music._s:Destroy() Music._s = nil end self._gui:Destroy() end

---------------------------------------------------------------- CreateWindow
function Library:CreateWindow(o)
    o = o or {}
    local W = setmetatable({ _tabs = {}, _vis = true, _os = 48 }, Window)
    local gui = New("ScreenGui", { Name = "PickasHub", ResetOnSpawn = false, IgnoreGuiInset = true, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, DisplayOrder = 999 })
    pcall(function() gui.Parent = (gethui and gethui()) or game:GetService("CoreGui") end)
    if not gui.Parent then gui.Parent = LP:WaitForChild("PlayerGui") end
    W._gui = gui

    local vp = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1280, 720)
    local sz = o.Size or Vector2.new(math.min(620, vp.X - 24), math.min(400, vp.Y - 30))
    local sideW = vp.X < 700 and 132 or 150
    local main = New("Frame", { Name = "Window", AnchorPoint = Vector2.new(.5, .5), Position = UDim2.fromScale(.5, .5), Size = UDim2.fromOffset(sz.X, sz.Y), BackgroundColor3 = C.Dark2,
        ClipsDescendants = true, Parent = gui }, { Corner(16, true), New("UIGradient", { Rotation = 135, Color = ColorSequence.new(C.Dark1, C.Dark2) }) })
    W._main = main W._scale = New("UIScale", { Parent = main }) Glow(main, 2, .1)

    -- aurora / rainbow ribbons
    local aur = New("Frame", { BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Parent = main })
    local specs = { { y = .22, r = -18, o = 0 }, { y = .50, r = 14, o = .12 }, { y = .78, r = -8, o = -.1 }, { y = .95, r = 22, o = .25 } }
    for i, sp in ipairs(specs) do
        local f = New("Frame", { AnchorPoint = Vector2.new(.5, .5), Size = UDim2.fromScale(1.9, .5), Position = UDim2.fromScale(.5, sp.y), Rotation = sp.r, BackgroundColor3 = Library.Theme.Accent, BorderSizePixel = 0, Parent = aur })
        local g = New("UIGradient", { Rotation = 90, Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(.5, .78), NumberSequenceKeypoint.new(1, 1) }), Parent = f })
        table.insert(Library._aur, { f = f, g = g, y = sp.y, r = sp.r, o = sp.o, p = i * 2.1, sx = .25 + i * .06, sy = .35 + i * .05 })
    end

    -- header
    local bar = New("Frame", { Size = UDim2.new(1, 0, 0, 46), BackgroundColor3 = C.Glass, BorderSizePixel = 0, Parent = main }) GlassReg(bar, .55)
    local left = New("Frame", { BackgroundTransparency = 1, ClipsDescendants = true, Position = UDim2.fromOffset(12, 0), Size = UDim2.new(1, -300, 1, 0), Parent = bar }, { List(8, Enum.FillDirection.Horizontal) })
    left.UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    Ico(left, "bolt", 22, Library.Theme.Accent).LayoutOrder = 0
    W._title = Txt(left, o.Title or "Picka's Hub", 15, { AutomaticSize = X, Size = UDim2.new(0, 0, 1, 0), Font = Enum.Font.GothamBold, LayoutOrder = 1 })
    W._tagf = New("Frame", { AutomaticSize = X, Size = UDim2.fromOffset(0, 18), BackgroundColor3 = Library.Theme.Accent, BackgroundTransparency = .25, LayoutOrder = 2, Parent = left },
        { Corner(), New("UIPadding", { PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8) }) })
    Bind(function(c) W._tagf.BackgroundColor3 = c end)
    W._tag = Txt(W._tagf, "", 10, { AutomaticSize = X, Size = UDim2.new(0, 0, 1, 0), Font = Enum.Font.GothamBold })
    W:SetTag(o.Tag or Device())

    local bmin = IconBtn(bar, "minus", "-", function() W:SetVisible(false) end, 28) bmin.AnchorPoint = Vector2.new(1, .5) bmin.Position = UDim2.new(1, -44, .5, 0)
    local bcls = IconBtn(bar, "x", "x", function()
        W:Dialog({ Title = "Close UI?", Content = "This will destroy the interface.", Buttons = { { Text = "Cancel" }, { Text = "Close", Callback = function() W:Destroy() end } } })
    end, 28) bcls.AnchorPoint = Vector2.new(1, .5) bcls.Position = UDim2.new(1, -10, .5, 0)

    W._mcard = BuildMusicCard(W, bar)

    local startPos
    DragDelta(bar, function() startPos = main.Position end, function(d)
        local tgt = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        if Library.Smooth then Tween(main, { Position = tgt }, .09, Enum.EasingStyle.Quad) else main.Position = tgt end
    end)

    -- sidebar: search + tabs + user card
    local side = New("Frame", { Position = UDim2.fromOffset(0, 46), Size = UDim2.new(0, sideW, 1, -46), BackgroundColor3 = C.Glass, BorderSizePixel = 0, Parent = main }) GlassReg(side, .65)
    local sf = New("Frame", { Position = UDim2.fromOffset(8, 8), Size = UDim2.new(1, -16, 0, 32), BackgroundColor3 = C.Dark2, BackgroundTransparency = .4, Parent = side },
        { Corner(10, true), New("UIStroke", { Color = Library.Theme.Accent, Transparency = .65 }) })
    Bind(function(c) sf.UIStroke.Color = c end)
    Ico(sf, "search", 14, C.Sub, "?").Position = UDim2.fromOffset(9, 9)
    local sbx = New("TextBox", { BackgroundTransparency = 1, Position = UDim2.fromOffset(30, 0), Size = UDim2.new(1, -36, 1, 0), Text = "", PlaceholderText = "Search", PlaceholderColor3 = C.Sub,
        TextColor3 = C.Text, Font = Enum.Font.Gotham, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false, Parent = sf })
    sbx.Focused:Connect(function() Tween(sf.UIStroke, { Transparency = .05, Thickness = 1.8 }, .2) end)
    sbx.FocusLost:Connect(function() Tween(sf.UIStroke, { Transparency = .65, Thickness = 1 }, .25) end)
    sbx:GetPropertyChangedSignal("Text"):Connect(function() W:_filter(sbx.Text) end)
    W._tabsList = New("ScrollingFrame", { Position = UDim2.fromOffset(0, 48), Size = UDim2.new(1, 0, 1, -112), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 0,
        CanvasSize = UDim2.new(), AutomaticCanvasSize = Y, Parent = side }, { List(5), Pad(7) })
    W._tabsList.UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Top

    local uc = New("Frame", { AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 8, 1, -8), Size = UDim2.new(1, -16, 0, 50), BackgroundColor3 = C.Glass, Parent = side },
        { Corner(12, true), New("UIStroke", { Color = Library.Theme.Accent, Transparency = .6 }) })
    GlassReg(uc, .4) Bind(function(c) uc.UIStroke.Color = c end)
    W._uav = New("ImageLabel", { Position = UDim2.fromOffset(8, 8), Size = UDim2.fromOffset(34, 34), BackgroundColor3 = C.Dark2, Parent = uc }, { Corner(), New("UIStroke", { Color = Library.Theme.Accent, Thickness = 2 }) })
    Bind(function(c) W._uav.UIStroke.Color = c end)
    New("Frame", { AnchorPoint = Vector2.new(1, 1), Position = UDim2.fromOffset(44, 44), Size = UDim2.fromOffset(10, 10), BackgroundColor3 = C.Success, Parent = uc }, { Corner(), New("UIStroke", { Color = C.Dark1, Thickness = 2 }) })
    W._unm = Txt(uc, "", 12, { Position = UDim2.fromOffset(50, 5), Size = UDim2.new(1, -56, 0, 14), Font = Enum.Font.GothamBold, TextTruncate = Enum.TextTruncate.AtEnd })
    W._uus = Txt(uc, "", 10, { Position = UDim2.fromOffset(50, 20), Size = UDim2.new(1, -56, 0, 12), TextColor3 = C.Sub, TextTruncate = Enum.TextTruncate.AtEnd })
    W._ust = Txt(uc, "Online", 10, { Position = UDim2.fromOffset(50, 32), Size = UDim2.new(1, -56, 0, 12), TextColor3 = Library.Theme.Accent })
    Bind(function(c) W._ust.TextColor3 = c end)
    W:SetUserCard({})

    W._content = New("Frame", { BackgroundTransparency = 1, Position = UDim2.fromOffset(sideW, 46), Size = UDim2.new(1, -sideW, 1, -46), ClipsDescendants = true, Parent = main })

    -- resize handle
    local rh = New("Frame", { AnchorPoint = Vector2.new(1, 1), Position = UDim2.fromScale(1, 1), Size = UDim2.fromOffset(22, 22), BackgroundTransparency = 1, ZIndex = 20, Parent = main })
    for i = 1, 2 do New("Frame", { AnchorPoint = Vector2.new(.5, .5), Position = UDim2.fromOffset(13, 13), Size = UDim2.fromOffset(i * 6, 2), Rotation = -45, BackgroundColor3 = C.Sub, BorderSizePixel = 0, ZIndex = 20, Parent = rh }) end
    local s0
    DragDelta(rh, function() s0 = main.AbsoluteSize end, function(d)
        main.Size = UDim2.fromOffset(math.clamp(s0.X + d.X, 420, 1000), math.clamp(s0.Y + d.Y, 270, 700))
    end)

    -- tooltip / notifications / toasts
    Library._tip = New("TextLabel", { AutomaticSize = Enum.AutomaticSize.XY, Size = UDim2.fromOffset(0, 0), BackgroundColor3 = C.Dark1, BackgroundTransparency = .1, Text = "", TextSize = 11, Font = Enum.Font.Gotham,
        TextColor3 = C.Text, Visible = false, ZIndex = 200, Parent = gui }, { Corner(6), New("UIPadding", { PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8), PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 4) }), New("UIStroke", { Color = Library.Theme.Accent, Transparency = .4 }) })
    UIS.InputChanged:Connect(function(i) if i.UserInputType == MMV and Library._tip.Visible then Library._tip.Position = UDim2.fromOffset(i.Position.X + 14, i.Position.Y + 14) end end)
    Library._notes = New("Frame", { AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -10, 0, 50), Size = UDim2.fromOffset(210, 400), BackgroundTransparency = 1, Parent = gui }, { List(6) })
    Library._notes.UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Top
    Library._toasts = New("Frame", { AnchorPoint = Vector2.new(.5, 1), Position = UDim2.new(.5, 0, 1, -24), Size = UDim2.fromOffset(300, 100), BackgroundTransparency = 1, Parent = gui }, { List(6) })
    Library._toasts.UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom Library._toasts.UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    -- floating open button: circle + Thunder only
    local fl = New("Frame", { Position = UDim2.fromOffset(16, 90), Size = UDim2.fromOffset(48, 48), BackgroundColor3 = C.Dark1, Parent = gui }, { Corner(), New("UIScale", {}) })
    GlassReg(fl, .2) Glow(fl, 2, .1)
    W._float = fl W._fps = fl.UIScale
    W:SetOpenSize(o.OpenSize or 48)
    local fp, moved = nil, 0
    local fb = New("TextButton", { Text = "", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ZIndex = 5, Parent = fl })
    DragDelta(fb, function() fp = fl.Position moved = 0 end, function(d) moved = math.max(moved, d.Magnitude) fl.Position = UDim2.new(fp.X.Scale, fp.X.Offset + d.X, fp.Y.Scale, fp.Y.Offset + d.Y) end,
        function() if moved < 6 then W:Toggle() end end)
    table.insert(Library._tick, function(dt, t)
        if not fl.Parent then return end
        W._fps.Scale = (not W._vis and not Library.LowFx) and (1 + .06 * math.sin(t * 3)) or 1
    end)
    UIS.InputBegan:Connect(function(i, gp) if not gp and i.KeyCode == (o.ToggleKey or Enum.KeyCode.RightShift) then W:Toggle() end end)

    W._mpanel = BuildMusicPanel(W)
    W:SetVisible(true)

    if o.General ~= false then
        local ok, err = pcall(Library._general, Library, W, o)
        if not ok then warn("[PickasHub] General tab error: " .. tostring(err)) end
    end
    return W
end

---------------------------------------------------------------- General tab
function Library:_general(W, o)
    local gen = W:AddTab({ Title = "General", Icon = "house" })
    local info = gen:AddSubTab({ Title = "Info", Icon = "info" })
    local comm = gen:AddSubTab({ Title = "Community's", Icon = "users" })
    local conf = gen:AddSubTab({ Title = "Configure", Icon = "save" })
    local set = gen:AddSubTab({ Title = "Settings", Icon = "settings" })
    gen._subs[1]:Select()

    info:AddSection({ Title = "Main" })
    info:AddGameCard({})
    local dual = info:AddDual({ Left = { Title = "Session", Value = "00:00:00" }, Right = { Title = "Player", Value = LP.Name } })
    local st = os.time()
    task.spawn(function()
        while dual.Frame.Parent do
            local d = os.time() - st
            dual:SetLeft(string.format("%02d:%02d:%02d", math.floor(d / 3600), math.floor(d % 3600 / 60), d % 60)) task.wait(1)
        end
    end)
    info:AddInfo({ Title = "Version", Value = o.Version or Library.Version })
    local ex = "Unknown" pcall(function() local n, v = identifyexecutor() ex = tostring(n) .. (v and (" " .. tostring(v)) or "") end)
    info:AddInfo({ Title = "Executor", Value = ex })
    local hwid = "Unavailable" pcall(function() hwid = gethwid and gethwid() or game:GetService("RbxAnalyticsService"):GetClientId() end)
    info:AddInfo({ Title = "HWID", Value = hwid, Copy = true })
    info:AddInfo({ Title = "Job ID", Value = game.JobId ~= "" and game.JobId or "Studio", Copy = true })

    comm:AddSection({ Title = "Community's" })
    comm:AddCommunityCard({ Title = "Discord Community", Link = "discord.gg/R3rDNwrV7y", Icon = "discord", Color = Color3.fromRGB(88, 101, 242) })
    comm:AddCommunityCard({ Title = "Telegram Community", Link = "t.me/+MGEV4AC7LEllZDJl", Icon = "telegram", Color = Color3.fromRGB(42, 171, 238) })

    conf:AddSection({ Title = "Configure" })
    local name = conf:AddInput({ Title = "Configure Name", Placeholder = "Put Name" })
    local dd = conf:AddDropdown({ Title = "Select Configure", Options = Library:ListConfigs(), Default = nil })
    local function refresh() dd:SetOptions(Library:ListConfigs()) end
    conf:AddButton({ Title = "Save Configure", Icon = "save", Callback = function()
        local n = name:Get() if Library:SaveConfig(n) then Library:Notify({ Title = "Saved", Content = n, Type = "Success" }) refresh() else Library:Notify({ Title = "Save failed", Content = "Enter a name first.", Type = "Error" }) end end })
    conf:AddButton({ Title = "Load Configure", Icon = "download", Callback = function()
        local n = dd:Get() if n and Library:LoadConfig(n) then Library:Notify({ Title = "Loaded", Content = n, Type = "Success" }) else Library:Notify({ Title = "Load failed", Content = "Select a config.", Type = "Error" }) end end })
    conf:AddButton({ Title = "Delete Configure", Icon = "trash", Callback = function()
        local n = dd:Get() if n then Library:DeleteConfig(n) refresh() dd:Set(nil) Library:Notify({ Title = "Deleted", Content = n, Type = "Warning" }) end end })

    set:AddSection({ Title = "Appearance" })
    set:AddColorpicker({ Title = "Theme Color", Flag = "ThemeColor", Default = Library.Theme.Accent, Callback = function(c) Library:SetAccent(c) end })
    set:AddToggle({ Title = "Rainbow Mode", Flag = "Rainbow", Default = false, Callback = function(v) Library.Rainbow = v if not v then Library:SetAccent(Library.Theme.Accent) end end })
    set:AddSlider({ Title = "Window Transparency", Flag = "WinAlpha", Min = 0, Max = .8, Step = .05, Default = .2, Callback = function(v) Library:SetGlass(v) end })
    set:AddSlider({ Title = "Degree Angles", Flag = "Radius", Min = 4, Max = 24, Default = 16, Callback = function(v) Library:SetRadius(v) end })
    set:AddSlider({ Title = "Open Size", Flag = "OpenSize", Min = 30, Max = 80, Default = 48, Callback = function(v) W:SetOpenSize(v) end })
    set:AddSection({ Title = "Behavior" })
    set:AddToggle({ Title = "Smooth UI Dragging", Flag = "Smooth", Default = true, Callback = function(v) Library.Smooth = v end })
    set:AddToggle({ Title = "Low Effects", Flag = "LowFx", Default = Library.LowFx, Callback = function(v) Library.LowFx = v end })
end

return Library
