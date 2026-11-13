-- ============================================================================
-- Unnamed Enhancements V3  |  Rivals
-- UE skin · full stack · defensive GUI build
-- Built by Olivia — https://discord.gg/ojailbreaks
-- ============================================================================
--!nocheck
--!native

local HttpService      = game:GetService("HttpService")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players          = game:GetService("Players")
local Lighting         = game:GetService("Lighting")
local ReplicatedStorage= game:GetService("ReplicatedStorage")
local CollectionService= game:GetService("CollectionService")
local TweenService     = game:GetService("TweenService")
local SoundService     = game:GetService("SoundService")
local VirtualUser      = game:GetService("VirtualUser")
local TeleportService  = game:GetService("TeleportService")
local Debris           = game:GetService("Debris")
local Workspace        = workspace

local LocalPlayer = Players.LocalPlayer
local Camera      = Workspace.CurrentCamera
local Mouse       = LocalPlayer:GetMouse()

if getgenv().UEV3_LOADED then
    pcall(function() getgenv().UEV3_UNLOAD() end)
end
getgenv().UEV3_LOADED = true

-- ============================================================================
-- ANTIDETECT
-- ============================================================================
pcall(function()
    if not (hookfunction and newcclosure and getcallingscript) then return end
    local real_setmt
    real_setmt = hookfunction(setmetatable, newcclosure(function(t, mt)
        if type(mt) == "table" and rawget(mt, "__mode") == "kv" then
            local s = getcallingscript()
            if s and (s.Name == "MiscellaneousController" or s.Name:lower():find("anticheat")) then
                return real_setmt(t, {})
            end
        end
        return real_setmt(t, mt)
    end))
end)

task.spawn(function()
    pcall(function()
        local kill = {"anticheat","detection","ban","kick","security","moderation","report"}
        local function sweep(d)
            if d:IsA("LocalScript") or d:IsA("ModuleScript") then
                local n = d.Name:lower()
                for _,k in ipairs(kill) do
                    if n:find(k,1,true) then pcall(function() d.Disabled = true end) break end
                end
            end
        end
        game.DescendantAdded:Connect(function(d) pcall(sweep,d) end)
        for i,d in ipairs(game:GetDescendants()) do
            pcall(sweep,d)
            if i % 4000 == 0 then task.wait() end
        end
    end)
end)

-- ============================================================================
-- LIBRARY (UE lib — PhonkWare + UE source ship with this one)
-- ============================================================================
do
    local body = game:HttpGet("https://raw.githubusercontent.com/Anonymus23231/thing/refs/heads/main/Lib")
    local chunk, err = loadstring(body .. [[

getgenv().ThemeManager = ThemeManager
getgenv().SaveManager = SaveManager
getgenv().Trove = Trove
]])
    assert(chunk, "[UEV3] lib compile failed: "..tostring(err))
    local ok, runErr = pcall(chunk)
    assert(ok, "[UEV3] lib run failed: "..tostring(runErr))
end

local Library      = getgenv().Library
local ThemeManager = getgenv().ThemeManager
local SaveManager  = getgenv().SaveManager
assert(Library, "[UEV3] Library missing")

Library.AccentColor     = Color3.fromRGB(196, 30, 58)
Library.BackgroundColor = Color3.fromRGB(13, 13, 15)
Library.MainColor       = Color3.fromRGB(20, 20, 23)
Library.OutlineColor    = Color3.fromRGB(45, 45, 50)
Library.FontColor       = Color3.fromRGB(235, 235, 240)

local function uiScale()
    local cam = Workspace.CurrentCamera
    local vp = cam and cam.ViewportSize or Vector2.new(1920, 1080)
    return math.clamp(math.min(vp.X / 1920, vp.Y / 1080), 0.5, 1.4)
end
local _scale = uiScale()

local Window = Library:CreateWindow({
    Title     = "Unnamed Enhancements V3  |  https://discord.gg/ojailbreaks",
    SubTitle  = "Rivals · Cracked",
    Center    = true,
    AutoShow  = true,
    Resizable = true,
    Draggable = true,
    TabPadding = 8,
    MenuFadeTime = 0.2,
    Size      = UDim2.fromOffset(math.floor(740 * _scale), math.floor(660 * _scale)),
})

pcall(function()
    local sg = Library.ScreenGui
    if sg then
        local old = sg:FindFirstChild("UEV3_UIScale") if old then old:Destroy() end
        local s = Instance.new("UIScale") s.Name="UEV3_UIScale" s.Scale=_scale s.Parent=sg
    end
end)

local Tabs = {}
local tabNames = {"Rage","Legit","Visuals","World","Character","Movement","Misc","Scripts","Spoofer","Optim","Config"}
for _, n in ipairs(tabNames) do
    local ok, t = pcall(function() return Window:AddTab(n) end)
    if ok then Tabs[n] = t end
end

-- ============================================================================
-- DEFENSIVE GUI HELPERS
-- ============================================================================
local function LGroup(tab, name)
    if not tab then return nil end
    local ok, g = pcall(function() return tab:AddLeftGroupbox(name) end)
    if ok then return g end
    return nil
end

local function RGroup(tab, name)
    if not tab then return nil end
    local ok, g = pcall(function() return tab:AddRightGroupbox(name) end)
    if ok then return g end
    return nil
end

local function Toggle(g, id, text, default, cb)
    if not g then return end
    local ok, t = pcall(function()
        return g:AddToggle(id, { Text = text, Default = default and true or false })
    end)
    if not ok or not t then return end
    if cb then
        pcall(function()
            t:OnChanged(function() cb(t.Value) end)
        end)
    end
    return t
end

local function Slider(g, id, text, def, min, max, rounding, cb)
    if not g then return end
    local ok, s = pcall(function()
        return g:AddSlider(id, {
            Text = text, Default = def, Min = min, Max = max, Rounding = rounding or 0,
        })
    end)
    if not ok or not s then return end
    if cb then
        pcall(function()
            s:OnChanged(function() cb(s.Value) end)
        end)
    end
    return s
end

local function Dropdown(g, id, text, values, default, cb)
    if not g then return end
    local ok, d = pcall(function()
        return g:AddDropdown(id, { Text = text, Values = values, Default = default })
    end)
    if not ok or not d then return end
    if cb then
        pcall(function()
            d:OnChanged(function() cb(d.Value) end)
        end)
    end
    return d
end

local function Input(g, id, text, default, cb)
    if not g then return end
    local ok, i = pcall(function()
        return g:AddInput(id, { Text = text, Default = default or "", Numeric = false })
    end)
    if not ok or not i then return end
    if cb then
        pcall(function()
            i:OnChanged(function() cb(i.Value) end)
        end)
    end
    return i
end

local function Label(g, text)
    if not g then return end
    pcall(function() g:AddLabel(text) end)
end

local function Button(g, text, cb)
    if not g then return end
    pcall(function() g:AddButton(text, cb) end)
end

local function ColorPicker(g, id, text, default, cb)
    if not g then return end
    -- try label-chained first (linoria style), then direct (phonkware style)
    local ok1, c = pcall(function()
        local l = g:AddLabel(text)
        return l:AddColorPicker(id, { Default = default })
    end)
    if not ok1 or not c then
        local ok2, c2 = pcall(function()
            return g:AddColorPicker(id, { Default = default, Title = text })
        end)
        if ok2 then c = c2 end
    end
    if c and cb then
        pcall(function()
            c:OnChanged(function() cb(c.Value) end)
        end)
    end
    return c
end

local function KeyPicker(g, id, text, default, mode, cb)
    if not g then return end
    -- try label-chained, then direct
    local ok1, k = pcall(function()
        local l = g:AddLabel(text)
        return l:AddKeyPicker(id, { Default = default, Mode = mode or "Toggle", Text = text })
    end)
    if not ok1 or not k then
        local ok2, k2 = pcall(function()
            return g:AddKeyPicker(id, { Default = default, Mode = mode or "Toggle", Text = text })
        end)
        if ok2 then k = k2 end
    end
    return k
end

-- ============================================================================
-- STATE
-- ============================================================================
getgenv().UEV3 = {
    aimbot = { enable=false, show_fov=true, fov=180, fov_color=Color3.fromRGB(196,30,58),
               smoothing=3, visible_only=false, team_check=true, hit_part="Head",
               prediction=0.165, snapline=false, snapline_color=Color3.fromRGB(255,255,255),
               lock_sound=false, max_dist=1500 },
    silent = { enable=false, show_fov=true, fov=300, fov_color=Color3.fromRGB(255,255,255),
               hit_part="Head", team_check=true, hitchance=70 },
    ragebot = { enable=false, autoshoot=true, autoscope=true, tp_duration=0.15, y_offset=3,
                team_check=true, prediction=true, hitchance=70, force_body=false,
                max_range=2000, priority="distance" },
    triggerbot = { enable=false, team_check=true, reaction=0.05, delay=0.1, max_dist=600,
                   headshot_only=false, burst=false },
    anti_aim = { enable=false, pitch="Down", yaw="Spin", yaw_speed=6 },
    esp = {
        enable=false, team_check=true, max_dist=1000,
        box_e=true, box_color=Color3.fromRGB(196,30,58), box_outline=true,
        name_e=true, name_color=Color3.fromRGB(255,255,255), name_display=true,
        hp_e=true, hp_color=Color3.fromRGB(80,220,80), hp_bar=true, hp_grad=true,
        dist_e=true, dist_color=Color3.fromRGB(200,200,200),
        wep_e=false, wep_color=Color3.fromRGB(255,215,120),
        tracer_e=false, tracer_color=Color3.fromRGB(196,30,58), tracer_origin="bottom",
        dot_e=false, dot_color=Color3.fromRGB(255,255,255),
        skel_e=false, skel_color=Color3.fromRGB(255,255,255),
        hl_e=true, hl_fill=Color3.fromRGB(196,30,58), hl_fill_t=0.5,
        hl_outline=Color3.fromRGB(255,255,255), hl_outline_t=0,
        chams_e=false, chams_mat="ForceField", chams_color=Color3.fromRGB(196,30,58), chams_t=0,
        arrow_e=false, arrow_color=Color3.fromRGB(196,30,58), arrow_radius=200,
    },
    crosshair = { enable=false, length=6, thickness=1, gap=3, color=Color3.fromRGB(0,255,170),
                  outline=true, outline_color=Color3.fromRGB(0,0,0),
                  dot=false, dot_color=Color3.fromRGB(255,255,255),
                  rainbow=false, pulse=false, circle=false, circle_radius=14 },
    world = {
        fov_e=false, fov_v=90,
        atm_e=false, atm_d=0.3, atm_o=0.25, atm_glare=0.2, atm_haze=1.5,
        atm_color=Color3.fromRGB(180,100,100), atm_decay=Color3.fromRGB(80,20,20),
        cc_e=false, cc_br=0, cc_con=0.15, cc_sat=0.1, cc_tint=Color3.fromRGB(255,220,220),
        bloom_e=false, bloom_i=0.4, bloom_s=24, bloom_t=2,
        blur_e=false, blur_s=0,
        sunrays_e=false, sunrays_i=0.25,
        dof_e=false, dof_f=5,
        time_e=false, time_h=12,
        fog_e=false,
        sky_e=false, sky_preset="DeepSpace", sky_rs=false, sky_rm=false, sky_rst=false,
        amb_e=false, amb_color=Color3.fromRGB(128,128,128),
    },
    character = {
        ws_e=false, ws_v=20, jp_e=false, jp_v=60, gv_e=false, gv_v=196,
        hip_e=false, hip_v=2, infj=false, bhop=false, god=false,
        heal_e=false, heal_r=1, nofall=false, instrst=false,
        hitbox_e=false, hitbox_s=5, hitbox_p="Head",
    },
    movement = {
        fly_e=false, fly_s=50, fly_nc=false, noclip_e=false,
        tp_method="closest", tp_y=0, tp_team=true, tp_pred=true,
        ug_e=false, ug_d=5.8, avoid_e=false, avoid_f=-50, avoid_t=0,
        slowfall_e=false, slowfall_s=100,
    },
    misc = {
        gm_e=false, gm_recoil=true, gm_spread=true, gm_cd=true, gm_os=false, gm_proj=0,
        hs_e=false, hs_id="hitmarker", hs_v=1, hs_p=1, hs_custom="",
        ks_e=false, ks_id="rust", ks_v=1,
        wm_e=true, wm_pos="top_left",
        kf_e=false, notif=true, afk=true,
        auto_accept=false, auto_ready=false,
    },
    spoofer = { name_e=false, name_v="", display_e=false, display_v="",
                level_e=false, level_v=9, streak_e=false, streak_v=9,
                rank_e=false, rank_v="GM", wins_e=false, wins_v=9999 },
    optim = { no_part=false, no_shad=false, no_tex=false, low_q=false, no_snd=false,
              fps_cap_e=false, fps_cap=240, no_mesh=false, destroy_fx=false },
    panic = { key="End" },
}
local S = getgenv().UEV3
local Trash = {}
local function bin(x) Trash[#Trash+1] = x return x end

-- ============================================================================
-- HELPERS
-- ============================================================================
local function getChar() return LocalPlayer.Character end
local function getHRP() local c=getChar() return c and c:FindFirstChild("HumanoidRootPart") end
local function getHum() local c=getChar() return c and c:FindFirstChildOfClass("Humanoid") end

local function isTeammate(plr)
    local a, b = plr:GetAttribute("TeamID"), LocalPlayer:GetAttribute("TeamID")
    if a and b then return a == b end
    return plr.Team and LocalPlayer.Team and plr.Team == LocalPlayer.Team
end

local function alive(plr)
    local c = plr.Character if not c then return false end
    local h = c:FindFirstChildOfClass("Humanoid")
    return h and h.Health > 0
end

local function visibleTo(part, origin)
    if not part then return false end
    origin = origin or Camera.CFrame.Position
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = { LocalPlayer.Character, part.Parent }
    params.FilterType = Enum.RaycastFilterType.Exclude
    local r = Workspace:Raycast(origin, (part.Position - origin), params)
    return r == nil
end

local function predict(part, t)
    if not part then return nil end
    local v = part.AssemblyLinearVelocity or Vector3.zero
    return part.Position + v * t
end

local function onscreen(pos)
    local v, on = Camera:WorldToViewportPoint(pos)
    return on, Vector2.new(v.X, v.Y), v.Z
end

local function keyHeld(opt)
    if not opt then return true end
    if type(opt.GetState) == "function" then
        local ok, r = pcall(function() return opt:GetState() end)
        if ok then return r == true end
    end
    return true
end

local function notify(text, duration)
    if not S.misc.notif then return end
    pcall(function() Library:Notify(text, duration or 3) end)
end

local function playSound(id, vol, pitch)
    local s = Instance.new("Sound")
    s.SoundId = typeof(id)=="number" and ("rbxassetid://"..id) or id
    s.Volume = vol or 1
    s.PlaybackSpeed = pitch or 1
    s.Parent = SoundService
    s:Play()
    Debris:AddItem(s, 3)
end

local function rainbow(speed, offset)
    return Color3.fromHSV(((tick() * (speed or 1)) + (offset or 0)) % 1, 1, 1)
end

local hitSounds = {
    hitmarker=3779005184, rust=5554541971, skeet=1500880381,
    bell=12222257, minecraft=1839997054, bone=2851554006,
    ding=230295843, glass=143082895, pop=448572983, tick=1659517145,
}
local killSounds = {
    rust=5554541971, anime=4612375233, taco=142403532, gta=177418988,
    quake=2616682174, bruh=4953846338, windows=136351184,
}
local skyboxes = {
    DeepSpace  = {Up="48348670",Dn="48348710",Lf="48348542",Rt="48348587",Bk="48348446",Ft="48348499"},
    NebulaBlue = {Up="159454299",Dn="159454296",Lf="159454293",Rt="159454286",Bk="159454284",Ft="159454288"},
    Sunset     = {Up="271042467",Dn="271077243",Lf="271042330",Rt="271077958",Bk="271084259",Ft="271083692"},
    Night      = {Up="12064107",Dn="12064152",Lf="12064121",Rt="12063984",Bk="12064115",Ft="12063993"},
    Purple     = {Up="159454288",Dn="159454293",Lf="159454299",Rt="159454284",Bk="159454296",Ft="159454286"},
    Realistic  = {Up="159454278",Dn="159454282",Lf="159454275",Rt="159454272",Bk="159454269",Ft="159454267"},
}

-- ============================================================================
-- AIMBOT
-- ============================================================================
local aimCircle = Drawing.new("Circle")
aimCircle.Thickness=1 aimCircle.NumSides=64 aimCircle.Filled=false aimCircle.Visible=false
bin(aimCircle)

local snapLine = Drawing.new("Line")
snapLine.Thickness=1 snapLine.Visible=false
bin(snapLine)

local function bestTarget()
    local center = Camera.ViewportSize / 2
    local best, bestDist = nil, S.aimbot.fov
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and alive(plr) and (not S.aimbot.team_check or not isTeammate(plr)) then
            local part = plr.Character:FindFirstChild(S.aimbot.hit_part or "Head")
            if part then
                local d3 = (part.Position - Camera.CFrame.Position).Magnitude
                if d3 <= S.aimbot.max_dist then
                    if (not S.aimbot.visible_only) or visibleTo(part) then
                        local on, scr = onscreen(part.Position)
                        if on then
                            local d = (scr - center).Magnitude
                            if d < bestDist then bestDist = d best = plr end
                        end
                    end
                end
            end
        end
    end
    return best
end

local lockedLast
bin(RunService.RenderStepped:Connect(function()
    if S.aimbot.enable and S.aimbot.show_fov then
        aimCircle.Visible = true
        aimCircle.Radius  = S.aimbot.fov
        aimCircle.Color   = S.aimbot.fov_color
        aimCircle.Position= Camera.ViewportSize / 2
    else aimCircle.Visible = false end

    if not S.aimbot.enable then snapLine.Visible=false return end
    if not keyHeld(Library.Options.aimbot_key) then snapLine.Visible=false return end

    local tgt = bestTarget()
    if not tgt then snapLine.Visible=false lockedLast=nil return end
    local part = tgt.Character and tgt.Character:FindFirstChild(S.aimbot.hit_part or "Head")
    if not part then snapLine.Visible=false return end

    local target = predict(part, S.aimbot.prediction or 0)
    local smooth = math.clamp((101 - math.clamp(S.aimbot.smoothing,1,100)) / 100, 0.02, 1)
    local look = (target - Camera.CFrame.Position).Unit
    local blend = Camera.CFrame.LookVector:Lerp(look, smooth)
    pcall(function()
        Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, Camera.CFrame.Position + blend)
    end)

    if S.aimbot.snapline then
        local on, scr = onscreen(target)
        if on then
            snapLine.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
            snapLine.To = scr
            snapLine.Color = S.aimbot.snapline_color
            snapLine.Visible = true
        end
    else snapLine.Visible = false end

    if S.aimbot.lock_sound and lockedLast ~= tgt then
        lockedLast = tgt
        pcall(function() playSound(3779005184, 0.6, 1) end)
    end
end))

-- ============================================================================
-- TRIGGERBOT
-- ============================================================================
bin(task.spawn(function()
    while task.wait(0.03) do
        if not S.triggerbot.enable then continue end
        local rp = RaycastParams.new()
        rp.FilterDescendantsInstances = { LocalPlayer.Character }
        rp.FilterType = Enum.RaycastFilterType.Exclude
        local r = Workspace:Raycast(Camera.CFrame.Position,
                                    Camera.CFrame.LookVector * S.triggerbot.max_dist, rp)
        if not r then continue end
        local part = r.Instance
        local hum = part.Parent and part.Parent:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then continue end
        if S.triggerbot.headshot_only and part.Name ~= "Head" then continue end
        local plr = Players:GetPlayerFromCharacter(part.Parent)
        if S.triggerbot.team_check and plr and isTeammate(plr) then continue end
        task.wait(S.triggerbot.reaction)
        pcall(function()
            local fc = require(LocalPlayer.PlayerScripts.Controllers.FighterController)
            if fc and fc.LocalFighter then fc.LocalFighter:Input("StartShooting") end
        end)
        task.wait(S.triggerbot.delay)
        pcall(function()
            local fc = require(LocalPlayer.PlayerScripts.Controllers.FighterController)
            if fc and fc.LocalFighter then fc.LocalFighter:Input("StopShooting") end
        end)
    end
end))

-- ============================================================================
-- SILENT AIM
-- ============================================================================
local silentCircle = Drawing.new("Circle")
silentCircle.Thickness=1 silentCircle.NumSides=64 silentCircle.Filled=false silentCircle.Visible=false
bin(silentCircle)

bin(RunService.RenderStepped:Connect(function()
    if S.silent.enable and S.silent.show_fov then
        silentCircle.Visible = true
        silentCircle.Radius  = S.silent.fov
        silentCircle.Color   = S.silent.fov_color
        silentCircle.Position= Camera.ViewportSize / 2
    else silentCircle.Visible = false end
end))

local function silentTarget()
    if not S.silent.enable then return nil end
    local center = Camera.ViewportSize / 2
    local best, bestDist = nil, S.silent.fov
    for _, ent in ipairs(CollectionService:GetTagged("Entity")) do
        if ent ~= getChar() then
            local part = ent:FindFirstChild(S.silent.hit_part or "Head", true)
            if part and part:IsA("BasePart") then
                local on, scr = onscreen(part.Position)
                if on then
                    local d = (scr - center).Magnitude
                    if d < bestDist then bestDist = d best = part end
                end
            end
        end
    end
    return best
end

pcall(function()
    local rs = ReplicatedStorage
    local useItem = rs:FindFirstChild("Remotes")
        and rs.Remotes:FindFirstChild("Replication")
        and rs.Remotes.Replication:FindFirstChild("Fighter")
        and rs.Remotes.Replication.Fighter:FindFirstChild("UseItem")
    local ok1, Utility = pcall(require, rs.Modules.Utility)
    local ok2, EnumLib = pcall(require, rs.Modules.EnumLibrary)
    if not (useItem and hookfunction and newcclosure and ok1 and ok2) then return end

    local original
    original = hookfunction(useItem.FireServer, newcclosure(function(self, a1, a2, a3, a4, ...)
        if S.silent.enable and a2 == EnumLib:ToEnum("StartShooting") then
            local hrp = getHRP()
            local tgt = silentTarget()
            if hrp and tgt and (S.silent.hitchance >= 100 or math.random(1,100) <= S.silent.hitchance) then
                local cf = tgt.CFrame
                a3 = {
                    [utf8.char(1)] = {
                        [utf8.char(0)] = Utility:EncodeCFrame(CFrame.lookAt(hrp.Position, tgt.Position)),
                        [utf8.char(1)] = Utility:EncodeCFrame(cf),
                        [utf8.char(2)] = tgt,
                        [utf8.char(3)] = Utility:EncodeCFrame(cf:ToObjectSpace(CFrame.new(tgt.Position))),
                    },
                }
            end
        end
        return original(self, a1, a2, a3, a4, ...)
    end))
end)

-- ============================================================================
-- RAGEBOT
-- ============================================================================
local function ragePickTarget()
    local best, bestVal = nil, math.huge
    local hrp = getHRP() if not hrp then return nil end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and alive(plr) and (not S.ragebot.team_check or not isTeammate(plr)) then
            local part = plr.Character:FindFirstChild(S.ragebot.force_body and "HumanoidRootPart" or "Head")
            if part then
                local d3 = (part.Position - hrp.Position).Magnitude
                if d3 <= S.ragebot.max_range then
                    local val = d3
                    if S.ragebot.priority == "lowest_hp" then val = plr.Character:FindFirstChildOfClass("Humanoid").Health end
                    if val < bestVal then bestVal=val best=plr end
                end
            end
        end
    end
    return best
end

bin(task.spawn(function()
    while task.wait(0.05) do
        if not S.ragebot.enable then continue end
        local tgt = ragePickTarget()
        if not tgt then continue end
        local part = tgt.Character and tgt.Character:FindFirstChild(S.ragebot.force_body and "HumanoidRootPart" or "Head")
        if not part then continue end
        local hrp = getHRP() if not hrp then continue end
        local savedCF = hrp.CFrame
        local targetPos = S.ragebot.prediction and predict(part, 0.15) or part.Position
        pcall(function()
            hrp.CFrame = CFrame.new(targetPos + Vector3.new(0, S.ragebot.y_offset, 0))
            Camera.CFrame = CFrame.lookAt(hrp.Position, targetPos)
            if S.ragebot.autoshoot then
                local fc = require(LocalPlayer.PlayerScripts.Controllers.FighterController)
                if fc and fc.LocalFighter then
                    fc.LocalFighter:Input("StartShooting")
                    task.wait(0.05)
                    fc.LocalFighter:Input("StopShooting")
                end
            end
        end)
        task.wait(S.ragebot.tp_duration)
        pcall(function() hrp.CFrame = savedCF end)
    end
end))

-- ============================================================================
-- ANTI-AIM
-- ============================================================================
local aaT = 0
bin(RunService.Heartbeat:Connect(function(dt)
    if not S.anti_aim.enable then return end
    aaT = aaT + dt
    local hrp = getHRP() if not hrp then return end
    local pitchDeg = 0
    if S.anti_aim.pitch == "Up" then pitchDeg = -89
    elseif S.anti_aim.pitch == "Down" then pitchDeg = 89
    elseif S.anti_aim.pitch == "Zero" then pitchDeg = 0 end
    local yawDeg = 0
    if S.anti_aim.yaw == "Spin" then yawDeg = (aaT * S.anti_aim.yaw_speed * 60) % 360
    elseif S.anti_aim.yaw == "Jitter" then yawDeg = (aaT * 60) % 2 < 1 and 180 or 0
    elseif S.anti_aim.yaw == "Backward" then yawDeg = 180
    elseif S.anti_aim.yaw == "Random" then yawDeg = math.random(0, 360) end
    pcall(function()
        hrp.CFrame = CFrame.new(hrp.Position) * CFrame.Angles(math.rad(pitchDeg), math.rad(yawDeg), 0)
    end)
end))

-- ============================================================================
-- ESP
-- ============================================================================
local skeletonLinks = {
    {"Head","UpperTorso"},{"UpperTorso","LowerTorso"},
    {"UpperTorso","LeftUpperArm"},{"LeftUpperArm","LeftLowerArm"},{"LeftLowerArm","LeftHand"},
    {"UpperTorso","RightUpperArm"},{"RightUpperArm","RightLowerArm"},{"RightLowerArm","RightHand"},
    {"LowerTorso","LeftUpperLeg"},{"LeftUpperLeg","LeftLowerLeg"},{"LeftLowerLeg","LeftFoot"},
    {"LowerTorso","RightUpperLeg"},{"RightUpperLeg","RightLowerLeg"},{"RightLowerLeg","RightFoot"},
}

local espCache = {}
local function newEsp()
    local e = {
        box=Drawing.new("Square"), box_out=Drawing.new("Square"),
        name=Drawing.new("Text"), health=Drawing.new("Text"),
        hp_bar=Drawing.new("Line"), hp_bg=Drawing.new("Line"),
        dist=Drawing.new("Text"), weapon=Drawing.new("Text"),
        tracer=Drawing.new("Line"), dot=Drawing.new("Circle"),
        arrow_a=Drawing.new("Line"), arrow_b=Drawing.new("Line"), arrow_c=Drawing.new("Line"),
        skeleton={},
    }
    for i=1,#skeletonLinks do
        local l=Drawing.new("Line") l.Thickness=1 l.Visible=false
        e.skeleton[i]=l
    end
    e.box.Filled=false e.box.Thickness=1 e.box.Visible=false
    e.box_out.Filled=false e.box_out.Thickness=3 e.box_out.Color=Color3.new(0,0,0) e.box_out.Visible=false
    for _,t in ipairs({e.name,e.health,e.dist,e.weapon}) do
        t.Size=14 t.Center=true t.Outline=true t.Visible=false t.Font=Drawing.Fonts.Plex
    end
    e.hp_bar.Thickness=2 e.hp_bar.Visible=false
    e.hp_bg.Thickness=4 e.hp_bg.Color=Color3.new(0,0,0) e.hp_bg.Visible=false
    e.tracer.Thickness=1 e.tracer.Visible=false
    e.dot.NumSides=16 e.dot.Radius=3 e.dot.Thickness=1 e.dot.Filled=true e.dot.Visible=false
    for _,a in ipairs({e.arrow_a,e.arrow_b,e.arrow_c}) do a.Thickness=1 a.Visible=false end
    return e
end

local function killEsp(plr)
    local e = espCache[plr] if not e then return end
    for _,d in pairs(e) do
        if typeof(d)=="table" then
            for _,ln in ipairs(d) do pcall(function() ln:Remove() end) end
        else pcall(function() d:Remove() end) end
    end
    espCache[plr] = nil
    if plr.Character then
        local hl = plr.Character:FindFirstChild("UEV3_Highlight") if hl then hl:Destroy() end
        for _,v in ipairs(plr.Character:GetDescendants()) do
            if v:IsA("BasePart") and v:GetAttribute("UEV3_ChamBackup") then
                v.Material = Enum.Material[v:GetAttribute("UEV3_mat")] or Enum.Material.Plastic
                v.Transparency = v:GetAttribute("UEV3_trans") or 0
                v:SetAttribute("UEV3_ChamBackup", nil)
            end
        end
    end
end

local function hideEsp(e)
    for _,d in pairs(e) do
        if typeof(d)=="table" then
            for _,ln in ipairs(d) do ln.Visible=false end
        else pcall(function() d.Visible=false end) end
    end
end

bin(RunService.RenderStepped:Connect(function()
    if not S.esp.enable then
        for _, e in pairs(espCache) do hideEsp(e) end
        return
    end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        if not alive(plr) then if espCache[plr] then hideEsp(espCache[plr]) end continue end
        if S.esp.team_check and isTeammate(plr) then if espCache[plr] then hideEsp(espCache[plr]) end continue end

        local char = plr.Character
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local head = char:FindFirstChild("Head")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not (hrp and head and hum) then continue end

        local dist = (hrp.Position - Camera.CFrame.Position).Magnitude
        if dist > S.esp.max_dist then if espCache[plr] then hideEsp(espCache[plr]) end continue end

        if not espCache[plr] then espCache[plr] = newEsp() end
        local e = espCache[plr]

        local onHead, headScr = onscreen(head.Position + Vector3.new(0,0.5,0))
        local onFoot, footScr = onscreen(hrp.Position - Vector3.new(0,3,0))

        if not (onHead and onFoot) then
            hideEsp(e)
            if S.esp.arrow_e then
                local toTarget = (hrp.Position - Camera.CFrame.Position)
                local flat = Vector3.new(toTarget.X, 0, toTarget.Z).Unit
                local look = Vector3.new(Camera.CFrame.LookVector.X, 0, Camera.CFrame.LookVector.Z).Unit
                local right = Camera.CFrame.RightVector
                local angle = math.atan2(flat:Dot(right), flat:Dot(look))
                local center = Camera.ViewportSize / 2
                local radius = S.esp.arrow_radius
                local pos = center + Vector2.new(math.sin(angle), -math.cos(angle)) * radius
                local size = 14
                local ang2 = angle + math.pi/2
                local p1 = pos + Vector2.new(math.cos(ang2), math.sin(ang2)) * size
                local p2 = pos - Vector2.new(math.cos(ang2), math.sin(ang2)) * size
                local p3 = pos + Vector2.new(math.sin(angle), -math.cos(angle)) * size * 1.6
                e.arrow_a.From=p1 e.arrow_a.To=p2 e.arrow_a.Color=S.esp.arrow_color e.arrow_a.Visible=true
                e.arrow_b.From=p1 e.arrow_b.To=p3 e.arrow_b.Color=S.esp.arrow_color e.arrow_b.Visible=true
                e.arrow_c.From=p2 e.arrow_c.To=p3 e.arrow_c.Color=S.esp.arrow_color e.arrow_c.Visible=true
            end
            continue
        end
        for _,a in ipairs({e.arrow_a,e.arrow_b,e.arrow_c}) do a.Visible=false end

        local height = (footScr.Y - headScr.Y)
        local width = height / 2
        local topLeft = Vector2.new(headScr.X - width/2, headScr.Y)

        if S.esp.box_e then
            e.box.Size=Vector2.new(width, height) e.box.Position=topLeft
            e.box.Color=S.esp.box_color e.box.Visible=true
            if S.esp.box_outline then
                e.box_out.Size=e.box.Size e.box_out.Position=e.box.Position e.box_out.Visible=true
            else e.box_out.Visible=false end
        else e.box.Visible=false e.box_out.Visible=false end

        if S.esp.name_e then
            e.name.Text = S.esp.name_display and plr.DisplayName or plr.Name
            e.name.Position = Vector2.new(headScr.X, headScr.Y - 16)
            e.name.Color = S.esp.name_color
            e.name.Visible = true
        else e.name.Visible=false end

        if S.esp.hp_e then
            local pct = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
            if S.esp.hp_bar then
                local barX = topLeft.X - 5
                e.hp_bg.From = Vector2.new(barX, topLeft.Y)
                e.hp_bg.To = Vector2.new(barX, topLeft.Y + height)
                e.hp_bar.From = Vector2.new(barX, topLeft.Y + height * (1 - pct))
                e.hp_bar.To = Vector2.new(barX, topLeft.Y + height)
                e.hp_bar.Color = S.esp.hp_grad and Color3.fromHSV(0.33 * pct, 1, 1) or S.esp.hp_color
                e.hp_bar.Visible=true e.hp_bg.Visible=true
            end
            e.health.Text = math.floor(hum.Health).."hp"
            e.health.Position = Vector2.new(headScr.X, footScr.Y + 2)
            e.health.Color = S.esp.hp_color
            e.health.Visible = true
        else e.hp_bar.Visible=false e.hp_bg.Visible=false e.health.Visible=false end

        if S.esp.dist_e then
            e.dist.Text = string.format("[%dm]", math.floor(dist))
            e.dist.Position = Vector2.new(headScr.X, footScr.Y + 16)
            e.dist.Color = S.esp.dist_color
            e.dist.Visible = true
        else e.dist.Visible=false end

        if S.esp.wep_e then
            local tool = char:FindFirstChildOfClass("Tool")
            e.weapon.Text = tool and tool.Name or ""
            e.weapon.Position = Vector2.new(headScr.X, footScr.Y + 30)
            e.weapon.Color = S.esp.wep_color
            e.weapon.Visible = tool ~= nil
        else e.weapon.Visible=false end

        if S.esp.tracer_e then
            local origin
            if S.esp.tracer_origin == "top" then origin = Vector2.new(Camera.ViewportSize.X/2, 0)
            elseif S.esp.tracer_origin == "middle" then origin = Camera.ViewportSize/2
            else origin = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y) end
            e.tracer.From = origin e.tracer.To = footScr
            e.tracer.Color = S.esp.tracer_color
            e.tracer.Visible = true
        else e.tracer.Visible=false end

        if S.esp.dot_e then
            e.dot.Position = headScr e.dot.Color = S.esp.dot_color e.dot.Visible = true
        else e.dot.Visible=false end

        if S.esp.skel_e then
            for i, link in ipairs(skeletonLinks) do
                local a = char:FindFirstChild(link[1])
                local b = char:FindFirstChild(link[2])
                local ln = e.skeleton[i]
                if a and b and ln then
                    local on1, s1 = onscreen(a.Position)
                    local on2, s2 = onscreen(b.Position)
                    if on1 and on2 then
                        ln.From=s1 ln.To=s2 ln.Color=S.esp.skel_color ln.Visible=true
                    else ln.Visible=false end
                else if ln then ln.Visible=false end end
            end
        else for _,ln in ipairs(e.skeleton) do ln.Visible=false end end

        if S.esp.hl_e then
            local hl = char:FindFirstChild("UEV3_Highlight")
            if not hl then
                hl = Instance.new("Highlight") hl.Name="UEV3_Highlight" hl.Parent=char
            end
            hl.FillColor=S.esp.hl_fill hl.FillTransparency=S.esp.hl_fill_t
            hl.OutlineColor=S.esp.hl_outline hl.OutlineTransparency=S.esp.hl_outline_t
            hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        else local hl = char:FindFirstChild("UEV3_Highlight") if hl then hl:Destroy() end end

        if S.esp.chams_e then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                    if not part:GetAttribute("UEV3_ChamBackup") then
                        part:SetAttribute("UEV3_ChamBackup", true)
                        part:SetAttribute("UEV3_mat", part.Material.Name)
                        part:SetAttribute("UEV3_trans", part.Transparency)
                    end
                    part.Material = Enum.Material[S.esp.chams_mat] or Enum.Material.ForceField
                    part.Color = S.esp.chams_color
                    part.Transparency = S.esp.chams_t
                end
            end
        end
    end
end))

Players.PlayerRemoving:Connect(killEsp)

-- ============================================================================
-- CROSSHAIR
-- ============================================================================
local xhairLines = {}
for i=1,4 do local l=Drawing.new("Line") l.Thickness=1 l.Visible=false xhairLines[i]=l bin(l) end
local xhairDot = Drawing.new("Circle") xhairDot.Filled=true xhairDot.Radius=1 xhairDot.NumSides=12 xhairDot.Visible=false
bin(xhairDot)
local xhairCircle = Drawing.new("Circle") xhairCircle.Filled=false xhairCircle.NumSides=48 xhairCircle.Visible=false
bin(xhairCircle)

local xhairT = 0
bin(RunService.RenderStepped:Connect(function(dt)
    xhairT = xhairT + dt
    if not S.crosshair.enable then
        for _,l in ipairs(xhairLines) do l.Visible=false end
        xhairDot.Visible=false xhairCircle.Visible=false
        return
    end
    local c = Camera.ViewportSize/2
    local len, gap = S.crosshair.length, S.crosshair.gap
    local col = S.crosshair.color
    if S.crosshair.rainbow then col = rainbow(1) end
    if S.crosshair.pulse then
        local mul = 0.6 + 0.4 * math.abs(math.sin(xhairT * 3))
        col = Color3.new(col.R * mul, col.G * mul, col.B * mul)
    end
    for _,l in ipairs(xhairLines) do l.Color=col l.Thickness=S.crosshair.thickness l.Visible=true end
    xhairLines[1].From=c+Vector2.new(0,-gap) xhairLines[1].To=c+Vector2.new(0,-gap-len)
    xhairLines[2].From=c+Vector2.new(0,gap)  xhairLines[2].To=c+Vector2.new(0,gap+len)
    xhairLines[3].From=c+Vector2.new(-gap,0) xhairLines[3].To=c+Vector2.new(-gap-len,0)
    xhairLines[4].From=c+Vector2.new(gap,0)  xhairLines[4].To=c+Vector2.new(gap+len,0)
    if S.crosshair.circle then
        xhairCircle.Position=c xhairCircle.Radius=S.crosshair.circle_radius xhairCircle.Color=col xhairCircle.Visible=true
    else xhairCircle.Visible=false end
    if S.crosshair.dot then
        xhairDot.Position=c xhairDot.Color=S.crosshair.dot_color xhairDot.Visible=true
    else xhairDot.Visible=false end
end))

-- ============================================================================
-- CHARACTER
-- ============================================================================
bin(RunService.Heartbeat:Connect(function()
    local hum = getHum() if not hum then return end
    if S.character.ws_e then hum.WalkSpeed = S.character.ws_v end
    if S.character.jp_e then hum.UseJumpPower=true hum.JumpPower=S.character.jp_v end
    if S.character.hip_e then hum.HipHeight = S.character.hip_v end
    if S.character.gv_e then Workspace.Gravity = S.character.gv_v end
    if S.character.bhop and UserInputService:IsKeyDown(Enum.KeyCode.Space) then
        if hum:GetState() == Enum.HumanoidStateType.Landed or hum.FloorMaterial ~= Enum.Material.Air then
            hum.Jump = true
        end
    end
    if S.character.god then pcall(function() hum.Health = hum.MaxHealth end) end
    if S.character.heal_e then pcall(function() hum.Health = math.min(hum.Health + S.character.heal_r, hum.MaxHealth) end) end
    if S.character.hitbox_e then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and alive(plr) then
                local part = plr.Character:FindFirstChild(S.character.hitbox_p)
                if part then
                    part.Size = Vector3.new(S.character.hitbox_s, S.character.hitbox_s, S.character.hitbox_s)
                    part.CanCollide = false part.Transparency = 0.7
                end
            end
        end
    end
end))

bin(UserInputService.JumpRequest:Connect(function()
    if S.character.infj then
        local h = getHum() if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end))

-- ============================================================================
-- MOVEMENT
-- ============================================================================
local flyBV, flyBG
local function destroyFly()
    if flyBV then flyBV:Destroy() flyBV=nil end
    if flyBG then flyBG:Destroy() flyBG=nil end
end
LocalPlayer.CharacterAdded:Connect(destroyFly)

bin(RunService.Heartbeat:Connect(function()
    if S.movement.fly_e then
        local hrp = getHRP() if not hrp then return end
        if not flyBV then
            flyBV = Instance.new("BodyVelocity") flyBV.MaxForce=Vector3.new(1e9,1e9,1e9) flyBV.Parent=hrp
            flyBG = Instance.new("BodyGyro") flyBG.MaxTorque=Vector3.new(1e9,1e9,1e9) flyBG.P=1e5 flyBG.Parent=hrp
        end
        flyBG.CFrame = Camera.CFrame
        local move = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then move += Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then move -= Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then move -= Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then move += Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.new(0,1,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then move -= Vector3.new(0,1,0) end
        flyBV.Velocity = (move.Magnitude > 0 and move.Unit or Vector3.zero) * S.movement.fly_s
    else destroyFly() end

    if S.movement.noclip_e or (S.movement.fly_e and S.movement.fly_nc) then
        local c = getChar()
        if c then
            for _,p in ipairs(c:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide=false end
            end
        end
    end

    if S.movement.avoid_e then
        local hrp = getHRP()
        if hrp and hrp.Position.Y < S.movement.avoid_f then
            hrp.CFrame = CFrame.new(0, S.movement.avoid_t, 0) * (hrp.CFrame - hrp.CFrame.Position)
        end
    end

    if S.movement.slowfall_e then
        local hrp = getHRP()
        if hrp and hrp.AssemblyLinearVelocity.Y < -5 then
            hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, -S.movement.slowfall_s/10, hrp.AssemblyLinearVelocity.Z)
        end
    end
end))

local function pickMovementTarget(method)
    local best, bestVal = nil, math.huge
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and alive(plr)
           and (not S.movement.tp_team or not isTeammate(plr)) then
            local hrp = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
            local hum = plr.Character and plr.Character:FindFirstChildOfClass("Humanoid")
            if hrp and hum then
                local val
                if method == "closest" then
                    val = (hrp.Position - (getHRP() and getHRP().Position or Vector3.zero)).Magnitude
                elseif method == "lowest_hp" then val = hum.Health
                else val = math.random() end
                if val < bestVal then bestVal=val best=plr end
            end
        end
    end
    return best
end

local function doTeleport()
    local tgt = pickMovementTarget(S.movement.tp_method)
    if not tgt then return end
    local hrp = getHRP() if not hrp then return end
    local tp = tgt.Character and tgt.Character:FindFirstChild("HumanoidRootPart") if not tp then return end
    local offset = Vector3.new(0, S.movement.tp_y, 0)
    if S.movement.tp_pred then offset = offset + tp.AssemblyLinearVelocity * 0.15 end
    hrp.CFrame = CFrame.new(tp.Position + offset) * (hrp.CFrame - hrp.CFrame.Position)
end

-- ============================================================================
-- WORLD
-- ============================================================================
local function ensureEffect(name, class)
    local e = Lighting:FindFirstChild(name)
    if not e then e=Instance.new(class) e.Name=name e.Parent=Lighting end
    return e
end

bin(RunService.RenderStepped:Connect(function()
    if S.world.fov_e then Camera.FieldOfView = S.world.fov_v end

    local atm = ensureEffect("UEV3_Atmosphere","Atmosphere")
    atm.Enabled = S.world.atm_e
    if S.world.atm_e then
        atm.Density=S.world.atm_d atm.Offset=S.world.atm_o
        atm.Color=S.world.atm_color atm.Decay=S.world.atm_decay
        atm.Glare=S.world.atm_glare atm.Haze=S.world.atm_haze
    end

    local cc = ensureEffect("UEV3_CC","ColorCorrectionEffect")
    cc.Enabled = S.world.cc_e
    if S.world.cc_e then
        cc.Brightness=S.world.cc_br cc.Contrast=S.world.cc_con
        cc.Saturation=S.world.cc_sat cc.TintColor=S.world.cc_tint
    end

    local bl = ensureEffect("UEV3_Bloom","BloomEffect")
    bl.Enabled = S.world.bloom_e
    if S.world.bloom_e then bl.Intensity=S.world.bloom_i bl.Size=S.world.bloom_s bl.Threshold=S.world.bloom_t end

    local blur = ensureEffect("UEV3_Blur","BlurEffect")
    blur.Enabled = S.world.blur_e
    if S.world.blur_e then blur.Size=S.world.blur_s end

    local sr = ensureEffect("UEV3_SunRays","SunRaysEffect")
    sr.Enabled = S.world.sunrays_e
    if S.world.sunrays_e then sr.Intensity=S.world.sunrays_i end

    local dof = ensureEffect("UEV3_DOF","DepthOfFieldEffect")
    dof.Enabled = S.world.dof_e
    if S.world.dof_e then dof.FocusDistance=S.world.dof_f end

    if S.world.sky_e then
        local sky = Lighting:FindFirstChild("UEV3_Sky")
        if not sky then sky=Instance.new("Sky") sky.Name="UEV3_Sky" sky.Parent=Lighting end
        local tbl = skyboxes[S.world.sky_preset]
        if tbl then
            sky.SkyboxBk="rbxassetid://"..tbl.Bk sky.SkyboxDn="rbxassetid://"..tbl.Dn
            sky.SkyboxFt="rbxassetid://"..tbl.Ft sky.SkyboxLf="rbxassetid://"..tbl.Lf
            sky.SkyboxRt="rbxassetid://"..tbl.Rt sky.SkyboxUp="rbxassetid://"..tbl.Up
        end
        sky.SunAngularSize = S.world.sky_rs and 0 or 11
        sky.MoonAngularSize = S.world.sky_rm and 0 or 11
        sky.StarCount = S.world.sky_rst and 0 or 3000
    else
        local sky = Lighting:FindFirstChild("UEV3_Sky") if sky then sky:Destroy() end
    end

    if S.world.amb_e then Lighting.Ambient = S.world.amb_color Lighting.OutdoorAmbient = S.world.amb_color end
    if S.world.time_e then Lighting.ClockTime = S.world.time_h end
    if S.world.fog_e then Lighting.FogEnd = 1e6 end
end))

-- ============================================================================
-- OPTIMIZATIONS
-- ============================================================================
bin(task.spawn(function()
    while task.wait(1) do
        if S.optim.no_part then
            for _,v in ipairs(Workspace:GetDescendants()) do
                if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") then v.Enabled=false end
            end
        end
        if S.optim.no_shad then
            for _,v in ipairs(Workspace:GetDescendants()) do
                if v:IsA("BasePart") then v.CastShadow=false end
            end
        end
        if S.optim.no_tex then
            for _,v in ipairs(Workspace:GetDescendants()) do
                if v:IsA("Texture") or v:IsA("Decal") then v.Transparency=1 end
            end
        end
        if S.optim.low_q then pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level01 end) end
        if S.optim.fps_cap_e and setfpscap then setfpscap(S.optim.fps_cap) end
        if S.optim.no_snd then
            for _,v in ipairs(game:GetDescendants()) do
                if v:IsA("Sound") then v.Volume=0 end
            end
        end
        if S.optim.destroy_fx then
            for _,v in ipairs(Workspace:GetDescendants()) do
                if v:IsA("Explosion") or v:IsA("PointLight") or v:IsA("SpotLight") then v:Destroy() end
            end
        end
    end
end))

-- ============================================================================
-- GUN MODS
-- ============================================================================
pcall(function()
    local gm_hooked = false
    bin(RunService.Heartbeat:Connect(function()
        if not S.misc.gm_e then return end
        local ok, lib = pcall(require, ReplicatedStorage.Modules.ItemLibrary)
        if ok and lib and lib.Items then
            for _, item in pairs(lib.Items) do
                if type(item) == "table" then
                    if S.misc.gm_spread then item.ShootSpread=0 item.ShootAccuracy=0 end
                    if S.misc.gm_recoil then item.ShootRecoil=0 end
                    if S.misc.gm_cd then
                        item.ShootCooldown=0.001 item.ShootBurstCooldown=0.001
                        item.AttackCooldown=0 item.SwingCooldown=0 item.MeleeCooldown=0
                        item.Cooldown=0 item.RecoveryTime=0
                    end
                    if S.misc.gm_proj > 0 then item.ProjectileSpeed=S.misc.gm_proj end
                    if S.misc.gm_os then item.Damage=999 end
                end
            end
        end
        if not gm_hooked then
            local ok2, ci = pcall(require, LocalPlayer.PlayerScripts.Modules.ClientReplicatedClasses.ClientFighter.ClientItem)
            if ok2 and ci and ci.Input then
                gm_hooked = true
                local orig = ci.Input
                ci.Input = function(self, ...)
                    if S.misc.gm_e and self and self.Info then
                        self.Info.ShootRecoil=0 self.Info.ShootSpread=0
                        self.Info.ShootCooldown=0 self.Info.QuickShotCooldown=0
                    end
                    return orig(self, ...)
                end
            end
        end
    end))
end)

-- ============================================================================
-- WATERMARK
-- ============================================================================
local wmGui = Instance.new("ScreenGui")
wmGui.Name="UEV3_Watermark" wmGui.ResetOnSpawn=false wmGui.IgnoreGuiInset=true
pcall(function() wmGui.Parent = (gethui and gethui()) or game:GetService("CoreGui") end)
bin(wmGui)

local wmFrame = Instance.new("Frame")
wmFrame.Size = UDim2.new(0, 280, 0, 24)
wmFrame.Position = UDim2.new(0, 10, 0, 10)
wmFrame.BackgroundColor3 = Color3.fromRGB(13,13,15)
wmFrame.BorderSizePixel = 0
wmFrame.Parent = wmGui
Instance.new("UICorner", wmFrame).CornerRadius = UDim.new(0,4)
local wmStroke = Instance.new("UIStroke", wmFrame) wmStroke.Color=Color3.fromRGB(196,30,58) wmStroke.Thickness=1
local wmAccent = Instance.new("Frame")
wmAccent.Size = UDim2.new(0, 3, 1, 0)
wmAccent.BackgroundColor3 = Color3.fromRGB(196,30,58) wmAccent.BorderSizePixel = 0
wmAccent.Parent = wmFrame
local wmLabel = Instance.new("TextLabel")
wmLabel.BackgroundTransparency = 1
wmLabel.Size = UDim2.new(1,-10,1,0) wmLabel.Position = UDim2.new(0,8,0,0)
wmLabel.Font = Enum.Font.Code wmLabel.TextColor3 = Color3.fromRGB(235,235,240)
wmLabel.TextSize = 13 wmLabel.TextXAlignment = Enum.TextXAlignment.Left
wmLabel.Parent = wmFrame

local wmTick = 0
bin(RunService.Heartbeat:Connect(function(dt)
    wmTick = wmTick + dt
    if wmTick < 0.25 then return end wmTick = 0
    if not S.misc.wm_e then wmGui.Enabled=false return end
    wmGui.Enabled = true
    local fps = math.floor(1 / math.max(RunService.RenderStepped:Wait(), 0.001))
    local ping = math.floor(LocalPlayer:GetNetworkPing() * 1000)
    wmLabel.Text = string.format(" UE V3 | %d fps | %d ms | %s", fps, ping, os.date("%H:%M:%S"))
    local positions = {
        top_left     = UDim2.new(0, 10, 0, 10),
        top_right    = UDim2.new(1, -290, 0, 10),
        bottom_left  = UDim2.new(0, 10, 1, -34),
        bottom_right = UDim2.new(1, -290, 1, -34),
    }
    wmFrame.Position = positions[S.misc.wm_pos] or positions.top_left
end))

-- ============================================================================
-- HIT SOUNDS
-- ============================================================================
local function playHit()
    if not S.misc.hs_e then return end
    local id = S.misc.hs_custom ~= "" and ("rbxassetid://"..S.misc.hs_custom)
               or ("rbxassetid://"..(hitSounds[S.misc.hs_id] or hitSounds.hitmarker))
    playSound(id, S.misc.hs_v, S.misc.hs_p)
end

pcall(function()
    for _, v in ipairs(ReplicatedStorage:GetDescendants()) do
        if v:IsA("RemoteEvent") then
            local n = v.Name:lower()
            if n:find("hit") then v.OnClientEvent:Connect(function() playHit() end) end
        end
    end
end)

-- ============================================================================
-- ANTI-AFK
-- ============================================================================
LocalPlayer.Idled:Connect(function()
    if not S.misc.afk then return end
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

-- ============================================================================
-- UNLOAD
-- ============================================================================
getgenv().UEV3_UNLOAD = function()
    for _, t in ipairs(Trash) do
        pcall(function()
            if typeof(t) == "RBXScriptConnection" then t:Disconnect()
            elseif typeof(t) == "Instance" then t:Destroy()
            elseif type(t) == "function" then t() end
        end)
    end
    for plr,_ in pairs(espCache) do pcall(function() killEsp(plr) end) end
    pcall(function() Library:Unload() end)
    getgenv().UEV3_LOADED = nil
end

bin(UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode[S.panic.key] then getgenv().UEV3_UNLOAD() end
end))

-- ============================================================================
-- GUI BUILD — RAGE TAB
-- ============================================================================
do
    local g = LGroup(Tabs.Rage, "Ragebot")
    Toggle(g, "rb_e",     "Enabled",       false, function(v) S.ragebot.enable=v end)
    Toggle(g, "rb_shoot", "Auto Shoot",    true,  function(v) S.ragebot.autoshoot=v end)
    Toggle(g, "rb_scope", "Auto Scope",    true,  function(v) S.ragebot.autoscope=v end)
    Toggle(g, "rb_pred",  "Prediction",    true,  function(v) S.ragebot.prediction=v end)
    Toggle(g, "rb_team",  "Team Check",    true,  function(v) S.ragebot.team_check=v end)
    Toggle(g, "rb_body",  "Force Body",    false, function(v) S.ragebot.force_body=v end)
    Slider(g, "rb_hc",    "Hitchance",     70, 0, 100, 0, function(v) S.ragebot.hitchance=v end)
    Slider(g, "rb_tp",    "TP Duration",   0.15, 0, 1, 2, function(v) S.ragebot.tp_duration=v end)
    Slider(g, "rb_y",     "Y Offset",      3, -10, 10, 1, function(v) S.ragebot.y_offset=v end)
    Slider(g, "rb_range", "Max Range",     2000, 100, 5000, 0, function(v) S.ragebot.max_range=v end)
    Dropdown(g, "rb_prio","Priority", {"distance","lowest_hp"}, "distance", function(v) S.ragebot.priority=v end)
end

do
    local g = RGroup(Tabs.Rage, "Anti-Aim")
    Toggle(g, "aa_e",     "Enabled", false, function(v) S.anti_aim.enable=v end)
    Dropdown(g, "aa_p",   "Pitch", {"Off","Up","Down","Zero"}, "Down", function(v) S.anti_aim.pitch=v end)
    Dropdown(g, "aa_y",   "Yaw",   {"Off","Spin","Jitter","Backward","Random"}, "Spin", function(v) S.anti_aim.yaw=v end)
    Slider(g, "aa_speed", "Yaw Speed", 6, 1, 60, 0, function(v) S.anti_aim.yaw_speed=v end)
end

do
    local g = LGroup(Tabs.Rage, "Silent Aim")
    Toggle(g, "sa_e",    "Enabled", false, function(v) S.silent.enable=v end)
    Toggle(g, "sa_fov",  "Show FOV", true, function(v) S.silent.show_fov=v end)
    Slider(g, "sa_fov_r","FOV Radius", 300, 20, 800, 0, function(v) S.silent.fov=v end)
    Slider(g, "sa_hc",   "Hit Chance", 70, 0, 100, 0, function(v) S.silent.hitchance=v end)
    Dropdown(g, "sa_part","Hit Part", {"Head","Torso","HumanoidRootPart","UpperTorso"}, "Head", function(v) S.silent.hit_part=v end)
    Toggle(g, "sa_team", "Team Check", true, function(v) S.silent.team_check=v end)
    ColorPicker(g, "sa_c", "FOV Color", Color3.fromRGB(255,255,255), function(v) S.silent.fov_color=v end)
end

-- ============================================================================
-- GUI BUILD — LEGIT TAB
-- ============================================================================
do
    local g = LGroup(Tabs.Legit, "Aimbot")
    Toggle(g, "aim_e",    "Enabled", false, function(v) S.aimbot.enable=v end)
    KeyPicker(g, "aimbot_key", "Aim Key", "MouseButton2", "Hold")
    Toggle(g, "aim_fov",  "Show FOV", true, function(v) S.aimbot.show_fov=v end)
    Slider(g, "aim_fov_r","FOV Radius", 180, 10, 600, 0, function(v) S.aimbot.fov=v end)
    Slider(g, "aim_sm",   "Smoothing", 3, 1, 100, 0, function(v) S.aimbot.smoothing=v end)
    Slider(g, "aim_pred", "Prediction", 0.165, 0, 0.5, 3, function(v) S.aimbot.prediction=v end)
    Slider(g, "aim_dist", "Max Distance", 1500, 100, 5000, 0, function(v) S.aimbot.max_dist=v end)
    Dropdown(g, "aim_part","Hit Part", {"Head","Torso","HumanoidRootPart","UpperTorso"}, "Head", function(v) S.aimbot.hit_part=v end)
    Toggle(g, "aim_vis",  "Visible Only", false, function(v) S.aimbot.visible_only=v end)
    Toggle(g, "aim_team", "Team Check", true, function(v) S.aimbot.team_check=v end)
    Toggle(g, "aim_snap", "Snapline", false, function(v) S.aimbot.snapline=v end)
    Toggle(g, "aim_snd",  "Lock Sound", false, function(v) S.aimbot.lock_sound=v end)
    ColorPicker(g, "aim_c", "FOV Color", Color3.fromRGB(196,30,58), function(v) S.aimbot.fov_color=v end)
    ColorPicker(g, "aim_sc", "Snap Color", Color3.fromRGB(255,255,255), function(v) S.aimbot.snapline_color=v end)
end

do
    local g = RGroup(Tabs.Legit, "Triggerbot")
    Toggle(g, "tb_e",    "Enabled", false, function(v) S.triggerbot.enable=v end)
    Toggle(g, "tb_team", "Team Check", true, function(v) S.triggerbot.team_check=v end)
    Toggle(g, "tb_head", "Headshot Only", false, function(v) S.triggerbot.headshot_only=v end)
    Toggle(g, "tb_burst","Burst Fire", false, function(v) S.triggerbot.burst=v end)
    Slider(g, "tb_react","Reaction", 0.05, 0, 0.5, 3, function(v) S.triggerbot.reaction=v end)
    Slider(g, "tb_delay","Fire Delay", 0.1, 0, 1, 3, function(v) S.triggerbot.delay=v end)
    Slider(g, "tb_dist", "Max Distance", 600, 50, 2500, 0, function(v) S.triggerbot.max_dist=v end)
end

do
    local g = LGroup(Tabs.Legit, "Crosshair")
    Toggle(g, "xh_e",    "Enabled", false, function(v) S.crosshair.enable=v end)
    Slider(g, "xh_len",  "Length", 6, 1, 40, 0, function(v) S.crosshair.length=v end)
    Slider(g, "xh_gap",  "Gap", 3, 0, 30, 0, function(v) S.crosshair.gap=v end)
    Slider(g, "xh_th",   "Thickness", 1, 1, 6, 0, function(v) S.crosshair.thickness=v end)
    Toggle(g, "xh_dot",  "Dot", false, function(v) S.crosshair.dot=v end)
    Toggle(g, "xh_circ", "Circle", false, function(v) S.crosshair.circle=v end)
    Slider(g, "xh_cr",   "Circle Radius", 14, 4, 60, 0, function(v) S.crosshair.circle_radius=v end)
    Toggle(g, "xh_pulse","Pulse", false, function(v) S.crosshair.pulse=v end)
    Toggle(g, "xh_rb",   "Rainbow", false, function(v) S.crosshair.rainbow=v end)
    ColorPicker(g, "xh_c", "Color", Color3.fromRGB(0,255,170), function(v) S.crosshair.color=v end)
    ColorPicker(g, "xh_dc", "Dot Color", Color3.fromRGB(255,255,255), function(v) S.crosshair.dot_color=v end)
end

-- ============================================================================
-- GUI BUILD — VISUALS TAB
-- ============================================================================
do
    local g = LGroup(Tabs.Visuals, "ESP Core")
    Toggle(g, "esp_e",      "Enabled", false, function(v) S.esp.enable=v end)
    Toggle(g, "esp_team",   "Team Check", true, function(v) S.esp.team_check=v end)
    Slider(g, "esp_dist",   "Max Distance", 1000, 50, 5000, 0, function(v) S.esp.max_dist=v end)
    Toggle(g, "esp_box",    "Box", true, function(v) S.esp.box_e=v end)
    Toggle(g, "esp_box_o",  "Box Outline", true, function(v) S.esp.box_outline=v end)
    Toggle(g, "esp_name",   "Name", true, function(v) S.esp.name_e=v end)
    Toggle(g, "esp_name_d", "Use DisplayName", true, function(v) S.esp.name_display=v end)
    Toggle(g, "esp_hp",     "Health Text", true, function(v) S.esp.hp_e=v end)
    Toggle(g, "esp_hpbar",  "HP Bar", true, function(v) S.esp.hp_bar=v end)
    Toggle(g, "esp_hpgrad", "HP Gradient", true, function(v) S.esp.hp_grad=v end)
    Toggle(g, "esp_dists",  "Distance", true, function(v) S.esp.dist_e=v end)
    Toggle(g, "esp_wep",    "Weapon", false, function(v) S.esp.wep_e=v end)
    Toggle(g, "esp_dot",    "Head Dot", false, function(v) S.esp.dot_e=v end)
    Toggle(g, "esp_skel",   "Skeleton", false, function(v) S.esp.skel_e=v end)
    ColorPicker(g, "esp_box_c", "Box Color", Color3.fromRGB(196,30,58), function(v) S.esp.box_color=v end)
    ColorPicker(g, "esp_name_c", "Name Color", Color3.fromRGB(255,255,255), function(v) S.esp.name_color=v end)
    ColorPicker(g, "esp_hp_c", "HP Color", Color3.fromRGB(80,220,80), function(v) S.esp.hp_color=v end)
end

do
    local g = RGroup(Tabs.Visuals, "Tracers / Chams / Arrow")
    Toggle(g, "esp_tr",   "Tracer", false, function(v) S.esp.tracer_e=v end)
    Dropdown(g, "esp_tro","Tracer Origin", {"bottom","middle","top"}, "bottom", function(v) S.esp.tracer_origin=v end)
    ColorPicker(g, "esp_tr_c", "Tracer Color", Color3.fromRGB(196,30,58), function(v) S.esp.tracer_color=v end)
    Toggle(g, "esp_hl",   "Highlight", true, function(v) S.esp.hl_e=v end)
    Slider(g, "esp_hl_t", "Highlight Transparency", 0.5, 0, 1, 2, function(v) S.esp.hl_fill_t=v end)
    ColorPicker(g, "esp_hl_c", "Highlight Fill", Color3.fromRGB(196,30,58), function(v) S.esp.hl_fill=v end)
    ColorPicker(g, "esp_hl_o", "Highlight Outline", Color3.fromRGB(255,255,255), function(v) S.esp.hl_outline=v end)
    Toggle(g, "esp_ch",   "Chams", false, function(v) S.esp.chams_e=v end)
    Dropdown(g, "esp_ch_m", "Chams Material", {"Neon","ForceField","Glass","Metal","Ice","Plastic"}, "ForceField", function(v) S.esp.chams_mat=v end)
    Slider(g, "esp_ch_t", "Chams Transparency", 0, 0, 1, 2, function(v) S.esp.chams_t=v end)
    ColorPicker(g, "esp_ch_c", "Chams Color", Color3.fromRGB(196,30,58), function(v) S.esp.chams_color=v end)
    Toggle(g, "esp_arr",  "Offscreen Arrow", false, function(v) S.esp.arrow_e=v end)
    Slider(g, "esp_arr_r","Arrow Radius", 200, 80, 400, 0, function(v) S.esp.arrow_radius=v end)
    ColorPicker(g, "esp_arr_c", "Arrow Color", Color3.fromRGB(196,30,58), function(v) S.esp.arrow_color=v end)
end

-- ============================================================================
-- GUI BUILD — WORLD TAB
-- ============================================================================
do
    local g = LGroup(Tabs.World, "Camera / Lighting")
    Toggle(g, "fov_e",  "FOV Changer", false, function(v) S.world.fov_e=v end)
    Slider(g, "fov_v",  "FOV", 90, 20, 120, 0, function(v) S.world.fov_v=v end)
    Toggle(g, "fog_e",  "Remove Fog", false, function(v) S.world.fog_e=v end)
    Toggle(g, "time_e", "Lock Time", false, function(v) S.world.time_e=v end)
    Slider(g, "time_h", "Hour", 12, 0, 24, 1, function(v) S.world.time_h=v end)
    Toggle(g, "amb_e",  "Ambient Override", false, function(v) S.world.amb_e=v end)
    ColorPicker(g, "amb_c", "Ambient Color", Color3.fromRGB(128,128,128), function(v) S.world.amb_color=v end)
end

do
    local g = RGroup(Tabs.World, "Atmosphere")
    Toggle(g, "atm_e", "Enabled", false, function(v) S.world.atm_e=v end)
    Slider(g, "atm_d", "Density", 0.3, 0, 1, 2, function(v) S.world.atm_d=v end)
    Slider(g, "atm_o", "Offset", 0.25, 0, 1, 2, function(v) S.world.atm_o=v end)
    Slider(g, "atm_g", "Glare", 0.2, 0, 3, 2, function(v) S.world.atm_glare=v end)
    Slider(g, "atm_h", "Haze", 1.5, 0, 10, 2, function(v) S.world.atm_haze=v end)
    ColorPicker(g, "atm_c", "Color", Color3.fromRGB(180,100,100), function(v) S.world.atm_color=v end)
    ColorPicker(g, "atm_dc", "Decay", Color3.fromRGB(80,20,20), function(v) S.world.atm_decay=v end)
end

do
    local g = LGroup(Tabs.World, "Color Correction / Post FX")
    Toggle(g, "cc_e",  "Color Correction", false, function(v) S.world.cc_e=v end)
    Slider(g, "cc_br", "Brightness", 0, -1, 1, 2, function(v) S.world.cc_br=v end)
    Slider(g, "cc_con","Contrast", 0.15, -1, 1, 2, function(v) S.world.cc_con=v end)
    Slider(g, "cc_sat","Saturation", 0.1, -1, 1, 2, function(v) S.world.cc_sat=v end)
    ColorPicker(g, "cc_t", "Tint", Color3.fromRGB(255,220,220), function(v) S.world.cc_tint=v end)
    Toggle(g, "bl_e",  "Bloom", false, function(v) S.world.bloom_e=v end)
    Slider(g, "bl_i",  "Bloom Intensity", 0.4, 0, 3, 2, function(v) S.world.bloom_i=v end)
    Toggle(g, "blur_e","Blur", false, function(v) S.world.blur_e=v end)
    Slider(g, "blur_s","Blur Size", 0, 0, 56, 0, function(v) S.world.blur_s=v end)
    Toggle(g, "sr_e",  "Sun Rays", false, function(v) S.world.sunrays_e=v end)
    Toggle(g, "dof_e", "Depth Of Field", false, function(v) S.world.dof_e=v end)
end

do
    local g = RGroup(Tabs.World, "Skybox")
    Toggle(g, "sky_e",   "Enabled", false, function(v) S.world.sky_e=v end)
    Dropdown(g, "sky_s", "Preset", {"DeepSpace","NebulaBlue","Sunset","Night","Purple","Realistic"}, "DeepSpace", function(v) S.world.sky_preset=v end)
    Toggle(g, "sky_rs",  "Remove Sun", false, function(v) S.world.sky_rs=v end)
    Toggle(g, "sky_rm",  "Remove Moon", false, function(v) S.world.sky_rm=v end)
    Toggle(g, "sky_rst", "Remove Stars", false, function(v) S.world.sky_rst=v end)
end

-- ============================================================================
-- GUI BUILD — CHARACTER TAB
-- ============================================================================
do
    local g = LGroup(Tabs.Character, "Humanoid")
    Toggle(g, "ws_e",   "Walkspeed", false, function(v) S.character.ws_e=v end)
    Slider(g, "ws_v",   "Walkspeed Value", 20, 8, 200, 0, function(v) S.character.ws_v=v end)
    Toggle(g, "jp_e",   "Jump Power", false, function(v) S.character.jp_e=v end)
    Slider(g, "jp_v",   "Jump Power Value", 60, 30, 500, 0, function(v) S.character.jp_v=v end)
    Toggle(g, "gv_e",   "Gravity", false, function(v) S.character.gv_e=v end)
    Slider(g, "gv_v",   "Gravity Value", 196, 0, 400, 0, function(v) S.character.gv_v=v end)
    Toggle(g, "ij_e",   "Infinite Jump", false, function(v) S.character.infj=v end)
    Toggle(g, "bh_e",   "Auto Bhop", false, function(v) S.character.bhop=v end)
    Toggle(g, "god_e",  "God Mode", false, function(v) S.character.god=v end)
    Toggle(g, "heal_e", "Auto Heal", false, function(v) S.character.heal_e=v end)
    Slider(g, "heal_r", "Heal Rate", 1, 0.1, 10, 2, function(v) S.character.heal_r=v end)
    Toggle(g, "hip_e",  "HipHeight", false, function(v) S.character.hip_e=v end)
    Slider(g, "hip_v",  "HipHeight Value", 2, 0, 10, 2, function(v) S.character.hip_v=v end)
end

do
    local g = RGroup(Tabs.Character, "Hitbox Expander")
    Toggle(g, "hb_e",   "Enabled", false, function(v) S.character.hitbox_e=v end)
    Slider(g, "hb_s",   "Hitbox Size", 5, 1, 30, 0, function(v) S.character.hitbox_s=v end)
    Dropdown(g, "hb_p", "Hitbox Part", {"Head","HumanoidRootPart","UpperTorso"}, "Head", function(v) S.character.hitbox_p=v end)
end

-- ============================================================================
-- GUI BUILD — MOVEMENT TAB
-- ============================================================================
do
    local g = LGroup(Tabs.Movement, "Fly / Noclip")
    Toggle(g, "fly_e",  "Fly", false, function(v) S.movement.fly_e=v end)
    Slider(g, "fly_s",  "Fly Speed", 50, 10, 500, 0, function(v) S.movement.fly_s=v end)
    Toggle(g, "fly_nc", "Fly Noclip", false, function(v) S.movement.fly_nc=v end)
    Toggle(g, "nc_e",   "Noclip", false, function(v) S.movement.noclip_e=v end)
end

do
    local g = RGroup(Tabs.Movement, "Teleport / Underground")
    KeyPicker(g, "tp_key", "TP Key", "T", "Toggle")
    Dropdown(g, "tp_m", "TP Method", {"closest","lowest_hp","random"}, "closest", function(v) S.movement.tp_method=v end)
    Slider(g, "tp_y",   "TP Y Offset", 0, -20, 20, 1, function(v) S.movement.tp_y=v end)
    Toggle(g, "tp_t",   "TP Team Check", true, function(v) S.movement.tp_team=v end)
    Toggle(g, "tp_p",   "TP Prediction", true, function(v) S.movement.tp_pred=v end)
    Toggle(g, "ug_e",   "Underground", false, function(v) S.movement.ug_e=v end)
    Slider(g, "ug_d",   "UG Depth", 5.8, 1, 20, 1, function(v) S.movement.ug_d=v end)
    Toggle(g, "av_e",   "Anti Void", false, function(v) S.movement.avoid_e=v end)
    Toggle(g, "sf_e",   "Slow Fall", false, function(v) S.movement.slowfall_e=v end)
    Slider(g, "sf_s",   "Slow Fall Strength", 100, 10, 500, 0, function(v) S.movement.slowfall_s=v end)
end

bin(task.spawn(function()
    while task.wait(0.1) do
        if Library.Options.tp_key and Library.Options.tp_key:GetState() then
            doTeleport() task.wait(0.4)
        end
    end
end))

-- ============================================================================
-- GUI BUILD — MISC TAB
-- ============================================================================
do
    local g = LGroup(Tabs.Misc, "Gun Mods")
    Toggle(g, "gm_e",    "Enabled", false, function(v) S.misc.gm_e=v end)
    Toggle(g, "gm_rec",  "No Recoil", true, function(v) S.misc.gm_recoil=v end)
    Toggle(g, "gm_spr",  "No Spread", true, function(v) S.misc.gm_spread=v end)
    Toggle(g, "gm_cd",   "No Cooldown", true, function(v) S.misc.gm_cd=v end)
    Toggle(g, "gm_os",   "One Shot", false, function(v) S.misc.gm_os=v end)
    Slider(g, "gm_proj", "Projectile Speed", 0, 0, 10000, 0, function(v) S.misc.gm_proj=v end)
end

do
    local g = RGroup(Tabs.Misc, "Sounds / UI")
    Toggle(g, "hs_e",    "Hit Sounds", false, function(v) S.misc.hs_e=v end)
    Dropdown(g, "hs_id", "Hit Sound", {"hitmarker","rust","skeet","bell","minecraft","bone","ding","glass","pop","tick"}, "hitmarker", function(v) S.misc.hs_id=v end)
    Slider(g, "hs_v",    "Volume", 1, 0, 5, 2, function(v) S.misc.hs_v=v end)
    Slider(g, "hs_p",    "Pitch", 1, 0.5, 3, 2, function(v) S.misc.hs_p=v end)
    Input(g, "hs_c",     "Custom Hit ID", "", function(v) S.misc.hs_custom=v end)
    Toggle(g, "wm_e",    "Watermark", true, function(v) S.misc.wm_e=v end)
    Dropdown(g, "wm_p",  "Watermark Position", {"top_left","top_right","bottom_left","bottom_right"}, "top_left", function(v) S.misc.wm_pos=v end)
    Toggle(g, "afk_e",   "Anti AFK", true, function(v) S.misc.afk=v end)
    Toggle(g, "notif",   "Notifications", true, function(v) S.misc.notif=v end)
end

-- ============================================================================
-- GUI BUILD — SCRIPTS TAB
-- ============================================================================
do
    local g = LGroup(Tabs.Scripts, "Utility Scripts")
    Button(g, "Infinite Yield", function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
    end)
    Button(g, "Dex Explorer", function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/dex.lua"))()
    end)
    Button(g, "Simple Spy", function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/exxtremestuffs/SimpleSpySource/master/SimpleSpy.lua"))()
    end)
    Button(g, "Hydroxide", function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Upbolt/Hydroxide/master/main.lua"))()
    end)
end

do
    local g = RGroup(Tabs.Scripts, "Server / Performance")
    Button(g, "FPS Booster", function()
        for _,v in pairs(Workspace:GetDescendants()) do
            if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") then v.Enabled=false end
            if v:IsA("Texture") or v:IsA("Decal") then v.Transparency=1 end
        end
        pcall(function() settings().Rendering.QualityLevel=1 end)
        Lighting.GlobalShadows = false
        notify("FPS Booster applied", 3)
    end)
    Button(g, "Rejoin Server", function()
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end)
    Button(g, "Server Hop", function()
        local ok, res = pcall(function()
            return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?limit=100"))
        end)
        if ok and res and res.data then
            local servers = {}
            for _,s in ipairs(res.data) do
                if s.playing < s.maxPlayers and s.id ~= game.JobId then servers[#servers+1] = s.id end
            end
            if #servers > 0 then TeleportService:TeleportToPlaceInstance(game.PlaceId, servers[math.random(1,#servers)], LocalPlayer) end
        end
    end)
end

-- ============================================================================
-- GUI BUILD — SPOOFER TAB
-- ============================================================================
do
    local g = LGroup(Tabs.Spoofer, "Account Spoof")
    Toggle(g, "spf_n", "Spoof Name", false, function(v) S.spoofer.name_e=v end)
    Input(g, "spf_nv", "Name Value", "", function(v) S.spoofer.name_v=v end)
    Toggle(g, "spf_d", "Spoof Display", false, function(v) S.spoofer.display_e=v end)
    Input(g, "spf_dv", "Display Value", "", function(v) S.spoofer.display_v=v end)
    Toggle(g, "spf_l", "Spoof Level", false, function(v) S.spoofer.level_e=v end)
    Slider(g, "spf_lv","Level", 9, 0, 999, 0, function(v) S.spoofer.level_v=v end)
end

do
    local g = RGroup(Tabs.Spoofer, "Stats Spoof")
    Toggle(g, "spf_s", "Spoof Streak", false, function(v) S.spoofer.streak_e=v end)
    Slider(g, "spf_sv","Streak", 9, 0, 999, 0, function(v) S.spoofer.streak_v=v end)
    Toggle(g, "spf_r", "Spoof Rank", false, function(v) S.spoofer.rank_e=v end)
    Input(g, "spf_rv", "Rank Value", "GM", function(v) S.spoofer.rank_v=v end)
    Toggle(g, "spf_w", "Spoof Wins", false, function(v) S.spoofer.wins_e=v end)
    Slider(g, "spf_wv","Wins", 9999, 0, 99999, 0, function(v) S.spoofer.wins_v=v end)
end

-- ============================================================================
-- GUI BUILD — OPTIMIZATIONS TAB
-- ============================================================================
do
    local g = LGroup(Tabs.Optim, "Performance")
    Toggle(g, "op_part", "No Particles", false, function(v) S.optim.no_part=v end)
    Toggle(g, "op_shad", "No Shadows", false, function(v) S.optim.no_shad=v end)
    Toggle(g, "op_tex",  "No Textures", false, function(v) S.optim.no_tex=v end)
    Toggle(g, "op_low",  "Low Quality", false, function(v) S.optim.low_q=v end)
    Toggle(g, "op_snd",  "Disable Sounds", false, function(v) S.optim.no_snd=v end)
    Toggle(g, "op_dfx",  "Destroy Map FX", false, function(v) S.optim.destroy_fx=v end)
    Toggle(g, "op_cap_e","FPS Cap", false, function(v) S.optim.fps_cap_e=v end)
    Slider(g, "op_cap_v","FPS Cap Value", 240, 30, 360, 0, function(v) S.optim.fps_cap=v end)
end

-- ============================================================================
-- GUI BUILD — CONFIG TAB
-- ============================================================================
do
    local g = LGroup(Tabs.Config, "UI Settings")
    KeyPicker(g, "menu_key", "Menu Toggle", "RightShift", "Toggle")
    KeyPicker(g, "panic_key", "Panic Unload", "End", "Toggle")
    Button(g, "Unload UE V3", function() getgenv().UEV3_UNLOAD() end)
    Button(g, "Rejoin Server", function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end)
end

do
    local g = RGroup(Tabs.Config, "Info")
    Label(g, "Unnamed Enhancements V3")
    Label(g, "Built by Olivia")
    Label(g, "discord.gg/ojailbreaks")
    Label(g, " ")
    Label(g, "Press End to panic unload")
end

-- ============================================================================
-- THEME + SAVE
-- ============================================================================
pcall(function()
    ThemeManager:SetLibrary(Library)
    SaveManager:SetLibrary(Library)
    SaveManager:IgnoreThemeSettings()
    SaveManager:SetIgnoreIndexes({"menu_key","panic_key"})
    ThemeManager:SetFolder("UnnamedEnhancementsV3")
    SaveManager:SetFolder("UnnamedEnhancementsV3/Rivals")
    SaveManager:BuildConfigSection(Tabs.Config)
    ThemeManager:ApplyToTab(Tabs.Config)
    SaveManager:LoadAutoloadConfig()
end)

Library:OnUnload(function()
    getgenv().UEV3_LOADED = nil
end)

notify("Unnamed Enhancements V3  |  Rivals loaded — discord.gg/ojailbreaks", 5)
print("[UE V3] Loaded — Built by Olivia — https://discord.gg/ojailbreaks")
