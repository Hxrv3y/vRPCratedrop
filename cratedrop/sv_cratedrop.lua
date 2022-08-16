local Tunnel = module('vrp', 'lib/Tunnel')
local Proxy = module('vrp', 'lib/Proxy')
vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP", "vRP_gunshop")


local Coords = { --Where you want the crate to spawn ALL MESSAGES YOU CAN DELETE AFTER (WOLFHILL)
    vector3(1865.0517578125,294.37481689453,168.91744995117+600),
    vector3(120.09413909912,6918.2944335938,21.275566101074+600),
    vector3(2689.6569824219,1484.3740234375,24.57213973999+600),
    vector3(1544.5241699219,-2103.0690917969,77.245864868164+600),
    vector3(-1788.9268798828,3167.6887207031,32.9303855896+600),
}

local stayTime = 3600 --How long till the airdrop disappears
local spawnTime = 500
local amountOffItems = 600 --How many items are in the crate 
local used = false

local dropMsg = "An airdrop is landing..."
local removeMsg = "The airdrop has vanished..."
local lootedMsg = "Someone looted the airdrop!"

local avaliableItems = { --Where you put you weapons and how frequently you want them to spawn E.G M1911 with its ammo. and put that in there twice and akm once the m1911 will have more chance of spawning
    {"wammo|WEAPON_m1911", "9 mm Bullets", 250, 0.01},
    {"wbody|WEAPON_m1911", "Weapon_m1911 body", 1, 2.5},
    {"wammo|WEAPON_ak74", "7.62 mm Bullets", 250, 0.01},
}

local currentLoot = {}

RegisterServerEvent('openLootCrate', function(playerCoords, boxCoords)
    local source = source
    user_id = vRP.getUserId({source})
    if #(playerCoords - boxCoords) < 2.0 then
        if not used then
            
                used = true
                vRP.giveInventoryItem({user_id, "wbody|" .. 'WEAPON_MOSIN', 1, true})
                vRP.giveInventoryItem({user_id, '7.62 Bullets', 250, true})

                vRP.giveInventoryItem({user_id, "wbody|" .. 'WEAPON_MP40', 1, true})
                vRP.giveInventoryItem({user_id, '9mm Bullets', 250, true})
                vRP.giveInventoryItem({user_id, "body_armor", 3, true})

                TriggerClientEvent("removeCrate", -1)
                TriggerClientEvent('chatMessage', -1, "^1[Wolfhill]: ^0 ", {66, 72, 245}, "The Drop has been Looted.", "alert") --Chat message change if you want
        end
    end
end)

RegisterServerEvent('updateLoot', function(source, item, amount)
    local i = currentLoot[item]
    local j = i[2] - amount
    if (j > 0) then
        currentLoot[item] = {i[1], j, i[3]}
    else
        currentLoot[item] = nil
    end

    if #currentLoot == 0 then
        if not used then
            used = true
            TriggerClientEvent('chatMessage', -1, "^1[Wolfhill]: ^0 ", {66, 72, 245}, lootedMsg, "alert")
        end
    end

            TriggerClientEvent('Eclipse:SendSecondaryInventoryData', source, currentLoot, vRP.computeItemsWeight({currentLoot}), 30)
end) 

Citizen.CreateThread(function()
    while (true) do
        Wait(spawnTime * 1000)

        local num = math.random(1, #Coords)
        local coords = Coords[num]

        for i = 1, amountOffItems do
            local secondNum = math.random(1, #avaliableItems)
            local k = avaliableItems[secondNum]
            currentLoot[k[1]] = {k[2], k[3], k[4]}
        end 

        TriggerClientEvent('crateDrop', -1, coords)
        TriggerClientEvent('chatMessage', -1, "^1[Wolfhill]: ^0", {66, 72, 245}, dropMsg, "alert")
        used = false

        Citizen.SetTimeout(stayTime * 1000, function()
        TriggerClientEvent("removeCrate", -1)
        TriggerClientEvent('chatMessage', -1, "^1[Wolfhill]: ^0 ", {66, 72, 245}, removeMsg, "alert")
        TriggerClientEvent(vrp:PlaySound, -1, "YourSoundNameHere")
        end)

        Wait(stayTime * 1000 + 500)
    end
end)
