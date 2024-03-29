local models = {"p_cargo_chute_s", "sm_prop_smug_crate_s_narc"} --What models the first one is the parachute and the second one is the brief case
local activeCrate = nil
local activeParachute = nil
local crateBlip, radiusBlip = nil
local soundID

local function LoadModel(modelName)
    local modelHash
    if type(modelName) ~= "string" then
        modelHash = modelName
    else
        modelHash = GetHashKey(modelName)
    end
    if IsModelInCdimage(modelHash) then
        if not HasModelLoaded(modelHash) then
            RequestModel(modelHash)
            while not HasModelLoaded(modelHash) do
                Wait(0)
            end
        end
        return modelHash
    else
        return nil
    end
end

RegisterNetEvent("crateDrop")
AddEventHandler("crateDrop", function(c)
    TriggerEvent("removeCrate")
    for k,v in pairs(models) do
        LoadModel(v)
    end
    RequestWeaponAsset("weapon_flare")
    while not HasWeaponAssetLoaded("weapon_flare") do
        Wait(0)
    end

    activeCrate = CreateObject(GetHashKey(models[2]), Coords, false, true, true)

    SetEntityLodDist(activeCrate, 10000)
    ActivatePhysics(activeCrate)
    SetDamping(activeCrate, 2, 0.1)
    SetEntityVelocity(activeCrate, 0.0, 0.0, -0.3)

    activeParachute = CreateObject(GetHashKey(models[1]), Coords, false, true, true)
    SetEntityLodDist(activeParachute, 10000)
    SetEntityVelocity(activeParachute, 0.0, 0.0, -0.3)
    ActivatePhysics(activeCrate)
    AttachEntityToEntity(activeParachute, activeCrate, 0, 0.0, 0.0, 0.1, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
    radiusBlip = AddBlipForRadius(Coords, 200.0)
    SetBlipColour(radiusBlip, 1)
    SetBlipAlpha(radiusBlip, 180)

    crateBlip = AddBlipForEntity(activeCrate)
    SetBlipSprite(crateBlip, 501)
    SetBlipColour(crateBlip, 2)
    

    while GetEntityHeightAboveGround(activeCrate) > 2 do -- when the Z in coords hits ground
        Wait(100)
    end

    soundID = GetSoundId()
    PlaySoundFromEntity(soundID, "Crate_Beeps", activeCrate, "MP_CRATE_DROP_SOUNDS", true, 0) --When the crate is nearby it beeps remove if you want.
    DetachEntity(activeParachute, true, true)
    DeleteEntity(activeParachute)
    ShootSingleBulletBetweenCoords(GetEntityCoords(activeCrate),GetEntityCoords(activeCrate) - vector3(0.0001, 0.0001, 0.0001),0,false,"weapon_flare",0,true,false,-1.0)

    Citizen.CreateThread(function()
        while (true) do
            Citizen.Wait(0)

            local boxCoords = GetEntityCoords(activeCrate)
            local playerCoords = GetEntityCoords(PlayerPedId())

            if #(boxCoords - playerCoords) < 2.0 then
                if IsControlJustPressed(1, 51) then
                    if IsPedInAnyVehicle(GetPlayerPed(-1), false) == false then
                        LoadAnimDict('amb@medic@standing@kneel@base')
                        LoadAnimDict('anim@gangops@facility@servers@bodysearch@')
                        TaskPlayAnim(PlayerPedId(), "amb@medic@standing@kneel@base" ,"base" ,8.0, -8.0, -1, 1, 0, false, false, false )
                        TaskPlayAnim(PlayerPedId(), "anim@gangops@facility@servers@bodysearch@" ,"player_search" ,8.0, -8.0, -1, 48, 0, false, false, false )
                        notify("~r~Looting Crate Drop...")
                        FreezeEntityPosition(PlayerPedId(), true)
                        Wait(10000)
                        FreezeEntityPosition(PlayerPedId(), false)
                        ClearPedTasksImmediately(PlayerPedId())
                        if IsPedInAnyVehicle(GetPlayerPed(-1), false) == false then
                            TriggerServerEvent('openLootCrate', boxCoords, playerCoords)
                            StopSound(soundID)
                            ReleaseSoundId(soundID)
                        else
                            notify("~r~You cannot loot while in a Vehicle!")
                        end
                    else
                        notify("~r~You cannot loot while in a Vehicle!")
                    end
                end
            end
        end
    end)
end)

function LoadAnimDict(dict)
    while (not HasAnimDictLoaded(dict)) do
      RequestAnimDict(dict)
      Citizen.Wait(5)
    end
end

function notify(string)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(string)
    DrawNotification(true, false)
end



RegisterNetEvent("removeCrate")
AddEventHandler("removeCrate", function()
    if activeCrate then
        if DoesEntityExist(activeCrate) then
            DeleteEntity(activeCrate)
        end
        if DoesEntityExist(activeParachute) then
            DeleteEntity(activeParachute)
        end
        SetTimeout(300000,function()
            RemoveBlip(radiusBlip)
            RemoveBlip(crateBlip)
        end)
        StopSound(soundID)
        ReleaseSoundId(soundID)
    end
end)