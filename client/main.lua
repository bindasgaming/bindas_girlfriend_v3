local gfPed = nil
local gfSpawned = false
local gfBlip = nil
local gfModel = "s_f_y_hooker_01"
local spawnCoords = vector3(126.76, -223.39, 54.56) -- nearest clothing store
local hasGreeted = false

-- VGF spawn & interaction
RegisterCommand("gf", function()
    if gfSpawned then
        Notify("❤️ তোমার girlfriend তো আগেই এসেছে!")
        return
    end

    -- Load model
    RequestModel(gfModel)
    while not HasModelLoaded(gfModel) do Wait(100) end

    gfPed = CreatePed(4, gfModel, spawnCoords.x, spawnCoords.y, spawnCoords.z - 1.0, 0.0, true, true)
    SetEntityAsMissionEntity(gfPed, true, true)
    SetPedFleeAttributes(gfPed, 0, 0)
    SetBlockingOfNonTemporaryEvents(gfPed, true)
    SetPedCanRagdoll(gfPed, true)
    SetPedDefaultComponentVariation(gfPed)

    -- Blip
    gfBlip = AddBlipForEntity(gfPed)
    SetBlipSprite(gfBlip, 280) -- heart icon
    SetBlipColour(gfBlip, 27)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("❤️ Your GF")
    EndTextCommandSetBlipName(gfBlip)

    gfSpawned = true
    hasGreeted = false
    Notify("❤️ তোমার GF তোমার জন্য অপেক্ষা করছে।")

    WaitForPlayerProximity()
end)

-- Hug when near
function WaitForPlayerProximity()
    CreateThread(function()
        while gfSpawned and not hasGreeted do
            local player = PlayerPedId()
            local playerCoords = GetEntityCoords(player)
            local gfCoords = GetEntityCoords(gfPed)

            if #(playerCoords - gfCoords) < 2.5 then
                hasGreeted = true
                PlayAnim(gfPed, "mp_ped_interaction", "kisses_guy_a")
                PlayVoice(gfPed, "GENERIC_HI")
                Notify("💞 GF: হাই ডার্লিং!")
                Wait(3000)
                OpenVgfMenu()
            end
            Wait(500)
        end
    end)
end

-- Menu system
function OpenVgfMenu()
    local menu = {
        {
            header = "❤️ Virtual Girlfriend Menu",
            isMenuHeader = true
        },
        {
            header = "👣 Follow Me",
            params = { event = "vgf:follow" }
        },
        {
            header = "🛑 Stop Following",
            params = { event = "vgf:unfollow" }
        },
        {
            header = "🚗 Get In My Car",
            params = { event = "vgf:carin" }
        },
        {
            header = "🚪 Get Out My Car",
            params = { event = "vgf:carout" }
        },
        {
            header = "🏠 Go Home (Kiss Goodbye)",
            params = { event = "vgf:gohome" }
        },
    }

    TriggerEvent("qb-menu:client:openMenu", menu)
end

-- Anim/Task Events
RegisterNetEvent("vgf:follow", function()
    local ped = PlayerPedId()
    local group = GetPedGroupIndex(ped)
    SetPedAsGroupMember(gfPed, group)
    SetPedNeverLeavesGroup(gfPed, true)
    Notify("GF: তোমার পেছনে পেছনে আসছি!")
    PlayVoice(gfPed, "GENERIC_HOWS_IT_GOING")
end)

RegisterNetEvent("vgf:unfollow", function()
    RemovePedFromGroup(gfPed)
    ClearPedTasks(gfPed)
    Notify("GF: আচ্ছা আমি এখানেই থাকছি।")
    PlayVoice(gfPed, "GENERIC_OK")
end)

RegisterNetEvent("vgf:carin", function()
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    if vehicle and DoesEntityExist(vehicle) then
        TaskEnterVehicle(gfPed, vehicle, 10000, 1, 1.0, 1, 0)
        Notify("GF গাড়িতে উঠছে...")
    end
end)

RegisterNetEvent("vgf:carout", function()
    TaskLeaveVehicle(gfPed, GetVehiclePedIsIn(gfPed, false), 0)
    Notify("GF গাড়ি থেকে নেমেছে।")
end)

RegisterNetEvent("vgf:gohome", function()
    PlayAnim(gfPed, "anim@mp_player_intcelebrationfemale@blow_kiss", "blow_kiss")
    PlayVoice(gfPed, "GENERIC_BYE")
    Notify("GF: বাই হানি! দেখা হবে আবার!")
    Wait(3000)
    DeleteEntity(gfPed)
    RemoveBlip(gfBlip)
    gfSpawned = false
end)

-- Utility Functions
function Notify(msg)
    TriggerEvent('chat:addMessage', { args = {"GF", msg} })
end

function PlayAnim(ped, dict, anim)
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do Wait(100) end
    TaskPlayAnim(ped, dict, anim, 8.0, -8, 3000, 49, 0, false, false, false)
end

function PlayVoice(ped, speech)
    PlayAmbientSpeech1(ped, speech, "SPEECH_PARAMS_FORCE_NORMAL")
end