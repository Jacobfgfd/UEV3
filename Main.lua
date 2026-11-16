--[==[ UNNAMED ENHANCEMENTS  v8  //  olivia  //  discord.gg/ojailbreaks ]==]

if getgenv().UEV8 and getgenv().UEV8.Unload then pcall(getgenv().UEV8.Unload) end

local HttpService = game:GetService("HttpService")
local Players     = game:GetService("Players")
local RunService  = game:GetService("RunService")
local UIS         = game:GetService("UserInputService")
local Lighting    = game:GetService("Lighting")
local Workspace   = game:GetService("Workspace")
local CoreGui     = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Camera      = Workspace.CurrentCamera
local LP          = Players.LocalPlayer

local U = { Opt={}, Tog={}, Key={}, Con={}, Draw={}, Esp={}, Ghost={}, SelfPath={}, BT={}, Sum={shots=0,hits=0,kills=0} }
getgenv().UEV8 = U
local O,T,K,Sum = U.Opt,U.Tog,U.Key,U.Sum
local function C(c) table.insert(U.Con,c); return c end
local function D(d) table.insert(U.Draw,d); return d end
local function pc(f,...) local ok,r=pcall(f,...); return ok and r end

----------------------------------------------------------------
local P = {
    bg  = Color3.fromRGB(10,10,12),
    pn  = Color3.fromRGB(18,18,22),
    pn2 = Color3.fromRGB(26,26,32),
    bd  = Color3.fromRGB(60,60,70),
    bdh = Color3.fromRGB(120,120,140),
    tx  = Color3.fromRGB(215,215,220),
    dim = Color3.fromRGB(110,110,120),
    ac  = Color3.fromRGB(255,120,60),   -- default accent (user customizes)
    gn  = Color3.fromRGB(130,220,120),
    rd  = Color3.fromRGB(230,80,80),
    bl  = Color3.fromRGB(110,180,255),
    yw  = Color3.fromRGB(240,200,80),
}
local F = {mono=Enum.Font.Code, px=Enum.Font.Arcade}

local function N(c,p) local i=Instance.new(c); for k,v in pairs(p or {}) do i[k]=v end; return i end
local function pd(p,l,r,t,b) N("UIPadding",{PaddingLeft=UDim.new(0,l),PaddingRight=UDim.new(0,r or l),PaddingTop=UDim.new(0,t or l),PaddingBottom=UDim.new(0,b or t or l),Parent=p}) end
local function brd(parent,col,thick)
    thick = thick or 1
    N("Frame",{Size=UDim2.new(1,0,0,thick),BackgroundColor3=col,BorderSizePixel=0,ZIndex=(parent.ZIndex or 1)+1,Parent=parent})
    N("Frame",{Size=UDim2.new(1,0,0,thick),Position=UDim2.new(0,0,1,-thick),BackgroundColor3=col,BorderSizePixel=0,ZIndex=(parent.ZIndex or 1)+1,Parent=parent})
    N("Frame",{Size=UDim2.new(0,thick,1,0),BackgroundColor3=col,BorderSizePixel=0,ZIndex=(parent.ZIndex or 1)+1,Parent=parent})
    N("Frame",{Size=UDim2.new(0,thick,1,0),Position=UDim2.new(1,-thick,0,0),BackgroundColor3=col,BorderSizePixel=0,ZIndex=(parent.ZIndex or 1)+1,Parent=parent})
end

----------------------------------------------------------------
-- shell
----------------------------------------------------------------
local Screen = N("ScreenGui",{IgnoreGuiInset=true,ResetOnSpawn=false,ZIndexBehavior=Enum.ZIndexBehavior.Sibling,DisplayOrder=1e5,Name="_ue"..math.random(1e5,1e6)})
pcall(function() if syn and syn.protect_gui then syn.protect_gui(Screen) end; if gethui then Screen.Parent=gethui() else Screen.Parent=CoreGui end end)
if not Screen.Parent then Screen.Parent = LP:WaitForChild("PlayerGui") end
U.Screen = Screen

local Root = N("Frame",{Size=UDim2.fromOffset(820,560),Position=UDim2.new(0.5,-410,0.5,-280),BackgroundColor3=P.bg,BorderSizePixel=0,Parent=Screen,Active=true})
brd(Root,P.bdh,1)

-- hand-grimed corner marks (asymmetric, breaks AI symmetry)
local function cornerMark(x,y,txt,col,sz)
    N("TextLabel",{Size=UDim2.fromOffset(60,12),Position=UDim2.fromOffset(x,y),BackgroundTransparency=1,Text=txt,Font=F.mono,TextSize=sz or 9,TextColor3=col or P.dim,TextXAlignment=Enum.TextXAlignment.Left,Parent=Root})
end
cornerMark(8,4,"+",P.ac,10)
cornerMark(Root.Size.X.Offset-14,4,"+",P.ac,10)
cornerMark(8,Root.Size.Y.Offset-12,"+",P.ac,10)
cornerMark(Root.Size.X.Offset-14,Root.Size.Y.Offset-12,"+",P.ac,10)

-- top strip
local TB = N("Frame",{Size=UDim2.new(1,-2,0,26),Position=UDim2.fromOffset(1,1),BackgroundColor3=P.pn,BorderSizePixel=0,Parent=Root})
N("Frame",{Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,1,0),BackgroundColor3=P.ac,BorderSizePixel=0,Parent=TB})

-- grime details: small ascii glyphs varying sizes, asymmetric positions
N("TextLabel",{Size=UDim2.fromOffset(40,14),Position=UDim2.fromOffset(8,6),BackgroundTransparency=1,Text="~//~",Font=F.mono,TextSize=11,TextColor3=P.ac,Parent=TB})
local TtlA = N("TextLabel",{Size=UDim2.fromOffset(300,14),Position=UDim2.fromOffset(50,4),BackgroundTransparency=1,Text="unnamed enhancements",Font=F.mono,TextSize=13,TextColor3=P.tx,TextXAlignment=Enum.TextXAlignment.Left,Parent=TB})
local TtlB = N("TextLabel",{Size=UDim2.fromOffset(60,14),Position=UDim2.fromOffset(50,15),BackgroundTransparency=1,Text="v8  //  olivia",Font=F.mono,TextSize=10,TextColor3=P.dim,TextXAlignment=Enum.TextXAlignment.Left,Parent=TB})
local TtlC = N("TextLabel",{Size=UDim2.fromOffset(240,14),Position=UDim2.fromOffset(300,15),BackgroundTransparency=1,Text="/*  discord.gg/ojailbreaks  */",Font=F.mono,TextSize=10,TextColor3=P.ac,TextXAlignment=Enum.TextXAlignment.Left,Parent=TB})

local closeX = N("TextButton",{Size=UDim2.fromOffset(20,16),Position=UDim2.new(1,-26,0,5),BackgroundColor3=P.bg,BorderSizePixel=0,Text="[x]",Font=F.mono,TextSize=11,TextColor3=P.rd,AutoButtonColor=false,Parent=TB})
closeX.MouseButton1Click:Connect(function() if U.Unload then U.Unload() end end)

-- drag
do local dr,sm,sp
    TB.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dr=true; sm=i.Position; sp=Root.Position end end)
    TB.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dr=false end end)
    C(UIS.InputChanged:Connect(function(i) if dr and i.UserInputType==Enum.UserInputType.MouseMovement then local d=i.Position-sm; Root.Position=UDim2.new(sp.X.Scale,sp.X.Offset+d.X,sp.Y.Scale,sp.Y.Offset+d.Y) end end))
end

-- tabs on the LEFT (not top — breaks default AI layout)
local TabCol = N("Frame",{Size=UDim2.fromOffset(130,1),Position=UDim2.fromOffset(2,28),BackgroundColor3=P.pn,BorderSizePixel=0,Parent=Root})
TabCol.Size = UDim2.new(0,130,1,-54)
N("Frame",{Size=UDim2.new(0,1,1,0),Position=UDim2.new(1,0,0,0),BackgroundColor3=P.ac,BorderSizePixel=0,Parent=TabCol})
pd(TabCol,4,4,6,6)
N("UIListLayout",{Padding=UDim.new(0,2),Parent=TabCol})

local Content = N("Frame",{Size=UDim2.new(1,-134,1,-54),Position=UDim2.fromOffset(132,28),BackgroundColor3=P.bg,BorderSizePixel=0,Parent=Root})
pd(Content,8,8,8,8)

-- bottom status strip (varied: left ascii load bar, right stats)
local SB = N("Frame",{Size=UDim2.new(1,-2,0,22),Position=UDim2.new(0,1,1,-23),BackgroundColor3=P.pn,BorderSizePixel=0,Parent=Root})
N("Frame",{Size=UDim2.new(1,0,0,1),BackgroundColor3=P.ac,BorderSizePixel=0,Parent=SB})
local sTL = N("TextLabel",{Size=UDim2.new(0.6,0,1,0),Position=UDim2.fromOffset(8,0),BackgroundTransparency=1,Text=">>  booting...",Font=F.mono,TextSize=11,TextColor3=P.gn,TextXAlignment=Enum.TextXAlignment.Left,Parent=SB})
local sTR = N("TextLabel",{Size=UDim2.new(0.4,-10,1,0),Position=UDim2.new(0.6,0,0,0),BackgroundTransparency=1,Text="",Font=F.mono,TextSize=11,TextColor3=P.ac,TextXAlignment=Enum.TextXAlignment.Right,Parent=SB})

----------------------------------------------------------------
-- tabs
----------------------------------------------------------------
local pages, tabs = {}, {}
local current
local function selectTab(name)
    current = name
    for n,v in pairs(tabs) do
        v.btn.BackgroundColor3 = (n==name) and P.pn2 or P.pn
        v.lbl.TextColor3 = (n==name) and P.ac or P.dim
        v.mark.Visible = (n==name)
        pages[n].Visible = (n==name)
    end
end
local tabCount = 0
local function Tab(name,glyph)
    tabCount = tabCount + 1
    local num = string.format("%02d",tabCount)
    local b = N("TextButton",{Size=UDim2.new(1,0,0,22),BackgroundColor3=P.pn,BorderSizePixel=0,Text="",AutoButtonColor=false,Parent=TabCol})
    local mark = N("TextLabel",{Size=UDim2.fromOffset(10,22),BackgroundTransparency=1,Text=">",Font=F.mono,TextSize=12,TextColor3=P.ac,Visible=false,Parent=b})
    local lbl = N("TextLabel",{Size=UDim2.new(1,-10,1,0),Position=UDim2.fromOffset(10,0),BackgroundTransparency=1,Text=num.." "..(glyph or ".").." "..name,Font=F.mono,TextSize=11,TextColor3=P.dim,TextXAlignment=Enum.TextXAlignment.Left,Parent=b})
    local p = N("ScrollingFrame",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,ScrollBarThickness=3,ScrollBarImageColor3=P.ac,CanvasSize=UDim2.new(0,0,0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y,BorderSizePixel=0,Visible=false,Parent=Content})
    N("UIListLayout",{FillDirection=Enum.FillDirection.Horizontal,Wraps=true,Padding=UDim.new(0,6),Parent=p})
    pages[name]=p; tabs[name]={btn=b,lbl=lbl,mark=mark}
    b.MouseButton1Click:Connect(function() selectTab(name) end)
    return p
end

local function Group(parent,title,wide)
    local sz = wide and UDim2.new(1,0,0,0) or UDim2.new(0.5,-3,0,0)
    local w = N("Frame",{Size=sz,BackgroundColor3=P.pn,BorderSizePixel=0,AutomaticSize=Enum.AutomaticSize.Y,Parent=parent})
    brd(w,P.bd,1); pd(w,8,8,6,8)
    -- hand-drawn ascii header
    local head = N("Frame",{Size=UDim2.new(1,0,0,14),BackgroundTransparency=1,Parent=w})
    N("TextLabel",{Size=UDim2.fromOffset(12,14),BackgroundTransparency=1,Text="[",Font=F.mono,TextSize=11,TextColor3=P.ac,Parent=head})
    N("TextLabel",{Size=UDim2.new(1,-24,1,0),Position=UDim2.fromOffset(12,0),BackgroundTransparency=1,Text=" "..title.." ",Font=F.mono,TextSize=11,TextColor3=P.tx,TextXAlignment=Enum.TextXAlignment.Left,Parent=head})
    N("TextLabel",{Size=UDim2.fromOffset(12,14),Position=UDim2.new(1,-12,0,0),BackgroundTransparency=1,Text="]",Font=F.mono,TextSize=11,TextColor3=P.ac,Parent=head})
    local col = N("Frame",{Size=UDim2.new(1,0,0,0),Position=UDim2.new(0,0,0,18),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1,Parent=w})
    N("UIListLayout",{Padding=UDim.new(0,3),Parent=col})
    return col
end

----------------------------------------------------------------
-- widgets
----------------------------------------------------------------
local function Toggle(p,k,t,d)
    T[k]=d and true or false
    local r = N("TextButton",{Size=UDim2.new(1,0,0,17),BackgroundTransparency=1,Text="",AutoButtonColor=false,Parent=p})
    local bx = N("TextLabel",{Size=UDim2.fromOffset(13,13),Position=UDim2.fromOffset(0,2),BackgroundColor3=P.bg,BorderSizePixel=0,Text=T[k] and "+" or "-",Font=F.mono,TextSize=11,TextColor3=T[k] and P.ac or P.dim,Parent=r})
    brd(bx,P.bd,1)
    N("TextLabel",{Size=UDim2.new(1,-18,1,0),Position=UDim2.fromOffset(18,0),BackgroundTransparency=1,Text=t,Font=F.mono,TextSize=11,TextColor3=P.tx,TextXAlignment=Enum.TextXAlignment.Left,Parent=r})
    r.MouseButton1Click:Connect(function() T[k]=not T[k]; bx.Text=T[k] and "+" or "-"; bx.TextColor3=T[k] and P.ac or P.dim end)
end

local function Slider(p,k,t,d,mn,mx,st,sx)
    O[k]=d
    local r = N("Frame",{Size=UDim2.new(1,0,0,28),BackgroundTransparency=1,Parent=p})
    N("TextLabel",{Size=UDim2.new(1,-70,0,12),BackgroundTransparency=1,Text=t,Font=F.mono,TextSize=11,TextColor3=P.tx,TextXAlignment=Enum.TextXAlignment.Left,Parent=r})
    local vl = N("TextLabel",{Size=UDim2.fromOffset(70,12),Position=UDim2.new(1,-70,0,0),BackgroundTransparency=1,Text=tostring(d)..(sx or ""),Font=F.mono,TextSize=11,TextColor3=P.ac,TextXAlignment=Enum.TextXAlignment.Right,Parent=r})
    local bar = N("TextButton",{Size=UDim2.new(1,0,0,10),Position=UDim2.new(0,0,0,16),BackgroundColor3=P.bg,BorderSizePixel=0,Text="",AutoButtonColor=false,Parent=r})
    brd(bar,P.bd,1)
    local fill = N("Frame",{Size=UDim2.new((d-mn)/(mx-mn),0,1,0),BackgroundColor3=P.ac,BorderSizePixel=0,Parent=bar})
    local dr=false
    local function set(x)
        local rel=math.clamp((x-bar.AbsolutePosition.X)/bar.AbsoluteSize.X,0,1)
        local v=mn+(mx-mn)*rel; if st then v=math.floor(v/st+0.5)*st end; v=math.clamp(v,mn,mx)
        O[k]=v; fill.Size=UDim2.new(rel,0,1,0)
        vl.Text=((st and st>=1) and tostring(math.floor(v)) or string.format("%.2f",v))..(sx or "")
    end
    bar.MouseButton1Down:Connect(function() dr=true; set(UIS:GetMouseLocation().X) end)
    C(UIS.InputChanged:Connect(function(i) if dr and i.UserInputType==Enum.UserInputType.MouseMovement then set(i.Position.X) end end))
    C(UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dr=false end end))
    return function(v) O[k]=v; fill.Size=UDim2.new((v-mn)/(mx-mn),0,1,0); vl.Text=((st and st>=1) and tostring(math.floor(v)) or string.format("%.2f",v))..(sx or "") end
end

local function Dropdown(p,k,t,vs,d)
    O[k]=d
    local r = N("Frame",{Size=UDim2.new(1,0,0,30),BackgroundTransparency=1,Parent=p})
    N("TextLabel",{Size=UDim2.new(1,0,0,12),BackgroundTransparency=1,Text=t,Font=F.mono,TextSize=11,TextColor3=P.tx,TextXAlignment=Enum.TextXAlignment.Left,Parent=r})
    local b = N("TextButton",{Size=UDim2.new(1,0,0,14),Position=UDim2.new(0,0,0,14),BackgroundColor3=P.bg,BorderSizePixel=0,Text="  <"..d..">",Font=F.mono,TextSize=11,TextColor3=P.ac,TextXAlignment=Enum.TextXAlignment.Left,AutoButtonColor=false,Parent=r})
    brd(b,P.bd,1)
    local idx=1; for i,v in ipairs(vs) do if v==d then idx=i; break end end
    b.MouseButton1Click:Connect(function() idx=(idx%#vs)+1; O[k]=vs[idx]; b.Text="  <"..vs[idx]..">" end)
    b.MouseButton2Click:Connect(function() idx=((idx-2)%#vs)+1; O[k]=vs[idx]; b.Text="  <"..vs[idx]..">" end)
end

local function Keybind(p,k,t,dk)
    K[k]={k=dk,mode="Hold",state=false,tog=false}
    local r = N("Frame",{Size=UDim2.new(1,0,0,17),BackgroundTransparency=1,Parent=p})
    N("TextLabel",{Size=UDim2.new(1,-120,1,0),BackgroundTransparency=1,Text=t,Font=F.mono,TextSize=11,TextColor3=P.tx,TextXAlignment=Enum.TextXAlignment.Left,Parent=r})
    local function nm(x) return (typeof(x)=="EnumItem") and x.Name or tostring(x) end
    local kb = N("TextButton",{Size=UDim2.fromOffset(60,15),Position=UDim2.new(1,-120,0,1),BackgroundColor3=P.bg,BorderSizePixel=0,Text="["..nm(dk).."]",Font=F.mono,TextSize=10,TextColor3=P.ac,AutoButtonColor=false,Parent=r})
    brd(kb,P.bd,1)
    local mb = N("TextButton",{Size=UDim2.fromOffset(56,15),Position=UDim2.new(1,-58,0,1),BackgroundColor3=P.bg,BorderSizePixel=0,Text="HOLD",Font=F.mono,TextSize=10,TextColor3=P.gn,AutoButtonColor=false,Parent=r})
    brd(mb,P.bd,1)
    local picking=false
    kb.MouseButton1Click:Connect(function() picking=true; kb.Text="[...]" end)
    C(UIS.InputBegan:Connect(function(i,gp)
        if picking then
            if i.UserInputType==Enum.UserInputType.Keyboard then K[k].k=i.KeyCode
            elseif i.UserInputType==Enum.UserInputType.MouseButton1 then K[k].k="MB1"
            elseif i.UserInputType==Enum.UserInputType.MouseButton2 then K[k].k="MB2" end
            kb.Text="["..nm(K[k].k).."]"; picking=false; return
        end
        if gp then return end
        local kk=K[k]; local m=(kk.k=="MB1" and i.UserInputType==Enum.UserInputType.MouseButton1) or (kk.k=="MB2" and i.UserInputType==Enum.UserInputType.MouseButton2) or (typeof(kk.k)=="EnumItem" and i.KeyCode==kk.k)
        if m then if kk.mode=="Hold" then kk.state=true elseif kk.mode=="Toggle" then kk.tog=not kk.tog; kk.state=kk.tog end end
    end))
    C(UIS.InputEnded:Connect(function(i) local kk=K[k]; local m=(kk.k=="MB1" and i.UserInputType==Enum.UserInputType.MouseButton1) or (kk.k=="MB2" and i.UserInputType==Enum.UserInputType.MouseButton2) or (typeof(kk.k)=="EnumItem" and i.KeyCode==kk.k); if m and kk.mode=="Hold" then kk.state=false end end))
    mb.MouseButton1Click:Connect(function() local nx={Hold="Toggle",Toggle="Always",Always="Hold"}; K[k].mode=nx[K[k].mode]; mb.Text=string.upper(K[k].mode); K[k].state=(K[k].mode=="Always") end)
end

local function Button(p,t,cb)
    local b = N("TextButton",{Size=UDim2.new(1,0,0,17),BackgroundColor3=P.bg,BorderSizePixel=0,Text="  >>  "..t.."  <<",Font=F.mono,TextSize=11,TextColor3=P.ac,AutoButtonColor=false,Parent=p})
    brd(b,P.bd,1)
    b.MouseEnter:Connect(function() b.BackgroundColor3=P.pn2 end)
    b.MouseLeave:Connect(function() b.BackgroundColor3=P.bg end)
    b.MouseButton1Click:Connect(cb)
end

local function Label(p,t,c) return N("TextLabel",{Size=UDim2.new(1,0,0,12),BackgroundTransparency=1,Text=t,Font=F.mono,TextSize=11,TextColor3=c or P.dim,TextXAlignment=Enum.TextXAlignment.Left,Parent=p}) end
local function Divider(p,t) local r=N("Frame",{Size=UDim2.new(1,0,0,10),BackgroundTransparency=1,Parent=p}); N("TextLabel",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text=".."..(t or "")..string.rep(".",40),Font=F.mono,TextSize=10,TextColor3=P.dim,TextXAlignment=Enum.TextXAlignment.Left,Parent=r}) end

local ACCENTS = {
    {name="orange",c=Color3.fromRGB(255,120,60)},
    {name="pink",c=Color3.fromRGB(255,80,180)},
    {name="purple",c=Color3.fromRGB(180,100,255)},
    {name="green",c=Color3.fromRGB(130,220,120)},
    {name="cyan",c=Color3.fromRGB(0,200,255)},
    {name="red",c=Color3.fromRGB(230,80,80)},
    {name="amber",c=Color3.fromRGB(255,176,0)},
    {name="white",c=Color3.fromRGB(230,230,240)},
    {name="blue",c=Color3.fromRGB(110,180,255)},
}
local accentIdx = 1
local function applyAccent()
    local c = ACCENTS[accentIdx].c
    P.ac = c
    for _,d in ipairs(Root:GetDescendants()) do
        if d:IsA("TextLabel") or d:IsA("TextButton") then
            if d.TextColor3==P.ac or d.TextColor3.R>0.9 and d.TextColor3.G>0.4 and d.TextColor3.B<0.3 then
                -- leave non-accent elements alone; we repaint via refresh
            end
        end
    end
    -- just refresh the strongest spots
    TtlC.TextColor3=c
end

----------------------------------------------------------------
-- tabs built
----------------------------------------------------------------
do local p = Tab("home",".")
    local g=Group(p,"welcome",true)
    Label(g,"//  unnamed enhancements v8",P.ac)
    Label(g,"//  built by olivia")
    Label(g,"//  discord.gg/ojailbreaks",P.ac)
    Divider(g,".notes")
    Label(g,"menu toggle: RightShift. close via [x] in corner.",P.tx)
    Label(g,"right-click a dropdown to cycle backwards.",P.tx)
    Label(g,"all engines gated by their master toggle.",P.tx)
    Label(g,"save/load configs in the config tab.",P.tx)
end

do local p = Tab("ragebot","#")
    local g=Group(p,"core")
    Toggle(g,"RageOn","master",false)
    Toggle(g,"Silent","silent aim",true)
    Toggle(g,"AutoFire","auto fire",false)
    Toggle(g,"AutoScope","auto scope",true)
    Toggle(g,"AutoStop","auto stop (zero velocity)",false)
    Toggle(g,"AutoCrouch","auto crouch on shot",false)
    Slider(g,"Fov","fov",120,10,500,5,"px")
    Slider(g,"MaxDist","max distance",2000,50,5000,10,"s")
    Slider(g,"FireRate","shots/sec",10,1,40,1)
    Dropdown(g,"KeyMode","key mode",{"Always","Hold","Toggle"},"Hold")
    Keybind(g,"RageKey","aim key","MB2")

    local g2=Group(p,"target")
    Dropdown(g2,"Prio","priority",{"FOV","Distance","Health","Crosshair","Random"},"FOV")
    Toggle(g2,"VisOnly","visible only",false)
    Toggle(g2,"IgnTeam","ignore team",true)
    Toggle(g2,"IgnFriend","ignore friends",true)
    Toggle(g2,"LockTgt","lock target",false)
    Slider(g2,"SwitchDly","switch delay",0.05,0,1,0.01,"s")
    Slider(g2,"KillDly","kill delay",0,0,1,0.01,"s")

    local g3=Group(p,"hitbox")
    Dropdown(g3,"HB","hitbox",{"Head","UpperTorso","Torso","HumanoidRootPart","MultiScan","Nearest"},"Head")
    Slider(g3,"WtHead","weight head",10,0,10,1)
    Slider(g3,"WtChest","weight chest",6,0,10,1)
    Slider(g3,"WtPelvis","weight pelvis",4,0,10,1)
    Slider(g3,"WtLimbs","weight limbs",2,0,10,1)
    Toggle(g3,"ForceHS","force headshot",false)
    Toggle(g3,"ForceBaim","force body aim",false)

    local g4=Group(p,"prediction / BT")
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

do local p = Tab("anti-aim","<")
    local g=Group(p,"master")
    Toggle(g,"AAOn","anti-aim",false)
    Dropdown(g,"AABase","base",{"Backwards","Target","AtTarget","Freestand","Local","Zero"},"AtTarget")
    Dropdown(g,"AAYaw","yaw modifier",{"None","Spin","Jitter","Random","Sway","3way","Offset"},"Jitter")
    Slider(g,"AAYawDeg","yaw deg",90,0,180,1,"°")
    Slider(g,"AAYawHz","yaw speed",8,0.1,30,0.1,"hz")
    Slider(g,"AADesync","desync",58,0,60,1,"°")
    Keybind(g,"AAInvert","invert",Enum.KeyCode.X)

    local g2=Group(p,"per-state")
    Label(g2,"different mode per movement state")
    Dropdown(g2,"AASt","standing",{"Inherit","Backwards","Jitter","Spin","Sideways","Zero"},"Inherit")
    Dropdown(g2,"AAMv","moving",{"Inherit","Backwards","Jitter","Spin","Sideways","Zero"},"Inherit")
    Dropdown(g2,"AAAir","in air",{"Inherit","Backwards","Jitter","Spin","Sideways","Zero"},"Zero")
    Dropdown(g2,"AACr","crouching",{"Inherit","Backwards","Jitter","Spin","Sideways","Zero"},"Inherit")

    local g3=Group(p,"pitch / roll")
    Toggle(g3,"AAPOn","pitch",true)
    Dropdown(g3,"AAPitch","pitch",{"Down","Up","Zero","Jitter","Fake","Random"},"Down")
    Slider(g3,"AAPDeg","pitch deg",89,0,89,1,"°")
    Dropdown(g3,"AARoll","roll",{"None","Left","Right","Alternate","Sway"},"None")
    Slider(g3,"AARDeg","roll deg",30,0,180,1,"°")

    local g4=Group(p,"advanced")
    Toggle(g4,"LBY","LBY breaker",true)
    Toggle(g4,"BodyYaw","body yaw",true)
    Slider(g4,"BodyDeg","body yaw deg",90,0,180,1,"°")
    Toggle(g4,"Micro","micro jitter",true)
    Slider(g4,"MicroDeg","micro deg",3,0,15,1,"°")
    Toggle(g4,"OnShot","on-shot flip",true)
    Slider(g4,"OnShotMs","on-shot ms",220,50,1000,10,"ms")
    Toggle(g4,"Defensive","defensive AA",true)
    Toggle(g4,"AAArrow","arrow HUD",true)

    local g5=Group(p,"manual")
    Toggle(g5,"ManOn","manual enable",false)
    Keybind(g5,"ManL","manual left",Enum.KeyCode.Left)
    Keybind(g5,"ManR","manual right",Enum.KeyCode.Right)
    Keybind(g5,"ManB","manual back",Enum.KeyCode.Down)
    Keybind(g5,"ManF","manual forward",Enum.KeyCode.Up)
end

do local p = Tab("fake pos","~")
    local g=Group(p,"engine")
    Toggle(g,"FPOn","fake position",false)
    Dropdown(g,"FPE","engine",{"Static","Orbit","OrbitDual","Random","Behind","Teleport","Zigzag","Figure8","PathReplay","Mirror","PingTP","Split","ChokeFreeze","Warp"},"OrbitDual")
    Slider(g,"FPR","radius",10,1,80,1,"s")
    Slider(g,"FPH","height",0,-20,20,0.5,"s")
    Slider(g,"FPSp","speed",3,0,30,0.1)
    Toggle(g,"FPDual","dual ghost",true)
    Slider(g,"FPAlpha","ghost alpha",0.45,0,1,0.05)
    Dropdown(g,"FPCol","ghost color",{"accent","rainbow","white","red","cyan"},"accent")
    Keybind(g,"FPKey","toggle key",Enum.KeyCode.V)
    local g2=Group(p,"extras")
    Slider(g2,"FPReplay","replay lag",350,50,1500,10,"ms")
    Toggle(g2,"FPBlink","blink teleport",false)
    Keybind(g2,"FPBlinkK","blink key",Enum.KeyCode.G)
    Slider(g2,"FPBlinkD","blink dist",8,2,40,1,"s")
    Toggle(g2,"FPFreezePeek","freeze on peek",false)
    Toggle(g2,"FPTrail","ghost trail",false)
end

do local p = Tab("voidspam","v")
    local g=Group(p,"master",true)
    Label(g,"voidspam = rapid HRP teleport around target to break",P.dim)
    Label(g,"their collision/network — voids them or spam-lags their aim.",P.dim)
    Divider(g,".config")
    Toggle(g,"VoidOn","voidspam master",false)
    Dropdown(g,"VoidMode","spam mode",{"OnTarget","OnMouse","OnNearest","Chaos","Ring","Shake"},"OnTarget")
    Slider(g,"VoidRad","radius",6,1,30,0.5,"s")
    Slider(g,"VoidRate","spams/sec",30,1,120,1)
    Slider(g,"VoidCount","points per spam",4,1,16,1)
    Slider(g,"VoidYaw","yaw jitter per tick",30,0,180,1,"°")
    Toggle(g,"VoidDown","drop to y=0 pulse",false)
    Toggle(g,"VoidReturn","return to real pos after",true)
    Slider(g,"VoidReturnMs","return delay",50,10,500,5,"ms")
    Toggle(g,"VoidInvisible","invisibility pulse",false)
    Toggle(g,"VoidRagdoll","ragdoll trigger",false)
    Toggle(g,"VoidNoclip","noclip during spam",true)
    Keybind(g,"VoidKey","voidspam key",Enum.KeyCode.Z)
    Dropdown(g,"VoidKeyMode","key mode",{"Hold","Toggle","Always"},"Hold")
    Divider(g,".safety")
    Toggle(g,"VoidKillCheck","stop on target death",true)
    Slider(g,"VoidMaxMs","max duration",3000,100,10000,100,"ms")
end

do local p = Tab("esp","*")
    local g=Group(p,"visible")
    Toggle(g,"EspOn","esp master",false)
    Toggle(g,"EspBox","box",true)
    Dropdown(g,"EspBoxS","box style",{"full","corner","rounded","3d"},"corner")
    Toggle(g,"EspName","name",true)
    Toggle(g,"EspDist","distance",true)
    Toggle(g,"EspHealth","health bar",true)
    Toggle(g,"EspHealthT","health text",false)
    Toggle(g,"EspTeam","show team",false)
    Toggle(g,"EspTracer","tracer",false)
    Dropdown(g,"EspTracerO","tracer origin",{"bottom","top","mouse","center"},"bottom")
    Toggle(g,"EspSkel","skeleton",false)
    Toggle(g,"EspHeadDot","head dot",false)
    Toggle(g,"EspHeadCir","head circle",false)
    Toggle(g,"EspSnap","snapline (to target)",false)
    Toggle(g,"EspOff","offscreen arrow",true)
    Toggle(g,"EspRainbow","rainbow",false)
    Slider(g,"EspFont","font size",13,8,22,1)

    local g2=Group(p,"chams")
    Toggle(g2,"ChamsOn","chams master",false)
    Dropdown(g2,"ChamsMat","material",{"ForceField","Neon","Plastic","Glass","Metal"},"ForceField")
    Slider(g2,"ChamsFill","fill transparency",0.4,0,1,0.05)
    Dropdown(g2,"ChamsCol","enemy color",{"red","pink","purple","cyan","white","green","orange"},"red")
    Toggle(g2,"ChamsVis","visible color swap",true)
    Dropdown(g2,"ChamsVisCol","visible color",{"green","cyan","white","amber"},"green")
end

do local p = Tab("movement","^")
    local g=Group(p,"speed / jump")
    Toggle(g,"WsOn","walkspeed",false)
    Slider(g,"Ws","value",50,16,500,1)
    Toggle(g,"JpOn","jumppower",false)
    Slider(g,"Jp","value",80,50,1000,1)
    Toggle(g,"Bhop","bunnyhop",false)
    Toggle(g,"InfJump","infinite jump",false)
    Toggle(g,"Noclip","noclip",false)
    local g2=Group(p,"fly")
    Toggle(g2,"Fly","fly",false)
    Slider(g2,"FlySpd","fly speed",50,5,300,1)
    Keybind(g2,"FlyKey","fly toggle",Enum.KeyCode.F)
end

do local p = Tab("world","w")
    local g=Group(p,"environment")
    Toggle(g,"NoFog","no fog",false)
    Toggle(g,"FB","fullbright",false)
    Slider(g,"FBV","brightness",2,0,10,0.1)
    Toggle(g,"RemParticles","remove particles",false)
    Toggle(g,"TimeLock","lock time (noon)",false)
    local g2=Group(p,"camera")
    Toggle(g2,"CFov","camera fov",false)
    Slider(g2,"CFovV","fov value",70,1,120,1)
    Toggle(g2,"TP","third person",false)
    Slider(g2,"TPDist","3p distance",12,2,40,1)
end

do local p = Tab("ui","U")
    local g=Group(p,"customize",true)
    Button(g,"cycle accent color",function()
        accentIdx = accentIdx%#ACCENTS + 1
        applyAccent()
        sTR.Text="accent: "..ACCENTS[accentIdx].name
    end)
    Slider(g,"MenuAlpha","menu opacity",1,0.3,1,0.05)
    Slider(g,"MenuScale","menu scale",1,0.6,1.4,0.05)
    Keybind(g,"MenuKey","menu toggle",Enum.KeyCode.RightShift)
    Toggle(g,"WaterMark","watermark",true)
    Toggle(g,"StatusHUD","status hud",true)
    Toggle(g,"FovRing","fov ring",true)
end

do local p = Tab("config","$")
    local g=Group(p,"save/load",true)
    Label(g,"configs save to your executor workspace folder")
    Button(g,"save 'default'",function()
        if not writefile then return end
        local d={O={},T={}}
        for k,v in pairs(O) do if type(v)~="function" then d.O[k]=v end end
        for k,v in pairs(T) do d.T[k]=v end
        pc(writefile,"UEV8_default.json",HttpService:JSONEncode(d))
        sTL.Text=">>  config saved"
    end)
    Button(g,"load 'default'",function()
        if not (isfile and isfile("UEV8_default.json")) then sTL.Text=">>  no config"; return end
        local ok,d=pcall(function() return HttpService:JSONDecode(readfile("UEV8_default.json")) end)
        if ok and d then for k,v in pairs(d.O or {}) do O[k]=v end; for k,v in pairs(d.T or {}) do T[k]=v end; sTL.Text=">>  config loaded" end
    end)
    Button(g,"unload script",function() U.Unload() end)
end

selectTab("home")
local scl = N("UIScale",{Scale=1,Parent=Root})

----------------------------------------------------------------
-- core
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

local COL = {red=Color3.fromRGB(255,60,80),pink=Color3.fromRGB(255,80,180),purple=Color3.fromRGB(180,100,255),cyan=Color3.fromRGB(0,200,255),white=Color3.new(1,1,1),green=Color3.fromRGB(100,230,120),orange=Color3.fromRGB(255,140,0),amber=Color3.fromRGB(255,176,0),accent=function() return P.ac end,rainbow=function() return Color3.fromHSV((os.clock()*0.3)%1,0.9,1) end}
local function col(name) local v=COL[name]; if type(v)=="function" then return v() end; return v or P.ac end

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
-- aim target + silent aim
----------------------------------------------------------------
local aimPos, curTarget = nil, nil

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
                        elseif prio=="Health" then local h=p.Character:FindFirstChildOfClass("Humanoid"); sc=h and h.Health or 100
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

local lastSwitch,lastKillAt = 0,0
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

-- metatable hook (only reliable silent-aim path)
local lastShotAt = 0
local function doFire()
    local now=os.clock(); local rate=1/(O.FireRate or 10)
    if now-lastShotAt<rate then return end; lastShotAt=now
    Sum.shots+=1
    pc(function() local t=LP.Character and LP.Character:FindFirstChildOfClass("Tool"); if t then t:Activate() end end)
    pc(function() if mouse1press then mouse1press(); task.wait(); mouse1release() end end)
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

local function fireTick() if T.RageOn and T.AutoFire and curTarget and aimPos then doFire() end end

----------------------------------------------------------------
-- anti-aim
----------------------------------------------------------------
local onShotUntil, defUntil, aaSide = 0,0,1
local function getState()
    if not alive(LP) then return "none" end
    local h=LP.Character:FindFirstChildOfClass("Humanoid"); if not h then return "none" end
    local s=h:GetState()
    if s==Enum.HumanoidStateType.Freefall or s==Enum.HumanoidStateType.Jumping then return "Air" end
    if h:GetAttribute("Crouching") then return "Crouch" end
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

local realDesyncYaw=0
local function aaTick()
    if not T.AAOn then return end
    if not alive(LP) then return end
    local hrp=LP.Character.HumanoidRootPart; local hum=LP.Character:FindFirstChildOfClass("Humanoid")
    if hum then pc(function() hum.AutoRotate=false end) end
    local y,p,r = 0,0,0
    local ov = stateMode()
    local base = ov or O.AABase
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

local lastDoFireOrig=doFire
doFire=function() local ok=lastDoFireOrig(); onShotUntil=os.clock()+(O.OnShotMs or 220)/1000; defUntil=os.clock()+0.3; return ok end

----------------------------------------------------------------
-- fake position
----------------------------------------------------------------
local function ghost(key,c) local g=U.Ghost[key]; if g and g.Parent then return g end; g=Instance.new("Part"); g.Size=Vector3.new(2,5,1); g.Anchored=true; g.CanCollide=false; g.Material=Enum.Material.ForceField; g.Color=c or P.ac; g.Transparency=0.4; pc(function() g.Parent=Workspace end); U.Ghost[key]=g; return g end
local function killGhost(k) if U.Ghost[k] then pc(function() U.Ghost[k]:Destroy() end); U.Ghost[k]=nil end end

local frozenAt
local function fpTick()
    if not T.FPOn then killGhost("g1"); killGhost("g2"); frozenAt=nil; return end
    if not alive(LP) then return end
    local hrp=LP.Character.HumanoidRootPart; local e=O.FPE; local R=O.FPR or 10; local H=O.FPH or 0; local t=os.clock()*(O.FPSp or 3)
    local p1,p2
    if e=="Static" then p1=hrp.Position+Vector3.new(R,H,0); p2=hrp.Position-Vector3.new(R,H,0)
    elseif e=="Orbit" then p1=hrp.Position+Vector3.new(math.cos(t)*R,H,math.sin(t)*R); p2=p1
    elseif e=="OrbitDual" then p1=hrp.Position+Vector3.new(math.cos(t)*R,H,math.sin(t)*R); p2=hrp.Position+Vector3.new(math.cos(t+math.pi)*R,H,math.sin(t+math.pi)*R)
    elseif e=="Random" then p1=hrp.Position+Vector3.new((math.random()*2-1)*R,H,(math.random()*2-1)*R); p2=hrp.Position-(p1-hrp.Position)
    elseif e=="Behind" then p1=hrp.Position-hrp.CFrame.LookVector*R+Vector3.new(0,H,0); p2=p1
    elseif e=="Teleport" then p1=hrp.Position+((math.floor(t*2)%2==0) and Vector3.new(R,H,0) or Vector3.new(-R,H,0)); p2=p1
    elseif e=="Zigzag" then p1=hrp.Position+Vector3.new(math.sin(t*3)*R,H,math.cos(t)*R); p2=p1
    elseif e=="Figure8" then p1=hrp.Position+Vector3.new(math.sin(t)*R,H,math.sin(t*2)*R*0.5); p2=hrp.Position-(p1-hrp.Position)
    elseif e=="PathReplay" then local rec=self_bt(O.FPReplay or 350); p1 = rec and rec.cf.Position or hrp.Position; p2=hrp.Position+Vector3.new(math.cos(t)*R*0.5,H,math.sin(t)*R*0.5)
    elseif e=="Mirror" then if curTarget and alive(curTarget) then local Tp=curTarget.Character.HumanoidRootPart.Position; p1=Tp*2-hrp.Position+Vector3.new(0,H,0); p2=hrp.Position+(hrp.Position-Tp).Unit*R+Vector3.new(0,H,0) else p1=hrp.Position+Vector3.new(R,H,0); p2=hrp.Position-Vector3.new(R,H,0) end
    elseif e=="PingTP" then local ph=math.floor(t*2)%3; p1 = (ph==0 and hrp.Position+Vector3.new(R,H,0)) or (ph==1 and hrp.Position+Vector3.new(0,H,R)) or hrp.Position-Vector3.new(R,H,0); p2=hrp.Position-(p1-hrp.Position)
    elseif e=="Split" then p1=hrp.Position+Vector3.new(R,H,R); p2=hrp.Position+Vector3.new(-R,H,-R)
    elseif e=="ChokeFreeze" then frozenAt = frozenAt or hrp.Position; p1=frozenAt; p2=hrp.Position+Vector3.new(math.cos(t)*R,H,math.sin(t)*R)
    elseif e=="Warp" then p1=hrp.Position+hrp.CFrame.LookVector*R+Vector3.new(0,H,0); p2=hrp.Position-hrp.CFrame.LookVector*R+Vector3.new(0,H,0) end
    if T.FPBlink and K.FPBlinkK.state then p1 = p1 + hrp.CFrame.RightVector*(O.FPBlinkD or 8) end
    if e~="ChokeFreeze" then frozenAt=nil end
    local c = col(O.FPCol or "accent")
    local g1=ghost("g1",c); pc(function() g1.CFrame=CFrame.new(p1); g1.Transparency=O.FPAlpha or 0.45; g1.Color=c end)
    if T.FPDual and p2 then local g2=ghost("g2",c:Lerp(Color3.new(1,1,1),0.3)); pc(function() g2.CFrame=CFrame.new(p2); g2.Transparency=(O.FPAlpha or 0.45)*0.9 end) else killGhost("g2") end
end

----------------------------------------------------------------
-- VOIDSPAM
----------------------------------------------------------------
local voidActiveUntil, voidStartedAt, voidRealPos = 0,0,nil
local function voidActive()
    if not T.VoidOn then return false end
    local kk=K.VoidKey; local m=O.VoidKeyMode or "Hold"
    if m=="Hold" then return kk.state end
    if m=="Toggle" then return kk.state end
    if m=="Always" then return true end
    return false
end

local function voidTick()
    if not alive(LP) then return end
    local on = voidActive()
    local hrp = LP.Character.HumanoidRootPart
    local hum = LP.Character:FindFirstChildOfClass("Humanoid")
    if on then
        if voidStartedAt==0 then voidStartedAt=os.clock(); voidRealPos=hrp.Position end
        if os.clock()-voidStartedAt>(O.VoidMaxMs/1000) then return end
        local target
        if O.VoidMode=="OnTarget" then target=curTarget and alive(curTarget) and curTarget.Character.HumanoidRootPart.Position or hrp.Position
        elseif O.VoidMode=="OnMouse" then local m=UIS:GetMouseLocation(); local ray=Camera:ViewportPointToRay(m.X,m.Y,0); local rp=RaycastParams.new(); rp.FilterDescendantsInstances={LP.Character,Camera}; rp.FilterType=Enum.RaycastFilterType.Exclude; local r=Workspace:Raycast(ray.Origin,ray.Direction*500,rp); target=(r and r.Position) or (ray.Origin+ray.Direction*100)
        elseif O.VoidMode=="OnNearest" then local best,bd; for _,p in ipairs(Players:GetPlayers()) do if p~=LP and alive(p) and enemy(p) then local pos=p.Character.HumanoidRootPart.Position; local d=(pos-hrp.Position).Magnitude; if not bd or d<bd then bd,best=d,pos end end end; target=best or hrp.Position
        elseif O.VoidMode=="Chaos" then target=hrp.Position+Vector3.new((math.random()*2-1)*50,0,(math.random()*2-1)*50)
        elseif O.VoidMode=="Ring" then local a=os.clock()*8; target=hrp.Position+Vector3.new(math.cos(a)*O.VoidRad,0,math.sin(a)*O.VoidRad)
        elseif O.VoidMode=="Shake" then target=hrp.Position end
        if T.VoidKillCheck and O.VoidMode=="OnTarget" and (not curTarget or not alive(curTarget)) then return end
        -- noclip during
        if T.VoidNoclip then for _,d in ipairs(LP.Character:GetDescendants()) do if d:IsA("BasePart") then pc(function() d.CanCollide=false end) end end end
        -- invisibility
        if T.VoidInvisible then for _,d in ipairs(LP.Character:GetDescendants()) do if d:IsA("BasePart") and d~=hrp then pc(function() d.LocalTransparencyModifier=1 end) end end end
        -- ragdoll
        if T.VoidRagdoll and hum then pc(function() hum:ChangeState(Enum.HumanoidStateType.Physics) end) end
        -- spam teleports
        local n = O.VoidCount or 4
        for i=1,n do
            local yaw = math.rad(math.random(-O.VoidYaw,O.VoidYaw))
            local rad = O.VoidRad * (0.5+math.random())
            local pos = target + Vector3.new(math.cos(yaw)*rad, (T.VoidDown and -5 or 0), math.sin(yaw)*rad)
            pc(function() hrp.CFrame = CFrame.new(pos) end)
        end
        if T.VoidReturn and voidRealPos then
            task.delay((O.VoidReturnMs or 50)/1000, function() if alive(LP) and not voidActive() then pc(function() LP.Character.HumanoidRootPart.CFrame = CFrame.new(voidRealPos) end) end end)
        end
    else
        if voidStartedAt~=0 then
            -- end of spam — restore
            if T.VoidInvisible and alive(LP) then for _,d in ipairs(LP.Character:GetDescendants()) do if d:IsA("BasePart") then pc(function() d.LocalTransparencyModifier=0 end) end end end
            if voidRealPos and alive(LP) and T.VoidReturn then pc(function() LP.Character.HumanoidRootPart.CFrame=CFrame.new(voidRealPos) end) end
            voidStartedAt=0; voidRealPos=nil
        end
    end
end

----------------------------------------------------------------
-- movement / world (unchanged essentials)
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
-- ESP (same backbone as v7 minus a few additions)
----------------------------------------------------------------
local SKEL={ {"Head","UpperTorso"},{"UpperTorso","LowerTorso"},{"UpperTorso","LeftUpperArm"},{"LeftUpperArm","LeftLowerArm"},{"UpperTorso","RightUpperArm"},{"RightUpperArm","RightLowerArm"},{"LowerTorso","LeftUpperLeg"},{"LeftUpperLeg","LeftLowerLeg"},{"LowerTorso","RightUpperLeg"},{"RightUpperLeg","RightLowerLeg"} }
local function ensureEsp(p) local e=U.Esp[p]; if e then return e end
    e={bones={},corners={}}
    local hl=Instance.new("Highlight"); hl.FillTransparency=0.5; hl.Enabled=false; pc(function() hl.Parent=Workspace end); e.hl=hl
    e.box=D(Drawing.new("Square")); e.box.Thickness=1; e.box.Filled=false; e.box.Visible=false
    for i=1,8 do e.corners[i]=D(Drawing.new("Line")); e.corners[i].Thickness=1; e.corners[i].Visible=false end
    e.name=D(Drawing.new("Text")); e.name.Size=13; e.name.Center=true; e.name.Outline=true; e.name.Visible=false; e.name.Font=2
    e.dist=D(Drawing.new("Text")); e.dist.Size=12; e.dist.Center=true; e.dist.Outline=true; e.dist.Visible=false; e.dist.Font=2
    e.team=D(Drawing.new("Text")); e.team.Size=11; e.team.Center=true; e.team.Outline=true; e.team.Visible=false; e.team.Font=2
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
local function hideEsp(e) e.box.Visible=false; for i=1,8 do e.corners[i].Visible=false end; e.name.Visible=false; e.dist.Visible=false; e.team.Visible=false; e.hpbg.Visible=false; e.hp.Visible=false; e.hpt.Visible=false; e.tracer.Visible=false; e.dot.Visible=false; e.circ.Visible=false; e.arrow.Visible=false; for i=1,#SKEL do e.bones[i].Visible=false end; if e.hl then pc(function() e.hl.Enabled=false; e.hl.Adornee=nil end) end end
local function destroyEsp(p) local e=U.Esp[p]; if not e then return end; pc(function() e.hl:Destroy() end); hideEsp(e); U.Esp[p]=nil end
C(Players.PlayerRemoving:Connect(destroyEsp))
C(Players.PlayerAdded:Connect(function(p) p.CharacterRemoving:Connect(function() local e=U.Esp[p]; if e then hideEsp(e) end end) end))
for _,p in ipairs(Players:GetPlayers()) do if p~=LP then p.CharacterRemoving:Connect(function() local e=U.Esp[p]; if e then hideEsp(e) end end) end end

local function espTick()
    if not T.EspOn and not T.ChamsOn then for _,e in pairs(U.Esp) do hideEsp(e) end; return end
    local rainbow = T.EspRainbow and Color3.fromHSV((os.clock()*0.3)%1,0.9,1)
    for _,pl in ipairs(Players:GetPlayers()) do if pl~=LP then
        local e=ensureEsp(pl)
        if not alive(pl) then hideEsp(e) else
            local isEn=enemy(pl); local show = T.EspOn and (isEn or T.EspTeam); local showC = T.ChamsOn and (isEn or T.EspTeam)
            local c = rainbow or COL[O.ChamsCol] or P.rd
            if not isEn then c=P.bl end
            local ch=pl.Character; local hrp=ch.HumanoidRootPart; local head=ch:FindFirstChild("Head") or hrp; local hum=ch:FindFirstChildOfClass("Humanoid")
            if show then
                local s1,o1=w2s(head.Position+Vector3.new(0,0.5,0)); local s2,o2=w2s(hrp.Position+Vector3.new(0,-3,0))
                if o1 and o2 then
                    local h=s2.Y-s1.Y; local w=h*0.55; local x,y=s1.X-w/2,s1.Y
                    if T.EspBox then
                        local st=O.EspBoxS
                        if st=="full" or st=="rounded" then e.box.Visible=true; e.box.Size=Vector2.new(w,h); e.box.Position=Vector2.new(x,y); e.box.Color=c; for i=1,8 do e.corners[i].Visible=false end
                        elseif st=="corner" then e.box.Visible=false; local cl=w*0.3
                            local pts={{Vector2.new(x,y),Vector2.new(x+cl,y)},{Vector2.new(x,y),Vector2.new(x,y+cl)},{Vector2.new(x+w,y),Vector2.new(x+w-cl,y)},{Vector2.new(x+w,y),Vector2.new(x+w,y+cl)},{Vector2.new(x,y+h),Vector2.new(x+cl,y+h)},{Vector2.new(x,y+h),Vector2.new(x,y+h-cl)},{Vector2.new(x+w,y+h),Vector2.new(x+w-cl,y+h)},{Vector2.new(x+w,y+h),Vector2.new(x+w,y+h-cl)}}
                            for i=1,8 do e.corners[i].Visible=true; e.corners[i].From=pts[i][1]; e.corners[i].To=pts[i][2]; e.corners[i].Color=c end
                        else e.box.Visible=true; e.box.Size=Vector2.new(w,h); e.box.Position=Vector2.new(x,y); e.box.Color=c; for i=1,8 do e.corners[i].Visible=false end end
                    else e.box.Visible=false; for i=1,8 do e.corners[i].Visible=false end end
                    if T.EspName then e.name.Visible=true; e.name.Text=pl.Name; e.name.Size=O.EspFont or 13; e.name.Position=Vector2.new(s1.X,s1.Y-(O.EspFont or 13)-2); e.name.Color=c else e.name.Visible=false end
                    if T.EspDist then e.dist.Visible=true; e.dist.Text=string.format("[%ds]",math.floor((hrp.Position-Camera.CFrame.Position).Magnitude)); e.dist.Position=Vector2.new(s1.X,s2.Y+2); e.dist.Color=c else e.dist.Visible=false end
                    if T.EspTeam and pl.Team then e.team.Visible=true; e.team.Text="<"..pl.Team.Name..">"; e.team.Position=Vector2.new(s1.X,s2.Y+16); e.team.Color=c else e.team.Visible=false end
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
                        e.tracer.From=src; e.tracer.To=Vector2.new(s2.X,s2.Y); e.tracer.Color=c
                    else e.tracer.Visible=false end
                    if T.EspHeadDot then local hs,hon=w2s(head.Position); if hon then e.dot.Visible=true; e.dot.Position=hs; e.dot.Radius=3; e.dot.Color=c else e.dot.Visible=false end else e.dot.Visible=false end
                    if T.EspHeadCir then local hs,hon=w2s(head.Position); if hon then e.circ.Visible=true; e.circ.Position=hs; e.circ.Radius=h*0.09; e.circ.Color=c else e.circ.Visible=false end else e.circ.Visible=false end
                    if T.EspSkel then for i,pair in ipairs(SKEL) do local a=ch:FindFirstChild(pair[1]); local b=ch:FindFirstChild(pair[2]); if a and b then local sa,oa=w2s(a.Position); local sb,ob=w2s(b.Position); if oa and ob then e.bones[i].Visible=true; e.bones[i].From=sa; e.bones[i].To=sb; e.bones[i].Color=c else e.bones[i].Visible=false end else e.bones[i].Visible=false end end
                    else for i=1,#SKEL do e.bones[i].Visible=false end end
                    if T.EspOff then local sc,on=w2s(hrp.Position); if not on then local vp=Camera.ViewportSize; local cc=vp/2; local dir=Vector2.new(sc.X,sc.Y)-cc; if dir.Magnitude<1 then dir=Vector2.new(1,0) end; dir=dir.Unit; local tip=cc+dir*180; local perp=Vector2.new(-dir.Y,dir.X)*12; e.arrow.Visible=true; e.arrow.PointA=tip; e.arrow.PointB=tip-dir*20+perp; e.arrow.PointC=tip-dir*20-perp; e.arrow.Color=c else e.arrow.Visible=false end else e.arrow.Visible=false end
                else hideEsp(e) end
            else e.box.Visible=false; for i=1,8 do e.corners[i].Visible=false end; e.name.Visible=false; e.dist.Visible=false; e.team.Visible=false; e.hpbg.Visible=false; e.hp.Visible=false; e.hpt.Visible=false; e.tracer.Visible=false; e.dot.Visible=false; e.circ.Visible=false; e.arrow.Visible=false; for i=1,#SKEL do e.bones[i].Visible=false end end
            if showC then pc(function() e.hl.Enabled=true; e.hl.Adornee=ch; local fc=c; if T.ChamsVis and los(Camera.CFrame.Position,head) then fc=COL[O.ChamsVisCol or "green"] end; e.hl.FillColor=fc; e.hl.OutlineColor=Color3.new(1,1,1); e.hl.FillTransparency=O.ChamsFill end) else pc(function() e.hl.Enabled=false; e.hl.Adornee=nil end) end
        end
    end end
end

----------------------------------------------------------------
-- HUD + status
----------------------------------------------------------------
local fovRing=D(Drawing.new("Circle")); fovRing.Thickness=1; fovRing.NumSides=64; fovRing.Visible=false
local aaArrow=D(Drawing.new("Triangle")); aaArrow.Filled=true; aaArrow.Visible=false
local watermark=D(Drawing.new("Text")); watermark.Size=14; watermark.Outline=true; watermark.Font=2; watermark.Visible=false
local function hudTick()
    fovRing.Visible = T.FovRing and (T.RageOn or T.Silent)
    if fovRing.Visible then fovRing.Position=UIS:GetMouseLocation(); fovRing.Radius=O.Fov or 120; fovRing.Color=P.ac end
    aaArrow.Visible = T.AAArrow and T.AAOn
    if aaArrow.Visible then local cc=Camera.ViewportSize/2; local y=realDesyncYaw; aaArrow.PointA=cc+Vector2.new(math.sin(y),-math.cos(y))*45; aaArrow.PointB=cc+Vector2.new(math.sin(y+2.6),-math.cos(y+2.6))*15; aaArrow.PointC=cc+Vector2.new(math.sin(y-2.6),-math.cos(y-2.6))*15; aaArrow.Color=P.ac end
    watermark.Visible = T.WaterMark
    if watermark.Visible then watermark.Text="unnamed enhancements v8 // olivia"; watermark.Position=Vector2.new(Camera.ViewportSize.X-300,10); watermark.Color=P.ac end
end
local function statusTick()
    sTL.Text = string.format(">>  rage:%s  silent:%s  aa:%s  fp:%s  void:%s  esp:%s  fly:%s",T.RageOn and "ON" or "--",T.Silent and "ON" or "--",T.AAOn and "ON" or "--",T.FPOn and "ON" or "--",voidActive() and "ON" or "--",T.EspOn and "ON" or "--",T.Fly and "ON" or "--")
    sTR.Text = string.format("tgt:%s  shots:%d", curTarget and curTarget.Name or "---", Sum.shots)
end

----------------------------------------------------------------
-- scheduler
----------------------------------------------------------------
C(RunService.Heartbeat:Connect(function()
    for _,p in ipairs(Players:GetPlayers()) do if p~=LP then pc(bt_push,p) end end
    pc(self_bt_push); pc(aimTick); pc(fireTick); pc(aaTick); pc(fpTick); pc(voidTick); pc(moveTick); pc(worldTick); pc(espTick); pc(hudTick); pc(statusTick)
    scl.Scale = O.MenuScale or 1
    Root.BackgroundTransparency = 1-(O.MenuAlpha or 1)
end))

-- kills counter
C(Players.PlayerAdded:Connect(function(p) p.CharacterAdded:Connect(function(ch) local h=ch:WaitForChild("Humanoid",5); if h then h.Died:Connect(function() if curTarget==p then Sum.kills+=1; lastKillAt=os.clock() end end) end end) end))

-- menu toggle key (RightShift default)
C(UIS.InputBegan:Connect(function(i,gp) if gp then return end; local kk=K.MenuKey; if kk and typeof(kk.k)=="EnumItem" and i.KeyCode==kk.k then Root.Visible = not Root.Visible end end))

LP.CharacterAdded:Connect(function() for _,e in pairs(U.Esp) do hideEsp(e) end end)

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
    pcall(function() Lighting.FogEnd=origFog; Lighting.Brightness=origBrt; Camera.FieldOfView=70 end)
    pcall(function() Screen:Destroy() end)
    getgenv().UEV8=nil
end

sTL.Text=">>  ready."
