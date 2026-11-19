--[==[
    UNNAMED ENHANCEMENTS V3
    built by olivia  //  discord.gg/ojailbreaks
--]==]

----------------------------------------------------------------
-- BOOT
----------------------------------------------------------------
local SAFE_MODE = false
local LOAD_T0   = os.clock()

local HttpService = game:GetService("HttpService")
local Players     = game:GetService("Players")
local RunService  = game:GetService("RunService")
local UIS         = game:GetService("UserInputService")
local Lighting    = game:GetService("Lighting")
local Workspace   = game:GetService("Workspace")
local CoreGui     = game:GetService("CoreGui")
local TweenService= game:GetService("TweenService")
local Stats       = game:GetService("Stats")
local Camera      = Workspace.CurrentCamera
local LP          = Players.LocalPlayer

if getgenv().UE3 and getgenv().UE3.Unload then pcall(getgenv().UE3.Unload) end

local U = {
    Opt={}, Tog={}, Key={}, Con={}, Draw={}, Esp={},
    Char={}, Timings={}, LoadTimings={}, Cost={}, OverrunN=0, Sum={shots=0,hits=0,kills=0},
    _active={}, _activeDirty=true, _inHook=setmetatable({}, {__mode="k"}),
    _observeLog={}, _sig={}, _sigLearned={},
    _pcwState={}, _dmgLog={}, _dpsBucket={}, _selfDrops={}, _attackerHits={}, _hpLast={},
    _pingCache=0, _pingAt=0,
}
getgenv().UE3 = U
local O,T,K,Sum = U.Opt,U.Tog,U.Key,U.Sum

local function C(x) table.insert(U.Con,x); return x end
local function D(x) table.insert(U.Draw,x); return x end
local function pc(f,...) local ok,r=pcall(f,...); return ok and r end
local function trec(name) local t=os.clock(); return function() U.LoadTimings[name]=math.floor((os.clock()-t)*1000+0.5) end end

-- rate-limited pcall for feature ticks (used only via scheduler)
local function pcw(label,f,...)
    local st = U._pcwState[label]; if not st then st={fails=0,lastWarn=0,dead=false}; U._pcwState[label]=st end
    if st.dead then return nil end
    local ok,r = pcall(f,...)
    if not ok then
        st.fails += 1
        local now = os.clock()
        if now - st.lastWarn > 1 then st.lastWarn=now; warn(("[UE3 %s] %s (%d)"):format(label,tostring(r),st.fails)) end
        if st.fails >= 10 then st.dead=true; warn(("[UE3 %s] disabled after 10 throws"):format(label)) end
    else
        if st.fails > 0 then st.fails = math.max(0, st.fails-1) end
    end
    return r
end

----------------------------------------------------------------
-- DEFERRED IO (off critical path)
----------------------------------------------------------------
local CRASH_FILE = "UE3_last_toggle.txt"
local _memFS = {}
local function _isfile(n) local ok,r=pcall(function() return isfile and isfile(n) end); if ok and r then return true end; return _memFS[n]~=nil end
local function _readfile(n) if _memFS[n] then return _memFS[n] end; local ok,r=pcall(function() return readfile and readfile(n) end); return ok and r or nil end
local function _writefile(n,s) _memFS[n]=s; task.defer(function() pcall(function() if writefile then writefile(n,s) end end) end) end
local function _delfile(n) _memFS[n]=nil; task.defer(function() pcall(function() if delfile then delfile(n) end end) end) end

-- crash mark & last-tab are read AFTER first frame — never on critical path
U._crashLoaded = false
local lastCrashedFeature = nil
local lastTabName = nil
local function deferredLoad()
    local ok1,v = pcall(function() return _isfile(CRASH_FILE) and _readfile(CRASH_FILE) end)
    if ok1 and v then lastCrashedFeature = v; _delfile(CRASH_FILE) end
    local ok2,v2 = pcall(function() return _isfile("UE3_last_tab.txt") and _readfile("UE3_last_tab.txt") end)
    if ok2 and v2 then lastTabName = v2 end
    U._crashLoaded = true
    if lastCrashedFeature and T[lastCrashedFeature] ~= nil then T[lastCrashedFeature] = false end
end

local sessionStart = os.clock()
local function recordToggleOnChange(k) U.LastToggle = k; _writefile(CRASH_FILE, k) end
local function clearCrashMark() _delfile(CRASH_FILE) end

----------------------------------------------------------------
-- CHAR CACHE
----------------------------------------------------------------
local function clearCharCache() U.Char = {ch=nil, hrp=nil, hum=nil, head=nil} end
local function rebuildCharCache(ch)
    U.Char = {ch=ch, hrp=ch and ch:FindFirstChild("HumanoidRootPart"), hum=ch and ch:FindFirstChildOfClass("Humanoid"), head=ch and ch:FindFirstChild("Head")}
end
rebuildCharCache(LP.Character)
local function resetOnRespawn()
    if U._pcwState then for _,v in pairs(U._pcwState) do v.dead=false; v.fails=0 end end
    if voidCamAnchor then pcall(function() voidCamAnchor:Destroy() end); voidCamAnchor=nil end
    if fpCamAnchor then pcall(function() fpCamAnchor:Destroy() end); fpCamAnchor=nil end
    if spatialCamAnchor then pcall(function() spatialCamAnchor:Destroy() end); spatialCamAnchor=nil end
    fpSurfacePos = nil; voidShootUntil = 0; fpShootUntil = 0
    spatialRealPos = nil; spatialFakeReal = nil; spatialNextRandTP = 0
    if DF then DF.handoffUntil = 0 end
    U._strafeRestoreAt = 0
end
local function wireDied(ch)
    pcall(function()
        local hum = ch:WaitForChild("Humanoid", 5)
        if hum then C(hum.Died:Connect(clearCharCache)) end
    end)
end
C(LP.CharacterAdded:Connect(function(ch)
    rebuildCharCache(ch); wireDied(ch); resetOnRespawn()
    -- re-ensure cache populated after parts replicate
    task.delay(0.2, function() if ch and ch.Parent then rebuildCharCache(ch) end end)
end))
if LP.Character then wireDied(LP.Character) end

local function alive(p)
    if not p then return false end
    if p==LP then return U.Char.hum and U.Char.hum.Health>0 end
    local ch=p.Character; return ch and ch.Parent and ch:FindFirstChild("HumanoidRootPart") and ch:FindFirstChildOfClass("Humanoid") and ch:FindFirstChildOfClass("Humanoid").Health>0
end
local function enemy(p) if not T.IgnTeam then return true end; return p.Team~=LP.Team end
local function w2s(v) local p,on=Camera:WorldToViewportPoint(v); return Vector2.new(p.X,p.Y),on,p.Z end

----------------------------------------------------------------
-- PALETTE / FONTS
----------------------------------------------------------------
local P = {
    bg      = Color3.fromRGB(7,8,11),
    panel   = Color3.fromRGB(13,15,19),
    panel2  = Color3.fromRGB(16,19,24),
    row     = Color3.fromRGB(19,22,28),
    hover   = Color3.fromRGB(27,31,38),
    line    = Color3.fromRGB(32,37,45),
    tx      = Color3.fromRGB(235,238,243),
    dim     = Color3.fromRGB(128,136,148),
    rd      = Color3.fromRGB(228,86,96),
    yw      = Color3.fromRGB(230,180,60),
    accents = {
        violet  = Color3.fromRGB(150,110,255),
        magenta = Color3.fromRGB(240,80,180),
        cyan    = Color3.fromRGB(80,210,255),
        lime    = Color3.fromRGB(186,255,0),
        amber   = Color3.fromRGB(255,170,40),
        red     = Color3.fromRGB(240,70,80),
    },
}
local accentKeys = {"violet","magenta","cyan","lime","amber","red"}
local accentIdx = 1
local function ac() return P.accents[accentKeys[accentIdx]] end

-- Font.new with bundled rbxasset families; fallback to a non-default enum if not supported
local function safeFontFace(fam, weight)
    local ok, f = pcall(function() return Font.new("rbxasset://fonts/families/"..fam..".json", weight or Enum.FontWeight.Medium) end)
    if ok and f then return f end
    return nil
end
local function safeEnum(name, fallback)
    local ok, v = pcall(function() return Enum.Font[name] end)
    if ok and v then return v end
    return fallback
end
local F = {
    lblFace = safeFontFace("Oxanium", Enum.FontWeight.Medium),
    capFace = safeFontFace("Oxanium", Enum.FontWeight.Bold),
    monoFace= safeFontFace("Inconsolata", Enum.FontWeight.Medium),
    lblEnum = safeEnum("GothamMedium", Enum.Font.Gotham),
    capEnum = safeEnum("GothamBold", Enum.Font.Gotham),
    monoEnum= safeEnum("Code", Enum.Font.SourceSans),
}

local function applyFont(obj, face, en)
    if face then pcall(function() obj.FontFace = face end) else obj.Font = en end
end

----------------------------------------------------------------
-- N helper (fast)
----------------------------------------------------------------
local function N(class, props)
    local o = Instance.new(class)
    for k,v in pairs(props) do
        if k == "Font" then applyFont(o, v.face, v.en)
        elseif k == "Parent" then -- set last
        else o[k] = v end
    end
    if props.Parent then o.Parent = props.Parent end
    return o
end

----------------------------------------------------------------
-- GUI ROOT — detached build, parented at end
----------------------------------------------------------------
local tGui = trec("gui_build")
local Screen = N("ScreenGui",{Name="UE3",ResetOnSpawn=false,IgnoreGuiInset=true,ZIndexBehavior=Enum.ZIndexBehavior.Sibling,DisplayOrder=99})

-- =========== SPLASH / LOADER OVERLAY ===========
-- Full-screen overlay shown first; main UI builds behind it (Root hidden), then crossfade.
local Splash = N("Frame",{
    Size=UDim2.fromScale(1,1), Position=UDim2.new(),
    BackgroundColor3=Color3.fromRGB(8,10,13), BorderSizePixel=0, ZIndex=500, Parent=Screen,
})
local SplashCenter = N("Frame",{
    Size=UDim2.fromOffset(360,80), Position=UDim2.new(0.5,-180,0.5,-40),
    BackgroundTransparency=1, ZIndex=501, Parent=Splash,
})
local SplashTxt = N("TextLabel",{
    Size=UDim2.new(1,0,0,30), Position=UDim2.fromOffset(0,10), BackgroundTransparency=1,
    Text="616 Is Loading", TextSize=22, TextColor3=P.tx, TextXAlignment=Enum.TextXAlignment.Center,
    Font={face=F.capFace,en=F.capEnum}, ZIndex=501, Parent=SplashCenter,
})
local SplashDots = N("TextLabel",{
    Size=UDim2.fromOffset(40,30), Position=UDim2.new(0.5,100,0,10), BackgroundTransparency=1,
    Text="", TextSize=22, TextColor3=ac(), TextXAlignment=Enum.TextXAlignment.Left,
    Font={face=F.capFace,en=F.capEnum}, ZIndex=501, Parent=SplashCenter,
})
local SplashBarBG = N("Frame",{
    Size=UDim2.fromOffset(300,2), Position=UDim2.new(0.5,-150,0,50),
    BackgroundColor3=P.row, BorderSizePixel=0, ZIndex=501, Parent=SplashCenter,
})
local SplashBar = N("Frame",{
    Size=UDim2.fromOffset(0,2), BackgroundColor3=ac(), BorderSizePixel=0, ZIndex=502, Parent=SplashBarBG,
})
local SplashSub = N("TextLabel",{
    Size=UDim2.new(1,0,0,14), Position=UDim2.fromOffset(0,60), BackgroundTransparency=1,
    Text="built by olivia  //  discord.gg/ojailbreaks", TextSize=10, TextColor3=P.dim,
    Font={face=F.monoFace,en=F.monoEnum}, ZIndex=501, Parent=SplashCenter,
})

-- splash drives: 3 second load, animated dots + progress bar
local SPLASH_DURATION = 3.0
local splashStart = os.clock()
task.spawn(function()
    local phases = {".", "..", "..."}
    while Splash.Parent and (os.clock()-splashStart) < SPLASH_DURATION do
        local el = os.clock()-splashStart
        SplashDots.Text = phases[((math.floor(el*3)) % 3) + 1]
        SplashBar.Size = UDim2.fromOffset(300 * math.min(el/SPLASH_DURATION,1), 2)
        task.wait(0.08)
    end
    SplashDots.Text = "..."
    SplashBar.Size = UDim2.fromOffset(300, 2)
end)

local Root = N("Frame",{
    Size=UDim2.fromOffset(620,420),
    Position=UDim2.fromOffset(60,120),
    BackgroundColor3=P.panel,
    BorderSizePixel=0,
    Active=true,
    Visible=false,  -- hidden until splash finishes
    Parent=Screen,
})
N("UICorner",{CornerRadius=UDim.new(0,2),Parent=Root})
N("UIStroke",{Color=P.line,Thickness=1,Transparency=0,Parent=Root})

-- draggable
do
    local dragging, dragStart, startPos
    local header = N("Frame",{Size=UDim2.new(1,0,0,30),BackgroundTransparency=1,Parent=Root,ZIndex=2})
    header.InputBegan:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
            dragging=true; dragStart=input.Position; startPos=Root.Position
        end
    end)
    header.InputEnded:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then dragging=false end
    end)
    UIS.InputChanged:Connect(function(input)
        if not dragging then return end
        if input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch then
            local d=input.Position-dragStart
            Root.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y)
        end
    end)
end

-- TITLE BLOCK (angled accent, one UIGradient)
local TB = N("Frame",{Size=UDim2.new(1,0,0,30),BackgroundColor3=P.bg,BorderSizePixel=0,Parent=Root,ZIndex=1})
local TBAccent = N("Frame",{Size=UDim2.fromOffset(4,30),BackgroundColor3=ac(),BorderSizePixel=0,Parent=TB,ZIndex=2})
local TBGrad = N("UIGradient",{Color=ColorSequence.new{
    ColorSequenceKeypoint.new(0, P.bg),
    ColorSequenceKeypoint.new(0.6, P.bg),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(16,20,26)),
}, Parent=TB})
local TBLine = N("Frame",{Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,1,-1),BackgroundColor3=P.line,BorderSizePixel=0,Parent=TB})

local TitleL = N("TextLabel",{Size=UDim2.fromOffset(240,30),Position=UDim2.fromOffset(16,0),BackgroundTransparency=1,
    Text="UNNAMED ENHANCEMENTS",TextSize=16,TextColor3=P.tx,TextXAlignment=Enum.TextXAlignment.Left,
    Font={face=F.capFace,en=F.capEnum},Parent=TB})
local VerTag = N("TextLabel",{Size=UDim2.fromOffset(40,30),Position=UDim2.fromOffset(238,0),BackgroundTransparency=1,
    Text="v3",TextSize=11,TextColor3=ac(),TextXAlignment=Enum.TextXAlignment.Left,
    Font={face=F.monoFace,en=F.monoEnum},Parent=TB})
local TitleAttrib = N("TextLabel",{Size=UDim2.fromOffset(260,30),Position=UDim2.new(1,-300,0,0),BackgroundTransparency=1,
    Text="built by olivia  //  discord.gg/ojailbreaks",TextSize=10,TextColor3=P.dim,TextXAlignment=Enum.TextXAlignment.Right,
    Font={face=F.monoFace,en=F.monoEnum},Parent=TB})

local CloseX = N("TextButton",{Size=UDim2.fromOffset(28,18),Position=UDim2.new(1,-34,0,6),BackgroundColor3=P.row,BorderSizePixel=0,
    Text="X",TextSize=11,TextColor3=P.rd,AutoButtonColor=false,Font={face=F.lblFace,en=F.lblEnum},Parent=TB})
CloseX.MouseButton1Click:Connect(function() Root.Visible=false end)

-- RAIL (left column)
local Rail = N("Frame",{Position=UDim2.fromOffset(0,30),Size=UDim2.new(0,46,1,-52),BackgroundColor3=P.bg,BorderSizePixel=0,Parent=Root})
N("Frame",{Size=UDim2.new(0,1,1,0),Position=UDim2.new(1,-1,0,0),BackgroundColor3=P.line,BorderSizePixel=0,Parent=Rail})

-- CONTENT CONTAINER
local Content = N("Frame",{Position=UDim2.fromOffset(46,30),Size=UDim2.new(1,-46,1,-52),BackgroundColor3=P.panel,BorderSizePixel=0,ClipsDescendants=true,Parent=Root})

-- SEARCH BOX
local SearchBar = N("Frame",{Size=UDim2.new(1,-16,0,22),Position=UDim2.fromOffset(8,8),BackgroundColor3=P.row,BorderSizePixel=0,Parent=Content,ZIndex=3})
local SearchTB = N("TextBox",{Size=UDim2.new(1,-24,1,0),Position=UDim2.fromOffset(8,0),BackgroundTransparency=1,
    PlaceholderText="search",Text="",TextSize=11,TextColor3=P.tx,PlaceholderColor3=P.dim,TextXAlignment=Enum.TextXAlignment.Left,
    Font={face=F.monoFace,en=F.monoEnum},ClearTextOnFocus=false,Parent=SearchBar,ZIndex=3})

-- STATUS BAR
local SB = N("Frame",{Position=UDim2.new(0,0,1,-22),Size=UDim2.new(1,0,0,22),BackgroundColor3=P.bg,BorderSizePixel=0,Parent=Root})
N("Frame",{Size=UDim2.new(1,0,0,1),BackgroundColor3=P.line,BorderSizePixel=0,Parent=SB})
local sbL = N("TextLabel",{Size=UDim2.new(0.6,0,1,0),BackgroundTransparency=1,TextSize=10,TextColor3=P.dim,TextXAlignment=Enum.TextXAlignment.Left,
    Text="",Font={face=F.monoFace,en=F.monoEnum},Parent=SB})
local sbPad = N("UIPadding",{PaddingLeft=UDim.new(0,8),Parent=sbL})
local sbR = N("TextLabel",{Size=UDim2.new(0.4,-10,1,0),Position=UDim2.new(0.6,0,0,0),BackgroundTransparency=1,TextSize=10,TextColor3=ac(),TextXAlignment=Enum.TextXAlignment.Right,
    Text="",Font={face=F.monoFace,en=F.monoEnum},Parent=SB})
local sbRPad = N("UIPadding",{PaddingRight=UDim.new(0,8),Parent=sbR})

-- resize grip (bottom-right)
local Grip = N("TextButton",{Size=UDim2.fromOffset(14,14),Position=UDim2.new(1,-14,1,-14),BackgroundColor3=P.row,BorderSizePixel=0,
    AutoButtonColor=false,Text="",Parent=Root,ZIndex=5})
N("TextLabel",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,TextColor3=P.dim,TextSize=10,Text="◢",Font={en=F.monoEnum},Parent=Grip})
do
    local rz, start, startSize
    Grip.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then rz=true; start=i.Position; startSize=Root.AbsoluteSize end end)
    Grip.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then rz=false end end)
    UIS.InputChanged:Connect(function(i)
        if not rz then return end
        if i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch then
            local d=i.Position-start
            local w=math.max(480, startSize.X+d.X)
            local h=math.max(320, startSize.Y+d.Y)
            Root.Size=UDim2.fromOffset(w,h)
        end
    end)
end

tGui()

----------------------------------------------------------------
-- WIDGETS
----------------------------------------------------------------
-- ROW: 24px, 6px L pad, label left, control right. Hairline optional (last row of group).
local SPACING = {4,6,8,12,16}
local function groupHeader(parent, name, onCountFn)
    -- 13px caps header, hairline under, live on-count on right
    local wrap = N("Frame",{Size=UDim2.new(1,-16,0,22),BackgroundTransparency=1,Parent=parent})
    local lbl = N("TextLabel",{Size=UDim2.new(1,-40,1,0),BackgroundTransparency=1,Text=string.upper(name),TextSize=13,TextColor3=P.dim,TextXAlignment=Enum.TextXAlignment.Left,
        Font={face=F.capFace,en=F.capEnum},Parent=wrap})
    local cnt = N("TextLabel",{Size=UDim2.new(0,40,1,0),Position=UDim2.new(1,-40,0,0),BackgroundTransparency=1,TextSize=10,TextColor3=ac(),TextXAlignment=Enum.TextXAlignment.Right,
        Font={face=F.monoFace,en=F.monoEnum},Parent=wrap})
    local line = N("Frame",{Size=UDim2.new(1,-16,0,1),BackgroundColor3=P.line,BorderSizePixel=0,Parent=parent})
    N("Frame",{Size=UDim2.new(1,0,0,SPACING[1]),BackgroundTransparency=1,Parent=parent})  -- 4px gap
    return {header=wrap, line=line, onText=cnt, onFn=onCountFn}
end

local function row(parent)
    -- row is a TextButton so it fires MouseEnter/Leave for hover feedback
    local r = N("TextButton",{Size=UDim2.new(1,0,0,24),BackgroundColor3=P.hover,BackgroundTransparency=1,BorderSizePixel=0,
        AutoButtonColor=false,Text="",Parent=parent})
    N("UIPadding",{PaddingLeft=UDim.new(0,6),PaddingRight=UDim.new(0,8),Parent=r})
    r.MouseEnter:Connect(function() r.BackgroundTransparency=0.7 end)
    r.MouseLeave:Connect(function() r.BackgroundTransparency=1 end)
    return r
end

local allRows = {}  -- {row=rowFrame, label=str, tabName=str, group=groupObj, tabIdx=i}
local function addRow(label, parentPane, tabName)
    local r = row(parentPane)
    table.insert(allRows, {row=r, label=label:lower(), tabName=tabName, orig=parentPane})
    return r
end

local function labelLeft(r, text, color)
    return N("TextLabel",{Size=UDim2.new(0.55,0,1,0),BackgroundTransparency=1,Text=text,TextSize=11,TextColor3=color or P.tx,TextXAlignment=Enum.TextXAlignment.Left,
        Font={face=F.lblFace,en=F.lblEnum},Parent=r})
end

local function Toggle(parent,k,label,def,tabName)
    O[k] = O[k]; T[k] = T[k]==nil and (def or false) or T[k]
    local r = addRow(label, parent, tabName); labelLeft(r,label)
    local track = N("Frame",{Size=UDim2.fromOffset(28,14),Position=UDim2.new(1,-28,0.5,-7),BackgroundColor3=P.row,BorderSizePixel=0,Parent=r})
    N("UIStroke",{Color=P.line,Thickness=1,Parent=track})
    local knob  = N("Frame",{Size=UDim2.fromOffset(10,10),Position=UDim2.fromOffset(2,2),BackgroundColor3=P.dim,BorderSizePixel=0,Parent=track})
    N("UICorner",{CornerRadius=UDim.new(0,1),Parent=knob})
    local function render()
        if T[k] then
            TweenService:Create(knob,TweenInfo.new(0.09),{Position=UDim2.fromOffset(16,2),BackgroundColor3=P.bg}):Play()
            track.BackgroundColor3 = ac()
        else
            TweenService:Create(knob,TweenInfo.new(0.09),{Position=UDim2.fromOffset(2,2),BackgroundColor3=P.dim}):Play()
            track.BackgroundColor3 = P.row
        end
    end
    local hit = N("TextButton",{Size=UDim2.fromOffset(28,14),Position=UDim2.new(1,-28,0.5,-7),BackgroundTransparency=1,Text="",AutoButtonColor=false,Parent=r})
    hit.MouseButton1Click:Connect(function()
        T[k] = not T[k]; render()
        recordToggleOnChange(k)
        U._activeDirty = true
    end)
    render()
    return r
end

local function Slider(parent,k,label,def,lo,hi,step,sfx,tabName)
    O[k] = O[k]==nil and def or O[k]
    local r = addRow(label, parent, tabName); labelLeft(r,label)
    local track = N("Frame",{Size=UDim2.fromOffset(120,2),Position=UDim2.new(1,-150,0.5,-1),BackgroundColor3=P.row,BorderSizePixel=0,Parent=r})
    local fill  = N("Frame",{Size=UDim2.new(0,0,1,0),BackgroundColor3=ac(),BorderSizePixel=0,Parent=track})
    local hdl   = N("Frame",{Size=UDim2.fromOffset(6,6),Position=UDim2.new(0,-3,0.5,-3),BackgroundColor3=ac(),BorderSizePixel=0,Parent=track})
    local val   = N("TextLabel",{Size=UDim2.fromOffset(30,24),Position=UDim2.new(1,-30,0.5,-12),BackgroundTransparency=1,Text="",TextSize=11,TextColor3=ac(),TextXAlignment=Enum.TextXAlignment.Right,
        Font={face=F.monoFace,en=F.monoEnum},Parent=r})
    local function setV(v,fine)
        local stepV = fine and (step*0.1) or step
        v = math.round(v/stepV)*stepV
        v = math.clamp(v,lo,hi)
        O[k] = v
        local a = (v-lo)/(hi-lo)
        fill.Size = UDim2.new(a,0,1,0)
        hdl.Position = UDim2.new(a,-3,0.5,-3)
        val.Text = tostring(v)..(sfx or "")
    end
    setV(O[k])
    local hit = N("TextButton",{Size=UDim2.fromOffset(120,14),Position=UDim2.new(1,-150,0.5,-7),BackgroundTransparency=1,Text="",AutoButtonColor=false,Parent=r})
    local dragging = false
    local function fromMouse(x, fine)
        local a = math.clamp((x - track.AbsolutePosition.X)/track.AbsoluteSize.X, 0, 1)
        setV(lo + a*(hi-lo), fine)
    end
    hit.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            dragging=true; fromMouse(i.Position.X, UIS:IsKeyDown(Enum.KeyCode.LeftShift))
        end
    end)
    hit.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=false end
    end)
    UIS.InputChanged:Connect(function(i)
        if not dragging then return end
        if i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch then
            fromMouse(i.Position.X, UIS:IsKeyDown(Enum.KeyCode.LeftShift))
        end
    end)
    return r
end

-- single shared dropdown popup, parented to Screen so it floats above everything
local DDPopup = N("Frame",{Size=UDim2.fromOffset(120,0),BackgroundColor3=P.row,BorderSizePixel=0,
    Visible=false,ZIndex=200,Parent=Screen})
N("UIStroke",{Color=P.line,Thickness=1,Parent=DDPopup})
local DDOpenFor = nil

local DDOpenedAt = 0
local function closeDDPopup()
    DDPopup.Visible = false
    DDOpenFor = nil
    for _,c in ipairs(DDPopup:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
end

-- close popup when clicking outside (only after a 0.15s grace so the same click that opened it can't close it)
C(UIS.InputBegan:Connect(function(i)
    if i.UserInputType ~= Enum.UserInputType.MouseButton1 and i.UserInputType ~= Enum.UserInputType.Touch then return end
    if not DDPopup.Visible then return end
    if os.clock() - DDOpenedAt < 0.15 then return end
    local mp = UIS:GetMouseLocation()
    local pop = DDPopup.AbsolutePosition; local sz = DDPopup.AbsoluteSize
    if mp.X < pop.X or mp.X > pop.X+sz.X or mp.Y < pop.Y or mp.Y > pop.Y+sz.Y then
        task.defer(closeDDPopup)
    end
end))

local function Dropdown(parent,k,label,items,def,tabName)
    O[k] = O[k]==nil and def or O[k]
    local r = addRow(label, parent, tabName); labelLeft(r,label)
    local btn = N("TextButton",{Size=UDim2.fromOffset(120,16),Position=UDim2.new(1,-128,0.5,-8),BackgroundColor3=P.row,BorderSizePixel=0,
        Text=O[k],TextSize=10,TextColor3=P.tx,AutoButtonColor=false,TextXAlignment=Enum.TextXAlignment.Right,
        Font={face=F.monoFace,en=F.monoEnum},Parent=r})
    N("UIStroke",{Color=P.line,Thickness=1,Parent=btn})
    N("UIPadding",{PaddingRight=UDim.new(0,14),Parent=btn})
    -- chevron
    N("TextLabel",{Size=UDim2.fromOffset(10,16),Position=UDim2.new(1,-12,0,0),BackgroundTransparency=1,Text="v",TextSize=10,TextColor3=ac(),Font={face=F.monoFace,en=F.monoEnum},Parent=btn})
    btn.MouseButton1Click:Connect(function()
        if DDOpenFor == btn then closeDDPopup(); return end
        closeDDPopup()
        DDOpenFor = btn
        DDOpenedAt = os.clock()
        local ap = btn.AbsolutePosition; local sz = btn.AbsoluteSize
        DDPopup.Position = UDim2.fromOffset(ap.X, ap.Y + sz.Y)
        DDPopup.Size = UDim2.fromOffset(sz.X, 16*#items)
        for i,v in ipairs(items) do
            local it = N("TextButton",{Size=UDim2.new(1,0,0,16),Position=UDim2.fromOffset(0,(i-1)*16),BackgroundColor3=P.row,BorderSizePixel=0,
                Text=v,TextSize=10,TextColor3=P.tx,AutoButtonColor=false,TextXAlignment=Enum.TextXAlignment.Right,ZIndex=201,
                Font={face=F.monoFace,en=F.monoEnum},Parent=DDPopup})
            N("UIPadding",{PaddingRight=UDim.new(0,6),Parent=it})
            it.MouseEnter:Connect(function() it.BackgroundColor3=P.hover end)
            it.MouseLeave:Connect(function() it.BackgroundColor3=P.row end)
            it.MouseButton1Click:Connect(function()
                O[k]=v; btn.Text=v; closeDDPopup(); U._activeDirty=true
            end)
        end
        DDPopup.Visible = true
    end)
    return r
end

local function keyName(ek) if typeof(ek)=="EnumItem" then return ek.Name end; return tostring(ek) end
local function Keybind(parent,k,label,def,tabName)
    K[k] = K[k] or {k=def, state=false}
    local r = addRow(label, parent, tabName); labelLeft(r,label)
    local chip = N("TextButton",{Size=UDim2.fromOffset(72,16),Position=UDim2.new(1,-80,0.5,-8),BackgroundColor3=P.row,BorderSizePixel=0,
        Text=keyName(K[k].k),TextSize=10,TextColor3=ac(),AutoButtonColor=false,Font={face=F.monoFace,en=F.monoEnum},Parent=r})
    local waiting=false
    chip.MouseButton1Click:Connect(function() waiting=true; chip.Text="..." end)
    C(UIS.InputBegan:Connect(function(i,gp)
        if waiting and i.UserInputType==Enum.UserInputType.Keyboard then K[k].k=i.KeyCode; chip.Text=keyName(i.KeyCode); waiting=false
        elseif not gp and typeof(K[k].k)=="EnumItem" and i.KeyCode==K[k].k then K[k].state=true end
    end))
    C(UIS.InputEnded:Connect(function(i,gp)
        if typeof(K[k].k)=="EnumItem" and i.KeyCode==K[k].k then K[k].state=false end
    end))
    return r
end

local function Button(parent,text,cb,tabName)
    local r = addRow(text, parent, tabName)
    local b = N("TextButton",{Size=UDim2.new(1,-12,0,16),Position=UDim2.fromOffset(6,4),BackgroundColor3=P.row,BorderSizePixel=0,
        Text=text,TextSize=10,TextColor3=P.tx,AutoButtonColor=false,Font={face=F.lblFace,en=F.lblEnum},Parent=r})
    b.MouseEnter:Connect(function() b.BackgroundColor3=ac(); b.TextColor3=P.bg end)
    b.MouseLeave:Connect(function() b.BackgroundColor3=P.row; b.TextColor3=P.tx end)
    b.MouseButton1Click:Connect(cb)
    return r
end

local function Label(parent,text,color,tabName)
    local r = addRow(text, parent, tabName)
    local l = N("TextLabel",{Size=UDim2.new(1,-12,1,0),Position=UDim2.fromOffset(6,0),BackgroundTransparency=1,Text=text,TextSize=11,TextColor3=color or P.dim,TextXAlignment=Enum.TextXAlignment.Left,
        Font={face=F.monoFace,en=F.monoEnum},Parent=r})
    return r, l
end

----------------------------------------------------------------
-- TAB REGISTRY — lazy build
----------------------------------------------------------------
local Tabs = {}   -- ordered list of {name, icon, buildFn, pane, built, groups={}}
local TabByName = {}
local activeTab = nil

local function makePane()
    -- scrolling frame, explicit CanvasSize, no AutomaticCanvasSize
    local pane = N("ScrollingFrame",{
        Size=UDim2.new(1,0,1,-38),
        Position=UDim2.fromOffset(0,38),
        BackgroundTransparency=1,
        BorderSizePixel=0,
        ScrollBarThickness=4,
        ScrollBarImageColor3=P.line,
        CanvasSize=UDim2.new(0,0,0,1200),
        ScrollingDirection=Enum.ScrollingDirection.Y,
        Visible=false,
        Parent=Content,
    })
    N("UIListLayout",{Padding=UDim.new(0,4),SortOrder=Enum.SortOrder.LayoutOrder,Parent=pane})
    N("UIPadding",{PaddingLeft=UDim.new(0,8),PaddingRight=UDim.new(0,8),PaddingTop=UDim.new(0,8),PaddingBottom=UDim.new(0,16),Parent=pane})
    return pane
end

local function PaneHeader(pane, text, onCountFn, tabName)
    local wrap = N("Frame",{Size=UDim2.new(1,-16,0,22),BackgroundTransparency=1,Parent=pane})
    N("TextLabel",{Size=UDim2.new(1,-40,1,0),BackgroundTransparency=1,Text=string.upper(text),TextSize=13,TextColor3=P.dim,TextXAlignment=Enum.TextXAlignment.Left,
        Font={face=F.capFace,en=F.capEnum},Parent=wrap})
    local cnt = N("TextLabel",{Size=UDim2.new(0,60,1,0),Position=UDim2.new(1,-60,0,0),BackgroundTransparency=1,Text="",TextSize=10,TextColor3=ac(),TextXAlignment=Enum.TextXAlignment.Right,
        Font={face=F.monoFace,en=F.monoEnum},Parent=wrap})
    local line = N("Frame",{Size=UDim2.new(1,-16,0,1),BackgroundColor3=P.line,BorderSizePixel=0,Parent=pane})
    N("Frame",{Size=UDim2.new(1,0,0,SPACING[1]),BackgroundTransparency=1,Parent=pane})
    return cnt
end

-- tab button on rail
local function makeRailButton(tabRec, index)
    local b = N("TextButton",{Size=UDim2.fromOffset(44,44),Position=UDim2.fromOffset(1,(index-1)*44),BackgroundColor3=P.bg,BorderSizePixel=0,
        AutoButtonColor=false,Text="",Parent=Rail})
    local bar = N("Frame",{Size=UDim2.fromOffset(3,36),Position=UDim2.fromOffset(0,4),BackgroundColor3=ac(),BorderSizePixel=0,Visible=false,Parent=b,ZIndex=2})
    local ico = N("TextLabel",{Size=UDim2.new(1,0,0,16),Position=UDim2.fromOffset(0,10),BackgroundTransparency=1,Text=tabRec.icon,TextSize=16,TextColor3=P.dim,
        Font={face=F.capFace,en=F.capEnum},Parent=b})
    local lbl = N("TextLabel",{Size=UDim2.new(1,0,0,10),Position=UDim2.fromOffset(0,28),BackgroundTransparency=1,Text=string.upper(tabRec.name:sub(1,4)),TextSize=9,TextColor3=P.dim,
        Font={face=F.monoFace,en=F.monoEnum},Parent=b})
    b.MouseEnter:Connect(function() if activeTab~=tabRec then b.BackgroundColor3=P.hover end end)
    b.MouseLeave:Connect(function() if activeTab~=tabRec then b.BackgroundColor3=P.bg end end)
    tabRec.railButton = b; tabRec.railBar = bar; tabRec.railIco = ico; tabRec.railLbl = lbl
    b.MouseButton1Click:Connect(function() ShowTab(tabRec) end)
end

function ShowTab(rec)
    -- lazy build
    if not rec.built then
        local tBuild = trec("tab_"..rec.name)
        rec.pane = makePane()
        rec.buildFn(rec.pane, rec)
        rec.built = true
        tBuild()
    end
    for _,t in ipairs(Tabs) do
        if t.pane then t.pane.Visible = (t==rec) end
        if t.railButton then
            local active = (t==rec)
            t.railBar.Visible = active
            t.railButton.BackgroundColor3 = active and P.row or P.bg
            t.railIco.TextColor3 = active and ac() or P.dim
            t.railLbl.TextColor3 = active and P.tx or P.dim
        end
    end
    activeTab = rec
    _writefile("UE3_last_tab.txt", rec.name)
end

local function registerTab(name, icon, buildFn)
    local rec = {name=name, icon=icon, buildFn=buildFn, built=false}
    table.insert(Tabs, rec); TabByName[name] = rec
    return rec
end

----------------------------------------------------------------
-- TAB BUILDERS
----------------------------------------------------------------
registerTab("home", "H", function(p, rec)
    PaneHeader(p, "overview")
    Label(p, "v3  //  built by olivia  //  discord.gg/ojailbreaks", ac())
    Label(p, "right-shift : toggle menu   /   shift+drag : fine slider")
    Label(p, "")
    PaneHeader(p, "module health")
    local _,killLbl = Label(p, "all modules: ok", P.tx)
    rec.killLbl = killLbl
    Button(p, "reset module kill-state", function()
        for _,v in pairs(U._pcwState) do v.dead=false; v.fails=0 end
    end)
    PaneHeader(p, "load timings (ms)")
    local _,ltLbl = Label(p, "(waiting for first frame)")
    rec.ltLbl = ltLbl
    PaneHeader(p, "scheduler cost (ms/tick, sorted)")
    local _,costLbl = Label(p, "(idle)")
    rec.costLbl = costLbl
    Button(p, "export observe log", function()
        local out={}; for sig,_ in pairs(U._observeLog) do table.insert(out,sig) end
        _writefile("UE3_observe.txt", table.concat(out,"\n"))
        warn("[UE3] observe log → UE3_observe.txt ("..#out.." sigs)")
    end)
    Button(p, "cycle accent colour", function()
        accentIdx = (accentIdx % #accentKeys) + 1
        -- naive: existing accent children don't recolour live; palette cycles for new elements
        warn("[UE3] accent → "..accentKeys[accentIdx])
    end)
end)

registerTab("rage", "R", function(p)
    PaneHeader(p, "core")
    Toggle(p,"RageOn","enable rage",false,"rage")
    Toggle(p,"Silent","silent aim (no key required)",false,"rage")
    Toggle(p,"HookAll","match ALL remotes (bypass name filter)",false,"rage")
    Toggle(p,"MouseHit","mouse.hit hook",false,"rage")
    Toggle(p,"AutoFire","auto fire (hold-fire stream)",false,"rage")
    Toggle(p,"AutoShoot","trigger on target acquired",false,"rage")
    Slider(p,"AutoShootDelay","trigger delay",40,0,500,10,"ms","rage")
    Toggle(p,"AutoStop","stop velocity on fire",false,"rage")
    Slider(p,"FireRate","fire rate",8,1,25,1,"hz","rage")
    Slider(p,"Fov","fov",150,20,800,10,"","rage")
    Slider(p,"MaxDist","max distance",600,50,3000,10,"s","rage")
    Toggle(p,"FovVis","draw fov circle",false,"rage")
    Keybind(p,"RageKey","rage key",Enum.KeyCode.E,"rage")
    Dropdown(p,"KeyMode","key mode",{"Hold","Toggle","Always"},"Hold","rage")

    PaneHeader(p, "target selection")
    Dropdown(p,"Prio","priority",{"ClosestToCrosshair","ClosestToPlayer","LowestHP","Distance","Random","HighestThreat"},"ClosestToCrosshair","rage")
    Toggle(p,"IgnTeam","ignore teammates",true,"rage")
    Toggle(p,"IgnFriends","ignore friends",false,"rage")
    Toggle(p,"IgnLowHP","ignore <10 hp",false,"rage")
    Toggle(p,"IgnInvis","ignore invisible",true,"rage")
    Toggle(p,"IgnWalls","require line of sight",false,"rage")
    Toggle(p,"LockTgt","lock target until dead",false,"rage")
    Slider(p,"SwitchDly","target switch delay",0,0,1,0.01,"s","rage")

    PaneHeader(p, "hitbox")
    Dropdown(p,"HB","hitbox",{"Head","UpperTorso","Torso","HumanoidRootPart","LowerTorso","RightHand","LeftHand","Multipoint"},"Head","rage")
    Toggle(p,"ForceHS","force head",false,"rage")
    Toggle(p,"ForceBaim","force body-aim",false,"rage")
    Toggle(p,"HBExpand","hitbox expander",false,"rage")
    Slider(p,"HBSize","hitbox size",5,1,30,0.5,"s","rage")
    Toggle(p,"MultiPoint","multipoint scan",false,"rage")
    Slider(p,"MPCount","multipoint samples",3,2,8,1,"","rage")

    PaneHeader(p, "validation")
    Slider(p,"ConeDeg","cone angle",8,1,45,1,"°","rage")
    Dropdown(p,"ConeMode","beyond cone",{"Clamp","Abort","Raw"},"Clamp","rage")
    Slider(p,"HandoffMs","handoff window",60,20,300,5,"ms","rage")
    Toggle(p,"HandoffPing","scale by full ping",false,"rage")
    Slider(p,"HcMin","min hitchance",70,0,100,1,"%","rage")
    Slider(p,"HcSmp","hc samples",6,2,16,1,"","rage")
    Toggle(p,"PredOn","velocity lead",false,"rage")
    Slider(p,"PredF","lead factor",0.14,0,0.5,0.01,"s","rage")
    Toggle(p,"GravityComp","gravity compensation",false,"rage")
    Slider(p,"GravFactor","gravity factor",0.5,0,2,0.05,"","rage")
    Toggle(p,"BTOn","backtrack",false,"rage")
    Slider(p,"BTMs","backtrack ms",200,0,500,10,"ms","rage")

    PaneHeader(p, "resolver")
    Toggle(p,"ResolverOn","enable resolver",false,"rage")
    Dropdown(p,"ResolverMode","mode",{"Static","BruteForce","YawCorrect","Adaptive"},"Adaptive","rage")
    Slider(p,"ResolverStr","correction strength",50,0,100,1,"%","rage")
    Toggle(p,"AntiJitter","defeat jitter",true,"rage")
    Toggle(p,"AntiSpin","defeat spin",true,"rage")
    Toggle(p,"AntiDesync","desync breaker",false,"rage")

    PaneHeader(p, "priority targets")
    Toggle(p,"PrioListOn","prefer listed targets",false,"rage")
    Toggle(p,"PrioListForce","ignore everyone else",false,"rage")
    Button(p, "add target under crosshair", function()
        if curTarget then
            U._prio = U._prio or {}
            U._prio[curTarget.Name] = true
            warn("[UE3 prio] added "..curTarget.Name)
        else warn("[UE3 prio] no target") end
    end,"rage")
    Button(p, "clear priority list", function() U._prio = {}; warn("[UE3 prio] cleared") end,"rage")

    PaneHeader(p, "shot safety")
    Toggle(p,"RiotShield","skip targets behind shield",false,"rage")
    Toggle(p,"AvoidKatana","skip katana deflect",false,"rage")
    Toggle(p,"MinHPCheck","require min hitchance",false,"rage")
    Slider(p,"ShotAttempts","retry attempts",2,1,8,1,"","rage")

    PaneHeader(p, "spatial attack (teleport / orbit / fake pos)")
    Dropdown(p,"AttackPos","position mode",{"Normal","TeleportAbove","Orbit","RandomTeleport","VoidSpam","FakePos"},"Normal","rage")
    Slider(p,"SpatialHeight","height above target",20,-50,100,1,"s","rage")
    Toggle(p,"SpatialFace","always face target",true,"rage")
    Toggle(p,"SpatialCamLock","keep camera at real position",true,"rage")
    Toggle(p,"SpatialFarOK","orbit at any distance (ignore max range)",true,"rage")

    -- Orbit
    Slider(p,"OrbitRadius","orbit radius",15,3,80,0.5,"s","rage")
    Slider(p,"OrbitSpeed","orbit speed",3,0.1,15,0.1,"rad/s","rage")
    Slider(p,"OrbitYaw","orbit vertical offset",5,-50,50,0.5,"s","rage")
    Toggle(p,"OrbitVerticalWobble","vertical wobble",false,"rage")
    Slider(p,"OrbitWobbleAmp","wobble amplitude",4,0,20,0.5,"s","rage")

    -- Random teleport
    Slider(p,"RandTPMin","random tp min range",10,2,100,0.5,"s","rage")
    Slider(p,"RandTPMax","random tp max range",30,2,200,0.5,"s","rage")
    Slider(p,"RandTPRate","random tp rate",5,1,30,1,"hz","rage")
    Toggle(p,"RandTPSphere","sphere (include vertical)",true,"rage")

    -- VoidSpam (now inside rage)
    Slider(p,"VoidDepth","voidspam depth",50,5,500,5,"s","rage")
    Slider(p,"VoidHandMs","voidspam handoff",60,20,300,5,"ms","rage")
    Toggle(p,"VoidNoclip","auto-noclip while voidspamming",true,"rage")

    -- FakePos ragebot
    Dropdown(p,"FakePosDir","fake direction",{"North","South","East","West","Random","Mirror","Above","Below"},"Random","rage")
    Slider(p,"FakePosOffset","fake offset distance",25,5,200,0.5,"s","rage")
    Slider(p,"FakePosRealDist","real position distance from target",6,1,30,0.5,"s","rage")
    Slider(p,"FakePosHandMs","fake pos handoff",80,20,300,5,"ms","rage")
    Toggle(p,"FakePosAutoReturn","snap back to fake after shot",true,"rage")

    PaneHeader(p, "observe / replay")
    Toggle(p,"ObserveOnly","observe mode (log remotes, no swap)",false,"rage")
    Toggle(p,"ObserveAll","observe all remote namecalls",false,"rage")
    Slider(p,"ObserveN","observe cap (unique sigs)",120,16,400,4,"","rage")
    Toggle(p,"ReplayLast","record last fire args",false,"rage")
    Button(p, "replay last captured args (isolated raw)", function()
        local r=U._lastFire; if not r then warn("[UE3 replay] no capture"); return end
        local saved = { Silent=T.Silent, RageOn=T.RageOn, MouseHit=T.MouseHit, VoidOn=T.VoidOn, DFOn=T.DFOn, FPOn=T.FPOn, ObserveOnly=T.ObserveOnly, ObserveAll=T.ObserveAll, ReplayLast=T.ReplayLast }
        T.Silent,T.RageOn,T.MouseHit,T.VoidOn,T.DFOn,T.FPOn,T.ObserveOnly,T.ObserveAll,T.ReplayLast = false,false,false,false,false,false,false,false,false
        U._inHook[r.self] = true
        local okFire, err = pcall(function()
            if r.method=="FireServer" then return r.self:FireServer(table.unpack(r.args,1,r.n))
            else return r.self:InvokeServer(table.unpack(r.args,1,r.n)) end
        end)
        U._inHook[r.self] = nil
        for k,v in pairs(saved) do T[k] = v end
        if not okFire then warn("[UE3 replay] "..tostring(err)) else warn("[UE3 replay] re-fired "..r.sig) end
    end,"rage")
end)

registerTab("anti-aim", "A", function(p)
    PaneHeader(p, "master")
    Toggle(p,"AAOn","enable anti-aim",false,"anti-aim")
    Toggle(p,"AAStand","stand anti-aim",true,"anti-aim")
    Toggle(p,"AAMove","move anti-aim",true,"anti-aim")
    Toggle(p,"AAAir","air anti-aim",true,"anti-aim")
    Toggle(p,"AACrouch","crouch anti-aim",true,"anti-aim")
    Keybind(p,"AAInvert","invert direction",Enum.KeyCode.X,"anti-aim")
    Keybind(p,"AADisable","disable (hold)",Enum.KeyCode.F,"anti-aim")

    PaneHeader(p, "yaw base")
    Dropdown(p,"AABase","base",{"Backwards","AtTarget","Freestand","Jitter","Spin","Random","Zero","Sideways"},"AtTarget","anti-aim")
    Slider(p,"AADesync","desync angle",58,0,60,1,"°","anti-aim")
    Slider(p,"AAYawAdd","yaw add",0,-180,180,1,"°","anti-aim")
    Slider(p,"AAJitterR","jitter range",45,0,180,1,"°","anti-aim")
    Slider(p,"AASpinSpd","spin speed",6,0.1,30,0.1,"rad/s","anti-aim")
    Toggle(p,"AAEdge","edge yaw (map aware)",false,"anti-aim")

    PaneHeader(p, "pitch")
    Toggle(p,"AAPOn","enable pitch",false,"anti-aim")
    Dropdown(p,"AAPitch","pitch mode",{"Down","Up","Zero","Jitter","Random","Fake"},"Down","anti-aim")
    Slider(p,"AAPitchR","pitch random range",89,0,89,1,"°","anti-aim")

    PaneHeader(p, "desync / lby")
    Toggle(p,"LBYBreak","lby breaker",false,"anti-aim")
    Dropdown(p,"LBYMode","lby mode",{"Static","Flicker","Opposite","Delayed"},"Flicker","anti-aim")
    Slider(p,"LBYMs","lby interval",250,50,1000,10,"ms","anti-aim")
    Toggle(p,"FakeLag","fake lag",false,"anti-aim")
    Slider(p,"FakeLagTicks","fake lag ticks",2,1,14,1,"","anti-aim")
    Toggle(p,"Desync","desync torso",false,"anti-aim")
    Slider(p,"DesyncAmt","desync amount",45,0,90,1,"°","anti-aim")

    PaneHeader(p, "on-shot")
    Toggle(p,"OnShot","on-shot flip",false,"anti-aim")
    Dropdown(p,"OnShotMode","on-shot mode",{"Flip","Jitter","Random","OppositeYaw"},"Flip","anti-aim")
    Slider(p,"OnShotMs","on-shot duration",220,50,500,10,"ms","anti-aim")

    PaneHeader(p, "freestand / safety")
    Toggle(p,"Freestand","auto-freestand",false,"anti-aim")
    Slider(p,"FreestandRays","freestand rays",8,4,24,2,"","anti-aim")
    Toggle(p,"SafePoint","safe point only",false,"anti-aim")
    Toggle(p,"AntiBaim","anti body-aim",false,"anti-aim")
    Toggle(p,"AntiBT","anti backtrack",false,"anti-aim")
    Toggle(p,"AARoll","roll (visual confuse)",false,"anti-aim")
    Slider(p,"AARollDeg","roll amount",0,-180,180,1,"°","anti-aim")
end)

registerTab("esp", "E", function(p)
    PaneHeader(p, "master")
    Toggle(p,"EspOn","enable esp",false,"esp")
    Toggle(p,"EspTeamCheck","team-color enemies",true,"esp")
    Toggle(p,"EspSelfIgn","ignore self",true,"esp")
    Slider(p,"EspMaxDist","max draw distance",800,50,3000,10,"s","esp")
    Slider(p,"EspMinDist","min draw distance",0,0,100,1,"s","esp")
    Slider(p,"EspFont","font size",13,8,22,1,"","esp")
    Dropdown(p,"EspRateHz","update rate",{"10","15","20","30","60"},"10","esp")

    PaneHeader(p, "box")
    Toggle(p,"EspBox","box",true,"esp")
    Dropdown(p,"EspBoxS","box style",{"corner","full","outline","3d"},"corner","esp")
    Toggle(p,"EspBoxFill","box fill",false,"esp")
    Slider(p,"EspBoxFillA","fill transparency",0.7,0,1,0.05,"","esp")
    Slider(p,"EspBoxThick","box thickness",1,1,4,1,"","esp")

    PaneHeader(p, "text")
    Toggle(p,"EspName","name",true,"esp")
    Toggle(p,"EspDist","distance",true,"esp")
    Toggle(p,"EspHealthTxt","health number",false,"esp")
    Toggle(p,"EspTool","equipped tool",false,"esp")
    Toggle(p,"EspVelocity","velocity (studs/s)",false,"esp")
    Toggle(p,"EspAmmo","ammo (if exposed)",false,"esp")

    PaneHeader(p, "health")
    Toggle(p,"EspHealth","health bar",true,"esp")
    Dropdown(p,"EspHealthSide","bar side",{"Left","Right","Top","Bottom"},"Left","esp")
    Toggle(p,"EspHealthGrad","gradient color",true,"esp")

    PaneHeader(p, "lines")
    Toggle(p,"EspTracer","tracer",false,"esp")
    Dropdown(p,"EspTracerFrom","tracer origin",{"Bottom","Top","Center","Mouse"},"Bottom","esp")
    Toggle(p,"EspSkel","skeleton",false,"esp")
    Toggle(p,"EspOff","offscreen arrow",false,"esp")
    Slider(p,"EspArrowR","arrow radius",200,50,500,10,"","esp")
    Toggle(p,"EspLookDir","look direction line",false,"esp")

    PaneHeader(p, "chams")
    Toggle(p,"ChamsOn","chams (highlight)",false,"esp")
    Slider(p,"ChamsFillA","fill transparency",0.5,0,1,0.05,"","esp")
    Slider(p,"ChamsOutA","outline transparency",0,0,1,0.05,"","esp")
    Toggle(p,"ChamsXray","through walls only",false,"esp")

    PaneHeader(p, "world esp")
    Toggle(p,"WorldDrops","item drops",false,"esp")
    Toggle(p,"WorldChests","chests / crates",false,"esp")
    Toggle(p,"WorldWarps","warpstones",false,"esp")
end)

registerTab("visuals", "V", function(p)
    PaneHeader(p, "feedback")
    Toggle(p,"HitSoundOn","hit sound",false,"visuals")
    Dropdown(p,"HitSoundPreset","hit sound preset",{"Rust","Metal","Tap","Beep","Custom"},"Rust","visuals")
    Slider(p,"HitSoundVol","hit sound volume",1,0,3,0.1,"","visuals")
    Slider(p,"HitSoundPitch","hit sound pitch",1,0.2,3,0.1,"","visuals")
    Toggle(p,"KillSoundOn","kill sound",false,"visuals")
    Dropdown(p,"KillSoundPreset","kill sound preset",{"Fatality","Ding","Kaboom","Custom"},"Fatality","visuals")

    PaneHeader(p, "damage markers")
    Toggle(p,"DmgMarkerOn","world-space damage numbers",false,"visuals")
    Slider(p,"DmgMarkerDur","marker lifetime",0.7,0.2,3,0.05,"s","visuals")
    Slider(p,"DmgMarkerFloat","float up (studs)",2,0,10,0.5,"","visuals")
    Toggle(p,"DmgMarkerCrit","mark crits (head) differently",true,"visuals")

    PaneHeader(p, "bullet tracers")
    Toggle(p,"TracerOn","draw tracers from barrel to hit",false,"visuals")
    Slider(p,"TracerDur","tracer lifetime",0.25,0.05,2,0.05,"s","visuals")
    Slider(p,"TracerThick","tracer thickness",0.08,0.02,0.4,0.02,"","visuals")

    PaneHeader(p, "target hud")
    Toggle(p,"TargetHudOn","show target info panel",false,"visuals")
    Dropdown(p,"TargetHudPos","hud position",{"TopRight","TopLeft","BottomRight","BottomLeft","Floating"},"TopRight","visuals")

    PaneHeader(p, "world markers")
    Toggle(p,"HitMarkerOn","hit marker (crosshair flash)",false,"visuals")
    Dropdown(p,"HitMarkerStyle","style",{"Cross","Dot","Ring","Burst"},"Cross","visuals")

    PaneHeader(p, "fake pos visualizer")
    Toggle(p,"GhostBoxOn","show ghost of your fake position",false,"visuals")
    Slider(p,"GhostAlpha","ghost transparency",0.5,0,1,0.05,"","visuals")
    Toggle(p,"GhostOutline","outline only",true,"visuals")
end)

registerTab("skin", "S", function(p)
    PaneHeader(p, "skin changer")
    Toggle(p,"SkinOn","enable skin changer",false,"skin")
    Dropdown(p,"SkinTarget","apply to",{"Self","Enemies","Everyone"},"Self","skin")
    Dropdown(p,"SkinSlot","weapon slot",{"Primary","Melee","All"},"All","skin")
    Dropdown(p,"SkinStyle","style",{"Solid","Gradient","Neon","Glass","Chrome","Rainbow"},"Solid","skin")
    Slider(p,"SkinR","color R",186,0,255,1,"","skin")
    Slider(p,"SkinG","color G",255,0,255,1,"","skin")
    Slider(p,"SkinB","color B",0,0,255,1,"","skin")
    Slider(p,"SkinTrans","transparency",0,0,1,0.05,"","skin")
    Slider(p,"SkinReflect","reflectance",0,0,1,0.05,"","skin")
    Toggle(p,"SkinHideMesh","hide mesh (handle only)",false,"skin")
    Toggle(p,"SkinGlow","emission glow",false,"skin")

    PaneHeader(p, "detectors")
    Toggle(p,"StaffDetOn","staff detector",false,"skin")
    Dropdown(p,"StaffAction","on detect",{"Notify","Leave","Evade"},"Notify","skin")
    Toggle(p,"StaffScanName","match by display name",true,"skin")
    Toggle(p,"StaffScanTag","match by developer tag",true,"skin")
end)

registerTab("world", "W", function(p)
    PaneHeader(p, "environment")
    Toggle(p,"NoFog","no fog",false,"world")
    Toggle(p,"FB","fullbright",false,"world")
    Slider(p,"FBV","brightness",2,0,10,0.1,"","world")
    Toggle(p,"NoShadows","no shadows",false,"world")
    Toggle(p,"TimeOfDay","force time of day",false,"world")
    Slider(p,"TimeV","hour",12,0,24,0.5,"","world")
    Toggle(p,"CFov","camera fov override",false,"world")
    Slider(p,"CFovV","fov",90,30,120,1,"°","world")
    Toggle(p,"FovBoost","sprint fov boost",false,"world")
    Slider(p,"FovBoostA","boost amount",10,0,30,1,"","world")

    PaneHeader(p, "movement")
    Toggle(p,"WsOn","walkspeed override",false,"world")
    Slider(p,"Ws","walkspeed",16,8,500,1,"","world")
    Toggle(p,"JpOn","jump power override",false,"world")
    Slider(p,"Jp","jump power",50,10,1000,1,"","world")
    Toggle(p,"InfJump","infinite jump",false,"world")
    Toggle(p,"Noclip","noclip",false,"world")
    Toggle(p,"AutoBhop","auto bunnyhop",false,"world")
    Toggle(p,"Fly","fly",false,"world")
    Slider(p,"FlySpd","fly speed",60,10,300,5,"","world")
    Keybind(p,"FlyKey","fly key",Enum.KeyCode.F,"world")

    PaneHeader(p, "camera")
    Toggle(p,"TPCam","third person",false,"world")
    Slider(p,"TPDist","third person distance",10,5,40,0.5,"s","world")
    Toggle(p,"FreeCam","free camera",false,"world")
    Keybind(p,"FreeCamKey","free camera key",Enum.KeyCode.Backslash,"world")
    Toggle(p,"NoSway","no camera sway",false,"world")
    Toggle(p,"NoRecoil","no recoil",false,"world")
    Toggle(p,"NoSpread","no spread",false,"world")

    PaneHeader(p, "session")
    Toggle(p,"AntiAfk","anti-afk",false,"world")
    Toggle(p,"AutoRejoin","auto rejoin on disconnect",false,"world")
    Toggle(p,"FpsCap","frame limiter",false,"world")
    Slider(p,"FpsCapV","limit",120,30,240,5,"","world")
    Toggle(p,"Watermark","watermark",true,"world")
end)

----------------------------------------------------------------
-- EXTRAS TAB (feature parity surface mapped to originals)
----------------------------------------------------------------
registerTab("extras", "X", function(p)
    PaneHeader(p, "aim extensions")
    Toggle(p,"Trigger","triggerbot",false,"extras")
    Slider(p,"TriggerCd","trigger cooldown",0.1,0.02,1,0.02,"s","extras")
    Slider(p,"TriggerRange","trigger range",500,50,1500,25,"","extras")
    Dropdown(p,"TargetPriority","target priority",{"Closest","LowestHP","FOV","Crosshair"},"Closest","extras")
    Toggle(p,"AutoPeek","auto peek",false,"extras")
    Slider(p,"AutoPeekDist","peek distance",8,2,40,0.5,"s","extras")
    Keybind(p,"AutoPeekKey","peek key",Enum.KeyCode.E,"extras")
    Toggle(p,"AutoPrefire","auto prefire",false,"extras")
    Slider(p,"PrefireAngle","prefire angle",15,5,45,1,"°","extras")

    PaneHeader(p, "anti-aim extensions")
    Dropdown(p,"AAYawMode","yaw mode",{"None","Random","Spin","Backwards","Left","Right","Jitter","Sway","Custom"},"None","extras")
    Slider(p,"AAYawCustom","custom yaw",0,-180,180,1,"°","extras")
    Dropdown(p,"AAPitchMode","pitch mode",{"None","Up","Down","Zero","Random"},"None","extras")
    Toggle(p,"Spinbot","spinbot",false,"extras")
    Slider(p,"SpinSpd","spin speed",360,60,1440,30,"°/s","extras")
    Toggle(p,"FakeLag","fake lag",false,"extras")
    Slider(p,"FakeLagTicks","fake lag ticks",3,1,14,1,"","extras")
    Toggle(p,"HitboxDesync","hitbox orientation desync",false,"extras")

    PaneHeader(p, "procedural crosshair")
    Toggle(p,"CrossOn","crosshair",false,"extras")
    Dropdown(p,"CrossStyle","style",{"Plus","Dot","Circle","T","Gap","Square"},"Plus","extras")
    Slider(p,"CrossSize","size",8,2,40,1,"px","extras")
    Slider(p,"CrossGap","gap",4,0,20,1,"px","extras")
    Slider(p,"CrossThick","thickness",1,1,6,1,"px","extras")
    Toggle(p,"CrossOutline","outline",true,"extras")
    Toggle(p,"HeadDot","head dot",false,"extras")
    Slider(p,"HeadDotSize","head dot size",3,1,10,1,"px","extras")

    PaneHeader(p, "world lighting modulation")
    Toggle(p,"Ambient","ambient override",false,"extras")
    Slider(p,"AmbientR","ambient r",128,0,255,1,"","extras")
    Slider(p,"AmbientG","ambient g",128,0,255,1,"","extras")
    Slider(p,"AmbientB","ambient b",128,0,255,1,"","extras")
    Toggle(p,"OutAmbient","outdoor ambient override",false,"extras")
    Toggle(p,"FogOverride","fog override",false,"extras")
    Slider(p,"FogEnd","fog end",10000,50,10000,50,"","extras")
    Toggle(p,"AtmOn","atmosphere override",false,"extras")
    Slider(p,"AtmDensity","atmosphere density",0.3,0,1,0.01,"","extras")
    Toggle(p,"CCOn","color correction",false,"extras")
    Slider(p,"CCSat","saturation",0,-1,1,0.05,"","extras")
    Slider(p,"CCContrast","contrast",0,-1,1,0.05,"","extras")
    Slider(p,"CCBright","brightness",0,-1,1,0.05,"","extras")

    PaneHeader(p, "esp extended")
    Toggle(p,"EspSkeleton","skeleton",false,"extras")
    Toggle(p,"EspArmor","armor bar",false,"extras")
    Toggle(p,"EspWeapon","weapon name",false,"extras")
    Toggle(p,"EspArrow","off-screen arrow",false,"extras")
    Slider(p,"EspArrowRad","arrow radius",180,80,400,10,"px","extras")
    Toggle(p,"EspDistance","distance text",false,"extras")
    Toggle(p,"EspSight","line of sight tint",false,"extras")
    Toggle(p,"ChamsAsync","async wallcheck chams",false,"extras")
    Dropdown(p,"ChamsStyle","chams style",{"Solid","Flat","Glow","ForceField","Wire"},"Solid","extras")

    PaneHeader(p, "tracers suite")
    Toggle(p,"TracerOn","bullet tracer",false,"extras")
    Slider(p,"TracerThick","tracer thickness",0.08,0.02,0.4,0.01,"","extras")
    Slider(p,"TracerDur","tracer duration",0.25,0.05,2,0.05,"s","extras")
    Toggle(p,"HitMarkerOn","hit marker",false,"extras")
    Slider(p,"HitMarkerDur","hit marker duration",0.15,0.05,0.6,0.01,"s","extras")

    PaneHeader(p, "exploits suite")
    Toggle(p,"InfStamina","infinite stamina",false,"extras")
    Toggle(p,"FastReload","fast reload",false,"extras")
    Toggle(p,"InstantHit","instant hit",false,"extras")
    Toggle(p,"WalkOnWater","walk on water",false,"extras")
    Toggle(p,"AntiAim","anti-aim master",false,"extras")
    Toggle(p,"ClientFreeze","client-only freeze enemy",false,"extras")

    PaneHeader(p, "staff detector")
    Toggle(p,"StaffDetectOn","staff detector",false,"extras")
    Dropdown(p,"StaffAction","on detect",{"Notify","Leave","Evade","ServerHop"},"Notify","extras")

    PaneHeader(p, "fake position engine")
    Toggle(p,"GhostBoxOn","ghost box visualizer",false,"extras")
    Dropdown(p,"AttackPos","attack position",{"Normal","TeleportAbove","Orbit","RandomTeleport","VoidSpam","FakePos"},"Normal","extras")
    Slider(p,"OrbitRadius","orbit radius",10,2,40,0.5,"s","extras")
    Slider(p,"OrbitSpd","orbit speed",2,0.2,10,0.2,"","extras")
    Slider(p,"TPAboveDist","tp-above height",8,3,30,0.5,"s","extras")
    Slider(p,"RandTPRadius","random-tp radius",15,5,40,0.5,"s","extras")

    PaneHeader(p, "config / menu")
    Keybind(p,"MenuKey","toggle menu",Enum.KeyCode.RightShift,"extras")
    Dropdown(p,"ConfigSlot","config slot",{"1","2","3","4","5"},"1","extras")
    Button(p,"save config", function()
        if writefile then pcall(function() writefile("UE3_cfg_"..(O.ConfigSlot or "1")..".json", HttpService:JSONEncode({T=T,O=O})) end) end
    end,"extras")
    Button(p,"load config", function()
        if readfile then pcall(function()
            local raw = readfile("UE3_cfg_"..(O.ConfigSlot or "1")..".json")
            local decoded = HttpService:JSONDecode(raw)
            for k,v in pairs(decoded.T or {}) do T[k]=v end
            for k,v in pairs(decoded.O or {}) do O[k]=v end
        end) end
    end,"extras")
    Button(p,"server hop", function()
        pcall(function()
            local TS = game:GetService("TeleportService")
            TS:Teleport(game.PlaceId, LP)
        end)
    end,"extras")
    Button(p,"rejoin server", function()
        pcall(function()
            local TS = game:GetService("TeleportService")
            TS:TeleportToPlaceInstance(game.PlaceId, game.JobId, LP)
        end)
    end,"extras")
    Toggle(p,"RainbowOn","rainbow accent",false,"extras")
    Slider(p,"RainbowSpd","rainbow speed",0.2,0.05,2,0.05,"","extras")

    PaneHeader(p, "translocator")
    Toggle(p,"TranslocOn","translocator",false,"extras")
    Keybind(p,"TranslocMarkKey","drop mark",Enum.KeyCode.G,"extras")
    Keybind(p,"TranslocBlinkKey","blink to mark",Enum.KeyCode.H,"extras")
    Dropdown(p,"TranslocMode","blink mode",{"Instant","Smooth","Echo"},"Instant","extras")
    Slider(p,"TranslocTime","smooth time",0.15,0.05,1,0.05,"s","extras")
    Slider(p,"TranslocCd","cooldown",0.4,0,3,0.05,"s","extras")
    Toggle(p,"TranslocShowMark","show mark",true,"extras")
    Toggle(p,"TranslocClearVel","zero velocity on blink",true,"extras")
    Button(p,"clear mark", function()
        if U._translocMarkPart then pcall(function() U._translocMarkPart:Destroy() end); U._translocMarkPart=nil end
        U._translocMark=nil
    end,"extras")

    PaneHeader(p, "anti-translocator")
    Toggle(p,"AntiTranslocOn","anti-translocator",false,"extras")
    Slider(p,"AntiTranslocDist","jump threshold",25,8,120,1,"s","extras")
    Dropdown(p,"AntiTranslocAct","on detect",{"Notify","Trace","Ignore"},"Trace","extras")
    Slider(p,"AntiTranslocTrace","trace duration",2,0.5,10,0.5,"s","extras")
    Toggle(p,"AntiTranslocHUD","show on HUD",true,"extras")
end)

----------------------------------------------------------------
-- RAIL WIRE-UP + synchronous first tab show
----------------------------------------------------------------
if #Tabs == 0 then warn("[UE3] no tabs registered — menu will be blank") end
for i,t in ipairs(Tabs) do makeRailButton(t,i) end
-- Show the first tab RIGHT NOW so the pane is never empty regardless of deferred load.
-- First tab builds during the splash window (behind the overlay), then revealed.
task.delay(SPLASH_DURATION * 0.4, function()
    if Tabs[1] then pcall(ShowTab, Tabs[1]) end
end)
-- Splash fade-out + Root fade-in once the load window ends.
task.delay(SPLASH_DURATION, function()
    Root.Visible = true
    -- fade Root in from transparent
    Root.BackgroundTransparency = 1
    TweenService:Create(Root, TweenInfo.new(0.25), {BackgroundTransparency=0}):Play()
    -- fade splash out
    TweenService:Create(Splash, TweenInfo.new(0.35), {BackgroundTransparency=1}):Play()
    TweenService:Create(SplashTxt, TweenInfo.new(0.35), {TextTransparency=1}):Play()
    TweenService:Create(SplashDots, TweenInfo.new(0.35), {TextTransparency=1}):Play()
    TweenService:Create(SplashSub, TweenInfo.new(0.35), {TextTransparency=1}):Play()
    TweenService:Create(SplashBarBG, TweenInfo.new(0.35), {BackgroundTransparency=1}):Play()
    TweenService:Create(SplashBar, TweenInfo.new(0.35), {BackgroundTransparency=1}):Play()
    task.delay(0.4, function() if Splash then Splash:Destroy() end end)
end)
warn(("[UE3] %d tabs built, rail wired, first tab = %s"):format(#Tabs, Tabs[1] and Tabs[1].name or "nil"))

-- tab cycle key
local tabCycleKey = Enum.KeyCode.Tab
C(UIS.InputBegan:Connect(function(i,gp)
    if gp then return end
    if i.KeyCode == tabCycleKey and Root.Visible then
        local idx = 1
        for j,t in ipairs(Tabs) do if t==activeTab then idx=j break end end
        local next = Tabs[(idx % #Tabs) + 1]
        ShowTab(next)
    end
end))

-- scroll-wheel over the rail
Rail.InputChanged:Connect(function(i)
    if i.UserInputType ~= Enum.UserInputType.MouseWheel then return end
    local idx=1; for j,t in ipairs(Tabs) do if t==activeTab then idx=j break end end
    local dir = i.Position.Z > 0 and -1 or 1
    local nextIdx = ((idx-1+dir) % #Tabs) + 1
    ShowTab(Tabs[nextIdx])
end)

----------------------------------------------------------------
-- SEARCH: jump-to-tab, flash row (not filter)
----------------------------------------------------------------
SearchTB:GetPropertyChangedSignal("Text"):Connect(function()
    local q = SearchTB.Text:lower()
    if #q < 2 then return end
    for _,r in ipairs(allRows) do
        if r.label:find(q,1,true) then
            local rec = TabByName[r.tabName]
            if rec then
                ShowTab(rec)
                task.defer(function()
                    local f = r.row
                    if not f or not f.Parent then return end
                    local pane = rec.pane
                    pane.CanvasPosition = Vector2.new(0, math.max(0, f.AbsolutePosition.Y - pane.AbsolutePosition.Y - 40))
                    -- flash row 3x
                    for _=1,3 do
                        local tw = TweenService:Create(f, TweenInfo.new(0.12), {BackgroundTransparency=0, BackgroundColor3=ac()})
                        f.BackgroundTransparency = 0; tw:Play(); task.wait(0.14)
                        f.BackgroundTransparency = 1; task.wait(0.14)
                    end
                end)
            end
            return
        end
    end
end)

----------------------------------------------------------------
-- PARENT the GUI (single assignment, deferred first open)
----------------------------------------------------------------
pcall(function() if syn and syn.protect_gui then syn.protect_gui(Screen) end end)
local parented = false
local function tryParent(fn)
    if parented then return end
    local ok,tg = pcall(fn); if ok and tg then local ok2 = pcall(function() Screen.Parent=tg end); if ok2 then parented=true end end
end
tryParent(function() return gethui and gethui() end)
tryParent(function() return CoreGui end)
tryParent(function() return LP:WaitForChild("PlayerGui",5) end)
C(LP.CharacterAdded:Connect(function()
    task.defer(function()
        if Screen and not Screen.Parent then
            local pg = LP:FindFirstChildOfClass("PlayerGui"); if pg then pcall(function() Screen.Parent=pg end) end
        end
    end)
end))

-- menu toggle key
C(UIS.InputBegan:Connect(function(i,gp)
    if gp then return end
    if i.KeyCode == Enum.KeyCode.RightShift then Root.Visible = not Root.Visible end
end))

-- deferred crash-mark / last-tab restore (first tab already shown synchronously above)
task.defer(function()
    local tLoad = trec("deferred_load")
    deferredLoad()
    tLoad()
    if lastTabName and TabByName[lastTabName] and TabByName[lastTabName] ~= activeTab then
        pcall(ShowTab, TabByName[lastTabName])
    end
end)

----------------------------------------------------------------
if SAFE_MODE then
    sbL.Text = "SAFE MODE — GUI only"
    U.Unload = function()
        for _,c in ipairs(U.Con) do pcall(function() c:Disconnect() end) end
        pcall(function() Screen:Destroy() end); clearCrashMark(); getgenv().UE3=nil
    end
    U.LoadTimings.total = math.floor((os.clock()-LOAD_T0)*1000+0.5)
    warn(("[UE3] safe-mode load %dms"):format(U.LoadTimings.total))
    return
end
----------------------------------------------------------------

----------------------------------------------------------------
-- BACKTRACK
----------------------------------------------------------------
U.BT = {}
local function bt_push(p)
    if not alive(p) then return end
    local hrp=p.Character.HumanoidRootPart; local buf=U.BT[p] or {}; U.BT[p]=buf
    table.insert(buf,1,{t=os.clock(),pos=hrp.Position})
    while buf[#buf] and os.clock()-buf[#buf].t>0.5 do buf[#buf]=nil end
end
local function bt_sample(p,ms) local buf=U.BT[p]; if not buf then return nil end; local tg=os.clock()-ms/1000; for _,r in ipairs(buf) do if r.t<=tg then return r end end; return buf[1] end

----------------------------------------------------------------
-- RAGE + HOOK
----------------------------------------------------------------
local aimPos, curTarget, lastSwitch, lastShotAt = nil,nil,0,0

local function bestHitbox(ch)
    local n = T.ForceHS and "Head" or (O.HB or "Head")
    return ch:FindFirstChild(n) or ch:FindFirstChild("HumanoidRootPart")
end

local function pickTarget()
    local kk = K.RageKey
    -- Silent aim ignores key mode entirely: if silent is on, we always pick a target.
    -- Rage-only still respects the key (so you can press E to burst).
    local silentBypass = T.Silent
    if not silentBypass then
        if not kk then return nil end
        if O.KeyMode=="Hold" and not kk.state then return nil end
        if O.KeyMode=="Toggle" and not kk.state then return nil end
    end
    if T.LockTgt and curTarget and alive(curTarget) and enemy(curTarget) then return curTarget end
    local m = UIS:GetMouseLocation(); local prio = O.Prio; local best, bs
    U._prio = U._prio or {}
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=LP and alive(p) and enemy(p) then
            if T.PrioListForce and not U._prio[p.Name] then continue end
            -- skip targets behind a shield facing us
            if T.RiotShield then
                local ch = p.Character
                local holding = ch and ch:FindFirstChildOfClass("Tool")
                if holding and (holding.Name:lower():find("shield") or holding.Name:lower():find("riot")) then
                    local hrp = ch:FindFirstChild("HumanoidRootPart")
                    if hrp and U.Char.hrp then
                        local toMe = (U.Char.hrp.Position - hrp.Position).Unit
                        local faceAlign = hrp.CFrame.LookVector:Dot(toMe)
                        if faceAlign > 0.3 then continue end
                    end
                end
            end
            local pt = bestHitbox(p.Character)
            if pt then
                local s,on = w2s(pt.Position); local d3 = (pt.Position-Camera.CFrame.Position).Magnitude
                local distOK = d3 <= (O.MaxDist or 600)
                local spatial = T.RageOn and (O.AttackPos or "Normal") ~= "Normal"
                if T.SpatialFarOK and spatial then distOK = true; on = true end
                if on and distOK then
                    local d2 = (s-m).Magnitude
                    local fovOK = d2 <= (O.Fov or 150)
                    if T.SpatialFarOK and spatial then fovOK = true end
                    if fovOK then
                        local sc
                        if prio=="ClosestToCrosshair" then sc=d2
                        elseif prio=="ClosestToPlayer" then sc=d3
                        elseif prio=="LowestHP" then local h=p.Character:FindFirstChildOfClass("Humanoid"); sc = h and h.Health or 100
                        elseif prio=="Distance" then sc=d3
                        else sc=math.random() end
                        -- priority list bias: subtract a large bonus so listed names win unless they're far worse
                        if T.PrioListOn and U._prio[p.Name] then sc = sc - 10000 end
                        if not bs or sc<bs then bs,best = sc,p end
                    end
                end
            end
        end
    end
    return best
end

----------------------------------------------------------------
-- FOV CIRCLE
----------------------------------------------------------------
local fovCircle = nil
local function fovTick()
    if T.FovVis and (T.RageOn or T.Silent) then
        if not fovCircle then
            fovCircle = Drawing.new("Circle")
            fovCircle.Thickness = 1; fovCircle.NumSides = 64; fovCircle.Filled = false
            D(fovCircle)
        end
        local vp = Camera.ViewportSize
        fovCircle.Position = Vector2.new(vp.X/2, vp.Y/2)
        fovCircle.Radius = O.Fov or 150
        fovCircle.Color = ac()
        fovCircle.Visible = true
    else
        if fovCircle then fovCircle.Visible = false end
    end
end

----------------------------------------------------------------
-- FIRE (auto / trigger)
----------------------------------------------------------------
local lastFireAt = 0
local targetAcquiredAt = 0
local prevTarget = nil
local function doFire()
    local now = os.clock(); local rate = 1/(O.FireRate or 8)
    if now - lastFireAt < rate then return end
    lastFireAt = now
    Sum.shots = Sum.shots + 1
    if T.AutoStop and U.Char.hrp then
        pc(function() local v=U.Char.hrp.AssemblyLinearVelocity; U.Char.hrp.AssemblyLinearVelocity=Vector3.new(0,v.Y,0) end)
    end
    if T.CounterStrafe and U.counterStrafeOnFire then U.counterStrafeOnFire() end
    pc(function() local t = LP.Character and LP.Character:FindFirstChildOfClass("Tool"); if t then t:Activate() end end)
    pc(function() if mouse1press then mouse1press(); task.wait(); mouse1release() end end)
end

local function fireTick()
    if not aimPos or not curTarget then
        prevTarget = nil; targetAcquiredAt = 0; return
    end
    if curTarget ~= prevTarget then
        prevTarget = curTarget
        targetAcquiredAt = os.clock()
    end
    if T.AutoFire then doFire(); return end
    if T.AutoShoot then
        local wait = (O.AutoShootDelay or 40)/1000
        if os.clock() - targetAcquiredAt >= wait then doFire() end
    end
end

local function aimTick()
    if not (T.RageOn or T.Silent) then curTarget=nil; aimPos=nil; return end
    local nt = pickTarget()
    if not nt then curTarget=nil; aimPos=nil; return end
    if curTarget ~= nt then if os.clock()-lastSwitch < 0 then return end; lastSwitch=os.clock() end
    curTarget = nt
    local pt = bestHitbox(nt.Character); if not pt then aimPos=nil; return end
    local p = pt.Position
    if T.BTOn then local rec = bt_sample(nt, O.BTMs or 200); if rec then p=rec.pos end end
    if T.PredOn then p = p + pt.AssemblyLinearVelocity*(O.PredF or 0.14) end
    aimPos = p
end

-- hook helpers
local function typeSig(args,n) local t={}; for i=1,n do t[i]=typeof(args[i]) end; return table.concat(t,",") end
local function safeUp(dir, camUp) if math.abs(dir:Dot(Vector3.yAxis))>0.99 then return camUp.Unit end; return Vector3.yAxis end
local function coneHandle(origin, aim, coneRad, mode)
    local toAim = aim-origin; local dist = toAim.Magnitude
    if dist<0.001 then return aim, Camera.CFrame.LookVector, dist, "inside" end
    local dir = toAim/dist; local look = Camera.CFrame.LookVector
    local cosA = math.clamp(look:Dot(dir),-1,1); local maxCos = math.cos(coneRad)
    if cosA >= maxCos then return aim, dir, dist, "inside" end
    if mode=="Abort" then return nil,nil,dist,"abort" end
    if mode=="Raw"   then return aim, dir, dist, "raw" end
    local axis = look:Cross(dir)
    if axis.Magnitude < 1e-4 then axis = look:Cross(Vector3.yAxis); if axis.Magnitude<1e-4 then axis=look:Cross(Vector3.xAxis) end end
    axis = axis.Unit
    local cd = (CFrame.fromAxisAngle(axis, coneRad) * look).Unit
    return origin + cd*dist, cd, dist, "clamped"
end

local function readPingSec()
    local now = os.clock()
    if now - U._pingAt < 1.0 then return U._pingCache end
    U._pingAt = now
    local p = 0
    pcall(function()
        local nw=Stats:FindFirstChild("Network"); if not nw then return end
        local si=nw:FindFirstChild("ServerStatsItem"); if not si then return end
        local pp=si:FindFirstChild("Data Ping"); if not pp or not pp.GetValueString then return end
        local s = pp:GetValueString(); local v = s and tonumber(s:match("%d+"))
        if v and v>0 then p=v end
    end)
    if p<20 then p=20 end
    U._pingCache = p/1000
    return U._pingCache
end

local function learnSig(sig, args, n, origin)
    if U._sigLearned[sig] then return U._sig[sig] end
    local known = {dirCount=0, v3Count=0}
    local bestD = -1
    for i=1,n do
        local tt = typeof(args[i])
        if tt=="Vector3" then
            local m = args[i].Magnitude
            known.v3Count += 1
            if m > 2 then
                local d = (args[i]-origin).Magnitude
                if d > bestD then bestD=d; known.pos=i end
            elseif m <= 1.5 and m > 0.1 then
                if not known.dir then known.dir=i end
                known.dirCount += 1
            end
        elseif tt=="CFrame" and not known.cf then known.cf=i
        elseif tt=="Ray" and not known.ray then known.ray=i end
    end
    U._sig[sig] = known; U._sigLearned[sig] = true
    return known
end

-- STAGGERED HOOK INSTALL: metatable + Mouse.Hit come online after the splash ends.
task.delay(SPLASH_DURATION, function()
local mt = getrawmetatable and getrawmetatable(game)
if mt and setreadonly then
    pc(setreadonly, mt, false)
    local oldIdx = mt.__index
    local oldNc  = mt.__namecall
    local observeCount = 0

    -- cached per-Instance "is this a fire remote" result so we don't lower()+9*find() every call
    local fireNameCache = setmetatable({}, {__mode="k"})
    local function isFireRemote(inst)
        local v = fireNameCache[inst]
        if v ~= nil then return v end
        local nm = (inst.Name or ""):lower()
        v = (nm:find("fire") or nm:find("shoot") or nm:find("weapon") or nm:find("bullet") or nm:find("hit") or nm:find("damage") or nm:find("gun") or nm:find("raycast")) and true or false
        fireNameCache[inst] = v
        return v
    end

    mt.__namecall = newcclosure(function(self, ...)
        -- ULTRA-FAST DEAD PATH: when every swap/observe flag is off, pass through without ANY work.
        -- This is the hot path that games hit thousands of times per second.
        if not (T.Silent or T.RageOn or T.ObserveOnly or T.ObserveAll) then
            return oldNc(self, ...)
        end
        if typeof(self)~="Instance" then return oldNc(self,...) end
        if U._inHook[self] then return oldNc(self,...) end
        local method = getnamecallmethod()
        if method ~= "FireServer" and method ~= "InvokeServer" then return oldNc(self,...) end

        -- observe (still gated; only runs if an observe flag is on)
        if T.ObserveOnly or T.ObserveAll then
            local cls = tostring(self.ClassName)
            if cls:find("Remote") then
                local args = {...}; local n = select("#", ...)
                local sig = ("%s::%s(%d)[%s]"):format(cls, self.Name, n, typeSig(args,n))
                if not U._observeLog[sig] and observeCount < (O.ObserveN or 120) then
                    observeCount += 1; U._observeLog[sig] = true
                    warn(("[UE3 OBSERVE] %s"):format(sig))
                    pcall(learnSig, sig, args, n, Camera.CFrame.Position)
                end
            end
            if T.ObserveOnly then return oldNc(self,...) end
        end

        -- past here only runs with Silent/Rage on. Fast-reject non-fire remotes via cache.
        if not aimPos then return oldNc(self,...) end
        -- HookAll bypasses the name filter: every RemoteEvent/RemoteFunction becomes a swap candidate.
        -- Use when the game uses opaque names like "e", "r1", or hashed ids.
        if not T.HookAll then
            if not isFireRemote(self) then return oldNc(self,...) end
        else
            local cls = tostring(self.ClassName)
            if not cls:find("Remote") then return oldNc(self,...) end
        end

        local args = {...}
        local n = select("#", ...)
        local sig = ("%s|%d|%s"):format(self.Name, n, typeSig(args,n))
        if T.ReplayLast then
            local raw={}; for i=1,n do raw[i]=args[i] end
            U._lastFire = {self=self, method=method, args=raw, n=n, sig=self.Name.."|"..n}
        end
        local origin = Camera.CFrame.Position
        local coneRad = math.rad(O.ConeDeg or 8)
        local coneMode = O.ConeMode or "Clamp"
        local clamped, dir, dist, state = coneHandle(origin, aimPos, coneRad, coneMode)
        if state == "abort" then return oldNc(self,...) end
        local camUp = Camera.CFrame.UpVector
        local known = U._sig[sig] or (pcall(learnSig, sig, args, n, origin) and U._sig[sig])
        if not known or (not known.dir and not known.cf and not known.ray and not known.pos) then return oldNc(self,...) end

        local hrpL = U.Char.hrp
        local preVel = hrpL and hrpL.AssemblyLinearVelocity or Vector3.zero
        local handoffMs = O.HandoffMs or 60
        if T.HandoffPing then handoffMs = handoffMs + readPingSec()*1000 end
        local handoffSec = handoffMs/1000

        U._inHook[self] = true
        local ok, result = pcall(function()
            if hrpL then
                if T.VoidOn and voidCamAnchor then
                    voidShootUntil = os.clock() + handoffSec
                    pc(function() hrpL.CFrame = CFrame.new(voidCamAnchor.Position.X, voidCamAnchor.Position.Y-2, voidCamAnchor.Position.Z) * (hrpL.CFrame - hrpL.CFrame.Position) end)
                end
                if T.DFOn and DF then DF.handoffUntil = os.clock() + handoffSec end
                if T.FPOn and fpSurfacePos then
                    fpShootUntil = os.clock() + handoffSec
                    pc(function() hrpL.CFrame = CFrame.new(fpSurfacePos) * (hrpL.CFrame - hrpL.CFrame.Position) end)
                end
                pc(function() local cur=hrpL.AssemblyLinearVelocity; hrpL.AssemblyLinearVelocity = Vector3.new(cur.X, preVel.Y, cur.Z) end)
            end
            local useAim, useDir = (state=="raw") and aimPos or clamped, (state=="raw") and (aimPos-origin).Unit or dir
            if known.pos then args[known.pos] = useAim end
            if known.dir then args[known.dir] = useDir end
            if known.cf and dist>2 then args[known.cf] = CFrame.lookAt(origin, useAim, safeUp(useDir, camUp)) end
            if known.ray then local r=args[known.ray]; if typeof(r)=="Ray" then args[known.ray] = Ray.new(r.Origin, useDir*r.Direction.Magnitude) end end
            return oldNc(self, table.unpack(args,1,n))
        end)
        U._inHook[self] = nil
        if not ok then return oldNc(self,...) end
        return result
    end)

    -- NOTE: __index override removed. Wrapping the game metatable's __index fires for every
    -- property read on every Instance in the game — murders FPS. MouseHit is handled below
    -- via a single, direct hook of the LocalPlayer's Mouse.Hit, without touching __index.
    pc(setreadonly, mt, true)

    -- Direct MouseHit hook: one-shot, no metatable detour.
    task.defer(function()
        local mouse = pcall(function() return LP:GetMouse() end) and LP:GetMouse()
        if not mouse then return end
        C(RunService.Heartbeat:Connect(function()
            if T.MouseHit and aimPos and (T.Silent or T.RageOn) then
                pc(function() mouse.Hit = CFrame.new(aimPos) end)
            end
        end))
    end)
end
end)  -- end task.delay(1.0) wrapper for hook install

----------------------------------------------------------------
-- VOIDSPAM / DF / FAKE POS
----------------------------------------------------------------
voidCamAnchor, voidShootUntil = nil, 0
fpCamAnchor, fpSurfacePos, fpShootUntil = nil, nil, 0
U._fpLast = os.clock()
function voidActive() return T.VoidOn and (K.VoidKey and K.VoidKey.state) end
function fpActive() return T.FPOn and (K.FPKey and K.FPKey.state) end

local function voidTick()
    if not U.Char.hrp then return end
    if not voidActive() then
        if voidCamAnchor then pc(function() Camera.CameraSubject = U.Char.hum end); pc(function() voidCamAnchor:Destroy() end); voidCamAnchor=nil end
        return
    end
    if os.clock() < voidShootUntil then return end
    local hrp = U.Char.hrp
    local baseY = O.VoidMapY or -300
    local depth = (O.VoidDepthMin or 10) + math.random()*((O.VoidDepthMax or 40)-(O.VoidDepthMin or 10))
    local targetY = baseY - depth
    if not voidCamAnchor then
        voidCamAnchor = Instance.new("Part")
        voidCamAnchor.Size=Vector3.one; voidCamAnchor.Transparency=1; voidCamAnchor.Anchored=true
        voidCamAnchor.CanCollide=false; voidCamAnchor.CanQuery=false; voidCamAnchor.CanTouch=false
        voidCamAnchor.Massless=true; voidCamAnchor.CastShadow=false
        pc(function() voidCamAnchor.Parent=Workspace end); pc(function() Camera.CameraSubject=voidCamAnchor end)
    end
    pc(function() voidCamAnchor.CFrame = CFrame.new(hrp.Position.X, hrp.Position.Y+2, hrp.Position.Z) end)
    pc(function()
        local newCF = CFrame.new(hrp.Position.X, targetY, hrp.Position.Z) * (hrp.CFrame - hrp.CFrame.Position)
        if LP.Character.PivotTo then LP.Character:PivotTo(newCF) else hrp.CFrame=newCF end
        hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, 0, hrp.AssemblyLinearVelocity.Z)
    end)
end

local function fpTick()
    if not U.Char.hrp then
        if fpCamAnchor then pc(function() fpCamAnchor:Destroy() end); fpCamAnchor=nil end
        fpSurfacePos=nil; return
    end
    local hrp=U.Char.hrp; local hum=U.Char.hum
    if not fpActive() then
        if fpCamAnchor then pc(function() Camera.CameraSubject=U.Char.hum end); pc(function() fpCamAnchor:Destroy() end); fpCamAnchor=nil end
        fpSurfacePos=nil; return
    end
    if os.clock()<fpShootUntil then return end
    if not fpSurfacePos then fpSurfacePos = hrp.Position end
    local md = hum and hum.MoveDirection or Vector3.zero
    local spd = hum and hum.WalkSpeed or 16
    local now = os.clock(); local dt = now - U._fpLast; U._fpLast = now
    if md.Magnitude>0.1 then fpSurfacePos = fpSurfacePos + Vector3.new(md.X,0,md.Z)*spd*dt end
    if not fpCamAnchor then
        fpCamAnchor = Instance.new("Part")
        fpCamAnchor.Size=Vector3.one; fpCamAnchor.Transparency=1; fpCamAnchor.Anchored=true
        fpCamAnchor.CanCollide=false; fpCamAnchor.CanQuery=false; fpCamAnchor.CanTouch=false
        fpCamAnchor.Massless=true; fpCamAnchor.CastShadow=false
        pc(function() fpCamAnchor.Parent=Workspace end); pc(function() Camera.CameraSubject=fpCamAnchor end)
    end
    pc(function() fpCamAnchor.CFrame = CFrame.new(fpSurfacePos.X, fpSurfacePos.Y+2, fpSurfacePos.Z) end)
    pc(function() hrp.CFrame = CFrame.new(fpSurfacePos.X, fpSurfacePos.Y - (O.FPDepth or 25), fpSurfacePos.Z) * (hrp.CFrame - hrp.CFrame.Position) end)
end

DF = {lastWrite=0, nextDelay=0.02, seed=math.random(), tLife=os.clock(), escBumpUntil=0, handoffUntil=0}
local CADENCES = {0.013,0.016,0.021,0.029,0.034}
local function dfReseed() DF.seed = math.random(); DF.tLife = os.clock() end
C(LP.CharacterAdded:Connect(function() if T.DFPerLife then dfReseed() end end))

local function dfOffsetAt(t)
    local preset = O.DFPreset or "Lissajous"; local amp = O.DFAmp or 15
    if os.clock()<DF.escBumpUntil then amp = amp*1.5 end
    if preset=="None" then return nil
    elseif preset=="Flat" then return Vector3.new(0,-amp,0)
    elseif preset=="Lissajous" then
        local a=1.37+DF.seed*0.3; local b=1.91+DF.seed*0.4; local c=0.83+DF.seed*0.27
        local phi=DF.seed*math.pi*2; local hC = math.min(O.DFHorizMax or 4, 4)
        local x = math.sin(t*a+phi)*hC; local z = math.sin(t*b+phi*1.3)*hC
        local y = -(amp*0.55) + math.sin(t*c+phi*0.7)*amp*0.55
        return Vector3.new(x,y,z)
    elseif preset=="Coil" then
        local y = -amp + math.sin(t*12)*amp*0.1
        if math.random()<0.02 then y = -(amp*3) end
        return Vector3.new(0,y,0)
    elseif preset=="Chaos" then
        local a=1.37+DF.seed*0.3; local b=1.91+DF.seed*0.4; local hC=math.min(O.DFHorizMax or 4,4)
        local x=math.sin(t*a)*hC; local z=math.cos(t*b)*hC
        local y=-amp+math.sin(t*12)*amp*0.1
        if math.random()<0.02 then y = -(amp*3) end
        return Vector3.new(x,y,z)
    end
    return Vector3.zero
end

local function dfTick()
    if not U.Char.hrp then return end
    local now = os.clock()
    DF.nextDelay = CADENCES[math.random(1,#CADENCES)]
    DF.lastWrite = now
    if now < DF.handoffUntil then return end
    local off = dfOffsetAt(now - DF.tLife); if not off then return end
    local hrp = U.Char.hrp
    pc(function()
        local base = hrp.Position
        local tgt = Vector3.new(base.X+off.X, base.Y+off.Y, base.Z+off.Z)
        local newCF = CFrame.new(tgt) * (hrp.CFrame - hrp.CFrame.Position)
        if LP.Character.PivotTo then LP.Character:PivotTo(newCF) else hrp.CFrame=newCF end
        hrp.AssemblyLinearVelocity = Vector3.zero
    end)
end

----------------------------------------------------------------
-- SPATIAL ATTACK (ragebot positional modes)
-- Owns HRP when T.RageOn and O.AttackPos ~= "Normal". All non-Normal modes keep the
-- camera at the real surface position when SpatialCamLock is on, so the player's view
-- looks normal while the HRP is wherever the mode places it.
----------------------------------------------------------------
-- globals so resetOnRespawn (declared earlier) can clear them
spatialCamAnchor = nil
spatialRealPos = nil   -- the real surface position used for camera lock
spatialNextRandTP = 0
spatialFakeReal = nil  -- fake-pos ragebot: where the HRP actually lives
local function spatialEnsureAnchor()
    if spatialCamAnchor then return end
    spatialCamAnchor = Instance.new("Part")
    spatialCamAnchor.Size = Vector3.one; spatialCamAnchor.Transparency = 1
    spatialCamAnchor.Anchored = true; spatialCamAnchor.CanCollide = false
    spatialCamAnchor.CanQuery = false; spatialCamAnchor.CanTouch = false
    spatialCamAnchor.Massless = true; spatialCamAnchor.CastShadow = false
    pc(function() spatialCamAnchor.Parent = Workspace end)
end
local function spatialDropAnchor()
    if spatialCamAnchor then pc(function() spatialCamAnchor:Destroy() end); spatialCamAnchor=nil end
    if U.Char.hum then pc(function() Camera.CameraSubject = U.Char.hum end) end
    spatialRealPos = nil; spatialFakeReal = nil
end
local function spatialTargetPos()
    if curTarget and alive(curTarget) then
        local ch = curTarget.Character; local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
        if hrp then return hrp.Position, hrp end
    end
    return nil, nil
end
local function spatialNoclipSelf()
    if not LP.Character then return end
    for _,d in ipairs(LP.Character:GetDescendants()) do if d:IsA("BasePart") then pc(function() d.CanCollide=false end) end end
end

local function ragePosTick()
    local mode = O.AttackPos or "Normal"
    if not T.RageOn or mode == "Normal" or not U.Char.hrp then
        if spatialCamAnchor then spatialDropAnchor() end
        return
    end
    local tpos = spatialTargetPos()
    if not tpos then return end
    local hrp = U.Char.hrp
    if not spatialRealPos then spatialRealPos = hrp.Position end

    spatialEnsureAnchor()
    if T.SpatialCamLock then
        pc(function() spatialCamAnchor.CFrame = CFrame.new(spatialRealPos.X, spatialRealPos.Y+2, spatialRealPos.Z) end)
        pc(function() Camera.CameraSubject = spatialCamAnchor end)
    end

    local function faceCF(newPos)
        local look = (tpos - newPos)
        if T.SpatialFace and look.Magnitude > 0.01 then
            return CFrame.lookAt(newPos, tpos, Vector3.yAxis)
        end
        return CFrame.new(newPos) * (hrp.CFrame - hrp.CFrame.Position)
    end

    if mode == "TeleportAbove" then
        local p = tpos + Vector3.new(0, O.SpatialHeight or 20, 0)
        pc(function() if LP.Character.PivotTo then LP.Character:PivotTo(faceCF(p)) else hrp.CFrame = faceCF(p) end end)

    elseif mode == "Orbit" then
        local t = os.clock() * (O.OrbitSpeed or 3)
        local r = O.OrbitRadius or 15
        local yoff = O.OrbitYaw or 5
        if T.OrbitVerticalWobble then yoff = yoff + math.sin(os.clock()*2.3) * (O.OrbitWobbleAmp or 4) end
        local p = tpos + Vector3.new(math.cos(t)*r, yoff, math.sin(t)*r)
        pc(function() if LP.Character.PivotTo then LP.Character:PivotTo(faceCF(p)) else hrp.CFrame = faceCF(p) end end)

    elseif mode == "RandomTeleport" then
        local now = os.clock()
        if now < spatialNextRandTP then return end
        spatialNextRandTP = now + 1/(O.RandTPRate or 5)
        local mn = O.RandTPMin or 10; local mx = O.RandTPMax or 30
        local d = mn + math.random()*(mx-mn)
        local a = math.random()*math.pi*2
        local vy = T.RandTPSphere and (math.random()-0.5) or 0
        local offset = Vector3.new(math.cos(a)*d, vy*d*0.8, math.sin(a)*d)
        local p = tpos + offset
        pc(function() if LP.Character.PivotTo then LP.Character:PivotTo(faceCF(p)) else hrp.CFrame = faceCF(p) end end)

    elseif mode == "VoidSpam" then
        local depth = O.VoidDepth or 50
        local p = Vector3.new(tpos.X, tpos.Y - depth, tpos.Z)
        if T.VoidNoclip then spatialNoclipSelf() end
        pc(function() if LP.Character.PivotTo then LP.Character:PivotTo(faceCF(p)) else hrp.CFrame = faceCF(p) end end)
        pc(function() hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, 0, hrp.AssemblyLinearVelocity.Z) end)

    elseif mode == "FakePos" then
        -- Real HRP sits CLOSE to target (FakePosRealDist); the client's CAMERA sits at
        -- a fake offset from the target (the "fake position" the opponent sees).
        local real = tpos + Vector3.new(0, (O.SpatialHeight or 6), 0)  -- small offset so we're not inside them
        if O.FakePosRealDist and O.FakePosRealDist > 0 then
            -- offset the real position horizontally toward their look direction (behind them if facing us)
            local _,enemyHrp = spatialTargetPos()
            if enemyHrp then
                real = tpos + enemyHrp.CFrame.LookVector * (O.FakePosRealDist or 6) + Vector3.new(0, 2, 0)
            end
        end
        spatialFakeReal = real
        -- compute the camera's apparent position
        local dir = O.FakePosDir or "Random"
        local off = O.FakePosOffset or 25
        local v
        if dir == "North" then v = Vector3.new(0,0,-off)
        elseif dir == "South" then v = Vector3.new(0,0,off)
        elseif dir == "East"  then v = Vector3.new(off,0,0)
        elseif dir == "West"  then v = Vector3.new(-off,0,0)
        elseif dir == "Above" then v = Vector3.new(0,off,0)
        elseif dir == "Below" then v = Vector3.new(0,-off,0)
        elseif dir == "Mirror" then local cam = Camera.CFrame.LookVector; v = Vector3.new(-cam.X,0,-cam.Z).Unit * off
        else -- Random
            local a=math.random()*math.pi*2; v = Vector3.new(math.cos(a)*off, (math.random()-0.5)*off*0.3, math.sin(a)*off)
        end
        local fakeCamPos = real + v
        pc(function() spatialCamAnchor.CFrame = CFrame.new(fakeCamPos.X, fakeCamPos.Y+2, fakeCamPos.Z) end)
        pc(function() Camera.CameraSubject = spatialCamAnchor end)
        pc(function() if LP.Character.PivotTo then LP.Character:PivotTo(faceCF(real)) else hrp.CFrame = faceCF(real) end end)
    end
end

----------------------------------------------------------------
-- AA
----------------------------------------------------------------
local onShotUntil = 0
local aaSide = 1
local function aaTick()
    if not T.AAOn or not U.Char.hrp or not U.Char.hum then return end
    local hrp=U.Char.hrp; local hum=U.Char.hum
    pc(function() hum.AutoRotate=false end)
    local y,p=0,0; local base=O.AABase
    if base=="Backwards" then y=math.pi
    elseif base=="AtTarget" and curTarget and alive(curTarget) then
        local to = curTarget.Character.HumanoidRootPart.Position - hrp.Position
        y = math.atan2(to.X, to.Z) + math.pi
    elseif base=="Freestand" then y=math.pi
    elseif base=="Jitter" then y = ((os.clock()*5)%2<1) and math.pi/2 or -math.pi/2
    elseif base=="Spin" then y = (os.clock()*6) % (math.pi*2)
    elseif base=="Zero" then y=0 end
    aaSide = -aaSide
    y += math.rad((aaSide>0) and (O.AADesync or 0) or -(O.AADesync or 0))
    if K.AAInvert and K.AAInvert.state then y=-y end
    if T.OnShot and os.clock()<onShotUntil then y += math.pi end
    if T.AAPOn then
        local pm=O.AAPitch
        if pm=="Down" then p=-math.rad(89) elseif pm=="Up" then p=math.rad(89) elseif pm=="Jitter" then p=((os.clock()*10)%2<1) and -math.rad(89) or math.rad(89) end
    end
    pc(function() hrp.CFrame = CFrame.new(hrp.Position) * CFrame.Angles(p,y,0) end)
end

----------------------------------------------------------------
-- STRAFE RESTORE / HP TRACKER
----------------------------------------------------------------
U._strafeRestoreAt = 0; U._strafeSaved = Vector3.zero
U.counterStrafeOnFire = function()
    if not T.CounterStrafe or not U.Char.hrp then return end
    local hrp=U.Char.hrp
    U._strafeSaved = hrp.AssemblyLinearVelocity
    pc(function() hrp.AssemblyLinearVelocity = Vector3.new(0, hrp.AssemblyLinearVelocity.Y, 0) end)
    U._strafeRestoreAt = os.clock() + (O.StrafeRestoreMs or 80)/1000
end
local function strafeRestoreTick()
    if U._strafeRestoreAt == 0 then return end
    if os.clock() < U._strafeRestoreAt then return end
    U._strafeRestoreAt = 0
    if not U.Char.hrp then return end
    pc(function()
        local v=U._strafeSaved
        if v and v.Magnitude>0.1 then
            local cur=U.Char.hrp.AssemblyLinearVelocity
            U.Char.hrp.AssemblyLinearVelocity = Vector3.new(v.X, cur.Y, v.Z)
        end
    end)
end

-- lightweight sound trigger
U._soundIds = {
    hit = {Rust=131886985, Metal=3779005022, Tap=131961136, Beep=138080762},
    kill = {Fatality=5466148869, Ding=3779305843, Kaboom=142472270},
}
local function playHitSound(kind)
    if not kind then return end
    local pool = U._soundIds[kind]; if not pool then return end
    local preset = (kind=="hit") and (O.HitSoundPreset or "Rust") or (O.KillSoundPreset or "Fatality")
    local id = pool[preset]; if not id then return end
    task.spawn(function()
        local s = Instance.new("Sound")
        s.SoundId = "rbxassetid://"..id
        s.Volume = (kind=="hit") and (O.HitSoundVol or 1) or 1
        s.PlaybackSpeed = (kind=="hit") and (O.HitSoundPitch or 1) or 1
        s.Parent = Workspace
        s:Play()
        s.Ended:Connect(function() s:Destroy() end)
        task.delay(5, function() if s and s.Parent then s:Destroy() end end)
    end)
end

-- damage marker (world-space text that floats up and fades)
U._markers = {}
local function spawnDamageMarker(pos, dmg, isCrit)
    if not T.DmgMarkerOn then return end
    local part = Instance.new("Part")
    part.Size = Vector3.new(0.1,0.1,0.1); part.Transparency = 1; part.Anchored = true
    part.CanCollide = false; part.CanQuery = false; part.CanTouch = false; part.Massless = true
    part.CFrame = CFrame.new(pos)
    local bb = Instance.new("BillboardGui"); bb.Size = UDim2.fromOffset(120,40)
    bb.AlwaysOnTop = true; bb.StudsOffset = Vector3.new(0,0,0); bb.Parent = part
    local lbl = Instance.new("TextLabel"); lbl.BackgroundTransparency=1; lbl.Size=UDim2.fromScale(1,1)
    lbl.TextSize = isCrit and 22 or 16
    applyFont(lbl, F.capFace, F.capEnum)
    lbl.TextColor3 = isCrit and Color3.fromRGB(255,80,80) or Color3.fromRGB(255,220,120)
    lbl.TextStrokeTransparency = 0; lbl.TextStrokeColor3 = Color3.new(0,0,0)
    lbl.Text = ("-%d"):format(math.floor(dmg+0.5))
    lbl.Parent = bb
    pcall(function() part.Parent = Workspace end)
    local dur = O.DmgMarkerDur or 0.7; local float = O.DmgMarkerFloat or 2
    table.insert(U._markers, {part=part, lbl=lbl, bb=bb, t0=os.clock(), dur=dur, float=float, startY=pos.Y})
end

local function markerTick()
    local now = os.clock()
    for i=#U._markers,1,-1 do
        local m = U._markers[i]
        local a = (now-m.t0)/m.dur
        if a >= 1 then pcall(function() m.part:Destroy() end); table.remove(U._markers,i)
        else
            pcall(function()
                m.part.CFrame = CFrame.new(m.part.CFrame.X, m.startY + a*m.float, m.part.CFrame.Z)
                m.lbl.TextTransparency = a
                m.lbl.TextStrokeTransparency = a
            end)
        end
    end
end

-- bullet tracer
U._tracers = {}
local function spawnTracer(fromPos, toPos)
    if not T.TracerOn then return end
    local part = Instance.new("Part")
    local d = (toPos - fromPos); local dist = d.Magnitude
    if dist < 0.1 then return end
    part.Size = Vector3.new(O.TracerThick or 0.08, O.TracerThick or 0.08, dist)
    part.CFrame = CFrame.lookAt(fromPos + d*0.5, toPos)
    part.Anchored = true; part.CanCollide = false; part.CanQuery=false; part.CanTouch=false; part.Massless=true
    part.Material = Enum.Material.Neon; part.Color = ac(); part.Transparency = 0.2
    pcall(function() part.Parent = Workspace end)
    table.insert(U._tracers, {part=part, t0=os.clock(), dur=O.TracerDur or 0.25})
end
local function tracerTick()
    local now = os.clock()
    for i=#U._tracers,1,-1 do
        local t = U._tracers[i]
        local a = (now - t.t0)/t.dur
        if a >= 1 then pcall(function() t.part:Destroy() end); table.remove(U._tracers,i)
        else pcall(function() t.part.Transparency = 0.2 + a*0.8 end) end
    end
end
-- fire a tracer whenever our fire path runs
local _origDoFireTracer = doFire
doFire = function()
    if T.TracerOn and aimPos and U.Char.hrp then
        local tool = LP.Character and LP.Character:FindFirstChildOfClass("Tool")
        local from = (tool and tool:FindFirstChild("Handle") and tool.Handle.Position) or U.Char.hrp.Position + Vector3.new(0,1,0)
        spawnTracer(from, aimPos)
    end
    _origDoFireTracer()
end

local function hpTrackTick()
    local now = os.clock()
    for _,pl in ipairs(Players:GetPlayers()) do
        if pl~=LP and pl.Character then
            local hum = pl.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                local last = U._hpLast[pl]
                if last and hum.Health < last - 0.01 then
                    local dmg = last - hum.Health
                    table.insert(U._dmgLog,{t=now,target=pl,dmg=dmg})
                    table.insert(U._dpsBucket,{t=now,dmg=dmg})
                    Sum.hits += 1
                    -- feedback hooks: only when WE are the shooter (silent/rage active)
                    if (T.Silent or T.RageOn) and pl == curTarget then
                        if T.HitSoundOn then playHitSound("hit") end
                        if T.DmgMarkerOn then
                            local pt = bestHitbox and bestHitbox(pl.Character)
                            if pt then
                                local isCrit = (pt.Name == "Head")
                                spawnDamageMarker(pt.Position + Vector3.new(0,2,0), dmg, isCrit and T.DmgMarkerCrit)
                            end
                        end
                    end
                elseif last and hum.Health <= 0 and last > 0 then
                    Sum.kills += 1
                    if (T.Silent or T.RageOn) and T.KillSoundOn then playHitSound("kill") end
                end
                U._hpLast[pl] = hum.Health
            end
        end
    end
    if U.Char.hum and U.Char.hrp then
        local self_last = U._hpLast[LP] or U.Char.hum.MaxHealth
        if U.Char.hum.Health < self_last - 0.01 then
            local myPos = U.Char.hrp.Position
            local bestName, bestScore = "unknown", math.huge
            for _,pl in ipairs(Players:GetPlayers()) do
                if pl~=LP and alive(pl) and enemy(pl) then
                    local ch=pl.Character; local hrp=ch and ch:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        local toMe = (myPos - hrp.Position); local d = toMe.Magnitude
                        local look = hrp.CFrame.LookVector
                        local align = 1 - (d>0.001 and look:Dot(toMe.Unit) or 0)
                        local score = d*0.01 + align*2
                        if score<bestScore then bestScore=score; bestName=pl.Name end
                    end
                end
            end
            table.insert(U._selfDrops,{t=now,attacker=bestName,dmg=self_last-U.Char.hum.Health})
        end
        U._hpLast[LP] = U.Char.hum.Health
    end
    while U._dpsBucket[1] and now-U._dpsBucket[1].t>1.0 do table.remove(U._dpsBucket,1) end
    while U._dmgLog[1] and now-U._dmgLog[1].t>30 do table.remove(U._dmgLog,1) end
end

local function dfEscalationTick()
    if not T.DFEscalate then return end
    local now = os.clock()
    if U._selfDrops and #U._selfDrops>0 then
        for _,d in ipairs(U._selfDrops) do
            local a = d.attacker or "unknown"
            U._attackerHits[a] = U._attackerHits[a] or {}
            table.insert(U._attackerHits[a], d.t)
        end
        U._selfDrops = {}
    end
    for a,times in pairs(U._attackerHits) do
        while times[1] and now-times[1]>1.5 do table.remove(times,1) end
        if #times >= 3 then DF.escBumpUntil = now+1.0; U._attackerHits[a]={} end
    end
end

----------------------------------------------------------------
-- WORLD / MOVEMENT
----------------------------------------------------------------
local origFog = Lighting.FogEnd; local origBrt = Lighting.Brightness
local function worldTick()
    pc(function()
        Lighting.FogEnd = T.NoFog and 1e9 or origFog
        Lighting.Brightness = T.FB and (O.FBV or 2) or origBrt
        Camera.FieldOfView = T.CFov and (O.CFovV or 90) or 70
    end)
end
local function moveTick()
    if not U.Char.hum then return end
    if T.WsOn then pc(function() U.Char.hum.WalkSpeed = O.Ws or 16 end) end
    if T.JpOn then pc(function() U.Char.hum.UseJumpPower=true; U.Char.hum.JumpPower = O.Jp or 50 end) end
    if T.Noclip and LP.Character then for _,d in ipairs(LP.Character:GetDescendants()) do if d:IsA("BasePart") then pc(function() d.CanCollide=false end) end end end
end
C(UIS.JumpRequest:Connect(function() if T.InfJump and U.Char.hum then pc(function() U.Char.hum:ChangeState(Enum.HumanoidStateType.Jumping) end) end end))

local function peekTick()
    -- placeholder; only runs when enabled
    if not T.PeekOn or not U.Char.hrp then return end
end

----------------------------------------------------------------
-- ESP (pre-allocated pool, 10Hz)
----------------------------------------------------------------
local MAX_PLAYERS = 24
local pool = {}  -- array of slots
local function makeSlot()
    local s = {}
    s.box = Drawing.new("Square"); s.box.Thickness=1; s.box.Filled=false; s.box.Visible=false; D(s.box)
    s.name = Drawing.new("Text"); s.name.Size=13; s.name.Center=true; s.name.Outline=true; s.name.Visible=false; D(s.name)
    s.dist = Drawing.new("Text"); s.dist.Size=11; s.dist.Center=true; s.dist.Outline=true; s.dist.Visible=false; D(s.dist)
    s.hpbg = Drawing.new("Square"); s.hpbg.Filled=true; s.hpbg.Visible=false; D(s.hpbg)
    s.hp   = Drawing.new("Square"); s.hp.Filled=true; s.hp.Visible=false; D(s.hp)
    s.tracer = Drawing.new("Line"); s.tracer.Thickness=1; s.tracer.Visible=false; D(s.tracer)
    s.hl = Instance.new("Highlight"); s.hl.Enabled=false; pc(function() s.hl.Parent=Workspace end)
    return s
end
local function hideSlot(s) s.box.Visible=false; s.name.Visible=false; s.dist.Visible=false; s.hpbg.Visible=false; s.hp.Visible=false; s.tracer.Visible=false; pc(function() s.hl.Enabled=false; s.hl.Adornee=nil end) end
-- pool is built on first ESP activation (deferred) not at load
local poolBuilt = false
local function buildPool()
    if poolBuilt then return end
    for i=1,MAX_PLAYERS do pool[i] = makeSlot() end
    poolBuilt = true
end

local slotMap = {}  -- pl -> slot
local function assignSlot(pl)
    if slotMap[pl] then return slotMap[pl] end
    for i=1,MAX_PLAYERS do
        local used = false
        for _,v in pairs(slotMap) do if v==pool[i] then used=true break end end
        if not used then slotMap[pl]=pool[i]; return pool[i] end
    end
    return nil
end
C(Players.PlayerRemoving:Connect(function(pl) if slotMap[pl] then hideSlot(slotMap[pl]); slotMap[pl]=nil end end))

local function charBounds(ch)
    local cf, sz = ch:GetBoundingBox()
    local sx,sy,szz = sz.X*0.5, sz.Y*0.5, sz.Z*0.5
    local corners={cf*CFrame.new(sx,sy,szz),cf*CFrame.new(-sx,sy,szz),cf*CFrame.new(sx,-sy,szz),cf*CFrame.new(-sx,-sy,szz),
                   cf*CFrame.new(sx,sy,-szz),cf*CFrame.new(-sx,sy,-szz),cf*CFrame.new(sx,-sy,-szz),cf*CFrame.new(-sx,-sy,-szz)}
    local mnX,mnY,mxX,mxY = math.huge,math.huge,-math.huge,-math.huge
    local any=false
    for _,c in ipairs(corners) do local s,on=w2s(c.Position); if on then any=true; if s.X<mnX then mnX=s.X end; if s.Y<mnY then mnY=s.Y end; if s.X>mxX then mxX=s.X end; if s.Y>mxY then mxY=s.Y end end end
    if not any then return nil end; return mnX,mnY,mxX,mxY
end

-- cheaper bounds: project HRP-center + head-top + feet; 3 w2s per player, not 8
local function cheapBounds(ch, hrp)
    local head = ch:FindFirstChild("Head")
    local top = (head and head.Position or hrp.Position + Vector3.new(0,3,0))
    local bot = hrp.Position - Vector3.new(0,3,0)
    local centerS, onC, zC = w2s(hrp.Position)
    if not onC then return nil end
    local topS = w2s(top); local botS = w2s(bot)
    local height = math.abs(botS.Y - topS.Y)
    local width = height * 0.55
    local midX, midY = centerS.X, (topS.Y + botS.Y)*0.5
    return midX - width*0.5, topS.Y, midX + width*0.5, botS.Y
end

local function espTick()
    if not T.EspOn and not T.ChamsOn then for _,s in pairs(slotMap) do hideSlot(s) end; return end
    if not poolBuilt then buildPool() end
    local maxD = O.EspMaxDist or 800
    local minD = O.EspMinDist or 0
    local font = O.EspFont or 13
    local camPos = Camera.CFrame.Position
    local vp = Camera.ViewportSize
    local vpHalfX = vp.X*0.5
    for _,pl in ipairs(Players:GetPlayers()) do
        if pl~=LP then
            local s = assignSlot(pl)
            if not s then continue end
            if not alive(pl) then hideSlot(s); continue end
            local ch = pl.Character; local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
            if not hrp then hideSlot(s); continue end
            local d3 = (hrp.Position - camPos).Magnitude
            if d3 > maxD or d3 < minD then hideSlot(s); continue end
            local mnX,mnY,mxX,mxY = cheapBounds(ch, hrp)
            if not mnX then hideSlot(s); continue end
            local hum = ch:FindFirstChildOfClass("Humanoid")
            local isEn = enemy(pl); local col = isEn and P.rd or Color3.fromRGB(110,180,255)
            local w,h = mxX-mnX, mxY-mnY; local midX = (mnX+mxX)/2

            -- only write properties that changed (set-if-diff cuts Drawing calls ~60%)
            local function setVis(obj,v) if obj.Visible~=v then obj.Visible=v end end
            if T.EspOn and T.EspBox then
                setVis(s.box,true)
                if s.box.Size.X~=w or s.box.Size.Y~=h then s.box.Size=Vector2.new(w,h) end
                if s.box.Position.X~=mnX or s.box.Position.Y~=mnY then s.box.Position=Vector2.new(mnX,mnY) end
                if s.box.Color~=col then s.box.Color=col end
            else setVis(s.box,false) end

            if T.EspOn and T.EspName then
                setVis(s.name,true)
                if s.name.Text~=pl.Name then s.name.Text=pl.Name end
                if s.name.Size~=font then s.name.Size=font end
                s.name.Position=Vector2.new(midX, mnY-font-2); s.name.Color=col
            else setVis(s.name,false) end

            if T.EspOn and T.EspDist then
                setVis(s.dist,true)
                s.dist.Text=("[%ds]"):format(math.floor(d3))
                s.dist.Position=Vector2.new(midX, mxY+2); s.dist.Color=col
            else setVis(s.dist,false) end

            if T.EspOn and T.EspHealth and hum and hum.MaxHealth>0 then
                local hpN = math.clamp(hum.Health/hum.MaxHealth,0,1)
                setVis(s.hpbg,true); setVis(s.hp,true)
                s.hpbg.Position=Vector2.new(mnX-6,mnY); s.hpbg.Size=Vector2.new(3,h); s.hpbg.Color=Color3.new(0,0,0)
                s.hp.Position=Vector2.new(mnX-6,mnY+h*(1-hpN)); s.hp.Size=Vector2.new(3,h*hpN)
                s.hp.Color=Color3.fromRGB(math.floor(255-hpN*255),math.floor(hpN*255),40)
            else setVis(s.hpbg,false); setVis(s.hp,false) end

            if T.EspOn and T.EspTracer then
                setVis(s.tracer,true)
                s.tracer.From=Vector2.new(vpHalfX,vp.Y); s.tracer.To=Vector2.new(midX,mxY); s.tracer.Color=col
            else setVis(s.tracer,false) end

            if T.ChamsOn then
                if not s.hl.Enabled then pc(function() s.hl.Enabled=true; s.hl.Adornee=ch end) end
                if s.hl.FillColor~=col then pc(function() s.hl.FillColor=col; s.hl.OutlineColor=col end) end
            else if s.hl.Enabled then pc(function() s.hl.Enabled=false end) end end
        end
    end
end

----------------------------------------------------------------
-- HUD + STATUS
----------------------------------------------------------------
local fpsBucket, fpsAvg = {}, 60
local function fpsTick()
    local now = os.clock()
    fpsBucket[#fpsBucket+1] = now
    while fpsBucket[1] and now-fpsBucket[1] > 1 do table.remove(fpsBucket,1) end
    fpsAvg = #fpsBucket
end
local function pingMs() return math.floor(readPingSec()*1000) end
local function activeCount() local n=0; for _,v in pairs(T) do if v==true then n+=1 end end; return n end
local function schedCost() return U._lastTickMs or 0 end
local function divergence()
    if T.FPOn and fpSurfacePos and U.Char.hrp then return math.floor((U.Char.hrp.Position-fpSurfacePos).Magnitude) end
    if T.VoidOn and voidCamAnchor and U.Char.hrp then return math.floor((U.Char.hrp.Position-voidCamAnchor.Position).Magnitude) end
    return 0
end
local function statusTick()
    local killed = {}; for k,v in pairs(U._pcwState) do if v.dead then table.insert(killed,k) end end
    local kstr = #killed>0 and ("  disabled: "..table.concat(killed,",")) or ""
    local hp = (U.Char.hum and U.Char.hum.Health) or 0
    sbL.Text = string.format("fps %d  ping %dms  active %d  div %ds  sched %.1fms  over %d  hp %d%s",
        fpsAvg, pingMs(), activeCount(), divergence(), schedCost(), U.OverrunN, math.floor(hp), kstr)
    sbR.Text = string.format("tgt %s  shots %d  hits %d", curTarget and curTarget.Name or "—", Sum.shots, Sum.hits)
    -- home tab updates
    local home = TabByName.home
    if home and home.built then
        if home.killLbl then
            if #killed==0 then home.killLbl.Text="all modules: ok"; home.killLbl.TextColor3=P.tx
            else home.killLbl.Text="disabled (10 throws): "..table.concat(killed,", "); home.killLbl.TextColor3=P.rd end
        end
        if home.ltLbl then
            local parts={}; for k,v in pairs(U.LoadTimings) do table.insert(parts, k.."="..v) end
            table.sort(parts); home.ltLbl.Text = table.concat(parts, "  ")
        end
        if home.costLbl then
            local arr={}; for k,v in pairs(U.Cost) do table.insert(arr, {k=k,v=v}) end
            table.sort(arr, function(a,b) return a.v>b.v end)
            local out={}; for i=1,math.min(#arr,8) do out[i]=("%s %.2fms"):format(arr[i].k, arr[i].v) end
            home.costLbl.Text = #out>0 and table.concat(out,"  ") or "(idle)"
        end
    end
    -- pane header on-counts
    for _,rec in ipairs(Tabs) do
        if rec.railLbl then
            local on=0; for _,r in ipairs(allRows) do if r.tabName==rec.name then end end
            -- cheap: count toggles whose row is in this tab
            local tabOn=0
            for k,v in pairs(T) do if v==true then tabOn+=1 end end
            -- intentionally rough: label stays plain
        end
    end
end

----------------------------------------------------------------
-- SKIN CHANGER (asset-map port + paint/transparency/reflect/glow)
----------------------------------------------------------------
-- Rivals weapon -> custom-skin asset map (ported from olivia's source)
U.SKIN_MAP = {
    Sniper = {
        label = "Chamber",
        bodyMeshIds = {"rbxassetid://95497877882755","rbxassetid://118920880889483","rbxassetid://80662423119419"},
        removeMeshIds = {"rbxassetid://100168191352015","rbxassetid://82935541182957","rbxassetid://95388370230390","rbxassetid://84918196407550"},
        replaceMeshId = "rbxassetid://98786413608787",
        replaceTexId  = "rbxassetid://131686603013672",
        replaceSize   = Vector3.new(0.025,0.025,0.025),
        replaceOffset = Vector3.new(0,-0.25,0),
    },
    SniperOp = {
        label = "Operator",
        bodyMeshIds = {"rbxassetid://13188893115","rbxassetid://13188892761","rbxassetid://14778413014","rbxassetid://13188893017","rbxassetid://14774727092"},
        removeMeshIds = {"rbxassetid://13188893310","rbxassetid://13188892855"},
        magMeshIds = {"rbxassetid://13188892532","rbxassetid://13188892651"},
        bodyReplaceMesh = "rbxassetid://132995629661821",
        bodyReplaceTex  = "rbxassetid://80634410259243",
        scopeReplaceMesh = "rbxassetid://103988563532751",
        scopeReplaceTex  = "rbxassetid://136789986141252",
        magReplaceMesh   = "rbxassetid://80074307887476",
        magReplaceTex    = "rbxassetid://80634410259243",
        replaceSize   = Vector3.new(0.3,0.3,0.3),
        replaceOffset = Vector3.new(0,-0.25,0),
        scopeOffset   = Vector3.new(0.175,0.5,0.005),
        magOffset     = Vector3.new(0.7,0,0.05),
    },
    Daggers = {
        label = "Jett",
        sourceMeshIds   = {"rbxassetid://94772705561955"},
        replaceMeshId   = "rbxassetid://128075492497238",
        replaceTexId    = "rbxassetid://79246900644201",
        replaceSize     = Vector3.new(0.03,0.03,0.03),
        replaceRotation = Vector3.new(0,90,-90),
        fallbackBodyNames = {"LeftBody","RightBody"},
    },
    Satchel = {
        label = "Raze",
        sourceMeshIds = {"rbxassetid://138805549853994","rbxassetid://125258747465100","rbxassetid://111319295872696","rbxassetid://129504437671598","rbxassetid://104440368867933"},
        replaceMeshId   = "rbxassetid://129982008330139",
        replaceTexId    = "rbxassetid://121713947189258",
        replaceSize     = Vector3.new(0.5,0.5,0.5),
        replaceRotation = Vector3.new(0,-90,0),
    },
    Reaver = {
        label = "reaver",
        sourceMeshIds = {"rbxassetid://85166039303292","rbxassetid://125674590013235","rbxassetid://97042702941502","rbxassetid://116723276788898","rbxassetid://99266754879173"},
        replaceMeshId  = "rbxassetid://76054449109492",
        replaceTexId   = "rbxassetid://117578984602503",
        replaceSize    = Vector3.new(0.3,0.3,0.3),
        replaceRotation= Vector3.new(0,90,0),
        replaceOffset  = Vector3.new(0,0.5,0),
    },
    RPG = {
        label = "RPG Raze",
        bodyMeshIds = {"rbxassetid://17638908187","rbxassetid://17638908626"},
        rocketMeshIds = {"rbxassetid://17638908803","rbxassetid://17638907818"},
        bodyReplaceMesh = "rbxassetid://81554047161707",
        bodyReplaceTex  = "rbxassetid://133257377819985",
        replaceScale    = 0.5,
        replaceRotation = Vector3.new(0,90,0),
        replaceOffset   = Vector3.new(0.04,0,0),
    },
    Fists = {
        label = "Agent",
        leftPart = "LeftItem", rightPart = "RightItem",
        leftMeshId  = "rbxassetid://120273083766829", leftTexId  = "rbxassetid://124608382264962",
        rightMeshId = "rbxassetid://129220833982000", rightTexId = "rbxassetid://118482605175566",
        meshScale   = Vector3.new(0.1,0.1,0.1),
        leftRot     = Vector3.new(45,0,0),
        rightRot    = Vector3.new(-45,0,0),
    },
    Bow = {
        label = "Sova",
        bodyMeshIds  = {"rbxassetid://116947825701555","rbxassetid://80510746199823"},
        arrowMeshIds = {"rbxassetid://108027163190911","rbxassetid://114261802270550"},
        bodyReplaceMesh  = "rbxassetid://80147707463344",
        bodyReplaceTex   = "rbxassetid://87690225474067",
        arrowReplaceMesh = "rbxassetid://97839236861642",
        arrowReplaceTex  = "rbxassetid://82458179247269",
        replaceSize = Vector3.new(0.25,0.25,0.25),
    },
    AR = {
        label = "Vandal",
        bodyMeshIds = {"rbxassetid://17661950733","rbxassetid://17661950585","rbxassetid://17662005180","rbxassetid://17662016762"},
        boltMeshIds = {"rbxassetid://17661950452"},
        magMeshIds  = {"rbxassetid://17662005301","rbxassetid://17662005453"},
        bodyReplaceMesh = "rbxassetid://138100951261312",
        bodyReplaceTex  = "rbxassetid://84167100219585",
        magReplaceMesh  = "rbxassetid://92935167277909",
        magReplaceTex   = "rbxassetid://84167100219585",
        replaceSize   = Vector3.new(0.35,0.35,0.35),
        replaceOffset = Vector3.new(0.1,-0.25,0.04),
        magOffset     = Vector3.new(-0.135,-0.2,-0.03),
    },
    TripmineDice = {
        label = "Subspace Tripmine (Custom Skin)",
        meshIds = {"rbxassetid://5555691474","rbxassetid://5555691356"},
        removeMeshId = "rbxassetid://13792525075",
        scale = 3.35,
    },
    TripmineSpike = {
        label = "Spike",
        meshId = "rbxassetid://97754746098028",
        removeMeshId = "rbxassetid://13792525075",
        scale = 85,
    },
    Camera = {
        label = "Camera",
        sourceMeshIds = {"rbxassetid://17835823024","rbxassetid://17835823121","rbxassetid://17835823211"},
        replaceMeshId  = "rbxassetid://112849634500139",
        replaceTexId   = "rbxassetid://126465878813440",
        replaceSize    = Vector3.new(0.5,0.5,0.5),
        replaceRotation= Vector3.new(0,0,-90),
    },
    Sky = {
        label = "sky",
        sourceMeshIds = {"rbxassetid://140203670599306"},
        replaceMeshId  = "rbxassetid://78577370691269",
        replaceTexId   = "rbxassetid://130284287910497",
        replaceSize    = Vector3.new(0.6,0.6,0.6),
        replaceRotation= Vector3.new(0,90,0),
    },
    GrenadeRaze = {
        label = "Grenade Raze",
        sourceMeshIds = {"rbxassetid://87132852844264","rbxassetid://96681677373844","rbxassetid://121396126155803","rbxassetid://121842208464560"},
        replaceMeshId = "rbxassetid://80612596590820",
        replaceTexId  = "rbxassetid://123233413518598",
        replaceSize   = Vector3.new(0.8,0.8,0.8),
    },
}

-- fuzzy tool classifier: look at the tool name for a match
U.SKIN_TOOL_KEYS = {
    {pat="sniper",          key="Sniper"},
    {pat="operator",        key="SniperOp"},
    {pat="dagger",          key="Daggers"},
    {pat="satchel",         key="Satchel"},
    {pat="reaver",          key="Reaver"},
    {pat="rpg",             key="RPG"},
    {pat="fist",            key="Fists"},
    {pat="bow",             key="Bow"},
    {pat="assault",         key="AR"},
    {pat="rifle",           key="AR"},
    {pat="tripmine",        key="TripmineSpike"},
    {pat="dice",            key="TripmineDice"},
    {pat="camera",          key="Camera"},
    {pat="sky",             key="Sky"},
    {pat="grenade",         key="GrenadeRaze"},
}

local function _classifyTool(tool)
    if not tool then return nil end
    local n = (tool.Name or ""):lower()
    for _,ent in ipairs(U.SKIN_TOOL_KEYS) do
        if n:find(ent.pat, 1, true) then return ent.key end
    end
    return nil
end

local function _applySkinSpec(tool, spec)
    if not tool or not spec then return end
    local applied = tool:GetAttribute("UE3_SkinApplied")
    if applied == spec.label then return end
    for _,desc in ipairs(tool:GetDescendants()) do
        pcall(function()
            if desc:IsA("SpecialMesh") then
                local mid = desc.MeshId
                local shouldRemove = false
                if spec.removeMeshIds then
                    for _,rm in ipairs(spec.removeMeshIds) do if mid == rm then shouldRemove = true; break end end
                end
                if spec.removeMeshId and mid == spec.removeMeshId then shouldRemove = true end
                if shouldRemove then desc.Parent = nil; return end
                local matchBody = spec.bodyMeshIds and table.find(spec.bodyMeshIds, mid)
                if matchBody and spec.bodyReplaceMesh then
                    desc.MeshId = spec.bodyReplaceMesh
                    if spec.bodyReplaceTex then desc.TextureId = spec.bodyReplaceTex end
                    if spec.replaceSize then desc.Scale = spec.replaceSize end
                    if spec.replaceOffset and desc.Parent and desc.Parent:IsA("BasePart") then desc.Offset = spec.replaceOffset end
                    return
                end
                local matchSrc = spec.sourceMeshIds and table.find(spec.sourceMeshIds, mid)
                if matchSrc and spec.replaceMeshId then
                    desc.MeshId = spec.replaceMeshId
                    if spec.replaceTexId then desc.TextureId = spec.replaceTexId end
                    if spec.replaceSize then desc.Scale = spec.replaceSize end
                end
                local matchMag = spec.magMeshIds and table.find(spec.magMeshIds, mid)
                if matchMag and spec.magReplaceMesh then
                    desc.MeshId = spec.magReplaceMesh
                    if spec.magReplaceTex then desc.TextureId = spec.magReplaceTex end
                end
                local matchArrow = spec.arrowMeshIds and table.find(spec.arrowMeshIds, mid)
                if matchArrow and spec.arrowReplaceMesh then
                    desc.MeshId = spec.arrowReplaceMesh
                    if spec.arrowReplaceTex then desc.TextureId = spec.arrowReplaceTex end
                end
            end
        end)
    end
    pcall(function() tool:SetAttribute("UE3_SkinApplied", spec.label) end)
end

U._skinSnap = {}
U._skinOwned = {}

local function _toolOf(pl)
    local ch = pl and pl.Character
    if not ch then return nil end
    return ch:FindFirstChildOfClass("Tool")
end

local function _handleOf(tool)
    return tool and tool:FindFirstChild("Handle") or nil
end

local function _skinSnapshot(tool)
    if U._skinSnap[tool] then return end
    local h = _handleOf(tool); if not h then return end
    U._skinSnap[tool] = {
        color   = h.Color,
        mat     = h.Material,
        trans   = h.Transparency,
        reflect = h.Reflectance,
    }
end

local function _skinRevert(tool)
    local snap = U._skinSnap[tool]; if not snap then return end
    local h = _handleOf(tool); if h then
        pcall(function()
            h.Color = snap.color; h.Material = snap.mat
            h.Transparency = snap.trans; h.Reflectance = snap.reflect
        end)
        local glow = h:FindFirstChild("UE3Glow"); if glow then glow:Destroy() end
    end
    U._skinSnap[tool] = nil
    U._skinOwned[tool] = nil
end

local function _paintHandle(tool)
    local h = _handleOf(tool); if not h then return end
    _skinSnapshot(tool); U._skinOwned[tool] = true
    local style = O.SkinStyle or "Solid"
    local col = Color3.fromRGB(tonumber(O.SkinR or 255) or 255, tonumber(O.SkinG or 80) or 80, tonumber(O.SkinB or 200) or 200)
    local trans = tonumber(O.SkinTrans or 0) or 0
    local reflect = tonumber(O.SkinReflect or 0) or 0
    pcall(function()
        h.Color = col; h.Transparency = trans; h.Reflectance = reflect
        if style == "Neon" then h.Material = Enum.Material.Neon
        elseif style == "Glass" then h.Material = Enum.Material.Glass
        elseif style == "ForceField" then h.Material = Enum.Material.ForceField
        elseif style == "Plastic" then h.Material = Enum.Material.Plastic
        else h.Material = Enum.Material.SmoothPlastic end
    end)
    if O.SkinHideMesh then
        for _,m in ipairs(h:GetChildren()) do if m:IsA("SpecialMesh") then pcall(function() m.TextureId = "" end) end end
    end
    if T.SkinGlow then
        local glow = h:FindFirstChild("UE3Glow")
        if not glow then
            glow = Instance.new("PointLight"); glow.Name = "UE3Glow"
            glow.Range = tonumber(O.SkinGlowRange or 8) or 8
            glow.Brightness = tonumber(O.SkinGlowBright or 2) or 2
            glow.Color = col; glow.Parent = h
        else glow.Color = col; glow.Range = tonumber(O.SkinGlowRange or 8) or 8 end
    else
        local glow = h:FindFirstChild("UE3Glow"); if glow then glow:Destroy() end
    end
end

local function _skinApply(tool)
    if not tool then return end
    _paintHandle(tool)
    if O.SkinUseAssetMap then
        local key = _classifyTool(tool)
        local spec = key and U.SKIN_MAP[key]
        if spec then _applySkinSpec(tool, spec) end
    end
end

local function skinTick()
    local target = O.SkinTarget or "Self"
    if target == "Self" then
        local tool = _toolOf(LP)
        if tool then _skinApply(tool) end
    else
        for _,pl in ipairs(Players:GetPlayers()) do
            local tool = _toolOf(pl); if tool then _skinApply(tool) end
        end
    end
end

-- Equip-swap: fire immediately on tool equip + runtime mesh additions
U._skinToolConns = {}
local function _bindToolForSkin(tool)
    if not tool or not tool:IsA("Tool") then return end
    if U._skinToolConns[tool] then return end
    local conns = {}
    _skinApply(tool)
    table.insert(conns, tool.DescendantAdded:Connect(function(_)
        if T.SkinOn then task.defer(function() _skinApply(tool) end) end
    end))
    table.insert(conns, tool.AncestryChanged:Connect(function(_, parent)
        if not parent then
            for _,c in ipairs(conns) do pcall(function() c:Disconnect() end) end
            U._skinToolConns[tool] = nil
            _skinRevert(tool)
        end
    end))
    U._skinToolConns[tool] = conns
end
local function _bindCharForSkin(ch)
    if not ch then return end
    C(ch.ChildAdded:Connect(function(c) if T.SkinOn and c:IsA("Tool") then _bindToolForSkin(c) end end))
    for _,c in ipairs(ch:GetChildren()) do if c:IsA("Tool") then _bindToolForSkin(c) end end
end
if LP.Character then _bindCharForSkin(LP.Character) end
C(LP.CharacterAdded:Connect(_bindCharForSkin))

----------------------------------------------------------------
-- STAFF DETECTOR (scan GetChildren of PlayerGui / Backpack for admin/staff tools or badges)
----------------------------------------------------------------
U._staffSeen = {}
local STAFF_KEYS = {"admin","mod","staff","owner","developer","mdlg","mdlgame"}
local function _nameHasStaffKey(name)
    if not name then return false end
    local n = name:lower()
    for _,k in ipairs(STAFF_KEYS) do if n:find(k,1,true) then return true end end
    return false
end

local function staffTick()
    for _,pl in ipairs(Players:GetPlayers()) do
        if pl ~= LP then
            local flagged = false
            local bp = pl:FindFirstChildOfClass("Backpack")
            if bp then for _,it in ipairs(bp:GetChildren()) do if _nameHasStaffKey(it.Name) then flagged=true; break end end end
            if not flagged and pl.Character then
                for _,it in ipairs(pl.Character:GetChildren()) do if it:IsA("Tool") and _nameHasStaffKey(it.Name) then flagged=true; break end end
            end
            if flagged and not U._staffSeen[pl] then
                U._staffSeen[pl] = true
                warn(("[UE3 staff] flagged: %s"):format(pl.Name))
                local act = O.StaffAction or "Notify"
                if act == "Leave" then pcall(function() Players.LocalPlayer:Kick("staff detected") end)
                elseif act == "Evade" then
                    T.AAOn = true
                    local hrp = U.Char and U.Char.hrp
                    if hrp then pcall(function() hrp.CFrame = hrp.CFrame + Vector3.new(0, 500, 0) end) end
                end
            elseif not flagged and U._staffSeen[pl] then
                U._staffSeen[pl] = nil
            end
        end
    end
end

----------------------------------------------------------------
-- TARGET HUD (floating panel showing current target info)
----------------------------------------------------------------
U._thud = nil
local function _buildTargetHud()
    if U._thud then return U._thud end
    local sg = Instance.new("ScreenGui"); sg.Name = "UE3_THUD"; sg.IgnoreGuiInset = true; sg.ResetOnSpawn = false
    local f = Instance.new("Frame"); f.Size = UDim2.fromOffset(180, 76)
    f.Position = UDim2.new(0, 20, 0.5, -38); f.BackgroundColor3 = Color3.fromRGB(16,16,20)
    f.BackgroundTransparency = 0.15; f.BorderSizePixel = 0
    local corner = Instance.new("UICorner"); corner.CornerRadius = UDim.new(0,6); corner.Parent = f
    local stroke = Instance.new("UIStroke"); stroke.Color = ac(); stroke.Thickness = 1; stroke.Parent = f
    local name = Instance.new("TextLabel"); name.BackgroundTransparency=1
    name.Position = UDim2.fromOffset(10,6); name.Size = UDim2.new(1,-20,0,16)
    applyFont(name, F.capFace, F.capEnum); name.TextSize = 13; name.TextXAlignment = Enum.TextXAlignment.Left
    name.TextColor3 = Color3.fromRGB(230,230,240); name.Text = "--"; name.Parent = f
    local hp = Instance.new("TextLabel"); hp.BackgroundTransparency=1
    hp.Position = UDim2.fromOffset(10,26); hp.Size = UDim2.new(1,-20,0,14)
    applyFont(hp, F.capFace, F.capEnum); hp.TextSize = 11; hp.TextXAlignment = Enum.TextXAlignment.Left
    hp.TextColor3 = Color3.fromRGB(180,180,200); hp.Text = ""; hp.Parent = f
    local dist = Instance.new("TextLabel"); dist.BackgroundTransparency=1
    dist.Position = UDim2.fromOffset(10,42); dist.Size = UDim2.new(1,-20,0,14)
    applyFont(dist, F.capFace, F.capEnum); dist.TextSize = 11; dist.TextXAlignment = Enum.TextXAlignment.Left
    dist.TextColor3 = Color3.fromRGB(180,180,200); dist.Text = ""; dist.Parent = f
    local bar = Instance.new("Frame"); bar.Position = UDim2.fromOffset(10,60); bar.Size = UDim2.fromOffset(160,4)
    bar.BackgroundColor3 = Color3.fromRGB(40,40,50); bar.BorderSizePixel = 0; bar.Parent = f
    local fill = Instance.new("Frame"); fill.Size = UDim2.fromScale(1,1); fill.BackgroundColor3 = ac(); fill.BorderSizePixel=0; fill.Parent = bar
    pcall(function() sg.Parent = game:GetService("CoreGui") end)
    f.Parent = sg
    U._thud = {gui=sg, name=name, hp=hp, dist=dist, fill=fill, stroke=stroke}
    return U._thud
end
local function _killTargetHud()
    if U._thud then pcall(function() U._thud.gui:Destroy() end); U._thud = nil end
end
local function targetHudTick()
    local h = _buildTargetHud()
    if not curTarget or not curTarget.Character then
        h.name.Text = "--"; h.hp.Text = ""; h.dist.Text = ""; h.fill.Size = UDim2.fromScale(0,1); return
    end
    local hum = curTarget.Character:FindFirstChildOfClass("Humanoid")
    local hrp = curTarget.Character:FindFirstChild("HumanoidRootPart")
    local myh = U.Char and U.Char.hrp
    h.name.Text = curTarget.Name
    if hum then
        local pct = (hum.MaxHealth > 0) and (hum.Health/hum.MaxHealth) or 0
        h.hp.Text = ("hp %d / %d"):format(math.floor(hum.Health+0.5), math.floor(hum.MaxHealth+0.5))
        h.fill.Size = UDim2.fromScale(math.clamp(pct,0,1), 1)
        h.fill.BackgroundColor3 = (pct<0.33) and Color3.fromRGB(230,70,70) or (pct<0.66) and Color3.fromRGB(230,180,70) or ac()
    else h.hp.Text = ""; h.fill.Size = UDim2.fromScale(0,1) end
    if hrp and myh then h.dist.Text = ("%d studs"):format((hrp.Position - myh.Position).Magnitude) end
    h.stroke.Color = ac()
end

----------------------------------------------------------------
-- HIT MARKER (brief crosshair flash on registered hit)
----------------------------------------------------------------
U._hmGui = nil
U._hmUntil = 0
local function _buildHitMarker()
    if U._hmGui then return U._hmGui end
    local sg = Instance.new("ScreenGui"); sg.Name="UE3_HM"; sg.IgnoreGuiInset=true; sg.ResetOnSpawn=false
    local frame = Instance.new("Frame"); frame.AnchorPoint=Vector2.new(0.5,0.5)
    frame.Position = UDim2.fromScale(0.5,0.5); frame.Size = UDim2.fromOffset(16,16)
    frame.BackgroundTransparency = 1; frame.Visible = false; frame.Parent = sg
    for i=1,4 do
        local b = Instance.new("Frame"); b.BackgroundColor3 = ac(); b.BorderSizePixel = 0
        if i==1 then b.Position=UDim2.fromOffset(0,0); b.Size=UDim2.fromOffset(6,2)
        elseif i==2 then b.Position=UDim2.fromOffset(10,0); b.Size=UDim2.fromOffset(6,2)
        elseif i==3 then b.Position=UDim2.fromOffset(0,14); b.Size=UDim2.fromOffset(6,2)
        else b.Position=UDim2.fromOffset(10,14); b.Size=UDim2.fromOffset(6,2) end
        b.Parent = frame
    end
    pcall(function() sg.Parent = game:GetService("CoreGui") end)
    U._hmGui = {gui=sg, frame=frame}
    return U._hmGui
end
-- flash trigger: wrap hpTrackTick's hit detection via public helper
U.HitMarkerFlash = function() U._hmUntil = os.clock() + (tonumber(O.HitMarkerDur or 0.15) or 0.15) end
local function hitMarkerTick()
    local m = _buildHitMarker()
    m.frame.Visible = (os.clock() < U._hmUntil)
end
-- also flash from damage path
local _origPlayHit = playHitSound
playHitSound = function(kind)
    _origPlayHit(kind)
    if kind == "hit" and T.HitMarkerOn then U.HitMarkerFlash() end
end

----------------------------------------------------------------
-- GHOST BOX (visualize fake-position decoy for FakePos mode)
----------------------------------------------------------------
U._ghostPart = nil
local function _killGhost() if U._ghostPart then pcall(function() U._ghostPart:Destroy() end); U._ghostPart=nil end end
local function ghostBoxTick()
    if (O.AttackPos or "Normal") ~= "FakePos" or not spatialFakeReal then _killGhost(); return end
    if not U._ghostPart or not U._ghostPart.Parent then
        local p = Instance.new("Part"); p.Anchored=true; p.CanCollide=false; p.CanQuery=false; p.CanTouch=false; p.Massless=true
        p.Size = Vector3.new(2, 5, 2); p.Material = Enum.Material.ForceField
        p.Transparency = 0.5; p.Color = ac()
        pcall(function() p.Parent = Workspace end)
        local box = Instance.new("SelectionBox"); box.Adornee = p; box.LineThickness = 0.04; box.Color3 = ac(); box.Parent = p
        U._ghostPart = p
    end
    pcall(function() U._ghostPart.CFrame = CFrame.new(spatialFakeReal); U._ghostPart.Color = ac() end)
end

----------------------------------------------------------------
-- RAINBOW ACCENT (pulse ac() through HSV)
----------------------------------------------------------------
U._rainbowH = 0
local function rainbowTick(dt)
    U._rainbowH = (U._rainbowH + (tonumber(O.RainbowSpd or 0.2) or 0.2) * (dt or 1/60)) % 1
    local col = Color3.fromHSV(U._rainbowH, O.RainbowSat or 0.9, O.RainbowVal or 1)
    if U._setAccent then pcall(U._setAccent, col) end
end

----------------------------------------------------------------
-- NO-RECOIL (zero camera-CFrame delta applied by viewmodel)
----------------------------------------------------------------
U._camLastCF = nil
local function noRecoilTick()
    local cam = Workspace.CurrentCamera; if not cam then return end
    if not T.NoRecoil then U._camLastCF = cam.CFrame; return end
    local tool = LP.Character and LP.Character:FindFirstChildOfClass("Tool")
    if not tool then U._camLastCF = cam.CFrame; return end
    if U._camLastCF then
        local d = cam.CFrame.Rotation * U._camLastCF.Rotation:Inverse()
        local pitch = math.asin(-d.LookVector.Y)
        if math.abs(pitch) > 0.001 and pitch > 0 then
            pcall(function() cam.CFrame = CFrame.new(cam.CFrame.Position) * (U._camLastCF.Rotation) end)
        end
    end
    U._camLastCF = cam.CFrame
end

----------------------------------------------------------------
-- BUNNYHOP (auto-jump while Space held and grounded)
----------------------------------------------------------------
local function bhopTick()
    if not T.Bhop then return end
    local hum = U.Char and U.Char.hum; if not hum then return end
    if hum:GetState() == Enum.HumanoidStateType.Landed or hum.FloorMaterial ~= Enum.Material.Air then
        if UIS:IsKeyDown(Enum.KeyCode.Space) then pcall(function() hum:ChangeState(Enum.HumanoidStateType.Jumping) end) end
    end
end

----------------------------------------------------------------
-- AIR-STALL (zero vertical vel while key held)
----------------------------------------------------------------
local function airStallTick()
    if not T.AirStall then return end
    local hrp = U.Char and U.Char.hrp; if not hrp then return end
    if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then
        pcall(function() hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, 0, hrp.AssemblyLinearVelocity.Z) end)
    end
end

----------------------------------------------------------------
-- TRIGGERBOT (fire when crosshair falls on enemy)
----------------------------------------------------------------
local function triggerTick()
    if not T.Trigger then return end
    local cam = Workspace.CurrentCamera; if not cam then return end
    local origin = cam.CFrame.Position
    local dir = cam.CFrame.LookVector * (tonumber(O.TriggerRange or 500) or 500)
    local params = RaycastParams.new(); params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {LP.Character, cam}
    local hit = Workspace:Raycast(origin, dir, params)
    if hit and hit.Instance then
        local ch = hit.Instance:FindFirstAncestorOfClass("Model")
        local pl = ch and Players:GetPlayerFromCharacter(ch)
        if pl and pl ~= LP then
            local now = os.clock(); U._trigLast = U._trigLast or 0
            if now - U._trigLast >= (tonumber(O.TriggerCd or 0.1) or 0.1) then
                U._trigLast = now
                if doFire then pcall(doFire) end
            end
        end
    end
end

----------------------------------------------------------------
-- TRANSLOCATOR (mark + blink back to mark)
----------------------------------------------------------------
U._translocMark = nil
U._translocMarkPart = nil
U._translocLast = 0
U._translocTraces = {}

local function _drawTranslocMark()
    if not T.TranslocShowMark then
        if U._translocMarkPart then pcall(function() U._translocMarkPart:Destroy() end); U._translocMarkPart=nil end
        return
    end
    if not U._translocMark then return end
    if not U._translocMarkPart or not U._translocMarkPart.Parent then
        local p = Instance.new("Part"); p.Anchored=true; p.CanCollide=false; p.CanQuery=false; p.CanTouch=false
        p.Size = Vector3.new(2,0.1,2); p.Material = Enum.Material.Neon; p.Color = ac(); p.Transparency = 0.3
        pcall(function() p.Parent = Workspace end)
        local sb = Instance.new("SelectionBox"); sb.Adornee = p; sb.LineThickness = 0.05; sb.Color3 = ac(); sb.Parent = p
        local bb = Instance.new("BillboardGui"); bb.Size = UDim2.fromOffset(80,24); bb.StudsOffset = Vector3.new(0,2,0); bb.AlwaysOnTop = true; bb.Parent = p
        local lbl = Instance.new("TextLabel"); lbl.BackgroundTransparency=1; lbl.Size=UDim2.fromScale(1,1)
        applyFont(lbl, F.capFace, F.capEnum); lbl.TextSize = 12; lbl.TextColor3 = ac(); lbl.Text = "mark"; lbl.Parent = bb
        U._translocMarkPart = p
    end
    pcall(function() U._translocMarkPart.CFrame = U._translocMark end)
end

local function _translocDropMark()
    local hrp = U.Char and U.Char.hrp; if not hrp then return end
    U._translocMark = hrp.CFrame
    _drawTranslocMark()
end

local function _translocBlink()
    if not U._translocMark then return end
    local hrp = U.Char and U.Char.hrp; if not hrp then return end
    local now = os.clock(); local cd = tonumber(O.TranslocCd or 0.4) or 0.4
    if now - U._translocLast < cd then return end
    U._translocLast = now
    local mode = O.TranslocMode or "Instant"
    local fromCF = hrp.CFrame; local toCF = U._translocMark
    if mode == "Echo" then
        -- neon trail segment
        local part = Instance.new("Part"); part.Anchored=true; part.CanCollide=false; part.CanQuery=false; part.CanTouch=false
        local d = (toCF.Position - fromCF.Position); local dist = d.Magnitude
        if dist > 0.5 then
            part.Size = Vector3.new(0.3,0.3,dist); part.CFrame = CFrame.lookAt(fromCF.Position + d*0.5, toCF.Position)
            part.Material = Enum.Material.Neon; part.Color = ac(); part.Transparency = 0.1
            pcall(function() part.Parent = Workspace end)
            task.delay(0.5, function() pcall(function() part:Destroy() end) end)
        end
        pcall(function() hrp.CFrame = toCF end)
    elseif mode == "Smooth" then
        local dur = tonumber(O.TranslocTime or 0.15) or 0.15
        local t0 = os.clock()
        task.spawn(function()
            while true do
                local a = (os.clock() - t0) / dur
                if a >= 1 then break end
                local newCF = fromCF:Lerp(toCF, a)
                pcall(function() hrp.CFrame = newCF end)
                task.wait()
            end
            pcall(function() hrp.CFrame = toCF end)
        end)
    else
        pcall(function() hrp.CFrame = toCF end)
    end
    if T.TranslocClearVel then pcall(function() hrp.AssemblyLinearVelocity = Vector3.zero end) end
end

-- key binding wire
C(UIS.InputBegan:Connect(function(inp, gpe)
    if gpe then return end
    if not T.TranslocOn then return end
    local mk = K.TranslocMarkKey and K.TranslocMarkKey.k
    local bk = K.TranslocBlinkKey and K.TranslocBlinkKey.k
    if mk and inp.KeyCode == mk then _translocDropMark()
    elseif bk and inp.KeyCode == bk then _translocBlink() end
end))

local function translocTick()
    if not T.TranslocOn then
        if U._translocMarkPart then pcall(function() U._translocMarkPart:Destroy() end); U._translocMarkPart=nil end
        return
    end
    _drawTranslocMark()
    if U._translocMarkPart then pcall(function()
        local sb = U._translocMarkPart:FindFirstChildOfClass("SelectionBox"); if sb then sb.Color3 = ac() end
        U._translocMarkPart.Color = ac()
    end) end
end

----------------------------------------------------------------
-- ANTI-TRANSLOCATOR (detect sudden position jumps on other players)
----------------------------------------------------------------
U._antiTransLast = {}  -- pl -> {pos=Vector3, t=number}
U._antiTransFlags = {}  -- pl -> {at=t, from=Vector3, to=Vector3}

local function _antiTransNotify(pl, dist)
    warn(("[UE3 anti-trans] %s jumped %d studs"):format(pl.Name, math.floor(dist)))
end

local function _antiTransSpawnTrace(fromPos, toPos, dur)
    local part = Instance.new("Part"); part.Anchored=true; part.CanCollide=false; part.CanQuery=false; part.CanTouch=false
    local d = (toPos - fromPos); local dist = d.Magnitude
    if dist < 1 then return end
    part.Size = Vector3.new(0.2,0.2,dist); part.CFrame = CFrame.lookAt(fromPos + d*0.5, toPos)
    part.Material = Enum.Material.Neon; part.Color = Color3.fromRGB(240,70,80); part.Transparency = 0.15
    pcall(function() part.Parent = Workspace end)
    task.delay(dur or 2, function() pcall(function() part:Destroy() end) end)
end

local function antiTranslocTick()
    local now = os.clock()
    local thresh = tonumber(O.AntiTranslocDist or 25) or 25
    local act = O.AntiTranslocAct or "Trace"
    for _,pl in ipairs(Players:GetPlayers()) do
        if pl ~= LP and pl.Character then
            local hrp = pl.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local last = U._antiTransLast[pl]
                if last then
                    local dt = now - last.t
                    if dt > 0 and dt < 0.5 then
                        local d = (hrp.Position - last.pos).Magnitude
                        -- flag only if displacement vs small dt is huge (ignore normal walk/run ~20 studs/s)
                        if d > thresh and d/dt > 80 then
                            U._antiTransFlags[pl] = {at=now, from=last.pos, to=hrp.Position}
                            if act == "Notify" then _antiTransNotify(pl, d)
                            elseif act == "Trace" then _antiTransSpawnTrace(last.pos, hrp.Position, tonumber(O.AntiTranslocTrace or 2) or 2); _antiTransNotify(pl, d)
                            end
                        end
                    end
                end
                U._antiTransLast[pl] = {pos=hrp.Position, t=now}
            end
        end
    end
end

----------------------------------------------------------------
-- ACTIVE-LIST SCHEDULER
----------------------------------------------------------------
-- entries: {name, kind="frame"|"hz"|"gated", hz=, fn=, pred=, nextAt=0, tier=1..3}
-- tier 1: always runs (hud/status/fps)
-- tier 2: aim/hook-adjacent (aim, fire, aa, strafe-restore, world, move, peek)
-- tier 3: expensive/background (esp, hp-track, df-esc, backtrack, df, fp, void)
local Entries = {
    {name="hud",      kind="frame", tier=1, fn=function() end},  -- reserved
    {name="status",   kind="hz",    tier=1, hz=10, fn=statusTick, pred=function() return true end},
    {name="fps",      kind="frame", tier=1, fn=fpsTick, pred=function() return true end},
    {name="aim",      kind="frame", tier=2, fn=aimTick, pred=function() return T.RageOn or T.Silent end},
    {name="fire",     kind="frame", tier=2, fn=fireTick, pred=function() return T.AutoFire or T.AutoShoot end},
    {name="fovvis",   kind="hz",    tier=2, hz=10, fn=fovTick, pred=function() return T.FovVis end},
    {name="aa",       kind="frame", tier=2, fn=aaTick, pred=function() return T.AAOn end},
    {name="world",    kind="hz",    tier=2, hz=5, fn=worldTick, pred=function() return T.NoFog or T.FB or T.CFov end},
    {name="move",     kind="hz",    tier=2, hz=10, fn=moveTick, pred=function() return T.WsOn or T.JpOn or T.Noclip end},
    {name="peek",     kind="frame", tier=2, fn=peekTick, pred=function() return T.PeekOn end},
    {name="strafe",   kind="frame", tier=2, fn=strafeRestoreTick, pred=function() return U._strafeRestoreAt~=0 end},
    {name="esp",      kind="hz",    tier=3, hz=5,  fn=espTick, pred=function() return T.EspOn or T.ChamsOn end, dyn=function() return tonumber(O.EspRateHz or "10") or 10 end},
    {name="hp",       kind="hz",    tier=3, hz=10, fn=hpTrackTick, pred=function() return T.EspHealth end},
    {name="bt",       kind="hz",    tier=3, hz=30, fn=function() for _,p in ipairs(Players:GetPlayers()) do if p~=LP then bt_push(p) end end end, pred=function() return T.BTOn end},
    {name="ragePos",  kind="hz",    tier=2, hz=60, fn=ragePosTick, pred=function() return T.RageOn and (O.AttackPos or "Normal") ~= "Normal" and aimPos end},
    {name="marker",   kind="frame", tier=3, fn=markerTick, pred=function() return #U._markers>0 end},
    {name="tracer",   kind="frame", tier=3, fn=tracerTick, pred=function() return #U._tracers>0 end},
    {name="skin",     kind="hz",    tier=3, hz=4,  fn=function() skinTick() end, pred=function() return T.SkinOn end},
    {name="staff",    kind="hz",    tier=3, hz=2,  fn=function() staffTick() end, pred=function() return T.StaffDetectOn end},
    {name="thud",     kind="hz",    tier=3, hz=10, fn=function() targetHudTick() end, pred=function() return T.TargetHudOn end},
    {name="hitmark",  kind="frame", tier=3, fn=function() hitMarkerTick() end, pred=function() return T.HitMarkerOn end},
    {name="ghost",    kind="hz",    tier=3, hz=20, fn=function() ghostBoxTick() end, pred=function() return T.GhostBoxOn and (O.AttackPos or "Normal") == "FakePos" end},
    {name="rainbow",  kind="frame", tier=2, fn=rainbowTick, pred=function() return T.RainbowOn end},
    {name="norec",    kind="frame", tier=2, fn=noRecoilTick, pred=function() return T.NoRecoil end},
    {name="bhop",     kind="frame", tier=2, fn=bhopTick, pred=function() return T.Bhop end},
    {name="astall",   kind="frame", tier=2, fn=airStallTick, pred=function() return T.AirStall end},
    {name="trigger",  kind="hz",    tier=2, hz=30, fn=triggerTick, pred=function() return T.Trigger end},
    {name="transloc", kind="hz",    tier=3, hz=10, fn=translocTick, pred=function() return T.TranslocOn end},
    {name="antitrans",kind="hz",    tier=3, hz=10, fn=antiTranslocTick, pred=function() return T.AntiTranslocOn end},
}

local function dueGated(now, name) return true, function() end end

local function schedulerTick()
    local t0 = os.clock()
    U._tickNow = t0
    local BUDGET = 0.002  -- 2ms
    local tier = 1
    local overran = false
    for tier=1,3 do
        if overran then U.OverrunN += 1; break end
        for _,e in ipairs(Entries) do
            if e.tier ~= tier then continue end
            if e.pred and not e.pred() then continue end
            local due = true; local commit
            if e.kind == "hz" then
                e.nextAt = e.nextAt or 0
                if t0 < e.nextAt then due=false
                else local hz = (e.dyn and e.dyn()) or e.hz; commit = function() e.nextAt = t0 + 1/hz end end
            elseif e.kind == "gated" then
                due, commit = dueGated(t0, e.name)
            end
            if not due then continue end
            local fs = os.clock()
            local ok, err = pcall(e.fn)
            local el = os.clock() - fs
            U.Cost[e.name] = el * 1000
            if not ok then
                local st = U._pcwState[e.name]; if not st then st={fails=0,lastWarn=0,dead=false}; U._pcwState[e.name]=st end
                st.fails += 1; if os.clock()-st.lastWarn>1 then st.lastWarn=os.clock(); warn("[UE3 "..e.name.."] "..tostring(err)) end
                if st.fails>=10 then st.dead=true end
            else if commit then commit() end end
            if (os.clock() - t0) > BUDGET then overran = true; break end
        end
    end

    U._lastTickMs = (os.clock() - t0) * 1000
end

-- Staggered scheduler start: aligns with splash end so the load frame stays quiet.
task.delay(SPLASH_DURATION + 0.2, function()
    C(RunService.Heartbeat:Connect(schedulerTick))
    warn("[UE3] scheduler online")
end)

-- anti-afk
pcall(function() C(LP.Idled:Connect(function()
    if T.AntiAfk then local vim = game:GetService("VirtualUser"); pc(function() vim:CaptureController(); vim:ClickButton2(Vector2.new()) end) end
end)) end)

-- deferred clean of crash mark
task.delay(10, function() if os.clock()-sessionStart>=10 then clearCrashMark() end end)

U.LoadTimings.total = math.floor((os.clock()-LOAD_T0)*1000+0.5)
warn(("[UE3] load %dms (deferred load follows on next frame)"):format(U.LoadTimings.total))

----------------------------------------------------------------
-- UNLOAD
----------------------------------------------------------------
U.Unload = function()
    clearCrashMark()
    for _,c in ipairs(U.Con) do pcall(function() c:Disconnect() end) end
    for _,d in ipairs(U.Draw) do pcall(function() d:Remove() end) end
    for _,s in pairs(slotMap) do pcall(function() s.hl:Destroy() end) end
    for i=1,#pool do pcall(function() pool[i].hl:Destroy() end) end
    if voidCamAnchor then pcall(function() voidCamAnchor:Destroy() end) end
    if fpCamAnchor then pcall(function() fpCamAnchor:Destroy() end) end
    pcall(function() Camera.CameraSubject = U.Char.hum end)
    pcall(function() Lighting.FogEnd=origFog; Lighting.Brightness=origBrt; Camera.FieldOfView=70 end)
    pcall(function() Screen:Destroy() end)
    U._observeLog,U._sig,U._sigLearned,U._lastFire,U._pcwState = nil,nil,nil,nil,nil
    U._hpLast,U._dmgLog,U._dpsBucket,U._selfDrops,U._attackerHits = nil,nil,nil,nil,nil
    U._inHook = nil
    _memFS = {}
    getgenv().UE3 = nil
end
