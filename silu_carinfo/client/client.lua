local outlineVehicles = {}

local function SendReactMessage(action, data)
    SendNUIMessage({ type = action, data = data })
end

local function CloseUI()
    SendReactMessage("closeBox", {})
    SetNuiFocus(false, false)
end

RegisterCommand(Config.CommandName, function()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local forward = GetOffsetFromEntityInWorldCoords(ped, 0.0, 10.0, 0.0)

    local rayHandle = StartShapeTestCapsule(coords.x, coords.y, coords.z, forward.x, forward.y, forward.z, 2.0, 10, ped, 7)
    local _, hit, _, _, entity = GetShapeTestResult(rayHandle)

    local lang = Config.Languages[Config.Language]

    if hit and DoesEntityExist(entity) and IsEntityAVehicle(entity) then
        local vehicle = entity
        SetVehicleModKit(vehicle, 0)

        outlineVehicles[vehicle] = true
        SetEntityDrawOutline(vehicle, true)
        SetEntityDrawOutlineColor(Config.OutlineColor.r, Config.OutlineColor.g, Config.OutlineColor.b, Config.OutlineColor.a)


        local turboCount = GetNumVehicleMods(vehicle, 18)
        local turboExists = turboCount > 0
        local turboEnabled = turboExists and IsToggleModOn(vehicle, 18) or false

        local function GetModOrNA(vehicle, modType)
            local modValue = GetVehicleMod(vehicle, modType)
            if modValue == -1 then return lang.notAvailable end
            return modValue
        end

        local data = {
            title = lang.vehicleInfoTitle,
            engineLabel = lang.engine,
            transmissionLabel = lang.transmission,
            brakesLabel = lang.brakes,
            suspensionLabel = lang.suspension,
            turboLabel = lang.turbo,
            turboStatus = turboExists and (turboEnabled and lang.turboOn or lang.turboOff) or lang.turboNA,
            engineHealthLabel = lang.engineHealth,
            bodyHealthLabel = lang.bodyHealth,
            engine = GetModOrNA(vehicle, 11),
            transmission = GetModOrNA(vehicle, 13),
            brakes = GetModOrNA(vehicle, 12),
            suspension = GetModOrNA(vehicle, 15),
            engineHealth = GetVehicleEngineHealth(vehicle),
            bodyHealth = GetVehicleBodyHealth(vehicle)
        }

        SendReactMessage("carInfo", data)

        Citizen.SetTimeout(10000, function()
            if DoesEntityExist(vehicle) then
                SetEntityDrawOutline(vehicle, false)
            end
            outlineVehicles[vehicle] = nil
            CloseUI()
        end)
    else
        TriggerEvent("chat:addMessage", {
            color = {255,0,0},
            args = {lang.systemTitle, lang.noVeh} 
        })
    end
end, false)