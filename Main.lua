-- ============================================================================
-- Unnamed Enhancements V3  |  Rivals
-- UE skin · full stack · one-file loadstring
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
local StarterGui       = game:GetService("StarterGui")
local SoundService     = game:GetService("SoundService")
local VirtualUser      = game:GetService("VirtualUser")
local TeleportService  = game:GetService("TeleportService")
local MarketplaceService = game:GetService("MarketplaceService")
local Debris           = game:GetService("Debris")
local GuiService       = game:GetService("GuiService")
local Workspace        = workspace

local LocalPlayer = Players.LocalPlayer
local Camera      = Workspace.CurrentCamera
local Mouse       = LocalPlayer:GetMouse()

if getgenv().UEV3_LOADED then
    pcall(function() getgenv().UEV3_UNLOAD() end)
end
getgenv().UEV3_LOADED = true

-- ============================================================================
-- ANTIDETECT / ENV SHAPING
-- ============================================================================
pcall(function()
    if not (hookfunction and newcclosure and getcallingscript) then return end
    local real_setmt
    real_setmt = hookfunction(setmetatable, newcclosure(function(t, mt)
        if type(mt) == "table" and rawget(mt, "__mode") == "kv" then
            local s = getcallingscript()
            if s and (s.Name == "MiscellaneousController" or s.Name:lower():find("anticheat") or s.Name:lower():find("detection")) then
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
        local kill = {"anticheat","detection","ban","kick","security","moderation","report","sentry","watchdog","integrity","verify"}
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

pcall(function()
    if type(getgc) ~= "function" then return end
    local ls3 = game:GetService("ReplicatedFirst"):WaitForChild("LocalScript3", 10)
    local v = getgc(false)
    for i = 1, #v do
        local f = v[i]
        if type(f) == "function" and (type(islclosure) ~= "function" or islclosure(f)) then
            local ok, env = pcall(getfenv, f)
            if ok and type(env) == "table" then
                local ok2, s = pcall(function() return rawget(env, "script") end)
                if ok2 and typeof(s) == "Instance" then
                    local ok3, name = pcall(tostring, s)
                    if ok3 and (s == ls3 or (type(name) == "string" and name:find("LoadingScreen"))) then
                        local ok4, consts = pcall(debug.getconstants, f)
                        if ok4 and type(consts) == "table" then
                            for _, c in ipairs(consts) do
                                if type(c) == "string" and (c:find("TakeTheL") or c:find("ban") or c:find("kick")) then
                                    pcall(function() hookfunction(f, function() end) end)
                                    break
                                end
                            end
                        end
                    end
                end
            end
        end
        if i % 1500 == 0 then task.wait() end
    end
end)

-- ============================================================================
-- LIBRARY (real UE lib — PhonkWare + UE source ship with this one)
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
local Trove        = getgenv().Trove
assert(Library, "[UEV3] Library missing after load")

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

local Tabs = {
    Rage      = Window:AddTab("Rage"),
    Legit     = Window:AddTab("Legit"),
    Visuals   = Window:AddTab("Visuals"),
    World     = Window:AddTab("World"),
    Character = Window:AddTab("Character"),
    Movement  = Window:AddTab("Movement"),
    Misc      = Window:AddTab("Misc"),
    Scripts   = Window:AddTab("Scripts"),
    Spoofer   = Window:AddTab("Spoofer"),
    Optim     = Window:AddTab("Optimizations"),
    Config    = Window:AddTab("UI / Config"),
}

-- ============================================================================
-- STATE
-- ============================================================================
getgenv().UEV3 = {
    aimbot = {
        enable=false, show_fov=true, fov=180, fov_filled=false, fov_transparency=1,
        fov_color=Color3.fromRGB(196,30,58),
        smoothing=3, smoothing_x=3, smoothing_y=3, split_smoothing=false,
        closest_part=false, visible_only=false, team_check=true,
        hit_part="Head", prediction=0.165, wallcheck=false, snapline=false,
        snapline_color=Color3.fromRGB(255,255,255), snapline_thickness=1,
        lock_sound=false, lock_vol=0.6, autowall=false, max_dist=1500,
        bone_priority={"Head","UpperTorso","HumanoidRootPart"},
        aim_delay=0, miss_penalty=false, resolver=false,
    },
    silent = {
        enable=false, show_fov=true, fov=300, fov_color=Color3.fromRGB(255,255,255),
        hit_part="Head", team_check=true, hitchance=70, resolver=true,
        hit_random=false, wallbangs=true, body_aim=false,
    },
    ragebot = {
        enable=false, autoshoot=true, autoscope=true, tp_duration=0.15, y_offset=3,
        team_check=true, prediction=true, hitchance=70, double_tap=false,
        hide_shots=false, priority="distance", quick_peek=false, force_body=false,
        force_safe=false, auto_fire=true, max_range=2000, resolver=true,
        baim=false, min_damage=1, auto_knife=false,
    },
    triggerbot = {
        enable=false, team_check=true, reaction=0.05, delay=0.1, max_dist=600,
        visible_only=true, headshot_only=false, burst=false, mode="Hold",
        key="MouseButton4", scope_only=false,
    },
    anti_aim = {
        enable=false, pitch="Down", yaw="Spin", yaw_speed=6, jitter=false,
        fake_lag=false, fake_lag_amt=2, desync=false, edge_yaw=false,
        at_target=false, lby_break=false,
    },
    esp = {
        enable=false, team_check=true, max_dist=1000, fade_dist=true, rainbow=false,
        box={ enable=true, color=Color3.fromRGB(196,30,58), thickness=1, outline=true,
              corner=false, fill=false, fill_color=Color3.fromRGB(196,30,58), fill_t=0.8,
              style="2D" },
        name={ enable=true, color=Color3.fromRGB(255,255,255), size=14, show_display=true,
               show_user=false, show_prefix=false, font="Plex" },
        health={ enable=true, color=Color3.fromRGB(80,220,80), bar=true, show_text=true,
                 gradient=true, horizontal=false },
        armor={ enable=false, color=Color3.fromRGB(80,160,255), bar=true },
        distance={ enable=true, color=Color3.fromRGB(200,200,200), size=12 },
        weapon={ enable=false, color=Color3.fromRGB(255,215,120), icon=false },
        tracer={ enable=false, color=Color3.fromRGB(196,30,58), origin="bottom",
                 thickness=1, team_color=false },
        head_dot={ enable=false, color=Color3.fromRGB(255,255,255), filled=true, size=3 },
        skeleton={ enable=false, color=Color3.fromRGB(255,255,255), thickness=1 },
        highlight={ enable=true, fill=Color3.fromRGB(196,30,58), fill_t=0.5,
                    outline=Color3.fromRGB(255,255,255), outline_t=0 },
        chams={ enable=false, material="ForceField", color=Color3.fromRGB(196,30,58),
                transparency=0, ghost=false, strip=false,
                visible_color=Color3.fromRGB(80,220,80),
                invisible_color=Color3.fromRGB(196,30,58), split=false },
        offscreen_arrow={ enable=false, color=Color3.fromRGB(196,30,58), radius=200, size=14 },
        viewangle={ enable=false, color=Color3.fromRGB(255,255,255), length=6 },
        flags={ enable=false, color=Color3.fromRGB(255,80,80) },
    },
    world = {
        fov={ enable=false, value=90 },
        third_person={ enable=false, distance=10 },
        stretch={ enable=false, amount=0.2 },
        remove_fog=false,
        time_lock={ enable=false, hour=12 },
        no_night=false,
        atmosphere={ enable=false, density=0.3, offset=0.25,
                     color=Color3.fromRGB(180,100,100),
                     decay=Color3.fromRGB(80,20,20), glare=0.2, haze=1.5 },
        color_correction={ enable=false, brightness=0, contrast=0.15, saturation=0.1,
                           tint=Color3.fromRGB(255,220,220) },
        bloom={ enable=false, intensity=0.4, size=24, threshold=2 },
        blur={ enable=false, size=0 },
        sunrays={ enable=false, intensity=0.25, spread=1 },
        depthoffield={ enable=false, focus=5, blur=0.15, inFocus=20, far=100 },
        skybox={ enable=false, selected="DeepSpace", rotate=false, speed=1,
                 remove_sun=false, remove_moon=false, remove_stars=false },
        weather={ enable=false, type="Snow", color=Color3.fromRGB(255,255,255), rate=100 },
        no_particles=false,
        ambient={ enable=false, color=Color3.fromRGB(128,128,128), outdoor=Color3.fromRGB(128,128,128) },
        clear_map=false,
        kill_bricks=false,
        remove_textures=false,
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
        god_mode={ enable=false },
        auto_respawn={ enable=false },
        heal={ enable=false, rate=1 },
        auto_reload={ enable=false },
        remove_fall_damage={ enable=false },
        instant_reset={ enable=false, key="Y" },
    },
    movement = {
        fly={ enable=false, speed=50, noclip=false, mode="cframe", key="None" },
        freecam={ enable=false, speed=20, key="None" },
        noclip={ enable=false },
        teleport={ enable=false, method="closest", y_offset=0, team_check=true,
                   prediction=true, key="T" },
        underground={ enable=false, depth=5.8 },
        speed_glitch={ enable=false, multiplier=2 },
        waypoints={}, waypoint_name="Spot 1",
        tp_to_mouse={ enable=false, key="F" },
        anti_void={ enable=false, floor=-50, tp_to=0 },
        slow_fall={ enable=false, strength=100 },
        auto_strafe={ enable=false },
    },
    misc = {
        gun_mods={ enable=false, no_recoil=true, no_spread=true, no_cooldown=true,
                   inf_ammo=false, rapid=false, proj_speed=0, pierce=false,
                   one_shot=false, auto_fire=false },
        unlock_all=false,
        hitsounds={ enable=false, id="hitmarker", volume=1, pitch=1, custom="" },
        killsound={ enable=false, id="rust", volume=1, custom="" },
        damage_numbers={ enable=false, color1=Color3.fromRGB(255,80,80),
                         color2=Color3.fromRGB(255,200,80), mode="Gradient",
                         size=18, duration=0.8, rise=42, remove_ingame=true,
                         crit_color=Color3.fromRGB(255,255,0) },
        kill_effect={ enable=false, type="Explosion", color=Color3.fromRGB(196,30,58) },
        death_effect={ enable=false, type="Explosion", color=Color3.fromRGB(196,30,58) },
        spoof_level={ enable=false, value=9 },
        spoof_streak={ enable=false, value=9 },
        spoof_name={ enable=false, value="" },
        device_spoof={ enable=false, type="MouseKeyboard" },
        auto_reconnect=false, auto_rejoin=false,
        anti_afk=true, anti_report=false, anti_vote=false,
        chat_bypass=false,
        server_hop=false,
        notifications=true,
        clock_enable=true,
        keybinds_display=true,
        watermark=true, watermark_pos="top_left",
        killlog={ enable=false, max=5 },
        killfeed={ enable=false, position="top_right" },
        logs={ enable=false, hits=true, misses=true, deaths=true, kills=true },
        auto_accept={ enable=false },
        auto_ready={ enable=false },
        fake_ping={ enable=false, value=250 },
        custom_fov_zoom={ enable=false, scope_fov=30, hip_fov=70 },
    },
    crosshair = {
        enable=false, style="Cross", length=6, thickness=1, gap=3, rotation=0,
        color=Color3.fromRGB(0,255,170), outline=true, outline_color=Color3.fromRGB(0,0,0),
        outline_thickness=1,
        dot=false, dot_color=Color3.fromRGB(255,255,255), dot_size=1,
        rotating=false, rotating_speed=120,
        pulse=false, pulse_speed=3,
        follow_target=false,
        rainbow=false, rainbow_speed=1,
        t_shape=false, circle=false, circle_radius=14,
        hit_mark={ enable=false, duration=0.3, color=Color3.fromRGB(255,0,0) },
        spread={ enable=false, scale=1 },
    },
    spoofer = {
        name={ enable=false, value="" },
        display={ enable=false, value="" },
        level={ enable=false, value=9 },
        streak={ enable=false, value=9 },
        avatar={ enable=false, userid=1 },
        rank={ enable=false, value="GM" },
        wins={ enable=false, value=9999 },
        xp={ enable=false, value=99999 },
    },
    optim = {
        no_particles=false, no_shadows=false, low_quality=false, no_postfx=false,
        no_textures=false, no_atmosphere=false, fps_boost=false,
        fps_cap_enable=false, fps_cap=240,
        disable_sounds=false, disable_decals=false,
        clean_ragdolls=false, cull_distant=false, cull_distance=500,
        remove_mesh=false, no_meshes=false, no_welds=false,
        destroy_map_fx=false,
    },
    scripts = {
        infinite_yield=false, dex=false, remote_spy=false,
        hydroxide=false, simple_spy=false,
    },
    panic = { key="End" },
    menu = { key="RightShift", toggle_sound=true },
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
local function getHead() local c=getChar() return c and c:FindFirstChild("Head") end

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
    if not S.misc.notifications then return end
    pcall(function() Library:Notify(text, duration or 3) end)
end

local function distance3(a, b) return (a - b).Magnitude end

local function playSound(id, vol, pitch)
    local s = Instance.new("Sound")
    s.SoundId = typeof(id)=="number" and ("rbxassetid://"..id) or id
    s.Volume = vol or 1
    s.PlaybackSpeed = pitch or 1
    s.Parent = SoundService
    s:Play()
    Debris:AddItem(s, 3)
    return s
end

local function rainbow(speed, offset)
    return Color3.fromHSV(((tick() * (speed or 1)) + (offset or 0)) % 1, 1, 1)
end

local hitSoundLibrary = {
    hitmarker = 3779005184,
    rust      = 5554541971,
    skeet     = 1500880381,
    bell      = 12222257,
    minecraft = 1839997054,
    bone      = 2851554006,
    ding      = 230295843,
    glass     = 143082895,
    pop       = 448572983,
    tick      = 1659517145,
}

local killSoundLibrary = {
    rust       = 5554541971,
    anime      = 4612375233,
    fart       = 4612375233,
    taco       = 142403532,
    gta        = 177418988,
    quake      = 2616682174,
    bruh       = 4953846338,
    windows    = 136351184,
    laugh      = 5131212703,
}

local skyboxLibrary = {
    DeepSpace  = { Up="48348670",Dn="48348710",Lf="48348542",Rt="48348587",Bk="48348446",Ft="48348499" },
    NebulaBlue = { Up="159454299",Dn="159454296",Lf="159454293",Rt="159454286",Bk="159454284",Ft="159454288" },
    Sunset     = { Up="271042467",Dn="271077243",Lf="271042330",Rt="271077958",Bk="271084259",Ft="271083692" },
    Night      = { Up="12064107",Dn="12064152",Lf="12064121",Rt="12063984",Bk="12064115",Ft="12063993" },
    Purple     = { Up="159454288",Dn="159454293",Lf="159454299",Rt="159454284",Bk="159454296",Ft="159454286" },
    Realistic  = { Up="159454278",Dn="159454282",Lf="159454275",Rt="159454272",Bk="159454269",Ft="159454267" },
}

-- ============================================================================
-- AIMBOT
-- ============================================================================
local aimCircle = Drawing.new("Circle")
aimCircle.Thickness=1 aimCircle.NumSides=64 aimCircle.Filled=false aimCircle.Visible=false
bin(aimCircle)

local aimCircleFill = Drawing.new("Circle")
aimCircleFill.Thickness=1 aimCircleFill.NumSides=64 aimCircleFill.Filled=true aimCircleFill.Visible=false
aimCircleFill.Transparency = 0.1
bin(aimCircleFill)

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

local function bestBone(plr, priority)
    if not (plr and plr.Character) then return nil end
    for _, boneName in ipairs(priority) do
        local p = plr.Character:FindFirstChild(boneName)
        if p and visibleTo(p) then return p end
    end
    return plr.Character:FindFirstChild(priority[1])
end

local lockedLast
bin(RunService.RenderStepped:Connect(function()
    if S.aimbot.enable and S.aimbot.show_fov then
        aimCircle.Visible = true
        aimCircle.Radius  = S.aimbot.fov
        aimCircle.Color   = S.aimbot.fov_color
        aimCircle.Position= Camera.ViewportSize / 2
        aimCircle.Thickness = 1
        if S.aimbot.fov_filled then
            aimCircleFill.Visible = true
            aimCircleFill.Radius  = S.aimbot.fov
            aimCircleFill.Color   = S.aimbot.fov_color
            aimCircleFill.Position= Camera.ViewportSize / 2
            aimCircleFill.Transparency = S.aimbot.fov_transparency
        else aimCircleFill.Visible = false end
    else aimCircle.Visible=false aimCircleFill.Visible=false end

    if not S.aimbot.enable then snapLine.Visible=false return end
    if not keyHeld(Library.Options.aimbot_key) then snapLine.Visible=false return end

    local tgt = bestTarget(S.aimbot)
    if not tgt then snapLine.Visible=false lockedLast=nil return end

    local part
    if S.aimbot.wallcheck then
        part = bestBone(tgt, S.aimbot.bone_priority)
    else
        part = tgt.Character and tgt.Character:FindFirstChild(S.aimbot.hit_part or "Head")
    end
    if not part then snapLine.Visible=false return end

    local target = predict(part, S.aimbot.prediction or 0)
    if S.aimbot.split_smoothing then
        local smX = math.clamp((101 - math.clamp(S.aimbot.smoothing_x,1,100)) / 100, 0.02, 1)
        local smY = math.clamp((101 - math.clamp(S.aimbot.smoothing_y,1,100)) / 100, 0.02, 1)
        local look = (target - Camera.CFrame.Position).Unit
        local curLook = Camera.CFrame.LookVector
        local blendX = Vector3.new(curLook.X, 0, curLook.Z):Lerp(Vector3.new(look.X, 0, look.Z), smX)
        local blendY = curLook:Lerp(look, smY)
        local blend = Vector3.new(blendX.X, blendY.Y, blendX.Z)
        pcall(function()
            Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, Camera.CFrame.Position + blend)
        end)
    else
        local smooth = math.clamp((101 - math.clamp(S.aimbot.smoothing,1,100)) / 100, 0.02, 1)
        local look   = (target - Camera.CFrame.Position).Unit
        local blend  = Camera.CFrame.LookVector:Lerp(look, smooth)
        pcall(function()
            Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, Camera.CFrame.Position + blend)
        end)
    end

    if S.aimbot.snapline then
        local on, scr = onscreen(target)
        if on then
            snapLine.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
            snapLine.To = scr
            snapLine.Color = S.aimbot.snapline_color
            snapLine.Thickness = S.aimbot.snapline_thickness
            snapLine.Visible = true
        end
    else snapLine.Visible = false end

    if S.aimbot.lock_sound and lockedLast ~= tgt then
        lockedLast = tgt
        pcall(function() playSound(3779005184, S.aimbot.lock_vol, 1) end)
    end
end))

-- ============================================================================
-- TRIGGERBOT
-- ============================================================================
bin(task.spawn(function()
    while task.wait(0.03) do
        if not S.triggerbot.enable then continue end
        if S.triggerbot.mode == "Hold" and S.triggerbot.key ~= "None" then
            local ok, code = pcall(function() return Enum.UserInputType[S.triggerbot.key] end)
            if ok and not UserInputService:IsMouseButtonPressed(code) then continue end
        end
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
        if S.triggerbot.burst then
            for i=1,3 do
                task.wait(0.05)
                pcall(function()
                    local fc = require(LocalPlayer.PlayerScripts.Controllers.FighterController)
                    if fc and fc.LocalFighter then fc.LocalFighter:Input("StartShooting") task.wait(0.03) fc.LocalFighter:Input("StopShooting") end
                end)
            end
        end
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

pcall(function()
    local ok, Gun = pcall(function() return require(LocalPlayer.PlayerScripts.Modules.ItemTypes.Gun) end)
    if ok and Gun and Gun.IsFullyAiming and not Gun.__uev3_hooked then
        Gun.__uev3_hooked = true
        local orig = Gun.IsFullyAiming
        Gun.IsFullyAiming = function(self, ...)
            if S.silent.enable or S.misc.gun_mods.enable then return true end
            return orig(self, ...)
        end
    end
end)

-- ============================================================================
-- RAGEBOT
-- ============================================================================
local rageCache = { last_target=nil, last_shot=0 }

local function ragePickTarget()
    local best, bestVal = nil, math.huge
    local isLowest = S.ragebot.priority == "lowest_hp"
    local isDistance = S.ragebot.priority == "distance"
    local isFov = S.ragebot.priority == "fov"
    local center = Camera.ViewportSize / 2
    local hrp = getHRP() if not hrp then return nil end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and alive(plr) and (not S.ragebot.team_check or not isTeammate(plr)) then
            local part = plr.Character:FindFirstChild(S.ragebot.force_body and "HumanoidRootPart" or "Head")
            if part then
                local d3 = (part.Position - hrp.Position).Magnitude
                if d3 <= S.ragebot.max_range then
                    local val
                    if isLowest then val = plr.Character:FindFirstChildOfClass("Humanoid").Health
                    elseif isDistance then val = d3
                    elseif isFov then
                        local on, scr = onscreen(part.Position)
                        val = on and (scr - center).Magnitude or math.huge
                    else val = math.random() end
                    if val < bestVal then bestVal=val best=plr end
                end
            end
        end
    end
    return best
end

bin(task.spawn(function()
    while task.wait(0.03) do
        if not S.ragebot.enable then continue end
        local tgt = ragePickTarget()
        if not tgt then continue end
        local part = tgt.Character and tgt.Character:FindFirstChild(S.ragebot.force_body and "HumanoidRootPart" or "Head")
        if not part then continue end
        local hrp = getHRP() if not hrp then continue end
        local savedCF = hrp.CFrame
        local targetPos = S.ragebot.prediction and predict(part, 0.15) or part.Position
        local offset = Vector3.new(0, S.ragebot.y_offset, 0)
        pcall(function()
            hrp.CFrame = CFrame.new(targetPos + offset)
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
-- ESP MODULE
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
        box_fill = Drawing.new("Square"),
        name     = Drawing.new("Text"),
        user     = Drawing.new("Text"),
        health   = Drawing.new("Text"),
        hp_bar   = Drawing.new("Line"),
        hp_bar_bg= Drawing.new("Line"),
        armor_bar= Drawing.new("Line"),
        armor_bg = Drawing.new("Line"),
        dist     = Drawing.new("Text"),
        weapon   = Drawing.new("Text"),
        flags    = Drawing.new("Text"),
        tracer   = Drawing.new("Line"),
        dot      = Drawing.new("Circle"),
        viewline = Drawing.new("Line"),
        arrow_a  = Drawing.new("Line"),
        arrow_b  = Drawing.new("Line"),
        arrow_c  = Drawing.new("Line"),
        skeleton = {},
        corner_tl_h = Drawing.new("Line"), corner_tl_v = Drawing.new("Line"),
        corner_tr_h = Drawing.new("Line"), corner_tr_v = Drawing.new("Line"),
        corner_bl_h = Drawing.new("Line"), corner_bl_v = Drawing.new("Line"),
        corner_br_h = Drawing.new("Line"), corner_br_v = Drawing.new("Line"),
    }
    for i=1,#skeletonLinks do
        local l = Drawing.new("Line") l.Thickness=1 l.Visible=false
        e.skeleton[i] = l
    end
    e.box.Filled=false     e.box.Thickness=1     e.box.Visible=false
    e.box_out.Filled=false e.box_out.Thickness=3 e.box_out.Color=Color3.new(0,0,0) e.box_out.Visible=false
    e.box_fill.Filled=true e.box_fill.Transparency=0.8 e.box_fill.Visible=false
    for _,t in ipairs({e.name,e.user,e.health,e.dist,e.weapon,e.flags}) do
        t.Size=14 t.Center=true t.Outline=true t.Visible=false t.Font=Drawing.Fonts.Plex
    end
    e.hp_bar.Thickness=2    e.hp_bar.Visible=false
    e.hp_bar_bg.Thickness=4 e.hp_bar_bg.Color=Color3.new(0,0,0) e.hp_bar_bg.Visible=false
    e.armor_bar.Thickness=2 e.armor_bar.Visible=false
    e.armor_bg.Thickness=4  e.armor_bg.Color=Color3.new(0,0,0) e.armor_bg.Visible=false
    e.tracer.Thickness=1    e.tracer.Visible=false
    e.dot.NumSides=16 e.dot.Radius=3 e.dot.Thickness=1 e.dot.Filled=true e.dot.Visible=false
    e.viewline.Thickness=1 e.viewline.Visible=false
    for _,a in ipairs({e.arrow_a,e.arrow_b,e.arrow_c}) do a.Thickness=1 a.Visible=false end
    for _,c in ipairs({e.corner_tl_h,e.corner_tl_v,e.corner_tr_h,e.corner_tr_v,
                      e.corner_bl_h,e.corner_bl_v,e.corner_br_h,e.corner_br_v}) do
        c.Thickness=1 c.Visible=false
    end
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

        local boxColor = S.esp.rainbow and rainbow(1) or S.esp.box.color

        if S.esp.box.enable then
            if S.esp.box.style == "Corner" then
                local cornerLen = math.min(width, height) / 4
                local tl = topLeft
                local tr = topLeft + Vector2.new(width, 0)
                local bl = topLeft + Vector2.new(0, height)
                local br = topLeft + Vector2.new(width, height)
                for _,c in ipairs({e.corner_tl_h,e.corner_tl_v,e.corner_tr_h,e.corner_tr_v,
                                  e.corner_bl_h,e.corner_bl_v,e.corner_br_h,e.corner_br_v}) do
                    c.Color = boxColor c.Thickness = S.esp.box.thickness c.Visible = true
                end
                e.corner_tl_h.From=tl e.corner_tl_h.To=tl+Vector2.new(cornerLen,0)
                e.corner_tl_v.From=tl e.corner_tl_v.To=tl+Vector2.new(0,cornerLen)
                e.corner_tr_h.From=tr e.corner_tr_h.To=tr-Vector2.new(cornerLen,0)
                e.corner_tr_v.From=tr e.corner_tr_v.To=tr+Vector2.new(0,cornerLen)
                e.corner_bl_h.From=bl e.corner_bl_h.To=bl+Vector2.new(cornerLen,0)
                e.corner_bl_v.From=bl e.corner_bl_v.To=bl-Vector2.new(0,cornerLen)
                e.corner_br_h.From=br e.corner_br_h.To=br-Vector2.new(cornerLen,0)
                e.corner_br_v.From=br e.corner_br_v.To=br-Vector2.new(0,cornerLen)
                e.box.Visible=false e.box_out.Visible=false
            else
                e.box.Size      = Vector2.new(width, height)
                e.box.Position  = topLeft
                e.box.Color     = boxColor
                e.box.Thickness = S.esp.box.thickness
                e.box.Visible   = true
                if S.esp.box.outline then
                    e.box_out.Size=e.box.Size e.box_out.Position=e.box.Position e.box_out.Visible=true
                else e.box_out.Visible=false end
                for _,c in ipairs({e.corner_tl_h,e.corner_tl_v,e.corner_tr_h,e.corner_tr_v,
                                  e.corner_bl_h,e.corner_bl_v,e.corner_br_h,e.corner_br_v}) do c.Visible=false end
            end
            if S.esp.box.fill then
                e.box_fill.Size = Vector2.new(width, height)
                e.box_fill.Position = topLeft
                e.box_fill.Color = S.esp.box.fill_color
                e.box_fill.Transparency = S.esp.box.fill_t
                e.box_fill.Visible = true
            else e.box_fill.Visible = false end
        else
            e.box.Visible=false e.box_out.Visible=false e.box_fill.Visible=false
            for _,c in ipairs({e.corner_tl_h,e.corner_tl_v,e.corner_tr_h,e.corner_tr_v,
                              e.corner_bl_h,e.corner_bl_v,e.corner_br_h,e.corner_br_v}) do c.Visible=false end
        end

        if S.esp.name.enable then
            e.name.Text     = (S.esp.name.show_prefix and "[UE] " or "") ..
                              (S.esp.name.show_display and plr.DisplayName or plr.Name)
            e.name.Position = Vector2.new(headScr.X, headScr.Y - 16)
            e.name.Color    = S.esp.name.color
            e.name.Size     = S.esp.name.size
            e.name.Visible  = true
            if S.esp.name.show_user and plr.Name ~= plr.DisplayName then
                e.user.Text = "@" .. plr.Name
                e.user.Position = Vector2.new(headScr.X, headScr.Y - 30)
                e.user.Color = S.esp.name.color
                e.user.Size = S.esp.name.size - 2
                e.user.Visible = true
            else e.user.Visible=false end
        else e.name.Visible=false e.user.Visible=false end

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
            e.dist.Size     = S.esp.distance.size
            e.dist.Visible  = true
        else e.dist.Visible=false end

        if S.esp.weapon.enable then
            local tool = char:FindFirstChildOfClass("Tool")
            e.weapon.Text     = tool and tool.Name or ""
            e.weapon.Position = Vector2.new(headScr.X, footScr.Y + 30)
            e.weapon.Color    = S.esp.weapon.color
            e.weapon.Visible  = tool ~= nil
        else e.weapon.Visible=false end

        if S.esp.flags.enable then
            local flags = {}
            if hum.Health < hum.MaxHealth * 0.3 then table.insert(flags, "LOW") end
            local tool = char:FindFirstChildOfClass("Tool")
            if tool then table.insert(flags, tool.Name:sub(1,6):upper()) end
            e.flags.Text = table.concat(flags, " ")
            e.flags.Position = Vector2.new(headScr.X + width/2 + 15, headScr.Y)
            e.flags.Color = S.esp.flags.color
            e.flags.Visible = #flags > 0
        else e.flags.Visible=false end

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
            e.dot.Radius   = S.esp.head_dot.size
            e.dot.Visible  = true
        else e.dot.Visible=false end

        if S.esp.viewangle.enable then
            local look = head.CFrame.LookVector
            local endPos = head.Position + look * S.esp.viewangle.length
            local on1, s1 = onscreen(head.Position)
            local on2, s2 = onscreen(endPos)
            if on1 and on2 then
                e.viewline.From = s1 e.viewline.To = s2
                e.viewline.Color = S.esp.viewangle.color
                e.viewline.Visible = true
            else e.viewline.Visible=false end
        else e.viewline.Visible=false end

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
local xhairOutlines = {}
for i=1,4 do local l=Drawing.new("Line") l.Thickness=3 l.Color=Color3.new(0,0,0) l.Visible=false xhairOutlines[i]=l bin(l) end
local xhairDot = Drawing.new("Circle") xhairDot.Filled=true xhairDot.Radius=1 xhairDot.NumSides=12 xhairDot.Visible=false
bin(xhairDot)
local xhairCircle = Drawing.new("Circle") xhairCircle.Filled=false xhairCircle.NumSides=48 xhairCircle.Visible=false
bin(xhairCircle)

local xhairT = 0
bin(RunService.RenderStepped:Connect(function(dt)
    xhairT = xhairT + dt
    if not S.crosshair.enable then
        for _,l in ipairs(xhairLines) do l.Visible=false end
        for _,l in ipairs(xhairOutlines) do l.Visible=false end
        xhairDot.Visible=false xhairCircle.Visible=false
        return
    end
    local c = Camera.ViewportSize/2
    local len, gap = S.crosshair.length, S.crosshair.gap
    local col = S.crosshair.color
    if S.crosshair.rainbow then col = rainbow(S.crosshair.rainbow_speed) end
    if S.crosshair.pulse then
        local mul = 0.6 + 0.4 * math.abs(math.sin(xhairT * S.crosshair.pulse_speed))
        col = Color3.new(col.R * mul, col.G * mul, col.B * mul)
    end
    for i,l in ipairs(xhairLines) do l.Color=col l.Thickness=S.crosshair.thickness l.Visible=true end
    for i,l in ipairs(xhairOutlines) do
        l.Color=S.crosshair.outline_color
        l.Thickness=S.crosshair.thickness + S.crosshair.outline_thickness*2
        l.Visible=S.crosshair.outline
    end
    local pts = {
        { c + Vector2.new(0, -gap),       c + Vector2.new(0, -gap - len) },
        { c + Vector2.new(0,  gap),       c + Vector2.new(0,  gap + len) },
        { c + Vector2.new(-gap, 0),       c + Vector2.new(-gap - len, 0) },
        { c + Vector2.new( gap, 0),       c + Vector2.new( gap + len, 0) },
    }
    for i=1,4 do
        xhairLines[i].From = pts[i][1] xhairLines[i].To = pts[i][2]
        xhairOutlines[i].From = pts[i][1] xhairOutlines[i].To = pts[i][2]
    end
    if S.crosshair.t_shape then
        xhairLines[1].Visible=false xhairOutlines[1].Visible=false
    end
    if S.crosshair.circle then
        xhairCircle.Position=c xhairCircle.Radius=S.crosshair.circle_radius xhairCircle.Color=col xhairCircle.Visible=true
    else xhairCircle.Visible=false end
    if S.crosshair.dot then
        xhairDot.Position=c xhairDot.Color=S.crosshair.dot_color xhairDot.Radius=S.crosshair.dot_size xhairDot.Visible=true
    else xhairDot.Visible=false end
end))

-- ============================================================================
-- CHARACTER
-- ============================================================================
bin(RunService.Heartbeat:Connect(function()
    local hum = getHum() if not hum then return end
    if S.character.walkspeed.enable then hum.WalkSpeed = S.character.walkspeed.value end
    if S.character.jumppower.enable then hum.UseJumpPower=true hum.JumpPower=S.character.jumppower.value end
    if S.character.hipheight.enable then hum.HipHeight = S.character.hipheight.value end
    if S.character.gravity.enable then Workspace.Gravity = S.character.gravity.value end
    if S.character.auto_bhop.enable and UserInputService:IsKeyDown(Enum.KeyCode.Space) then
        if hum:GetState() == Enum.HumanoidStateType.Landed or hum.FloorMaterial ~= Enum.Material.Air then
            hum.Jump = true
        end
    end
    if S.character.god_mode.enable then
        pcall(function() hum.Health = hum.MaxHealth end)
    end
    if S.character.heal.enable then
        pcall(function() hum.Health = math.min(hum.Health + S.character.heal.rate, hum.MaxHealth) end)
    end
    if S.character.remove_fall_damage.enable then
        pcall(function()
            hum:GetPropertyChangedSignal("FloorMaterial"):Connect(function()
                hum.Health = hum.MaxHealth
            end)
        end)
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

bin(LocalPlayer.CharacterAdded:Connect(function()
    if S.character.auto_respawn.enable then task.wait(1) end
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

    if S.movement.anti_void.enable then
        local hrp = getHRP()
        if hrp and hrp.Position.Y < S.movement.anti_void.floor then
            hrp.CFrame = CFrame.new(0, S.movement.anti_void.tp_to, 0) * (hrp.CFrame - hrp.CFrame.Position)
        end
    end

    if S.movement.slow_fall.enable then
        local hrp = getHRP()
        if hrp and hrp.AssemblyLinearVelocity.Y < -5 then
            hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, -S.movement.slow_fall.strength/10, hrp.AssemblyLinearVelocity.Z)
        end
    end
end))

local function pickMovementTarget(method)
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
    local tgt = pickMovementTarget(S.movement.teleport.method)
    if not tgt then return end
    local hrp = getHRP() if not hrp then return end
    local tp = tgt.Character and tgt.Character:FindFirstChild("HumanoidRootPart") if not tp then return end
    local offset = Vector3.new(0, S.movement.teleport.y_offset, 0)
    if S.movement.teleport.prediction then offset = offset + tp.AssemblyLinearVelocity * 0.15 end
    hrp.CFrame = CFrame.new(tp.Position + offset) * (hrp.CFrame - hrp.CFrame.Position)
end

local function tpToMouse()
    local hrp = getHRP() if not hrp then return end
    if Mouse.Hit then
        hrp.CFrame = CFrame.new(Mouse.Hit.Position + Vector3.new(0, 3, 0))
    end
end

-- ============================================================================
-- WORLD / LIGHTING
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

    if S.world.skybox.enable then
        local sky = Lighting:FindFirstChild("UEV3_Sky")
        if not sky then sky = Instance.new("Sky") sky.Name="UEV3_Sky" sky.Parent=Lighting end
        local tbl = skyboxLibrary[S.world.skybox.selected]
        if tbl then
            sky.SkyboxBk = "rbxassetid://" .. tbl.Bk
            sky.SkyboxDn = "rbxassetid://" .. tbl.Dn
            sky.SkyboxFt = "rbxassetid://" .. tbl.Ft
            sky.SkyboxLf = "rbxassetid://" .. tbl.Lf
            sky.SkyboxRt = "rbxassetid://" .. tbl.Rt
            sky.SkyboxUp = "rbxassetid://" .. tbl.Up
        end
        sky.SunAngularSize = S.world.skybox.remove_sun and 0 or 11
        sky.MoonAngularSize = S.world.skybox.remove_moon and 0 or 11
        sky.StarCount = S.world.skybox.remove_stars and 0 or 3000
    else
        local sky = Lighting:FindFirstChild("UEV3_Sky") if sky then sky:Destroy() end
    end

    if S.world.ambient.enable then
        Lighting.Ambient = S.world.ambient.color
        Lighting.OutdoorAmbient = S.world.ambient.outdoor
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
            for _,v in ipairs(Workspace:GetDescendants()) do
                if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Beam") then v.Enabled=false end
            end
        end
        if S.optim.no_shadows then
            for _,v in ipairs(Workspace:GetDescendants()) do
                if v:IsA("BasePart") then v.CastShadow=false end
            end
        end
        if S.optim.no_textures then
            for _,v in ipairs(Workspace:GetDescendants()) do
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
        if S.optim.no_meshes then
            for _,v in ipairs(Workspace:GetDescendants()) do
                if v:IsA("SpecialMesh") or v:IsA("MeshPart") then
                    pcall(function() v.TextureID = "" end)
                end
            end
        end
        if S.optim.destroy_map_fx then
            for _,v in ipairs(Workspace:GetDescendants()) do
                if v:IsA("Explosion") or v:IsA("PointLight") or v:IsA("SpotLight") or v:IsA("SurfaceLight") then
                    v:Destroy()
                end
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
                    if S.misc.gun_mods.one_shot then item.Damage=999 end
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
-- WATERMARK
-- ============================================================================
local wmGui = Instance.new("ScreenGui")
wmGui.Name = "UEV3_Watermark"
wmGui.ResetOnSpawn = false
wmGui.IgnoreGuiInset = true
wmGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function() wmGui.Parent = (gethui and gethui()) or game:GetService("CoreGui") end)
bin(wmGui)

local wmFrame = Instance.new("Frame")
wmFrame.Size = UDim2.new(0, 280, 0, 24)
wmFrame.Position = UDim2.new(0, 10, 0, 10)
wmFrame.BackgroundColor3 = Color3.fromRGB(13,13,15)
wmFrame.BorderSizePixel = 0
wmFrame.Parent = wmGui
local wmCorner = Instance.new("UICorner", wmFrame) wmCorner.CornerRadius = UDim.new(0,4)
local wmStroke = Instance.new("UIStroke", wmFrame) wmStroke.Color=Color3.fromRGB(196,30,58) wmStroke.Thickness=1
local wmAccent = Instance.new("Frame")
wmAccent.Size = UDim2.new(0, 3, 1, 0)
wmAccent.Position = UDim2.new(0, 0, 0, 0)
wmAccent.BackgroundColor3 = Color3.fromRGB(196,30,58)
wmAccent.BorderSizePixel = 0
wmAccent.Parent = wmFrame
local wmLabel = Instance.new("TextLabel")
wmLabel.BackgroundTransparency = 1
wmLabel.Size = UDim2.new(1,-10,1,0)
wmLabel.Position = UDim2.new(0,8,0,0)
wmLabel.Font = Enum.Font.Code
wmLabel.TextColor3 = Color3.fromRGB(235,235,240)
wmLabel.TextSize = 13
wmLabel.TextXAlignment = Enum.TextXAlignment.Left
wmLabel.Parent = wmFrame

local wmTick = 0
bin(RunService.Heartbeat:Connect(function(dt)
    wmTick = wmTick + dt
    if wmTick < 0.25 then return end wmTick = 0
    if not S.misc.watermark then wmGui.Enabled=false return end
    wmGui.Enabled = true
    local fps = math.floor(1 / math.max(RunService.RenderStepped:Wait(), 0.001))
    local ping = math.floor(LocalPlayer:GetNetworkPing() * 1000)
    local t = os.date("%H:%M:%S")
    wmLabel.Text = string.format(" UE V3 | %d fps | %d ms | %s", fps, ping, t)
    local positions = {
        top_left     = UDim2.new(0, 10, 0, 10),
        top_right    = UDim2.new(1, -290, 0, 10),
        bottom_left  = UDim2.new(0, 10, 1, -34),
        bottom_right = UDim2.new(1, -290, 1, -34),
    }
    wmFrame.Position = positions[S.misc.watermark_pos] or positions.top_left
end))

-- ============================================================================
-- KILLFEED (own feed)
-- ============================================================================
local kfGui = Instance.new("ScreenGui")
kfGui.Name = "UEV3_Killfeed"
kfGui.ResetOnSpawn = false
kfGui.IgnoreGuiInset = true
pcall(function() kfGui.Parent = (gethui and gethui()) or game:GetService("CoreGui") end)
bin(kfGui)

local kfList = Instance.new("Frame")
kfList.Size = UDim2.new(0, 260, 0, 200)
kfList.Position = UDim2.new(1, -270, 0, 50)
kfList.BackgroundTransparency = 1
kfList.Parent = kfGui
local kfLayout = Instance.new("UIListLayout", kfList)
kfLayout.Padding = UDim.new(0, 4)
kfLayout.SortOrder = Enum.SortOrder.LayoutOrder

local function addKillfeedEntry(text)
    if not S.misc.killfeed.enable then return end
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, 22)
    f.BackgroundColor3 = Color3.fromRGB(13,13,15)
    f.BackgroundTransparency = 0.2
    f.BorderSizePixel = 0
    f.Parent = kfList
    local c = Instance.new("UICorner", f) c.CornerRadius = UDim.new(0,4)
    local s = Instance.new("UIStroke", f) s.Color=Color3.fromRGB(196,30,58) s.Thickness=1
    local l = Instance.new("TextLabel")
    l.BackgroundTransparency = 1
    l.Size = UDim2.new(1,-10,1,0)
    l.Position = UDim2.new(0,5,0,0)
    l.Font = Enum.Font.Code
    l.TextColor3 = Color3.fromRGB(235,235,240)
    l.TextSize = 12
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Text = text
    l.Parent = f
    task.delay(5, function()
        for i=0,1,0.05 do f.BackgroundTransparency=0.2+i*0.8 l.TextTransparency=i task.wait(0.02) end
        f:Destroy()
    end)
end

-- ============================================================================
-- HIT SOUND
-- ============================================================================
local function playHit()
    if not S.misc.hitsounds.enable then return end
    local id = S.misc.hitsounds.custom ~= "" and ("rbxassetid://"..S.misc.hitsounds.custom)
               or ("rbxassetid://"..(hitSoundLibrary[S.misc.hitsounds.id] or hitSoundLibrary.hitmarker))
    playSound(id, S.misc.hitsounds.volume, S.misc.hitsounds.pitch)
end

local function playKill()
    if not S.misc.killsound.enable then return end
    local id = S.misc.killsound.custom ~= "" and ("rbxassetid://"..S.misc.killsound.custom)
               or ("rbxassetid://"..(killSoundLibrary[S.misc.killsound.id] or killSoundLibrary.rust))
    playSound(id, S.misc.killsound.volume, 1)
end

pcall(function()
    local rs = ReplicatedStorage
    for _, v in ipairs(rs:GetDescendants()) do
        if v:IsA("RemoteEvent") then
            local n = v.Name:lower()
            if n:find("hit") then v.OnClientEvent:Connect(function() playHit() end) end
            if n:find("kill") then v.OnClientEvent:Connect(function() playKill() addKillfeedEntry("You eliminated someone") end) end
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
    if S.movement.teleport.key ~= "None" and input.KeyCode == Enum.KeyCode[S.movement.teleport.key] then doTeleport() end
    if S.movement.tp_to_mouse.enable and input.KeyCode == Enum.KeyCode[S.movement.tp_to_mouse.key] then tpToMouse() end
    if S.character.instant_reset.enable and input.KeyCode == Enum.KeyCode[S.character.instant_reset.key] then
        local h = getHum() if h then h.Health = 0 end
    end
end))

-- ============================================================================
-- GUI BUILD — RAGE TAB
-- ============================================================================
do
    local g = Tabs.Rage:AddLeftGroupbox("Ragebot")
    g:AddToggle("rage_enable", {Text="Enabled", Default=false}):OnChanged(function(v) S.ragebot.enable=v end)
    g:AddToggle("rage_shoot",  {Text="Auto Shoot", Default=true}):OnChanged(function(v) S.ragebot.autoshoot=v end)
    g:AddToggle("rage_scope",  {Text="Auto Scope", Default=true}):OnChanged(function(v) S.ragebot.autoscope=v end)
    g:AddToggle("rage_pred",   {Text="Prediction", Default=true}):OnChanged(function(v) S.ragebot.prediction=v end)
    g:AddToggle("rage_team",   {Text="Team Check", Default=true}):OnChanged(function(v) S.ragebot.team_check=v end)
    g:AddToggle("rage_body",   {Text="Force Body", Default=false}):OnChanged(function(v) S.ragebot.force_body=v end)
    g:AddToggle("rage_dt",     {Text="Double Tap", Default=false}):OnChanged(function(v) S.ragebot.double_tap=v end)
    g:AddToggle("rage_hide",   {Text="Hide Shots", Default=false}):OnChanged(function(v) S.ragebot.hide_shots=v end)
    g:AddToggle("rage_qp",     {Text="Quick Peek", Default=false}):OnChanged(function(v) S.ragebot.quick_peek=v end)
    g:AddToggle("rage_knife",  {Text="Auto Knife", Default=false}):OnChanged(function(v) S.ragebot.auto_knife=v end)
    g:AddSlider("rage_hc",     {Text="Hitchance", Default=70, Min=0, Max=100}):OnChanged(function(v) S.ragebot.hitchance=v end)
    g:AddSlider("rage_tp",     {Text="TP Duration", Default=0.15, Min=0, Max=1, Rounding=2}):OnChanged(function(v) S.ragebot.tp_duration=v end)
    g:AddSlider("rage_y",      {Text="Y Offset", Default=3, Min=-10, Max=10, Rounding=1}):OnChanged(function(v) S.ragebot.y_offset=v end)
    g:AddSlider("rage_range",  {Text="Max Range", Default=2000, Min=100, Max=5000}):OnChanged(function(v) S.ragebot.max_range=v end)
    g:AddSlider("rage_dmg",    {Text="Min Damage", Default=1, Min=1, Max=100}):OnChanged(function(v) S.ragebot.min_damage=v end)
    g:AddDropdown("rage_prio", {Text="Priority", Values={"distance","fov","lowest_hp","random"}, Default="distance"}):OnChanged(function(v) S.ragebot.priority=v end)
end

do
    local g = Tabs.Rage:AddRightGroupbox("Anti-Aim")
    g:AddToggle("aa_e",     {Text="Enabled", Default=false}):OnChanged(function(v) S.anti_aim.enable=v end)
    g:AddDropdown("aa_p",   {Text="Pitch", Values={"Off","Up","Down","Zero"}, Default="Down"}):OnChanged(function(v) S.anti_aim.pitch=v end)
    g:AddDropdown("aa_y",   {Text="Yaw", Values={"Off","Spin","Jitter","Backward","Random"}, Default="Spin"}):OnChanged(function(v) S.anti_aim.yaw=v end)
    g:AddSlider("aa_speed", {Text="Yaw Speed", Default=6, Min=1, Max=60}):OnChanged(function(v) S.anti_aim.yaw_speed=v end)
    g:AddToggle("aa_jit",   {Text="Jitter", Default=false}):OnChanged(function(v) S.anti_aim.jitter=v end)
    g:AddToggle("aa_fl",    {Text="Fake Lag", Default=false}):OnChanged(function(v) S.anti_aim.fake_lag=v end)
    g:AddSlider("aa_fla",   {Text="Fake Lag Amount", Default=2, Min=1, Max=14}):OnChanged(function(v) S.anti_aim.fake_lag_amt=v end)
    g:AddToggle("aa_edge",  {Text="Edge Yaw", Default=false}):OnChanged(function(v) S.anti_aim.edge_yaw=v end)
    g:AddToggle("aa_at",    {Text="At Target", Default=false}):OnChanged(function(v) S.anti_aim.at_target=v end)
    g:AddToggle("aa_lby",   {Text="LBY Break", Default=false}):OnChanged(function(v) S.anti_aim.lby_break=v end)
end

do
    local g = Tabs.Rage:AddLeftGroupbox("Silent Aim")
    g:AddToggle("sa_enable", {Text="Enabled", Default=false}):OnChanged(function(v) S.silent.enable=v end)
    g:AddLabel("Silent Key"):AddKeyPicker("silent_aim_key", {Default="None", Mode="Always", Text="Silent Key"})
    g:AddToggle("sa_fov",    {Text="Show FOV", Default=true}):OnChanged(function(v) S.silent.show_fov=v end)
    g:AddSlider("sa_fov_r",  {Text="FOV Radius", Default=300, Min=20, Max=800}):OnChanged(function(v) S.silent.fov=v end)
    g:AddSlider("sa_hc",     {Text="Hit Chance", Default=70, Min=0, Max=100}):OnChanged(function(v) S.silent.hitchance=v end)
    g:AddDropdown("sa_part", {Text="Hit Part", Values={"Head","Torso","HumanoidRootPart","UpperTorso"}, Default="Head"}):OnChanged(function(v) S.silent.hit_part=v end)
    g:AddToggle("sa_team",   {Text="Team Check", Default=true}):OnChanged(function(v) S.silent.team_check=v end)
    g:AddToggle("sa_res",    {Text="Resolver", Default=true}):OnChanged(function(v) S.silent.resolver=v end)
    g:AddToggle("sa_wb",     {Text="Wallbangs", Default=true}):OnChanged(function(v) S.silent.wallbangs=v end)
    g:AddToggle("sa_body",   {Text="Body Aim", Default=false}):OnChanged(function(v) S.silent.body_aim=v end)
    g:AddLabel("FOV Color"):AddColorPicker("sa_fov_c", {Default=Color3.fromRGB(255,255,255)}):OnChanged(function(v) S.silent.fov_color=v end)
end

-- ============================================================================
-- GUI BUILD — LEGIT TAB
-- ============================================================================
do
    local g = Tabs.Legit:AddLeftGroupbox("Aimbot")
    g:AddToggle("aim_enable",   {Text="Enabled", Default=false}):OnChanged(function(v) S.aimbot.enable=v end)
    g:AddLabel("Aim Key"):AddKeyPicker("aimbot_key",{Default="MouseButton2",Mode="Hold",Text="Aim Key"})
    g:AddToggle("aim_fov",      {Text="Show FOV", Default=true}):OnChanged(function(v) S.aimbot.show_fov=v end)
    g:AddToggle("aim_fov_fill", {Text="Fill FOV", Default=false}):OnChanged(function(v) S.aimbot.fov_filled=v end)
    g:AddSlider("aim_fov_t",    {Text="Fill Transparency", Default=1, Min=0, Max=1, Rounding=2}):OnChanged(function(v) S.aimbot.fov_transparency=v end)
    g:AddSlider("aim_fov_r",    {Text="FOV Radius", Default=180, Min=10, Max=600}):OnChanged(function(v) S.aimbot.fov=v end)
    g:AddToggle("aim_split",    {Text="Split Smoothing", Default=false}):OnChanged(function(v) S.aimbot.split_smoothing=v end)
    g:AddSlider("aim_smooth",   {Text="Smoothing", Default=3, Min=1, Max=100}):OnChanged(function(v) S.aimbot.smoothing=v end)
    g:AddSlider("aim_smooth_x", {Text="Smoothing X", Default=3, Min=1, Max=100}):OnChanged(function(v) S.aimbot.smoothing_x=v end)
    g:AddSlider("aim_smooth_y", {Text="Smoothing Y", Default=3, Min=1, Max=100}):OnChanged(function(v) S.aimbot.smoothing_y=v end)
    g:AddSlider("aim_pred",     {Text="Prediction", Default=0.165, Min=0, Max=0.5, Rounding=3}):OnChanged(function(v) S.aimbot.prediction=v end)
    g:AddSlider("aim_dist",     {Text="Max Distance", Default=1500, Min=100, Max=5000}):OnChanged(function(v) S.aimbot.max_dist=v end)
    g:AddDropdown("aim_part",   {Text="Hit Part", Values={"Head","Torso","HumanoidRootPart","UpperTorso"}, Default="Head"}):OnChanged(function(v) S.aimbot.hit_part=v end)
    g:AddToggle("aim_vis",      {Text="Visible Only", Default=false}):OnChanged(function(v) S.aimbot.visible_only=v end)
    g:AddToggle("aim_wall",     {Text="Wallcheck Bones", Default=false}):OnChanged(function(v) S.aimbot.wallcheck=v end)
    g:AddToggle("aim_team",     {Text="Team Check", Default=true}):OnChanged(function(v) S.aimbot.team_check=v end)
    g:AddToggle("aim_snap",     {Text="Snapline", Default=false}):OnChanged(function(v) S.aimbot.snapline=v end)
    g:AddSlider("aim_snap_t",   {Text="Snapline Thick", Default=1, Min=1, Max=5}):OnChanged(function(v) S.aimbot.snapline_thickness=v end)
    g:AddLabel("Snap Color"):AddColorPicker("aim_snap_c", {Default=Color3.fromRGB(255,255,255)}):OnChanged(function(v) S.aimbot.snapline_color=v end)
    g:AddToggle("aim_sound",    {Text="Lock Sound", Default=false}):OnChanged(function(v) S.aimbot.lock_sound=v end)
    g:AddSlider("aim_sound_v",  {Text="Lock Volume", Default=0.6, Min=0, Max=3, Rounding=2}):OnChanged(function(v) S.aimbot.lock_vol=v end)
    g:AddLabel("FOV Color"):AddColorPicker("aim_fov_c", {Default=Color3.fromRGB(196,30,58)}):OnChanged(function(v) S.aimbot.fov_color=v end)
end

do
    local g = Tabs.Legit:AddRightGroupbox("Triggerbot")
    g:AddToggle("tb_enable", {Text="Enabled", Default=false}):OnChanged(function(v) S.triggerbot.enable=v end)
    g:AddDropdown("tb_mode", {Text="Mode", Values={"Always","Hold"}, Default="Hold"}):OnChanged(function(v) S.triggerbot.mode=v end)
    g:AddDropdown("tb_key",  {Text="Hold Key", Values={"MouseButton4","MouseButton5","X","C","V","B"}, Default="MouseButton4"}):OnChanged(function(v) S.triggerbot.key=v end)
    g:AddToggle("tb_team",   {Text="Team Check", Default=true}):OnChanged(function(v) S.triggerbot.team_check=v end)
    g:AddToggle("tb_head",   {Text="Headshot Only", Default=false}):OnChanged(function(v) S.triggerbot.headshot_only=v end)
    g:AddToggle("tb_scope",  {Text="Scope Only", Default=false}):OnChanged(function(v) S.triggerbot.scope_only=v end)
    g:AddToggle("tb_burst",  {Text="Burst Fire", Default=false}):OnChanged(function(v) S.triggerbot.burst=v end)
    g:AddSlider("tb_react",  {Text="Reaction", Default=0.05, Min=0, Max=0.5, Rounding=3}):OnChanged(function(v) S.triggerbot.reaction=v end)
    g:AddSlider("tb_delay",  {Text="Fire Delay", Default=0.1, Min=0, Max=1, Rounding=3}):OnChanged(function(v) S.triggerbot.delay=v end)
    g:AddSlider("tb_dist",   {Text="Max Distance", Default=600, Min=50, Max=2500}):OnChanged(function(v) S.triggerbot.max_dist=v end)
end

do
    local g = Tabs.Legit:AddLeftGroupbox("Crosshair")
    g:AddToggle("xh_e",    {Text="Enabled", Default=false}):OnChanged(function(v) S.crosshair.enable=v end)
    g:AddSlider("xh_len",  {Text="Length", Default=6, Min=1, Max=40}):OnChanged(function(v) S.crosshair.length=v end)
    g:AddSlider("xh_gap",  {Text="Gap", Default=3, Min=0, Max=30}):OnChanged(function(v) S.crosshair.gap=v end)
    g:AddSlider("xh_thick",{Text="Thickness", Default=1, Min=1, Max=6}):OnChanged(function(v) S.crosshair.thickness=v end)
    g:AddToggle("xh_out",  {Text="Outline", Default=true}):OnChanged(function(v) S.crosshair.outline=v end)
    g:AddSlider("xh_out_t",{Text="Outline Thickness", Default=1, Min=1, Max=4}):OnChanged(function(v) S.crosshair.outline_thickness=v end)
    g:AddToggle("xh_dot",  {Text="Dot", Default=false}):OnChanged(function(v) S.crosshair.dot=v end)
    g:AddSlider("xh_dot_s",{Text="Dot Size", Default=1, Min=1, Max=8}):OnChanged(function(v) S.crosshair.dot_size=v end)
    g:AddToggle("xh_circ", {Text="Circle", Default=false}):OnChanged(function(v) S.crosshair.circle=v end)
    g:AddSlider("xh_circ_r",{Text="Circle Radius", Default=14, Min=4, Max=60}):OnChanged(function(v) S.crosshair.circle_radius=v end)
    g:AddToggle("xh_t",    {Text="T Shape", Default=false}):OnChanged(function(v) S.crosshair.t_shape=v end)
    g:AddToggle("xh_pulse",{Text="Pulse", Default=false}):OnChanged(function(v) S.crosshair.pulse=v end)
    g:AddSlider("xh_pulse_s",{Text="Pulse Speed", Default=3, Min=1, Max=15}):OnChanged(function(v) S.crosshair.pulse_speed=v end)
    g:AddToggle("xh_rb",   {Text="Rainbow", Default=false}):OnChanged(function(v) S.crosshair.rainbow=v end)
    g:AddSlider("xh_rb_s", {Text="Rainbow Speed", Default=1, Min=0.1, Max=10, Rounding=2}):OnChanged(function(v) S.crosshair.rainbow_speed=v end)
    g:AddLabel("Color"):AddColorPicker("xh_c", {Default=Color3.fromRGB(0,255,170)}):OnChanged(function(v) S.crosshair.color=v end)
    g:AddLabel("Outline Color"):AddColorPicker("xh_oc", {Default=Color3.fromRGB(0,0,0)}):OnChanged(function(v) S.crosshair.outline_color=v end)
    g:AddLabel("Dot Color"):AddColorPicker("xh_dc", {Default=Color3.fromRGB(255,255,255)}):OnChanged(function(v) S.crosshair.dot_color=v end)
end

-- ============================================================================
-- GUI BUILD — VISUALS TAB
-- ============================================================================
do
    local g = Tabs.Visuals:AddLeftGroupbox("ESP Core")
    g:AddToggle("esp_e",      {Text="Enabled", Default=false}):OnChanged(function(v) S.esp.enable=v end)
    g:AddToggle("esp_team",   {Text="Team Check", Default=true}):OnChanged(function(v) S.esp.team_check=v end)
    g:AddToggle("esp_rb",     {Text="Rainbow", Default=false}):OnChanged(function(v) S.esp.rainbow=v end)
    g:AddSlider("esp_dist",   {Text="Max Distance", Default=1000, Min=50, Max=5000}):OnChanged(function(v) S.esp.max_dist=v end)
    g:AddToggle("esp_box",    {Text="Box", Default=true}):OnChanged(function(v) S.esp.box.enable=v end)
    g:AddDropdown("esp_box_s",{Text="Box Style", Values={"2D","Corner"}, Default="2D"}):OnChanged(function(v) S.esp.box.style=v end)
    g:AddSlider("esp_box_t",  {Text="Box Thickness", Default=1, Min=1, Max=5}):OnChanged(function(v) S.esp.box.thickness=v end)
    g:AddToggle("esp_box_out",{Text="Box Outline", Default=true}):OnChanged(function(v) S.esp.box.outline=v end)
    g:AddToggle("esp_box_fill",{Text="Box Fill", Default=false}):OnChanged(function(v) S.esp.box.fill=v end)
    g:AddSlider("esp_box_ft", {Text="Fill Transparency", Default=0.8, Min=0, Max=1, Rounding=2}):OnChanged(function(v) S.esp.box.fill_t=v end)
    g:AddLabel("Box Color"):AddColorPicker("esp_box_c", {Default=Color3.fromRGB(196,30,58)}):OnChanged(function(v) S.esp.box.color=v end)
    g:AddLabel("Fill Color"):AddColorPicker("esp_box_fc", {Default=Color3.fromRGB(196,30,58)}):OnChanged(function(v) S.esp.box.fill_color=v end)
end

do
    local g = Tabs.Visuals:AddRightGroupbox("ESP Text")
    g:AddToggle("esp_name",   {Text="Name", Default=true}):OnChanged(function(v) S.esp.name.enable=v end)
    g:AddToggle("esp_name_d", {Text="Use DisplayName", Default=true}):OnChanged(function(v) S.esp.name.show_display=v end)
    g:AddToggle("esp_name_u", {Text="Show Username", Default=false}):OnChanged(function(v) S.esp.name.show_user=v end)
    g:AddToggle("esp_name_p", {Text="Prefix [UE]", Default=false}):OnChanged(function(v) S.esp.name.show_prefix=v end)
    g:AddSlider("esp_name_s", {Text="Name Size", Default=14, Min=10, Max=22}):OnChanged(function(v) S.esp.name.size=v end)
    g:AddToggle("esp_hp",     {Text="Health Text", Default=true}):OnChanged(function(v) S.esp.health.show_text=v end)
    g:AddToggle("esp_hpbar",  {Text="HP Bar", Default=true}):OnChanged(function(v) S.esp.health.bar=v end)
    g:AddToggle("esp_hpgrad", {Text="HP Gradient", Default=true}):OnChanged(function(v) S.esp.health.gradient=v end)
    g:AddToggle("esp_dists",  {Text="Distance", Default=true}):OnChanged(function(v) S.esp.distance.enable=v end)
    g:AddToggle("esp_wep",    {Text="Weapon", Default=false}):OnChanged(function(v) S.esp.weapon.enable=v end)
    g:AddToggle("esp_flags",  {Text="Flags", Default=false}):OnChanged(function(v) S.esp.flags.enable=v end)
    g:AddToggle("esp_dot",    {Text="Head Dot", Default=false}):OnChanged(function(v) S.esp.head_dot.enable=v end)
    g:AddSlider("esp_dot_s",  {Text="Dot Size", Default=3, Min=1, Max=10}):OnChanged(function(v) S.esp.head_dot.size=v end)
    g:AddToggle("esp_skel",   {Text="Skeleton", Default=false}):OnChanged(function(v) S.esp.skeleton.enable=v end)
    g:AddToggle("esp_view",   {Text="View Angle", Default=false}):OnChanged(function(v) S.esp.viewangle.enable=v end)
    g:AddLabel("Name Color"):AddColorPicker("esp_name_c", {Default=Color3.fromRGB(255,255,255)}):OnChanged(function(v) S.esp.name.color=v end)
    g:AddLabel("HP Color"):AddColorPicker("esp_hp_c", {Default=Color3.fromRGB(80,220,80)}):OnChanged(function(v) S.esp.health.color=v end)
end

do
    local g = Tabs.Visuals:AddLeftGroupbox("Tracers / Arrow")
    g:AddToggle("esp_tr",    {Text="Tracer", Default=false}):OnChanged(function(v) S.esp.tracer.enable=v end)
    g:AddDropdown("esp_tro", {Text="Tracer Origin", Values={"bottom","middle","top"}, Default="bottom"}):OnChanged(function(v) S.esp.tracer.origin=v end)
    g:AddSlider("esp_tr_t",  {Text="Tracer Thickness", Default=1, Min=1, Max=5}):OnChanged(function(v) S.esp.tracer.thickness=v end)
    g:AddLabel("Tracer Color"):AddColorPicker("esp_tr_c", {Default=Color3.fromRGB(196,30,58)}):OnChanged(function(v) S.esp.tracer.color=v end)
    g:AddToggle("esp_arr",   {Text="Offscreen Arrow", Default=false}):OnChanged(function(v) S.esp.offscreen_arrow.enable=v end)
    g:AddSlider("esp_arr_r", {Text="Arrow Radius", Default=200, Min=80, Max=400}):OnChanged(function(v) S.esp.offscreen_arrow.radius=v end)
    g:AddSlider("esp_arr_s", {Text="Arrow Size", Default=14, Min=6, Max=30}):OnChanged(function(v) S.esp.offscreen_arrow.size=v end)
    g:AddLabel("Arrow Color"):AddColorPicker("esp_arr_c", {Default=Color3.fromRGB(196,30,58)}):OnChanged(function(v) S.esp.offscreen_arrow.color=v end)
end

do
    local g = Tabs.Visuals:AddRightGroupbox("Highlight / Chams")
    g:AddToggle("esp_hl",    {Text="Highlight", Default=true}):OnChanged(function(v) S.esp.highlight.enable=v end)
    g:AddLabel("Fill"):AddColorPicker("esp_hl_f", {Default=Color3.fromRGB(196,30,58)}):OnChanged(function(v) S.esp.highlight.fill=v end)
    g:AddSlider("esp_hl_ft", {Text="Fill Transparency", Default=0.5, Min=0, Max=1, Rounding=2}):OnChanged(function(v) S.esp.highlight.fill_t=v end)
    g:AddLabel("Outline"):AddColorPicker("esp_hl_o", {Default=Color3.fromRGB(255,255,255)}):OnChanged(function(v) S.esp.highlight.outline=v end)
    g:AddSlider("esp_hl_ot", {Text="Outline Transparency", Default=0, Min=0, Max=1, Rounding=2}):OnChanged(function(v) S.esp.highlight.outline_t=v end)
    g:AddToggle("esp_ch",    {Text="Chams", Default=false}):OnChanged(function(v) S.esp.chams.enable=v end)
    g:AddDropdown("esp_ch_m",{Text="Chams Material", Values={"Neon","ForceField","Glass","Metal","Ice","Plastic","SmoothPlastic"}, Default="ForceField"}):OnChanged(function(v) S.esp.chams.material=v end)
    g:AddSlider("esp_ch_t",  {Text="Chams Transparency", Default=0, Min=0, Max=1, Rounding=2}):OnChanged(function(v) S.esp.chams.transparency=v end)
    g:AddLabel("Chams Color"):AddColorPicker("esp_ch_c", {Default=Color3.fromRGB(196,30,58)}):OnChanged(function(v) S.esp.chams.color=v end)
end

-- ============================================================================
-- GUI BUILD — WORLD TAB
-- ============================================================================
do
    local g = Tabs.World:AddLeftGroupbox("Camera / View")
    g:AddToggle("fov_e",   {Text="FOV Changer", Default=false}):OnChanged(function(v) S.world.fov.enable=v end)
    g:AddSlider("fov_v",   {Text="FOV", Default=90, Min=20, Max=120}):OnChanged(function(v) S.world.fov.value=v end)
    g:AddToggle("tp_e",    {Text="Third Person", Default=false}):OnChanged(function(v) S.world.third_person.enable=v end)
    g:AddSlider("tp_d",    {Text="TP Distance", Default=10, Min=1, Max=40}):OnChanged(function(v) S.world.third_person.distance=v end)
    g:AddToggle("fog_e",   {Text="Remove Fog", Default=false}):OnChanged(function(v) S.world.remove_fog=v end)
    g:AddToggle("time_e",  {Text="Lock Time", Default=false}):OnChanged(function(v) S.world.time_lock.enable=v end)
    g:AddSlider("time_h",  {Text="Hour", Default=12, Min=0, Max=24, Rounding=1}):OnChanged(function(v) S.world.time_lock.hour=v end)
    g:AddToggle("night_e", {Text="No Night", Default=false}):OnChanged(function(v) S.world.no_night=v end)
end

do
    local g = Tabs.World:AddRightGroupbox("Lighting / FX")
    g:AddToggle("atm_e",   {Text="Atmosphere", Default=false}):OnChanged(function(v) S.world.atmosphere.enable=v end)
    g:AddSlider("atm_d",   {Text="Density", Default=0.3, Min=0, Max=1, Rounding=2}):OnChanged(function(v) S.world.atmosphere.density=v end)
    g:AddSlider("atm_o",   {Text="Offset", Default=0.25, Min=0, Max=1, Rounding=2}):OnChanged(function(v) S.world.atmosphere.offset=v end)
    g:AddSlider("atm_g",   {Text="Glare", Default=0.2, Min=0, Max=3, Rounding=2}):OnChanged(function(v) S.world.atmosphere.glare=v end)
    g:AddSlider("atm_h",   {Text="Haze", Default=1.5, Min=0, Max=10, Rounding=2}):OnChanged(function(v) S.world.atmosphere.haze=v end)
    g:AddLabel("Atmo Color"):AddColorPicker("atm_c", {Default=Color3.fromRGB(180,100,100)}):OnChanged(function(v) S.world.atmosphere.color=v end)
    g:AddLabel("Atmo Decay"):AddColorPicker("atm_dc", {Default=Color3.fromRGB(80,20,20)}):OnChanged(function(v) S.world.atmosphere.decay=v end)
end

do
    local g = Tabs.World:AddLeftGroupbox("Color Correction")
    g:AddToggle("cc_e",  {Text="Enabled", Default=false}):OnChanged(function(v) S.world.color_correction.enable=v end)
    g:AddSlider("cc_sat",{Text="Saturation", Default=0.1, Min=-1, Max=1, Rounding=2}):OnChanged(function(v) S.world.color_correction.saturation=v end)
    g:AddSlider("cc_con",{Text="Contrast", Default=0.15, Min=-1, Max=1, Rounding=2}):OnChanged(function(v) S.world.color_correction.contrast=v end)
    g:AddSlider("cc_br", {Text="Brightness", Default=0, Min=-1, Max=1, Rounding=2}):OnChanged(function(v) S.world.color_correction.brightness=v end)
    g:AddLabel("Tint"):AddColorPicker("cc_t", {Default=Color3.fromRGB(255,220,220)}):OnChanged(function(v) S.world.color_correction.tint=v end)
end

do
    local g = Tabs.World:AddRightGroupbox("Post FX")
    g:AddToggle("bl_e",  {Text="Bloom", Default=false}):OnChanged(function(v) S.world.bloom.enable=v end)
    g:AddSlider("bl_i",  {Text="Bloom Intensity", Default=0.4, Min=0, Max=3, Rounding=2}):OnChanged(function(v) S.world.bloom.intensity=v end)
    g:AddSlider("bl_s",  {Text="Bloom Size", Default=24, Min=0, Max=56}):OnChanged(function(v) S.world.bloom.size=v end)
    g:AddSlider("bl_th", {Text="Bloom Threshold", Default=2, Min=0, Max=5, Rounding=2}):OnChanged(function(v) S.world.bloom.threshold=v end)
    g:AddToggle("blur_e",{Text="Blur", Default=false}):OnChanged(function(v) S.world.blur.enable=v end)
    g:AddSlider("blur_s",{Text="Blur Size", Default=0, Min=0, Max=56}):OnChanged(function(v) S.world.blur.size=v end)
    g:AddToggle("sr_e",  {Text="Sun Rays", Default=false}):OnChanged(function(v) S.world.sunrays.enable=v end)
    g:AddSlider("sr_i",  {Text="Rays Intensity", Default=0.25, Min=0, Max=1, Rounding=2}):OnChanged(function(v) S.world.sunrays.intensity=v end)
    g:AddToggle("dof_e", {Text="Depth Of Field", Default=false}):OnChanged(function(v) S.world.depthoffield.enable=v end)
    g:AddSlider("dof_f", {Text="DOF Focus", Default=5, Min=0, Max=100}):OnChanged(function(v) S.world.depthoffield.focus=v end)
end

do
    local g = Tabs.World:AddLeftGroupbox("Skybox")
    g:AddToggle("sky_e",   {Text="Enabled", Default=false}):OnChanged(function(v) S.world.skybox.enable=v end)
    g:AddDropdown("sky_s", {Text="Preset", Values={"DeepSpace","NebulaBlue","Sunset","Night","Purple","Realistic"}, Default="DeepSpace"}):OnChanged(function(v) S.world.skybox.selected=v end)
    g:AddToggle("sky_rs", {Text="Remove Sun", Default=false}):OnChanged(function(v) S.world.skybox.remove_sun=v end)
    g:AddToggle("sky_rm", {Text="Remove Moon", Default=false}):OnChanged(function(v) S.world.skybox.remove_moon=v end)
    g:AddToggle("sky_rst",{Text="Remove Stars", Default=false}):OnChanged(function(v) S.world.skybox.remove_stars=v end)
end

do
    local g = Tabs.World:AddRightGroupbox("Ambient")
    g:AddToggle("amb_e", {Text="Enabled", Default=false}):OnChanged(function(v) S.world.ambient.enable=v end)
    g:AddLabel("Ambient"):AddColorPicker("amb_c", {Default=Color3.fromRGB(128,128,128)}):OnChanged(function(v) S.world.ambient.color=v end)
    g:AddLabel("Outdoor"):AddColorPicker("amb_oc", {Default=Color3.fromRGB(128,128,128)}):OnChanged(function(v) S.world.ambient.outdoor=v end)
end

-- ============================================================================
-- GUI BUILD — CHARACTER TAB
-- ============================================================================
do
    local g = Tabs.Character:AddLeftGroupbox("Humanoid")
    g:AddToggle("ws_e",{Text="Walkspeed", Default=false}):OnChanged(function(v) S.character.walkspeed.enable=v end)
    g:AddSlider("ws_v",{Text="Walkspeed", Default=20, Min=8, Max=200}):OnChanged(function(v) S.character.walkspeed.value=v end)
    g:AddToggle("jp_e",{Text="Jump Power", Default=false}):OnChanged(function(v) S.character.jumppower.enable=v end)
    g:AddSlider("jp_v",{Text="Jump Power", Default=60, Min=30, Max=500}):OnChanged(function(v) S.character.jumppower.value=v end)
    g:AddToggle("gv_e",{Text="Gravity", Default=false}):OnChanged(function(v) S.character.gravity.enable=v end)
    g:AddSlider("gv_v",{Text="Gravity", Default=196, Min=0, Max=400}):OnChanged(function(v) S.character.gravity.value=v end)
    g:AddToggle("ij_e",{Text="Infinite Jump", Default=false}):OnChanged(function(v) S.character.infjump.enable=v end)
    g:AddToggle("bh_e",{Text="Auto Bhop", Default=false}):OnChanged(function(v) S.character.auto_bhop.enable=v end)
    g:AddToggle("hh_e",{Text="HipHeight", Default=false}):OnChanged(function(v) S.character.hipheight.enable=v end)
    g:AddSlider("hh_v",{Text="HipHeight", Default=2, Min=0, Max=10, Rounding=2}):OnChanged(function(v) S.character.hipheight.value=v end)
    g:AddToggle("god_e",{Text="God Mode", Default=false}):OnChanged(function(v) S.character.god_mode.enable=v end)
    g:AddToggle("heal_e",{Text="Auto Heal", Default=false}):OnChanged(function(v) S.character.heal.enable=v end)
    g:AddSlider("heal_r",{Text="Heal Rate", Default=1, Min=0.1, Max=10, Rounding=2}):OnChanged(function(v) S.character.heal.rate=v end)
    g:AddToggle("fall_e",{Text="No Fall Damage", Default=false}):OnChanged(function(v) S.character.remove_fall_damage.enable=v end)
    g:AddToggle("rst_e",{Text="Instant Reset", Default=false}):OnChanged(function(v) S.character.instant_reset.enable=v end)
    g:AddDropdown("rst_k",{Text="Reset Key", Values={"Y","U","H","J"}, Default="Y"}):OnChanged(function(v) S.character.instant_reset.key=v end)
end

do
    local g = Tabs.Character:AddRightGroupbox("Hitbox / Chams")
    g:AddToggle("hb_e",{Text="Hitbox Expander", Default=false}):OnChanged(function(v) S.character.hitbox_expander.enable=v end)
    g:AddSlider("hb_s",{Text="Hitbox Size", Default=5, Min=1, Max=30}):OnChanged(function(v) S.character.hitbox_expander.size=v end)
    g:AddDropdown("hb_p",{Text="Hitbox Part", Values={"Head","HumanoidRootPart","UpperTorso"}, Default="Head"}):OnChanged(function(v) S.character.hitbox_expander.part=v end)
    g:AddToggle("wc_e",{Text="Weapon Chams", Default=false}):OnChanged(function(v) S.character.weapon_chams.enable=v end)
    g:AddDropdown("wc_m",{Text="Material", Values={"Neon","ForceField","Glass","Metal","Ice","Plastic"}, Default="Neon"}):OnChanged(function(v) S.character.weapon_chams.material=v end)
    g:AddLabel("Weapon Color"):AddColorPicker("wc_c", {Default=Color3.fromRGB(255,255,255)}):OnChanged(function(v) S.character.weapon_chams.color=v end)
    g:AddToggle("ac_e",{Text="Arm Chams", Default=false}):OnChanged(function(v) S.character.arm_chams.enable=v end)
    g:AddToggle("ac_i",{Text="Invisible Arms", Default=false}):OnChanged(function(v) S.character.arm_chams.invisible=v end)
    g:AddLabel("Arm Color"):AddColorPicker("ac_c", {Default=Color3.fromRGB(255,255,255)}):OnChanged(function(v) S.character.arm_chams.color=v end)
    g:AddToggle("narm_e",{Text="Remove Arms", Default=false}):OnChanged(function(v) S.character.no_arm.enable=v end)
    g:AddToggle("nvm_e",{Text="No Viewmodel", Default=false}):OnChanged(function(v) S.character.no_viewmodel.enable=v end)
end

do
    local g = Tabs.Character:AddLeftGroupbox("Viewmodel Offsets")
    g:AddToggle("vmo_e",{Text="Enabled", Default=false}):OnChanged(function(v) S.character.viewmodel_offsets.enable=v end)
    g:AddSlider("vmo_x",{Text="Offset X", Default=0, Min=-10, Max=10, Rounding=2}):OnChanged(function(v) S.character.viewmodel_offsets.x=v end)
    g:AddSlider("vmo_y",{Text="Offset Y", Default=0, Min=-10, Max=10, Rounding=2}):OnChanged(function(v) S.character.viewmodel_offsets.y=v end)
    g:AddSlider("vmo_z",{Text="Offset Z", Default=0, Min=-10, Max=10, Rounding=2}):OnChanged(function(v) S.character.viewmodel_offsets.z=v end)
    g:AddSlider("vmo_f",{Text="Viewmodel FOV", Default=70, Min=20, Max=120}):OnChanged(function(v) S.character.viewmodel_offsets.fov=v end)
end

-- ============================================================================
-- GUI BUILD — MOVEMENT TAB
-- ============================================================================
do
    local g = Tabs.Movement:AddLeftGroupbox("Fly / Noclip")
    g:AddToggle("fly_e",  {Text="Fly", Default=false}):OnChanged(function(v) S.movement.fly.enable=v end)
    g:AddSlider("fly_s",  {Text="Fly Speed", Default=50, Min=10, Max=500}):OnChanged(function(v) S.movement.fly.speed=v end)
    g:AddToggle("fly_nc", {Text="Fly Noclip", Default=false}):OnChanged(function(v) S.movement.fly.noclip=v end)
    g:AddDropdown("fly_m",{Text="Fly Mode", Values={"cframe","velocity","smooth"}, Default="cframe"}):OnChanged(function(v) S.movement.fly.mode=v end)
    g:AddToggle("nc_e",   {Text="Noclip", Default=false}):OnChanged(function(v) S.movement.noclip.enable=v end)
    g:AddToggle("fc_e",   {Text="Freecam", Default=false}):OnChanged(function(v) S.movement.freecam.enable=v end)
    g:AddSlider("fc_s",   {Text="Freecam Speed", Default=20, Min=5, Max=200}):OnChanged(function(v) S.movement.freecam.speed=v end)
end

do
    local g = Tabs.Movement:AddRightGroupbox("Teleport")
    g:AddLabel("TP Key"):AddKeyPicker("tp_key", {Default="T", Mode="Toggle", Text="Teleport"})
    g:AddDropdown("tp_m",{Text="TP Method", Values={"closest","lowest_hp","random"}, Default="closest"}):OnChanged(function(v) S.movement.teleport.method=v end)
    g:AddSlider("tp_y",  {Text="TP Y Offset", Default=0, Min=-20, Max=20, Rounding=1}):OnChanged(function(v) S.movement.teleport.y_offset=v end)
    g:AddToggle("tp_t",  {Text="TP Team Check", Default=true}):OnChanged(function(v) S.movement.teleport.team_check=v end)
    g:AddToggle("tp_p",  {Text="TP Prediction", Default=true}):OnChanged(function(v) S.movement.teleport.prediction=v end)
    g:AddToggle("tpm_e", {Text="TP To Mouse", Default=false}):OnChanged(function(v) S.movement.tp_to_mouse.enable=v end)
    g:AddDropdown("tpm_k",{Text="Mouse TP Key", Values={"F","G","H","J"}, Default="F"}):OnChanged(function(v) S.movement.tp_to_mouse.key=v end)
end

do
    local g = Tabs.Movement:AddLeftGroupbox("Underground / Void")
    g:AddToggle("ug_e",{Text="Underground", Default=false}):OnChanged(function(v) S.movement.underground.enable=v end)
    g:AddSlider("ug_d",{Text="UG Depth", Default=5.8, Min=1, Max=20, Rounding=1}):OnChanged(function(v) S.movement.underground.depth=v end)
    g:AddToggle("av_e",{Text="Anti Void", Default=false}):OnChanged(function(v) S.movement.anti_void.enable=v end)
    g:AddSlider("av_f",{Text="Void Floor", Default=-50, Min=-500, Max=0}):OnChanged(function(v) S.movement.anti_void.floor=v end)
    g:AddSlider("av_t",{Text="TP To Y", Default=0, Min=-100, Max=500}):OnChanged(function(v) S.movement.anti_void.tp_to=v end)
    g:AddToggle("sf_e",{Text="Slow Fall", Default=false}):OnChanged(function(v) S.movement.slow_fall.enable=v end)
    g:AddSlider("sf_s",{Text="Slow Fall Strength", Default=100, Min=10, Max=500}):OnChanged(function(v) S.movement.slow_fall.strength=v end)
end

-- ============================================================================
-- GUI BUILD — MISC TAB
-- ============================================================================
do
    local g = Tabs.Misc:AddLeftGroupbox("Gun Mods")
    g:AddToggle("gm_e",   {Text="Enabled", Default=false}):OnChanged(function(v) S.misc.gun_mods.enable=v end)
    g:AddToggle("gm_rec", {Text="No Recoil", Default=true}):OnChanged(function(v) S.misc.gun_mods.no_recoil=v end)
    g:AddToggle("gm_spr", {Text="No Spread", Default=true}):OnChanged(function(v) S.misc.gun_mods.no_spread=v end)
    g:AddToggle("gm_cd",  {Text="No Cooldown", Default=true}):OnChanged(function(v) S.misc.gun_mods.no_cooldown=v end)
    g:AddToggle("gm_inf", {Text="Infinite Ammo", Default=false}):OnChanged(function(v) S.misc.gun_mods.inf_ammo=v end)
    g:AddToggle("gm_os",  {Text="One Shot", Default=false}):OnChanged(function(v) S.misc.gun_mods.one_shot=v end)
    g:AddToggle("gm_pier",{Text="Pierce Walls", Default=false}):OnChanged(function(v) S.misc.gun_mods.pierce=v end)
    g:AddSlider("gm_proj",{Text="Projectile Speed", Default=0, Min=0, Max=10000}):OnChanged(function(v) S.misc.gun_mods.proj_speed=v end)
end

do
    local g = Tabs.Misc:AddRightGroupbox("Sounds")
    g:AddToggle("hs_e",   {Text="Hit Sounds", Default=false}):OnChanged(function(v) S.misc.hitsounds.enable=v end)
    g:AddDropdown("hs_id",{Text="Hit Sound", Values={"hitmarker","rust","skeet","bell","minecraft","bone","ding","glass","pop","tick"}, Default="hitmarker"}):OnChanged(function(v) S.misc.hitsounds.id=v end)
    g:AddSlider("hs_v",   {Text="Hit Volume", Default=1, Min=0, Max=5, Rounding=2}):OnChanged(function(v) S.misc.hitsounds.volume=v end)
    g:AddSlider("hs_p",   {Text="Hit Pitch", Default=1, Min=0.5, Max=3, Rounding=2}):OnChanged(function(v) S.misc.hitsounds.pitch=v end)
    g:AddInput("hs_c",    {Text="Custom Hit ID", Default=""}):OnChanged(function(v) S.misc.hitsounds.custom=v end)
    g:AddToggle("ks_e",   {Text="Kill Sounds", Default=false}):OnChanged(function(v) S.misc.killsound.enable=v end)
    g:AddDropdown("ks_id",{Text="Kill Sound", Values={"rust","anime","taco","gta","quake","bruh","windows","laugh"}, Default="rust"}):OnChanged(function(v) S.misc.killsound.id=v end)
    g:AddSlider("ks_v",   {Text="Kill Volume", Default=1, Min=0, Max=5, Rounding=2}):OnChanged(function(v) S.misc.killsound.volume=v end)
    g:AddInput("ks_c",    {Text="Custom Kill ID", Default=""}):OnChanged(function(v) S.misc.killsound.custom=v end)
end

do
    local g = Tabs.Misc:AddLeftGroupbox("UI / Display")
    g:AddToggle("wm_e",  {Text="Watermark", Default=true}):OnChanged(function(v) S.misc.watermark=v end)
    g:AddDropdown("wm_p",{Text="Watermark Position", Values={"top_left","top_right","bottom_left","bottom_right"}, Default="top_left"}):OnChanged(function(v) S.misc.watermark_pos=v end)
    g:AddToggle("kf_e",  {Text="Killfeed", Default=false}):OnChanged(function(v) S.misc.killfeed.enable=v end)
    g:AddToggle("notif", {Text="Notifications", Default=true}):OnChanged(function(v) S.misc.notifications=v end)
    g:AddToggle("kb_e",  {Text="Keybinds Display", Default=true}):OnChanged(function(v) S.misc.keybinds_display=v end)
end

do
    local g = Tabs.Misc:AddRightGroupbox("Anti / Auto")
    g:AddToggle("afk_e", {Text="Anti AFK", Default=true}):OnChanged(function(v) S.misc.anti_afk=v end)
    g:AddToggle("ar_e",  {Text="Anti Report", Default=false}):OnChanged(function(v) S.misc.anti_report=v end)
    g:AddToggle("av_e2", {Text="Anti Vote Kick", Default=false}):OnChanged(function(v) S.misc.anti_vote=v end)
    g:AddToggle("cb_e",  {Text="Chat Bypass", Default=false}):OnChanged(function(v) S.misc.chat_bypass=v end)
    g:AddToggle("aa_e2", {Text="Auto Accept Duel", Default=false}):OnChanged(function(v) S.misc.auto_accept.enable=v end)
    g:AddToggle("ard_e", {Text="Auto Ready", Default=false}):OnChanged(function(v) S.misc.auto_ready.enable=v end)
    g:AddToggle("fp_e",  {Text="Fake Ping", Default=false}):OnChanged(function(v) S.misc.fake_ping.enable=v end)
    g:AddSlider("fp_v",  {Text="Fake Ping ms", Default=250, Min=0, Max=999}):OnChanged(function(v) S.misc.fake_ping.value=v end)
end

-- ============================================================================
-- GUI BUILD — SPOOFER TAB
-- ============================================================================
do
    local g = Tabs.Spoofer:AddLeftGroupbox("Account Spoof")
    g:AddToggle("spf_n",  {Text="Spoof Name", Default=false}):OnChanged(function(v) S.spoofer.name.enable=v end)
    g:AddInput("spf_nv",  {Text="Name Value", Default=""}):OnChanged(function(v) S.spoofer.name.value=v end)
    g:AddToggle("spf_d",  {Text="Spoof Display", Default=false}):OnChanged(function(v) S.spoofer.display.enable=v end)
    g:AddInput("spf_dv",  {Text="Display Value", Default=""}):OnChanged(function(v) S.spoofer.display.value=v end)
    g:AddToggle("spf_l",  {Text="Spoof Level", Default=false}):OnChanged(function(v) S.spoofer.level.enable=v end)
    g:AddSlider("spf_lv", {Text="Level", Default=9, Min=0, Max=999}):OnChanged(function(v) S.spoofer.level.value=v end)
    g:AddToggle("spf_s",  {Text="Spoof Streak", Default=false}):OnChanged(function(v) S.spoofer.streak.enable=v end)
    g:AddSlider("spf_sv", {Text="Streak", Default=9, Min=0, Max=999}):OnChanged(function(v) S.spoofer.streak.value=v end)
    g:AddToggle("spf_r",  {Text="Spoof Rank", Default=false}):OnChanged(function(v) S.spoofer.rank.enable=v end)
    g:AddInput("spf_rv",  {Text="Rank Value", Default="GM"}):OnChanged(function(v) S.spoofer.rank.value=v end)
end

do
    local g = Tabs.Spoofer:AddRightGroupbox("Stats Spoof")
    g:AddToggle("spf_w",  {Text="Spoof Wins", Default=false}):OnChanged(function(v) S.spoofer.wins.enable=v end)
    g:AddSlider("spf_wv", {Text="Wins", Default=9999, Min=0, Max=99999}):OnChanged(function(v) S.spoofer.wins.value=v end)
    g:AddToggle("spf_x",  {Text="Spoof XP", Default=false}):OnChanged(function(v) S.spoofer.xp.enable=v end)
    g:AddSlider("spf_xv", {Text="XP", Default=99999, Min=0, Max=999999}):OnChanged(function(v) S.spoofer.xp.value=v end)
    g:AddToggle("spf_a",  {Text="Spoof Avatar", Default=false}):OnChanged(function(v) S.spoofer.avatar.enable=v end)
    g:AddInput("spf_au",  {Text="User ID", Default="1"}):OnChanged(function(v) S.spoofer.avatar.userid=tonumber(v) or 1 end)
end

-- ============================================================================
-- GUI BUILD — SCRIPTS TAB
-- ============================================================================
do
    local g = Tabs.Scripts:AddLeftGroupbox("Utility Scripts")
    g:AddButton("Infinite Yield", function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
    end)
    g:AddButton("Dex Explorer", function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/dex.lua"))()
    end)
    g:AddButton("Simple Spy", function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/exxtremestuffs/SimpleSpySource/master/SimpleSpy.lua"))()
    end)
    g:AddButton("Remote Spy", function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/exxtremestuffs/SimpleSpySource/master/SimpleSpy.lua"))()
    end)
    g:AddButton("Hydroxide", function()
        local Owl = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/Upbolt/Hydroxide/master/main.lua"))
        Owl()
    end)
end

do
    local g = Tabs.Scripts:AddRightGroupbox("FPS / Performance")
    g:AddButton("FPS Booster", function()
        for _,v in pairs(Workspace:GetDescendants()) do
            if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") then
                v.Enabled=false
            end
            if v:IsA("Texture") or v:IsA("Decal") then v.Transparency=1 end
        end
        pcall(function() settings().Rendering.QualityLevel=1 end)
        Lighting.GlobalShadows = false
        notify("FPS Booster applied", 3)
    end)
    g:AddButton("Remove All Particles", function()
        for _,v in pairs(game:GetDescendants()) do
            if v:IsA("ParticleEmitter") then v:Destroy() end
        end
    end)
    g:AddButton("Destroy Map FX", function()
        for _,v in pairs(Workspace:GetDescendants()) do
            if v:IsA("PointLight") or v:IsA("SpotLight") or v:IsA("SurfaceLight") then v:Destroy() end
        end
    end)
    g:AddButton("Rejoin Server", function()
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end)
    g:AddButton("Server Hop", function()
        local servers = {}
        local ok, res = pcall(function()
            return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?limit=100"))
        end)
        if ok and res and res.data then
            for _,s in ipairs(res.data) do
                if s.playing < s.maxPlayers and s.id ~= game.JobId then servers[#servers+1] = s.id end
            end
            if #servers > 0 then TeleportService:TeleportToPlaceInstance(game.PlaceId, servers[math.random(1,#servers)], LocalPlayer) end
        end
    end)
end

-- ============================================================================
-- GUI BUILD — OPTIMIZATIONS TAB
-- ============================================================================
do
    local g = Tabs.Optim:AddLeftGroupbox("Performance")
    g:AddToggle("op_part",{Text="No Particles", Default=false}):OnChanged(function(v) S.optim.no_particles=v end)
    g:AddToggle("op_shad",{Text="No Shadows", Default=false}):OnChanged(function(v) S.optim.no_shadows=v end)
    g:AddToggle("op_tex", {Text="No Textures", Default=false}):OnChanged(function(v) S.optim.no_textures=v end)
    g:AddToggle("op_low", {Text="Low Quality", Default=false}):OnChanged(function(v) S.optim.low_quality=v end)
    g:AddToggle("op_snd", {Text="Disable Sounds", Default=false}):OnChanged(function(v) S.optim.disable_sounds=v end)
    g:AddToggle("op_mesh",{Text="No Mesh Textures", Default=false}):OnChanged(function(v) S.optim.no_meshes=v end)
    g:AddToggle("op_dfx", {Text="Destroy Map FX", Default=false}):OnChanged(function(v) S.optim.destroy_map_fx=v end)
    g:AddToggle("op_cap_e",{Text="FPS Cap", Default=false}):OnChanged(function(v) S.optim.fps_cap_enable=v end)
    g:AddSlider("op_cap_v",{Text="FPS Cap", Default=240, Min=30, Max=360}):OnChanged(function(v) S.optim.fps_cap=v end)
end

do
    local g = Tabs.Optim:AddRightGroupbox("Culling")
    g:AddToggle("cull_e",{Text="Distance Culling", Default=false}):OnChanged(function(v) S.optim.cull_distant=v end)
    g:AddSlider("cull_d",{Text="Cull Distance", Default=500, Min=100, Max=5000}):OnChanged(function(v) S.optim.cull_distance=v end)
    g:AddToggle("rag_e", {Text="Clean Ragdolls", Default=false}):OnChanged(function(v) S.optim.clean_ragdolls=v end)
end

-- ============================================================================
-- GUI BUILD — CONFIG TAB
-- ============================================================================
do
    local g = Tabs.Config:AddLeftGroupbox("UI Settings")
    g:AddLabel("Menu Toggle"):AddKeyPicker("menu_key", {Default="RightShift", NoUI=false, Text="Menu Key"})
    g:AddLabel("Panic (unload)"):AddKeyPicker("panic_key", {Default="End", Mode="Toggle", Text="Panic"})
    g:AddButton("Unload UE V3", function() getgenv().UEV3_UNLOAD() end)
    g:AddButton("Rejoin Server", function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end)
end

do
    local g = Tabs.Config:AddRightGroupbox("Info")
    g:AddLabel("Unnamed Enhancements V3")
    g:AddLabel("Built by Olivia")
    g:AddLabel("discord.gg/ojailbreaks")
    g:AddLabel(" ")
    g:AddLabel("Features: 200+")
    g:AddLabel("Press End to panic unload")
end

-- ============================================================================
-- TELEPORT KEY WATCHER
-- ============================================================================
bin(task.spawn(function()
    while task.wait(0.1) do
        if Library.Options.tp_key and Library.Options.tp_key:GetState() then
            doTeleport() task.wait(0.4)
        end
    end
end))

-- ============================================================================
-- THEME + SAVE
-- ============================================================================
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
print("[UE V3] Loaded — Built by Olivia — https://discord.gg/ojailbreaks")
