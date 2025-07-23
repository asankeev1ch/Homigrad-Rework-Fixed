--эээ ну да?
util.AddNetworkString("SyncRound")
util.AddNetworkString("EndRound")

RTV_ROUNDS = 15
CURRENT_ROUND = (CURRENT_ROUND or 0)
ROUNDS_ENABLED = true
RTV_ACTIVE = (RTV_ACTIVE or false)
RTV_ENABLED = true

hg.LastRoundTime = hg.LastRoundTime or 0

function StartRound()
    if #player.GetAll() == 1 then
        RunConsoleCommand("bot")
    end

    if RTV_ACTIVE then
        return
    end

    if !RTV_ENABLED then
        CURRENT_ROUND = CURRENT_ROUND - 1
    end

    ROUND_ACTIVE = true

    SetGlobalBool("DefaultMove",false)
    SetGlobalBool("NoGib",false)

    game.CleanUpMap(false)

    CURRENT_ROUND = CURRENT_ROUND + 1
    if CURRENT_ROUND >= RTV_ROUNDS and !GetGlobalBool("NoRTV") then
        SolidMapVote.start()
        RTV_ACTIVE = true

        //hg.rtv_open()

        timer.Simple(0.25,function()
            for i,ply in pairs(player.GetAll()) do
                if ply:Team() == 1002 then
                    continue 
                end
                if ply:Alive() then ply:KillSilent() end
            end
        end)
        ROUND_ACTIVE = false
    end

    local CanBeStarted = {}

    for _, lvl in ipairs(ROUND_LIST) do
        if TableRound(lvl).CantRandom then
            continue 
        end
        if TableRound(lvl).CanStart and TableRound(lvl).CanStart() then
            table.insert(CanBeStarted,lvl)
        elseif !TableRound(lvl).CanStart then
            table.insert(CanBeStarted,lvl)
        end
    end

    ROUND_NAME = (ROUND_NEXT or table.Random(CanBeStarted))
    if !GetGlobalBool("NoLevelChange",false) then
        ROUND_NEXT = (math.random(0,20) < 7 and table.Random(CanBeStarted) or "hmcd")
    end

    if string.match(game.GetMap(),"jb_") then
        ROUND_NEXT = "jb"
        ROUND_NAME = "jb"
    end

    if string.match(game.GetMap(),"d1_") or string.match(game.GetMap(),"d2_") or string.match(game.GetMap(),"d3_") then
        ROUND_NEXT = "coop"
        ROUND_NAME = "coop"
    end

    if string.match(game.GetMap(),"deathrun_") then
        ROUND_NEXT = "dr"
        ROUND_NAME = "dr"
    end

    RunConsoleCommand("hostname","Homigrad Rework | Open-Alpha")

    ROUND_ENDED = false

    for _, ply in ipairs(player.GetAll()) do
        if ply:Team() == 1002 then
            continue 
        end
        ply:KillSilent()
        ply:Spawn()
        ply:SetMaxHealth(100)
        ply:SetHealth(100)
        ply.AppearanceOverride = false
    end

    if TableRound().StartRound then
        TableRound().StartRound()
    end

    if TableRound().StartRoundSV then
        TableRound().StartRoundSV()
    end
    
    hg.LastRoundTime = CurTime()

    net.Start("SyncRound")
    net.WriteString(ROUND_NAME)
    net.WriteString(ROUND_NEXT)
    net.Broadcast()

    //DiscordLog("Round started - "..(TableRound().coolname or TableRound().name), "Info")
end

function EndRound(team_wins)
    local TeamName = TableRound().Teams[team_wins]["Name"]
    local TeamColor = TableRound().Teams[team_wins]["Color"]

    net.Start("EndRound")
    net.WriteColor(TeamColor)
    net.WriteString("level_wins")
    net.WriteString(TeamName)
    net.Broadcast()
end

--PrintTable(TableRound())

local Replaces = {
    ["weapon_pistol"] = "weapon_usp_match",
    ["weapon_357"] = "weapon_329pd",
    ["weapon_ar2"] = "weapon_hg_ar2",
    ["weapon_smg1"] = "weapon_hg_smg1",
    ["weapon_shotgun"] = "weapon_spas12",
    ["weapon_crowbar"] = "weapon_crowbar_hg",
}

local ammo = {
    ["AR2"] = "7.62x39 mm",
    ["Pistol"] = "9x19 mm Parabellum",
    ["357"] = ".44 Magnum"
}

hook.Add("Player Think","ReplaceAmmo",function(ply)
    for name, repl in pairs(ammo) do
        if ply:GetAmmoCount(name) > 0 then
            local count = ply:GetAmmoCount(name)
            ply:GiveAmmo(count,repl,true)
            ply:RemoveAmmo(count,name)
        end
    end
end)

hook.Add("Think","Ent_Replace",function()
    for _, ent in ipairs(ents.GetAll()) do
        if isentity(ent) and IsValid(ent) and ent.GetClass and Replaces[ent:GetClass()] and (!IsValid(ent:GetOwner()) or ent:GetOwner() == NULL or ent:GetOwner():IsPlayer()) then
            local nigg = ents.Create(Replaces[ent:GetClass()])
            nigg:SetPos(ent:GetPos())
            if ent:GetOwner():IsPlayer() then
                nigg.IsSpawned = false
            else
                nigg.IsSpawned = true
            end
            nigg:SetAngles(ent:GetAngles())
            nigg:Spawn()
            ent:Remove()
        end
    end
end)

hook.Add("PostCleanupMap","TableRound_Hook",function()
    timer.Simple(0.3,function()
        if TableRound and TableRound().PostCleanUpHook then
            TableRound().PostCleanUpHook()
        end
    end)
end)

hook.Add("Think","Round-Think",function()
    local nonspect = {}
    for _, ply in ipairs(player.GetAll()) do
        if ply:Team() != 1002 then
            table.insert(nonspect,ply)
        end
    end
    /*if #player.GetAll() > 2 then
        for _, ply in ipairs(player.GetAll()) do
            if ply:IsBot() then
                ply:Kick()
            end
        end
    end*/
    if #nonspect < 2 then
        return
    end
    if ROUND_ENDED and ROUND_ACTIVE then
        if ROUND_ENDSIN < CurTime() then
            ROUND_ACTIVE = false
        end
    end

    if #player.GetAll() == 0 then
        ROUND_ACTIVE = false
        return
    end

    if not ROUND_ACTIVE then
        StartRound()
    else
        if TableRound and TableRound().RoundThink then
            TableRound():RoundThink()
        end
    end
end)