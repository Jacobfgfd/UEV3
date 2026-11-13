-- ============================================================================
-- Unnamed Enhancements V3  |  Rivals
-- UE skin · deep stack · one-file loadstring
-- Built by Olivia — https://discord.gg/ojailbreaks
-- ============================================================================

local HttpService      = game:GetService("HttpService")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players          = game:GetService("Players")
local Lighting         = game:GetService("Lighting")
local ReplicatedStorage= game:GetService("ReplicatedStorage")
local CollectionService= game:GetService("CollectionService")
local TweenService     = game:GetService("TweenService")
local StarterGui       = game:GetService("StarterGui")
local SoundService     = game:GetService("SoundService")
local VirtualUser      = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer
local Camera      = workspace.CurrentCamera
local Mouse       = LocalPlayer:GetMouse()

if getgenv().UEV3_LOADED then
    pcall(function() getgenv().UEV3_UNLOAD() end)
end
getgenv().UEV3_LOADED = true

-- ============================================================================
-- antidetect + env shaping
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
    local real_rawlen
    real_rawlen = hookfunction(rawlen, newcclosure(function(t)
        if type(t) == "table" then
            local s = getcallingscript()
            if s and s.Name == "MiscellaneousController" then return 3 end
        end
        return real_rawlen(t)
    end))
end)

task.spawn(function()
    pcall(function()
        local kill = {"anticheat","detection","ban","kick","security","moderation","report","sentry"}
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
-- Library (Linoria w/ UE red theme)
-- ============================================================================
local function fetch(url)
    local ok, body = pcall(function() return game:HttpGet(url) end)
    if not ok then return nil, body end
    local fn, err = loadstring(body)
    if not fn then return nil, err end
    return fn()
end

local Library       = fetch("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/Library.lua")
local ThemeManager  = fetch("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/addons/ThemeManager.lua")
local SaveManager   = fetch("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/addons/SaveManager.lua")
assert(Library, "[UEV3] library fetch failed")

Library.AccentColor     = Color3.fromRGB(196, 30, 58)
Library.BackgroundColor = Color3.fromRGB(13, 13, 15)
Library.MainColor       = Color3.fromRGB(20, 20, 23)
Library.OutlineColor    = Color3.fromRGB(45, 45, 50)
Library.FontColor       = Color3.fromRGB(235, 235, 240)

local Window = Library:CreateWindow({
    Title    = "Unnamed Enhancements V3  |  Rivals",
    Center   = true,
    AutoShow = true,
    TabPadding = 8,
    MenuFadeTime = 0.2,
})

local Tabs = {
    Combat    = Window:AddTab("Combat"),
    Ragebot   = Window:AddTab("Ragebot"),
    Visuals   = Window:AddTab("Visuals"),
    World     = Window:AddTab("World"),
    Character = Window:AddTab("Character"),
    Movement  = Window:AddTab("Movement"),
    Misc      = Window:AddTab("Misc"),
    Optim     = Window:AddTab("Optimizations"),
    Config    = Window:AddTab("UI / Config"),
}

-- ============================================================================
-- state
-- ============================================================================
getgenv().UEV3 = {
    aimbot = { enable=false, show_fov=true, fov=180, fov_color=Color3.fromRGB(196,30,58),
               smoothing=3, closest_part=false, visible_only=false, team_check=true,
               hit_part="Head", prediction=0.165, wallcheck=false, snapline=false,
               snapline_color=Color3.fromRGB(255,255,255), lock_sound=false,
               autowall=false, max_dist=1500 },
    silent = { enable=false, show_fov=true, fov=300, fov_color=Color3.fromRGB(255,255,255),
               hit_part="Head", team_check=true, hitchance=70, resolver=true,
               hit_random=false },
    ragebot = { enable=false, autoshoot=true, autoscope=true, tp_duration=0.15, y_offset=3,
                team_check=true, prediction=true, hitchance=70, double_tap=false,
                hide_shots=false, priority="distance" },
    triggerbot = { enable=false, team_check=true, reaction=0.05, delay=0.1, max_dist=600,
                   visible_only=true, headshot_only=false, burst=false },
    anti_aim = { enable=false, pitch="Down", yaw="Spin", yaw_speed=6, jitter=false,
                 fake_lag=false, fake_lag_amt=2, desync=false },
    esp = {
        enable=false, team_check=true, max_dist=1000, fade_dist=true,
        box={ enable=true, color=Color3.fromRGB(196,30,58), thickness=1, outline=true,
              corner=false, fill=false, fill_color=Color3.fromRGB(196,30,58), fill_t=0.8 },
        name={ enable=true, color=Color3.fromRGB(255,255,255), size=14, show_display=true },
        health={ enable=true, color=Color3.fromRGB(80,220,80), bar=true, show_text=true,
                 gradient=true },
        armor={ enable=false, color=Color3.fromRGB(80,160,255) },
        distance={ enable=true, color=Color3.fromRGB(200,200,200) },
        weapon={ enable=false, color=Color3.fromRGB(255,215,120) },
        tracer={ enable=false, color=Color3.fromRGB(196,30,58), origin="bottom", thickness=1 },
        head_dot={ enable=false, color=Color3.fromRGB(255,255,255), filled=true },
        skeleton={ enable=false, color=Color3.fromRGB(255,255,255), thickness=1 },
        highlight={ enable=true, fill=Color3.fromRGB(196,30,58), fill_t=0.5,
                    outline=Color3.fromRGB(255,255,255), outline_t=0 },
        chams={ enable=false, material="ForceField", color=Color3.fromRGB(196,30,58),
                transparency=0, ghost=false, strip=false, visible_color=Color3.fromRGB(80,220,80),
                invisible_color=Color3.fromRGB(196,30,58), split=false },
        offscreen_arrow={ enable=false, color=Color3.fromRGB(196,30,58), radius=200, size=14 },
        viewangle={ enable=false, color=Color3.fromRGB(255,255,255), length=6 },
    },
    world = {
        fov={ enable=false, value=90 },
        stretch={ enable=false, amount=0.2 },
        remove_fog=false,
        time_lock={ enable=false, hour=12 },
        atmosphere={ enable=false, density=0.3, offset=0.25,
                     color=Color3.fromRGB(180,100,100),
                     decay=Color3.fromRGB(80,20,20), glare=0.2, haze=1.5 },
        color_correction={ enable=false, brightness=0, contrast=0.15, saturation=0.1,
                           tint=Color3.fromRGB(255,220,220) },
        bloom={ enable=false, intensity=0.4, size=24, threshold=2 },
        blur={ enable=false, size=0 },
        sunrays={ enable=false, intensity=0.25, spread=1 },
        depthoffield={ enable=false, focus=5, blur=0.15, inFocus=20, far=100 },
        no_night=false,
        kill_bricks=false,
        skybox_remove=false,
    },
    character = {
        walkspeed={ enable=false, value=20 },
        jumppower={ enable=false, value=60 },
        gravity={ enable=false, value=196 },
        hipheight={ enable=false, value=2 },
        infjump={ enable=false },
        auto_bhop={ enable=false },
        no_slow={ enable=false },
        slide_boost={ enable=false, speed=60 },
        no_arm={ enable=false },
        no_viewmodel={ enable=false },
        viewmodel_offsets={ enable=false, x=0, y=0, z=0, fov=70 },
        weapon_chams={ enable=false, color=Color3.fromRGB(255,255,255),
                       material="Neon", transparency=0 },
        arm_chams={ enable=false, color=Color3.fromRGB(255,255,255),
                    material="Neon", transparency=0, invisible=false },
        hitbox_expander={ enable=false, size=5, part="Head" },
    },
    movement = {
        fly={ enable=false, speed=50, noclip=false, mode="cframe" },
        freecam={ enable=false, speed=20 },
        noclip={ enable=false },
        teleport={ enable=false, method="closest", y_offset=0, team_check=true, prediction=true },
        underground={ enable=false, depth=5.8 },
        speed_glitch={ enable=false, multiplier=2 },
        waypoint_save={}, -- user-saved CFrames
    },
    misc = {
        gun_mods={ enable=false, no_recoil=true, no_spread=true, no_cooldown=true,
                   inf_ammo=false, rapid=false, proj_speed=0, pierce=false },
        unlock_all=false,
        hitsounds={ enable=false, id="hitmarker", volume=1, pitch=1, custom="" },
        killsound={ enable=false, id="rust", volume=1 },
        damage_numbers={ enable=false, color1=Color3.fromRGB(255,80,80),
                         color2=Color3.fromRGB(255,200,80), mode="Gradient",
                         size=18, duration=0.8, rise=42, remove_ingame=true,
                         crit_color=Color3.fromRGB(255,255,0) },
        kill_effect={ enable=false, type="Explosion", color=Color3.fromRGB(196,30,58) },
        spoof_level={ enable=false, value=9 },
        spoof_streak={ enable=false, value=9 },
        spoof_name={ enable=false, value="" },
        device_spoof={ enable=false, type="MouseKeyboard" },
        auto_reconnect=false, auto_rejoin=false,
        anti_afk=true,
        chat_bypass=false,
        server_hop=false,
        notifications=true,
        clock_enable=true,
        keybinds_display=true,
        watermark=true,
    },
    crosshair = {
        enable=false, style="cross", length=6, thickness=1, gap=3, rotation=0,
        color=Color3.fromRGB(0,255,170), outline=true, outline_color=Color3.fromRGB(0,0,0),
        dot=false, dot_color=Color3.fromRGB(255,255,255),
        rotating=false, rotating_speed=120,
        pulse=false, pulse_speed=3,
        follow_target=false,
        rainbow=false, rainbow_speed=1,
        t_shape=false, circle=false, circle_radius=14,
    },
    optim = {
        no_particles=false, no_shadows=false, low_quality=false, no_postfx=false,
        no_textures=false, no_atmosphere=false, fps_boost=false,
        fps_cap_enable=false, fps_cap=240,
        disable_sounds=false, disable_decals=false,
        clean_ragdolls=false, cull_distant=false, cull_distance=500,
    },
    panic = { key="End" },
}
local S = getgenv().UEV3
local Trash = {} -- cleanup bucket
local function bin(x) Trash[#Trash+1] = x return x end

-- ============================================================================
-- helpers
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

local function visibleTo(part)
    if not part then return false end
    local origin = Camera.CFrame.Position
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = { LocalPlayer.Character, part.Parent }
    params.FilterType = Enum.RaycastFilterType.Exclude
    local r = workspace:Raycast(origin, (part.Position - origin), params)
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
    if not S.misc.notifications then return end
    pcall(function() Library:Notify(text, duration or 3) end)
end

-- ============================================================================
-- AIMBOT (FOV, smoothing, predict, snapline, lock sound)
-- ============================================================================
local aimCircle = Drawing.new("Circle")
aimCircle.Thickness=1 aimCircle.NumSides=64 aimCircle.Filled=false aimCircle.Visible=false
bin(aimCircle)

local snapLine = Drawing.new("Line")
snapLine.Thickness=1 snapLine.Visible=false
bin(snapLine)

local function bestTarget(cfg)
    local center = Camera.ViewportSize / 2
    local best, bestDist = nil, cfg.fov
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and alive(plr) and (not cfg.team_check or not isTeammate(plr)) then
            local part = plr.Character:FindFirstChild(cfg.hit_part or "Head")
            if part then
                local d3 = (part.Position - Camera.CFrame.Position).Magnitude
                if d3 <= cfg.max_dist then
                    if (not cfg.visible_only) or visibleTo(part) then
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

    local tgt = bestTarget(S.aimbot)
    if not tgt then snapLine.Visible=false lockedLast=nil return end
    local part = tgt.Character and tgt.Character:FindFirstChild(S.aimbot.hit_part or "Head")
    if not part then snapLine.Visible=false return end

    local target = predict(part, S.aimbot.prediction or 0)
    local smooth = math.clamp((101 - math.clamp(S.aimbot.smoothing,1,100)) / 100, 0.02, 1)
    local look   = (target - Camera.CFrame.Position).Unit
    local blend  = Camera.CFrame.LookVector:Lerp(look, smooth)
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
        pcall(function()
            local s = Instance.new("Sound")
            s.SoundId = "rbxassetid://3779005184"
            s.Volume = 0.6
            s.Parent = SoundService
            s:Play()
            game:GetService("Debris"):AddItem(s, 1)
        end)
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
        local r = workspace:Raycast(Camera.CFrame.Position,
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
-- SILENT AIM — hooks UseItem.FireServer
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
-- ESP  — box, name, hp, hp bar, armor, dist, weapon, tracer, dot, skeleton,
--        highlight, chams, offscreen arrow, view angle
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
        box      = Drawing.new("Square"),
        box_out  = Drawing.new("Square"),
        name     = Drawing.new("Text"),
        health   = Drawing.new("Text"),
        hp_bar   = Drawing.new("Line"),
        hp_bar_bg= Drawing.new("Line"),
        armor    = Drawing.new("Text"),
        dist     = Drawing.new("Text"),
        weapon   = Drawing.new("Text"),
        tracer   = Drawing.new("Line"),
        dot      = Drawing.new("Circle"),
        arrow_a  = Drawing.new("Line"),
        arrow_b  = Drawing.new("Line"),
        arrow_c  = Drawing.new("Line"),
        skeleton = {},
    }
    for i=1,#skeletonLinks do
        local l = Drawing.new("Line") l.Thickness=1 l.Visible=false
        e.skeleton[i] = l
    end
    e.box.Filled=false     e.box.Thickness=1     e.box.Visible=false
    e.box_out.Filled=false e.box_out.Thickness=3 e.box_out.Color=Color3.new(0,0,0) e.box_out.Visible=false
    for _,t in ipairs({e.name,e.health,e.dist,e.weapon,e.armor}) do
        t.Size=14 t.Center=true t.Outline=true t.Visible=false t.Font=Drawing.Fonts.Plex
    end
    e.hp_bar.Thickness=2    e.hp_bar.Visible=false
    e.hp_bar_bg.Thickness=4 e.hp_bar_bg.Color=Color3.new(0,0,0) e.hp_bar_bg.Visible=false
    e.tracer.Thickness=1    e.tracer.Visible=false
    e.dot.NumSides=16 e.dot.Radius=3 e.dot.Thickness=1 e.dot.Filled=true e.dot.Visible=false
    for _,a in ipairs({e.arrow_a,e.arrow_b,e.arrow_c}) do a.Thickness=1 a.Visible=false end
    return e
end

local function killEsp(plr)
    local e = espCache[plr] if not e then return end
    for _,d in pairs(e) do
        if typeof(d) == "table" then
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
        if typeof(d) == "table" then
            for _,ln in ipairs(d) do ln.Visible=false end
        else pcall(function() d.Visible = false end) end
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
        local hrp  = char:FindFirstChild("HumanoidRootPart")
        local head = char:FindFirstChild("Head")
        local hum  = char:FindFirstChildOfClass("Humanoid")
        if not (hrp and head and hum) then continue end

        local dist = (hrp.Position - Camera.CFrame.Position).Magnitude
        if dist > S.esp.max_dist then if espCache[plr] then hideEsp(espCache[plr]) end continue end

        if not espCache[plr] then espCache[plr] = newEsp() end
        local e = espCache[plr]

        local onHead, headScr = onscreen(head.Position + Vector3.new(0,0.5,0))
        local onFoot, footScr = onscreen(hrp.Position - Vector3.new(0,3,0))

        -- offscreen arrow
        if not (onHead and onFoot) then
            hideEsp(e)
            if S.esp.offscreen_arrow.enable then
                local toTarget = (hrp.Position - Camera.CFrame.Position)
                local flat = Vector3.new(toTarget.X, 0, toTarget.Z).Unit
                local look = Vector3.new(Camera.CFrame.LookVector.X, 0, Camera.CFrame.LookVector.Z).Unit
                local right = Camera.CFrame.RightVector
                local angle = math.atan2(flat:Dot(right), flat:Dot(look))
                local center = Camera.ViewportSize / 2
                local radius = S.esp.offscreen_arrow.radius
                local pos = center + Vector2.new(math.sin(angle), -math.cos(angle)) * radius
                local size = S.esp.offscreen_arrow.size
                local ang2 = angle + math.pi/2
                local p1 = pos + Vector2.new(math.cos(ang2), math.sin(ang2)) * size
                local p2 = pos - Vector2.new(math.cos(ang2), math.sin(ang2)) * size
                local p3 = pos + Vector2.new(math.sin(angle), -math.cos(angle)) * size * 1.6
                e.arrow_a.From=p1 e.arrow_a.To=p2 e.arrow_a.Color=S.esp.offscreen_arrow.color e.arrow_a.Visible=true
                e.arrow_b.From=p1 e.arrow_b.To=p3 e.arrow_b.Color=S.esp.offscreen_arrow.color e.arrow_b.Visible=true
                e.arrow_c.From=p2 e.arrow_c.To=p3 e.arrow_c.Color=S.esp.offscreen_arrow.color e.arrow_c.Visible=true
            else for _,a in ipairs({e.arrow_a,e.arrow_b,e.arrow_c}) do a.Visible=false end end
            continue
        end
        for _,a in ipairs({e.arrow_a,e.arrow_b,e.arrow_c}) do a.Visible=false end

        local height = (footScr.Y - headScr.Y)
        local width  = height / 2
        local topLeft= Vector2.new(headScr.X - width/2, headScr.Y)

        if S.esp.box.enable then
            e.box.Size      = Vector2.new(width, height)
            e.box.Position  = topLeft
            e.box.Color     = S.esp.box.color
            e.box.Thickness = S.esp.box.thickness
            e.box.Visible   = true
            if S.esp.box.outline then
                e.box_out.Size=e.box.Size e.box_out.Position=e.box.Position e.box_out.Visible=true
            else e.box_out.Visible=false end
        else e.box.Visible=false e.box_out.Visible=false end

        if S.esp.name.enable then
            e.name.Text     = S.esp.name.show_display and plr.DisplayName or plr.Name
            e.name.Position = Vector2.new(headScr.X, headScr.Y - 16)
            e.name.Color    = S.esp.name.color
            e.name.Size     = S.esp.name.size
            e.name.Visible  = true
        else e.name.Visible=false end

        if S.esp.health.enable then
            local pct = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
            if S.esp.health.bar then
                local barX = topLeft.X - 5
                e.hp_bar_bg.From = Vector2.new(barX, topLeft.Y)
                e.hp_bar_bg.To   = Vector2.new(barX, topLeft.Y + height)
                e.hp_bar.From    = Vector2.new(barX, topLeft.Y + height * (1 - pct))
                e.hp_bar.To      = Vector2.new(barX, topLeft.Y + height)
                e.hp_bar.Color   = S.esp.health.gradient and Color3.fromHSV(0.33 * pct, 1, 1) or S.esp.health.color
                e.hp_bar.Visible=true e.hp_bar_bg.Visible=true
            else e.hp_bar.Visible=false e.hp_bar_bg.Visible=false end
            if S.esp.health.show_text then
                e.health.Text     = math.floor(hum.Health).."hp"
                e.health.Position = Vector2.new(headScr.X, footScr.Y + 2)
                e.health.Color    = S.esp.health.color
                e.health.Visible  = true
            else e.health.Visible=false end
        else e.hp_bar.Visible=false e.hp_bar_bg.Visible=false e.health.Visible=false end

        if S.esp.distance.enable then
            e.dist.Text     = string.format("[%dm]", math.floor(dist))
            e.dist.Position = Vector2.new(headScr.X, footScr.Y + 16)
            e.dist.Color    = S.esp.distance.color
            e.dist.Visible  = true
        else e.dist.Visible=false end

        if S.esp.weapon.enable then
            local tool = char:FindFirstChildOfClass("Tool")
            e.weapon.Text     = tool and tool.Name or ""
            e.weapon.Position = Vector2.new(headScr.X, footScr.Y + 30)
            e.weapon.Color    = S.esp.weapon.color
            e.weapon.Visible  = tool ~= nil
        else e.weapon.Visible=false end

        if S.esp.tracer.enable then
            local origin
            if S.esp.tracer.origin == "top" then origin = Vector2.new(Camera.ViewportSize.X/2, 0)
            elseif S.esp.tracer.origin == "middle" then origin = Camera.ViewportSize/2
            else origin = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y) end
            e.tracer.From = origin
            e.tracer.To   = footScr
            e.tracer.Color= S.esp.tracer.color
            e.tracer.Thickness=S.esp.tracer.thickness
            e.tracer.Visible=true
        else e.tracer.Visible=false end

        if S.esp.head_dot.enable then
            e.dot.Position = headScr
            e.dot.Color    = S.esp.head_dot.color
            e.dot.Filled   = S.esp.head_dot.filled
            e.dot.Visible  = true
        else e.dot.Visible=false end

        if S.esp.skeleton.enable then
            for i, link in ipairs(skeletonLinks) do
                local a = char:FindFirstChild(link[1])
                local b = char:FindFirstChild(link[2])
                local ln = e.skeleton[i]
                if a and b and ln then
                    local on1, s1 = onscreen(a.Position)
                    local on2, s2 = onscreen(b.Position)
                    if on1 and on2 then
                        ln.From=s1 ln.To=s2 ln.Color=S.esp.skeleton.color
                        ln.Thickness=S.esp.skeleton.thickness ln.Visible=true
                    else ln.Visible=false end
                else if ln then ln.Visible=false end end
            end
        else for _,ln in ipairs(e.skeleton) do ln.Visible=false end end

        if S.esp.highlight.enable then
            local hl = char:FindFirstChild("UEV3_Highlight")
            if not hl then
                hl = Instance.new("Highlight")
                hl.Name = "UEV3_Highlight"
                hl.Parent = char
            end
            hl.FillColor = S.esp.highlight.fill
            hl.FillTransparency = S.esp.highlight.fill_t
            hl.OutlineColor = S.esp.highlight.outline
            hl.OutlineTransparency = S.esp.highlight.outline_t
            hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        else local hl = char:FindFirstChild("UEV3_Highlight") if hl then hl:Destroy() end end

        if S.esp.chams.enable then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                    if not part:GetAttribute("UEV3_ChamBackup") then
                        part:SetAttribute("UEV3_ChamBackup", true)
                        part:SetAttribute("UEV3_mat", part.Material.Name)
                        part:SetAttribute("UEV3_trans", part.Transparency)
                    end
                    part.Material = Enum.Material[S.esp.chams.material] or Enum.Material.ForceField
                    part.Color = S.esp.chams.color
                    part.Transparency = S.esp.chams.transparency
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
    if S.crosshair.rainbow then col = Color3.fromHSV((xhairT * S.crosshair.rainbow_speed) % 1, 1, 1) end
    if S.crosshair.pulse then
        local mul = 0.6 + 0.4 * math.abs(math.sin(xhairT * S.crosshair.pulse_speed))
        col = Color3.new(col.R * mul, col.G * mul, col.B * mul)
    end
    for _,l in ipairs(xhairLines) do l.Color=col l.Thickness=S.crosshair.thickness l.Visible=true end
    xhairLines[1].From = c + Vector2.new(0, -gap)       xhairLines[1].To = c + Vector2.new(0, -gap - len)
    xhairLines[2].From = c + Vector2.new(0,  gap)       xhairLines[2].To = c + Vector2.new(0,  gap + len)
    xhairLines[3].From = c + Vector2.new(-gap, 0)       xhairLines[3].To = c + Vector2.new(-gap - len, 0)
    xhairLines[4].From = c + Vector2.new( gap, 0)       xhairLines[4].To = c + Vector2.new( gap + len, 0)
    if S.crosshair.t_shape then xhairLines[1].Visible=false end
    if S.crosshair.circle then
        xhairCircle.Position=c xhairCircle.Radius=S.crosshair.circle_radius xhairCircle.Color=col xhairCircle.Visible=true
    else xhairCircle.Visible=false end
    if S.crosshair.dot then xhairDot.Position=c xhairDot.Color=S.crosshair.dot_color xhairDot.Visible=true
    else xhairDot.Visible=false end
end))

-- ============================================================================
-- CHARACTER (speed, jump, gravity, bhop, infjump, hipheight, no_slow, hitbox)
-- ============================================================================
local savedSpeed, savedJump, savedGrav, savedHip = 16, 50, 196, 2

bin(RunService.Heartbeat:Connect(function()
    local hum = getHum() if not hum then return end
    if S.character.walkspeed.enable then hum.WalkSpeed = S.character.walkspeed.value end
    if S.character.jumppower.enable then hum.UseJumpPower=true hum.JumpPower=S.character.jumppower.value end
    if S.character.hipheight.enable then hum.HipHeight = S.character.hipheight.value end
    if S.character.gravity.enable then workspace.Gravity = S.character.gravity.value end
    if S.character.auto_bhop.enable and UserInputService:IsKeyDown(Enum.KeyCode.Space) then
        if hum:GetState() == Enum.HumanoidStateType.Landed or hum.FloorMaterial ~= Enum.Material.Air then
            hum.Jump = true
        end
    end
    if S.character.hitbox_expander.enable then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and alive(plr) then
                local part = plr.Character:FindFirstChild(S.character.hitbox_expander.part or "Head")
                if part then
                    part.Size = Vector3.new(S.character.hitbox_expander.size, S.character.hitbox_expander.size, S.character.hitbox_expander.size)
                    part.CanCollide = false
                    part.Transparency = 0.7
                end
            end
        end
    end
end))

bin(UserInputService.JumpRequest:Connect(function()
    if S.character.infjump.enable then
        local h = getHum() if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end))

-- ============================================================================
-- FLY + NOCLIP + TELEPORT + UNDERGROUND
-- ============================================================================
local flyBV, flyBG
local function destroyFly()
    if flyBV then flyBV:Destroy() flyBV=nil end
    if flyBG then flyBG:Destroy() flyBG=nil end
end
LocalPlayer.CharacterAdded:Connect(destroyFly)

bin(RunService.Heartbeat:Connect(function()
    if S.movement.fly.enable then
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
        flyBV.Velocity = (move.Magnitude > 0 and move.Unit or Vector3.zero) * S.movement.fly.speed
    else destroyFly() end

    if S.movement.noclip.enable or (S.movement.fly.enable and S.movement.fly.noclip) then
        local c = getChar()
        if c then
            for _,p in ipairs(c:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide=false end
            end
        end
    end
end))

local function pickTarget(method)
    local best, bestVal = nil, math.huge
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and alive(plr)
           and (not S.movement.teleport.team_check or not isTeammate(plr)) then
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
    local tgt = pickTarget(S.movement.teleport.method)
    if not tgt then return end
    local hrp = getHRP() if not hrp then return end
    local tp = tgt.Character and tgt.Character:FindFirstChild("HumanoidRootPart") if not tp then return end
    local offset = Vector3.new(0, S.movement.teleport.y_offset, 0)
    if S.movement.teleport.prediction then offset = offset + tp.AssemblyLinearVelocity * 0.15 end
    hrp.CFrame = CFrame.new(tp.Position + offset) * (hrp.CFrame - hrp.CFrame.Position)
end

-- ============================================================================
-- WORLD (fov, atmosphere, cc, bloom, blur, sunrays, dof, time, fog)
-- ============================================================================
local function ensureEffect(name, class, parent)
    parent = parent or Lighting
    local e = parent:FindFirstChild(name)
    if not e then e=Instance.new(class) e.Name=name e.Parent=parent end
    return e
end

bin(RunService.RenderStepped:Connect(function()
    if S.world.fov.enable then Camera.FieldOfView = S.world.fov.value end

    local atm = ensureEffect("UEV3_Atmosphere","Atmosphere")
    atm.Enabled = S.world.atmosphere.enable
    if S.world.atmosphere.enable then
        atm.Density=S.world.atmosphere.density atm.Offset=S.world.atmosphere.offset
        atm.Color=S.world.atmosphere.color atm.Decay=S.world.atmosphere.decay
        atm.Glare=S.world.atmosphere.glare atm.Haze=S.world.atmosphere.haze
    end

    local cc = ensureEffect("UEV3_CC","ColorCorrectionEffect")
    cc.Enabled = S.world.color_correction.enable
    if S.world.color_correction.enable then
        cc.Brightness=S.world.color_correction.brightness cc.Contrast=S.world.color_correction.contrast
        cc.Saturation=S.world.color_correction.saturation cc.TintColor=S.world.color_correction.tint
    end

    local bl = ensureEffect("UEV3_Bloom","BloomEffect")
    bl.Enabled = S.world.bloom.enable
    if S.world.bloom.enable then
        bl.Intensity=S.world.bloom.intensity bl.Size=S.world.bloom.size bl.Threshold=S.world.bloom.threshold
    end

    local blur = ensureEffect("UEV3_Blur","BlurEffect")
    blur.Enabled = S.world.blur.enable
    if S.world.blur.enable then blur.Size=S.world.blur.size end

    local sr = ensureEffect("UEV3_SunRays","SunRaysEffect")
    sr.Enabled = S.world.sunrays.enable
    if S.world.sunrays.enable then sr.Intensity=S.world.sunrays.intensity sr.Spread=S.world.sunrays.spread end

    local dof = ensureEffect("UEV3_DOF","DepthOfFieldEffect")
    dof.Enabled = S.world.depthoffield.enable
    if S.world.depthoffield.enable then
        dof.FocusDistance=S.world.depthoffield.focus dof.InFocusRadius=S.world.depthoffield.inFocus
        dof.NearIntensity=S.world.depthoffield.blur dof.FarIntensity=S.world.depthoffield.blur
    end

    if S.world.time_lock.enable then Lighting.ClockTime = S.world.time_lock.hour end
    if S.world.remove_fog then Lighting.FogEnd = 1e6 end
end))

-- ============================================================================
-- OPTIMIZATIONS
-- ============================================================================
bin(task.spawn(function()
    while task.wait(1) do
        if S.optim.no_particles then
            for _,v in ipairs(workspace:GetDescendants()) do
                if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") then v.Enabled=false end
            end
        end
        if S.optim.no_shadows then
            for _,v in ipairs(workspace:GetDescendants()) do
                if v:IsA("BasePart") then v.CastShadow=false end
            end
        end
        if S.optim.no_textures then
            for _,v in ipairs(workspace:GetDescendants()) do
                if v:IsA("Texture") or v:IsA("Decal") then v.Transparency=1 end
            end
        end
        if S.optim.low_quality then
            pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level01 end)
        end
        if S.optim.fps_cap_enable and setfpscap then setfpscap(S.optim.fps_cap) end
        if S.optim.disable_sounds then
            for _,v in ipairs(game:GetDescendants()) do
                if v:IsA("Sound") then v.Volume=0 end
            end
        end
    end
end))

-- ============================================================================
-- GUN MODS (Rivals-specific)
-- ============================================================================
pcall(function()
    local gm_hooked = false
    bin(RunService.Heartbeat:Connect(function()
        if not S.misc.gun_mods.enable then return end
        local ok, lib = pcall(require, ReplicatedStorage.Modules.ItemLibrary)
        if ok and lib and lib.Items then
            for _, item in pairs(lib.Items) do
                if type(item) == "table" then
                    if S.misc.gun_mods.no_spread then item.ShootSpread=0 item.ShootAccuracy=0 end
                    if S.misc.gun_mods.no_recoil then item.ShootRecoil=0 end
                    if S.misc.gun_mods.no_cooldown then
                        item.ShootCooldown=0.001 item.ShootBurstCooldown=0.001
                        item.AttackCooldown=0 item.SwingCooldown=0 item.MeleeCooldown=0
                        item.Cooldown=0 item.RecoveryTime=0
                    end
                    if S.misc.gun_mods.proj_speed > 0 then item.ProjectileSpeed=S.misc.gun_mods.proj_speed end
                end
            end
        end
        if not gm_hooked then
            local ok2, ci = pcall(require, LocalPlayer.PlayerScripts.Modules.ClientReplicatedClasses.ClientFighter.ClientItem)
            if ok2 and ci and ci.Input then
                gm_hooked = true
                local orig = ci.Input
                ci.Input = function(self, ...)
                    if S.misc.gun_mods.enable and self and self.Info then
                        self.Info.ShootRecoil=0 self.Info.ShootSpread=0
                        self.Info.ShootCooldown=0 self.Info.QuickShotCooldown=0
                        if S.misc.gun_mods.proj_speed > 0 then self.Info.ProjectileSpeed=S.misc.gun_mods.proj_speed end
                    end
                    return orig(self, ...)
                end
            end
        end
    end))
end)

-- ============================================================================
-- WATERMARK + CLOCK + KEYBINDS
-- ============================================================================
local wmGui = Instance.new("ScreenGui")
wmGui.Name = "UEV3_Watermark"
wmGui.ResetOnSpawn = false
wmGui.IgnoreGuiInset = true
wmGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function() wmGui.Parent = (gethui and gethui()) or game:GetService("CoreGui") end)
bin(wmGui)

local wmFrame = Instance.new("Frame")
wmFrame.Size = UDim2.new(0, 260, 0, 22)
wmFrame.Position = UDim2.new(0, 10, 0, 10)
wmFrame.BackgroundColor3 = Color3.fromRGB(13,13,15)
wmFrame.BorderSizePixel = 0
wmFrame.Parent = wmGui
local wmCorner = Instance.new("UICorner", wmFrame) wmCorner.CornerRadius = UDim.new(0,4)
local wmStroke = Instance.new("UIStroke", wmFrame) wmStroke.Color=Color3.fromRGB(196,30,58) wmStroke.Thickness=1
local wmLabel = Instance.new("TextLabel")
wmLabel.BackgroundTransparency = 1
wmLabel.Size = UDim2.new(1,0,1,0)
wmLabel.Font = Enum.Font.Code
wmLabel.TextColor3 = Color3.fromRGB(235,235,240)
wmLabel.TextSize = 13
wmLabel.Parent = wmFrame

bin(RunService.Heartbeat:Connect(function()
    if not S.misc.watermark then wmGui.Enabled=false return end
    wmGui.Enabled = true
    local fps = math.floor(1 / RunService.RenderStepped:Wait())
    local ping = math.floor(LocalPlayer:GetNetworkPing() * 1000)
    local t = os.date("%H:%M:%S")
    wmLabel.Text = string.format(" UE V3  |  %d fps  |  %d ms  |  %s", fps, ping, t)
end))

-- ============================================================================
-- Hitmarker + hit sound
-- ============================================================================
local hitSoundIds = {
    hitmarker = "rbxassetid://3779005184",
    rust      = "rbxassetid://5554541971",
    skeet     = "rbxassetid://1500880381",
    bell      = "rbxassetid://12222257",
}

local function playHit()
    if not S.misc.hitsounds.enable then return end
    local id = S.misc.hitsounds.custom ~= "" and ("rbxassetid://"..S.misc.hitsounds.custom)
               or hitSoundIds[S.misc.hitsounds.id] or hitSoundIds.hitmarker
    local s = Instance.new("Sound")
    s.SoundId = id
    s.Volume = S.misc.hitsounds.volume
    s.PlaybackSpeed = S.misc.hitsounds.pitch
    s.Parent = SoundService
    s:Play()
    game:GetService("Debris"):AddItem(s, 2)
end

-- hook damage event (best-effort: tagged hit events)
pcall(function()
    local rs = ReplicatedStorage
    for _, v in ipairs(rs:GetDescendants()) do
        if v:IsA("RemoteEvent") and v.Name:lower():find("hit") then
            v.OnClientEvent:Connect(function() playHit() end)
        end
    end
end)

-- ============================================================================
-- ANTI-AFK
-- ============================================================================
LocalPlayer.Idled:Connect(function()
    if not S.misc.anti_afk then return end
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

-- ============================================================================
-- PANIC KEY — unload
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
-- GUI
-- ============================================================================
-- COMBAT
local gAim = Tabs.Combat:AddLeftGroupbox("Aimbot")
gAim:AddToggle("aim_enable",   {Text="Enabled", Default=false}):OnChanged(function(v) S.aimbot.enable=v end)
gAim:AddLabel("Aim Key"):AddKeyPicker("aimbot_key",{Default="MouseButton2",Mode="Hold",Text="Aim Key"})
gAim:AddToggle("aim_fov",      {Text="Show FOV", Default=true}):OnChanged(function(v) S.aimbot.show_fov=v end)
gAim:AddSlider("aim_fov_r",    {Text="FOV Radius", Default=180, Min=10, Max=600}):OnChanged(function(v) S.aimbot.fov=v end)
gAim:AddSlider("aim_smooth",   {Text="Smoothing", Default=3, Min=1, Max=100}):OnChanged(function(v) S.aimbot.smoothing=v end)
gAim:AddSlider("aim_pred",     {Text="Prediction", Default=0.165, Min=0, Max=0.5, Rounding=3}):OnChanged(function(v) S.aimbot.prediction=v end)
gAim:AddSlider("aim_dist",     {Text="Max Distance", Default=1500, Min=100, Max=5000}):OnChanged(function(v) S.aimbot.max_dist=v end)
gAim:AddDropdown("aim_part",   {Text="Hit Part", Values={"Head","Torso","HumanoidRootPart","UpperTorso"}, Default="Head"}):OnChanged(function(v) S.aimbot.hit_part=v end)
gAim:AddToggle("aim_vis",      {Text="Visible Only", Default=false}):OnChanged(function(v) S.aimbot.visible_only=v end)
gAim:AddToggle("aim_team",     {Text="Team Check", Default=true}):OnChanged(function(v) S.aimbot.team_check=v end)
gAim:AddToggle("aim_snap",     {Text="Snapline", Default=false}):OnChanged(function(v) S.aimbot.snapline=v end)
gAim:AddToggle("aim_sound",    {Text="Lock Sound", Default=false}):OnChanged(function(v) S.aimbot.lock_sound=v end)
gAim:AddLabel("FOV Color"):AddColorPicker("aim_fov_c", {Default=Color3.fromRGB(196,30,58)}):OnChanged(function(v) S.aimbot.fov_color=v end)

local gSil = Tabs.Combat:AddRightGroupbox("Silent Aim")
gSil:AddToggle("sa_enable", {Text="Enabled", Default=false}):OnChanged(function(v) S.silent.enable=v end)
gSil:AddLabel("Silent Key"):AddKeyPicker("silent_aim_key", {Default="None", Mode="Always", Text="Silent Key"})
gSil:AddToggle("sa_fov",    {Text="Show FOV", Default=true}):OnChanged(function(v) S.silent.show_fov=v end)
gSil:AddSlider("sa_fov_r",  {Text="FOV Radius", Default=300, Min=20, Max=800}):OnChanged(function(v) S.silent.fov=v end)
gSil:AddSlider("sa_hc",     {Text="Hit Chance", Default=70, Min=0, Max=100}):OnChanged(function(v) S.silent.hitchance=v end)
gSil:AddDropdown("sa_part", {Text="Hit Part", Values={"Head","Torso","HumanoidRootPart","UpperTorso"}, Default="Head"}):OnChanged(function(v) S.silent.hit_part=v end)
gSil:AddToggle("sa_team",   {Text="Team Check", Default=true}):OnChanged(function(v) S.silent.team_check=v end)

local gTrig = Tabs.Combat:AddLeftGroupbox("Triggerbot")
gTrig:AddToggle("tb_enable", {Text="Enabled", Default=false}):OnChanged(function(v) S.triggerbot.enable=v end)
gTrig:AddToggle("tb_team",   {Text="Team Check", Default=true}):OnChanged(function(v) S.triggerbot.team_check=v end)
gTrig:AddToggle("tb_head",   {Text="Headshot Only", Default=false}):OnChanged(function(v) S.triggerbot.headshot_only=v end)
gTrig:AddSlider("tb_react",  {Text="Reaction", Default=0.05, Min=0, Max=0.5, Rounding=3}):OnChanged(function(v) S.triggerbot.reaction=v end)
gTrig:AddSlider("tb_delay",  {Text="Fire Delay", Default=0.1, Min=0, Max=1, Rounding=3}):OnChanged(function(v) S.triggerbot.delay=v end)
gTrig:AddSlider("tb_dist",   {Text="Max Distance", Default=600, Min=50, Max=2500}):OnChanged(function(v) S.triggerbot.max_dist=v end)

local gXh = Tabs.Combat:AddRightGroupbox("Crosshair")
gXh:AddToggle("xh_e",    {Text="Enabled", Default=false}):OnChanged(function(v) S.crosshair.enable=v end)
gXh:AddSlider("xh_len",  {Text="Length", Default=6, Min=1, Max=40}):OnChanged(function(v) S.crosshair.length=v end)
gXh:AddSlider("xh_gap",  {Text="Gap", Default=3, Min=0, Max=30}):OnChanged(function(v) S.crosshair.gap=v end)
gXh:AddSlider("xh_thick",{Text="Thickness", Default=1, Min=1, Max=6}):OnChanged(function(v) S.crosshair.thickness=v end)
gXh:AddToggle("xh_dot",  {Text="Dot", Default=false}):OnChanged(function(v) S.crosshair.dot=v end)
gXh:AddToggle("xh_circ", {Text="Circle", Default=false}):OnChanged(function(v) S.crosshair.circle=v end)
gXh:AddToggle("xh_pulse",{Text="Pulse", Default=false}):OnChanged(function(v) S.crosshair.pulse=v end)
gXh:AddToggle("xh_rb",   {Text="Rainbow", Default=false}):OnChanged(function(v) S.crosshair.rainbow=v end)
gXh:AddLabel("Color"):AddColorPicker("xh_c", {Default=Color3.fromRGB(0,255,170)}):OnChanged(function(v) S.crosshair.color=v end)

-- RAGEBOT
local gRage = Tabs.Ragebot:AddLeftGroupbox("Ragebot")
gRage:AddToggle("rb_e",     {Text="Enabled", Default=false}):OnChanged(function(v) S.ragebot.enable=v end)
gRage:AddToggle("rb_shoot", {Text="Auto Shoot", Default=true}):OnChanged(function(v) S.ragebot.autoshoot=v end)
gRage:AddToggle("rb_scope", {Text="Auto Scope", Default=true}):OnChanged(function(v) S.ragebot.autoscope=v end)
gRage:AddSlider("rb_hc",    {Text="Hitchance", Default=70, Min=0, Max=100}):OnChanged(function(v) S.ragebot.hitchance=v end)
gRage:AddSlider("rb_tp",    {Text="TP Duration", Default=0.15, Min=0, Max=1, Rounding=2}):OnChanged(function(v) S.ragebot.tp_duration=v end)
gRage:AddSlider("rb_y",     {Text="Y Offset", Default=3, Min=-10, Max=10, Rounding=1}):OnChanged(function(v) S.ragebot.y_offset=v end)
gRage:AddDropdown("rb_prio",{Text="Priority", Values={"distance","fov","lowest_hp","random"}, Default="distance"}):OnChanged(function(v) S.ragebot.priority=v end)
gRage:AddToggle("rb_team",  {Text="Team Check", Default=true}):OnChanged(function(v) S.ragebot.team_check=v end)

local gAA = Tabs.Ragebot:AddRightGroupbox("Anti-Aim")
gAA:AddToggle("aa_e",     {Text="Enabled", Default=false}):OnChanged(function(v) S.anti_aim.enable=v end)
gAA:AddDropdown("aa_p",   {Text="Pitch", Values={"Off","Up","Down","Zero"}, Default="Down"}):OnChanged(function(v) S.anti_aim.pitch=v end)
gAA:AddDropdown("aa_y",   {Text="Yaw", Values={"Off","Spin","Jitter","Backward","Random"}, Default="Spin"}):OnChanged(function(v) S.anti_aim.yaw=v end)
gAA:AddSlider("aa_speed", {Text="Yaw Speed", Default=6, Min=1, Max=60}):OnChanged(function(v) S.anti_aim.yaw_speed=v end)
gAA:AddToggle("aa_jit",   {Text="Jitter", Default=false}):OnChanged(function(v) S.anti_aim.jitter=v end)
gAA:AddToggle("aa_fl",    {Text="Fake Lag", Default=false}):OnChanged(function(v) S.anti_aim.fake_lag=v end)

-- VISUALS
local gEspA = Tabs.Visuals:AddLeftGroupbox("ESP Core")
gEspA:AddToggle("esp_e",     {Text="Enabled", Default=false}):OnChanged(function(v) S.esp.enable=v end)
gEspA:AddToggle("esp_team",  {Text="Team Check", Default=true}):OnChanged(function(v) S.esp.team_check=v end)
gEspA:AddSlider("esp_dist",  {Text="Max Distance", Default=1000, Min=50, Max=5000}):OnChanged(function(v) S.esp.max_dist=v end)
gEspA:AddToggle("esp_box",   {Text="Box", Default=true}):OnChanged(function(v) S.esp.box.enable=v end)
gEspA:AddLabel("Box Color"):AddColorPicker("esp_box_c", {Default=Color3.fromRGB(196,30,58)}):OnChanged(function(v) S.esp.box.color=v end)
gEspA:AddToggle("esp_name",  {Text="Name", Default=true}):OnChanged(function(v) S.esp.name.enable=v end)
gEspA:AddToggle("esp_hp",    {Text="Health", Default=true}):OnChanged(function(v) S.esp.health.enable=v end)
gEspA:AddToggle("esp_hpbar", {Text="HP Bar", Default=true}):OnChanged(function(v) S.esp.health.bar=v end)
gEspA:AddToggle("esp_dists", {Text="Distance", Default=true}):OnChanged(function(v) S.esp.distance.enable=v end)
gEspA:AddToggle("esp_wep",   {Text="Weapon", Default=false}):OnChanged(function(v) S.esp.weapon.enable=v end)
gEspA:AddToggle("esp_dot",   {Text="Head Dot", Default=false}):OnChanged(function(v) S.esp.head_dot.enable=v end)
gEspA:AddToggle("esp_skel",  {Text="Skeleton", Default=false}):OnChanged(function(v) S.esp.skeleton.enable=v end)

local gEspB = Tabs.Visuals:AddRightGroupbox("Tracer / Highlight / Chams / Arrow")
gEspB:AddToggle("esp_tr",    {Text="Tracer", Default=false}):OnChanged(function(v) S.esp.tracer.enable=v end)
gEspB:AddDropdown("esp_tro", {Text="Tracer Origin", Values={"bottom","middle","top"}, Default="bottom"}):OnChanged(function(v) S.esp.tracer.origin=v end)
gEspB:AddLabel("Tracer Color"):AddColorPicker("esp_tr_c", {Default=Color3.fromRGB(196,30,58)}):OnChanged(function(v) S.esp.tracer.color=v end)
gEspB:AddToggle("esp_hl",    {Text="Highlight", Default=true}):OnChanged(function(v) S.esp.highlight.enable=v end)
gEspB:AddLabel("Highlight Fill"):AddColorPicker("esp_hl_f", {Default=Color3.fromRGB(196,30,58)}):OnChanged(function(v) S.esp.highlight.fill=v end)
gEspB:AddSlider("esp_hl_ft", {Text="Fill Transparency", Default=0.5, Min=0, Max=1, Rounding=2}):OnChanged(function(v) S.esp.highlight.fill_t=v end)
gEspB:AddToggle("esp_ch",    {Text="Chams", Default=false}):OnChanged(function(v) S.esp.chams.enable=v end)
gEspB:AddDropdown("esp_ch_m",{Text="Chams Material", Values={"Neon","ForceField","Glass","Metal","Ice","Plastic"}, Default="ForceField"}):OnChanged(function(v) S.esp.chams.material=v end)
gEspB:AddLabel("Chams Color"):AddColorPicker("esp_ch_c", {Default=Color3.fromRGB(196,30,58)}):OnChanged(function(v) S.esp.chams.color=v end)
gEspB:AddToggle("esp_arr",   {Text="Offscreen Arrow", Default=false}):OnChanged(function(v) S.esp.offscreen_arrow.enable=v end)
gEspB:AddSlider("esp_arr_r", {Text="Arrow Radius", Default=200, Min=80, Max=400}):OnChanged(function(v) S.esp.offscreen_arrow.radius=v end)
gEspB:AddLabel("Arrow Color"):AddColorPicker("esp_arr_c", {Default=Color3.fromRGB(196,30,58)}):OnChanged(function(v) S.esp.offscreen_arrow.color=v end)

-- WORLD
local gW1 = Tabs.World:AddLeftGroupbox("Camera")
gW1:AddToggle("fov_e", {Text="FOV Changer", Default=false}):OnChanged(function(v) S.world.fov.enable=v end)
gW1:AddSlider("fov_v", {Text="FOV", Default=90, Min=20, Max=120}):OnChanged(function(v) S.world.fov.value=v end)

local gW2 = Tabs.World:AddRightGroupbox("Lighting / FX")
gW2:AddToggle("atm_e", {Text="Atmosphere", Default=false}):OnChanged(function(v) S.world.atmosphere.enable=v end)
gW2:AddSlider("atm_d", {Text="Density", Default=0.3, Min=0, Max=1, Rounding=2}):OnChanged(function(v) S.world.atmosphere.density=v end)
gW2:AddLabel("Atmo Color"):AddColorPicker("atm_c", {Default=Color3.fromRGB(180,100,100)}):OnChanged(function(v) S.world.atmosphere.color=v end)
gW2:AddToggle("cc_e",  {Text="Color Correction", Default=false}):OnChanged(function(v) S.world.color_correction.enable=v end)
gW2:AddSlider("cc_sat",{Text="Saturation", Default=0.1, Min=-1, Max=1, Rounding=2}):OnChanged(function(v) S.world.color_correction.saturation=v end)
gW2:AddSlider("cc_con",{Text="Contrast", Default=0.15, Min=-1, Max=1, Rounding=2}):OnChanged(function(v) S.world.color_correction.contrast=v end)
gW2:AddSlider("cc_br", {Text="Brightness", Default=0, Min=-1, Max=1, Rounding=2}):OnChanged(function(v) S.world.color_correction.brightness=v end)
gW2:AddToggle("bl_e",  {Text="Bloom", Default=false}):OnChanged(function(v) S.world.bloom.enable=v end)
gW2:AddToggle("blur_e",{Text="Blur", Default=false}):OnChanged(function(v) S.world.blur.enable=v end)
gW2:AddSlider("blur_s",{Text="Blur Size", Default=0, Min=0, Max=24}):OnChanged(function(v) S.world.blur.size=v end)
gW2:AddToggle("sr_e",  {Text="Sun Rays", Default=false}):OnChanged(function(v) S.world.sunrays.enable=v end)
gW2:AddToggle("dof_e", {Text="Depth Of Field", Default=false}):OnChanged(function(v) S.world.depthoffield.enable=v end)
gW2:AddToggle("fog_e", {Text="Remove Fog", Default=false}):OnChanged(function(v) S.world.remove_fog=v end)
gW2:AddToggle("time_e",{Text="Lock Time", Default=false}):OnChanged(function(v) S.world.time_lock.enable=v end)
gW2:AddSlider("time_h",{Text="Hour", Default=12, Min=0, Max=24, Rounding=1}):OnChanged(function(v) S.world.time_lock.hour=v end)

-- CHARACTER
local gCh1 = Tabs.Character:AddLeftGroupbox("Humanoid")
gCh1:AddToggle("ws_e",{Text="Walkspeed", Default=false}):OnChanged(function(v) S.character.walkspeed.enable=v end)
gCh1:AddSlider("ws_v",{Text="Walkspeed", Default=20, Min=8, Max=200}):OnChanged(function(v) S.character.walkspeed.value=v end)
gCh1:AddToggle("jp_e",{Text="Jump Power", Default=false}):OnChanged(function(v) S.character.jumppower.enable=v end)
gCh1:AddSlider("jp_v",{Text="Jump Power", Default=60, Min=30, Max=500}):OnChanged(function(v) S.character.jumppower.value=v end)
gCh1:AddToggle("gv_e",{Text="Gravity", Default=false}):OnChanged(function(v) S.character.gravity.enable=v end)
gCh1:AddSlider("gv_v",{Text="Gravity", Default=196, Min=0, Max=400}):OnChanged(function(v) S.character.gravity.value=v end)
gCh1:AddToggle("ij_e",{Text="Infinite Jump", Default=false}):OnChanged(function(v) S.character.infjump.enable=v end)
gCh1:AddToggle("bh_e",{Text="Auto Bhop", Default=false}):OnChanged(function(v) S.character.auto_bhop.enable=v end)
gCh1:AddToggle("hh_e",{Text="HipHeight", Default=false}):OnChanged(function(v) S.character.hipheight.enable=v end)
gCh1:AddSlider("hh_v",{Text="HipHeight", Default=2, Min=0, Max=10, Rounding=2}):OnChanged(function(v) S.character.hipheight.value=v end)

local gCh2 = Tabs.Character:AddRightGroupbox("Hitbox")
gCh2:AddToggle("hb_e",{Text="Hitbox Expander", Default=false}):OnChanged(function(v) S.character.hitbox_expander.enable=v end)
gCh2:AddSlider("hb_s",{Text="Hitbox Size", Default=5, Min=1, Max=30}):OnChanged(function(v) S.character.hitbox_expander.size=v end)
gCh2:AddDropdown("hb_p",{Text="Hitbox Part", Values={"Head","HumanoidRootPart","UpperTorso"}, Default="Head"}):OnChanged(function(v) S.character.hitbox_expander.part=v end)

-- MOVEMENT
local gMov = Tabs.Movement:AddLeftGroupbox("Fly / Noclip / TP / UG")
gMov:AddToggle("fly_e", {Text="Fly", Default=false}):OnChanged(function(v) S.movement.fly.enable=v end)
gMov:AddSlider("fly_s", {Text="Fly Speed", Default=50, Min=10, Max=500}):OnChanged(function(v) S.movement.fly.speed=v end)
gMov:AddToggle("fly_nc",{Text="Fly Noclip", Default=false}):OnChanged(function(v) S.movement.fly.noclip=v end)
gMov:AddToggle("nc_e",  {Text="Noclip", Default=false}):OnChanged(function(v) S.movement.noclip.enable=v end)
gMov:AddLabel("TP Key"):AddKeyPicker("tp_key", {Default="T", Mode="Toggle", Text="TP"})
gMov:AddDropdown("tp_m",{Text="TP Method", Values={"closest","lowest_hp","random"}, Default="closest"}):OnChanged(function(v) S.movement.teleport.method=v end)
gMov:AddSlider("tp_y",  {Text="TP Y Offset", Default=0, Min=-20, Max=20, Rounding=1}):OnChanged(function(v) S.movement.teleport.y_offset=v end)
gMov:AddToggle("tp_t",  {Text="TP Team Check", Default=true}):OnChanged(function(v) S.movement.teleport.team_check=v end)
gMov:AddToggle("ug_e",  {Text="Underground", Default=false}):OnChanged(function(v) S.movement.underground.enable=v end)
gMov:AddSlider("ug_d",  {Text="UG Depth", Default=5.8, Min=1, Max=20, Rounding=1}):OnChanged(function(v) S.movement.underground.depth=v end)

bin(task.spawn(function()
    while task.wait(0.1) do
        if Library.Options.tp_key and Library.Options.tp_key:GetState() then
            doTeleport() task.wait(0.4)
        end
    end
end))

-- MISC
local gMisc = Tabs.Misc:AddLeftGroupbox("Gun Mods")
gMisc:AddToggle("gm_e",   {Text="Enabled", Default=false}):OnChanged(function(v) S.misc.gun_mods.enable=v end)
gMisc:AddToggle("gm_rec", {Text="No Recoil", Default=true}):OnChanged(function(v) S.misc.gun_mods.no_recoil=v end)
gMisc:AddToggle("gm_spr", {Text="No Spread", Default=true}):OnChanged(function(v) S.misc.gun_mods.no_spread=v end)
gMisc:AddToggle("gm_cd",  {Text="No Cooldown", Default=true}):OnChanged(function(v) S.misc.gun_mods.no_cooldown=v end)
gMisc:AddSlider("gm_proj",{Text="Projectile Speed", Default=0, Min=0, Max=10000, Rounding=0}):OnChanged(function(v) S.misc.gun_mods.proj_speed=v end)

local gMisc2 = Tabs.Misc:AddRightGroupbox("Hit / Sound / Watermark")
gMisc2:AddToggle("hs_e",  {Text="Hit Sounds", Default=false}):OnChanged(function(v) S.misc.hitsounds.enable=v end)
gMisc2:AddDropdown("hs_id",{Text="Hit Sound", Values={"hitmarker","rust","skeet","bell","custom"}, Default="hitmarker"}):OnChanged(function(v) S.misc.hitsounds.id=v end)
gMisc2:AddSlider("hs_v",  {Text="Volume", Default=1, Min=0, Max=5, Rounding=2}):OnChanged(function(v) S.misc.hitsounds.volume=v end)
gMisc2:AddInput("hs_c",   {Text="Custom Sound ID", Default="", Numeric=false}):OnChanged(function(v) S.misc.hitsounds.custom=v end)
gMisc2:AddToggle("afk_e", {Text="Anti AFK", Default=true}):OnChanged(function(v) S.misc.anti_afk=v end)
gMisc2:AddToggle("notif_e",{Text="Notifications", Default=true}):OnChanged(function(v) S.misc.notifications=v end)
gMisc2:AddToggle("wm_e",  {Text="Watermark", Default=true}):OnChanged(function(v) S.misc.watermark=v end)

-- OPTIM
local gOpt = Tabs.Optim:AddLeftGroupbox("Performance")
gOpt:AddToggle("op_part",{Text="No Particles", Default=false}):OnChanged(function(v) S.optim.no_particles=v end)
gOpt:AddToggle("op_shad",{Text="No Shadows", Default=false}):OnChanged(function(v) S.optim.no_shadows=v end)
gOpt:AddToggle("op_tex", {Text="No Textures", Default=false}):OnChanged(function(v) S.optim.no_textures=v end)
gOpt:AddToggle("op_low", {Text="Low Quality", Default=false}):OnChanged(function(v) S.optim.low_quality=v end)
gOpt:AddToggle("op_snd", {Text="Disable Sounds", Default=false}):OnChanged(function(v) S.optim.disable_sounds=v end)
gOpt:AddToggle("op_cap_e",{Text="FPS Cap", Default=false}):OnChanged(function(v) S.optim.fps_cap_enable=v end)
gOpt:AddSlider("op_cap_v",{Text="FPS Cap", Default=240, Min=30, Max=360}):OnChanged(function(v) S.optim.fps_cap=v end)

-- CONFIG
local gUi = Tabs.Config:AddLeftGroupbox("UI")
gUi:AddLabel("Menu Toggle"):AddKeyPicker("menu_key", {Default="RightShift", NoUI=false, Text="Menu Key"})
gUi:AddLabel("Panic (unload)"):AddKeyPicker("panic_key", {Default="End", Mode="Toggle", Text="Panic"})
gUi:AddButton("Unload", function() getgenv().UEV3_UNLOAD() end)

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({"menu_key","panic_key"})
ThemeManager:SetFolder("UnnamedEnhancementsV3")
SaveManager:SetFolder("UnnamedEnhancementsV3/Rivals")
SaveManager:BuildConfigSection(Tabs.Config)
ThemeManager:ApplyToTab(Tabs.Config)
SaveManager:LoadAutoloadConfig()

Library:OnUnload(function()
    getgenv().UEV3_LOADED = nil
end)

notify("Unnamed Enhancements V3  |  Rivals loaded — discord.gg/ojailbreaks", 5)
