--[==[
    UNNAMED ENHANCEMENTS V3
    built by olivia  //  discord.gg/ojailbreaks
--]==]

if getgenv().UE3 and getgenv().UE3.Unload then pcall(getgenv().UE3.Unload) end

local HttpService = game:GetService("HttpService")
local Players     = game:GetService("Players")
local RunService  = game:GetService("RunService")
local UIS         = game:GetService("UserInputService")
local Lighting    = game:GetService("Lighting")
local Workspace   = game:GetService("Workspace")
local CoreGui     = game:GetService("CoreGui")
local TweenService= game:GetService("TweenService")
local Camera      = Workspace.CurrentCamera
local LP          = Players.LocalPlayer

local U = {
    Opt={}, Tog={}, Key={}, Con={}, Draw={}, Esp={},
    Ghost={}, SelfPath={}, BT={}, Sum={shots=0,hits=0,kills=0,misses=0},
    Accent = Color3.fromRGB(180,120,255),
}
getgenv().UE3 = U
local O,T,K,Sum = U.Opt,U.Tog,U.Key,U.Sum
local function C(c) table.insert(U.Con,c); return c end
local function D(d) table.insert(U.Draw,d); return d end
local function pc(f,...) local ok,r=pcall(f,...); return ok and r end

----------------------------------------------------------------
-- palette — modern dark, one accent the user controls
----------------------------------------------------------------
local P = {
    bg  = Color3.fromRGB(16,16,20),
    pn  = Color3.fromRGB(22,22,28),
    pn2 = Color3.fromRGB(28,28,36),
    pn3 = Color3.fromRGB(36,36,46),
    el  = Color3.fromRGB(44,44,56),
    bd  = Color3.fromRGB(50,50,62),
    bdh = Color3.fromRGB(80,80,96),
    tx  = Color3.fromRGB(230,230,240),
    sub = Color3.fromRGB(165,165,180),
    dim = Color3.fromRGB(110,110,125),
    gn  = Color3.fromRGB(110,220,140),
    rd  = Color3.fromRGB(235,90,105),
    yw  = Color3.fromRGB(240,200,80),
    bl  = Color3.fromRGB(110,180,255),
}
local function ac() return U.Accent end

local F = { ui=Enum.Font.Gotham, uiB=Enum.Font.GothamBold, mono=Enum.Font.Code, px=Enum.Font.Arcade }

local function N(c,p) local i=Instance.new(c); for k,v in pairs(p or {}) do i[k]=v end; return i end
local function pd(p,l,r,t,b) N("UIPadding",{PaddingLeft=UDim.new(0,l),PaddingRight=UDim.new(0,r or l),PaddingTop=UDim.new(0,t or l),PaddingBottom=UDim.new(0,b or t or l),Parent=p}) end
local function cr(p,r) N("UICorner",{CornerRadius=UDim.new(0,r or 4),Parent=p}) end
local function sk(p,c,t) local s=N("UIStroke",{Color=c or P.bd,Thickness=t or 1,Parent=p,ApplyStrokeMode=Enum.ApplyStrokeMode.Border}); return s end
local function tween(i,p,t) pcall(function() TweenService:Create(i,TweenInfo.new(t or 0.15,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),p):Play() end) end

----------------------------------------------------------------
-- shell
----------------------------------------------------------------
local Screen = N("ScreenGui",{IgnoreGuiInset=true,ResetOnSpawn=false,ZIndexBehavior=Enum.ZIndexBehavior.Sibling,DisplayOrder=1e5,Name="_ue3_"..math.random(1e5,1e6)})
pcall(function() if syn and syn.protect_gui then syn.protect_gui(Screen) end; if gethui then Screen.Parent=gethui() else Screen.Parent=CoreGui end end)
if not Screen.Parent then Screen.Parent = LP:WaitForChild("PlayerGui") end
U.Screen = Screen

local Root = N("Frame",{Size=UDim2.fromOffset(920,600),Position=UDim2.new(0.5,-460,0.5,-300),BackgroundColor3=P.bg,BorderSizePixel=0,Parent=Screen,Active=true,ClipsDescendants=true})
cr(Root,6); sk(Root,P.bdh,1)

-- subtle gradient overlay for depth
local gradBG = N("Frame",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Parent=Root,ZIndex=0})
N("UIGradient",{Rotation=135,Color=ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.fromRGB(30,30,42)),ColorSequenceKeypoint.new(0.5,Color3.fromRGB(18,18,22)),ColorSequenceKeypoint.new(1,Color3.fromRGB(12,12,16))},Parent=N("Frame",{Size=UDim2.new(1,0,1,0),BackgroundColor3=Color3.fromRGB(28,28,36),BorderSizePixel=0,Parent=gradBG})})

-- title bar
local TB = N("Frame",{Size=UDim2.new(1,0,0,42),BackgroundColor3=P.pn,BorderSizePixel=0,Parent=Root})
cr(TB,6)
N("Frame",{Size=UDim2.new(1,0,0,8),Position=UDim2.new(0,0,1,-8),BackgroundColor3=P.pn,BorderSizePixel=0,Parent=TB})
local TBline = N("Frame",{Size=UDim2.new(1,0,0,2),Position=UDim2.new(0,0,1,-2),BackgroundColor3=ac(),BorderSizePixel=0,Parent=TB})
N("UIGradient",{Color=ColorSequence.new{ColorSequenceKeypoint.new(0,ac()),ColorSequenceKeypoint.new(1,Color3.fromRGB(255,80,200))},Parent=TBline})

-- logo diamond
local LogoBox = N("Frame",{Size=UDim2.fromOffset(28,28),Position=UDim2.fromOffset(12,7),BackgroundColor3=ac(),BorderSizePixel=0,Parent=TB,Rotation=45})
cr(LogoBox,4)
N("Frame",{Size=UDim2.fromOffset(10,10),Position=UDim2.fromOffset(9,9),BackgroundColor3=P.bg,BorderSizePixel=0,Parent=LogoBox,Rotation=0})

local TtlName = N("TextLabel",{Size=UDim2.fromOffset(300,16),Position=UDim2.fromOffset(52,6),BackgroundTransparency=1,Text="UNNAMED ENHANCEMENTS",Font=F.uiB,TextSize=14,TextColor3=P.tx,TextXAlignment=Enum.TextXAlignment.Left,Parent=TB})
local TtlVer  = N("TextLabel",{Size=UDim2.fromOffset(60,16),Position=UDim2.fromOffset(234,6),BackgroundTransparency=1,Text="V3",Font=F.uiB,TextSize=14,TextColor3=ac(),TextXAlignment=Enum.TextXAlignment.Left,Parent=TB})
local TtlSub  = N("TextLabel",{Size=UDim2.fromOffset(400,14),Position=UDim2.fromOffset(52,22),BackgroundTransparency=1,Text="built by olivia  //  discord.gg/ojailbreaks",Font=F.ui,TextSize=11,TextColor3=P.sub,TextXAlignment=Enum.TextXAlignment.Left,Parent=TB})

local closeX = N("TextButton",{Size=UDim2.fromOffset(28,22),Position=UDim2.new(1,-38,0,10),BackgroundColor3=P.pn2,BorderSizePixel=0,Text="×",Font=F.uiB,TextSize=18,TextColor3=P.rd,AutoButtonColor=false,Parent=TB}); cr(closeX,3); sk(closeX,P.bd,1)
closeX.MouseEnter:Connect(function() tween(closeX,{BackgroundColor3=P.rd}); closeX.TextColor3=Color3.new(1,1,1) end)
closeX.MouseLeave:Connect(function() tween(closeX,{BackgroundColor3=P.pn2}); closeX.TextColor3=P.rd end)
closeX.MouseButton1Click:Connect(function() if U.Unload then U.Unload() end end)

local minBtn = N("TextButton",{Size=UDim2.fromOffset(28,22),Position=UDim2.new(1,-70,0,10),BackgroundColor3=P.pn2,BorderSizePixel=0,Text="–",Font=F.uiB,TextSize=16,TextColor3=P.sub,AutoButtonColor=false,Parent=TB}); cr(minBtn,3); sk(minBtn,P.bd,1)
local minimized=false
minBtn.MouseButton1Click:Connect(function() minimized=not minimized; tween(Root,{Size = minimized and UDim2.fromOffset(920,42) or UDim2.fromOffset(920,600)}, 0.18) end)

-- drag
do local dr,sm,sp
    TB.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dr=true; sm=i.Position; sp=Root.Position end end)
    TB.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dr=false end end)
    C(UIS.InputChanged:Connect(function(i) if dr and i.UserInputType==Enum.UserInputType.MouseMovement then local d=i.Position-sm; Root.Position=UDim2.new(sp.X.Scale,sp.X.Offset+d.X,sp.Y.Scale,sp.Y.Offset+d.Y) end end))
end

----------------------------------------------------------------
-- left tab rail (icons + labels)
----------------------------------------------------------------
local Rail = N("Frame",{Size=UDim2.new(0,170,1,-82),Position=UDim2.fromOffset(10,52),BackgroundColor3=P.pn,BorderSizePixel=0,Parent=Root}); cr(Rail,5); sk(Rail,P.bd,1); pd(Rail,8,8,10,10)
N("UIListLayout",{Padding=UDim.new(0,4),Parent=Rail})

-- rail header
local RH = N("Frame",{Size=UDim2.new(1,0,0,22),BackgroundTransparency=1,Parent=Rail,LayoutOrder=0})
N("TextLabel",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="NAVIGATION",Font=F.uiB,TextSize=10,TextColor3=P.dim,TextXAlignment=Enum.TextXAlignment.Left,Parent=RH})

local Content = N("Frame",{Size=UDim2.new(1,-196,1,-82),Position=UDim2.fromOffset(186,52),BackgroundColor3=P.pn,BorderSizePixel=0,Parent=Root}); cr(Content,5); sk(Content,P.bd,1); pd(Content,10,10,10,10)

-- bottom status strip
local SB = N("Frame",{Size=UDim2.new(1,-20,0,18),Position=UDim2.new(0,10,1,-24),BackgroundColor3=P.pn,BorderSizePixel=0,Parent=Root}); cr(SB,3); sk(SB,P.bd,1); pd(SB,10,10,2,2)
local sTL = N("TextLabel",{Size=UDim2.new(0.65,0,1,0),BackgroundTransparency=1,Text="",Font=F.mono,TextSize=11,TextColor3=P.gn,TextXAlignment=Enum.TextXAlignment.Left,Parent=SB})
local sTR = N("TextLabel",{Size=UDim2.new(0.35,0,1,0),Position=UDim2.new(0.65,0,0,0),BackgroundTransparency=1,Text="",Font=F.mono,TextSize=11,TextColor3=ac(),TextXAlignment=Enum.TextXAlignment.Right,Parent=SB})

----------------------------------------------------------------
-- tabs
----------------------------------------------------------------
local pages, tabs, current = {}, {}, nil
local function selectTab(name)
    current=name
    for n,v in pairs(tabs) do
        local active = n==name
        tween(v.btn,{BackgroundColor3 = active and P.pn3 or P.pn})
        v.lbl.TextColor3 = active and P.tx or P.sub
        v.ico.TextColor3 = active and ac() or P.dim
        v.ind.Visible = active
        pages[n].Visible = active
    end
end
local function Tab(name, icon)
    local b = N("TextButton",{Size=UDim2.new(1,0,0,30),BackgroundColor3=P.pn,BorderSizePixel=0,Text="",AutoButtonColor=false,Parent=Rail}); cr(b,4)
    local ind = N("Frame",{Size=UDim2.new(0,3,1,-10),Position=UDim2.new(0,0,0,5),BackgroundColor3=ac(),BorderSizePixel=0,Visible=false,Parent=b}); cr(ind,2)
    local ico = N("TextLabel",{Size=UDim2.fromOffset(22,30),Position=UDim2.fromOffset(8,0),BackgroundTransparency=1,Text=icon or "•",Font=F.uiB,TextSize=14,TextColor3=P.dim,Parent=b})
    local lbl = N("TextLabel",{Size=UDim2.new(1,-32,1,0),Position=UDim2.fromOffset(32,0),BackgroundTransparency=1,Text=name,Font=F.ui,TextSize=12,TextColor3=P.sub,TextXAlignment=Enum.TextXAlignment.Left,Parent=b})
    local p = N("ScrollingFrame",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,ScrollBarThickness=3,ScrollBarImageColor3=ac(),CanvasSize=UDim2.new(0,0,0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y,BorderSizePixel=0,Visible=false,Parent=Content})
    N("UIListLayout",{FillDirection=Enum.FillDirection.Horizontal,Wraps=true,Padding=UDim.new(0,8),Parent=p})
    pages[name]=p; tabs[name]={btn=b,lbl=lbl,ico=ico,ind=ind}
    b.MouseButton1Click:Connect(function() selectTab(name) end)
    b.MouseEnter:Connect(function() if current~=name then tween(b,{BackgroundColor3=P.pn2}) end end)
    b.MouseLeave:Connect(function() if current~=name then tween(b,{BackgroundColor3=P.pn}) end end)
    return p
end

local function Panel(parent, title, subtitle, wide)
    local sz = wide and UDim2.new(1,0,0,0) or UDim2.new(0.5,-4,0,0)
    local w = N("Frame",{Size=sz,BackgroundColor3=P.pn2,BorderSizePixel=0,AutomaticSize=Enum.AutomaticSize.Y,Parent=parent}); cr(w,5); sk(w,P.bd,1); pd(w,12,12,10,12)
    local head = N("Frame",{Size=UDim2.new(1,0,0,26),BackgroundTransparency=1,Parent=w})
    local tri = N("Frame",{Size=UDim2.fromOffset(4,14),Position=UDim2.fromOffset(0,4),BackgroundColor3=ac(),BorderSizePixel=0,Parent=head}); cr(tri,2)
    N("TextLabel",{Size=UDim2.new(1,-12,0,14),Position=UDim2.fromOffset(12,0),BackgroundTransparency=1,Text=string.upper(title),Font=F.uiB,TextSize=12,TextColor3=P.tx,TextXAlignment=Enum.TextXAlignment.Left,Parent=head})
    if subtitle then N("TextLabel",{Size=UDim2.new(1,-12,0,10),Position=UDim2.fromOffset(12,14),BackgroundTransparency=1,Text=subtitle,Font=F.ui,TextSize=10,TextColor3=P.dim,TextXAlignment=Enum.TextXAlignment.Left,Parent=head}) end
    local col = N("Frame",{Size=UDim2.new(1,0,0,0),Position=UDim2.new(0,0,0,30),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1,Parent=w})
    N("UIListLayout",{Padding=UDim.new(0,6),Parent=col})
    return col
end

----------------------------------------------------------------
-- widgets
----------------------------------------------------------------
local function Toggle(p,k,t,d,desc)
    T[k]=d and true or false
    local r = N("TextButton",{Size=UDim2.new(1,0,0, desc and 32 or 22),BackgroundTransparency=1,Text="",AutoButtonColor=false,Parent=p})
    local sw = N("Frame",{Size=UDim2.fromOffset(28,14),Position=UDim2.new(1,-28,0,4),BackgroundColor3=T[k] and ac() or P.el,BorderSizePixel=0,Parent=r}); cr(sw,7); sk(sw,P.bd,1)
    local kn = N("Frame",{Size=UDim2.fromOffset(10,10),Position=UDim2.fromOffset(T[k] and 16 or 2,2),BackgroundColor3=Color3.new(1,1,1),BorderSizePixel=0,Parent=sw}); cr(kn,5)
    N("TextLabel",{Size=UDim2.new(1,-36,0,14),Position=UDim2.fromOffset(0,2),BackgroundTransparency=1,Text=t,Font=F.ui,TextSize=12,TextColor3=P.tx,TextXAlignment=Enum.TextXAlignment.Left,Parent=r})
    if desc then N("TextLabel",{Size=UDim2.new(1,-36,0,12),Position=UDim2.fromOffset(0,18),BackgroundTransparency=1,Text=desc,Font=F.ui,TextSize=10,TextColor3=P.dim,TextXAlignment=Enum.TextXAlignment.Left,Parent=r}) end
    r.MouseButton1Click:Connect(function()
        T[k]=not T[k]
        tween(sw,{BackgroundColor3 = T[k] and ac() or P.el})
        tween(kn,{Position = T[k] and UDim2.fromOffset(16,2) or UDim2.fromOffset(2,2)})
    end)
end

local function Slider(p,k,t,d,mn,mx,st,sx)
    O[k]=d
    local r = N("Frame",{Size=UDim2.new(1,0,0,38),BackgroundTransparency=1,Parent=p})
    N("TextLabel",{Size=UDim2.new(1,-70,0,14),BackgroundTransparency=1,Text=t,Font=F.ui,TextSize=12,TextColor3=P.tx,TextXAlignment=Enum.TextXAlignment.Left,Parent=r})
    local vl = N("TextLabel",{Size=UDim2.fromOffset(70,14),Position=UDim2.new(1,-70,0,0),BackgroundTransparency=1,Text=tostring(d)..(sx or ""),Font=F.mono,TextSize=11,TextColor3=ac(),TextXAlignment=Enum.TextXAlignment.Right,Parent=r})
    local bar = N("TextButton",{Size=UDim2.new(1,0,0,6),Position=UDim2.new(0,0,0,22),BackgroundColor3=P.el,BorderSizePixel=0,Text="",AutoButtonColor=false,Parent=r}); cr(bar,3)
    local fill = N("Frame",{Size=UDim2.new((d-mn)/(mx-mn),0,1,0),BackgroundColor3=ac(),BorderSizePixel=0,Parent=bar}); cr(fill,3)
    local knob = N("Frame",{Size=UDim2.fromOffset(10,10),Position=UDim2.new((d-mn)/(mx-mn),-5,0.5,-5),BackgroundColor3=Color3.new(1,1,1),BorderSizePixel=0,Parent=bar}); cr(knob,5)
    local dr=false
    local function set(x)
        local rel=math.clamp((x-bar.AbsolutePosition.X)/bar.AbsoluteSize.X,0,1)
        local v=mn+(mx-mn)*rel; if st then v=math.floor(v/st+0.5)*st end; v=math.clamp(v,mn,mx)
        O[k]=v; fill.Size=UDim2.new(rel,0,1,0); knob.Position=UDim2.new(rel,-5,0.5,-5)
        vl.Text=((st and st>=1) and tostring(math.floor(v)) or string.format("%.2f",v))..(sx or "")
    end
    bar.MouseButton1Down:Connect(function() dr=true; set(UIS:GetMouseLocation().X) end)
    C(UIS.InputChanged:Connect(function(i) if dr and i.UserInputType==Enum.UserInputType.MouseMovement then set(i.Position.X) end end))
    C(UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dr=false end end))
end

local function Dropdown(p,k,t,vs,d)
    O[k]=d
    local r = N("Frame",{Size=UDim2.new(1,0,0,38),BackgroundTransparency=1,Parent=p})
    N("TextLabel",{Size=UDim2.new(1,0,0,14),BackgroundTransparency=1,Text=t,Font=F.ui,TextSize=12,TextColor3=P.tx,TextXAlignment=Enum.TextXAlignment.Left,Parent=r})
    local b = N("TextButton",{Size=UDim2.new(1,0,0,20),Position=UDim2.new(0,0,0,16),BackgroundColor3=P.el,BorderSizePixel=0,Text="  "..d,Font=F.ui,TextSize=12,TextColor3=P.tx,TextXAlignment=Enum.TextXAlignment.Left,AutoButtonColor=false,Parent=r}); cr(b,3); sk(b,P.bd,1)
    N("TextLabel",{Size=UDim2.fromOffset(16,20),Position=UDim2.new(1,-18,0,0),BackgroundTransparency=1,Text="▾",Font=F.uiB,TextSize=11,TextColor3=ac(),Parent=b})
    local list = N("Frame",{Size=UDim2.new(1,0,0,0),Position=UDim2.new(0,0,1,2),BackgroundColor3=P.pn3,BorderSizePixel=0,Visible=false,ZIndex=50,AutomaticSize=Enum.AutomaticSize.Y,Parent=b}); cr(list,4); sk(list,P.bd,1)
    N("UIListLayout",{Parent=list})
    for _,v in ipairs(vs) do
        local it = N("TextButton",{Size=UDim2.new(1,0,0,20),BackgroundColor3=P.pn3,BorderSizePixel=0,Text="  "..v,Font=F.ui,TextSize=11,TextColor3=P.tx,TextXAlignment=Enum.TextXAlignment.Left,AutoButtonColor=false,ZIndex=51,Parent=list})
        it.MouseEnter:Connect(function() it.BackgroundColor3=ac(); it.TextColor3=Color3.new(1,1,1) end)
        it.MouseLeave:Connect(function() it.BackgroundColor3=P.pn3; it.TextColor3=P.tx end)
        it.MouseButton1Click:Connect(function() O[k]=v; b.Text="  "..v; list.Visible=false end)
    end
    b.MouseButton1Click:Connect(function() list.Visible=not list.Visible end)
end

local function MultiToggle(p,k,t,vs,def)
    O[k]={}; for _,v in ipairs(def or {}) do O[k][v]=true end
    local r = N("Frame",{Size=UDim2.new(1,0,0,38),BackgroundTransparency=1,Parent=p})
    N("TextLabel",{Size=UDim2.new(1,0,0,14),BackgroundTransparency=1,Text=t,Font=F.ui,TextSize=12,TextColor3=P.tx,TextXAlignment=Enum.TextXAlignment.Left,Parent=r})
    local b = N("TextButton",{Size=UDim2.new(1,0,0,20),Position=UDim2.new(0,0,0,16),BackgroundColor3=P.el,BorderSizePixel=0,Text="  "..(def and table.concat(def,", ") or "none"),Font=F.ui,TextSize=12,TextColor3=P.tx,TextXAlignment=Enum.TextXAlignment.Left,AutoButtonColor=false,Parent=r}); cr(b,3); sk(b,P.bd,1)
    local list = N("Frame",{Size=UDim2.new(1,0,0,0),Position=UDim2.new(0,0,1,2),BackgroundColor3=P.pn3,BorderSizePixel=0,Visible=false,ZIndex=50,AutomaticSize=Enum.AutomaticSize.Y,Parent=b}); cr(list,4); sk(list,P.bd,1)
    N("UIListLayout",{Parent=list})
    local function refresh() local sel={}; for _,v in ipairs(vs) do if O[k][v] then table.insert(sel,v) end end; b.Text="  "..(#sel>0 and table.concat(sel,", ") or "none") end
    for _,v in ipairs(vs) do
        local it = N("TextButton",{Size=UDim2.new(1,0,0,20),BackgroundColor3=P.pn3,BorderSizePixel=0,Text=(O[k][v] and "☑ " or "☐ ")..v,Font=F.ui,TextSize=11,TextColor3=P.tx,TextXAlignment=Enum.TextXAlignment.Left,AutoButtonColor=false,ZIndex=51,Parent=list})
        it.MouseButton1Click:Connect(function() O[k][v]=not O[k][v]; it.Text=(O[k][v] and "☑ " or "☐ ")..v; refresh() end)
    end
    b.MouseButton1Click:Connect(function() list.Visible=not list.Visible end)
end

local function Keybind(p,k,t,dk)
    K[k]={k=dk,mode="Hold",state=false,tog=false}
    local r = N("Frame",{Size=UDim2.new(1,0,0,22),BackgroundTransparency=1,Parent=p})
    N("TextLabel",{Size=UDim2.new(1,-130,1,0),BackgroundTransparency=1,Text=t,Font=F.ui,TextSize=12,TextColor3=P.tx,TextXAlignment=Enum.TextXAlignment.Left,Parent=r})
    local function nm(x) return (typeof(x)=="EnumItem") and x.Name or tostring(x) end
    local kb = N("TextButton",{Size=UDim2.fromOffset(64,18),Position=UDim2.new(1,-130,0,2),BackgroundColor3=P.el,BorderSizePixel=0,Text=nm(dk),Font=F.mono,TextSize=11,TextColor3=ac(),AutoButtonColor=false,Parent=r}); cr(kb,3); sk(kb,P.bd,1)
    local mb = N("TextButton",{Size=UDim2.fromOffset(58,18),Position=UDim2.new(1,-62,0,2),BackgroundColor3=P.el,BorderSizePixel=0,Text="HOLD",Font=F.uiB,TextSize=10,TextColor3=P.gn,AutoButtonColor=false,Parent=r}); cr(mb,3); sk(mb,P.bd,1)
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
    mb.MouseButton1Click:Connect(function() local nx={Hold="Toggle",Toggle="Always",Always="Hold"}; K[k].mode=nx[K[k].mode]; mb.Text=K[k].mode; K[k].state=(K[k].mode=="Always") end)
end

local function Button(p,t,cb,style)
    local col = style=="danger" and P.rd or ac()
    local b = N("TextButton",{Size=UDim2.new(1,0,0,22),BackgroundColor3=col,BorderSizePixel=0,Text=t,Font=F.uiB,TextSize=11,TextColor3=Color3.new(1,1,1),AutoButtonColor=false,Parent=p}); cr(b,3)
    b.MouseEnter:Connect(function() b.BackgroundTransparency=0.15 end)
    b.MouseLeave:Connect(function() b.BackgroundTransparency=0 end)
    b.MouseButton1Click:Connect(cb)
end

local function ColorPicker(p,k,t,d)
    O[k]=d
    local r = N("Frame",{Size=UDim2.new(1,0,0,22),BackgroundTransparency=1,Parent=p})
    N("TextLabel",{Size=UDim2.new(1,-34,1,0),BackgroundTransparency=1,Text=t,Font=F.ui,TextSize=12,TextColor3=P.tx,TextXAlignment=Enum.TextXAlignment.Left,Parent=r})
    local sw = N("TextButton",{Size=UDim2.fromOffset(28,16),Position=UDim2.new(1,-28,0,3),BackgroundColor3=d,BorderSizePixel=0,Text="",AutoButtonColor=false,Parent=r}); cr(sw,3); sk(sw,P.bd,1)
    local presets={d,Color3.fromRGB(255,80,180),Color3.fromRGB(180,100,255),Color3.fromRGB(100,230,120),Color3.fromRGB(0,200,255),Color3.fromRGB(255,80,110),Color3.fromRGB(255,220,80),Color3.fromRGB(255,255,255),Color3.fromRGB(255,120,0),Color3.fromRGB(40,40,50)}
    local idx=1
    sw.MouseButton1Click:Connect(function() idx=idx%#presets+1; O[k]=presets[idx]; sw.BackgroundColor3=presets[idx] end)
end

local function Label(p,t,c) return N("TextLabel",{Size=UDim2.new(1,0,0,14),BackgroundTransparency=1,Text=t,Font=F.ui,TextSize=11,TextColor3=c or P.sub,TextXAlignment=Enum.TextXAlignment.Left,Parent=p}) end
local function Divider(p) local d=N("Frame",{Size=UDim2.new(1,0,0,1),BackgroundColor3=P.bd,BorderSizePixel=0,Parent=p}); return d end

----------------------------------------------------------------
-- ACCENT cycler — repaints the UI live
----------------------------------------------------------------
local ACCENTS = {
    {name="violet",c=Color3.fromRGB(180,120,255)},
    {name="pink",c=Color3.fromRGB(255,90,180)},
    {name="red",c=Color3.fromRGB(230,80,100)},
    {name="orange",c=Color3.fromRGB(255,140,60)},
    {name="amber",c=Color3.fromRGB(255,190,60)},
    {name="green",c=Color3.fromRGB(120,220,120)},
    {name="cyan",c=Color3.fromRGB(80,210,255)},
    {name="blue",c=Color3.fromRGB(110,160,255)},
    {name="white",c=Color3.fromRGB(230,230,240)},
}
local accentIdx=1
local accentTargets = {}
local function tagAccent(inst, kind) table.insert(accentTargets,{inst=inst,kind=kind or "bg"}) end
tagAccent(LogoBox,"bg"); tagAccent(TtlVer,"txt"); tagAccent(TBline,"bg")

local function setAccent(c)
    U.Accent = c
    for _,t in ipairs(accentTargets) do
        if t.inst and t.inst.Parent then
            if t.kind=="bg" then t.inst.BackgroundColor3 = c else t.inst.TextColor3 = c end
        end
    end
    sTR.TextColor3 = c
end

----------------------------------------------------------------
-- TAB BUILDS — eagerly, so every feature is wired at load
----------------------------------------------------------------
do local p=Tab("Home","◆")
    local g=Panel(p,"welcome","unnamed enhancements v3 — load complete",true)
    Label(g,"menu toggle: RightShift  —  closable via × in the header",P.tx)
    Label(g,"all engines are feature-gated by their master toggle",P.tx)
    Label(g,"configs save to your executor workspace (writefile required)",P.tx)
    Divider(g)
    Label(g,"VERSION LOCK: always v3. every release updates v3 in place.",ac())
    Label(g,"credit: built by olivia  //  discord.gg/ojailbreaks",P.gn)
end

do local p=Tab("Rage","◉")
    local g=Panel(p,"core","silent aim + target picker")
    Toggle(g,"RageOn","enable rage",false)
    Toggle(g,"Silent","silent aim",true,"hooks mouse + raycasts — invisible to the game")
    Toggle(g,"AutoFire","auto fire",false)
    Toggle(g,"AutoScope","auto scope",true)
    Toggle(g,"AutoStop","auto stop on shot",false)
    Toggle(g,"AutoCrouch","auto crouch on shot",false)
    Slider(g,"Fov","fov",120,10,500,5,"px")
    Slider(g,"MaxDist","max distance",2000,50,5000,10,"s")
    Slider(g,"FireRate","shots / sec",10,1,40,1)
    Dropdown(g,"KeyMode","key mode",{"Always","Hold","Toggle"},"Hold")
    Keybind(g,"RageKey","aim key","MB2")

    local g2=Panel(p,"target","selection logic")
    Dropdown(g2,"Prio","priority",{"FOV","Distance","Health","Crosshair","LowestHP","Random"},"FOV")
    Toggle(g2,"VisOnly","visible only",false)
    Toggle(g2,"IgnTeam","ignore team",true)
    Toggle(g2,"IgnFriend","ignore friends",true)
    Toggle(g2,"LockTgt","lock target until dead",false)
    Slider(g2,"SwitchDly","switch delay",0.05,0,1,0.01,"s")
    Slider(g2,"KillDly","kill delay",0,0,1,0.01,"s")

    local g3=Panel(p,"hitbox","per-part weighting")
    Dropdown(g3,"HB","hitbox",{"Head","UpperTorso","Torso","HumanoidRootPart","MultiScan","Nearest"},"Head")
    Slider(g3,"WtHead","weight head",10,0,10,1)
    Slider(g3,"WtChest","weight chest",6,0,10,1)
    Slider(g3,"WtPelvis","weight pelvis",4,0,10,1)
    Slider(g3,"WtLimbs","weight limbs",2,0,10,1)
    Toggle(g3,"ForceHS","force headshot",false)
    Toggle(g3,"ForceBaim","force body aim",false)

    local g4=Panel(p,"prediction","velocity + backtrack")
    Toggle(g4,"PredOn","velocity prediction",true)
    Slider(g4,"PredF","predict factor",0.14,0,0.5,0.01,"s")
    Toggle(g4,"HcGate","hitchance gate",true)
    Slider(g4,"HcMin","min hitchance",70,0,100,1,"%")
    Slider(g4,"HcSmp","hitchance samples",10,4,32,1)
    Toggle(g4,"BTOn","backtrack",true)
    Slider(g4,"BTMs","backtrack max",200,0,1000,10,"ms")
    Toggle(g4,"Safepoint","safepoint",true)
    Slider(g4,"SPBias","safepoint bias",0.5,0,1,0.05)
end

do local p=Tab("Anti-Aim","◁")
    local g=Panel(p,"master","yaw base + modifier")
    Toggle(g,"AAOn","enable anti-aim",false)
    Dropdown(g,"AABase","base",{"Backwards","Target","AtTarget","Freestand","Local","Jitter","Spin","Zero"},"AtTarget")
    Dropdown(g,"AAYaw","yaw modifier",{"None","Spin","Jitter","Random","Sway","3way","Offset"},"Jitter")
    Slider(g,"AAYawDeg","yaw deg",90,0,180,1,"°")
    Slider(g,"AAYawHz","yaw speed",8,0.1,30,0.1,"hz")
    Slider(g,"AADesync","desync",58,0,60,1,"°")
    Keybind(g,"AAInvert","invert desync",Enum.KeyCode.X)

    local g2=Panel(p,"per-state","different yaw per movement state")
    Dropdown(g2,"AASt","standing",{"Inherit","Backwards","Jitter","Spin","Sideways","Zero"},"Inherit")
    Dropdown(g2,"AAMv","moving",{"Inherit","Backwards","Jitter","Spin","Sideways","Zero"},"Inherit")
    Dropdown(g2,"AAAir","in air",{"Inherit","Backwards","Jitter","Spin","Sideways","Zero"},"Zero")
    Dropdown(g2,"AACr","crouching",{"Inherit","Backwards","Jitter","Spin","Sideways","Zero"},"Inherit")

    local g3=Panel(p,"pitch / roll","vertical + rotation")
    Toggle(g3,"AAPOn","pitch",true)
    Dropdown(g3,"AAPitch","pitch",{"Down","Up","Zero","Jitter","Fake","Random"},"Down")
    Slider(g3,"AAPDeg","pitch deg",89,0,89,1,"°")
    Dropdown(g3,"AARoll","roll",{"None","Left","Right","Alternate","Sway"},"None")
    Slider(g3,"AARDeg","roll deg",30,0,180,1,"°")

    local g4=Panel(p,"advanced","defensive + lby + on-shot")
    Toggle(g4,"LBY","LBY breaker",true)
    Toggle(g4,"BodyYaw","body yaw",true)
    Slider(g4,"BodyDeg","body yaw deg",90,0,180,1,"°")
    Toggle(g4,"Micro","micro jitter",true)
    Slider(g4,"MicroDeg","micro deg",3,0,15,1,"°")
    Toggle(g4,"OnShot","on-shot flip",true)
    Slider(g4,"OnShotMs","on-shot ms",220,50,1000,10,"ms")
    Toggle(g4,"Defensive","defensive AA",true)
    Toggle(g4,"AAArrow","arrow hud",true)

    local g5=Panel(p,"manual","4-way manual override")
    Toggle(g5,"ManOn","enable manual",false)
    Keybind(g5,"ManL","manual left",Enum.KeyCode.Left)
    Keybind(g5,"ManR","manual right",Enum.KeyCode.Right)
    Keybind(g5,"ManB","manual back",Enum.KeyCode.Down)
    Keybind(g5,"ManF","manual forward",Enum.KeyCode.Up)
end

do local p=Tab("Fake Pos","◇")
    local g=Panel(p,"underground","rivals pattern: sinks you below the map, camera stays at surface",true)
    Toggle(g,"FPOn","fake position",false)
    Slider(g,"FPDepth","depth",25,5,200,1,"s")
    Toggle(g,"FPNoclip","auto-noclip",true)
    Toggle(g,"FPShootHandoff","on-shoot handoff",true)
    Slider(g,"FPShootMs","handoff window",80,20,500,5,"ms")
    Keybind(g,"FPKey","toggle key",Enum.KeyCode.V)
    Dropdown(g,"FPKeyMode","key mode",{"Toggle","Hold","Always"},"Toggle")
    local g2=Panel(p,"blink","peek-style displacement")
    Toggle(g2,"FPBlink","blink enable",false)
    Keybind(g2,"FPBlinkK","blink key",Enum.KeyCode.G)
    Slider(g2,"FPBlinkD","blink dist",8,2,40,1,"s")
end

do local p=Tab("Voidspam","◈")
    local g=Panel(p,"voidspam","rivals: replicate HRP under the map so enemy hit-resolution misses",true)
    Toggle(g,"VoidOn","enable voidspam",false)
    Dropdown(g,"VoidMode","anchor",{"BelowTarget","BelowNearest","BelowMap"},"BelowTarget")
    Slider(g,"VoidDepthMin","depth min",10,1,100,1,"s")
    Slider(g,"VoidDepthMax","depth max",40,1,200,1,"s")
    Toggle(g,"VoidNoclip","auto-noclip underground",true)
    Toggle(g,"VoidShootHandoff","on-shoot handoff",true)
    Slider(g,"VoidShootMs","handoff window",50,20,300,5,"ms")
    Slider(g,"VoidMapY","BelowMap Y",-300,-1000,0,10,"s")
    Keybind(g,"VoidKey","voidspam key",Enum.KeyCode.Z)
    Dropdown(g,"VoidKeyMode","key mode",{"Hold","Toggle","Always"},"Hold")
end

do local p=Tab("ESP","✦")
    local g=Panel(p,"visible","drawings — box, name, hp")
    Toggle(g,"EspOn","esp master",false)
    Toggle(g,"EspBox","box",true)
    Dropdown(g,"EspBoxS","box style",{"full","corner","rounded","outlined"},"corner")
    Toggle(g,"EspBoxFill","filled box",false)
    Slider(g,"EspBoxFillA","fill alpha",0.2,0,1,0.05)
    Toggle(g,"EspName","name",true)
    Toggle(g,"EspDist","distance",true)
    Toggle(g,"EspHealth","health bar",true)
    Toggle(g,"EspHealthT","health text",false)
    Toggle(g,"EspTeam","show team",false)
    Toggle(g,"EspTeamColor","use team color",false)
    Toggle(g,"EspTool","equipped tool",false)
    Toggle(g,"EspTracer","tracer",false)
    Dropdown(g,"EspTracerO","tracer origin",{"bottom","top","mouse","center"},"bottom")
    Toggle(g,"EspSkel","skeleton",false)
    Toggle(g,"EspHeadDot","head dot",false)
    Toggle(g,"EspHeadCir","head circle",false)
    Toggle(g,"EspSnap","snapline from mouse",false)
    Toggle(g,"EspOff","offscreen arrow",true)
    Toggle(g,"EspRainbow","rainbow color",false)
    Slider(g,"EspFont","font size",13,8,22,1)
    ColorPicker(g,"EspEnemyCol","enemy color",Color3.fromRGB(255,80,120))
    ColorPicker(g,"EspFriendCol","friend color",Color3.fromRGB(110,180,255))

    local g2=Panel(p,"chams","3d highlight through walls")
    Toggle(g2,"ChamsOn","chams master",false)
    Dropdown(g2,"ChamsMat","material",{"ForceField","Neon","Plastic","Glass","Metal","SmoothPlastic"},"ForceField")
    Slider(g2,"ChamsFill","fill transparency",0.4,0,1,0.05)
    ColorPicker(g2,"ChamsCol","enemy fill",Color3.fromRGB(255,80,120))
    ColorPicker(g2,"ChamsOutCol","outline color",Color3.fromRGB(255,255,255))
    Toggle(g2,"ChamsVis","visible color swap",true)
    ColorPicker(g2,"ChamsVisCol","visible fill",Color3.fromRGB(110,220,140))
end

do local p=Tab("Visuals","✺")
    local g=Panel(p,"hud","on-screen info")
    Toggle(g,"WaterMark","watermark",true)
    Toggle(g,"StatusHUD","status hud",true)
    Toggle(g,"KeybindList","keybinds list",true)
    Toggle(g,"FovRing","fov ring",true)
    Toggle(g,"AimDot","aim-at dot",false)
    Toggle(g,"TargetBox","target box",true)
    local g2=Panel(p,"crosshair","custom aimpoint")
    Toggle(g2,"XhOn","crosshair",false)
    Dropdown(g2,"XhStyle","style",{"plus","dot","t","x","cross+dot","lines"},"plus")
    Slider(g2,"XhSize","size",10,2,40,1)
    Slider(g2,"XhGap","gap",3,0,20,1)
    Slider(g2,"XhThick","thickness",1,1,5,1)
    ColorPicker(g2,"XhColor","color",Color3.fromRGB(180,120,255))
end

do local p=Tab("Movement","↑")
    local g=Panel(p,"speed / jump","humanoid writes")
    Toggle(g,"WsOn","walkspeed",false)
    Slider(g,"Ws","value",50,16,500,1)
    Toggle(g,"JpOn","jumppower",false)
    Slider(g,"Jp","value",80,50,1000,1)
    Toggle(g,"Bhop","bunnyhop",false)
    Toggle(g,"InfJump","infinite jump",false)
    Toggle(g,"Noclip","noclip",false)
    local g2=Panel(p,"fly","body velocity")
    Toggle(g2,"Fly","fly",false)
    Slider(g2,"FlySpd","fly speed",50,5,300,1)
    Keybind(g2,"FlyKey","fly toggle",Enum.KeyCode.F)
end

do local p=Tab("World","✦")
    local g=Panel(p,"environment","lighting + particles")
    Toggle(g,"NoFog","no fog",false)
    Toggle(g,"FB","fullbright",false)
    Slider(g,"FBV","brightness",2,0,10,0.1)
    Toggle(g,"TimeLock","lock time (noon)",false)
    Toggle(g,"RemParticles","remove particles",false)
    local g2=Panel(p,"camera","fov + 3rd person")
    Toggle(g2,"CFov","camera fov",false)
    Slider(g2,"CFovV","fov value",70,1,120,1)
    Toggle(g2,"TP","third person",false)
    Slider(g2,"TPDist","3p distance",12,2,40,1)
end

do local p=Tab("Translocate","⇝")
    local g=Panel(p,"warpstone solver","ride the game warp, don't raw-jump",true)
    Toggle(g,"TLOn","enable translocate",false)
    Dropdown(g,"TLMode","mode",{"OnTarget","BehindTarget","Vertical","ReturnAnchor","OnLowHP","OnReload"},"BehindTarget")
    Slider(g,"TLLead","behind-lead",3,0,8,0.5,"s")
    Slider(g,"TLMaxDist","max warp dist",180,10,500,5,"s")
    Toggle(g,"TLPrefire","pre-fire during flight",true)
    Toggle(g,"TLYawSnap","snap camera yaw on arrive",true)
    Keybind(g,"TLKey","warp key",Enum.KeyCode.R)
    Slider(g,"TLLowHP","low-hp threshold",25,1,100,1,"hp")
    Label(g,"note: needs recon of Rivals Warpstone remote names — observe mode logs on enable",P.sub)
    Toggle(g,"TLObserve","observe-mode logging",true)
end

do local p=Tab("Anti-Warp","⇜")
    local g=Panel(p,"detector","shared with anti-katana — one event at different ranges",true)
    Toggle(g,"AWOn","enable anti-translocate",false)
    Slider(g,"AWStuds","warp delta threshold",12,4,40,1,"s")
    Slider(g,"AWMelee","katana delta threshold",6,2,20,1,"s")
    Toggle(g,"AWMarker","draw landing marker",true)
    Toggle(g,"AWBeep","beep on detect",false)
    Toggle(g,"AWCrossSnap","crosshair snap to landing",true)
    Toggle(g,"AWPreFire","pre-fire at landing (held)",false)
    Toggle(g,"AWAntiFrag","4-6 stud step-off",false)
    Slider(g,"AWStepStuds","step distance",5,2,10,1,"s")
    Toggle(g,"AWReWarp","counter-warp (needs Warpstone)",false)
end

do local p=Tab("UI","✎")
    local g=Panel(p,"theme","customize the look",true)
    local accentLabel = N("TextLabel",{Size=UDim2.new(1,0,0,14),BackgroundTransparency=1,Text="accent: "..ACCENTS[1].name,Font=F.ui,TextSize=11,TextColor3=ac(),TextXAlignment=Enum.TextXAlignment.Left,Parent=g})
    Button(g,"◆  cycle accent color",function()
        accentIdx = accentIdx%#ACCENTS + 1
        setAccent(ACCENTS[accentIdx].c)
        accentLabel.Text = "accent: "..ACCENTS[accentIdx].name
        accentLabel.TextColor3 = ACCENTS[accentIdx].c
    end)
    Slider(g,"MenuAlpha","menu opacity",1,0.3,1,0.05)
    Slider(g,"MenuScale","menu scale",1,0.6,1.4,0.05)
    Keybind(g,"MenuKey","menu toggle",Enum.KeyCode.RightShift)
    Toggle(g,"AnimOn","widget animations",true)
end

do local p=Tab("Config","◱")
    local g=Panel(p,"save / load","configs on disk",true)
    Button(g,"save 'default'",function()
        if not writefile then sTL.Text="❌ no writefile"; return end
        local d={O={},T={}}; for k,v in pairs(O) do if type(v)~="function" and type(v)~="userdata" then local ok=pcall(function() HttpService:JSONEncode(v) end); if ok then d.O[k]=v end end end
        for k,v in pairs(T) do d.T[k]=v end
        pc(writefile,"UE3_default.json",HttpService:JSONEncode(d))
        sTL.Text="✓ saved default.json"
    end)
    Button(g,"load 'default'",function()
        if not (isfile and isfile("UE3_default.json")) then sTL.Text="❌ no config file"; return end
        local ok,d=pcall(function() return HttpService:JSONDecode(readfile("UE3_default.json")) end)
        if ok and d then for k,v in pairs(d.O or {}) do O[k]=v end; for k,v in pairs(d.T or {}) do T[k]=v end; sTL.Text="✓ loaded" end
    end)
    Button(g,"unload script",function() U.Unload() end,"danger")
end

selectTab("Home")
local scl = N("UIScale",{Scale=1,Parent=Root})

----------------------------------------------------------------
-- core helpers
----------------------------------------------------------------
local function alive(p) return p and p.Character and p.Character.Parent and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChildOfClass("Humanoid") and p.Character:FindFirstChildOfClass("Humanoid").Health>0 end
local function enemy(p) if not T.IgnTeam then return true end; return p.Team~=LP.Team end
local function w2s(v) local p,on=Camera:WorldToViewportPoint(v); return Vector2.new(p.X,p.Y),on,p.Z end
local function los(from,hit) local d=hit.Position-from; local rp=RaycastParams.new(); rp.FilterDescendantsInstances={LP.Character,Camera}; rp.FilterType=Enum.RaycastFilterType.Exclude; local r=Workspace:Raycast(from,d,rp); if not r then return true end; return r.Instance:IsDescendantOf(hit.Parent) end

local function bestHitbox(ch)
    local n=O.HB or "Head"
    if n=="Nearest" then
        local m=UIS:GetMouseLocation(); local best,bd
        for _,nm in ipairs({"Head","UpperTorso","Torso","HumanoidRootPart"}) do local pt=ch:FindFirstChild(nm); if pt then local s,on=w2s(pt.Position); if on then local d=(s-m).Magnitude; if not bd or d<bd then bd,best=d,pt end end end end
        return best
    end
    if n=="MultiScan" then
        local w={Head=O.WtHead,UpperTorso=O.WtChest,HumanoidRootPart=O.WtPelvis,LeftUpperArm=O.WtLimbs,RightUpperArm=O.WtLimbs,LeftUpperLeg=O.WtLimbs,RightUpperLeg=O.WtLimbs}
        local best,bw
        for k,v in pairs(w) do local pt=ch:FindFirstChild(k); if pt and v>0 then if not bw or v>bw then bw,best=v,pt end end end
        return best or ch:FindFirstChild("HumanoidRootPart")
    end
    if T.ForceHS then return ch:FindFirstChild("Head") or ch:FindFirstChild("HumanoidRootPart") end
    if T.ForceBaim then return ch:FindFirstChild("UpperTorso") or ch:FindFirstChild("Torso") or ch:FindFirstChild("HumanoidRootPart") end
    return ch:FindFirstChild(n) or ch:FindFirstChild("HumanoidRootPart")
end

----------------------------------------------------------------
-- backtrack
----------------------------------------------------------------
local function bt_push(p)
    if not alive(p) then return end
    local hrp=p.Character.HumanoidRootPart; local buf=U.BT[p] or {}; U.BT[p]=buf
    table.insert(buf,1,{t=os.clock(),pos=hrp.Position,vel=hrp.AssemblyLinearVelocity})
    while buf[#buf] and os.clock()-buf[#buf].t>1 do buf[#buf]=nil end
end
local function bt_sample(p,ms) local buf=U.BT[p]; if not buf then return nil end; local tg=os.clock()-ms/1000; for _,r in ipairs(buf) do if r.t<=tg then return r end end; return buf[1] end
local function self_bt_push() if not alive(LP) then return end; table.insert(U.SelfPath,1,{t=os.clock(),cf=LP.Character.HumanoidRootPart.CFrame}); while U.SelfPath[#U.SelfPath] and os.clock()-U.SelfPath[#U.SelfPath].t>2 do U.SelfPath[#U.SelfPath]=nil end end
local function self_bt(ms) local tg=os.clock()-ms/1000; for _,r in ipairs(U.SelfPath) do if r.t<=tg then return r end end; return U.SelfPath[#U.SelfPath] end

----------------------------------------------------------------
-- aim + silent aim hook
----------------------------------------------------------------
local aimPos, curTarget = nil, nil
local lastSwitch,lastKillAt = 0,0

local function pickTarget()
    if not T.RageOn and not T.Silent then return nil end
    local kk=K.RageKey; if O.KeyMode=="Hold" and not kk.state then return nil end
    if O.KeyMode=="Toggle" and not kk.state then return nil end
    if T.LockTgt and curTarget and alive(curTarget) and enemy(curTarget) then return curTarget end
    local m=UIS:GetMouseLocation(); local prio=O.Prio
    local best,bs
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=LP and alive(p) and enemy(p) then
            local pt=bestHitbox(p.Character); if pt then
                local s,on=w2s(pt.Position); local d3=(pt.Position-Camera.CFrame.Position).Magnitude
                if on and d3<=O.MaxDist then
                    local d2=(s-m).Magnitude
                    if d2<=O.Fov and ((not T.VisOnly) or los(Camera.CFrame.Position,pt)) then
                        local sc
                        if prio=="FOV" then sc=d2
                        elseif prio=="Distance" then sc=d3
                        elseif prio=="Health" or prio=="LowestHP" then local h=p.Character:FindFirstChildOfClass("Humanoid"); sc=h and h.Health or 100
                        elseif prio=="Crosshair" then sc=d2*0.7+d3*0.3
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
    if os.clock()-lastKillAt<(O.KillDly or 0) then return end
    local nt=pickTarget()
    if not nt then curTarget=nil; aimPos=nil; return end
    if curTarget~=nt then if os.clock()-lastSwitch<(O.SwitchDly or 0) then return end; lastSwitch=os.clock() end
    curTarget=nt
    local pt=bestHitbox(nt.Character); if not pt then aimPos=nil; return end
    local p=pt.Position
    if T.BTOn then local rec=bt_sample(nt,O.BTMs); if rec then p=rec.pos end end
    if T.PredOn then p = p + pt.AssemblyLinearVelocity*(O.PredF or 0.14) end
    if T.Safepoint then p = p:Lerp(pt.Position,O.SPBias) end
    if T.HcGate then
        local hits=0; local vel=pt.AssemblyLinearVelocity; local jit=math.min(vel.Magnitude/40,1.2)
        for i=1,O.HcSmp do
            local ox,oz=(math.random()*2-1)*jit,(math.random()*2-1)*jit
            local rp=RaycastParams.new(); rp.FilterDescendantsInstances={LP.Character,Camera}; rp.FilterType=Enum.RaycastFilterType.Exclude
            local r=Workspace:Raycast(Camera.CFrame.Position,(pt.Position+Vector3.new(ox,0,oz))-Camera.CFrame.Position,rp)
            if not r or r.Instance:IsDescendantOf(pt.Parent) then hits+=1 end
        end
        local hc=hits/O.HcSmp*100
        if hc<O.HcMin then aimPos=nil; return end
    end
    aimPos=p
end

local onShotUntil, defUntil = 0, 0
local lastShotAt=0
local function doFire()
    local now=os.clock(); local rate=1/(O.FireRate or 10)
    if now-lastShotAt<rate then return end; lastShotAt=now
    Sum.shots+=1
    pc(function() local t=LP.Character and LP.Character:FindFirstChildOfClass("Tool"); if t then t:Activate() end end)
    pc(function() if mouse1press then mouse1press(); task.wait(); mouse1release() end end)
    onShotUntil = now + (O.OnShotMs or 220)/1000
    defUntil = now + 0.3
    if T.AutoCrouch and alive(LP) then local h=LP.Character:FindFirstChildOfClass("Humanoid"); if h then pc(function() h.Jump=false; h:ChangeState(Enum.HumanoidStateType.PlatformStanding) end) end end
end

local mt = getrawmetatable and getrawmetatable(game)
if mt and setreadonly then
    pc(setreadonly,mt,false)
    local oldIdx=mt.__index; local oldNc=mt.__namecall
    mt.__index = newcclosure(function(self,k)
        if aimPos and T.Silent then
            if self==LP and k=="GetMouse" then
                local real=oldIdx(self,k)
                return function(...) local mm=real(...); pc(function() mm.Hit=CFrame.new(aimPos); mm.Target=curTarget and curTarget.Character and bestHitbox(curTarget.Character) end); return mm end
            end
            if k=="Hit" and typeof(self)=="Instance" and self:IsA("PlayerMouse") then return CFrame.new(aimPos) end
        end
        return oldIdx(self,k)
    end)
    mt.__namecall = newcclosure(function(self,...)
        if aimPos and T.Silent then
            local method = getnamecallmethod()
            if method=="ScreenPointToRay" or method=="ViewportPointToRay" then local dir=(aimPos-Camera.CFrame.Position).Unit; return Ray.new(Camera.CFrame.Position,dir*2000) end
            if method=="Raycast" and self==Workspace then local args={...}; local orig,dir=args[1],args[2]; if typeof(orig)=="Vector3" and typeof(dir)=="Vector3" then args[2]=(aimPos-orig).Unit*dir.Magnitude; return oldNc(self,table.unpack(args)) end end
        end
        return oldNc(self,...)
    end)
    pc(setreadonly,mt,true)
end

----------------------------------------------------------------
-- RAGEBOT remote hook — Rivals-correct: intercept FireServer
-- and replace Vector3/CFrame args with aim direction toward target
----------------------------------------------------------------
do
    local oldNc2 = mt and mt.__namecall
    if mt and setreadonly and oldNc2 then
        pc(setreadonly,mt,false)
        local prev = mt.__namecall
        mt.__namecall = newcclosure(function(self,...)
            if aimPos and (T.RageOn or T.Silent) and typeof(self)=="Instance" then
                local method = getnamecallmethod()
                if method=="FireServer" or method=="InvokeServer" then
                    local nm = string.lower(self.Name or "")
                    local isFireRemote = nm:find("fire") or nm:find("shoot") or nm:find("weapon") or nm:find("bullet") or nm:find("hit") or nm:find("damage") or nm:find("gun") or nm:find("raycast")
                    -- VOID / FP handoff — correct order: restore → prev → next-tick re-drop
                    if isFireRemote and alive(LP) then
                        local hrpL = LP.Character.HumanoidRootPart
                        if T.VoidOn and T.VoidShootHandoff and voidActive() then
                            voidShootUntil = os.clock() + (O.VoidShootMs or 50)/1000
                            -- restore to surface via camera anchor X/Z and a sane Y
                            if voidCamAnchor then pc(function() hrpL.CFrame = CFrame.new(voidCamAnchor.Position.X, voidCamAnchor.Position.Y-2, voidCamAnchor.Position.Z) * (hrpL.CFrame - hrpL.CFrame.Position) end) end
                        end
                        if T.FPOn and T.FPShootHandoff and fpActive() and fpSurfacePos then
                            fpShootUntil = os.clock() + (O.FPShootMs or 80)/1000
                            pc(function() hrpL.CFrame = CFrame.new(fpSurfacePos) * (hrpL.CFrame - hrpL.CFrame.Position) end)
                        end
                    end
                    if isFireRemote or T.RageOn then
                        local args={...}
                        local origin = Camera.CFrame.Position
                        local toAim = aimPos - origin
                        local dist = toAim.Magnitude
                        local dir = dist > 0.001 and toAim.Unit or Camera.CFrame.LookVector
                        -- Per-remote signature cache keyed on name+argcount+type-pattern.
                        -- First call: infer position arg (farthest-from-origin Vector3) and direction arg
                        -- (unit-ish Vector3) by role, cache the indices, reuse forever.
                        local sig = ("%s|%d"):format(self.Name, select("#", ...))
                        U._sig = U._sig or {}
                        local known = U._sig[sig]
                        if not known then
                            known = {}
                            local posIdx, dirIdx, cfIdx, rayIdx
                            local bestPosD = -1
                            for i,v in ipairs(args) do
                                local tt = typeof(v)
                                if tt=="Vector3" then
                                    local d=(v-origin).Magnitude
                                    if d>2 and d>bestPosD then bestPosD=d; posIdx=i
                                    elseif v.Magnitude>0.1 and v.Magnitude<=1.5 and not dirIdx then dirIdx=i end
                                elseif tt=="CFrame" and not cfIdx then cfIdx=i
                                elseif tt=="Ray" and not rayIdx then rayIdx=i end
                            end
                            known.pos,known.dir,known.cf,known.ray = posIdx,dirIdx,cfIdx,rayIdx
                            U._sig[sig] = known
                        end
                        if known.pos then args[known.pos] = aimPos end
                        if known.dir then args[known.dir] = dir end
                        if known.cf then
                            -- point-blank guard: CFrame.new(from,to) degenerates at near-zero
                            args[known.cf] = (dist > 2)
                                and CFrame.lookAt(origin, aimPos, Vector3.yAxis)
                                or args[known.cf]
                        end
                        if known.ray then
                            -- preserve Ray.Origin, replace Direction only
                            local r=args[known.ray]
                            args[known.ray] = Ray.new(r.Origin, dir * r.Direction.Magnitude)
                        end
                        -- KEEP varargs exact — never append/truncate
                        return prev(self, unpack(args, 1, select("#", ...)))
                    end
                end
            end
            return prev(self,...)
        end)
        pc(setreadonly,mt,true)
    end
end

local function fireTick() if T.RageOn and T.AutoFire and curTarget and aimPos then doFire() end end

----------------------------------------------------------------
-- anti-aim
----------------------------------------------------------------
local aaSide, realDesyncYaw = 1, 0
local function getState()
    if not alive(LP) then return "none" end
    local h=LP.Character:FindFirstChildOfClass("Humanoid"); if not h then return "none" end
    local s=h:GetState()
    if s==Enum.HumanoidStateType.Freefall or s==Enum.HumanoidStateType.Jumping then return "Air" end
    local v=LP.Character.HumanoidRootPart.AssemblyLinearVelocity
    if v.Magnitude>2 then return "Move" end
    return "Stand"
end
local function stateMode()
    local st=getState(); local map={Stand=O.AASt,Move=O.AAMv,Air=O.AAAir,Crouch=O.AACr}; local m=map[st]
    if m and m~="Inherit" then return m end
    return nil
end
local function atTargetYaw()
    local best,bd
    for _,p in ipairs(Players:GetPlayers()) do if p~=LP and alive(p) and enemy(p) then local hrp=p.Character.HumanoidRootPart; local d=(hrp.Position-LP.Character.HumanoidRootPart.Position).Magnitude; if not bd or d<bd then bd,best=d,hrp end end end
    if not best then return math.pi end
    local to=best.Position-LP.Character.HumanoidRootPart.Position
    return math.atan2(to.X,to.Z)+math.pi
end
local function freestandSide()
    if not alive(LP) then return 1 end
    local hrp=LP.Character.HumanoidRootPart; local rp=RaycastParams.new(); rp.FilterDescendantsInstances={LP.Character,Camera}; rp.FilterType=Enum.RaycastFilterType.Exclude
    local rH=Workspace:Raycast(hrp.Position,hrp.CFrame.RightVector*20,rp)
    local lH=Workspace:Raycast(hrp.Position,-hrp.CFrame.RightVector*20,rp)
    local rD=rH and (rH.Position-hrp.Position).Magnitude or 20
    local lD=lH and (lH.Position-hrp.Position).Magnitude or 20
    return rD>=lD and 1 or -1
end
local function manualDir() if not T.ManOn then return nil end; if K.ManL.state then return math.pi*0.5 end; if K.ManR.state then return -math.pi*0.5 end; if K.ManB.state then return math.pi end; if K.ManF.state then return 0 end end

local function aaTick()
    if not T.AAOn then return end
    if not alive(LP) then return end
    local hrp=LP.Character.HumanoidRootPart; local hum=LP.Character:FindFirstChildOfClass("Humanoid")
    if hum then pc(function() hum.AutoRotate=false end) end
    local y,p,r = 0,0,0
    local base = stateMode() or O.AABase
    local md = manualDir()
    if md then y=md
    elseif base=="Backwards" then y=math.pi
    elseif base=="Sideways" then y=math.pi/2
    elseif base=="Target" and curTarget and alive(curTarget) then local to=curTarget.Character.HumanoidRootPart.Position-hrp.Position; y=math.atan2(to.X,to.Z)+math.pi
    elseif base=="AtTarget" then y=atTargetYaw()
    elseif base=="Freestand" then y=math.pi+freestandSide()*math.rad(O.AADesync or 58)
    elseif base=="Local" then y=select(2,Camera.CFrame:ToEulerAnglesYXZ())
    elseif base=="Jitter" then y=((os.clock()*5)%2<1) and math.pi/2 or -math.pi/2
    elseif base=="Spin" then y=(os.clock()*6)%(math.pi*2)
    elseif base=="Zero" then y=0 end
    local mod=O.AAYaw; local deg=math.rad(O.AAYawDeg or 90); local hz=O.AAYawHz or 8
    if mod=="Spin" then y+=(os.clock()*hz)%(math.pi*2)
    elseif mod=="Jitter" then y+=((os.clock()*hz)%2<1) and deg or -deg
    elseif mod=="Random" then y+=math.rad(math.random(-math.deg(deg),math.deg(deg)))
    elseif mod=="Sway" then y+=math.sin(os.clock()*hz)*deg
    elseif mod=="3way" then local ph=(math.floor(os.clock()*hz)%3); y+=(ph==0 and deg or ph==1 and -deg or 0)
    elseif mod=="Offset" then y+=deg end
    aaSide=-aaSide
    y+=math.rad((aaSide>0) and (O.AADesync or 0) or -(O.AADesync or 0))
    if K.AAInvert.state then y=-y end
    if T.LBY then y+=math.sin(os.clock()*4)*math.rad(5) end
    if T.Micro then y+=math.rad(math.random(-(O.MicroDeg or 3),O.MicroDeg or 3)) end
    if T.OnShot and os.clock()<onShotUntil then y+=math.pi end
    if T.Defensive and os.clock()<defUntil then y+=math.sin(os.clock()*18)*math.rad(25) end
    if T.AAPOn then
        local pm=O.AAPitch; local pd=math.rad(O.AAPDeg or 89)
        if pm=="Down" then p=-pd elseif pm=="Up" then p=pd elseif pm=="Jitter" then p=((os.clock()*10)%2<1) and -pd or pd elseif pm=="Fake" then p=((math.floor(os.clock()*4)%2)==0) and -pd or pd elseif pm=="Random" then p=(math.random()*2-1)*pd end
    end
    local rm=O.AARoll; local rd=math.rad(O.AARDeg or 30)
    if rm=="Left" then r=-rd elseif rm=="Right" then r=rd elseif rm=="Alternate" then r=((math.floor(os.clock()*2)%2)==0) and rd or -rd elseif rm=="Sway" then r=math.sin(os.clock()*2)*rd end
    pc(function() hrp.CFrame=CFrame.new(hrp.Position)*CFrame.Angles(p,y,r) end)
    realDesyncYaw=y
end

----------------------------------------------------------------
-- FAKE POSITION — rivals underground: depth slider, dynamic
-- walk (WASD still reads), surface camera, auto-noclip,
-- auto on-shoot handoff so own shots register.
----------------------------------------------------------------
local fpCamAnchor, fpSurfacePos, fpShootUntil = nil, nil, 0
local function fpActive()
    if not T.FPOn then return false end
    local kk=K.FPKey; local m=O.FPKeyMode or "Toggle"
    if m=="Hold" then return kk.state end
    if m=="Toggle" then return kk.state end
    if m=="Always" then return true end
    return false
end
local function fpTick()
    if not alive(LP) then
        if fpCamAnchor then pc(function() Camera.CameraSubject = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid") end); pc(function() fpCamAnchor:Destroy() end); fpCamAnchor=nil end
        fpSurfacePos=nil
        return
    end
    local hrp=LP.Character.HumanoidRootPart; local hum=LP.Character:FindFirstChildOfClass("Humanoid")
    if fpActive() then
        if os.clock()<fpShootUntil then return end -- handoff
        if not fpSurfacePos then fpSurfacePos = Vector3.new(hrp.Position.X, hrp.Position.Y, hrp.Position.Z) end
        -- dynamic walk: capture current intended X/Z movement by reading MoveDirection
        local md = hum and hum.MoveDirection or Vector3.zero
        local spd = (hum and hum.WalkSpeed or 16)
        local now = os.clock()
        U._fpLast = U._fpLast or now
        local dt = now - U._fpLast
        U._fpLast = now
        if md.Magnitude>0.1 then
            fpSurfacePos = fpSurfacePos + Vector3.new(md.X, 0, md.Z) * spd * dt
        end
        -- blink offset
        if T.FPBlink and K.FPBlinkK.state then fpSurfacePos = fpSurfacePos + hrp.CFrame.RightVector*(O.FPBlinkD or 8) end
        -- keep camera at surface
        if not fpCamAnchor then
            fpCamAnchor = Instance.new("Part")
            fpCamAnchor.Size=Vector3.new(1,1,1); fpCamAnchor.Transparency=1; fpCamAnchor.Anchored=true; fpCamAnchor.CanCollide=false
            pc(function() fpCamAnchor.Parent=Workspace end)
            pc(function() Camera.CameraSubject=fpCamAnchor end)
        end
        pc(function() fpCamAnchor.CFrame = CFrame.new(fpSurfacePos.X, fpSurfacePos.Y + 2, fpSurfacePos.Z) end)
        -- auto-noclip underground
        if T.FPNoclip then for _,d in ipairs(LP.Character:GetDescendants()) do if d:IsA("BasePart") then pc(function() d.CanCollide=false end) end end end
        -- sink HRP by depth
        pc(function()
            hrp.CFrame = CFrame.new(fpSurfacePos.X, fpSurfacePos.Y - (O.FPDepth or 25), fpSurfacePos.Z) * (hrp.CFrame - hrp.CFrame.Position)
        end)
    else
        if fpCamAnchor then
            pc(function() Camera.CameraSubject = LP.Character:FindFirstChildOfClass("Humanoid") end)
            pc(function() fpCamAnchor:Destroy() end); fpCamAnchor=nil
        end
        fpSurfacePos=nil
    end
end
-- shoot handoff: when user fires, briefly restore to surface
C(UIS.InputBegan:Connect(function(i,gp) if gp then return end
    if i.UserInputType==Enum.UserInputType.MouseButton1 and T.FPShootHandoff and fpActive() and fpSurfacePos then
        fpShootUntil = os.clock() + (O.FPShootMs or 80)/1000
        pc(function() if alive(LP) then LP.Character.HumanoidRootPart.CFrame = CFrame.new(fpSurfacePos) end end)
    end
end))

----------------------------------------------------------------
-- VOIDSPAM (rivals-correct) — writes HRP to targetHRP.Y - depth
-- every tick so enemies' hit resolution against the replicated
-- copy misses. Camera subject held on a floating anchor so the
-- local view doesn't dive. On-shoot handoff briefly restores
-- the real position so our own shot registers server-side.
----------------------------------------------------------------
local voidCamAnchor, voidShootUntil = nil, 0
local function voidActive()
    if not T.VoidOn then return false end
    local kk=K.VoidKey; local m=O.VoidKeyMode or "Hold"
    if m=="Hold" then return kk.state end
    if m=="Toggle" then return kk.state end
    if m=="Always" then return true end
    return false
end
local function voidPickDepth()
    local mn,mx = O.VoidDepthMin or 10, O.VoidDepthMax or 40
    return mn + math.random()*(mx-mn)
end
local function voidResolveY()
    -- pick a base Y to sit beneath: target's Y or map floor
    if O.VoidMode=="BelowTarget" and curTarget and alive(curTarget) then
        return curTarget.Character.HumanoidRootPart.Position.Y
    elseif O.VoidMode=="BelowNearest" then
        local best,bd
        for _,p in ipairs(Players:GetPlayers()) do if p~=LP and alive(p) and enemy(p) then local pos=p.Character.HumanoidRootPart.Position; local d=(pos-(LP.Character and LP.Character.HumanoidRootPart.Position or Vector3.zero)).Magnitude; if not bd or d<bd then bd,best=d,pos.Y end end end
        return best or -500
    end
    return O.VoidMapY or -300 -- map floor fallback (clamp — some maps kill-plane at -500)
end
local function voidTick()
    if not alive(LP) then
        if voidCamAnchor then pc(function() Camera.CameraSubject = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid") end); pc(function() voidCamAnchor:Destroy() end); voidCamAnchor=nil end
        return
    end
    local on = voidActive()
    local hrp = LP.Character.HumanoidRootPart
    if on then
        -- during on-shoot handoff, do not drop (let the shot register)
        if os.clock()<voidShootUntil then return end
        local baseY = voidResolveY()
        local depth = voidPickDepth()
        local targetY = baseY - depth
        -- keep camera anchored to our real world-X/Z so local view stays usable
        if not voidCamAnchor then
            voidCamAnchor = Instance.new("Part")
            voidCamAnchor.Size=Vector3.new(1,1,1); voidCamAnchor.Transparency=1; voidCamAnchor.Anchored=true; voidCamAnchor.CanCollide=false
            pc(function() voidCamAnchor.Parent = Workspace end)
            pc(function() Camera.CameraSubject = voidCamAnchor end)
        end
        pc(function() voidCamAnchor.CFrame = CFrame.new(hrp.Position.X, hrp.Position.Y + 2, hrp.Position.Z) end)
        -- write HRP underground. zero Y-velocity or physics fights the write.
        -- X/Z preserved exactly — horizontal jitter breaks our own aim math.
        pc(function()
            if T.VoidNoclip then for _,d in ipairs(LP.Character:GetDescendants()) do if d:IsA("BasePart") then d.CanCollide=false end end end
            local cx,_,cz = hrp.Position.X, hrp.Position.Y, hrp.Position.Z
            local newCF = CFrame.new(cx, targetY, cz) * (hrp.CFrame - hrp.CFrame.Position)
            if LP.Character.PivotTo then LP.Character:PivotTo(newCF) else hrp.CFrame = newCF end
            hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, 0, hrp.AssemblyLinearVelocity.Z)
        end)
    else
        if voidCamAnchor then
            pc(function() Camera.CameraSubject = LP.Character:FindFirstChildOfClass("Humanoid") end)
            pc(function() voidCamAnchor:Destroy() end); voidCamAnchor=nil
        end
    end
end
-- on-shoot handoff: restore when user fires (left mouse) for a window
C(UIS.InputBegan:Connect(function(i,gp) if gp then return end
    if i.UserInputType==Enum.UserInputType.MouseButton1 and T.VoidShootHandoff and voidActive() then
        voidShootUntil = os.clock() + (O.VoidShootMs or 120)/1000
    end
end))

----------------------------------------------------------------
-- TRANSLOCATE — Warpstone landing solve + reactivation
-- Rivals writes projectiles into Workspace; we scan for a part
-- named Warpstone/WarpStone/Translocator on first airborne tick
-- and compute a target landing point, then fire reactivation.
----------------------------------------------------------------
local tlLastStoneSeen, tlLogged = {}, {}
local function tlFindStone()
    -- scan live workspace for a stone instance owned by us. Match any part
    -- whose Name/parent matches warp-ish names and is moving (velocity>5).
    for _,d in ipairs(Workspace:GetDescendants()) do
        if d:IsA("BasePart") then
            local nm=(d.Name or ""):lower(); local parentNm = (d.Parent and d.Parent.Name or ""):lower()
            if (nm:find("warp") or nm:find("stone") or parentNm:find("warp")) and d.AssemblyLinearVelocity.Magnitude>5 then
                -- belongs to us if there's an ObjectValue "Owner" matching LP or parent attribute
                local owner = d:FindFirstChild("Owner") or (d.Parent and d.Parent:FindFirstChild("Owner"))
                if owner and owner.Value==LP then return d end
                -- fallback — if we have no clear owner, accept the closest one
                return d
            end
        end
    end
    return nil
end
local function tlSolveLanding(stone)
    -- integrate under gravity. steps of 1/30s, raycast each step.
    local pos = stone.Position; local vel = stone.AssemblyLinearVelocity
    local g = Vector3.new(0, -Workspace.Gravity, 0)
    local step = 1/30
    local rp = RaycastParams.new(); rp.FilterDescendantsInstances={stone, LP.Character, Camera}; rp.FilterType=Enum.RaycastFilterType.Exclude
    for i=1,120 do
        local next_ = pos + vel*step + 0.5*g*step*step
        local hit = Workspace:Raycast(pos, next_-pos, rp)
        if hit then return hit.Position end
        pos = next_; vel = vel + g*step
    end
    return pos
end
local function tlDesiredLanding()
    -- behind target along their velocity, 2-4 studs
    if not curTarget or not alive(curTarget) then return nil end
    local tgt = curTarget.Character.HumanoidRootPart
    local vel = tgt.AssemblyLinearVelocity
    local off = vel.Magnitude>0.2 and vel.Unit*(O.TLLead or 3) or Vector3.zero
    if O.TLMode=="BehindTarget" then return tgt.Position - off
    elseif O.TLMode=="OnTarget" then return tgt.Position
    elseif O.TLMode=="Vertical" then return tgt.Position+Vector3.new(0,10,0) end
    return tgt.Position - off
end
local function tlTick()
    if not T.TLOn then return end
    local stone = tlFindStone()
    if not stone then return end
    if T.TLObserve and not tlLogged[stone] then
        tlLogged[stone]=true
        pc(function() warn(("[UE3 TL] stone=%s parent=%s vel=%s"):format(tostring(stone.Name), tostring(stone.Parent and stone.Parent.Name), tostring(stone.AssemblyLinearVelocity.Magnitude))) end)
    end
    local solved = tlSolveLanding(stone)
    local desired = tlDesiredLanding()
    if desired and (solved-desired).Magnitude > 2 then
        -- would correct throw velocity here; needs the throw remote to replay with fixed args
        -- (user must observe-mode first). For now, store the delta for HUD.
        U._tlErr = (solved-desired).Magnitude
    end
    -- reactivate when near apex or when user holds key (manual arm)
    if K.TLKey.state then
        -- call generic reactivation: fire the warpstone owner's Activate() if it's a Tool,
        -- else try to signal via a child RemoteEvent named like "reactivate"/"warp"
        pc(function()
            local tool = LP.Character and LP.Character:FindFirstChildOfClass("Tool")
            if tool and tool:FindFirstChildOfClass("RemoteEvent") then
                for _,r in ipairs(tool:GetDescendants()) do if r:IsA("RemoteEvent") and r.Name:lower():find("warp") then r:FireServer() end end
            end
            if tool then tool:Activate() end
        end)
    end
end

----------------------------------------------------------------
-- ANTI-TRANSLOCATE — detector on enemy HRP delta, shared with katana lunge
----------------------------------------------------------------
local awLast = {}
local awMarker = D(Drawing.new("Circle")); awMarker.Visible=false; awMarker.NumSides=24; awMarker.Thickness=2
local awBeepT = 0
local function awTick()
    if not T.AWOn then awMarker.Visible=false; return end
    local biggestJump, jumpPlayer, jumpDest = 0, nil, nil
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=LP and alive(p) and enemy(p) then
            local cur = p.Character.HumanoidRootPart.Position
            local prev = awLast[p]
            if prev then
                local d = (cur-prev).Magnitude
                if d > (O.AWMelee or 6) and d > biggestJump then
                    biggestJump = d; jumpPlayer = p; jumpDest = cur
                end
            end
            awLast[p] = cur
        end
    end
    if jumpPlayer and biggestJump >= (O.AWStuds or 12) then
        -- warp detected
        if T.AWMarker then
            local s,on = w2s(jumpDest)
            if on then awMarker.Visible=true; awMarker.Position=s; awMarker.Radius=18; awMarker.Color=P.rd else awMarker.Visible=false end
        end
        if T.AWBeep and os.clock()-awBeepT>0.4 then awBeepT=os.clock(); pc(function() local s=Instance.new("Sound"); s.SoundId="rbxassetid://3744371091"; s.Volume=0.6; s.Parent=LP:FindFirstChild("PlayerGui") or LP; s:Play(); game:GetService("Debris"):AddItem(s,1) end) end
        if T.AWCrossSnap then
            -- snap mouse/camera yaw toward landing
            pc(function() Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, jumpDest, Vector3.yAxis) end)
        end
        if T.AWPreFire and K.RageKey and K.RageKey.state then
            aimPos = jumpDest; curTarget = jumpPlayer -- feed the hook
        end
        if T.AWAntiFrag and alive(LP) then
            local hrp = LP.Character.HumanoidRootPart
            local away = (hrp.Position-jumpDest)
            if away.Magnitude>0.1 then
                local dir = away.Unit
                local rp = RaycastParams.new(); rp.FilterDescendantsInstances={LP.Character,Camera}; rp.FilterType=Enum.RaycastFilterType.Exclude
                local r = Workspace:Raycast(hrp.Position, dir*(O.AWStepStuds or 5), rp)
                if not r then pc(function() hrp.CFrame = hrp.CFrame + dir*(O.AWStepStuds or 5) end) end
            end
        end
    elseif biggestJump < (O.AWStuds or 12) then
        awMarker.Visible=false
    end
end

----------------------------------------------------------------
-- movement / world
----------------------------------------------------------------
local flyBV, flyBG
local function moveTick()
    if not alive(LP) then return end
    local hum=LP.Character:FindFirstChildOfClass("Humanoid"); local hrp=LP.Character.HumanoidRootPart
    if hum then
        if T.WsOn then pc(function() hum.WalkSpeed=O.Ws end) end
        if T.JpOn then pc(function() hum.UseJumpPower=true; hum.JumpPower=O.Jp end) end
        if T.Bhop and hum:GetState()==Enum.HumanoidStateType.Landed then pc(function() hum:ChangeState(Enum.HumanoidStateType.Jumping) end) end
    end
    if T.Noclip then for _,d in ipairs(LP.Character:GetDescendants()) do if d:IsA("BasePart") then pc(function() d.CanCollide=false end) end end end
    local flyOn = T.Fly or K.FlyKey.state
    if flyOn then
        if not flyBV then flyBV=Instance.new("BodyVelocity"); flyBV.MaxForce=Vector3.new(1,1,1)*1e9; flyBV.Velocity=Vector3.zero; flyBV.Parent=hrp; flyBG=Instance.new("BodyGyro"); flyBG.MaxTorque=Vector3.new(1,1,1)*1e9; flyBG.P=1e4; flyBG.Parent=hrp end
        local cc=Camera.CFrame; local v=Vector3.zero
        if UIS:IsKeyDown(Enum.KeyCode.W) then v+=cc.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then v-=cc.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then v-=cc.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then v+=cc.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then v+=Vector3.yAxis end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then v-=Vector3.yAxis end
        flyBV.Velocity = v.Magnitude>0 and v.Unit*O.FlySpd or Vector3.zero
        flyBG.CFrame = cc
    elseif flyBV then pc(function() flyBV:Destroy() end); pc(function() flyBG:Destroy() end); flyBV=nil; flyBG=nil end
end
C(UIS.JumpRequest:Connect(function() if T.InfJump and alive(LP) then local h=LP.Character:FindFirstChildOfClass("Humanoid"); if h then pc(function() h:ChangeState(Enum.HumanoidStateType.Jumping) end) end end end))

local origFog=Lighting.FogEnd; local origBrt=Lighting.Brightness
local function worldTick()
    pc(function()
        Lighting.FogEnd = T.NoFog and 1e9 or origFog
        Lighting.Brightness = T.FB and O.FBV or origBrt
        if T.TimeLock then Lighting.ClockTime=12 end
        Camera.FieldOfView = T.CFov and O.CFovV or 70
        if T.TP then LP.CameraMinZoomDistance=O.TPDist; LP.CameraMaxZoomDistance=O.TPDist else LP.CameraMinZoomDistance=0.5; LP.CameraMaxZoomDistance=128 end
    end)
end

----------------------------------------------------------------
-- ESP — FIXED: project the character's actual GetBoundingBox corners
----------------------------------------------------------------
local SKEL={ {"Head","UpperTorso"},{"UpperTorso","LowerTorso"},{"UpperTorso","LeftUpperArm"},{"LeftUpperArm","LeftLowerArm"},{"UpperTorso","RightUpperArm"},{"RightUpperArm","RightLowerArm"},{"LowerTorso","LeftUpperLeg"},{"LeftUpperLeg","LeftLowerLeg"},{"LowerTorso","RightUpperLeg"},{"RightUpperLeg","RightLowerLeg"} }
local function ensureEsp(p) local e=U.Esp[p]; if e then return e end
    e={bones={},corners={}}
    local hl=Instance.new("Highlight"); hl.FillTransparency=0.5; hl.Enabled=false; pc(function() hl.Parent=Workspace end); e.hl=hl
    e.box=D(Drawing.new("Square")); e.box.Thickness=1; e.box.Filled=false; e.box.Visible=false
    e.boxOut=D(Drawing.new("Square")); e.boxOut.Thickness=3; e.boxOut.Filled=false; e.boxOut.Color=Color3.new(0,0,0); e.boxOut.Visible=false
    e.fill=D(Drawing.new("Square")); e.fill.Filled=true; e.fill.Visible=false
    for i=1,8 do e.corners[i]=D(Drawing.new("Line")); e.corners[i].Thickness=1; e.corners[i].Visible=false end
    e.name=D(Drawing.new("Text")); e.name.Size=13; e.name.Center=true; e.name.Outline=true; e.name.Visible=false; e.name.Font=2
    e.dist=D(Drawing.new("Text")); e.dist.Size=12; e.dist.Center=true; e.dist.Outline=true; e.dist.Visible=false; e.dist.Font=2
    e.team=D(Drawing.new("Text")); e.team.Size=11; e.team.Center=true; e.team.Outline=true; e.team.Visible=false; e.team.Font=2
    e.tool=D(Drawing.new("Text")); e.tool.Size=11; e.tool.Center=true; e.tool.Outline=true; e.tool.Visible=false; e.tool.Font=2
    e.hpbg=D(Drawing.new("Square")); e.hpbg.Filled=true; e.hpbg.Visible=false
    e.hp=D(Drawing.new("Square")); e.hp.Filled=true; e.hp.Visible=false
    e.hpt=D(Drawing.new("Text")); e.hpt.Size=10; e.hpt.Center=true; e.hpt.Outline=true; e.hpt.Visible=false
    e.tracer=D(Drawing.new("Line")); e.tracer.Thickness=1; e.tracer.Visible=false
    e.dot=D(Drawing.new("Circle")); e.dot.Filled=true; e.dot.NumSides=16; e.dot.Visible=false
    e.circ=D(Drawing.new("Circle")); e.circ.Filled=false; e.circ.NumSides=24; e.circ.Thickness=1; e.circ.Visible=false
    e.arrow=D(Drawing.new("Triangle")); e.arrow.Filled=true; e.arrow.Visible=false
    for i=1,#SKEL do e.bones[i]=D(Drawing.new("Line")); e.bones[i].Thickness=1; e.bones[i].Visible=false end
    U.Esp[p]=e; return e
end
local function hideEsp(e)
    e.box.Visible=false; e.boxOut.Visible=false; e.fill.Visible=false
    for i=1,8 do e.corners[i].Visible=false end
    e.name.Visible=false; e.dist.Visible=false; e.team.Visible=false; e.tool.Visible=false
    e.hpbg.Visible=false; e.hp.Visible=false; e.hpt.Visible=false
    e.tracer.Visible=false; e.dot.Visible=false; e.circ.Visible=false; e.arrow.Visible=false
    for i=1,#SKEL do e.bones[i].Visible=false end
    if e.hl then pc(function() e.hl.Enabled=false; e.hl.Adornee=nil end) end
end
local function destroyEsp(p) local e=U.Esp[p]; if not e then return end; pc(function() e.hl:Destroy() end); hideEsp(e); U.Esp[p]=nil end
C(Players.PlayerRemoving:Connect(destroyEsp))
C(Players.PlayerAdded:Connect(function(p) p.CharacterRemoving:Connect(function() local e=U.Esp[p]; if e then hideEsp(e) end end) end))
for _,p in ipairs(Players:GetPlayers()) do if p~=LP then p.CharacterRemoving:Connect(function() local e=U.Esp[p]; if e then hideEsp(e) end end) end end

-- project the character's actual bounding box corners into screen space
local function charBounds(ch)
    local cf, sz = ch:GetBoundingBox()
    local sx,sy,sz_ = sz.X*0.5, sz.Y*0.5, sz.Z*0.5
    local corners = {
        cf*CFrame.new( sx, sy, sz_), cf*CFrame.new(-sx, sy, sz_),
        cf*CFrame.new( sx,-sy, sz_), cf*CFrame.new(-sx,-sy, sz_),
        cf*CFrame.new( sx, sy,-sz_), cf*CFrame.new(-sx, sy,-sz_),
        cf*CFrame.new( sx,-sy,-sz_), cf*CFrame.new(-sx,-sy,-sz_),
    }
    local minX,minY,maxX,maxY = math.huge, math.huge, -math.huge, -math.huge
    local any=false
    for _,c in ipairs(corners) do
        local s,on = w2s(c.Position)
        if on then
            any=true
            if s.X<minX then minX=s.X end
            if s.Y<minY then minY=s.Y end
            if s.X>maxX then maxX=s.X end
            if s.Y>maxY then maxY=s.Y end
        end
    end
    if not any then return nil end
    return minX,minY,maxX,maxY
end

local function espTick()
    if not T.EspOn and not T.ChamsOn then for _,e in pairs(U.Esp) do hideEsp(e) end; return end
    local rainbow = T.EspRainbow and Color3.fromHSV((os.clock()*0.3)%1,0.9,1)
    for _,pl in ipairs(Players:GetPlayers()) do if pl~=LP then
        local e=ensureEsp(pl)
        if not alive(pl) then hideEsp(e) else
            local isEn=enemy(pl); local show = T.EspOn and (isEn or T.EspTeam); local showC = T.ChamsOn and (isEn or T.EspTeam)
            local c
            if rainbow then c=rainbow
            elseif T.EspTeamColor and pl.TeamColor then c=pl.TeamColor.Color
            else c = isEn and (O.EspEnemyCol or P.rd) or (O.EspFriendCol or P.bl) end
            local ch=pl.Character; local hrp=ch.HumanoidRootPart; local head=ch:FindFirstChild("Head") or hrp; local hum=ch:FindFirstChildOfClass("Humanoid")
            if show then
                local minX,minY,maxX,maxY = charBounds(ch)
                if minX then
                    local w = maxX - minX; local h = maxY - minY
                    local x,y = minX, minY
                    local midX = (minX+maxX)/2
                    if T.EspBox then
                        local st=O.EspBoxS
                        if st=="full" or st=="rounded" then
                            e.box.Visible=true; e.box.Size=Vector2.new(w,h); e.box.Position=Vector2.new(x,y); e.box.Color=c; e.box.Thickness=1
                            for i=1,8 do e.corners[i].Visible=false end
                            e.boxOut.Visible=false
                        elseif st=="outlined" then
                            e.boxOut.Visible=true; e.boxOut.Size=Vector2.new(w,h); e.boxOut.Position=Vector2.new(x,y); e.boxOut.Thickness=3
                            e.box.Visible=true; e.box.Size=Vector2.new(w,h); e.box.Position=Vector2.new(x,y); e.box.Color=c; e.box.Thickness=1
                            for i=1,8 do e.corners[i].Visible=false end
                        else -- corner
                            e.box.Visible=false; e.boxOut.Visible=false
                            local cl=math.min(w,h)*0.25
                            local pts={
                                {Vector2.new(x,y),Vector2.new(x+cl,y)},{Vector2.new(x,y),Vector2.new(x,y+cl)},
                                {Vector2.new(x+w,y),Vector2.new(x+w-cl,y)},{Vector2.new(x+w,y),Vector2.new(x+w,y+cl)},
                                {Vector2.new(x,y+h),Vector2.new(x+cl,y+h)},{Vector2.new(x,y+h),Vector2.new(x,y+h-cl)},
                                {Vector2.new(x+w,y+h),Vector2.new(x+w-cl,y+h)},{Vector2.new(x+w,y+h),Vector2.new(x+w,y+h-cl)}
                            }
                            for i=1,8 do e.corners[i].Visible=true; e.corners[i].From=pts[i][1]; e.corners[i].To=pts[i][2]; e.corners[i].Color=c end
                        end
                        if T.EspBoxFill then e.fill.Visible=true; e.fill.Position=Vector2.new(x,y); e.fill.Size=Vector2.new(w,h); e.fill.Color=c; e.fill.Transparency=O.EspBoxFillA else e.fill.Visible=false end
                    else e.box.Visible=false; e.boxOut.Visible=false; e.fill.Visible=false; for i=1,8 do e.corners[i].Visible=false end end

                    if T.EspName then e.name.Visible=true; e.name.Text=pl.Name; e.name.Size=O.EspFont or 13; e.name.Position=Vector2.new(midX, y - (O.EspFont or 13) - 2); e.name.Color=c else e.name.Visible=false end
                    if T.EspDist then e.dist.Visible=true; e.dist.Text=string.format("[%ds]",math.floor((hrp.Position-Camera.CFrame.Position).Magnitude)); e.dist.Position=Vector2.new(midX, y + h + 2); e.dist.Color=c else e.dist.Visible=false end
                    if T.EspTeam and pl.Team then e.team.Visible=true; e.team.Text="<"..pl.Team.Name..">"; e.team.Position=Vector2.new(midX, y + h + 16); e.team.Color=c else e.team.Visible=false end
                    if T.EspTool then local tl=ch:FindFirstChildOfClass("Tool"); if tl then e.tool.Visible=true; e.tool.Text=tl.Name; e.tool.Position=Vector2.new(midX, y + h + ((T.EspTeam and pl.Team) and 30 or 16)); e.tool.Color=c else e.tool.Visible=false end else e.tool.Visible=false end

                    if T.EspHealth and hum and hum.MaxHealth>0 then
                        local hp=math.clamp(hum.Health/hum.MaxHealth,0,1)
                        e.hpbg.Visible=true; e.hp.Visible=true
                        e.hpbg.Position=Vector2.new(x-6,y); e.hpbg.Size=Vector2.new(3,h); e.hpbg.Color=Color3.new(0,0,0)
                        e.hp.Position=Vector2.new(x-6,y+h*(1-hp)); e.hp.Size=Vector2.new(3,h*hp); e.hp.Color=Color3.fromRGB(math.floor(255-hp*255),math.floor(hp*255),40)
                        if T.EspHealthT then e.hpt.Visible=true; e.hpt.Text=tostring(math.floor(hum.Health)); e.hpt.Position=Vector2.new(x-14,y+h*(1-hp)-5); e.hpt.Color=e.hp.Color else e.hpt.Visible=false end
                    else e.hpbg.Visible=false; e.hp.Visible=false; e.hpt.Visible=false end

                    if T.EspTracer or T.EspSnap then
                        e.tracer.Visible=true; local vp=Camera.ViewportSize; local o=O.EspTracerO
                        local src = T.EspSnap and UIS:GetMouseLocation() or (o=="bottom" and Vector2.new(vp.X/2,vp.Y)) or (o=="top" and Vector2.new(vp.X/2,0)) or (o=="center" and vp/2) or UIS:GetMouseLocation()
                        e.tracer.From=src; e.tracer.To=Vector2.new(midX, y + h); e.tracer.Color=c
                    else e.tracer.Visible=false end

                    if T.EspHeadDot then local hs,hon=w2s(head.Position); if hon then e.dot.Visible=true; e.dot.Position=hs; e.dot.Radius=3; e.dot.Color=c else e.dot.Visible=false end else e.dot.Visible=false end
                    if T.EspHeadCir then local hs,hon=w2s(head.Position); if hon then e.circ.Visible=true; e.circ.Position=hs; e.circ.Radius=h*0.09; e.circ.Color=c else e.circ.Visible=false end else e.circ.Visible=false end

                    if T.EspSkel then for i,pair in ipairs(SKEL) do local a=ch:FindFirstChild(pair[1]); local b=ch:FindFirstChild(pair[2]); if a and b then local sa,oa=w2s(a.Position); local sb,ob=w2s(b.Position); if oa and ob then e.bones[i].Visible=true; e.bones[i].From=sa; e.bones[i].To=sb; e.bones[i].Color=c else e.bones[i].Visible=false end else e.bones[i].Visible=false end end
                    else for i=1,#SKEL do e.bones[i].Visible=false end end

                    if T.EspOff then
                        local sc,on=w2s(hrp.Position)
                        if not on then local vp=Camera.ViewportSize; local cc=vp/2; local dir=Vector2.new(sc.X,sc.Y)-cc; if dir.Magnitude<1 then dir=Vector2.new(1,0) end; dir=dir.Unit; local tip=cc+dir*180; local perp=Vector2.new(-dir.Y,dir.X)*12; e.arrow.Visible=true; e.arrow.PointA=tip; e.arrow.PointB=tip-dir*20+perp; e.arrow.PointC=tip-dir*20-perp; e.arrow.Color=c else e.arrow.Visible=false end
                    else e.arrow.Visible=false end
                else hideEsp(e) end
            else
                e.box.Visible=false; e.boxOut.Visible=false; e.fill.Visible=false; for i=1,8 do e.corners[i].Visible=false end
                e.name.Visible=false; e.dist.Visible=false; e.team.Visible=false; e.tool.Visible=false
                e.hpbg.Visible=false; e.hp.Visible=false; e.hpt.Visible=false; e.tracer.Visible=false; e.dot.Visible=false; e.circ.Visible=false; e.arrow.Visible=false
                for i=1,#SKEL do e.bones[i].Visible=false end
            end
            if showC then
                pc(function()
                    e.hl.Enabled=true; e.hl.Adornee=ch
                    local fc=O.ChamsCol or c
                    if T.ChamsVis and los(Camera.CFrame.Position,head) then fc=O.ChamsVisCol or Color3.fromRGB(110,220,140) end
                    e.hl.FillColor=fc; e.hl.OutlineColor=O.ChamsOutCol or Color3.new(1,1,1); e.hl.FillTransparency=O.ChamsFill
                end)
            else pc(function() e.hl.Enabled=false; e.hl.Adornee=nil end) end
        end
    end end
end

----------------------------------------------------------------
-- HUD drawings
----------------------------------------------------------------
local fovRing=D(Drawing.new("Circle")); fovRing.Thickness=1; fovRing.NumSides=64; fovRing.Visible=false
local aaArrow=D(Drawing.new("Triangle")); aaArrow.Filled=true; aaArrow.Visible=false
local watermark=D(Drawing.new("Text")); watermark.Size=14; watermark.Outline=true; watermark.Font=2; watermark.Visible=false
local aimDot=D(Drawing.new("Circle")); aimDot.Filled=true; aimDot.NumSides=16; aimDot.Visible=false
local tgtBox=D(Drawing.new("Square")); tgtBox.Thickness=2; tgtBox.Filled=false; tgtBox.Visible=false
local xh = {v1=D(Drawing.new("Line")),v2=D(Drawing.new("Line")),h1=D(Drawing.new("Line")),h2=D(Drawing.new("Line")),dot=D(Drawing.new("Circle"))}
for _,l in pairs(xh) do l.Visible=false end

local function hudTick()
    local c = ac()
    fovRing.Visible = T.FovRing and (T.RageOn or T.Silent)
    if fovRing.Visible then fovRing.Position=UIS:GetMouseLocation(); fovRing.Radius=O.Fov or 120; fovRing.Color=c end
    aaArrow.Visible = T.AAArrow and T.AAOn
    if aaArrow.Visible then local cc=Camera.ViewportSize/2; local y=realDesyncYaw; aaArrow.PointA=cc+Vector2.new(math.sin(y),-math.cos(y))*45; aaArrow.PointB=cc+Vector2.new(math.sin(y+2.6),-math.cos(y+2.6))*15; aaArrow.PointC=cc+Vector2.new(math.sin(y-2.6),-math.cos(y-2.6))*15; aaArrow.Color=c end
    watermark.Visible = T.WaterMark
    if watermark.Visible then watermark.Text="unnamed enhancements v3 // olivia"; watermark.Position=Vector2.new(Camera.ViewportSize.X-320,10); watermark.Color=c end
    aimDot.Visible = T.AimDot and aimPos ~= nil
    if aimDot.Visible then local s,on=w2s(aimPos); if on then aimDot.Position=s; aimDot.Radius=3; aimDot.Color=c else aimDot.Visible=false end end
    if T.TargetBox and curTarget and alive(curTarget) then local mnx,mny,mxx,mxy=charBounds(curTarget.Character); if mnx then tgtBox.Visible=true; tgtBox.Position=Vector2.new(mnx-2,mny-2); tgtBox.Size=Vector2.new((mxx-mnx)+4,(mxy-mny)+4); tgtBox.Color=c else tgtBox.Visible=false end else tgtBox.Visible=false end

    local xe = T.XhOn
    for _,l in pairs(xh) do l.Visible=xe end
    if xe then
        local cc=Camera.ViewportSize/2; local sz=O.XhSize; local gp=O.XhGap; local th=O.XhThick; local col=O.XhColor
        xh.v1.From=cc-Vector2.new(0,gp+sz); xh.v1.To=cc-Vector2.new(0,gp); xh.v1.Color=col; xh.v1.Thickness=th
        xh.v2.From=cc+Vector2.new(0,gp); xh.v2.To=cc+Vector2.new(0,gp+sz); xh.v2.Color=col; xh.v2.Thickness=th
        xh.h1.From=cc-Vector2.new(gp+sz,0); xh.h1.To=cc-Vector2.new(gp,0); xh.h1.Color=col; xh.h1.Thickness=th
        xh.h2.From=cc+Vector2.new(gp,0); xh.h2.To=cc+Vector2.new(gp+sz,0); xh.h2.Color=col; xh.h2.Thickness=th
        xh.dot.Position=cc; xh.dot.Radius=1; xh.dot.Color=col; xh.dot.Filled=true
    end
end

local function statusTick()
    sTL.Text = string.format("● rage %s  ● silent %s  ● aa %s  ● fp %s  ● void %s  ● esp %s  ● fly %s",
        T.RageOn and "ON" or "--", T.Silent and "ON" or "--", T.AAOn and "ON" or "--",
        T.FPOn and "ON" or "--", voidActive() and "ON" or "--", T.EspOn and "ON" or "--", T.Fly and "ON" or "--")
    sTR.Text = string.format("tgt: %s  //  shots: %d", curTarget and curTarget.Name or "—", Sum.shots)
end

----------------------------------------------------------------
-- scheduler
----------------------------------------------------------------
C(RunService.Heartbeat:Connect(function()
    for _,p in ipairs(Players:GetPlayers()) do if p~=LP then pc(bt_push,p) end end
    pc(self_bt_push); pc(aimTick); pc(fireTick); pc(aaTick)
    -- HRP arbiter per spec: transient handoff > fake pos > voidspam > base
    if T.FPOn then pc(fpTick) else pc(voidTick) end
    pc(tlTick); pc(awTick); pc(moveTick); pc(worldTick); pc(espTick); pc(hudTick); pc(statusTick)
    scl.Scale = O.MenuScale or 1
    Root.BackgroundTransparency = 1-(O.MenuAlpha or 1)
end))

C(Players.PlayerAdded:Connect(function(p) p.CharacterAdded:Connect(function(ch) local h=ch:WaitForChild("Humanoid",5); if h then h.Died:Connect(function() if curTarget==p then Sum.kills+=1; lastKillAt=os.clock() end end) end end) end))

C(UIS.InputBegan:Connect(function(i,gp) if gp then return end; local kk=K.MenuKey; if kk and typeof(kk.k)=="EnumItem" and i.KeyCode==kk.k then Root.Visible = not Root.Visible end end))

LP.CharacterAdded:Connect(function() for _,e in pairs(U.Esp) do hideEsp(e) end end)

setAccent(ACCENTS[1].c)
sTL.Text = "✓ ready — unnamed enhancements v3 loaded"

----------------------------------------------------------------
-- unload
----------------------------------------------------------------
U.Unload = function()
    for _,c in ipairs(U.Con) do pcall(function() c:Disconnect() end) end
    for _,d in ipairs(U.Draw) do pcall(function() d:Remove() end) end
    for p,_ in pairs(U.Esp) do destroyEsp(p) end
    for k,_ in pairs(U.Ghost) do pcall(function() U.Ghost[k]:Destroy() end) end
    if flyBV then pcall(function() flyBV:Destroy() end) end
    if flyBG then pcall(function() flyBG:Destroy() end) end
    if voidFF then pcall(function() voidFF:Destroy() end) end
    pcall(function() Lighting.FogEnd=origFog; Lighting.Brightness=origBrt; Camera.FieldOfView=70 end)
    pcall(function() Screen:Destroy() end)
    getgenv().UE3=nil
end
