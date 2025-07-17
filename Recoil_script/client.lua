
-- Pokročilý recoil systém pre FiveM s nepresnosťou pri jazde, bez bugov so streľbou
local recoilTable = {
    [`WEAPON_PISTOL`] = 0.3,
    [`WEAPON_COMBATPISTOL`] = 0.35,
    [`WEAPON_SMG`] = 0.4,
    [`WEAPON_ASSAULTRIFLE`] = 0.6,
    [`WEAPON_CARBINERIFLE`] = 0.7,
    [`WEAPON_SNIPERRIFLE`] = 1.2,
    [`WEAPON_PUMPSHOTGUN`] = 0.9
}

-- Zníženie recoil podľa skillu (0.0 až 1.0)
local playerSkill = 0.3 -- 0 = žiadny skill, 1 = profi, znižuje recoil

-- Aplikuj spätný ráz s nepresnosťou
local function applyRecoil(amount)
    local playerPed = PlayerPedId()
    local recoilAmount = amount * (1.0 - playerSkill)
    local pitch = GetGameplayCamRelativePitch()
    local heading = GetGameplayCamRelativeHeading()

    -- Pridaj náhodnú nepresnosť pri jazde
    if IsPedInAnyVehicle(playerPed, false) then
        local veh = GetVehiclePedIsIn(playerPed, false)
        local speed = GetEntitySpeed(veh) * 3.6 -- v km/h
        local inaccuracy = math.min(speed / 60.0, 1.0) -- max 1.0

        -- Rozhodenie kamery (nepresnosť)
        local offsetX = math.random() * 0.3 * inaccuracy - 0.15 * inaccuracy
        local offsetY = math.random() * 0.3 * inaccuracy - 0.15 * inaccuracy
        SetGameplayCamRelativePitch(pitch + recoilAmount + offsetY, 0.6)
        SetGameplayCamRelativeHeading(heading + offsetX)
    else
        SetGameplayCamRelativePitch(pitch + recoilAmount + math.random(-1,1)*0.1, 0.6)
    end

    -- Trasenie kamery
    ShakeGameplayCam("SMALL_EXPLOSION_SHAKE", 0.1)
end

-- Monitoruj streľbu
CreateThread(function()
    while true do
        Wait(0)
        local ped = PlayerPedId()
        if IsPedShooting(ped) then
            local weapon = GetSelectedPedWeapon(ped)
            local recoil = recoilTable[weapon]
            if recoil then
                applyRecoil(recoil)
                Wait(150)
            end
        end
    end
end)

-- Skrytie crosshairu pri mierení
CreateThread(function()
    while true do
        Wait(0)
        if IsPlayerFreeAiming(PlayerId()) then
            HideHudComponentThisFrame(14) -- 14 = zameriavací krížik
        end
    end
end)
