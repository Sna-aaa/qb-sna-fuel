local QBCore = exports['qb-core']:GetCoreObject()
local CurrentWeaponData

local CurrentPumpProp
local CurrentPumpObj
local CurrentPump
local CurrentRope
local CurrentVehicle
local CurrentBone
local CurrentCapPos
local CurrentCost
local CurrentSource
local IsMounted
local IsFueling
local VehicleOutOfFuel

function GetFuel(vehicle)
    local vehname = GetDisplayNameFromVehicleModel(GetEntityModel(vehicle)):lower()
    local fuel = DecorGetFloat(vehicle, Config.FuelDecor)
    if Config.TankSizes[vehname] then
        return fuel / Config.TankSizes[vehname] * 100.0
    else
        return fuel / Config.DefaultTankSize * 100.0
    end
end
exports('GetFuel', GetFuel)

function ApplyFuel(vehicle, fuel)
    local vehname = GetDisplayNameFromVehicleModel(GetEntityModel(vehicle)):lower()
    if Config.TankSizes[vehname] then
        DecorSetFloat(vehicle, Config.FuelDecor, fuel / 100.0 * Config.TankSizes[vehname])
    else
        DecorSetFloat(vehicle, Config.FuelDecor, fuel / 100.0 * Config.DefaultTankSize)
    end
end
exports('ApplyFuel', ApplyFuel)

function SetFuel(vehicle, fuel)
    if type(fuel) == 'number' and fuel >= 0 and fuel <= 100 then
        local vehname = GetDisplayNameFromVehicleModel(GetEntityModel(vehicle)):lower()
        if Config.ElectricVehicles[vehname] then
            QBCore.Functions.TriggerCallback('qb-fuel:server:GetTimeInGarage', function(time)
                if time then
                    local toadd = 100.0 / (Config.TimeForCompleteCharge * 60) * time
                    if fuel + toadd > 100 then
                        fuel = 100
                    else
                        fuel = fuel + toadd
                    end
                    ApplyFuel(vehicle, fuel)
                end
            end, GetVehicleNumberPlateText(vehicle))
        else
            ApplyFuel(vehicle, fuel)
        end
    end
end
exports('SetFuel', SetFuel)

CreateThread(function() -- Set target for pumps and blips
    local Pumps = {}

    for v, w in pairs(Config.PumpModels) do
        table.insert(Pumps, v)
    end
    Wait(100)
    exports['qb-target']:AddTargetModel(Pumps, {
        options = {{
            event = "qb-fuel:PickupPump",
            icon = "fas fa-gas-pump",
            label = Lang:t("info.pickup_pump"),
            entity = entity
        }, {
            event = "qb-fuel:BuyJerrican",
            icon = "fas fa-gas-can",
            label = Lang:t("info.buy_jerrican"),
            entity = entity
        }},
        job = {"all"},
        distance = Config.MaxDistance
    })
    for _, gasStationCoords in pairs(Config.GasStations) do
        local blip = AddBlipForCoord(gasStationCoords.x, gasStationCoords.y, gasStationCoords.z)

        SetBlipSprite(blip, 361)
        SetBlipScale(blip, 0.6)
        SetBlipColour(blip, 4)
        SetBlipDisplay(blip, 4)
        SetBlipAsShortRange(blip, true)

        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(Lang:t("info.blip_fuel"))
        EndTextCommandSetBlipName(blip)
    end
    for _, elecStationCoords in pairs(Config.SuperchargerStations) do
        local blip = AddBlipForCoord(elecStationCoords.x, elecStationCoords.y, elecStationCoords.z)

        SetBlipSprite(blip, 354)
        SetBlipScale(blip, 0.6)
        SetBlipColour(blip, 4)
        SetBlipDisplay(blip, 4)
        SetBlipAsShortRange(blip, true)

        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(Lang:t("info.blip_electric"))
        EndTextCommandSetBlipName(blip)
    end
end)

local function Round(num, numDecimalPlaces)
    local mult = 10 ^ (numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

RegisterNetEvent("qb-fuel:BuyJerrican", function(data)
    local ped = PlayerPedId()
    local currentCash = QBCore.Functions.GetPlayerData().money['cash']

    if not HasPedGotWeapon(ped, 883325847) then
        if currentCash >= Config.JerryCanCost then
            TriggerServerEvent('qb-fuel:server:Pay', Config.JerryCanCost)
            QBCore.Functions.Notify(Lang:t("message.jerrican_bought"), "success")
            TriggerServerEvent('qb-fuel:server:GiveJerrican')
        end
    else
        local refillCost = Round(Config.JerryCanCapacity * Config.LiterPrice * (1 - GetAmmoInPedWeapon(ped, 883325847) / 4500))
        if refillCost > 0 then
            if currentCash >= refillCost then
                TriggerServerEvent('qb-fuel:server:Pay', refillCost)
                QBCore.Functions.Notify(Lang:t("message.jerrican_refilled"), "success")
                SetPedAmmo(ped, 883325847, 4500)
                TriggerServerEvent("weapons:server:UpdateWeaponAmmo", CurrentWeaponData, tonumber(4500))
            else
                QBCore.Functions.Notify(Lang:t("message.no_money"), "error")
            end
        else
            QBCore.Functions.Notify(Lang:t("message.jerrican_full"), "error")
        end
    end
end)

local function DetectPetrolCap(electric)
    -- Detect nearby vehicle
    CurrentVehicle = GetVehiclePedIsIn(PlayerPedId(), true)

    local vehname = GetDisplayNameFromVehicleModel(GetEntityModel(CurrentVehicle)):lower()
    if Config.ElectricVehicles[vehname] == electric then
        local offset
        if Config.FuelCaps[vehname] then
            offset = Config.FuelCaps[vehname]
        else
            offset = {0.0, 0.0, 0.65}
        end

        -- Detect petrolcap location
        local tanks = {"petrolcap", "wheel_lr", "petroltank", "petroltank_l", "engine", "engine_l"}
    
        for k, v in pairs(tanks) do
            CurrentBone = GetEntityBoneIndexByName(CurrentVehicle, v)
            if CurrentBone ~= -1 then
                CurrentCapPos = GetWorldPositionOfEntityBone(CurrentVehicle, CurrentBone)
                local currentoffset = GetOffsetFromEntityGivenWorldCoords(CurrentVehicle, CurrentCapPos.x, CurrentCapPos.y, CurrentCapPos.z)
                currentoffset = vector3(currentoffset.x + offset[1], currentoffset.y + offset[2], currentoffset.z + offset[3])
                CurrentCapPos = GetOffsetFromEntityInWorldCoords(CurrentVehicle, currentoffset.x, currentoffset.y, currentoffset.z)
                break
            end
        end    
    end
end

RegisterNetEvent("qb-fuel:PickupPump", function(data)
    if CurrentPump then
        TriggerServerEvent('qb-fuel:server:DetachRope')
        exports['qb-core']:KeyPressed()
        Wait(7)
        -- exports['qb-core']:HideText()
    else
        local playerPed = PlayerPedId()

        RequestModel('prop_cs_fuel_nozle')
        while not HasModelLoaded('prop_cs_fuel_nozle') do
            Wait(1)
        end
        CurrentPumpProp = CreateObject('prop_cs_fuel_nozle', 1.0, 1.0, 1.0, true, true, false)
        CurrentPump = data.entity
    
        local bone = GetPedBoneIndex(playerPed, 60309)
    
        AttachEntityToEntity(CurrentPumpProp, playerPed, bone, 0.0549, 0.049, 0.0, -50.0, -90.0, -50.0, true, true, false, false, 0, true)
    
        RopeLoadTextures()
        while not RopeAreTexturesLoaded() do
            Wait(1)
        end

        print(GetEntityModel(CurrentPump))

        local pumpcoords = GetEntityCoords(CurrentPump)
        local netIdProp = ObjToNet(CurrentPumpProp)     -- NetworkGetNetworkIdFromEntity(CurrentPumpProp)
        SetNetworkIdExistsOnAllMachines(netIdProp, true)
        NetworkSetNetworkIdDynamic(netIdProp, true)
        SetNetworkIdCanMigrate(netIdProp, false)
        TriggerServerEvent('qb-fuel:server:AttachRope', netIdProp, pumpcoords, GetEntityModel(CurrentPump), playerPed)
    
        IsMounted = false
        DetectPetrolCap(Config.PumpModels[GetEntityModel(CurrentPump)].electric)
        exports['qb-core']:DrawText(Lang:t("info.info_pump"), Config.DrawTextLocation)    
    end
end)

RegisterNetEvent("qb-fuel:RefuelVehicle", function(ped, vehicle)
    local startingfuel = DecorGetFloat(vehicle, Config.FuelDecor)
    local startingCash = QBCore.Functions.GetPlayerData().money['cash']
    local vehname = GetDisplayNameFromVehicleModel(GetEntityModel(vehicle)):lower()
    local tank
    if Config.TankSizes[vehname] then
        tank = Config.TankSizes[vehname]
    else
        tank = Config.DefaultTankSize
    end
    print("Refueling")

    while IsFueling or CurrentCost ~= 0 do
        Wait(500)
        local currentFuel = DecorGetFloat(vehicle, Config.FuelDecor)
        local fuelToAdd
        if not Config.PumpModels[GetEntityModel(CurrentPump)].electric then
            if currentFuel + 1.0 > tank then
                fuelToAdd = tank - currentFuel
            else
                fuelToAdd = 1.0
            end
        else
            fuelToAdd = ((tank - currentFuel) / (tank - (tank * 0.8)))^(1.0/6.0)
            if currentFuel + fuelToAdd > tank then
                fuelToAdd = tank - currentFuel
            end
        end
        currentFuel = currentFuel + fuelToAdd
        if currentFuel <= tank then
            if CurrentPump == "can" then
                local fuelToRemove = 4500 / Config.JerryCanCapacity * fuelToAdd
                if GetAmmoInPedWeapon(ped, 883325847) - fuelToRemove >= 0 then
                    local ammo = math.floor(GetAmmoInPedWeapon(ped, 883325847) - fuelToRemove)
                    SetPedAmmo(ped, 883325847, ammo)
                    TriggerServerEvent("weapons:server:UpdateWeaponAmmo", CurrentWeaponData, ammo)
                else
                    IsFueling = false
                end
                exports['qb-core']:DrawText(Lang:t("info.jerrican_refilling", { value = Round(currentFuel - startingfuel, 1)}), Config.DrawTextLocation)
            else
                if not Config.PumpModels[GetEntityModel(CurrentPump)].electric then
                    CurrentCost = CurrentCost + (Config.LiterPrice * fuelToAdd)
                    exports['qb-core']:DrawText(Lang:t("info.refilling", { value = Round(currentFuel - startingfuel, 1), value2 = math.floor(CurrentCost) }), Config.DrawTextLocation)
                else
                    CurrentCost = CurrentCost + (Config.KwPrice * fuelToAdd)
                    exports['qb-core']:DrawText(Lang:t("info.recharging", { value = Round(currentFuel - startingfuel, 1), value2 = math.floor(CurrentCost) }), Config.DrawTextLocation)
                end
                if CurrentCost >= startingCash then
                    print("No more cash")
                    IsFueling = false
                end
            end
            if currentFuel == tank then
                print("Tank full")
                DecorSetFloat(vehicle, Config.FuelDecor, currentFuel + 0.0)
                IsFueling = false
            end
        end
        if IsFueling then
            DecorSetFloat(vehicle, Config.FuelDecor, currentFuel + 0.0)
        else
            if CurrentCost ~= 0 then
                print("Payment", CurrentCost)
                TriggerServerEvent('qb-fuel:server:Pay', math.floor(CurrentCost))
                CurrentCost = 0
            end
        end
    end
end)

local function LoadAnimDict(dict)
	if not HasAnimDictLoaded(dict) then
		RequestAnimDict(dict)

		while not HasAnimDictLoaded(dict) do
			Citizen.Wait(1)
		end
	end
end

CreateThread(function() -- Check key presses
    while true do
        local sleep = 1000
        if CurrentPump then
            sleep = 0
            if IsControlPressed(0, Config.ActionKey) and CurrentCapPos then
                local playerPed = PlayerPedId()
                if #(GetEntityCoords(playerPed) - CurrentCapPos) < 3.0 then -- Mount/Dismount pump
                    if not IsMounted then
                        -- Mount 
                        if CurrentPump ~= "can" then
                            local offset = GetOffsetFromEntityGivenWorldCoords(CurrentVehicle, CurrentCapPos.x, CurrentCapPos.y, CurrentCapPos.z)
                            DetachEntity(CurrentPumpProp, true, true)
                            AttachEntityToEntity(CurrentPumpProp, CurrentVehicle, nil, offset.x, offset.y, offset.z, -50.0, 0.0, -90.0, true, true, false, false, 0, true)
                        else
                            TaskTurnPedToFaceCoord(playerPed, CurrentCapPos, -1)
                            LoadAnimDict("weapons@misc@jerrycan@")
                            TaskPlayAnim(playerPed, "weapons@misc@jerrycan@", "fire", 2.0, 8.0, -1, 50, 0, 0, 0, 0)
                        end
                        IsMounted = true
                        IsFueling = true
                        CurrentCost = 0
                        TriggerEvent("qb-fuel:RefuelVehicle", playerPed, CurrentVehicle)
                    else
                        -- Dismount
                        if CurrentPump ~= "can" then
                            DetachEntity(CurrentPumpProp, true, true)
                            local bone = GetPedBoneIndex(playerPed, 28422)
                            AttachEntityToEntity(CurrentPumpProp, playerPed, bone, 0.0549, 0.049, 0.0, -50.0, -90.0, -50.0, true, true, false, false, 0, true)
                        else
                            ClearPedTasks(playerPed)
                            RemoveAnimDict("weapons@misc@jerrycan@")                            
                            exports['qb-core']:KeyPressed()
                            Wait(7)
                        end
                        IsMounted = false
                        IsFueling = false
                        if CurrentPump ~= "can" then
                            exports['qb-core']:DrawText(Lang:t("info.info_pump"), Config.DrawTextLocation)
                        end
                    end
                end
                Wait(1000)
            end
        end
        Wait(sleep)
    end
end)

local function DrawText3Ds(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)

    if onScreen then
        SetTextScale(0.35, 0.35)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 215)
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x, _y)
    end
end

CreateThread(function() -- Frame thread
    while true do
        local sleep = 1000
        if VehicleOutOfFuel then
            sleep = 0
            SetVehicleCheatPowerIncrease(VehicleOutOfFuel, 0.01)
        end
        if CurrentCapPos then
            sleep = 0
            if not IsMounted then
                if Config.Texts3d then
                    DrawText3Ds(CurrentCapPos.x, CurrentCapPos.y, CurrentCapPos.z, Lang:t("info.mount_pump"))                    
                end
            else
                if Config.Texts3d then
                    DrawText3Ds(CurrentCapPos.x, CurrentCapPos.y, CurrentCapPos.z, Lang:t("info.dismount_pump"))
                end
                if CurrentPump == "can" then
                    for _, controlIndex in pairs(Config.DisableKeys) do
                        DisableControlAction(0, controlIndex)
                    end            
                end
            end
        end
        Wait(sleep)
    end
end)

local function ManageFuelUsage(vehicle)
    if not DecorExistOn(vehicle, Config.FuelDecor) then
        ApplyFuel(vehicle, math.random(200, 800) / 10)
    end

    local fuel = DecorGetFloat(vehicle, Config.FuelDecor)
    local vehname = GetDisplayNameFromVehicleModel(GetEntityModel(vehicle)):lower()
    if not Config.Blacklist[vehname] then
        if IsVehicleEngineOn(vehicle) then
            if Config.ElectricVehicles[vehname] then
                local tank
                if Config.TankSizes[vehname] then
                    tank = Config.TankSizes[vehname]
                else
                    tank = Config.DefaultTankSize
                end
                local charge = ((tank - fuel) / (tank - (tank * 0.8)))^(1.0/4.0)
                if charge == 0 then
                    charge = 0.5
                end
                fuel = fuel - charge * Config.KwUsage[Round(GetVehicleCurrentRpm(vehicle), 1)] * (Config.ClassFuelUsage[GetVehicleClass(vehicle)] or 1.0) * (Config.ModelFuelUsage[GetDisplayNameFromVehicleModel(GetEntityModel(vehicle)):lower()] or 1.0) / 20.0
            else
                fuel = fuel - Config.FuelUsage[Round(GetVehicleCurrentRpm(vehicle), 1)] * (Config.ClassFuelUsage[GetVehicleClass(vehicle)] or 1.0) * (Config.ModelFuelUsage[GetDisplayNameFromVehicleModel(GetEntityModel(vehicle)):lower()] or 1.0) / 20.0
            end
            if fuel > 0 then
                DecorSetFloat(vehicle, Config.FuelDecor, fuel)
                VehicleOutOfFuel = nil
                SetVehicleFuelLevel(vehicle, 50.0)
            else
                DecorSetFloat(vehicle, Config.FuelDecor, 0.0)
                VehicleOutOfFuel = vehicle
                SetVehicleFuelLevel(vehicle, 0.0)
                SetVehicleEngineOn(vehicle, false, true, true)
            end
        else
            if fuel > 0 then
                SetVehicleFuelLevel(vehicle, 50.0)
            end
        end            
    end
end

CreateThread(function()
    local inBlacklisted
    DecorRegister(Config.FuelDecor, 1)

    while true do
        Wait(1000)

        local ped = PlayerPedId()
        if IsPedInAnyVehicle(ped, false) then
            local vehicle = GetVehiclePedIsIn(ped, false)

            if GetPedInVehicleSeat(vehicle, -1) == ped then
                ManageFuelUsage(vehicle)
            end
        else
            if GetSelectedPedWeapon(ped) == 883325847 then
                if GetAmmoInPedWeapon(ped, 883325847) > 100 and not CurrentCapPos then
                    CurrentPump = "can"
                    DetectPetrolCap(nil)
                end
            else
                if CurrentPump == "can" then
                    CurrentPump = nil
                    CurrentCapPos = nil
                    CurrentCost = 0
                end
            end
        end
        if CurrentPump and not IsMounted and CurrentPump ~= "can" then       --Check max distance
            if #(GetEntityCoords(ped) - GetEntityCoords(CurrentPump)) >= Config.RopeMaxLength then
                TriggerEvent('qb-fuel:PickupPump')
                QBCore.Functions.Notify(Lang:t("message.to_far_away"), "error")
            end
        end
        if IsMounted and #(GetEntityCoords(CurrentVehicle) - GetEntityCoords(CurrentPump)) >= Config.RopeMaxLength then
            TriggerEvent('qb-fuel:PickupPump')
            QBCore.Functions.Notify(Lang:t("message.to_far_away"), "error")
        end
    end
end)

AddEventHandler('weapons:client:SetCurrentWeapon', function(data, bool)
    if bool ~= false then
        CurrentWeaponData = data
    else
        CurrentWeaponData = {}
    end
end)

AddEventHandler("onResourceStop", function(resource)
    if resource == GetCurrentResourceName() then
        if CurrentPumpProp then
            DetachEntity(CurrentPumpProp, false, false)
            DeleteEntity(CurrentPumpProp)
        end
        exports['qb-core']:HideText()
    end
end)

RegisterNetEvent("qb-fuel:SetFuel", function(fuel)
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)
    if GetPedInVehicleSeat(vehicle, -1) == ped then
        ApplyFuel(vehicle, fuel)
    else
        QBCore.Functions.Notify(Lang:t("message.must_be_driver"), "primary")
    end
end)

RegisterNetEvent("qb-fuel:client:AttachRope", function(netIdProp, posPump, model, src)
    CurrentSource = src
    local object = GetHashKey('bkr_prop_bkr_cash_roll_01')
    RequestModel(object)
    while not HasModelLoaded(object) do
        Wait(1)
    end
    CurrentPumpObj = CreateObject(object, posPump.x, posPump.y, posPump.z, true, true, false)
    SetEntityRecordsCollisions(CurrentPumpObj, false)
    SetEntityLoadCollisionFlag(CurrentPumpObj, false)
    local timeout = 0
    local IdProp
    while true do
        if timeout > 50 then
            break
        end
        if NetworkDoesEntityExistWithNetworkId(netIdProp) then
            IdProp = NetworkGetEntityFromNetworkId(netIdProp)
            break                            
        else
            Wait(100)
            timeout = timeout + 1
        end
    end

    local pumppropcoords = GetOffsetFromEntityInWorldCoords(IdProp, 0.0, -0.019, -0.1749)

    CurrentRope = AddRope(posPump.x, posPump.y, posPump.z + Config.PumpModels[model].z, 0.0, 0.0, 0.0, Config.RopeLength, 1, 1000.0, 0.5, 1.0, false, false, false, 5.0, false, 0)
    AttachEntitiesToRope(CurrentRope, IdProp, CurrentPumpObj, pumppropcoords.x, pumppropcoords.y, pumppropcoords.z, posPump.x, posPump.y, posPump.z + Config.PumpModels[model].z, Config.RopeMaxLength, 0, 0)
end)

RegisterNetEvent("qb-fuel:client:DetachRope", function()
    DetachRopeFromEntity(CurrentRope, CurrentPumpProp)
    DeleteRope(CurrentRope)
    DeleteEntity(CurrentPumpObj)
    CurrentPump = nil
    CurrentRope = nil
    CurrentCapPos = nil
    CurrentVehicle = nil
    CurrentBone = nil
    if PlayerPedId() == CurrentSource then
        DetachEntity(CurrentPumpProp, true, true)
        DeleteEntity(CurrentPumpProp)
        CurrentPumpProp = nil
    end
end)