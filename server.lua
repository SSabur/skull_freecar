ESX               = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

print("^2 [no1_freecar] Developer - Playerno1")

AddEventHandler("no1_freecar:server:claimVehicle", function()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if xPlayer == nil then return end

    MySQL.Async.fetchAll('SELECT * FROM no1_freecar WHERE identifier = @identifier', { ['@identifier'] = xPlayer.identifier }, function(result)
        if result[1] ~= nil then
            TriggerClientEvent('esx:showNotification', src, "You've already claimed a vehicle!")
        else
            TriggerClientEvent('no1_freecar:client:spawnClaimedVehicle', src) 
        end
    end)
end)

AddEventHandler("no1_freecar:server:SetOwnedVehicle", function(plate, vehicleProps)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if xPlayer == nil then return end

    MySQL.Async.execute("INSERT INTO no1_freecar (identifier) VALUES (@identifier)", {['@identifier'] = xPlayer.identifier}, function()
        print("^6[playerno1] ^1"..xPlayer.getName().."^3 has claimed a free vehicle!")
    end)

    MySQL.Async.execute("INSERT INTO owned_vehicles (owner, plate, vehicle, type, stored) VALUES (@owner, @plate, @vehicle, @type, @stored)", {
        ['@owner'] = xPlayer.identifier,
        ['@plate'] = plate,
        ['@type'] = Config.Vehicle["type"],
        ['@vehicle'] = json.encode(vehicleProps),
        ['@stored'] = 0
    }, function()
        TriggerClientEvent('esx:showNotification', src, string.format("You've received a vehicle with plate number ~y~%s", string.upper(plate)))
    end)

    if Config.DiscordWebhook then
        SendToDiscord(string.format("**Name**: %s\n**Identifier**: %s (%s)\n**Plate**: %s\n**Timestamp**: %s", xPlayer.getName(), GetPlayerName(src), xPlayer.identifier, plate, os.date('%Y-%m-%d %H:%M:%S')))
    end
end)

function SendToDiscord(message)
	local embed = {
		{
			["title"] = "🚗 Free Car Log",
			["description"] = message,
		    ["footer"] = {
		        ["text"] = "• playerno1 •",
		    },
		}
	}
	PerformHttpRequest(Config.DiscordWebhook, function(err, text, headers) end, 'POST', json.encode({username = "playerno1", embeds = embed}), { ['Content-Type'] = 'application/json' })
end

RegisterNetEvent("no1_freecar:server:claimVehicle")
RegisterNetEvent("no1_freecar:server:SetOwnedVehicle")

