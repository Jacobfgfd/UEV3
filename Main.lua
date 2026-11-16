--[[
    Unnamed Enhancements V6 — standalone, lazy, AC-safe, pixel UI
    Built by Olivia — https://discord.gg/ojailbreaks
--]]

if getgenv().UEV6 and getgenv().UEV6.Unload then pcall(getgenv().UEV6.Unload) end

local HttpService      = game:GetService("HttpService")
local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local Lighting         = game:GetService("Lighting")
local Workspace        = game:GetService("Workspace")
local VirtualInput     = game:GetService("VirtualInputManager")
local CoreGui          = game:GetService("CoreGui")
local Camera           = Workspace.CurrentCamera
local LP               = Players.LocalPlayer

------------------------------------------------------
-- STATE
------------------------------------------------------
local V6 = {
    Opt={}, Tog={}, Keys={}, Conns={}, Draws={}, Ghosts={}, ESP={},
    State={
        target=nil, aimPos=nil, hitChance=0, lastShot=0, lastSwitch=0, lastKillAt=0,
        shotsBucket={}, resolver={}, backtrack={}, selfPath={},
        desyncYaw=0, onShotUntil=0, defUntil=0, aaSide=1,
        chokeCounter=0, choke=0,
        stats={shots=0,hits=0,kills=0,start=os.clock()},
        origFog=Lighting.FogEnd, origBright=Lighting.Brightness,
    },
}
getgenv().UEV6 = V6
local O,T,K,S = V6.Opt, V6.Tog, V6.Keys, V6.State
local function C(c) table.insert(V6.Conns,c); return c end
local function D(d) table.insert(V6.Draws,d); return d end
local function safe(f,...) local ok,r=pcall(f,...); if ok then return r end end

------------------------------------------------------
-- THEME (pixel)
------------------------------------------------------
local TH = {
    bg=Color3.fromRGB(8,8,12), bg2=Color3.fromRGB(12,12,18),
    pn=Color3.fromRGB(18,18,26), pn2=Color3.fromRGB(24,24,34), pn3=Color3.fromRGB(32,32,44),
    st=Color3.fromRGB(55,55,80), stHi=Color3.fromRGB(140,90,255),
    tx=Color3.fromRGB(240,240,250), sub=Color3.fromRGB(140,140,170), dim=Color3.fromRGB(85,85,105),
    ac=Color3.fromRGB(180,100,255), ac2=Color3.fromRGB(255,80,200),
    gd=Color3.fromRGB(80,230,160), bd=Color3.fromRGB(255,80,110), wn=Color3.fromRGB(255,200,80),
    px=Enum.Font.Arcade, mo=Enum.Font.Code,
}
local function N(cls,p) local i=Instance.new(cls); for k,v in pairs(p or {}) do i[k]=v end; return i end
local function cr(p,r) N("UICorner",{CornerRadius=UDim.new(0,r or 3),Parent=p}) end
local function sk(p,c,t) N("UIStroke",{Color=c or TH.st,Thickness=t or 1,Parent=p,ApplyStrokeMode=Enum.ApplyStrokeMode.Border}) end
local function pd(p,l,r,t,b) N("UIPadding",{PaddingLeft=UDim.new(0,l or 0),PaddingRight=UDim.new(0,r or l or 0),PaddingTop=UDim.new(0,t or l or 0),PaddingBottom=UDim.new(0,b or l or 0),Parent=p}) end

------------------------------------------------------
-- GUI
------------------------------------------------------
local Screen = N("ScreenGui",{IgnoreGuiInset=true,ResetOnSpawn=false,ZIndexBehavior=Enum.ZIndexBehavior.Sibling,DisplayOrder=1e5})
local ok = pcall(function()
    if syn and syn.protect_gui then syn.protect_gui(Screen) end
    if gethui then Screen.Parent=gethui() else Screen.Parent=CoreGui end
end)
if not ok then Screen.Parent = LP:WaitForChild("PlayerGui") end
Screen.Name = "UEV6_"..math.random(1e5,1e6-1)
V6.Screen = Screen

local Root = N("Frame",{Size=UDim2.fromOffset(880,580),Position=UDim2.new(0.5,-440,0.5,-290),BackgroundColor3=TH.bg,BorderSizePixel=0,Parent=Screen})
cr(Root,6); sk(Root,TH.ac,1)

-- title
local tb = N("Frame",{Size=UDim2.new(1,0,0,40),BackgroundColor3=TH.pn,BorderSizePixel=0,Parent=Root}); cr(tb,6)
N("Frame",{Size=UDim2.new(1,0,0,14),Position=UDim2.new(0,0,1,-14),BackgroundColor3=TH.pn,BorderSizePixel=0,Parent=tb})
local chip = N("Frame",{Size=UDim2.fromOffset(20,20),Position=UDim2.fromOffset(12,10),BackgroundColor3=TH.ac,BorderSizePixel=0,Parent=tb}); cr(chip,2)
N("Frame",{Size=UDim2.fromOffset(6,6),Position=UDim2.fromOffset(7,7),BackgroundColor3=TH.bg,BorderSizePixel=0,Parent=chip})
N("TextLabel",{Size=UDim2.new(1,-240,1,0),Position=UDim2.new(0,42,0,0),BackgroundTransparency=1,Text="UNNAMED ENHANCEMENTS  V6  ::  olivia  ::  discord.gg/ojailbreaks",TextColor3=TH.tx,Font=TH.px,TextSize=14,TextXAlignment=Enum.TextXAlignment.Left,Parent=tb})
local accLine = N("Frame",{Size=UDim2.new(1,-24,0,2),Position=UDim2.new(0,12,1,-4),BackgroundColor3=TH.ac,BorderSizePixel=0,Parent=tb})
N("UIGradient",{Color=ColorSequence.new{ColorSequenceKeypoint.new(0,TH.ac),ColorSequenceKeypoint.new(1,TH.ac2)},Parent=accLine})

local function winBtn(sym,col,x,cb)
    local b=N("TextButton",{Size=UDim2.fromOffset(22,22),Position=UDim2.new(1,x,0,9),BackgroundColor3=col,BorderSizePixel=0,Text=sym,TextColor3=TH.bg,Font=TH.px,TextSize=12,Parent=tb}); cr(b,3)
    b.MouseButton1Click:Connect(cb); return b
end
local minimized=false
winBtn("_",TH.wn,-58,function() minimized=not minimized; Root.Size = minimized and UDim2.fromOffset(880,40) or UDim2.fromOffset(880,580) end)
winBtn("x",TH.bd,-30,function() if V6.Unload then V6.Unload() end end)

-- drag
local drg,ds,sp
tb.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then drg=true; ds=i.Position; sp=Root.Position; i.Changed:Connect(function() if i.UserInputState==Enum.UserInputState.End then drg=false end end) end end)
C(UserInputService.InputChanged:Connect(function(i) if drg and i.UserInputType==Enum.UserInputType.MouseMovement then local d=i.Position-ds; Root.Position=UDim2.new(sp.X.Scale,sp.X.Offset+d.X,sp.Y.Scale,sp.Y.Offset+d.Y) end end))

-- search bar
local searchBar = N("Frame",{Size=UDim2.new(1,-16,0,26),Position=UDim2.new(0,8,0,46),BackgroundColor3=TH.pn,BorderSizePixel=0,Parent=Root}); cr(searchBar,3); sk(searchBar,TH.st,1); pd(searchBar,8,8,2,2)
local searchBox = N("TextBox",{Size=UDim2.new(1,-20,1,0),BackgroundTransparency=1,Text="",PlaceholderText="search features...",PlaceholderColor3=TH.dim,TextColor3=TH.tx,Font=TH.mo,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,Parent=searchBar,ClearTextOnFocus=false})

-- body
local body = N("Frame",{Size=UDim2.new(1,-16,1,-116),Position=UDim2.new(0,8,0,76),BackgroundTransparency=1,Parent=Root})
local tabCol = N("ScrollingFrame",{Size=UDim2.new(0,160,1,0),BackgroundColor3=TH.pn,BorderSizePixel=0,ScrollBarThickness=2,ScrollBarImageColor3=TH.ac,CanvasSize=UDim2.new(0,0,0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y,Parent=body}); cr(tabCol,4); sk(tabCol,TH.st,1); pd(tabCol,6)
N("UIListLayout",{Padding=UDim.new(0,3),SortOrder=Enum.SortOrder.LayoutOrder,Parent=tabCol})
local contentWrap = N("Frame",{Size=UDim2.new(1,-168,1,0),Position=UDim2.new(0,168,0,0),BackgroundColor3=TH.pn,BorderSizePixel=0,Parent=body}); cr(contentWrap,4); sk(contentWrap,TH.st,1); pd(contentWrap,10)

-- status + hotkeys bar
local statusBar = N("Frame",{Size=UDim2.new(1,-16,0,28),Position=UDim2.new(0,8,1,-32),BackgroundColor3=TH.pn,BorderSizePixel=0,Parent=Root}); cr(statusBar,3); sk(statusBar,TH.st,1); pd(statusBar,10,10,6,6)
local statusL = N("TextLabel",{Size=UDim2.new(1,-260,1,0),BackgroundTransparency=1,Text="ready",Font=TH.mo,TextSize=11,TextColor3=TH.sub,TextXAlignment=Enum.TextXAlignment.Left,Parent=statusBar})
local statusR = N("TextLabel",{Size=UDim2.new(0,260,1,0),Position=UDim2.new(1,-260,0,0),BackgroundTransparency=1,Text="",Font=TH.mo,TextSize=11,TextColor3=TH.ac,TextXAlignment=Enum.TextXAlignment.Right,Parent=statusBar})

local pages, pageBuilders, tabBtns = {}, {}, {}
local currentTab
local function newTab(name,icon,builder)
    local btn = N("TextButton",{Size=UDim2.new(1,0,0,26),BackgroundColor3=TH.pn2,Text="  "..(icon or "■").."  "..name,TextColor3=TH.sub,Font=TH.px,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left,AutoButtonColor=false,BorderSizePixel=0,Parent=tabCol}); cr(btn,3)
    local ind = N("Frame",{Size=UDim2.new(0,3,1,-6),Position=UDim2.new(0,0,0,3),BackgroundColor3=TH.ac,BorderSizePixel=0,Visible=false,Parent=btn})
    local page = N("ScrollingFrame",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,ScrollBarThickness=3,ScrollBarImageColor3=TH.ac,CanvasSize=UDim2.new(0,0,0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y,BorderSizePixel=0,Visible=false,Parent=contentWrap})
    N("UIListLayout",{Padding=UDim.new(0,8),SortOrder=Enum.SortOrder.LayoutOrder,Parent=page,FillDirection=Enum.FillDirection.Horizontal,Wraps=true})
    pages[name]=page; tabBtns[name]={btn=btn,ind=ind}; pageBuilders[name]=builder
    btn.MouseButton1Click:Connect(function()
        if pageBuilders[name] then safe(pageBuilders[name], page); pageBuilders[name]=nil end
        for n,p in pairs(pages) do p.Visible=(n==name) end
        for n,tb in pairs(tabBtns) do tb.btn.BackgroundColor3=TH.pn2; tb.btn.TextColor3=TH.sub; tb.ind.Visible=false end
        btn.BackgroundColor3=TH.pn3; btn.TextColor3=TH.tx; ind.Visible=true
        currentTab=name
    end)
end
local function openTab(name) local tb=tabBtns[name]; if tb then tb.btn.MouseButton1Click:Fire() end end

local function newSection(page,title,icon,wide)
    local w = wide and UDim2.new(1,0,0,0) or UDim2.new(0.5,-5,0,0)
    local box=N("Frame",{Size=w,BackgroundColor3=TH.pn2,BorderSizePixel=0,AutomaticSize=Enum.AutomaticSize.Y,Parent=page}); cr(box,4); sk(box,TH.st,1); pd(box,10,10,8,10)
    local head=N("Frame",{Size=UDim2.new(1,0,0,18),BackgroundTransparency=1,Parent=box})
    N("Frame",{Size=UDim2.fromOffset(3,12),Position=UDim2.fromOffset(0,3),BackgroundColor3=TH.ac,BorderSizePixel=0,Parent=head})
    N("TextLabel",{Size=UDim2.new(1,-10,1,0),Position=UDim2.fromOffset(8,0),BackgroundTransparency=1,Text=(icon and (icon.." ") or "")..string.upper(title),Font=TH.px,TextSize=11,TextColor3=TH.ac,TextXAlignment=Enum.TextXAlignment.Left,Parent=head})
    local col=N("Frame",{Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,Position=UDim2.new(0,0,0,22),BackgroundTransparency=1,Parent=box})
    N("UIListLayout",{Padding=UDim.new(0,5),SortOrder=Enum.SortOrder.LayoutOrder,Parent=col})
    return col
end

------------------------------------------------------
-- WIDGETS
------------------------------------------------------
local function Toggle(p,k,t,d)
    V6.Tog[k]=d and true or false
    local r=N("Frame",{Size=UDim2.new(1,0,0,22),BackgroundTransparency=1,Parent=p})
    N("TextLabel",{Size=UDim2.new(1,-44,1,0),BackgroundTransparency=1,Text=t,Font=TH.px,TextSize=11,TextColor3=TH.tx,TextXAlignment=Enum.TextXAlignment.Left,Parent=r})
    local sw=N("TextButton",{Size=UDim2.fromOffset(34,16),Position=UDim2.new(1,-34,0.5,-8),BackgroundColor3=V6.Tog[k] and TH.ac or TH.pn,BorderSizePixel=0,Text="",AutoButtonColor=false,Parent=r}); cr(sw,2); sk(sw,TH.st,1)
    local kn=N("Frame",{Size=UDim2.fromOffset(12,12),Position=UDim2.fromOffset(V6.Tog[k] and 20 or 2,2),BackgroundColor3=V6.Tog[k] and Color3.new(1,1,1) or TH.dim,BorderSizePixel=0,Parent=sw}); cr(kn,2)
    sw.MouseButton1Click:Connect(function()
        V6.Tog[k]=not V6.Tog[k]
        sw.BackgroundColor3 = V6.Tog[k] and TH.ac or TH.pn
        kn.Position = V6.Tog[k] and UDim2.fromOffset(20,2) or UDim2.fromOffset(2,2)
        kn.BackgroundColor3 = V6.Tog[k] and Color3.new(1,1,1) or TH.dim
    end)
end

local function Slider(p,k,t,d,mn,mx,st,sx)
    V6.Opt[k]=d
    local b=N("Frame",{Size=UDim2.new(1,0,0,34),BackgroundTransparency=1,Parent=p})
    N("TextLabel",{Size=UDim2.new(1,-60,0,14),BackgroundTransparency=1,Text=t,Font=TH.px,TextSize=11,TextColor3=TH.tx,TextXAlignment=Enum.TextXAlignment.Left,Parent=b})
    local vl=N("TextLabel",{Size=UDim2.new(0,60,0,14),Position=UDim2.new(1,-60,0,0),BackgroundTransparency=1,Text=tostring(d)..(sx or ""),Font=TH.mo,TextSize=11,TextColor3=TH.ac,TextXAlignment=Enum.TextXAlignment.Right,Parent=b})
    local br=N("Frame",{Size=UDim2.new(1,0,0,6),Position=UDim2.new(0,0,0,20),BackgroundColor3=TH.pn,BorderSizePixel=0,Parent=b}); cr(br,2)
    local fl=N("Frame",{Size=UDim2.new((d-mn)/(mx-mn),0,1,0),BackgroundColor3=TH.ac,BorderSizePixel=0,Parent=br}); cr(fl,2)
    N("UIGradient",{Color=ColorSequence.new{ColorSequenceKeypoint.new(0,TH.ac),ColorSequenceKeypoint.new(1,TH.ac2)},Parent=fl})
    local dr=false
    local function set(x)
        local rl=math.clamp((x-br.AbsolutePosition.X)/br.AbsoluteSize.X,0,1)
        local v=mn+(mx-mn)*rl; if st then v=math.floor(v/st+0.5)*st end; v=math.clamp(v,mn,mx)
        V6.Opt[k]=v; fl.Size=UDim2.new((v-mn)/(mx-mn),0,1,0)
        vl.Text = (st and st>=1) and (tostring(math.floor(v))..(sx or "")) or (string.format("%.2f",v)..(sx or ""))
    end
    br.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dr=true; set(i.Position.X) end end)
    C(UserInputService.InputChanged:Connect(function(i) if dr and i.UserInputType==Enum.UserInputType.MouseMovement then set(i.Position.X) end end))
    C(UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dr=false end end))
end

local function Dropdown(p,k,t,vs,d)
    V6.Opt[k]=d
    local b=N("Frame",{Size=UDim2.new(1,0,0,36),BackgroundTransparency=1,Parent=p})
    N("TextLabel",{Size=UDim2.new(1,0,0,14),BackgroundTransparency=1,Text=t,Font=TH.px,TextSize=11,TextColor3=TH.tx,TextXAlignment=Enum.TextXAlignment.Left,Parent=b})
    local bt=N("TextButton",{Size=UDim2.new(1,0,0,18),Position=UDim2.new(0,0,0,16),BackgroundColor3=TH.pn,BorderSizePixel=0,Text="  "..d.."  v",Font=TH.mo,TextSize=11,TextColor3=TH.tx,TextXAlignment=Enum.TextXAlignment.Left,AutoButtonColor=false,Parent=b}); cr(bt,2); sk(bt,TH.st,1)
    local ls=N("Frame",{Size=UDim2.new(1,0,0,0),Position=UDim2.new(0,0,1,2),BackgroundColor3=TH.pn2,BorderSizePixel=0,Visible=false,ZIndex=60,Parent=bt,AutomaticSize=Enum.AutomaticSize.Y}); cr(ls,2); sk(ls,TH.ac,1)
    N("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,Parent=ls})
    for _,v in ipairs(vs) do
        local it=N("TextButton",{Size=UDim2.new(1,0,0,18),BackgroundColor3=TH.pn2,BorderSizePixel=0,Text="  "..v,Font=TH.mo,TextSize=11,TextColor3=TH.tx,TextXAlignment=Enum.TextXAlignment.Left,AutoButtonColor=false,ZIndex=61,Parent=ls})
        it.MouseEnter:Connect(function() it.BackgroundColor3=TH.ac; it.TextColor3=Color3.new(1,1,1) end)
        it.MouseLeave:Connect(function() it.BackgroundColor3=TH.pn2; it.TextColor3=TH.tx end)
        it.MouseButton1Click:Connect(function() V6.Opt[k]=v; bt.Text="  "..v.."  v"; ls.Visible=false end)
    end
    bt.MouseButton1Click:Connect(function() ls.Visible=not ls.Visible end)
end

local function Keybind(p,k,t,dk,dm)
    V6.Keys[k]={k=dk,mode=dm or "Hold",state=false,toggleOn=false}
    local b=N("Frame",{Size=UDim2.new(1,0,0,22),BackgroundTransparency=1,Parent=p})
    N("TextLabel",{Size=UDim2.new(1,-130,1,0),BackgroundTransparency=1,Text=t,Font=TH.px,TextSize=11,TextColor3=TH.tx,TextXAlignment=Enum.TextXAlignment.Left,Parent=b})
    local function nm(x) return (typeof(x)=="EnumItem") and x.Name or tostring(x) end
    local kb=N("TextButton",{Size=UDim2.fromOffset(64,18),Position=UDim2.new(1,-130,0.5,-9),BackgroundColor3=TH.pn,Text=nm(dk),Font=TH.mo,TextSize=10,TextColor3=TH.ac,BorderSizePixel=0,AutoButtonColor=false,Parent=b}); cr(kb,2); sk(kb,TH.st,1)
    local mb=N("TextButton",{Size=UDim2.fromOffset(60,18),Position=UDim2.new(1,-62,0.5,-9),BackgroundColor3=TH.pn,Text=V6.Keys[k].mode,Font=TH.px,TextSize=10,TextColor3=TH.sub,BorderSizePixel=0,AutoButtonColor=false,Parent=b}); cr(mb,2); sk(mb,TH.st,1)
    local picking=false
    kb.MouseButton1Click:Connect(function() picking=true; kb.Text="..." end)
    C(UserInputService.InputBegan:Connect(function(i,gpe)
        if picking then
            if i.UserInputType==Enum.UserInputType.Keyboard then V6.Keys[k].k=i.KeyCode
            elseif i.UserInputType==Enum.UserInputType.MouseButton1 then V6.Keys[k].k="MB1"
            elseif i.UserInputType==Enum.UserInputType.MouseButton2 then V6.Keys[k].k="MB2" end
            kb.Text=nm(V6.Keys[k].k); picking=false; return
        end
        if gpe then return end
        local kk=V6.Keys[k]
        local m=(kk.k=="MB1" and i.UserInputType==Enum.UserInputType.MouseButton1) or (kk.k=="MB2" and i.UserInputType==Enum.UserInputType.MouseButton2) or (typeof(kk.k)=="EnumItem" and i.KeyCode==kk.k)
        if m then if kk.mode=="Hold" then kk.state=true elseif kk.mode=="Toggle" then kk.toggleOn=not kk.toggleOn; kk.state=kk.toggleOn end end
    end))
    C(UserInputService.InputEnded:Connect(function(i)
        local kk=V6.Keys[k]; local m=(kk.k=="MB1" and i.UserInputType==Enum.UserInputType.MouseButton1) or (kk.k=="MB2" and i.UserInputType==Enum.UserInputType.MouseButton2) or (typeof(kk.k)=="EnumItem" and i.KeyCode==kk.k)
        if m and kk.mode=="Hold" then kk.state=false end
    end))
    mb.MouseButton1Click:Connect(function() local o={Hold="Toggle",Toggle="Always",Always="Hold"}; V6.Keys[k].mode=o[V6.Keys[k].mode]; mb.Text=V6.Keys[k].mode; V6.Keys[k].state=(V6.Keys[k].mode=="Always") end)
end

local function ColorBox(p,k,t,d)
    V6.Opt[k]=d
    local b=N("Frame",{Size=UDim2.new(1,0,0,22),BackgroundTransparency=1,Parent=p})
    N("TextLabel",{Size=UDim2.new(1,-30,1,0),BackgroundTransparency=1,Text=t,Font=TH.px,TextSize=11,TextColor3=TH.tx,TextXAlignment=Enum.TextXAlignment.Left,Parent=b})
    local sw=N("Frame",{Size=UDim2.fromOffset(24,14),Position=UDim2.new(1,-24,0.5,-7),BackgroundColor3=d,BorderSizePixel=0,Parent=b}); cr(sw,2); sk(sw,TH.st,1)
    local presets={d,Color3.fromRGB(255,80,180),Color3.fromRGB(80,230,160),Color3.fromRGB(255,220,80),Color3.fromRGB(255,255,255),Color3.fromRGB(0,200,255),Color3.fromRGB(255,80,110),Color3.fromRGB(255,120,0),Color3.fromRGB(140,90,255)}
    local idx=1
    N("TextButton",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",Parent=sw}).MouseButton1Click:Connect(function() idx=idx%#presets+1; V6.Opt[k]=presets[idx]; sw.BackgroundColor3=presets[idx] end)
end

local function Button(p,t,cb)
    local b=N("TextButton",{Size=UDim2.new(1,0,0,22),BackgroundColor3=TH.ac,BorderSizePixel=0,Text=t,Font=TH.px,TextSize=11,TextColor3=Color3.new(1,1,1),AutoButtonColor=true,Parent=p}); cr(b,3)
    b.MouseButton1Click:Connect(cb)
end

local function Label(p,t,c) return N("TextLabel",{Size=UDim2.new(1,0,0,14),BackgroundTransparency=1,Text=t,Font=TH.px,TextSize=10,TextColor3=c or TH.sub,TextXAlignment=Enum.TextXAlignment.Left,Parent=p}) end

local function TextInput(p,k,t,d,ph)
    V6.Opt[k]=d
    local b=N("Frame",{Size=UDim2.new(1,0,0,36),BackgroundTransparency=1,Parent=p})
    N("TextLabel",{Size=UDim2.new(1,0,0,14),BackgroundTransparency=1,Text=t,Font=TH.px,TextSize=11,TextColor3=TH.tx,TextXAlignment=Enum.TextXAlignment.Left,Parent=b})
    local bx=N("TextBox",{Size=UDim2.new(1,0,0,18),Position=UDim2.new(0,0,0,16),BackgroundColor3=TH.pn,BorderSizePixel=0,Text=d,PlaceholderText=ph or "",Font=TH.mo,TextSize=11,TextColor3=TH.tx,TextXAlignment=Enum.TextXAlignment.Left,Parent=b}); cr(bx,2); sk(bx,TH.st,1); pd(bx,6)
    bx:GetPropertyChangedSignal("Text"):Connect(function() V6.Opt[k]=bx.Text end)
end

------------------------------------------------------
-- TABS (lazy builders — content built only on first open)
------------------------------------------------------
newTab("AC SAFE","!",function(p)
    local s=newSection(p,"Anti-Cheat Safe Mode","!",true)
    Label(s,"Rivals AC v2 catches CFrame writes and meta hooks.",TH.wn)
    Label(s,"Keep these ON when testing a new game.",TH.wn)
    local l=newSection(p,"Guards","!")
    Toggle(l,"AcSafe","AC Safe Mode (master)",true)
    Toggle(l,"AcNoCFrame","Skip HRP CFrame Writes",true)
    Toggle(l,"AcNoAutoRot","Skip AutoRotate Disable",true)
    Toggle(l,"AcNoHook","Skip Metatable Hook",false)
    Toggle(l,"AcNoBodyMover","Skip BodyVelocity/BodyGyro",false)
    Toggle(l,"AcSoftTick","Throttle Ticks",true)
    Toggle(l,"AcPcallAll","pcall Every Write",true)
    Toggle(l,"AcSkipDeadTicks","Skip Ticks When Dead",true)
    local r=newSection(p,"Diagnostics","?")
    Label(r,"Executor: "..(identifyexecutor and identifyexecutor() or "?"))
    Label(r,"hookmetamethod: "..(hookmetamethod and "yes" or "no"))
    Label(r,"getrawmetatable: "..(getrawmetatable and "yes" or "no"))
    Label(r,"mousemoverel: "..(mousemoverel and "yes" or "no"))
    Label(r,"Drawing: "..(Drawing and "yes" or "no"))
    Label(r,"writefile: "..(writefile and "yes" or "no"))
end)

newTab("RAGEBOT",">",function(p)
    local s=newSection(p,"Core",">")
    Toggle(s,"RageEnabled","Enable Ragebot",false)
    Toggle(s,"RageSilent","Silent Aim",true)
    Toggle(s,"RageAutoFire","Auto Fire",false)
    Toggle(s,"RageAutoStop","Auto Stop",false)
    Toggle(s,"RageAutoScope","Auto Scope",true)
    Toggle(s,"RageAutoCrouch","Auto Crouch on Shot",false)
    Toggle(s,"RageAutoReload","Auto Reload",false)
    Slider(s,"RageFov","FOV",80,5,500,1,"px")
    Slider(s,"RageMaxDist","Max Distance",500,10,5000,10,"s")
    Slider(s,"RageMinDmg","Min Damage",1,1,150,1)
    Slider(s,"RageShotDelay","Shot Delay",0.05,0,1,0.01,"s")
    Dropdown(s,"RageKeyMode","Activation",{"Always","Hold","Toggle"},"Hold")
    Keybind(s,"RageKey","Rage Key","MB2","Hold")

    local s2=newSection(p,"Target","@")
    Dropdown(s2,"RagePrio","Priority",{"FOV","Distance","Health","LowestHP","Crosshair","HighestDmg","Random"},"FOV")
    Toggle(s2,"RageVisibleOnly","Visible Only",false)
    Toggle(s2,"RageIgnoreTeam","Ignore Team",true)
    Toggle(s2,"RageIgnoreFriends","Ignore Friends",true)
    Toggle(s2,"RageIgnoreCrouch","Ignore Crouching",false)
    Toggle(s2,"RageIgnoreLow","Ignore HP<10",false)
    Toggle(s2,"RageLockTarget","Lock Target Until Dead",false)
    Slider(s2,"RageSwitch","Switch Delay",0.05,0,1,0.01,"s")
    Slider(s2,"RageKillDelay","Kill Delay",0,0,1,0.01,"s")

    local s3=newSection(p,"Hitboxes","#")
    Dropdown(s3,"RageHitbox","Primary Hitbox",{"Head","UpperTorso","Torso","HumanoidRootPart","LeftUpperArm","RightUpperArm","LeftUpperLeg","RightUpperLeg","Nearest","MultiScan"},"Head")
    Slider(s3,"RageHbHead","Weight: Head",10,0,10,1)
    Slider(s3,"RageHbChest","Weight: Chest",6,0,10,1)
    Slider(s3,"RageHbPelvis","Weight: Pelvis",4,0,10,1)
    Slider(s3,"RageHbArms","Weight: Arms",2,0,10,1)
    Slider(s3,"RageHbLegs","Weight: Legs",2,0,10,1)
    Slider(s3,"RageMultipoint","Multipoint Scale",0.75,0,1,0.05)
    Slider(s3,"RageMultiPts","Multipoint Count",6,1,16,1)
    Toggle(s3,"RageHeadScale","Head Scale Enable",false)
    Slider(s3,"RageHeadScaleV","Head Scale",2,1,10,0.1)

    local s4=newSection(p,"Prediction / BT","~")
    Toggle(s4,"RagePred","Velocity Prediction",true)
    Slider(s4,"RagePredFactor","Prediction Factor",0.16,0,1,0.01,"s")
    Toggle(s4,"RageAirPred","Air Prediction",true)
    Toggle(s4,"RageCurvePred","Parabolic Curve",false)
    Toggle(s4,"RageHcGate","Hitchance Gate",true)
    Slider(s4,"RageHc","Min Hitchance",70,0,100,1,"%")
    Slider(s4,"RageHcSamples","Hitchance Samples",12,4,32,1)
    Toggle(s4,"RageBT","Backtrack",true)
    Slider(s4,"RageBTms","Backtrack Max",200,0,1000,10,"ms")
    Toggle(s4,"RageMagicBullet","Magic Bullet Retry",false)
    Slider(s4,"RageMagicTries","Retry Count",3,1,10,1)
end)

newTab("RAGE+ PEAK",">>",function(p)
    local s=newSection(p,"Safepoint / Damage","+")
    Toggle(s,"RageSafepoint","Force Safepoint",true)
    Slider(s,"RageSPBias","Safepoint Bias",0.6,0,1,0.05)
    Toggle(s,"RageForceHS","Force Headshot",false)
    Toggle(s,"RageForceBaim","Force Body Aim",false)
    Toggle(s,"RageAdaptiveBaim","Adaptive Baim After Misses",true)
    Slider(s,"RageBaimMiss","Baim After Misses",2,1,6,1)
    Toggle(s,"RageDamageAvg","Damage Averaging",true)
    Slider(s,"RageDmgCeil","Damage Ceiling",100,1,200,1)

    local s2=newSection(p,"Delta / Teleport / Blink","*")
    Toggle(s2,"RageDeltaShot","Delta Shot",false)
    Slider(s2,"RageDeltaMs","Delta Window",60,1,400,1,"ms")
    Toggle(s2,"RageTPAim","Teleport Aim",false)
    Slider(s2,"RageTPDist","TP Distance",10,2,40,1,"s")
    Toggle(s2,"RageBlink","Blink (choke stack)",false)
    Slider(s2,"RageBlinkTicks","Blink Ticks",12,2,28,1)
    Keybind(s2,"RageBlinkKey","Blink Key",Enum.KeyCode.T,"Hold")
    Toggle(s2,"RageFakeDuck","Fake Duck",false)
    Keybind(s2,"RageDuckKey","Duck Key",Enum.KeyCode.H,"Toggle")
    Toggle(s2,"RageSlow","Slow Walk",false)
    Slider(s2,"RageSlowSpd","Slow Speed",4,1,16,1)

    local s3=newSection(p,"Rate / Behavior","%")
    Slider(s3,"RageSPS","Max Shots/sec",10,1,60,1)
    Slider(s3,"RageConf","Min Confidence",65,0,100,1,"%")
    Toggle(s3,"RageNoScope","Allow No-Scope",false)
    Toggle(s3,"RageFastFire","Fast Fire",false)
    Toggle(s3,"RageAimCone","Compensate Cone",true)
    Slider(s3,"RageConeSamp","Cone Samples",8,1,32,1)
    Toggle(s3,"RageAutoKnife","Auto Knife Close",false)
    Slider(s3,"RageKnifeDist","Knife Distance",10,2,25,1)
    Toggle(s3,"RageAutoPreTrig","Auto Pre-Trigger",false)
    Toggle(s3,"RageHidePeek","Hide Shots on Peek",false)

    local s4=newSection(p,"Humanize / Flick","!")
    Toggle(s4,"RageHumanize","Humanize Aim",false)
    Dropdown(s4,"RageCurve","Curve",{"Linear","EaseIn","EaseOut","EaseInOut","Bezier","Flick","Snap"},"EaseOut")
    Slider(s4,"RageSmooth","Smoothing",3,1,20,0.5)
    Toggle(s4,"RageFlick","Flick Mode",false)
    Slider(s4,"RageFlickDeg","Flick Angle",15,1,180,1,"°")
    Slider(s4,"RageFlickMs","Flick Duration",80,10,500,10,"ms")
end)

newTab("ANTI-AIM","<",function(p)
    local s=newSection(p,"Yaw","<")
    Toggle(s,"AAEnabled","Enable Anti-Aim",false)
    Dropdown(s,"AAYawMode","Yaw Mode",{"Backwards","Jitter","Spin","Zero","Sideways","Random","LBY-Break"},"Jitter")
    Slider(s,"AADesync","Desync Angle",58,-180,180,1,"°")
    Keybind(s,"AAInvert","Invert Key",Enum.KeyCode.X,"Toggle")
    local s2=newSection(p,"Pitch","v")
    Toggle(s2,"AAPitchOn","Enable Pitch",false)
    Dropdown(s2,"AAPitch","Pitch",{"Down","Up","Zero","Jitter"},"Down")
    local s3=newSection(p,"Fakelag","~")
    Toggle(s3,"FakeLag","Fakelag",false)
    Slider(s3,"FakeLagT","Choke Ticks",7,1,14,1)
    Dropdown(s3,"FakeLagMode","Mode",{"Static","Adaptive","Jitter","OnPeek","OnMove"},"Adaptive")
end)

newTab("AA+ PEAK","<<",function(p)
    local s=newSection(p,"Yaw Base","<<")
    Toggle(s,"AAXOn","Enable AA+",false)
    Dropdown(s,"AAXBase","Yaw Base",{"Target","Local","At-Targets","Freestanding","Static"},"At-Targets")
    Slider(s,"AAXYawAdd","Yaw Add",0,-180,180,1,"°")
    Dropdown(s,"AAXMod","Yaw Modifier",{"None","Center","Offset","Spin","Random","Jitter","Sway","3-way"},"Jitter")
    Slider(s,"AAXModDeg","Modifier Deg",15,0,180,1,"°")
    Slider(s,"AAXModHz","Modifier Hz",8,0.1,30,0.1)

    local s2=newSection(p,"Desync","#")
    Toggle(s2,"AAXDesyncReal","Desync Real",true)
    Slider(s2,"AAXDesyncL","Desync Left",58,0,60,1,"°")
    Slider(s2,"AAXDesyncR","Desync Right",58,0,60,1,"°")
    Toggle(s2,"AAXLBY","LBY Breaker",true)
    Toggle(s2,"AAXMicro","Micro Jitter",true)
    Slider(s2,"AAXMicroDeg","Micro Deg",3,0,20,1,"°")
    Toggle(s2,"AAXBodyYaw","Body Yaw",true)
    Slider(s2,"AAXBodyDeg","Body Yaw Deg",90,0,180,1,"°")
    Toggle(s2,"AAXEdge","Edge Yaw",false)

    local s3=newSection(p,"Per-State AA","s")
    Label(s3,"Different yaw per movement state")
    Dropdown(s3,"AAXStand","Standing",{"Inherit","Backwards","Jitter","Spin","Sideways"},"Inherit")
    Dropdown(s3,"AAXMove","Moving",{"Inherit","Backwards","Jitter","Spin","Sideways"},"Inherit")
    Dropdown(s3,"AAXAir","In Air",{"Inherit","Backwards","Jitter","Spin","Sideways","Zero"},"Zero")
    Dropdown(s3,"AAXCrouch","Crouching",{"Inherit","Backwards","Jitter","Spin","Sideways"},"Inherit")
    Dropdown(s3,"AAXSlowWalk","Slow Walk",{"Inherit","Backwards","Jitter","Spin","Sideways"},"Jitter")

    local s4=newSection(p,"Pitch / Roll / Sway","~")
    Dropdown(s4,"AAXPitch","Pitch",{"None","Down","Up","Zero","Fake","Jitter","Random"},"Down")
    Slider(s4,"AAXPitchDeg","Pitch Deg",89,0,89,1,"°")
    Dropdown(s4,"AAXRoll","Roll",{"None","Left","Right","Alternate","Sway"},"None")
    Slider(s4,"AAXRollDeg","Roll Deg",30,0,180,1,"°")
    Toggle(s4,"AAXSway","Sine Sway",false)
    Slider(s4,"AAXSwayHz","Sway Hz",1.5,0.1,20,0.1)
    Slider(s4,"AAXSwayDeg","Sway Deg",8,0,60,1,"°")

    local s5=newSection(p,"Manual / On-Shot / Defensive","!")
    Toggle(s5,"AAXManual","Enable Manual",false)
    Keybind(s5,"AAXML","Manual Left",Enum.KeyCode.Left,"Hold")
    Keybind(s5,"AAXMR","Manual Right",Enum.KeyCode.Right,"Hold")
    Keybind(s5,"AAXMB","Manual Back",Enum.KeyCode.Down,"Hold")
    Keybind(s5,"AAXMF","Manual Forward",Enum.KeyCode.Up,"Hold")
    Keybind(s5,"AAXFlip","Inverter",Enum.KeyCode.X,"Toggle")
    Toggle(s5,"AAXOnShot","On-Shot AA",true)
    Slider(s5,"AAXOSDeg","On-Shot Flip",180,0,360,1,"°")
    Slider(s5,"AAXOSms","On-Shot Hold",220,50,1000,10,"ms")
    Toggle(s5,"AAXDef","Defensive AA",true)
    Slider(s5,"AAXDefMs","Defensive Hold",320,50,1500,10,"ms")

    local s6=newSection(p,"Freestanding / HUD","o")
    Toggle(s6,"AAXFree","Freestanding",true)
    Slider(s6,"AAXFreeDist","Freestand Scan",20,2,60,1,"s")
    Toggle(s6,"AAXAtTgt","At-Targets",true)
    Toggle(s6,"AAXAtBest","Use Best vs Closest",true)
    Toggle(s6,"AAXArrow","Desync Arrow HUD",true)
    Toggle(s6,"AAXTriangle","Full Triangle Indicator",true)
end)

newTab("FAKE POS","~",function(p)
    local s=newSection(p,"Engine","~")
    Toggle(s,"FPOn","Enable Fake Position",false)
    Dropdown(s,"FPEngine","Engine",{"Static","Orbit","OrbitDual","Random","Behind","MouseDrag","Teleport","Zigzag","PathReplay","Mirror","PingTP","Split","Choke-Freeze","Warp","Figure8"},"OrbitDual")
    Slider(s,"FPRadius","Radius",10,1,80,1,"s")
    Slider(s,"FPHeight","Height",0,-20,20,0.5,"s")
    Slider(s,"FPSpeed","Speed",3,0,30,0.1)
    Toggle(s,"FPDual","Dual Ghost",true)
    Toggle(s,"FPColor","Color Shift",true)
    Slider(s,"FPAlpha","Ghost Alpha",0.4,0,1,0.05)
    ColorBox(s,"FPCol","Ghost Color",Color3.fromRGB(180,100,255))
    Keybind(s,"FPKey","Toggle Key",Enum.KeyCode.V,"Toggle")
    local s2=newSection(p,"Extras","*")
    Slider(s2,"FPReplayMs","Replay Lag",350,50,1500,10,"ms")
    Toggle(s2,"FPBlink","Blink Teleport",false)
    Keybind(s2,"FPBlinkKey","Blink Key",Enum.KeyCode.G,"Hold")
    Slider(s2,"FPBlinkDist","Blink Distance",8,2,40,1,"s")
    Toggle(s2,"FPWarpShot","Warp On Shot",false)
    Toggle(s2,"FPFreezePeek","Freeze on Peek",false)
    Toggle(s2,"FPGhostTrail","Ghost Trail",false)
end)

newTab("AUTOWALL","#",function(p)
    local s=newSection(p,"Autowall","#")
    Toggle(s,"AwOn","Enable",true)
    Slider(s,"AwMin","Min Wall Dmg",20,1,150,1)
    Slider(s,"AwPen","Max Penetrations",2,1,5,1)
    Slider(s,"AwLoss","Damage Per Wall",25,5,80,1)
    local s2=newSection(p,"Resolver","?")
    Toggle(s2,"ResOn","Enable",true)
    Dropdown(s2,"ResMode","Mode",{"Brute","Memory","Jitter","Static","LBY","Adaptive","LBY-Freestand","Velocity"},"Adaptive")
    Slider(s2,"ResMax","Max Misses",2,1,10,1)
    Slider(s2,"ResStep","Brute Step",58,1,180,1,"°")
    Toggle(s2,"ResForceBody","Force Body on Miss",true)
    Toggle(s2,"ResSafe","Prefer Safepoint",true)
end)

newTab("LEGIT","o",function(p)
    local s=newSection(p,"Legit Aim","o")
    Toggle(s,"LegitOn","Enable",false)
    Slider(s,"LegitFov","FOV",25,1,200,1,"px")
    Slider(s,"LegitSmooth","Smoothing",8,1,30,0.5)
    Dropdown(s,"LegitHB","Hitbox",{"Head","Torso","Nearest"},"Head")
    Toggle(s,"LegitVis","Visible Only",true)
    Toggle(s,"LegitPredict","Predict",false)
    Slider(s,"LegitPredMs","Predict ms",80,0,500,10,"ms")
    Keybind(s,"LegitKey","Legit Key","MB2","Hold")
    local s2=newSection(p,"Trigger Bot","!")
    Toggle(s2,"TrigOn","Enable",false)
    Slider(s2,"TrigDelay","Delay",0.03,0,0.5,0.01,"s")
    Slider(s2,"TrigBurst","Burst Count",1,1,10,1)
    Slider(s2,"TrigReset","Reset Cooldown",0.15,0,1,0.01,"s")
    Toggle(s2,"TrigHeadOnly","Head Only",false)
    Keybind(s2,"TrigKey","Trigger Key",Enum.KeyCode.C,"Hold")
end)

newTab("ESP+","*",function(p)
    local s=newSection(p,"Core","*")
    Toggle(s,"EspOn","Enable ESP",false)
    Toggle(s,"EspBox","Box",true)
    Dropdown(s,"EspBoxStyle","Box Style",{"Full","Corner","Rounded","3D"},"Corner")
    Toggle(s,"EspFilled","Filled Box",false)
    Slider(s,"EspBoxOpa","Fill Opacity",0.2,0,1,0.05)
    Toggle(s,"EspName","Name",true)
    Toggle(s,"EspHealth","Health Bar",true)
    Toggle(s,"EspHealthText","Health Text",false)
    Toggle(s,"EspDist","Distance",true)
    Toggle(s,"EspWeapon","Weapon",false)
    Toggle(s,"EspTeamTag","Team Tag",false)

    local s2=newSection(p,"Lines / Dots","-")
    Toggle(s2,"EspSkeleton","Skeleton",false)
    Toggle(s2,"EspHeadDot","Head Dot",false)
    Toggle(s2,"EspHeadCircle","Head Circle",false)
    Toggle(s2,"EspTracer","Tracer",false)
    Dropdown(s2,"EspTracerO","Tracer Origin",{"Bottom","Mouse","Top","Center"},"Bottom")
    Toggle(s2,"EspSnapline","Snapline (to target)",false)
    Toggle(s2,"EspOffscreen","Off-Screen Arrow",true)
    Slider(s2,"EspArrowRad","Arrow Radius",180,50,400,5)
    Slider(s2,"EspFontSize","Font Size",14,8,24,1)
    Toggle(s2,"EspTeamShow","Show Team",false)
    Toggle(s2,"EspTeamColor","Use Team Color",false)
    Toggle(s2,"EspRainbow","Rainbow Color",false)
    ColorBox(s2,"EspColor","Enemy Color",Color3.fromRGB(255,60,120))
    ColorBox(s2,"EspFriendColor","Friend Color",Color3.fromRGB(80,180,255))

    local s3=newSection(p,"Chams","#")
    Toggle(s3,"ChamsOn","Enable Chams",false)
    Dropdown(s3,"ChamsMat","Material",{"ForceField","Neon","Plastic","Glass","SmoothPlastic","Metal"},"ForceField")
    ColorBox(s3,"ChamsColor","Fill",Color3.fromRGB(255,0,120))
    Slider(s3,"ChamsFill","Fill Transparency",0.4,0,1,0.05)
    Toggle(s3,"ChamsVisCheck","Visible-Check Color",true)
    ColorBox(s3,"ChamsVisColor","Visible Color",Color3.fromRGB(80,230,160))
    ColorBox(s3,"ChamsOutline","Outline",Color3.fromRGB(255,255,255))
end)

newTab("VISUALS","+",function(p)
    local s=newSection(p,"HUD","+")
    Toggle(s,"VisFov","FOV Circle",true)
    ColorBox(s,"VisFovColor","FOV Color",Color3.fromRGB(180,100,255))
    Toggle(s,"VisFovFilled","Fill FOV",false)
    Toggle(s,"VisLegitFov","Legit FOV Circle",true)
    Toggle(s,"VisTargetBox","Target Highlight",true)
    Toggle(s,"VisHcBar","Hitchance Bar",true)
    Toggle(s,"VisStats","Stats Panel",true)
    Toggle(s,"VisWater","Watermark",true)
    Toggle(s,"VisKeybinds","Keybinds List",true)

    local s2=newSection(p,"Crosshair","+")
    Toggle(s2,"XhOn","Enable Crosshair",false)
    Dropdown(s2,"XhStyle","Style",{"Plus","Dot","T","Circle","Cross+Dot","X","Lines"},"Plus")
    Slider(s2,"XhSize","Size",10,2,40,1)
    Slider(s2,"XhGap","Gap",3,0,20,1)
    Slider(s2,"XhThick","Thickness",1,1,5,1)
    ColorBox(s2,"XhColor","Color",Color3.fromRGB(180,100,255))
    Toggle(s2,"XhOutline","Outline",true)
end)

newTab("WORLD","W",function(p)
    local s=newSection(p,"World","W")
    Toggle(s,"NoFog","No Fog",false)
    Toggle(s,"FullBright","Fullbright",false)
    Slider(s,"Bright","Brightness",2,0,10,0.1)
    Toggle(s,"TimeLock","Time Lock (Noon)",false)
    Toggle(s,"RemoveParticles","Remove Particles",false)
    local s2=newSection(p,"Camera","C")
    Toggle(s2,"CamFovOn","Apply Camera FOV",false)
    Slider(s2,"CamFov","Camera FOV",70,1,120,1)
    Toggle(s2,"ThirdP","Third Person",false)
    Slider(s2,"TPDist","3rd Person Distance",12,2,40,1)
end)

newTab("MOVEMENT","^",function(p)
    local s=newSection(p,"Movement","^")
    Toggle(s,"Bhop","Bunnyhop",false)
    Toggle(s,"InfJump","Infinite Jump",false)
    Toggle(s,"WsOn","Apply Walkspeed",false)
    Slider(s,"Ws","Walkspeed",16,16,500,1)
    Toggle(s,"JpOn","Apply JumpPower",false)
    Slider(s,"Jp","JumpPower",50,50,1000,1)
    Toggle(s,"Noclip","Noclip",false)
    Toggle(s,"HipFire","Lock Rotation Off",false)
    local s2=newSection(p,"Fly","^^")
    Toggle(s2,"Fly","Fly",false)
    Slider(s2,"FlySpd","Fly Speed",50,5,300,1)
    Keybind(s2,"FlyKey","Fly Key",Enum.KeyCode.F,"Toggle")
end)

newTab("MISC","=",function(p)
    local s=newSection(p,"Automation","=")
    Toggle(s,"AntiAfk","Anti AFK",true)
    Toggle(s,"HitSound","Hit Sound",true)
    Slider(s,"HitVol","Hit Sound Volume",0.6,0,2,0.05)
    TextInput(s,"HitSoundId","Hit Sound ID","3744371091","asset id")
    Toggle(s,"KillSound","Kill Sound",false)
    TextInput(s,"KillSoundId","Kill Sound ID","131886985","asset id")
    local s2=newSection(p,"Menu","M")
    Keybind(s2,"MenuKey","Toggle Menu",Enum.KeyCode.RightShift,"Hold")
    Slider(s2,"MenuAlpha","Menu Opacity",1,0.2,1,0.05)
end)

newTab("CONFIG","$",function(p)
    local s=newSection(p,"Config","$")
    TextInput(s,"CfgName","Config Name","default","")
    Button(s,"SAVE",function()
        local d={Opt={},Tog={}}
        for k,v in pairs(V6.Opt) do if typeof(v)~="Color3" and type(v)~="function" then d.Opt[k]=v end end
        for k,v in pairs(V6.Tog) do d.Tog[k]=v end
        if writefile then pcall(writefile,"UEV6_"..(O.CfgName or "default")..".json",HttpService:JSONEncode(d)) end
    end)
    Button(s,"LOAD",function()
        local f="UEV6_"..(O.CfgName or "default")..".json"
        if isfile and isfile(f) then local d=HttpService:JSONDecode(readfile(f)); for k,v in pairs(d.Opt or {}) do V6.Opt[k]=v end; for k,v in pairs(d.Tog or {}) do V6.Tog[k]=v end end
    end)
    Button(s,"UNLOAD",function() V6.Unload() end)
    local s2=newSection(p,"About","?")
    Label(s2,"UNNAMED ENHANCEMENTS V6",TH.ac)
    Label(s2,"Built by Olivia")
    Label(s2,"discord.gg/ojailbreaks",TH.ac2)
end)

-- open AC tab first
openTab("AC SAFE")

------------------------------------------------------
-- ENGINES — gated by master toggles for zero cost when off
------------------------------------------------------
local function alive(p) return p and p~=LP and p.Character and p.Character.Parent and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChildOfClass("Humanoid") and p.Character:FindFirstChildOfClass("Humanoid").Health>0 end
local function enemyOf(p) if not T.RageIgnoreTeam then return true end; return p.Team~=LP.Team end
local function w2s(pos) local v,on=Camera:WorldToViewportPoint(pos); return Vector2.new(v.X,v.Y),on,v.Z end
local function los(from,hit) local d=hit.Position-from; local rp=RaycastParams.new(); rp.FilterDescendantsInstances={LP.Character,Camera}; rp.FilterType=Enum.RaycastFilterType.Exclude; local r=Workspace:Raycast(from,d,rp); if not r then return true end; return r.Instance:IsDescendantOf(hit.Parent) end
local function bestHitbox(char)
    local name=O.RageHitbox or "Head"
    if name=="Nearest" then local m=UserInputService:GetMouseLocation(); local best,bd; for _,n in ipairs({"Head","UpperTorso","Torso","HumanoidRootPart"}) do local p=char:FindFirstChild(n); if p then local s,on=w2s(p.Position); if on then local d=(s-m).Magnitude; if not bd or d<bd then bd,best=d,p end end end end; return best end
    if name=="MultiScan" then
        local best,bw
        for n,w in pairs({Head=O.RageHbHead,UpperTorso=O.RageHbChest,HumanoidRootPart=O.RageHbPelvis,LeftUpperArm=O.RageHbArms,RightUpperArm=O.RageHbArms,LeftUpperLeg=O.RageHbLegs,RightUpperLeg=O.RageHbLegs}) do
            local pt=char:FindFirstChild(n); if pt and w>0 then if not bw or w>bw then bw,best=w,pt end end
        end
        return best or char:FindFirstChild("HumanoidRootPart")
    end
    return char:FindFirstChild(name) or char:FindFirstChild("HumanoidRootPart")
end

-- backtrack — only when rage on
local function bt_push(p) if not alive(p) then return end; local hrp=p.Character.HumanoidRootPart; local buf=S.backtrack[p] or {}; S.backtrack[p]=buf; table.insert(buf,1,{t=os.clock(),pos=hrp.Position,vel=hrp.AssemblyLinearVelocity}); local c=os.clock()-1; while buf[#buf] and buf[#buf].t<c do buf[#buf]=nil end end
local function bt_sample(p,ms) local buf=S.backtrack[p]; if not buf then return nil end; local tg=os.clock()-math.clamp(ms,0,1000)/1000; for _,r in ipairs(buf) do if r.t<=tg then return r end end; return buf[1] end
local function self_bt_push() if not alive(LP) then return end; table.insert(S.selfPath,1,{t=os.clock(),cf=LP.Character.HumanoidRootPart.CFrame}); while S.selfPath[#S.selfPath] and os.clock()-S.selfPath[#S.selfPath].t>2 do S.selfPath[#S.selfPath]=nil end end
local function self_bt(ms) local tg=os.clock()-ms/1000; for _,r in ipairs(S.selfPath) do if r.t<=tg then return r end end; return S.selfPath[#S.selfPath] end

local function hitchance(from,part,vel,pred)
    if not T.RageHcGate then return 100 end
    local n=O.RageHcSamples or 12; local hits=0
    local j=math.min(vel.Magnitude/40,1.5)
    for i=1,n do
        local ox=(math.random()*2-1)*j; local oz=(math.random()*2-1)*j
        local tgt=part.Position+Vector3.new(ox,0,oz)+vel*pred
        local rp=RaycastParams.new(); rp.FilterDescendantsInstances={LP.Character,Camera}; rp.FilterType=Enum.RaycastFilterType.Exclude
        local r=Workspace:Raycast(from,tgt-from,rp)
        if not r or r.Instance:IsDescendantOf(part.Parent) then hits+=1 end
    end
    return hits/n*100
end
local function autowall(from,part)
    if not T.AwOn then return 100 end
    local dir=part.Position-from; local rp=RaycastParams.new(); rp.FilterDescendantsInstances={LP.Character,Camera}; rp.FilterType=Enum.RaycastFilterType.Exclude
    local p=from; local rem=100; local loss=O.AwLoss or 25
    for i=1,O.AwPen do local r=Workspace:Raycast(p,dir.Unit*dir.Magnitude,rp); if not r then return rem end; if r.Instance:IsDescendantOf(part.Parent) then return rem end; rem-=loss; if rem<O.AwMin then return 0 end; p=r.Position+dir.Unit*0.5 end
    return rem
end
local function resolver_fix(p,part)
    if not T.ResOn then return part.Position end
    local r=S.resolver[p] or {yaw=0,misses=0}; S.resolver[p]=r
    local mode=O.ResMode; local step=O.ResStep; local yaw=r.yaw
    if mode=="Brute" then yaw=(r.misses*step)%360
    elseif mode=="Jitter" then yaw=((os.clock()*4)%2<1) and step or -step
    elseif mode=="LBY" then yaw=math.sin(os.clock()*2)*60
    elseif mode=="Memory" then yaw=r.lastHit or 0
    elseif mode=="Adaptive" then local v=part.AssemblyLinearVelocity.Magnitude; yaw=(v>2 and 0) or ((r.misses*step)%360)
    elseif mode=="LBY-Freestand" then local to=LP.Character.HumanoidRootPart.Position-part.Position; yaw=math.deg(math.atan2(to.X,to.Z))
    elseif mode=="Velocity" then local v=part.AssemblyLinearVelocity; yaw=math.deg(math.atan2(v.X,v.Z)) end
    local off=(p.Character.HumanoidRootPart.CFrame*CFrame.Angles(0,math.rad(yaw),0)).LookVector*0.3
    return part.Position+off
end
local function resolver_hit(p) local r=S.resolver[p] or {yaw=0,misses=0}; r.lastHit=r.yaw; r.misses=0; S.resolver[p]=r end

local function pickTarget()
    if not T.RageEnabled then return nil end
    local km=O.RageKeyMode
    if (km=="Hold" or km=="Toggle") and not K.RageKey.state then return nil end
    if T.RageLockTarget and S.target and alive(S.target) and enemyOf(S.target) then return S.target end
    local m=UserInputService:GetMouseLocation(); local fov=O.RageFov; local prio=O.RagePrio
    local best,bs
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=LP and alive(p) and enemyOf(p) then
            local hum=p.Character:FindFirstChildOfClass("Humanoid")
            if not (T.RageIgnoreLow and hum and hum.Health<10) then
                local part=bestHitbox(p.Character)
                if part then
                    local s,on=w2s(part.Position); local d2=(s-m).Magnitude; local d3=(part.Position-Camera.CFrame.Position).Magnitude
                    if on and d2<=fov and d3<=O.RageMaxDist then
                        if (not T.RageVisibleOnly) or los(Camera.CFrame.Position,part) then
                            local sc
                            if prio=="FOV" then sc=d2
                            elseif prio=="Distance" then sc=d3
                            elseif prio=="Health" or prio=="LowestHP" then sc=hum and hum.Health or 100
                            elseif prio=="Crosshair" then sc=d2*0.6+d3*0.4
                            elseif prio=="HighestDmg" then sc=-autowall(Camera.CFrame.Position,part)
                            elseif prio=="Random" then sc=math.random()
                            else sc=d2 end
                            if not bs or sc<bs then best,bs=p,sc end
                        end
                    end
                end
            end
        end
    end
    return best
end

local function fire_shot()
    local now=os.clock()
    while #S.shotsBucket>0 and now-S.shotsBucket[1]>1 do table.remove(S.shotsBucket,1) end
    if not T.RageFastFire and #S.shotsBucket>=O.RageSPS then return end
    if now-S.lastShot<(O.RageShotDelay or 0.05) then return end
    S.lastShot=now
    safe(function() VirtualInput:SendMouseButtonEvent(0,0,0,true,game,1); task.wait(); VirtualInput:SendMouseButtonEvent(0,0,0,false,game,1) end)
    table.insert(S.shotsBucket,now)
    S.stats.shots+=1
    S.onShotUntil = now + (O.AAXOSms or 0)/1000
    S.defUntil    = now + (O.AAXDefMs or 0)/1000
    if T.RageAutoCrouch and alive(LP) then local h=LP.Character:FindFirstChildOfClass("Humanoid"); if h then safe(function() h.Jump=false; h:ChangeState(Enum.HumanoidStateType.PlatformStanding) end) end end
end

-- silent aim hook
local function try_hook()
    if T.AcNoHook then return end
    local mt=getrawmetatable and getrawmetatable(game); if not mt or not setreadonly then return end
    safe(setreadonly,mt,false)
    local oldIdx=mt.__index; local oldNc=mt.__namecall
    mt.__index = newcclosure(function(self,k)
        if self==LP and k=="GetMouse" then local real=oldIdx(self,k); return function(...) local m=real(...); if S.aimPos and T.RageEnabled and T.RageSilent then safe(function() m.Hit=CFrame.new(S.aimPos) end) end; return m end end
        return oldIdx(self,k)
    end)
    mt.__namecall = newcclosure(function(self,...)
        if S.aimPos and T.RageSilent and T.RageEnabled then local method=getnamecallmethod(); if method=="ScreenPointToRay" or method=="ViewportPointToRay" then local dir=(S.aimPos-Camera.CFrame.Position).Unit; return Ray.new(Camera.CFrame.Position,dir*500) end end
        return oldNc(self,...)
    end)
    safe(setreadonly,mt,true)
end
pcall(try_hook)

local function rage_tick()
    if not T.RageEnabled then S.target=nil; S.aimPos=nil; return end
    if os.clock()-S.lastKillAt<O.RageKillDelay then return end
    local tgt=pickTarget(); if not tgt then S.target=nil; S.aimPos=nil; return end
    if S.target~=tgt then if os.clock()-S.lastSwitch<O.RageSwitch then return end; S.lastSwitch=os.clock() end
    S.target=tgt
    local part=bestHitbox(tgt.Character); if not part then return end
    local aim=part.Position
    if T.RageBT then local rec=bt_sample(tgt,O.RageBTms); if rec then aim=rec.pos end end
    if T.RagePred then local vel=part.AssemblyLinearVelocity; if T.RageAirPred or math.abs(vel.Y)<1 then aim+=vel*O.RagePredFactor end; if T.RageCurvePred then aim+=Vector3.new(0,-0.5*9.81*O.RagePredFactor^2,0) end end
    aim = aim + (resolver_fix(tgt,part)-part.Position)
    local hc=hitchance(Camera.CFrame.Position,part,part.AssemblyLinearVelocity,O.RagePredFactor)
    local dmg=autowall(Camera.CFrame.Position,part); S.hitChance=hc
    if hc<O.RageHc or dmg<O.RageMinDmg then S.aimPos=nil; return end
    if T.RageSafepoint then aim=aim:Lerp(part.Position,O.RageSPBias) end
    if T.RageForceHS and tgt.Character:FindFirstChild("Head") then aim=tgt.Character.Head.Position
    elseif T.RageForceBaim then local b=tgt.Character:FindFirstChild("UpperTorso") or tgt.Character:FindFirstChild("Torso"); if b then aim=b.Position end end
    S.aimPos=aim
    if T.RageAutoFire then local tries = T.RageMagicBullet and O.RageMagicTries or 1; for i=1,tries do fire_shot(); if i<tries then task.wait() end end end
end

-- anti-aim engine — per-state
local function getState()
    if not alive(LP) then return "none" end
    local h=LP.Character:FindFirstChildOfClass("Humanoid"); if not h then return "none" end
    local s=h:GetState()
    if s==Enum.HumanoidStateType.Freefall or s==Enum.HumanoidStateType.Jumping then return "Air" end
    local v=LP.Character.HumanoidRootPart.AssemblyLinearVelocity
    if v.Magnitude>2 then if T.RageSlow and K and K.RageSlowKey and K.RageSlowKey.state then return "SlowWalk" end; return "Move" end
    return "Stand"
end
local function stateOverride()
    local st=getState()
    local map={Stand=O.AAXStand,Move=O.AAXMove,Air=O.AAXAir,Crouch=O.AAXCrouch,SlowWalk=O.AAXSlowWalk}
    local mode=map[st]; if not mode or mode=="Inherit" then return nil end
    if mode=="Backwards" then return math.pi
    elseif mode=="Jitter" then return ((os.clock()*6)%2<1) and math.pi/2 or -math.pi/2
    elseif mode=="Spin" then return (os.clock()*8)%(math.pi*2)
    elseif mode=="Sideways" then return math.pi/2
    elseif mode=="Zero" then return 0 end
end

local function at_targets_yaw()
    local best,bd
    for _,p in ipairs(Players:GetPlayers()) do if p~=LP and alive(p) and enemyOf(p) then local hrp=p.Character.HumanoidRootPart; local d=(hrp.Position-LP.Character.HumanoidRootPart.Position).Magnitude; local sc=T.AAXAtBest and -d or d; if not bd or sc<bd then bd,best=sc,hrp end end end
    if not best then return 0 end
    local to=best.Position-LP.Character.HumanoidRootPart.Position
    return math.atan2(to.X,to.Z)+math.pi
end
local function freestand_side()
    if not alive(LP) then return 1 end
    local hrp=LP.Character.HumanoidRootPart; local rp=RaycastParams.new(); rp.FilterDescendantsInstances={LP.Character,Camera}; rp.FilterType=Enum.RaycastFilterType.Exclude
    local d=O.AAXFreeDist
    local rH=Workspace:Raycast(hrp.Position,hrp.CFrame.RightVector*d,rp)
    local lH=Workspace:Raycast(hrp.Position,-hrp.CFrame.RightVector*d,rp)
    local rS=rH and (d-(rH.Position-hrp.Position).Magnitude) or 0
    local lS=lH and (d-(lH.Position-hrp.Position).Magnitude) or 0
    return rS>=lS and 1 or -1
end
local function manual_dir() if not T.AAXManual then return nil end; if K.AAXML.state then return math.pi*0.5 end; if K.AAXMR.state then return -math.pi*0.5 end; if K.AAXMB.state then return math.pi end; if K.AAXMF.state then return 0 end end

local function apply_hrp(cf)
    if T.AcNoCFrame then return end
    if not alive(LP) then return end
    local hrp=LP.Character.HumanoidRootPart; local hum=LP.Character:FindFirstChildOfClass("Humanoid"); if not hum then return end
    if not T.AcNoAutoRot then safe(function() hum.AutoRotate=false end) end
    safe(function() hrp.CFrame=cf end)
end

local function aa_tick()
    if not T.AAEnabled and not T.AAXOn then return end
    if not alive(LP) then return end
    local hrp=LP.Character.HumanoidRootPart
    local yaw, pitch, roll = 0, 0, 0
    -- base yaw
    local ov = stateOverride()
    if ov then yaw = ov
    elseif T.AAXOn then
        local base=O.AAXBase
        local md=manual_dir()
        if md then yaw=md
        elseif base=="At-Targets" and T.AAXAtTgt then yaw=at_targets_yaw()
        elseif base=="Freestanding" and T.AAXFree then yaw=math.pi+freestand_side()*math.rad(O.AAXDesyncR)
        elseif base=="Target" and S.target and alive(S.target) then local to=S.target.Character.HumanoidRootPart.Position-hrp.Position; yaw=math.atan2(to.X,to.Z)+math.pi
        elseif base=="Local" then yaw=select(2,Camera.CFrame:ToEulerAnglesYXZ())
        end
        yaw+=math.rad(O.AAXYawAdd or 0)
        local mod=O.AAXMod; local deg=math.rad(O.AAXModDeg or 15); local hz=O.AAXModHz or 8
        if mod=="Offset" then yaw+=deg
        elseif mod=="Spin" then yaw+=(os.clock()*hz)%(math.pi*2)
        elseif mod=="Jitter" then yaw+=((os.clock()*hz)%2<1) and deg or -deg
        elseif mod=="Random" then yaw+=math.rad(math.random(-math.deg(deg),math.deg(deg)))
        elseif mod=="Sway" then yaw+=math.sin(os.clock()*hz)*deg
        elseif mod=="3-way" then local ph=(math.floor(os.clock()*hz)%3); yaw+=(ph==0 and deg or ph==1 and -deg or 0) end
        if T.AAXDesyncReal then S.aaSide=-S.aaSide; yaw+=math.rad((S.aaSide>0) and O.AAXDesyncR or -O.AAXDesyncL) end
        if K.AAXFlip and K.AAXFlip.state then yaw=-yaw end
        if T.AAXLBY then yaw+=math.sin(os.clock()*4)*math.rad(5) end
        if T.AAXMicro then yaw+=math.rad(math.random(-(O.AAXMicroDeg or 3),O.AAXMicroDeg or 3)) end
        if T.AAXOnShot and os.clock()<S.onShotUntil then yaw+=math.rad(O.AAXOSDeg or 180) end
        if T.AAXDef and os.clock()<S.defUntil then yaw+=math.rad(math.sin(os.clock()*18)*25) end
        local p=O.AAXPitch; local pd=math.rad(O.AAXPitchDeg or 89)
        if p=="Down" then pitch=-pd elseif p=="Up" then pitch=pd elseif p=="Fake" then pitch=((math.floor(os.clock()*4)%2)==0) and -pd or pd elseif p=="Jitter" then pitch=(os.clock()*10)%2<1 and -pd or pd elseif p=="Random" then pitch=(math.random()*2-1)*pd end
        local r=O.AAXRoll; local rd=math.rad(O.AAXRollDeg or 30)
        if r=="Left" then roll=-rd elseif r=="Right" then roll=rd elseif r=="Alternate" then roll=((math.floor(os.clock()*2)%2)==0) and rd or -rd elseif r=="Sway" then roll=math.sin(os.clock()*2)*rd end
        if T.AAXSway then yaw+=math.sin(os.clock()*(O.AAXSwayHz or 1.5))*math.rad(O.AAXSwayDeg or 8); pitch+=math.cos(os.clock()*(O.AAXSwayHz or 1.5))*math.rad((O.AAXSwayDeg or 8)*0.4) end
    elseif T.AAEnabled then
        local m=O.AAYawMode
        if m=="Backwards" then yaw=math.pi elseif m=="Jitter" then yaw=((os.clock()*6)%2<1) and math.pi/2 or -math.pi/2 elseif m=="Spin" then yaw=(os.clock()*8)%(math.pi*2) elseif m=="Sideways" then yaw=math.pi/2 elseif m=="Random" then yaw=math.rad(math.random(-180,180)) elseif m=="LBY-Break" then yaw=math.sin(os.clock()*3)*math.pi end
        if K.AAInvert and K.AAInvert.state then yaw=-yaw end
        yaw+=math.rad(O.AADesync or 58)
        if T.AAPitchOn then local p=O.AAPitch; if p=="Down" then pitch=math.rad(-89) elseif p=="Up" then pitch=math.rad(89) elseif p=="Jitter" then pitch=((os.clock()*10)%2<1) and math.rad(-89) or math.rad(89) end end
    end
    apply_hrp(CFrame.new(hrp.Position)*CFrame.Angles(pitch,yaw,roll))
    S.desyncYaw=yaw
end

-- fake pos
local function ghost(key,color) local g=V6.Ghosts[key]; if g and g.Parent then return g end; g=Instance.new("Part"); g.Size=Vector3.new(2,5,1); g.Anchored=true; g.CanCollide=false; g.Material=Enum.Material.ForceField; g.Color=color or TH.ac; g.Transparency=0.4; safe(function() g.Parent=Workspace end); V6.Ghosts[key]=g; return g end
local function killGhost(k) if V6.Ghosts[k] then safe(function() V6.Ghosts[k]:Destroy() end); V6.Ghosts[k]=nil end end

local function fakepos_tick()
    if not T.FPOn then killGhost("g1"); killGhost("g2"); return end
    if not alive(LP) then return end
    local hrp=LP.Character.HumanoidRootPart; local e=O.FPEngine; local R=O.FPRadius; local H=O.FPHeight; local t=os.clock()*(O.FPSpeed or 3)
    local p1,p2
    if e=="Static" then p1=hrp.Position+Vector3.new(R,H,0); p2=hrp.Position-Vector3.new(R,H,0)
    elseif e=="Orbit" then p1=hrp.Position+Vector3.new(math.cos(t)*R,H,math.sin(t)*R); p2=p1
    elseif e=="OrbitDual" then p1=hrp.Position+Vector3.new(math.cos(t)*R,H,math.sin(t)*R); p2=hrp.Position+Vector3.new(math.cos(t+math.pi)*R,H,math.sin(t+math.pi)*R)
    elseif e=="Random" then p1=hrp.Position+Vector3.new((math.random()*2-1)*R,H,(math.random()*2-1)*R); p2=hrp.Position-(p1-hrp.Position)
    elseif e=="Behind" then p1=hrp.Position-hrp.CFrame.LookVector*R+Vector3.new(0,H,0); p2=p1
    elseif e=="Teleport" then p1=hrp.Position+(((math.floor(t*2)%2)==0) and Vector3.new(R,H,0) or Vector3.new(-R,H,0)); p2=p1
    elseif e=="Zigzag" then p1=hrp.Position+Vector3.new(math.sin(t*3)*R,H,math.cos(t)*R); p2=p1
    elseif e=="Figure8" then p1=hrp.Position+Vector3.new(math.sin(t)*R,H,math.sin(t*2)*R*0.5); p2=hrp.Position-(p1-hrp.Position)
    elseif e=="PathReplay" then local rec=self_bt(O.FPReplayMs or 350); p1=rec and rec.cf.Position or hrp.Position; p2=hrp.Position+Vector3.new(math.cos(t)*R*0.5,H,math.sin(t)*R*0.5)
    elseif e=="Mirror" then if S.target and alive(S.target) then local Tp=S.target.Character.HumanoidRootPart.Position; p1=Tp*2-hrp.Position+Vector3.new(0,H,0); p2=hrp.Position+(hrp.Position-Tp).Unit*R+Vector3.new(0,H,0) else p1=hrp.Position+Vector3.new(R,H,0); p2=hrp.Position-Vector3.new(R,H,0) end
    elseif e=="PingTP" then local ph=(math.floor(t*2)%3); p1=(ph==0) and hrp.Position+Vector3.new(R,H,0) or (ph==1) and hrp.Position+Vector3.new(0,H,R) or hrp.Position-Vector3.new(R,H,0); p2=hrp.Position-(p1-hrp.Position)
    elseif e=="Split" then p1=hrp.Position+Vector3.new(R,H,R); p2=hrp.Position+Vector3.new(-R,H,-R)
    elseif e=="Choke-Freeze" then p1=S.frozenAt or hrp.Position; p2=hrp.Position+Vector3.new(math.cos(t)*R,H,math.sin(t)*R)
    elseif e=="Warp" then p1=hrp.Position+hrp.CFrame.LookVector*R+Vector3.new(0,H,0); p2=hrp.Position-hrp.CFrame.LookVector*R+Vector3.new(0,H,0)
    elseif e=="MouseDrag" then local m=UserInputService:GetMouseLocation(); local ray=Camera:ViewportPointToRay(m.X,m.Y,R); p1=ray.Origin+ray.Direction*R; p2=p1 end
    if T.FPBlink and K.FPBlinkKey.state then p1=p1+hrp.CFrame.RightVector*(O.FPBlinkDist or 8) end
    local col = T.FPColor and Color3.fromHSV((os.clock()*0.2)%1,0.9,1) or (O.FPCol or TH.ac)
    local g1=ghost("g1",col); safe(function() g1.CFrame=CFrame.new(p1); g1.Transparency=O.FPAlpha; g1.Color=col end)
    if T.FPDual and p2 then local g2=ghost("g2",col:Lerp(Color3.new(1,1,1),0.4)); safe(function() g2.CFrame=CFrame.new(p2); g2.Transparency=(O.FPAlpha or 0.4)*0.9 end) else killGhost("g2") end
end

-- movement
local flyBV, flyBG
local function fly_update()
    if not alive(LP) then return end
    local hrp=LP.Character.HumanoidRootPart; local on=T.Fly or K.FlyKey.state
    if on and not T.AcNoBodyMover then
        if not flyBV then flyBV=Instance.new("BodyVelocity"); flyBV.MaxForce=Vector3.new(1,1,1)*1e9; flyBV.Velocity=Vector3.new(); safe(function() flyBV.Parent=hrp end); flyBG=Instance.new("BodyGyro"); flyBG.MaxTorque=Vector3.new(1,1,1)*1e9; safe(function() flyBG.Parent=hrp end) end
        local c=Camera.CFrame; local v=Vector3.new()
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then v+=c.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then v-=c.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then v-=c.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then v+=c.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then v+=Vector3.new(0,1,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then v-=Vector3.new(0,1,0) end
        flyBV.Velocity = v.Magnitude>0 and v.Unit*O.FlySpd or Vector3.new(); flyBG.CFrame=c
    elseif flyBV then safe(function() flyBV:Destroy() end); safe(function() flyBG:Destroy() end); flyBV=nil; flyBG=nil end
end
local function move_tick()
    if not alive(LP) then return end
    local hum=LP.Character:FindFirstChildOfClass("Humanoid"); if not hum then return end
    if T.WsOn then safe(function() hum.WalkSpeed=O.Ws end) end
    if T.JpOn then safe(function() hum.JumpPower=O.Jp end) end
    if T.Bhop and hum:GetState()==Enum.HumanoidStateType.Landed then safe(function() hum:ChangeState(Enum.HumanoidStateType.Jumping) end) end
    if T.Noclip then for _,p in ipairs(LP.Character:GetDescendants()) do if p:IsA("BasePart") then safe(function() p.CanCollide=false end) end end end
    fly_update()
end
C(UserInputService.JumpRequest:Connect(function() if T.InfJump and alive(LP) then safe(function() LP.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping) end) end end))

-- world
local function world_tick()
    safe(function()
        Lighting.FogEnd = T.NoFog and 1e9 or S.origFog
        Lighting.Brightness = T.FullBright and O.Bright or S.origBright
        if T.TimeLock then Lighting.ClockTime=12 end
        Camera.FieldOfView = T.CamFovOn and O.CamFov or 70
        if T.ThirdP then LP.CameraMode=Enum.CameraMode.Classic; LP.CameraMaxZoomDistance=O.TPDist; LP.CameraMinZoomDistance=O.TPDist
        else LP.CameraMaxZoomDistance=128; LP.CameraMinZoomDistance=0.5 end
    end)
end

-- ESP — lazy drawings
local SKEL_PAIRS = {
    {"Head","UpperTorso"},{"UpperTorso","LowerTorso"},
    {"UpperTorso","LeftUpperArm"},{"LeftUpperArm","LeftLowerArm"},{"LeftLowerArm","LeftHand"},
    {"UpperTorso","RightUpperArm"},{"RightUpperArm","RightLowerArm"},{"RightLowerArm","RightHand"},
    {"LowerTorso","LeftUpperLeg"},{"LeftUpperLeg","LeftLowerLeg"},{"LeftLowerLeg","LeftFoot"},
    {"LowerTorso","RightUpperLeg"},{"RightUpperLeg","RightLowerLeg"},{"RightLowerLeg","RightFoot"},
}
local function esp_ensure(p)
    local e=V6.ESP[p]; if e then return e end
    e={bones={}, corners={}}
    local hl=Instance.new("Highlight"); hl.FillTransparency=0.5; hl.Enabled=false; safe(function() hl.Parent=Workspace end); e.hl=hl
    e.box=D(Drawing.new("Square")); e.box.Thickness=1; e.box.Filled=false; e.box.Visible=false
    e.fill=D(Drawing.new("Square")); e.fill.Filled=true; e.fill.Visible=false
    for i=1,8 do e.corners[i]=D(Drawing.new("Line")); e.corners[i].Thickness=1; e.corners[i].Visible=false end
    e.name=D(Drawing.new("Text")); e.name.Size=14; e.name.Center=true; e.name.Outline=true; e.name.Visible=false; e.name.Font=3
    e.wep=D(Drawing.new("Text")); e.wep.Size=12; e.wep.Center=true; e.wep.Outline=true; e.wep.Visible=false; e.wep.Font=3
    e.hpbg=D(Drawing.new("Square")); e.hpbg.Filled=true; e.hpbg.Visible=false
    e.hp=D(Drawing.new("Square")); e.hp.Filled=true; e.hp.Visible=false
    e.hptxt=D(Drawing.new("Text")); e.hptxt.Size=11; e.hptxt.Center=true; e.hptxt.Outline=true; e.hptxt.Visible=false; e.hptxt.Font=3
    e.dist=D(Drawing.new("Text")); e.dist.Size=12; e.dist.Center=true; e.dist.Outline=true; e.dist.Visible=false; e.dist.Font=3
    e.tracer=D(Drawing.new("Line")); e.tracer.Thickness=1; e.tracer.Visible=false
    e.headDot=D(Drawing.new("Circle")); e.headDot.Filled=true; e.headDot.NumSides=16; e.headDot.Visible=false
    e.headCir=D(Drawing.new("Circle")); e.headCir.Filled=false; e.headCir.NumSides=24; e.headCir.Thickness=1; e.headCir.Visible=false
    e.arrow=D(Drawing.new("Triangle")); e.arrow.Filled=true; e.arrow.Visible=false
    for i=1,#SKEL_PAIRS do e.bones[i]=D(Drawing.new("Line")); e.bones[i].Thickness=1; e.bones[i].Visible=false end
    V6.ESP[p]=e; return e
end
local function hide_all(e)
    for k,d in pairs(e) do
        if k~="hl" and k~="bones" and k~="corners" and typeof(d)=="table" and d.Visible~=nil then d.Visible=false end
    end
    if e.bones then for _,b in ipairs(e.bones) do b.Visible=false end end
    if e.corners then for _,c in ipairs(e.corners) do c.Visible=false end end
    if e.hl then safe(function() e.hl.Enabled=false; e.hl.Adornee=nil end) end
end
local function esp_destroy(p)
    local e=V6.ESP[p]; if not e then return end
    if e.hl then safe(function() e.hl:Destroy() end) end
    for k,d in pairs(e) do if k~="hl" and k~="bones" and k~="corners" and typeof(d)=="table" and d.Remove then safe(function() d:Remove() end) end end
    if e.bones then for _,b in ipairs(e.bones) do safe(function() b:Remove() end) end end
    if e.corners then for _,c in ipairs(e.corners) do safe(function() c:Remove() end) end end
    V6.ESP[p]=nil
end
C(Players.PlayerRemoving:Connect(esp_destroy))
C(Players.PlayerAdded:Connect(function(p) p.CharacterRemoving:Connect(function() local e=V6.ESP[p]; if e then hide_all(e) end end) end))
for _,p in ipairs(Players:GetPlayers()) do if p~=LP then p.CharacterRemoving:Connect(function() local e=V6.ESP[p]; if e then hide_all(e) end end) end end

local function esp_tick()
    if not T.EspOn and not T.ChamsOn then for _,e in pairs(V6.ESP) do hide_all(e) end; return end
    local rainbow = T.EspRainbow and Color3.fromHSV((os.clock()*0.3)%1,0.9,1)
    for _,p in ipairs(Players:GetPlayers()) do if p~=LP then
        local e=esp_ensure(p)
        if not alive(p) then hide_all(e) else
            local col = rainbow or (T.EspTeamColor and (p.TeamColor and p.TeamColor.Color)) or (enemyOf(p) and O.EspColor or O.EspFriendColor)
            local show = T.EspOn and (enemyOf(p) or T.EspTeamShow)
            local showCham = T.ChamsOn and (enemyOf(p) or T.EspTeamShow)
            local char=p.Character; local hrp=char.HumanoidRootPart; local head=char:FindFirstChild("Head") or hrp
            local hum=char:FindFirstChildOfClass("Humanoid")
            if show then
                local s1,on1=w2s(head.Position+Vector3.new(0,0.5,0))
                local s2,on2=w2s(hrp.Position+Vector3.new(0,-3,0))
                if on1 and on2 then
                    local h=s2.Y-s1.Y; local w=h*0.55
                    local x,y=s1.X-w/2, s1.Y
                    -- box
                    if T.EspBox then
                        local st=O.EspBoxStyle
                        if st=="Full" then
                            e.box.Visible=true; e.corners[1].Visible=false
                            e.box.Size=Vector2.new(w,h); e.box.Position=Vector2.new(x,y); e.box.Color=col
                            for i=1,8 do e.corners[i].Visible=false end
                        elseif st=="Corner" then
                            e.box.Visible=false; local cl=w*0.25
                            local pts={
                                {Vector2.new(x,y),Vector2.new(x+cl,y)},{Vector2.new(x,y),Vector2.new(x,y+cl)},
                                {Vector2.new(x+w,y),Vector2.new(x+w-cl,y)},{Vector2.new(x+w,y),Vector2.new(x+w,y+cl)},
                                {Vector2.new(x,y+h),Vector2.new(x+cl,y+h)},{Vector2.new(x,y+h),Vector2.new(x,y+h-cl)},
                                {Vector2.new(x+w,y+h),Vector2.new(x+w-cl,y+h)},{Vector2.new(x+w,y+h),Vector2.new(x+w,y+h-cl)},
                            }
                            for i=1,8 do e.corners[i].Visible=true; e.corners[i].From=pts[i][1]; e.corners[i].To=pts[i][2]; e.corners[i].Color=col end
                        else
                            e.box.Visible=true; e.box.Size=Vector2.new(w,h); e.box.Position=Vector2.new(x,y); e.box.Color=col
                            for i=1,8 do e.corners[i].Visible=false end
                        end
                        if T.EspFilled then e.fill.Visible=true; e.fill.Size=Vector2.new(w,h); e.fill.Position=Vector2.new(x,y); e.fill.Color=col; e.fill.Transparency=O.EspBoxOpa else e.fill.Visible=false end
                    else e.box.Visible=false; e.fill.Visible=false; for i=1,8 do e.corners[i].Visible=false end end
                    -- name
                    if T.EspName then e.name.Visible=true; e.name.Text=p.Name; e.name.Size=O.EspFontSize or 14; e.name.Position=Vector2.new(s1.X,s1.Y-(O.EspFontSize or 14)-2); e.name.Color=col else e.name.Visible=false end
                    if T.EspTeamTag and p.Team then e.wep.Visible=true; e.wep.Text="["..p.Team.Name.."]"; e.wep.Position=Vector2.new(s1.X,s2.Y+16); e.wep.Color=col else e.wep.Visible=false end
                    -- health
                    if T.EspHealth and hum and hum.MaxHealth>0 then
                        local hp=math.clamp(hum.Health/hum.MaxHealth,0,1)
                        e.hpbg.Visible=true; e.hp.Visible=true
                        e.hpbg.Position=Vector2.new(x-6,y); e.hpbg.Size=Vector2.new(3,h); e.hpbg.Color=Color3.new(0,0,0)
                        e.hp.Position=Vector2.new(x-6,y+h*(1-hp)); e.hp.Size=Vector2.new(3,h*hp)
                        e.hp.Color=Color3.fromRGB(math.floor(255-hp*255),math.floor(hp*255),40)
                        if T.EspHealthText then e.hptxt.Visible=true; e.hptxt.Text=tostring(math.floor(hum.Health)); e.hptxt.Position=Vector2.new(x-14,y+h*(1-hp)-5); e.hptxt.Color=e.hp.Color else e.hptxt.Visible=false end
                    else e.hpbg.Visible=false; e.hp.Visible=false; e.hptxt.Visible=false end
                    -- dist
                    if T.EspDist then e.dist.Visible=true; e.dist.Text=string.format("%.0fs",(hrp.Position-Camera.CFrame.Position).Magnitude); e.dist.Position=Vector2.new(s1.X,s2.Y+2); e.dist.Color=col else e.dist.Visible=false end
                    -- tracer/snapline
                    if T.EspTracer or T.EspSnapline then
                        e.tracer.Visible=true; local vp=Camera.ViewportSize; local o=O.EspTracerO
                        local src = T.EspSnapline and UserInputService:GetMouseLocation()
                               or (o=="Bottom" and Vector2.new(vp.X/2,vp.Y))
                               or (o=="Top" and Vector2.new(vp.X/2,0))
                               or (o=="Center" and Vector2.new(vp.X/2,vp.Y/2))
                               or UserInputService:GetMouseLocation()
                        e.tracer.From=src; e.tracer.To=Vector2.new(s2.X,s2.Y); e.tracer.Color=col
                    else e.tracer.Visible=false end
                    -- head dot/circle
                    if T.EspHeadDot then local hs,hon=w2s(head.Position); if hon then e.headDot.Visible=true; e.headDot.Position=hs; e.headDot.Radius=3; e.headDot.Color=col else e.headDot.Visible=false end else e.headDot.Visible=false end
                    if T.EspHeadCircle then local hs,hon=w2s(head.Position); if hon then e.headCir.Visible=true; e.headCir.Position=hs; e.headCir.Radius=h*0.09; e.headCir.Color=col else e.headCir.Visible=false end else e.headCir.Visible=false end
                    -- skeleton
                    if T.EspSkeleton then
                        for i,pair in ipairs(SKEL_PAIRS) do
                            local a=char:FindFirstChild(pair[1]); local b=char:FindFirstChild(pair[2])
                            if a and b then local sa,oa=w2s(a.Position); local sb,ob=w2s(b.Position); if oa and ob then e.bones[i].Visible=true; e.bones[i].From=sa; e.bones[i].To=sb; e.bones[i].Color=col else e.bones[i].Visible=false end
                            else e.bones[i].Visible=false end
                        end
                    else for i=1,#SKEL_PAIRS do e.bones[i].Visible=false end end
                    -- offscreen arrow
                    if T.EspOffscreen then
                        local sc,onsc=w2s(hrp.Position)
                        if not onsc then
                            local vp=Camera.ViewportSize; local c=vp/2
                            local dir=(Vector2.new(sc.X,sc.Y)-c)
                            if dir.Magnitude<1 then dir=Vector2.new(1,0) end
                            dir=dir.Unit
                            local rad=O.EspArrowRad or 180
                            local tip=c+dir*rad
                            local perp=Vector2.new(-dir.Y,dir.X)*12
                            e.arrow.Visible=true
                            e.arrow.PointA=tip; e.arrow.PointB=tip-dir*20+perp; e.arrow.PointC=tip-dir*20-perp; e.arrow.Color=col
                        else e.arrow.Visible=false end
                    else e.arrow.Visible=false end
                else hide_all(e) end
            else
                e.box.Visible=false; e.fill.Visible=false; for i=1,8 do e.corners[i].Visible=false end
                e.name.Visible=false; e.wep.Visible=false; e.hpbg.Visible=false; e.hp.Visible=false; e.hptxt.Visible=false; e.dist.Visible=false; e.tracer.Visible=false; e.headDot.Visible=false; e.headCir.Visible=false; e.arrow.Visible=false
                for i=1,#SKEL_PAIRS do e.bones[i].Visible=false end
            end
            if showCham then safe(function() e.hl.Enabled=true; e.hl.Adornee=char; e.hl.FillColor=col; if T.ChamsVisCheck and los(Camera.CFrame.Position,head) then e.hl.FillColor=O.ChamsVisColor end; e.hl.FillTransparency=O.ChamsFill end)
            else safe(function() e.hl.Enabled=false; e.hl.Adornee=nil end) end
        end
    end end
end

-- HUD drawings
local fov=D(Drawing.new("Circle")); fov.Thickness=1; fov.NumSides=64
local lfov=D(Drawing.new("Circle")); lfov.Thickness=1; lfov.NumSides=64
local tbx=D(Drawing.new("Square")); tbx.Thickness=2
local hcb=D(Drawing.new("Square"))
local hcf=D(Drawing.new("Square")); hcf.Filled=true
local st_=D(Drawing.new("Text")); st_.Size=14; st_.Outline=true; st_.Font=3
local wm=D(Drawing.new("Text")); wm.Size=16; wm.Outline=true; wm.Font=3
local arr=D(Drawing.new("Triangle")); arr.Filled=true
local xh={v1=D(Drawing.new("Line")),v2=D(Drawing.new("Line")),h1=D(Drawing.new("Line")),h2=D(Drawing.new("Line")),dot=D(Drawing.new("Circle"))}

local function hud_tick()
    local m=UserInputService:GetMouseLocation()
    fov.Visible = T.VisFov and T.RageEnabled
    if fov.Visible then fov.Position=m; fov.Radius=O.RageFov; fov.Color=O.VisFovColor; fov.Filled=T.VisFovFilled; fov.Transparency = T.VisFovFilled and 0.2 or 1 end
    lfov.Visible = T.VisLegitFov and T.LegitOn
    if lfov.Visible then lfov.Position=m; lfov.Radius=O.LegitFov; lfov.Color=Color3.fromRGB(255,200,0) end
    if T.VisTargetBox and S.target and alive(S.target) then local hrp=S.target.Character.HumanoidRootPart; local s,on=w2s(hrp.Position); if on then tbx.Visible=true; tbx.Size=Vector2.new(90,140); tbx.Position=s-Vector2.new(45,70); tbx.Color = S.hitChance>70 and TH.gd or TH.wn else tbx.Visible=false end else tbx.Visible=false end
    hcb.Visible=T.VisHcBar; hcf.Visible=T.VisHcBar
    if T.VisHcBar then hcb.Position=Vector2.new(20,Camera.ViewportSize.Y-80); hcb.Size=Vector2.new(200,14); hcb.Color=Color3.new(1,1,1); hcf.Position=hcb.Position+Vector2.new(1,1); hcf.Size=Vector2.new((S.hitChance/100)*198,12); hcf.Color=Color3.fromRGB(math.floor(255-S.hitChance*2.55),math.floor(S.hitChance*2.55),40) end
    st_.Visible=T.VisStats
    if T.VisStats then st_.Position=Vector2.new(20,Camera.ViewportSize.Y-110); st_.Text=string.format("UE V6 | shots:%d hits:%d kills:%d hc:%.0f%%",S.stats.shots,S.stats.hits,S.stats.kills,S.hitChance); st_.Color=TH.ac end
    wm.Visible=T.VisWater
    if T.VisWater then wm.Position=Vector2.new(Camera.ViewportSize.X-310,10); wm.Text="UE V6 :: olivia :: discord.gg/ojailbreaks"; wm.Color=TH.ac end
    arr.Visible = T.AAXArrow and (T.AAEnabled or T.AAXOn)
    if arr.Visible then local c=Camera.ViewportSize/2; local y=S.desyncYaw or 0; arr.PointA=c+Vector2.new(math.sin(y),-math.cos(y))*50; arr.PointB=c+Vector2.new(math.sin(y+2.6),-math.cos(y+2.6))*15; arr.PointC=c+Vector2.new(math.sin(y-2.6),-math.cos(y-2.6))*15; arr.Color=TH.ac end
    local xe=T.XhOn
    for _,l in pairs(xh) do l.Visible=xe end
    if xe then local c=Camera.ViewportSize/2; local sz=O.XhSize; local gp=O.XhGap; local th=O.XhThick; local col=O.XhColor; xh.v1.From=c-Vector2.new(0,gp+sz); xh.v1.To=c-Vector2.new(0,gp); xh.v1.Color=col; xh.v1.Thickness=th; xh.v2.From=c+Vector2.new(0,gp); xh.v2.To=c+Vector2.new(0,gp+sz); xh.v2.Color=col; xh.v2.Thickness=th; xh.h1.From=c-Vector2.new(gp+sz,0); xh.h1.To=c-Vector2.new(gp,0); xh.h1.Color=col; xh.h1.Thickness=th; xh.h2.From=c+Vector2.new(gp,0); xh.h2.To=c+Vector2.new(gp+sz,0); xh.h2.Color=col; xh.h2.Thickness=th; xh.dot.Position=c; xh.dot.Radius=1; xh.dot.Color=col; xh.dot.Filled=true end
end

-- status
local function status_tick()
    statusL.Text = string.format("ac:%s  rage:%s  aa:%s  fpos:%s  esp:%s  chams:%s  fly:%s",
        T.AcSafe and "SAFE" or "raw",
        T.RageEnabled and "ON" or "off",
        (T.AAEnabled or T.AAXOn) and "ON" or "off",
        T.FPOn and "ON" or "off",
        T.EspOn and "ON" or "off",
        T.ChamsOn and "ON" or "off",
        T.Fly and "ON" or "off")
    statusR.Text = string.format("tgt:%s  hc:%.0f%%  shots:%d",
        S.target and S.target.Name or "—", S.hitChance, S.stats.shots)
end

-- scheduler — gated per feature
local tc=0
C(RunService.Heartbeat:Connect(function()
    tc+=1
    -- always run hud + status (cheap)
    safe(hud_tick); safe(status_tick)
    if T.AcSoftTick and tc%2~=0 then return end
    if T.AcSkipDeadTicks and not alive(LP) then return end
    if T.RageEnabled then for _,p in ipairs(Players:GetPlayers()) do if p~=LP then safe(bt_push,p) end end; safe(self_bt_push); safe(rage_tick) end
    if T.FPOn then safe(self_bt_push); safe(fakepos_tick) else if V6.Ghosts.g1 then killGhost("g1") killGhost("g2") end end
    if T.AAEnabled or T.AAXOn then safe(aa_tick) end
    if T.WsOn or T.JpOn or T.Bhop or T.Noclip or T.Fly or K.FlyKey.state then safe(move_tick) end
    if T.NoFog or T.FullBright or T.TimeLock or T.CamFovOn or T.ThirdP then safe(world_tick) else safe(function() Camera.FieldOfView=70 end) end
    safe(esp_tick)
end))

-- kills
C(Players.PlayerAdded:Connect(function(p) p.CharacterAdded:Connect(function(c) local h=c:WaitForChild("Humanoid",5); if not h then return end; h.Died:Connect(function() if S.target==p then S.stats.kills+=1; S.lastKillAt=os.clock(); resolver_hit(p); if T.KillSound then local s=Instance.new("Sound"); s.SoundId="rbxassetid://"..(O.KillSoundId or "131886985"); s.Volume=O.HitVol or 0.6; s.Parent=LP:FindFirstChild("PlayerGui") or LP; s:Play(); game:GetService("Debris"):AddItem(s,3) end end end) end) end))

pcall(function() C(LP.Idled:Connect(function() if T.AntiAfk then safe(function() VirtualInput:Button2Down(Vector2.new(),game); task.wait(1); VirtualInput:Button2Up(Vector2.new(),game) end) end end)) end)

C(UserInputService.InputBegan:Connect(function(i,gpe) if gpe then return end; if K.MenuKey and typeof(K.MenuKey.k)=="EnumItem" and i.KeyCode==K.MenuKey.k then Root.Visible=not Root.Visible end end))

LP.CharacterAdded:Connect(function() for _,e in pairs(V6.ESP) do hide_all(e) end end)

-- SEARCH filtering
searchBox:GetPropertyChangedSignal("Text"):Connect(function()
    local q = string.lower(searchBox.Text)
    for n,tb in pairs(tabBtns) do
        if q=="" then tb.btn.Visible=true
        else tb.btn.Visible = string.find(string.lower(n), q, 1, true) ~= nil end
    end
end)

------------------------------------------------------
-- UNLOAD
------------------------------------------------------
V6.Unload = function()
    for _,c in ipairs(V6.Conns) do pcall(function() c:Disconnect() end) end
    for _,d in ipairs(V6.Draws) do pcall(function() d:Remove() end) end
    for k,_ in pairs(V6.Ghosts) do pcall(function() V6.Ghosts[k]:Destroy() end) end
    for p,_ in pairs(V6.ESP) do esp_destroy(p) end
    if flyBV then pcall(function() flyBV:Destroy() end) end
    if flyBG then pcall(function() flyBG:Destroy() end) end
    pcall(function() Lighting.FogEnd=S.origFog; Lighting.Brightness=S.origBright; Camera.FieldOfView=70 end)
    pcall(function() Screen:Destroy() end)
    getgenv().UEV6 = nil
end
