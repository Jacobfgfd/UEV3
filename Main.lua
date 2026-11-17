--[==[
    UNNAMED ENHANCEMENTS V3
    built by olivia  //  discord.gg/ojailbreaks
--]==]

----------------------------------------------------------------
-- BOOT: safe mode, last-toggle crash guard, module timing
----------------------------------------------------------------
local SAFE_MODE = false -- set true to load GUI only, no hooks / no loops

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

-- hard unload previous instance before anything else
if getgenv().UE3 and getgenv().UE3.Unload then pcall(getgenv().UE3.Unload) end

local U = {
    Opt={}, Tog={}, Key={}, Con={}, Draw={}, Esp={}, Pool={},
    SelfPath={}, BT={}, Sum={shots=0,hits=0,kills=0,misses=0},
    Accent = Color3.fromRGB(186,255,0), -- acid lime
    Char={}, Modules={}, Timings={}, RunOnce={},
    LastToggle=nil, _inHook=false,
}
getgenv().UE3 = U
local O,T,K,Sum = U.Opt,U.Tog,U.Key,U.Sum
local function C(c) table.insert(U.Con,c); return c end
local function D(d) table.insert(U.Draw,d); return d end
local function pc(f,...) local ok,r=pcall(f,...); return ok and r end
-- rate-limited pcall wrapper: 1 warn/sec per label, auto-disable after 10 fails
U._pcwState = U._pcwState or {}
local function pcw(label,f,...)
    local st = U._pcwState[label]; if not st then st={fails=0, lastWarn=0, dead=false}; U._pcwState[label]=st end
    if st.dead then return nil end
    local ok,r = pcall(f,...)
    if not ok then
        st.fails = st.fails + 1
        local now = os.clock()
        if now - st.lastWarn > 1 then st.lastWarn = now; warn(("[UE3 %s] %s (%d)"):format(label, tostring(r), st.fails)) end
        if st.fails >= 10 then st.dead=true; warn(("[UE3 %s] disabled after 10 throws"):format(label)) end
    else
        if st.fails > 0 then st.fails = math.max(0, st.fails-1) end
    end
    return r
end
U._pcwKilled = function() local t={}; for k,v in pairs(U._pcwState) do if v.dead then table.insert(t,k) end end; return t end

-- crash guard: persist last-toggled key; on next load, start it OFF
-- executor-aware io: pcall-wrapped, falls back to in-memory table on mobile / no fs
local CRASH_FILE = "UE3_last_toggle.txt"
local _memFS = {}
local function _isfile(n) local ok,r=pcall(function() return isfile and isfile(n) end); if ok and r then return true end; return _memFS[n]~=nil end
local function _readfile(n) if _memFS[n] then return _memFS[n] end; local ok,r=pcall(function() return readfile and readfile(n) end); return ok and r or nil end
local function _writefile(n,s) _memFS[n]=s; pcall(function() if writefile then writefile(n,s) end end) end
local function _delfile(n) _memFS[n]=nil; pcall(function() if delfile then delfile(n) end end) end
local lastCrashedFeature
if _isfile(CRASH_FILE) then lastCrashedFeature = _readfile(CRASH_FILE); _delfile(CRASH_FILE) end
local sessionStart = os.clock()
local function recordToggle(k) U.LastToggle = k; _writefile(CRASH_FILE, k) end
local function clearCrashMark() _delfile(CRASH_FILE) end

----------------------------------------------------------------
-- character cache
----------------------------------------------------------------
local function clearCharCache() U.Char = {ch=nil, hrp=nil, hum=nil, head=nil} end
local function rebuildCharCache(ch)
    U.Char = {ch = ch, hrp = ch and ch:FindFirstChild("HumanoidRootPart"), hum = ch and ch:FindFirstChildOfClass("Humanoid"), head = ch and ch:FindFirstChild("Head")}
end
rebuildCharCache(LP.Character)
local function wireDied(ch) pcall(function() C(ch:WaitForChild("Humanoid").Died:Connect(clearCharCache)) end) end
C(LP.CharacterAdded:Connect(function(ch) rebuildCharCache(ch); wireDied(ch) end))
if LP.Character then wireDied(LP.Character) end

local function alive(p)
    if not p then return false end
    if p==LP then return U.Char.hum and U.Char.hum.Health>0 end
    local ch=p.Character; return ch and ch.Parent and ch:FindFirstChild("HumanoidRootPart") and ch:FindFirstChildOfClass("Humanoid") and ch:FindFirstChildOfClass("Humanoid").Health>0
end
local function enemy(p) if not T.IgnTeam then return true end; return p.Team~=LP.Team end
local function w2s(v) local p,on=Camera:WorldToViewportPoint(v); return Vector2.new(p.X,p.Y),on,p.Z end

----------------------------------------------------------------
-- palette, fonts, builders
----------------------------------------------------------------
local P = {
    bg  = Color3.fromRGB(12,13,16),
    pn  = Color3.fromRGB(18,19,24),
    pn2 = Color3.fromRGB(24,26,32),
    pn3 = Color3.fromRGB(32,34,42),
    el  = Color3.fromRGB(40,42,52),
    hl  = Color3.fromRGB(60,64,78),
    tx  = Color3.fromRGB(228,230,236),
    sub = Color3.fromRGB(158,162,172),
    dim = Color3.fromRGB(96,100,112),
    gn  = Color3.fromRGB(110,220,140),
    rd  = Color3.fromRGB(235,85,100),
    yw  = Color3.fromRGB(240,200,80),
}
local function ac() return U.Accent end

local F = { lbl=Enum.Font.GothamMedium, body=Enum.Font.Gotham, mono=Enum.Font.Code, cap=Enum.Font.GothamBold }

local function N(cls, props) local i=Instance.new(cls); for k,v in pairs(props or {}) do i[k]=v end; return i end
local function pd(p,l,r,t,b) N("UIPadding",{PaddingLeft=UDim.new(0,l),PaddingRight=UDim.new(0,r or l),PaddingTop=UDim.new(0,t or l),PaddingBottom=UDim.new(0,b or t or l),Parent=p}) end
local function hairline(parent, dir, pos) local d = N("Frame",{BackgroundColor3=P.hl,BorderSizePixel=0,Parent=parent}); if dir=="h" then d.Size=UDim2.new(1,0,0,1); d.Position=pos or UDim2.new(0,0,0,0) else d.Size=UDim2.new(0,1,1,0); d.Position=pos or UDim2.new(0,0,0,0) end; return d end

----------------------------------------------------------------
-- GUI build (detached; parented at the end only)
----------------------------------------------------------------
local Screen = N("ScreenGui",{IgnoreGuiInset=true,ResetOnSpawn=false,ZIndexBehavior=Enum.ZIndexBehavior.Sibling,DisplayOrder=1e6,Name="_ue3_"..math.random(1e6,1e7-1)})
local Root = N("Frame",{Size=UDim2.fromOffset(620,420),Position=UDim2.new(0.5,-310,0.5,-210),BackgroundColor3=P.bg,BorderSizePixel=0,Parent=Screen,Active=true,ClipsDescendants=true})
N("UICorner",{CornerRadius=UDim.new(0,2),Parent=Root})
N("UIStroke",{Color=P.hl,Thickness=1,Parent=Root,ApplyStrokeMode=Enum.ApplyStrokeMode.Border})

-- one root gradient fade (allowed; everything else gets zero gradients)
local gradBG = N("Frame",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Parent=Root,ZIndex=0})
N("UIGradient",{Rotation=135,Color=ColorSequence.new{ColorSequenceKeypoint.new(0,P.pn),ColorSequenceKeypoint.new(1,P.bg)},Parent=N("Frame",{Size=UDim2.new(1,0,1,0),BackgroundColor3=P.pn,BorderSizePixel=0,Parent=gradBG})})

-- angled diagonal header block (no uniform centered titlebar)
local TB = N("Frame",{Size=UDim2.new(1,0,0,30),BackgroundColor3=P.pn,BorderSizePixel=0,Parent=Root})
hairline(TB,"h",UDim2.new(0,0,1,-1))
local accentBar = N("Frame",{Size=UDim2.fromOffset(4,30),BackgroundColor3=ac(),BorderSizePixel=0,Parent=TB})
local TitleL = N("TextLabel",{Size=UDim2.fromOffset(240,30),Position=UDim2.fromOffset(16,0),BackgroundTransparency=1,Text="UNNAMED ENHANCEMENTS",Font=F.lbl,TextSize=11,TextColor3=P.tx,TextXAlignment=Enum.TextXAlignment.Left,Parent=TB})
N("UIPadding",{PaddingTop=UDim.new(0,2),Parent=TitleL}) -- gothic feel via vertical nudge
local VerTag = N("TextLabel",{Size=UDim2.fromOffset(40,30),Position=UDim2.fromOffset(188,0),BackgroundTransparency=1,Text="v3",Font=F.mono,TextSize=11,TextColor3=ac(),TextXAlignment=Enum.TextXAlignment.Left,Parent=TB})
local attrib = N("TextLabel",{Size=UDim2.fromOffset(260,30),Position=UDim2.new(1,-300,0,0),BackgroundTransparency=1,Text="built by olivia  //  discord.gg/ojailbreaks",Font=F.mono,TextSize=10,TextColor3=P.sub,TextXAlignment=Enum.TextXAlignment.Right,Parent=TB})

local closeX = N("TextButton",{Size=UDim2.fromOffset(28,18),Position=UDim2.new(1,-34,0,6),BackgroundColor3=P.pn2,BorderSizePixel=0,Text="×",Font=F.lbl,TextSize=14,TextColor3=P.rd,AutoButtonColor=false,Parent=TB})
closeX.MouseButton1Click:Connect(function() if U.Unload then U.Unload() end end)

-- drag
do local dr,sm,sp
    TB.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dr=true; sm=i.Position; sp=Root.Position end end)
    TB.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dr=false end end)
    C(UIS.InputChanged:Connect(function(i) if dr and i.UserInputType==Enum.UserInputType.MouseMovement then local d=i.Position-sm; Root.Position=UDim2.new(sp.X.Scale,sp.X.Offset+d.X,sp.Y.Scale,sp.Y.Offset+d.Y) end end))
end

-- icon rail + content pane + status bar (no card-per-setting)
local Rail = N("Frame",{Size=UDim2.new(0,46,1,-52),Position=UDim2.fromOffset(0,30),BackgroundColor3=P.pn,BorderSizePixel=0,Parent=Root})
hairline(Rail,"v",UDim2.new(1,-1,0,0))
pd(Rail,4,4,6,6)
N("UIListLayout",{Padding=UDim.new(0,2),Parent=Rail})

local Search = N("TextBox",{Size=UDim2.new(1,-54,0,22),Position=UDim2.fromOffset(50,34),BackgroundColor3=P.pn,BorderSizePixel=0,Text="",PlaceholderText="search",PlaceholderColor3=P.dim,Font=F.body,TextSize=11,TextColor3=P.tx,TextXAlignment=Enum.TextXAlignment.Left,ClearTextOnFocus=false,Parent=Root})
pd(Search,10)
hairline(Search,"h",UDim2.new(0,0,1,-1))

local Content = N("Frame",{Size=UDim2.new(1,-54,1,-82),Position=UDim2.fromOffset(50,56),BackgroundColor3=P.bg,BorderSizePixel=0,Parent=Root})
pd(Content,10,10,8,8)

-- bottom status bar: fps / ping / active / divergence / build
local SB = N("Frame",{Size=UDim2.new(1,0,0,22),Position=UDim2.new(0,0,1,-22),BackgroundColor3=P.pn,BorderSizePixel=0,Parent=Root})
hairline(SB,"h")
pd(SB,10,10,2,2)
local sbL = N("TextLabel",{Size=UDim2.new(0.6,0,1,0),BackgroundTransparency=1,Text="",Font=F.mono,TextSize=10,TextColor3=P.sub,TextXAlignment=Enum.TextXAlignment.Left,Parent=SB})
local sbR = N("TextLabel",{Size=UDim2.new(0.4,-10,1,0),Position=UDim2.new(0.6,0,0,0),BackgroundTransparency=1,Text="",Font=F.mono,TextSize=10,TextColor3=ac(),TextXAlignment=Enum.TextXAlignment.Right,Parent=SB})

----------------------------------------------------------------
-- tabs + rows (density: 22-24px rows, hairline dividers, no cards)
----------------------------------------------------------------
local pages, tabs, current = {}, {}, nil
local function selectTab(name)
    current=name
    for n,v in pairs(tabs) do
        v.btn.BackgroundColor3 = n==name and P.pn3 or P.pn
        v.ico.TextColor3 = n==name and ac() or P.dim
        pages[n].Visible = n==name
    end
end
local function Tab(name, icon)
    local b = N("TextButton",{Size=UDim2.new(1,0,0,36),BackgroundColor3=P.pn,BorderSizePixel=0,Text="",AutoButtonColor=false,Parent=Rail})
    local ico = N("TextLabel",{Size=UDim2.new(1,0,0,22),Position=UDim2.fromOffset(0,4),BackgroundTransparency=1,Text=icon or "·",Font=F.lbl,TextSize=14,TextColor3=P.dim,Parent=b})
    local lbl = N("TextLabel",{Size=UDim2.new(1,0,0,10),Position=UDim2.fromOffset(0,24),BackgroundTransparency=1,Text=string.sub(name,1,4),Font=F.mono,TextSize=9,TextColor3=P.sub,Parent=b})
    local p = N("ScrollingFrame",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,ScrollBarThickness=2,ScrollBarImageColor3=ac(),CanvasSize=UDim2.new(0,0,0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y,BorderSizePixel=0,Visible=false,Parent=Content})
    N("UIListLayout",{Padding=UDim.new(0,6),Parent=p})
    pages[name]=p; tabs[name]={btn=b,lbl=lbl,ico=ico}
    b.MouseButton1Click:Connect(function() selectTab(name) end)
    return p
end

local function Group(parent, title)
    local w = N("Frame",{Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1,Parent=parent})
    N("TextLabel",{Size=UDim2.new(1,0,0,14),BackgroundTransparency=1,Text=string.upper(title),Font=F.lbl,TextSize=10,TextColor3=P.sub,TextXAlignment=Enum.TextXAlignment.Left,Parent=w})
    hairline(w,"h",UDim2.new(0,0,0,14))
    local col = N("Frame",{Size=UDim2.new(1,0,0,0),Position=UDim2.new(0,0,0,18),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1,Parent=w})
    N("UIListLayout",{Padding=UDim.new(0,2),Parent=col})
    return col
end

local allRows = {}
local function addRow(label, parent)
    local r = N("Frame",{Size=UDim2.new(1,0,0,22),BackgroundTransparency=1,Parent=parent})
    table.insert(allRows,{row=r,text=string.lower(label)})
    return r
end

-- widgets
local function Toggle(p,k,t)
    T[k]=T[k] or false
    local r = addRow(t,p)
    r.Size=UDim2.new(1,0,0,22)
    local hitbox = N("TextButton",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",AutoButtonColor=false,Parent=r})
    N("TextLabel",{Size=UDim2.new(1,-40,1,0),BackgroundTransparency=1,Text=t,Font=F.body,TextSize=11,TextColor3=P.tx,TextXAlignment=Enum.TextXAlignment.Left,Parent=r})
    local track = N("Frame",{Size=UDim2.fromOffset(28,14),Position=UDim2.new(1,-30,0.5,-7),BackgroundColor3=T[k] and ac() or P.el,BorderSizePixel=0,Parent=r})
    N("UICorner",{CornerRadius=UDim.new(1,0),Parent=track})
    local knob = N("Frame",{Size=UDim2.fromOffset(10,10),Position=UDim2.fromOffset(T[k] and 16 or 2,2),BackgroundColor3=Color3.new(1,1,1),BorderSizePixel=0,Parent=track})
    N("UICorner",{CornerRadius=UDim.new(1,0),Parent=knob})
    hitbox.MouseButton1Click:Connect(function()
        T[k]=not T[k]; recordToggle(k)
        TweenService:Create(track,TweenInfo.new(0.09),{BackgroundColor3=T[k] and ac() or P.el}):Play()
        TweenService:Create(knob,TweenInfo.new(0.09),{Position=T[k] and UDim2.fromOffset(16,2) or UDim2.fromOffset(2,2)}):Play()
    end)
    return r
end

local function Slider(p,k,t,d,mn,mx,st,sx)
    O[k]=(O[k]==nil) and d or O[k]
    local v=O[k]
    local r = addRow(t,p); r.Size=UDim2.new(1,0,0,22)
    N("TextLabel",{Size=UDim2.new(0.55,0,1,0),BackgroundTransparency=1,Text=t,Font=F.body,TextSize=11,TextColor3=P.tx,TextXAlignment=Enum.TextXAlignment.Left,Parent=r})
    local vl = N("TextLabel",{Size=UDim2.new(0.18,0,1,0),Position=UDim2.new(0.57,0,0,0),BackgroundTransparency=1,Text=tostring(v)..(sx or ""),Font=F.mono,TextSize=11,TextColor3=ac(),TextXAlignment=Enum.TextXAlignment.Right,Parent=r})
    local bar = N("TextButton",{Size=UDim2.new(0.22,-4,0,2),Position=UDim2.new(0.77,0,0.5,-1),BackgroundColor3=P.hl,BorderSizePixel=0,Text="",AutoButtonColor=false,Parent=r})
    local fill = N("Frame",{Size=UDim2.new((v-mn)/(mx-mn),0,1,0),BackgroundColor3=ac(),BorderSizePixel=0,Parent=bar})
    local knob = N("Frame",{Size=UDim2.fromOffset(6,10),Position=UDim2.new((v-mn)/(mx-mn),-3,0.5,-5),BackgroundColor3=ac(),BorderSizePixel=0,Parent=bar})
    local dr=false
    local function set(x, fine)
        local rel=math.clamp((x-bar.AbsolutePosition.X)/bar.AbsoluteSize.X,0,1)
        local val=mn+(mx-mn)*rel; local useStep = (st or 1) * (fine and 0.1 or 1)
        if useStep then val=math.floor(val/useStep+0.5)*useStep end; val=math.clamp(val,mn,mx)
        O[k]=val; fill.Size=UDim2.new(rel,0,1,0); knob.Position=UDim2.new(rel,-3,0.5,-5)
        vl.Text=((st and st>=1) and tostring(math.floor(val)) or string.format("%.2f",val))..(sx or "")
    end
    bar.MouseButton1Down:Connect(function() dr=true; set(UIS:GetMouseLocation().X, UIS:IsKeyDown(Enum.KeyCode.LeftShift)) end)
    r.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dr=true; set(UIS:GetMouseLocation().X, UIS:IsKeyDown(Enum.KeyCode.LeftShift)) end end)
    C(UIS.InputChanged:Connect(function(i) if dr and i.UserInputType==Enum.UserInputType.MouseMovement then set(i.Position.X, UIS:IsKeyDown(Enum.KeyCode.LeftShift)) end end))
    C(UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dr=false end end))
end

local function Dropdown(p,k,t,vs,d)
    O[k]=(O[k]==nil) and d or O[k]
    local r = addRow(t,p); r.Size=UDim2.new(1,0,0,22)
    N("TextLabel",{Size=UDim2.new(0.55,0,1,0),BackgroundTransparency=1,Text=t,Font=F.body,TextSize=11,TextColor3=P.tx,TextXAlignment=Enum.TextXAlignment.Left,Parent=r})
    local b = N("TextButton",{Size=UDim2.new(0.42,0,0,16),Position=UDim2.new(0.57,0,0.5,-8),BackgroundColor3=P.pn,BorderSizePixel=0,Text=O[k],Font=F.mono,TextSize=10,TextColor3=P.tx,TextXAlignment=Enum.TextXAlignment.Right,AutoButtonColor=false,Parent=r})
    pd(b,4,16,0,0)
    N("TextLabel",{Size=UDim2.fromOffset(12,16),Position=UDim2.new(1,-14,0,0),BackgroundTransparency=1,Text="▾",Font=F.mono,TextSize=10,TextColor3=ac(),Parent=b})
    local list = N("Frame",{Size=UDim2.new(1,0,0,0),Position=UDim2.new(0,0,1,2),BackgroundColor3=P.pn3,BorderSizePixel=0,Visible=false,ZIndex=50,AutomaticSize=Enum.AutomaticSize.Y,Parent=b})
    N("UIListLayout",{Parent=list})
    N("UIStroke",{Color=P.hl,Thickness=1,Parent=list})
    for _,v in ipairs(vs) do
        local it = N("TextButton",{Size=UDim2.new(1,0,0,18),BackgroundColor3=P.pn3,BorderSizePixel=0,Text=v,Font=F.mono,TextSize=10,TextColor3=P.tx,TextXAlignment=Enum.TextXAlignment.Left,AutoButtonColor=false,ZIndex=51,Parent=list})
        pd(it,6,6,0,0)
        it.MouseEnter:Connect(function() it.BackgroundColor3=ac(); it.TextColor3=P.bg end)
        it.MouseLeave:Connect(function() it.BackgroundColor3=P.pn3; it.TextColor3=P.tx end)
        it.MouseButton1Click:Connect(function() O[k]=v; b.Text=v; list.Visible=false end)
    end
    b.MouseButton1Click:Connect(function() list.Visible=not list.Visible end)
end

local function Keybind(p,k,t,dk)
    K[k]=K[k] or {k=dk,mode="Hold",state=false,tog=false}
    local r = addRow(t,p); r.Size=UDim2.new(1,0,0,22)
    N("TextLabel",{Size=UDim2.new(0.55,0,1,0),BackgroundTransparency=1,Text=t,Font=F.body,TextSize=11,TextColor3=P.tx,TextXAlignment=Enum.TextXAlignment.Left,Parent=r})
    local function nm(x) return (typeof(x)=="EnumItem") and x.Name or tostring(x) end
    local kb = N("TextButton",{Size=UDim2.new(0.22,0,0,16),Position=UDim2.new(0.57,0,0.5,-8),BackgroundColor3=P.pn,BorderSizePixel=0,Text=nm(dk),Font=F.mono,TextSize=10,TextColor3=ac(),AutoButtonColor=false,Parent=r})
    local mb = N("TextButton",{Size=UDim2.new(0.19,0,0,16),Position=UDim2.new(0.80,0,0.5,-8),BackgroundColor3=P.pn,BorderSizePixel=0,Text="HOLD",Font=F.mono,TextSize=10,TextColor3=P.gn,AutoButtonColor=false,Parent=r})
    local picking=false
    kb.MouseButton1Click:Connect(function() picking=true; kb.Text="..." end)
    C(UIS.InputBegan:Connect(function(i,gp)
        if picking then
            if i.UserInputType==Enum.UserInputType.Keyboard then K[k].k=i.KeyCode
            elseif i.UserInputType==Enum.UserInputType.MouseButton1 then K[k].k="MB1"
            elseif i.UserInputType==Enum.UserInputType.MouseButton2 then K[k].k="MB2" end
            kb.Text=nm(K[k].k); picking=false; return
        end
        if gp then return end
        local kk=K[k]; local m=(kk.k=="MB1" and i.UserInputType==Enum.UserInputType.MouseButton1) or (kk.k=="MB2" and i.UserInputType==Enum.UserInputType.MouseButton2) or (typeof(kk.k)=="EnumItem" and i.KeyCode==kk.k)
        if m then if kk.mode=="Hold" then kk.state=true elseif kk.mode=="Toggle" then kk.tog=not kk.tog; kk.state=kk.tog end end
    end))
    C(UIS.InputEnded:Connect(function(i) local kk=K[k]; local m=(kk.k=="MB1" and i.UserInputType==Enum.UserInputType.MouseButton1) or (kk.k=="MB2" and i.UserInputType==Enum.UserInputType.MouseButton2) or (typeof(kk.k)=="EnumItem" and i.KeyCode==kk.k); if m and kk.mode=="Hold" then kk.state=false end end))
    mb.MouseButton1Click:Connect(function() local nx={Hold="Toggle",Toggle="Always",Always="Hold"}; K[k].mode=nx[K[k].mode]; mb.Text=string.upper(K[k].mode); K[k].state=(K[k].mode=="Always") end)
end

local function Button(p,t,cb)
    local r = addRow(t,p); r.Size=UDim2.new(1,0,0,20)
    local b = N("TextButton",{Size=UDim2.new(1,0,1,0),BackgroundColor3=P.pn3,BorderSizePixel=0,Text=t,Font=F.lbl,TextSize=10,TextColor3=P.tx,AutoButtonColor=false,Parent=r})
    b.MouseEnter:Connect(function() b.BackgroundColor3=ac(); b.TextColor3=P.bg end)
    b.MouseLeave:Connect(function() b.BackgroundColor3=P.pn3; b.TextColor3=P.tx end)
    b.MouseButton1Click:Connect(cb)
end

local function Label(p,t,c) local r=addRow(t,p); N("TextLabel",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text=t,Font=F.mono,TextSize=10,TextColor3=c or P.sub,TextXAlignment=Enum.TextXAlignment.Left,Parent=r}); return r end

-- live search filtering
Search:GetPropertyChangedSignal("Text"):Connect(function()
    local q = string.lower(Search.Text)
    for _,row in ipairs(allRows) do
        row.row.Visible = q=="" or string.find(row.text, q, 1, true)~=nil
    end
end)

----------------------------------------------------------------
-- tab content
----------------------------------------------------------------
do local p = Tab("home","◆")
    local g=Group(p,"overview")
    Label(g," unnamed enhancements v3",ac())
    Label(g," built by olivia")
    Label(g," discord.gg/ojailbreaks",ac())
    Label(g," ")
    Label(g," RightShift  :  toggle menu")
    Label(g," Shift+drag  :  fine slider")
    Label(g," ")
    if lastCrashedFeature then Label(g,"[safe] last-toggled '"..lastCrashedFeature.."' auto-disabled",P.rd) end
    if SAFE_MODE then Label(g,"[SAFE MODE] all hooks and ticks disabled",P.yw) end

    local gk=Group(p,"module health")
    local killRow = Label(gk,"all modules: ok",P.tx)
    local killTxt = killRow:FindFirstChildOfClass("TextLabel")
    task.spawn(function()
        while U._pcwState and killTxt do
            task.wait(1)
            if not Screen or not Screen.Parent then break end
            local dead={}; for k,v in pairs(U._pcwState) do if v.dead then table.insert(dead,k) end end
            if #dead==0 then killTxt.Text = "all modules: ok"; killTxt.TextColor3 = P.tx
            else killTxt.Text = "disabled (10 throws): "..table.concat(dead,", "); killTxt.TextColor3 = P.rd end
        end
    end)
    Button(gk,"reset module kill-state",function() for k,v in pairs(U._pcwState) do v.dead=false; v.fails=0 end end)
    Button(gk,"export last observe log",function()
        local out={}; for sig,_ in pairs(U._observeLog or {}) do table.insert(out, sig) end
        _writefile("UE3_observe.txt", table.concat(out,"\n"))
        warn("[UE3] observe log → UE3_observe.txt ("..#out.." sigs)")
    end)
end

do local p = Tab("rage","◉")
    local g=Group(p,"core")
    Toggle(g,"RageOn","enable rage")
    Toggle(g,"Silent","silent aim (remote hook)")
    Toggle(g,"MouseHit","mouse.hit hook (detectable)")
    Toggle(g,"AutoFire","auto fire")
    Toggle(g,"ObserveOnly","observe-mode only (log, do not swap)")
    Slider(g,"Fov","fov",120,10,500,5,"px")
    Slider(g,"MaxDist","max distance",2000,50,5000,10,"s")
    Slider(g,"FireRate","shots / sec",8,1,30,1)
    Dropdown(g,"KeyMode","key mode",{"Always","Hold","Toggle"},"Hold")
    Keybind(g,"RageKey","aim key","MB2")

    local g2=Group(p,"target")
    Dropdown(g2,"Prio","sort",{"ClosestToCrosshair","ClosestToPlayer","LowestHP","Distance","Random"},"ClosestToCrosshair")
    Toggle(g2,"VisOnly","visible only")
    Toggle(g2,"IgnTeam","ignore team")
    Toggle(g2,"LockTgt","lock target until dead")
    Slider(g2,"SwitchDly","switch delay",0.05,0,1,0.01,"s")

    local g3=Group(p,"hitbox")
    Dropdown(g3,"HB","hitbox",{"Head","UpperTorso","Torso","HumanoidRootPart"},"Head")
    Toggle(g3,"ForceHS","force head")
    Toggle(g3,"ForceBaim","force body")

    local g4=Group(p,"validation")
    Slider(g4,"ConeDeg","cone angle",8,1,45,1,"°")
    Dropdown(g4,"ConeMode","beyond cone",{"Clamp","Abort","Raw"},"Clamp")
    Toggle(g4,"ObserveOnly","observe mode (log remotes, no swap)")
    Toggle(g4,"ObserveAll","observe ALL namecalls (RemoteEvent/Function only)")
    Slider(g4,"ObserveN","observe log cap (unique sigs)",120,16,400,4)
    Toggle(g4,"ReplayLast","record last fire args")
    Button(g4,"replay last captured args (raw, isolated)",function()
        local r=U._lastFire; if not r then warn("[UE3 replay] no capture"); return end
        -- Force isolation: temporarily disable every swap path + silent aim, so replay tests ONLY the raw remote.
        local saved = { Silent=T.Silent, RageOn=T.RageOn, MouseHit=T.MouseHit, VoidOn=T.VoidOn, DFOn=T.DFOn, FPOn=T.FPOn, ObserveOnly=T.ObserveOnly, ObserveAll=T.ObserveAll, ReplayLast=T.ReplayLast }
        T.Silent, T.RageOn, T.MouseHit, T.VoidOn, T.DFOn, T.FPOn, T.ObserveOnly, T.ObserveAll, T.ReplayLast = false,false,false,false,false,false,false,false,false
        -- Mark the remote so its own hook falls through immediately
        U._inHook[r.self] = true
        local okFire, err = pcall(function()
            if r.method=="FireServer" then return r.self:FireServer(table.unpack(r.args,1,r.n))
            elseif r.method=="InvokeServer" then return r.self:InvokeServer(table.unpack(r.args,1,r.n)) end
        end)
        U._inHook[r.self] = nil
        for k,v in pairs(saved) do T[k] = v end
        if not okFire then warn("[UE3 replay] "..tostring(err)) else warn("[UE3 replay] re-fired "..r.sig.." — watch for Humanoid.Health deltas on target") end
    end)
    Slider(g4,"HandoffMs","handoff window",60,20,300,5,"ms")
    Toggle(g4,"HandoffPing","scale handoff by ping (handoff + ping/2)")
    Slider(g4,"HcMin","min hitchance",70,0,100,1,"%")
    Slider(g4,"HcSmp","hc samples",8,2,16,1)
    Toggle(g4,"PredOn","velocity lead")
    Slider(g4,"PredF","lead factor",0.14,0,0.5,0.01,"s")
    Toggle(g4,"BTOn","backtrack")
    Slider(g4,"BTMs","backtrack ms",200,0,500,10,"ms")
end

do local p = Tab("aa","◁")
    local g=Group(p,"master")
    Toggle(g,"AAOn","enable anti-aim")
    Dropdown(g,"AABase","base",{"Backwards","AtTarget","Freestand","Jitter","Spin","Zero"},"AtTarget")
    Slider(g,"AADesync","desync",58,0,60,1,"°")
    Keybind(g,"AAInvert","invert",Enum.KeyCode.X)
    local g2=Group(p,"pitch")
    Toggle(g2,"AAPOn","pitch")
    Dropdown(g2,"AAPitch","pitch mode",{"Down","Up","Zero","Jitter"},"Down")
    local g3=Group(p,"extras")
    Toggle(g3,"OnShot","on-shot flip")
    Slider(g3,"OnShotMs","on-shot ms",220,50,500,10,"ms")
    Toggle(g3,"AAArrow","arrow hud")
end

do local p = Tab("void","◈")
    local g=Group(p,"voidspam")
    Toggle(g,"VoidOn","enable voidspam")
    Dropdown(g,"VoidMode","anchor",{"BelowTarget","BelowNearest","BelowMap"},"BelowTarget")
    Slider(g,"VoidDepthMin","depth min",10,1,100,1,"s")
    Slider(g,"VoidDepthMax","depth max",40,1,200,1,"s")
    Slider(g,"VoidMapY","below-map Y",-300,-1000,0,10,"s")
    Toggle(g,"VoidNoclip","auto-noclip")
    Slider(g,"VoidShootMin","handoff min",40,20,200,5,"ms")
    Slider(g,"VoidShootMax","handoff max",70,20,300,5,"ms")
    Keybind(g,"VoidKey","void key",Enum.KeyCode.Z)
    Dropdown(g,"VoidKeyMode","key mode",{"Hold","Toggle","Always"},"Hold")
end

do local p = Tab("field","◇")
    local g=Group(p,"displacement field")
    Label(g,"replaces voidspam fixed-depth when on",P.yw)
    Toggle(g,"DFOn","enable field")
    -- "None" = no positional defense at all. "Flat" = voidspam-equivalent (fixed depth).
    Dropdown(g,"DFPreset","shape",{"None","Flat","Lissajous","Coil","Chaos"},"Lissajous")
    Slider(g,"DFAmp","amplitude",15,2,80,1,"s")
    Slider(g,"DFHorizMax","horiz clamp",4,0,10,0.5,"s")
    Toggle(g,"DFEscalate","escalate on repeat hits")
    Toggle(g,"DFPerLife","per-life seed reroll")
    local g2=Group(p,"fake pos")
    Toggle(g2,"FPOn","enable fake pos")
    Slider(g2,"FPDepth","depth",25,5,200,1,"s")
    Toggle(g2,"FPNoclip","auto-noclip")
    Slider(g2,"FPShootMs","handoff",80,20,300,5,"ms")
    Keybind(g2,"FPKey","toggle",Enum.KeyCode.V)
end

do local p = Tab("esp","✦")
    local g=Group(p,"drawings")
    Toggle(g,"EspOn","enable esp")
    Toggle(g,"EspBox","box")
    Dropdown(g,"EspBoxS","box style",{"corner","full","outlined"},"corner")
    Toggle(g,"EspName","name")
    Toggle(g,"EspDist","distance")
    Toggle(g,"EspHealth","health bar")
    Toggle(g,"EspTool","equipped tool")
    Toggle(g,"EspTracer","tracer")
    Toggle(g,"EspSkel","skeleton")
    Toggle(g,"EspOff","offscreen arrow")
    Slider(g,"EspMaxDist","max draw dist",800,50,3000,10,"s")
    Slider(g,"EspFont","font size",13,8,22,1)

    local g2=Group(p,"chams")
    Toggle(g2,"ChamsOn","enable chams")
    Dropdown(g2,"ChamsMat","material",{"ForceField","Neon","Plastic"},"ForceField")
    Slider(g2,"ChamsFill","fill alpha",0.4,0,1,0.05)
    Toggle(g2,"ChamsVis","visible color swap")

    local g3=Group(p,"sound")
    Toggle(g3,"SoundESP","footstep arcs")
end

do local p = Tab("qol","✎")
    local g=Group(p,"peek / motion")
    Toggle(g,"PeekOn","peek assist")
    Keybind(g,"PeekKey","peek key",Enum.KeyCode.Q)
    Slider(g,"PeekDist","peek distance",6,1,12,0.5,"s")
    Toggle(g,"CounterStrafe","counter-strafe on shot (zero→restore)")
    Slider(g,"StrafeRestoreMs","strafe restore delay",80,20,250,5,"ms")
    Toggle(g,"AutoReload","auto reload (safe)")

    local g2=Group(p,"tracking / hud")
    Toggle(g2,"DmgNumbers","damage numbers")
    Toggle(g2,"DPSReadout","dps readout")
    Toggle(g2,"FightLog","fight log (8 events)")
    Toggle(g2,"HitboxVis","hitbox visualiser")
    Toggle(g2,"LeadReadout","lead-offset readout")
    Toggle(g2,"DebugOverlay","debug overlay (real vs replicated)")

    local g3=Group(p,"session")
    Toggle(g3,"FpsCap","frame limiter (coop sleep, not a renderer cap)")
    Slider(g3,"FpsCapV","limit",120,30,240,5)
    Toggle(g3,"AntiAfk","anti-afk")
    Toggle(g3,"AutoRejoin","auto rejoin on disconnect")
    Toggle(g3,"FrameGraph","frame graph")
end

do local p = Tab("world","✵")
    local g=Group(p,"environment")
    Toggle(g,"NoFog","no fog")
    Toggle(g,"FB","fullbright")
    Slider(g,"FBV","brightness",2,0,10,0.1)
    Toggle(g,"CFov","camera fov override")
    Slider(g,"CFovV","fov",70,1,120,1)
    local g2=Group(p,"movement")
    Toggle(g2,"WsOn","walkspeed")
    Slider(g2,"Ws","value",16,16,300,1)
    Toggle(g2,"JpOn","jumppower")
    Slider(g2,"Jp","value",50,50,500,1)
    Toggle(g2,"InfJump","infinite jump")
    Toggle(g2,"Noclip","noclip")
end

do local p = Tab("ui","⚙")
    local g=Group(p,"theme")
    local accents = {{n="lime",c=Color3.fromRGB(186,255,0)},{n="magenta",c=Color3.fromRGB(255,80,220)},{n="amber",c=Color3.fromRGB(255,176,0)},{n="cyan",c=Color3.fromRGB(80,230,255)},{n="red",c=Color3.fromRGB(235,85,100)}}
    local ai=1
    Button(g,"cycle accent",function()
        ai=ai%#accents+1; U.Accent=accents[ai].c
        accentBar.BackgroundColor3=U.Accent; VerTag.TextColor3=U.Accent; sbR.TextColor3=U.Accent
    end)
    Keybind(g,"MenuKey","menu toggle",Enum.KeyCode.RightShift)

    local g2=Group(p,"config")
    Button(g2,"save default",function()
        if not writefile then return end
        local d={O={},T={}}; for k,v in pairs(O) do if type(v)~="function" and typeof(v)~="Color3" then d.O[k]=v end end
        for k,v in pairs(T) do d.T[k]=v end
        pc(writefile,"UE3_default.json",HttpService:JSONEncode(d))
    end)
    Button(g2,"load default",function()
        if not (isfile and isfile("UE3_default.json")) then return end
        local ok,d=pcall(function() return HttpService:JSONDecode(readfile("UE3_default.json")) end)
        if ok and d then for k,v in pairs(d.O or {}) do O[k]=v end; for k,v in pairs(d.T or {}) do T[k]=v end end
    end)
    Button(g2,"unload",function() U.Unload() end)
end

selectTab("home")

----------------------------------------------------------------
-- PARENT the GUI only now — after full detached build
----------------------------------------------------------------
pcall(function() if syn and syn.protect_gui then syn.protect_gui(Screen) end end)
local parented = false
local function tryParent(fn)
    if parented then return end
    local ok, target = pcall(fn)
    if ok and target then local ok2 = pcall(function() Screen.Parent = target end); if ok2 then parented = true end end
end
tryParent(function() return gethui and gethui() end)
tryParent(function() return CoreGui end)
tryParent(function() return LP:WaitForChild("PlayerGui", 5) end)
-- auto re-parent on PlayerGui reset (game-triggered GUI wipes)
C(LP.CharacterAdded:Connect(function()
    task.defer(function()
        if Screen and not Screen.Parent then
            local pg = LP:FindFirstChildOfClass("PlayerGui"); if pg then pcall(function() Screen.Parent = pg end) end
        end
    end)
end))
U.Screen = Screen

-- auto-disable the feature that crashed last session
if lastCrashedFeature and T[lastCrashedFeature] ~= nil then T[lastCrashedFeature] = false end

----------------------------------------------------------------
if SAFE_MODE then
    sbL.Text = "SAFE MODE — GUI only"
    U.Unload = function() for _,c in ipairs(U.Con) do pcall(function() c:Disconnect() end) end; pcall(function() Screen:Destroy() end); clearCrashMark(); getgenv().UE3=nil end
    return
end
----------------------------------------------------------------

----------------------------------------------------------------
-- backtrack (cheap: 30Hz)
----------------------------------------------------------------
local function bt_push(p)
    if not alive(p) then return end
    local hrp=p.Character.HumanoidRootPart; local buf=U.BT[p] or {}; U.BT[p]=buf
    table.insert(buf,1,{t=os.clock(),pos=hrp.Position})
    while buf[#buf] and os.clock()-buf[#buf].t>0.5 do buf[#buf]=nil end
end
local function bt_sample(p,ms) local buf=U.BT[p]; if not buf then return nil end; local tg=os.clock()-ms/1000; for _,r in ipairs(buf) do if r.t<=tg then return r end end; return buf[1] end

----------------------------------------------------------------
-- RAGE: target pick + silent aim + remote hook
----------------------------------------------------------------
local aimPos, curTarget, lastSwitch, lastShotAt = nil, nil, 0, 0

local function bestHitbox(ch)
    local n = T.ForceHS and "Head" or T.ForceBaim and "UpperTorso" or (O.HB or "Head")
    return ch:FindFirstChild(n) or ch:FindFirstChild("HumanoidRootPart")
end

local function pickTarget()
    local kk=K.RageKey; if O.KeyMode=="Hold" and not kk.state then return nil end
    if O.KeyMode=="Toggle" and not kk.state then return nil end
    if T.LockTgt and curTarget and alive(curTarget) and enemy(curTarget) then return curTarget end
    local m=UIS:GetMouseLocation(); local prio=O.Prio; local best,bs
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=LP and alive(p) and enemy(p) then
            local pt=bestHitbox(p.Character)
            if pt then
                local s,on=w2s(pt.Position); local d3=(pt.Position-Camera.CFrame.Position).Magnitude
                if on and d3<=O.MaxDist then
                    local d2=(s-m).Magnitude
                    if d2<=O.Fov then
                        local sc
                        if prio=="ClosestToCrosshair" then sc=d2
                        elseif prio=="ClosestToPlayer" then sc=d3
                        elseif prio=="LowestHP" then local h=p.Character:FindFirstChildOfClass("Humanoid"); sc=h and h.Health or 100
                        elseif prio=="Distance" then sc=d3
                        else sc=math.random() end
                        if not bs or sc<bs then bs,best=sc,p end
                    end
                end
            end
        end
    end
    return best
end

local function aimTick()
    if not (T.RageOn or T.Silent) then curTarget=nil; aimPos=nil; return end
    local nt=pickTarget()
    if not nt then curTarget=nil; aimPos=nil; return end
    if curTarget~=nt then if os.clock()-lastSwitch<(O.SwitchDly or 0) then return end; lastSwitch=os.clock() end
    curTarget=nt
    local pt=bestHitbox(nt.Character); if not pt then aimPos=nil; return end
    local p=pt.Position
    if T.BTOn then local rec=bt_sample(nt,O.BTMs); if rec then p=rec.pos end end
    if T.PredOn then p = p + pt.AssemblyLinearVelocity*(O.PredF or 0.14) end
    aimPos=p
end

-- Remote hook with reentrancy guard + per-remote signature cache + observe-mode
local mt = getrawmetatable and getrawmetatable(game)
if mt and setreadonly then
    pc(setreadonly, mt, false)
    local oldIdx = mt.__index
    local oldNc  = mt.__namecall
    U._observeLog = {}
    local observeCount = 0

    -- type signature for a call (for cache keying + unfiltered observe)
    local function typeSig(args, n)
        local t={}; for i=1,n do t[i]=typeof(args[i]) end; return table.concat(t,",")
    end

    -- safe up vector: camera up when aim is near-vertical, else Y
    local function safeUp(dir, camUp)
        if math.abs(dir:Dot(Vector3.yAxis)) > 0.99 then return camUp.Unit end
        return Vector3.yAxis
    end

    -- Out-of-cone policy: 1=Clamp (partial correction), 2=Abort (fly original), 3=Raw (ignore cone)
    -- Only rotates when ACTUALLY out of cone (no degenerate axis, no NaN on a zero cross product).
    local function coneHandle(origin, aimPos, coneRad, mode)
        local toAim = aimPos - origin; local dist = toAim.Magnitude
        if dist < 0.001 then return aimPos, Camera.CFrame.LookVector, dist, "inside" end
        local dir = toAim/dist
        local look = Camera.CFrame.LookVector
        local cosA = math.clamp(look:Dot(dir), -1, 1)
        local maxCos = math.cos(coneRad)
        if cosA >= maxCos then return aimPos, dir, dist, "inside" end  -- under the cone: no clamp math at all
        if mode == "Abort" then return nil, nil, dist, "abort" end
        if mode == "Raw"   then return aimPos, dir, dist, "raw" end
        -- Clamp: rotate look toward dir by coneRad on a normalized perpendicular axis.
        local axis = look:Cross(dir)
        if axis.Magnitude < 1e-4 then
            -- aim is parallel-or-antiparallel to look (rare); pick any perpendicular stable axis
            axis = look:Cross(Vector3.yAxis)
            if axis.Magnitude < 1e-4 then axis = look:Cross(Vector3.xAxis) end
        end
        axis = axis.Unit
        local clampedDir = (CFrame.fromAxisAngle(axis, coneRad) * look).Unit
        local clamped = origin + clampedDir * dist
        return clamped, clampedDir, dist, "clamped"
    end

    -- per-remote reentrancy guard table (not a global flag)
    U._inHook = U._inHook or setmetatable({}, {__mode="k"})
    -- learned signatures: only populated during an observe pass with no aim; normal calls that find no entry skip swap
    U._sigLearned = U._sigLearned or {}
    -- cached ping, with floor; nil on GetValueString until Stats warms up
    local function readPingSec()
        local p = 0
        pcall(function()
            local nw = Stats:FindFirstChild("Network"); if not nw then return end
            local si = nw:FindFirstChild("ServerStatsItem"); if not si then return end
            local pp = si:FindFirstChild("Data Ping"); if not pp or not pp.GetValueString then return end
            local s = pp:GetValueString(); local v = s and tonumber(s:match("%d+"))
            if v and v > 0 then p = v end
        end)
        if p < 20 then p = 20 end  -- floor; Data Ping is empty for first seconds
        return p / 1000
    end

    -- learn signature (called from observe pass; only writes on observe-only turns or when no aim)
    local function learnSig(sig, args, n, origin)
        if U._sigLearned[sig] then return U._sig[sig] end
        local known = {dirCount=0, v3Count=0}
        local bestD = -1
        for i=1,n do
            local tt = typeof(args[i])
            if tt == "Vector3" then
                local m = args[i].Magnitude
                known.v3Count = known.v3Count + 1
                if m > 2 then
                    -- POSITION: real-world magnitude, not a unit
                    local d = (args[i] - origin).Magnitude
                    if d > bestD then bestD = d; known.pos = i end
                elseif m <= 1.5 and m > 0.1 then
                    -- DIRECTION: unit-ish vector
                    if not known.dir then known.dir = i end
                    known.dirCount = known.dirCount + 1
                end
            elseif tt == "CFrame" and not known.cf then known.cf = i
            elseif tt == "Ray" and not known.ray then known.ray = i end
        end
        -- Single-Vector3 policy: do NOT promote. A lone unit vector is a direction, not a position.
        -- A lone big vector is a position. Both are already assigned above.
        -- If neither role was assigned (odd zero-mag v3), leave them unset.
        U._sig[sig] = known
        U._sigLearned[sig] = true
        return known
    end

    mt.__namecall = newcclosure(function(self, ...)
        if typeof(self)~="Instance" then return oldNc(self, ...) end
        if U._inHook[self] then return oldNc(self, ...) end  -- per-remote recursion guard
        local method = getnamecallmethod()
        if method ~= "FireServer" and method ~= "InvokeServer" then return oldNc(self, ...) end

        local args = {...}
        local n = select("#", ...)

        -- OBSERVE: log first N UNIQUE signatures (not call count). RemoteEvent/RemoteFunction only.
        if T.ObserveOnly or T.ObserveAll then
            local cls = tostring(self.ClassName)
            if cls:find("Remote") then
                local sig = ("%s::%s(%d)[%s]"):format(cls, self.Name, n, typeSig(args, n))
                if not U._observeLog[sig] and observeCount < (O.ObserveN or 120) then
                    observeCount = observeCount + 1
                    U._observeLog[sig] = true
                    warn(("[UE3 OBSERVE] %s"):format(sig))
                    local preview={}; for i=1,math.min(n,6) do local v=args[i]; local tt=typeof(v); if tt=="number" or tt=="string" or tt=="boolean" then preview[i]=tostring(v) else preview[i]="<"..tt..">" end end
                    if n>0 then warn("    args = {"..table.concat(preview,", ").."}") end
                    -- learn during observe (no mutation, no target required)
                    pcall(learnSig, sig, args, n, Camera.CFrame.Position)
                end
            end
            if T.ObserveOnly then return oldNc(self, ...) end
        end

        -- fast reject if not swapping (also the "prime" path: learn with no aim present)
        local hasAim = aimPos and (T.Silent or T.RageOn)
        local nm = (self.Name or ""):lower()
        local isFire = nm:find("fire") or nm:find("shoot") or nm:find("weapon") or nm:find("bullet") or nm:find("hit") or nm:find("damage") or nm:find("gun") or nm:find("raycast") or nm:find("remote")
        if not isFire then return oldNc(self, ...) end

        local sig = ("%s|%d|%s"):format(self.Name, n, typeSig(args, n))
        if not hasAim then
            -- prime pass: learn silently, do not mutate
            pcall(learnSig, sig, args, n, Camera.CFrame.Position)
            return oldNc(self, ...)
        end

        -- cache capture for replay BEFORE mutation
        if T.ReplayLast then
            local raw={}; for i=1,n do raw[i]=args[i] end
            U._lastFire = {self=self, method=method, args=raw, n=n, sig=self.Name.."|"..n}
        end

        -- cone handling (mode-driven)
        local origin = Camera.CFrame.Position
        local coneRad = math.rad(O.ConeDeg or 8)
        local coneMode = O.ConeMode or "Clamp"
        local clampedAim, dir, dist, coneState = coneHandle(origin, aimPos, coneRad, coneMode)
        if coneState == "abort" then return oldNc(self, ...) end
        local camUp = Camera.CFrame.UpVector

        -- signature lookup (never learn on a mutating call)
        local known = U._sig[sig]
        if not known then
            -- haven't seen this one during observe/prime; swap with conservative defaults using one-shot scan
            pcall(learnSig, sig, args, n, origin)
            known = U._sig[sig]
        end
        if not known or (not known.dir and not known.cf and not known.ray and not known.pos) then
            return oldNc(self, ...)
        end

        -- CAPTURE velocity at handoff entry, BEFORE any drop/write. Restore only Y later.
        local hrpL = U.Char.hrp
        local preVel = hrpL and hrpL.AssemblyLinearVelocity or Vector3.zero

        -- HANDOFF (restore → prev → re-drop). Single timer. Ping-scaled (full ping, not half).
        local handoffMs = O.HandoffMs or 60
        if T.HandoffPing then
            local pingSec = readPingSec()
            handoffMs = handoffMs + pingSec * 1000
        end
        local handoffSec = handoffMs/1000

        U._inHook[self] = true
        local okBody, result = pcall(function()
            if hrpL then
                if T.VoidOn and voidActive and voidActive() and voidCamAnchor then
                    voidShootUntil = os.clock() + handoffSec
                    pc(function() hrpL.CFrame = CFrame.new(voidCamAnchor.Position.X, voidCamAnchor.Position.Y-2, voidCamAnchor.Position.Z) * (hrpL.CFrame - hrpL.CFrame.Position) end)
                end
                if T.DFOn and DF then
                    DF.handoffUntil = os.clock() + handoffSec
                end
                if T.FPOn and fpActive and fpActive() and fpSurfacePos then
                    fpShootUntil = os.clock() + handoffSec
                    pc(function() hrpL.CFrame = CFrame.new(fpSurfacePos) * (hrpL.CFrame - hrpL.CFrame.Position) end)
                end
                -- Y-only restore: keep X/Z that the player is inputting right now
                pc(function()
                    local cur = hrpL.AssemblyLinearVelocity
                    hrpL.AssemblyLinearVelocity = Vector3.new(cur.X, preVel.Y, cur.Z)
                end)
            end

            -- mutate args (coneState "raw" and "clamped" both set clampedAim; "inside" leaves it = aimPos)
            if coneState ~= "raw" then
                if known.pos then args[known.pos] = clampedAim end
                if known.dir then args[known.dir] = dir end
                if known.cf and dist > 2 then args[known.cf] = CFrame.lookAt(origin, clampedAim, safeUp(dir, camUp)) end
                if known.ray then local r = args[known.ray]; if typeof(r)=="Ray" then args[known.ray] = Ray.new(r.Origin, dir * r.Direction.Magnitude) end end
            else
                -- raw: full swap to the real aim, no cone math
                if known.pos then args[known.pos] = aimPos end
                if known.dir then args[known.dir] = (aimPos - origin).Unit end
                if known.cf and dist > 2 then args[known.cf] = CFrame.lookAt(origin, aimPos, safeUp(dir, camUp)) end
                if known.ray then local r = args[known.ray]; if typeof(r)=="Ray" then args[known.ray] = Ray.new(r.Origin, (aimPos-origin).Unit * r.Direction.Magnitude) end end
            end

            return oldNc(self, table.unpack(args, 1, n))
        end)
        U._inHook[self] = nil  -- always release, even on throw
        if not okBody then return oldNc(self, ...) end
        return result
    end)

    -- optional mouse.hit hook (gated off by default — most detectable)
    mt.__index = newcclosure(function(self, k)
        if T.MouseHit and aimPos and T.Silent then
            if self==LP and k=="GetMouse" then
                local real = oldIdx(self,k)
                return function(...) local mm = real(...); pc(function() mm.Hit = CFrame.new(aimPos) end); return mm end
            end
        end
        return oldIdx(self,k)
    end)
    pc(setreadonly, mt, true)
end

----------------------------------------------------------------
-- auto fire (tool:Activate + mouse1)
----------------------------------------------------------------
local function doFire()
    local now=os.clock(); local rate=1/(O.FireRate or 8)
    if now-lastShotAt<rate then return end; lastShotAt=now
    Sum.shots+=1
    if T.CounterStrafe and U.counterStrafeOnFire then pcw("strafe", U.counterStrafeOnFire) end
    pc(function() local t = LP.Character and LP.Character:FindFirstChildOfClass("Tool"); if t then t:Activate() end end)
    pc(function() if mouse1press then mouse1press(); task.wait(); mouse1release() end end)
end
local function fireTick() if T.RageOn and T.AutoFire and curTarget and aimPos then doFire() end end

----------------------------------------------------------------
-- VOIDSPAM (correct order with hook-side handoff)
----------------------------------------------------------------
voidCamAnchor, voidShootUntil = nil, 0
function voidActive()
    if not T.VoidOn then return false end
    local kk=K.VoidKey; local m=O.VoidKeyMode or "Hold"
    if m=="Hold" then return kk.state end
    if m=="Toggle" then return kk.state end
    if m=="Always" then return true end
    return false
end
local function voidPickY()
    if O.VoidMode=="BelowTarget" and curTarget and alive(curTarget) then return curTarget.Character.HumanoidRootPart.Position.Y end
    if O.VoidMode=="BelowNearest" then
        local best,bd
        for _,p in ipairs(Players:GetPlayers()) do if p~=LP and alive(p) and enemy(p) then local pos=p.Character.HumanoidRootPart.Position; local d=(pos-(U.Char.hrp and U.Char.hrp.Position or Vector3.zero)).Magnitude; if not bd or d<bd then bd,best=d,pos.Y end end end
        return best or O.VoidMapY or -300
    end
    return O.VoidMapY or -300
end
local function voidTick()
    if not U.Char.hrp then return end
    local on = voidActive()
    local hrp = U.Char.hrp
    if on then
        if os.clock() < voidShootUntil then return end
        local baseY = voidPickY()
        local depth = (O.VoidDepthMin or 10) + math.random()*((O.VoidDepthMax or 40) - (O.VoidDepthMin or 10))
        local targetY = baseY - depth
        if not voidCamAnchor then
            voidCamAnchor = Instance.new("Part")
            voidCamAnchor.Size=Vector3.new(1,1,1); voidCamAnchor.Transparency=1; voidCamAnchor.Anchored=true; voidCamAnchor.CanCollide=false; voidCamAnchor.CanQuery=false; voidCamAnchor.CanTouch=false; voidCamAnchor.Massless=true; voidCamAnchor.CastShadow=false
            pc(function() voidCamAnchor.Parent = Workspace end)
            pc(function() Camera.CameraSubject = voidCamAnchor end)
        end
        pc(function() voidCamAnchor.CFrame = CFrame.new(hrp.Position.X, hrp.Position.Y+2, hrp.Position.Z) end)
        if T.VoidNoclip then for _,d in ipairs(LP.Character:GetDescendants()) do if d:IsA("BasePart") then pc(function() d.CanCollide=false end) end end end
        pc(function()
            local newCF = CFrame.new(hrp.Position.X, targetY, hrp.Position.Z) * (hrp.CFrame - hrp.CFrame.Position)
            if LP.Character.PivotTo then LP.Character:PivotTo(newCF) else hrp.CFrame = newCF end
            hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, 0, hrp.AssemblyLinearVelocity.Z)
        end)
    else
        if voidCamAnchor then
            pc(function() Camera.CameraSubject = U.Char.hum end)
            pc(function() voidCamAnchor:Destroy() end); voidCamAnchor=nil
        end
    end
end

----------------------------------------------------------------
-- FAKE POSITION
----------------------------------------------------------------
fpCamAnchor, fpSurfacePos, fpShootUntil = nil, nil, 0
U._fpLast = os.clock()
function fpActive() return T.FPOn and K.FPKey.state end -- single toggle for simplicity

local function fpTick()
    if not U.Char.hrp then
        if fpCamAnchor then pc(function() fpCamAnchor:Destroy() end); fpCamAnchor=nil end
        fpSurfacePos=nil; return
    end
    local hrp = U.Char.hrp; local hum = U.Char.hum
    if fpActive() then
        if os.clock()<fpShootUntil then return end
        if not fpSurfacePos then fpSurfacePos = hrp.Position end
        local md = hum and hum.MoveDirection or Vector3.zero
        local spd = hum and hum.WalkSpeed or 16
        local now = os.clock(); local dt = now - U._fpLast; U._fpLast = now
        if md.Magnitude>0.1 then fpSurfacePos = fpSurfacePos + Vector3.new(md.X,0,md.Z)*spd*dt end
        if not fpCamAnchor then
            fpCamAnchor = Instance.new("Part")
            fpCamAnchor.Size=Vector3.new(1,1,1); fpCamAnchor.Transparency=1; fpCamAnchor.Anchored=true; fpCamAnchor.CanCollide=false; fpCamAnchor.CanQuery=false; fpCamAnchor.CanTouch=false; fpCamAnchor.Massless=true; fpCamAnchor.CastShadow=false
            pc(function() fpCamAnchor.Parent=Workspace end)
            pc(function() Camera.CameraSubject=fpCamAnchor end)
        end
        pc(function() fpCamAnchor.CFrame = CFrame.new(fpSurfacePos.X, fpSurfacePos.Y+2, fpSurfacePos.Z) end)
        if T.FPNoclip then for _,d in ipairs(LP.Character:GetDescendants()) do if d:IsA("BasePart") then pc(function() d.CanCollide=false end) end end end
        pc(function() hrp.CFrame = CFrame.new(fpSurfacePos.X, fpSurfacePos.Y-(O.FPDepth or 25), fpSurfacePos.Z) * (hrp.CFrame - hrp.CFrame.Position) end)
    else
        if fpCamAnchor then pc(function() Camera.CameraSubject=U.Char.hum end); pc(function() fpCamAnchor:Destroy() end); fpCamAnchor=nil end
        fpSurfacePos=nil
    end
end

----------------------------------------------------------------
-- DISPLACEMENT FIELD (Jitter / Lissajous / Coil / Chaos)
-- shapes resolvers haven't seen. replaces fixed voidspam depth.
-- random write cadence, per-life seed, horizontal clamp <=4 studs.
----------------------------------------------------------------
local DF = {lastWrite=0, nextDelay=0.02, seed=math.random(), tLife=os.clock(), escBumpUntil=0}
local CADENCES = {0.013,0.016,0.021,0.029,0.034}
local function dfReseed() DF.seed = math.random(); DF.tLife = os.clock() end
C(LP.CharacterAdded:Connect(function() if T.DFPerLife then dfReseed() end end))

local function dfOffsetAt(t)
    local preset = O.DFPreset or "Lissajous"
    local amp = O.DFAmp or 15
    if os.clock()<DF.escBumpUntil then amp = amp * 1.5 end
    if preset=="None" then
        return nil  -- true no-defense; dfTick skips the write entirely
    elseif preset=="Flat" then
        return Vector3.new(0, -amp, 0)  -- voidspam-equivalent fixed depth
    elseif preset=="Lissajous" then
        -- irrational freq ratios on all three axes → path never closes, depth walks too
        local a = 1.37 + DF.seed*0.3
        local b = 1.91 + DF.seed*0.4
        local c = 0.83 + DF.seed*0.27  -- y: slow, non-commensurate with a,b
        local phi = DF.seed*math.pi*2
        local hClamp = math.min(O.DFHorizMax or 4, 4)
        local x = math.sin(t*a + phi) * hClamp
        local z = math.sin(t*b + phi*1.3) * hClamp
        local yWalk = math.sin(t*c + phi*0.7)
        local y = -(amp*0.55) + yWalk * amp * 0.55  -- range: 0 .. -amp*1.1
        return Vector3.new(x, y, z)
    elseif preset=="Coil" then
        local y = -amp + math.sin(t*12)*amp*0.1
        if math.random()<0.02 then y = -(amp*3) end -- rare 1-tick spike
        return Vector3.new(0, y, 0)
    elseif preset=="Chaos" then
        local a, b = 1.37 + DF.seed*0.3, 1.91 + DF.seed*0.4
        local hClamp = math.min(O.DFHorizMax or 4, 4)
        local x = math.sin(t*a) * hClamp
        local z = math.cos(t*b) * hClamp
        local y = -amp + math.sin(t*12)*amp*0.1
        if math.random()<0.02 then y = -(amp*3) end
        return Vector3.new(x, y, z)
    end
    return Vector3.zero
end

local function dfTick()
    if not T.DFOn then return end
    if not U.Char.hrp then return end
    local now = os.clock()
    -- cadence owned here, consumed by scheduler via DF.nextDelay
    DF.nextDelay = CADENCES[math.random(1,#CADENCES)]
    DF.lastWrite = now
    if now < (DF.handoffUntil or 0) then return end  -- during shoot handoff: stay on surface
    local hrp = U.Char.hrp
    local t = now - DF.tLife
    local off = dfOffsetAt(t)
    if not off then return end  -- "None" preset: no-op, true no-positional-defense state
    pc(function()
        local base = hrp.Position
        local target = Vector3.new(base.X + off.X, base.Y + off.Y, base.Z + off.Z)
        local newCF = CFrame.new(target) * (hrp.CFrame - hrp.CFrame.Position)
        if LP.Character.PivotTo then LP.Character:PivotTo(newCF) else hrp.CFrame = newCF end
        hrp.AssemblyLinearVelocity = Vector3.new(0,0,0)
    end)
end

-- escalation: 3 hits from SAME attacker within 1.5s → bump amp 1.5x for 1s.
-- Attacker identity is inferred from who is aimed at us + closest enemy at the moment of the drop.
-- (With no server-sent attacker, this is the best signal available without flag soup.)
local function dfEscalationTick()
    if not T.DFEscalate then return end
    local now = os.clock()
    U._attackerHits = U._attackerHits or {}  -- attackerName -> {t1,t2,...}
    -- consume new drops recorded by hpTrackTick (U._selfDrops), tagging the suspected attacker at drop time
    if U._selfDrops and #U._selfDrops > 0 then
        for _,d in ipairs(U._selfDrops) do
            local a = d.attacker or "unknown"
            U._attackerHits[a] = U._attackerHits[a] or {}
            table.insert(U._attackerHits[a], d.t)
        end
        U._selfDrops = {}
    end
    for a,times in pairs(U._attackerHits) do
        while times[1] and now - times[1] > 1.5 do table.remove(times,1) end
        if #times >= 3 then
            DF.escBumpUntil = now + 1.0
            U._attackerHits[a] = {}
        end
    end
end

----------------------------------------------------------------
-- ANTI-AIM
----------------------------------------------------------------
local onShotUntil = 0
local aaSide=1
local realDesyncYaw=0
local function aaTick()
    if not T.AAOn or not U.Char.hrp or not U.Char.hum then return end
    local hrp=U.Char.hrp; local hum=U.Char.hum
    pc(function() hum.AutoRotate=false end)
    local y,p = 0,0
    local base=O.AABase
    if base=="Backwards" then y=math.pi
    elseif base=="AtTarget" and curTarget and alive(curTarget) then local to=curTarget.Character.HumanoidRootPart.Position-hrp.Position; y=math.atan2(to.X,to.Z)+math.pi
    elseif base=="Freestand" then y=math.pi
    elseif base=="Jitter" then y=((os.clock()*5)%2<1) and math.pi/2 or -math.pi/2
    elseif base=="Spin" then y=(os.clock()*6)%(math.pi*2)
    elseif base=="Zero" then y=0 end
    aaSide=-aaSide; y += math.rad((aaSide>0) and (O.AADesync or 0) or -(O.AADesync or 0))
    if K.AAInvert.state then y=-y end
    if T.OnShot and os.clock()<onShotUntil then y += math.pi end
    if T.AAPOn then
        local pm=O.AAPitch
        if pm=="Down" then p=-math.rad(89) elseif pm=="Up" then p=math.rad(89) elseif pm=="Jitter" then p=((os.clock()*10)%2<1) and -math.rad(89) or math.rad(89) end
    end
    pc(function() hrp.CFrame = CFrame.new(hrp.Position)*CFrame.Angles(p,y,0) end)
    realDesyncYaw = y
end

----------------------------------------------------------------
-- movement / world
----------------------------------------------------------------
local function moveTick()
    if not U.Char.hum then return end
    if T.WsOn then pc(function() U.Char.hum.WalkSpeed=O.Ws end) end
    if T.JpOn then pc(function() U.Char.hum.UseJumpPower=true; U.Char.hum.JumpPower=O.Jp end) end
    if T.Noclip and LP.Character then for _,d in ipairs(LP.Character:GetDescendants()) do if d:IsA("BasePart") then pc(function() d.CanCollide=false end) end end end
end
C(UIS.JumpRequest:Connect(function() if T.InfJump and U.Char.hum then pc(function() U.Char.hum:ChangeState(Enum.HumanoidStateType.Jumping) end) end end))

local origFog=Lighting.FogEnd; local origBrt=Lighting.Brightness
local function worldTick()
    pc(function()
        Lighting.FogEnd = T.NoFog and 1e9 or origFog
        Lighting.Brightness = T.FB and O.FBV or origBrt
        Camera.FieldOfView = T.CFov and O.CFovV or 70
    end)
end

----------------------------------------------------------------
-- PEEK ASSIST + COUNTER-STRAFE
----------------------------------------------------------------
local peekOrigin
local function peekTick()
    if not T.PeekOn or not U.Char.hrp then peekOrigin=nil; return end
    local held = K.PeekKey.state
    if held and not peekOrigin then
        peekOrigin = U.Char.hrp.Position
        -- step out toward camera right
        local dir = Camera.CFrame.RightVector
        pc(function() U.Char.hrp.CFrame = U.Char.hrp.CFrame + dir*(O.PeekDist or 6) end)
    elseif not held and peekOrigin then
        pc(function() U.Char.hrp.CFrame = CFrame.new(peekOrigin) * (U.Char.hrp.CFrame - U.Char.hrp.CFrame.Position) end)
        peekOrigin = nil
    end
end
-- counter-strafe: zero horiz on fire, restore captured velocity after 80ms
U._strafeRestoreAt = 0
U._strafeSaved = Vector3.zero
U.counterStrafeOnFire = function()
    if not T.CounterStrafe or not U.Char.hrp then return end
    local hrp = U.Char.hrp
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
        local v = U._strafeSaved
        if v and v.Magnitude > 0.1 then
            local cur = U.Char.hrp.AssemblyLinearVelocity
            U.Char.hrp.AssemblyLinearVelocity = Vector3.new(v.X, cur.Y, v.Z)
        end
    end)
end

----------------------------------------------------------------
-- HEALTH-DELTA TRACKER (feeds damage numbers, DPS, df escalation)
----------------------------------------------------------------
U._hpLast = U._hpLast or {}      -- pl -> last hp
U._dmgLog = U._dmgLog or {}      -- {t, target, dmg}
U._dpsBucket = U._dpsBucket or {} -- {t, dmg}
U._selfHitLog = U._selfHitLog or {} -- times of hp drops (for df escalation)
local function hpTrackTick()
    local now = os.clock()
    -- enemy health deltas
    for _,pl in ipairs(Players:GetPlayers()) do
        if pl ~= LP and pl.Character then
            local hum = pl.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                local last = U._hpLast[pl]
                if last and hum.Health < last - 0.01 then
                    local dmg = last - hum.Health
                    table.insert(U._dmgLog, {t=now, target=pl, dmg=dmg})
                    table.insert(U._dpsBucket, {t=now, dmg=dmg})
                    Sum.hits = Sum.hits + 1
                elseif last and hum.Health <= 0 and last > 0 then
                    Sum.kills = Sum.kills + 1
                end
                U._hpLast[pl] = hum.Health
            end
        end
    end
    -- self damage → df escalation signal (tagged with best-guess attacker)
    U._selfDrops = U._selfDrops or {}
    if U.Char.hum and U.Char.hrp then
        local self_last = U._hpLast[LP] or U.Char.hum.MaxHealth
        if U.Char.hum.Health < self_last - 0.01 then
            -- closest enemy whose look vector points at us is the suspect
            local myPos = U.Char.hrp.Position
            local bestName, bestScore = "unknown", math.huge
            for _,pl in ipairs(Players:GetPlayers()) do
                if pl ~= LP and alive(pl) and enemy(pl) then
                    local ch = pl.Character; local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        local toMe = (myPos - hrp.Position)
                        local d = toMe.Magnitude
                        local look = hrp.CFrame.LookVector
                        local align = 1 - (d>0.001 and look:Dot(toMe.Unit) or 0)
                        local score = d * 0.01 + align * 2  -- weight alignment heavier than distance
                        if score < bestScore then bestScore = score; bestName = pl.Name end
                    end
                end
            end
            table.insert(U._selfHitLog, now)
            table.insert(U._selfDrops, {t=now, attacker=bestName, dmg=self_last - U.Char.hum.Health})
        end
        U._hpLast[LP] = U.Char.hum.Health
    end
    -- trim windows
    while U._dpsBucket[1] and now - U._dpsBucket[1].t > 1.0 do table.remove(U._dpsBucket,1) end
    while U._dmgLog[1] and now - U._dmgLog[1].t > 30 do table.remove(U._dmgLog,1) end
    while U._selfHitLog[1] and now - U._selfHitLog[1] > 1.5 do table.remove(U._selfHitLog,1) end
end
local function currentDPS()
    local d=0; for _,r in ipairs(U._dpsBucket) do d=d+r.dmg end; return d
end
C(Players.PlayerRemoving:Connect(function(pl) U._hpLast[pl]=nil end))

----------------------------------------------------------------
-- ESP (10Hz, bounding-box projection, pooled drawings)
----------------------------------------------------------------
local SKEL={{"Head","UpperTorso"},{"UpperTorso","LowerTorso"},{"UpperTorso","LeftUpperArm"},{"LeftUpperArm","LeftLowerArm"},{"UpperTorso","RightUpperArm"},{"RightUpperArm","RightLowerArm"},{"LowerTorso","LeftUpperLeg"},{"LeftUpperLeg","LeftLowerLeg"},{"LowerTorso","RightUpperLeg"},{"RightUpperLeg","RightLowerLeg"}}
local function ensureEsp(p)
    local e=U.Esp[p]; if e then return e end
    e={bones={},corners={}}
    local hl=Instance.new("Highlight"); hl.FillTransparency=0.5; hl.Enabled=false; pc(function() hl.Parent=Workspace end); e.hl=hl
    e.box=D(Drawing.new("Square")); e.box.Thickness=1; e.box.Filled=false; e.box.Visible=false
    for i=1,8 do e.corners[i]=D(Drawing.new("Line")); e.corners[i].Thickness=1; e.corners[i].Visible=false end
    e.name=D(Drawing.new("Text")); e.name.Size=13; e.name.Center=true; e.name.Outline=true; e.name.Visible=false
    e.dist=D(Drawing.new("Text")); e.dist.Size=11; e.dist.Center=true; e.dist.Outline=true; e.dist.Visible=false
    e.tool=D(Drawing.new("Text")); e.tool.Size=10; e.tool.Center=true; e.tool.Outline=true; e.tool.Visible=false
    e.hpbg=D(Drawing.new("Square")); e.hpbg.Filled=true; e.hpbg.Visible=false
    e.hp=D(Drawing.new("Square")); e.hp.Filled=true; e.hp.Visible=false
    e.tracer=D(Drawing.new("Line")); e.tracer.Thickness=1; e.tracer.Visible=false
    e.arrow=D(Drawing.new("Triangle")); e.arrow.Filled=true; e.arrow.Visible=false
    for i=1,#SKEL do e.bones[i]=D(Drawing.new("Line")); e.bones[i].Thickness=1; e.bones[i].Visible=false end
    U.Esp[p]=e; return e
end
local function hideEsp(e)
    e.box.Visible=false; for i=1,8 do e.corners[i].Visible=false end
    e.name.Visible=false; e.dist.Visible=false; e.tool.Visible=false
    e.hpbg.Visible=false; e.hp.Visible=false; e.tracer.Visible=false; e.arrow.Visible=false
    for i=1,#SKEL do e.bones[i].Visible=false end
    if e.hl then pc(function() e.hl.Enabled=false; e.hl.Adornee=nil end) end
end
local function destroyEsp(p) local e=U.Esp[p]; if not e then return end; pc(function() e.hl:Destroy() end); hideEsp(e); U.Esp[p]=nil end
C(Players.PlayerRemoving:Connect(destroyEsp))

local function charBounds(ch)
    local cf, sz = ch:GetBoundingBox()
    local sx,sy,sz_ = sz.X*0.5, sz.Y*0.5, sz.Z*0.5
    local corners={cf*CFrame.new(sx,sy,sz_),cf*CFrame.new(-sx,sy,sz_),cf*CFrame.new(sx,-sy,sz_),cf*CFrame.new(-sx,-sy,sz_),cf*CFrame.new(sx,sy,-sz_),cf*CFrame.new(-sx,sy,-sz_),cf*CFrame.new(sx,-sy,-sz_),cf*CFrame.new(-sx,-sy,-sz_)}
    local mnX,mnY,mxX,mxY=math.huge,math.huge,-math.huge,-math.huge
    local any=false
    for _,c in ipairs(corners) do local s,on=w2s(c.Position); if on then any=true; if s.X<mnX then mnX=s.X end; if s.Y<mnY then mnY=s.Y end; if s.X>mxX then mxX=s.X end; if s.Y>mxY then mxY=s.Y end end end
    if not any then return nil end
    return mnX,mnY,mxX,mxY
end

local function espTick()
    if not T.EspOn and not T.ChamsOn then for _,e in pairs(U.Esp) do hideEsp(e) end; return end
    for _,pl in ipairs(Players:GetPlayers()) do if pl~=LP then
        local e = ensureEsp(pl)
        if not alive(pl) then hideEsp(e)
        else
            local isEn = enemy(pl)
            local col = isEn and P.rd or Color3.fromRGB(110,180,255)
            local ch=pl.Character; local hrp=ch.HumanoidRootPart; local hum=ch:FindFirstChildOfClass("Humanoid")
            local d3 = (hrp.Position - Camera.CFrame.Position).Magnitude
            if d3 > (O.EspMaxDist or 800) then hideEsp(e)
            elseif T.EspOn then
                local mnX,mnY,mxX,mxY = charBounds(ch)
                if mnX then
                    local w = mxX-mnX; local h = mxY-mnY; local midX = (mnX+mxX)/2
                    if T.EspBox then
                        if O.EspBoxS=="corner" then
                            e.box.Visible=false
                            local cl=math.min(w,h)*0.25
                            local pts={{Vector2.new(mnX,mnY),Vector2.new(mnX+cl,mnY)},{Vector2.new(mnX,mnY),Vector2.new(mnX,mnY+cl)},{Vector2.new(mxX,mnY),Vector2.new(mxX-cl,mnY)},{Vector2.new(mxX,mnY),Vector2.new(mxX,mnY+cl)},{Vector2.new(mnX,mxY),Vector2.new(mnX+cl,mxY)},{Vector2.new(mnX,mxY),Vector2.new(mnX,mxY-cl)},{Vector2.new(mxX,mxY),Vector2.new(mxX-cl,mxY)},{Vector2.new(mxX,mxY),Vector2.new(mxX,mxY-cl)}}
                            for i=1,8 do e.corners[i].Visible=true; e.corners[i].From=pts[i][1]; e.corners[i].To=pts[i][2]; e.corners[i].Color=col end
                        else
                            e.box.Visible=true; e.box.Size=Vector2.new(w,h); e.box.Position=Vector2.new(mnX,mnY); e.box.Color=col
                            for i=1,8 do e.corners[i].Visible=false end
                        end
                    else e.box.Visible=false; for i=1,8 do e.corners[i].Visible=false end end
                    if T.EspName then e.name.Visible=true; e.name.Text=pl.Name; e.name.Size=O.EspFont or 13; e.name.Position=Vector2.new(midX, mnY-(O.EspFont or 13)-2); e.name.Color=col else e.name.Visible=false end
                    if T.EspDist then e.dist.Visible=true; e.dist.Text=string.format("[%ds]",math.floor(d3)); e.dist.Position=Vector2.new(midX, mxY+2); e.dist.Color=col else e.dist.Visible=false end
                    if T.EspTool then local tl=ch:FindFirstChildOfClass("Tool"); if tl then e.tool.Visible=true; e.tool.Text=tl.Name; e.tool.Position=Vector2.new(midX, mxY+16); e.tool.Color=col else e.tool.Visible=false end else e.tool.Visible=false end
                    if T.EspHealth and hum and hum.MaxHealth>0 then
                        local hp=math.clamp(hum.Health/hum.MaxHealth,0,1)
                        e.hpbg.Visible=true; e.hp.Visible=true
                        e.hpbg.Position=Vector2.new(mnX-6,mnY); e.hpbg.Size=Vector2.new(3,h); e.hpbg.Color=Color3.new(0,0,0)
                        e.hp.Position=Vector2.new(mnX-6,mnY+h*(1-hp)); e.hp.Size=Vector2.new(3,h*hp); e.hp.Color=Color3.fromRGB(math.floor(255-hp*255),math.floor(hp*255),40)
                    else e.hpbg.Visible=false; e.hp.Visible=false end
                    if T.EspTracer then e.tracer.Visible=true; local vp=Camera.ViewportSize; e.tracer.From=Vector2.new(vp.X/2,vp.Y); e.tracer.To=Vector2.new(midX, mxY); e.tracer.Color=col else e.tracer.Visible=false end
                    if T.EspSkel then for i,pair in ipairs(SKEL) do local a=ch:FindFirstChild(pair[1]); local b=ch:FindFirstChild(pair[2]); if a and b then local sa,oa=w2s(a.Position); local sb,ob=w2s(b.Position); if oa and ob then e.bones[i].Visible=true; e.bones[i].From=sa; e.bones[i].To=sb; e.bones[i].Color=col else e.bones[i].Visible=false end else e.bones[i].Visible=false end end else for i=1,#SKEL do e.bones[i].Visible=false end end
                    if T.EspOff then local sc,on=w2s(hrp.Position); if not on then local vp=Camera.ViewportSize; local cc=vp/2; local dir=Vector2.new(sc.X,sc.Y)-cc; if dir.Magnitude<1 then dir=Vector2.new(1,0) end; dir=dir.Unit; local tip=cc+dir*180; local perp=Vector2.new(-dir.Y,dir.X)*12; e.arrow.Visible=true; e.arrow.PointA=tip; e.arrow.PointB=tip-dir*20+perp; e.arrow.PointC=tip-dir*20-perp; e.arrow.Color=col else e.arrow.Visible=false end else e.arrow.Visible=false end
                else hideEsp(e) end
            else hideEsp(e) end
            if T.ChamsOn then pc(function() e.hl.Enabled=true; e.hl.Adornee=ch; e.hl.FillColor=col; e.hl.FillTransparency=O.ChamsFill end) end
        end
    end end
end

----------------------------------------------------------------
-- HUD drawings — fovring, waterwark, divergence
----------------------------------------------------------------
local fovRing=D(Drawing.new("Circle")); fovRing.Thickness=1; fovRing.NumSides=64; fovRing.Visible=false
local watermark=D(Drawing.new("Text")); watermark.Size=12; watermark.Outline=true; watermark.Font=2; watermark.Visible=false
local dbgReal=D(Drawing.new("Circle")); dbgReal.Thickness=2; dbgReal.NumSides=12; dbgReal.Visible=false
local dbgRep =D(Drawing.new("Circle")); dbgRep.Thickness=2;  dbgRep.NumSides=12;  dbgRep.Visible=false
local dmgNum=D(Drawing.new("Text")); dmgNum.Size=14; dmgNum.Outline=true; dmgNum.Visible=false

local function hudTick()
    fovRing.Visible = (T.RageOn or T.Silent)
    if fovRing.Visible then fovRing.Position=UIS:GetMouseLocation(); fovRing.Radius=O.Fov; fovRing.Color=ac() end
    watermark.Visible = true
    watermark.Text = "unnamed enhancements v3 // olivia"
    watermark.Position = Vector2.new(Camera.ViewportSize.X-280, 6); watermark.Color = ac()

    if T.DebugOverlay and U.Char.hrp then
        local real, rep
        if fpSurfacePos then real=fpSurfacePos; rep=U.Char.hrp.Position
        elseif voidCamAnchor then real=voidCamAnchor.Position; rep=U.Char.hrp.Position end
        if real and rep then
            local s1,o1=w2s(real); local s2,o2=w2s(rep)
            if o1 then dbgReal.Visible=true; dbgReal.Position=s1; dbgReal.Radius=8; dbgReal.Color=P.gn else dbgReal.Visible=false end
            if o2 then dbgRep.Visible=true;  dbgRep.Position=s2;  dbgRep.Radius=8;  dbgRep.Color=P.rd  else dbgRep.Visible=false end
        else dbgReal.Visible=false; dbgRep.Visible=false end
    else dbgReal.Visible=false; dbgRep.Visible=false end
end

----------------------------------------------------------------
-- FPS cap + status readouts
----------------------------------------------------------------
local lastFrameT = os.clock()
local fpsBucket, fpsAvg = {}, 60
local function fpsTick()
    local now = os.clock(); local dt = now - lastFrameT; lastFrameT = now
    table.insert(fpsBucket, 1/dt); if #fpsBucket>30 then table.remove(fpsBucket,1) end
    local s=0; for _,v in ipairs(fpsBucket) do s+=v end; fpsAvg = s/#fpsBucket
    if T.FpsCap and dt < 1/(O.FpsCapV or 120) then
        local budget = 1/(O.FpsCapV or 120) - dt
        if budget>0 then task.wait(budget) end
    end
end

local function pingMs()
    local ok, v = pcall(function() return Stats.Network.ServerStatsItem["Data Ping"]:GetValue() end)
    return ok and math.floor(v) or 0
end
local activeCount = function()
    local n=0; for _,v in pairs(T) do if v==true then n+=1 end end; return n
end
local divergence = function()
    if fpSurfacePos and U.Char.hrp then return math.floor((U.Char.hrp.Position-fpSurfacePos).Magnitude)
    elseif voidCamAnchor and U.Char.hrp then return math.floor(math.abs(U.Char.hrp.Position.Y - voidCamAnchor.Position.Y))
    end
    return 0
end
local function statusTick()
    local killed = U._pcwKilled and U._pcwKilled() or {}
    local kstr = (#killed>0) and ("  ⚠ "..table.concat(killed,",")) or ""
    local hp = (U.Char.hum and U.Char.hum.Health) or 0
    sbL.Text = string.format("fps %3d  ping %3dms  active %d  divergence %d studs  hp %d%s",
        math.floor(fpsAvg), pingMs(), activeCount(), divergence(), math.floor(hp), kstr)
    sbR.Text = string.format("tgt %s  shots %d  hits %d", curTarget and curTarget.Name or "—", Sum.shots, Sum.hits)
end

----------------------------------------------------------------
-- ONE SCHEDULER (collapse every feature into one Heartbeat)
-- 30Hz for HRP writes, 10Hz for ESP, every-frame for HUD/status
----------------------------------------------------------------
-- per-feature next-run timestamps (independent cadences, one loop)
local lastESP10  = 0
local lastBT30   = 0
local lastHP15   = 0
local nextVoidAt = 0     -- voidspam: flat 1/30
local nextFPAt   = 0     -- fake pos: flat 1/30
local nextDFAt   = 0     -- field: owned random cadence (13-34ms)
local prevArb    = "none"  -- for resetting stale timers on arbiter switch

local function schedulerTick()
    local now = os.clock()
    -- per-frame (cheap / render)
    pcw("hud", hudTick)
    pcw("status", statusTick)
    pcw("aim", aimTick)
    pcw("fire", fireTick)
    pcw("world", worldTick)
    pcw("fps", fpsTick)
    pcw("peek", peekTick)
    pcw("aa", aaTick)
    pcw("move", moveTick)
    pcw("df-esc", dfEscalationTick)
    pcw("strafe-restore", strafeRestoreTick)

    -- 15Hz: health-delta tracker (deltas don't need sub-100ms resolution)
    if now - lastHP15 >= 1/15 then
        lastHP15 = now
        pcw("hp-track", hpTrackTick)
    end

    -- 30Hz: backtrack sampler
    if now - lastBT30 >= 1/30 then
        lastBT30 = now
        for _,p in ipairs(Players:GetPlayers()) do if p~=LP then pcw("bt", bt_push, p) end end
    end

    -- ARBITER: FP > DF > voidspam, mutually exclusive.
    -- On every switch, zero the stale nextAt so the incoming feature doesn't immediately fire from an expired timer.
    local arb = (T.FPOn and "fp") or (T.DFOn and "df") or (T.VoidOn and "void") or "none"
    if arb ~= prevArb then
        nextVoidAt, nextFPAt, nextDFAt = now, now, now
        prevArb = arb
    end
    if arb == "fp" then
        if now >= nextFPAt then nextFPAt = now + 1/30; pcw("fp", fpTick) end
    elseif arb == "df" then
        if now >= nextDFAt then pcw("df", dfTick); nextDFAt = now + (DF and DF.nextDelay or 0.02) end
    elseif arb == "void" then
        if now >= nextVoidAt then nextVoidAt = now + 1/30; pcw("void", voidTick) end
    end

    -- 10Hz: ESP
    if now - lastESP10 >= 1/10 then
        lastESP10 = now
        pcw("esp", espTick)
    end
end

C(RunService.Heartbeat:Connect(schedulerTick))

----------------------------------------------------------------
-- menu toggle key
----------------------------------------------------------------
K.MenuKey = K.MenuKey or {k=Enum.KeyCode.RightShift, mode="Toggle", state=false, tog=false}
C(UIS.InputBegan:Connect(function(i,gp) if gp then return end; if typeof(K.MenuKey.k)=="EnumItem" and i.KeyCode==K.MenuKey.k then Root.Visible = not Root.Visible end end))

-- anti-afk
pcall(function() C(LP.Idled:Connect(function() if T.AntiAfk then local vim=game:GetService("VirtualUser"); pc(function() vim:CaptureController(); vim:ClickButton2(Vector2.new()) end) end end)) end)

-- clean the crash-mark after a successful 10s run (survived load, past most crash windows)
task.delay(10, function() if os.clock() - sessionStart >= 10 then clearCrashMark() end end)

----------------------------------------------------------------
-- UNLOAD
----------------------------------------------------------------
U.Unload = function()
    clearCrashMark()
    for _,c in ipairs(U.Con) do pcall(function() c:Disconnect() end) end
    for _,d in ipairs(U.Draw) do pcall(function() d:Remove() end) end
    for p,_ in pairs(U.Esp) do destroyEsp(p) end
    if voidCamAnchor then pcall(function() voidCamAnchor:Destroy() end) end
    if fpCamAnchor then pcall(function() fpCamAnchor:Destroy() end) end
    pcall(function() Camera.CameraSubject = U.Char.hum end)
    pcall(function() Lighting.FogEnd=origFog; Lighting.Brightness=origBrt; Camera.FieldOfView=70 end)
    pcall(function() Screen:Destroy() end)
    -- state tables
    U._observeLog, U._sig, U._sigLearned = nil, nil, nil
    U._lastFire, U._pcwState = nil, nil
    U._hpLast, U._dmgLog, U._dpsBucket, U._selfHitLog, U._selfDrops, U._attackerHits = nil,nil,nil,nil,nil,nil
    U._inHook = nil
    U._strafeRestoreAt, U._strafeSaved = 0, nil
    _memFS = {}
    getgenv().UE3 = nil
end
