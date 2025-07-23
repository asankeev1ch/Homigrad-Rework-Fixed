bahmut = bahmut or {}

function bahmut.SpawnBlue(ply)
    local SpawnList = ReadDataMap("bahmut_blue")

    local weps_pri = {"weapon_ak74","weapon_m4a1","weapon_mp7","weapon_xm1014","weapon_scar"}
    local weps_sec = {"weapon_deagle_a","weapon_deagle_b","weapon_glockp80","weapon_fiveseven"}
    local weps_oth = {"weapon_kabar","weapon_bandage","weapon_medkit_hg","weapon_f1"}

    ply:SetTeam(1)

    ply:Spawn()

    ply.AppearanceOverride = true

    ply:SetPos(((table.Random(SpawnList) != nil and table.Random(SpawnList)[1] != nil) and table.Random(SpawnList)[1] or ply:GetPos()))

    local wep_primary = ply:Give(table.Random(weps_pri))
    local wep_secondary = ply:Give(table.Random(weps_sec))
    for _, wep in pairs(weps_oth) do
        ply:Give(wep)
    end

    wep_primary:SetClip1(wep_primary:GetMaxClip1())
    wep_secondary:SetClip1(wep_secondary:GetMaxClip1())

    ply:GiveAmmo(wep_primary:GetMaxClip1() * math.random(8,16), wep_primary:GetPrimaryAmmoType(), true)
    ply:GiveAmmo(wep_secondary:GetMaxClip1() * math.random(2,4), wep_secondary:GetPrimaryAmmoType(), true)

    timer.Simple(0,function()
        ply:SetPlayerColor(Color(0,0,255):ToVector())
        ply:SetSubMaterial()
    end)
end

function bahmut.SpawnRed(ply)
    local SpawnList = ReadDataMap("bahmut_red")

    local weps_pri = {"weapon_ak74","weapon_m4a1","weapon_mp7","weapon_xm1014","weapon_scar"}
    local weps_sec = {"weapon_deagle_a","weapon_deagle_b","weapon_glockp80","weapon_fiveseven"}
    local weps_oth = {"weapon_kabar","weapon_bandage","weapon_medkit_hg","weapon_rgd5"}

    ply:SetTeam(2)

    ply:Spawn()

    ply.AppearanceOverride = true

    ply:SetPos(((table.Random(SpawnList) != nil and table.Random(SpawnList)[1] != nil) and table.Random(SpawnList)[1] or ply:GetPos()))

    local wep_primary = ply:Give(table.Random(weps_pri))
    local wep_secondary = ply:Give(table.Random(weps_sec))
    for _, wep in pairs(weps_oth) do
        ply:Give(wep)
    end

    wep_primary:SetClip1(wep_primary:GetMaxClip1())
    wep_secondary:SetClip1(wep_secondary:GetMaxClip1())

    ply:GiveAmmo(wep_primary:GetMaxClip1() * math.random(8,16), wep_primary:GetPrimaryAmmoType(), true)
    ply:GiveAmmo(wep_secondary:GetMaxClip1() * math.random(2,4), wep_secondary:GetPrimaryAmmoType(), true)

    timer.Simple(0,function()
        ply:SetPlayerColor(Color(255,0,0):ToVector())
        ply:SetSubMaterial()
    end)
end

function bahmut.StartRoundSV()
    team.DirectTeams(1,2)

    local blus = team.GetPlayers(1)
    local reds = team.GetPlayers(2)

    for _, ply in ipairs(reds) do
        bahmut.SpawnRed(ply)
    end

    for _, ply in ipairs(blus) do
        bahmut.SpawnBlue(ply)
    end
    
    game.CleanUpMap(false)
end

function bahmut.RoundThink()
    local T_ALIVE = team.GetCountLive(team.GetPlayers(2))
    local CT_ALIVE = team.GetCountLive(team.GetPlayers(1))

    if T_ALIVE == 0 and !ROUND_ENDED then
        ROUND_ENDED = true
        ROUND_ENDSIN = CurTime() + 8

        EndRound(1)
    end

    if CT_ALIVE == 0 and !ROUND_ENDED then
        ROUND_ENDED = true
        ROUND_ENDSIN = CurTime() + 8

        EndRound(2)
    end
end

function bahmut.CanStart(forced)
    local world = game.GetWorld()
    
    local min, max = world:GetModelBounds()
    local size = max - min

    local size_final = size:Length()

    if size_final < 10000 then
            return false
    else
        return true 
    end
end

function bahmut.LootSpawn()
    return false
end