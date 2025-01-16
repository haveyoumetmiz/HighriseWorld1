--!Type(ClientAndServer)

local counterInterface = nil

local UpdateCountRequest = Event.new("UpdateCountRequestEvent")
local UpdateCountEvent = Event.new("UpdateCountEvent")

function self:ClientAwake()
    counterInterface = self.gameObject:GetComponent(UserCounterInterface)

    UpdateCountEvent:Connect(function(count)
        counterInterface.SetUserCount(count)
    end)

    UpdateCountRequest:FireServer()
end

function self:ServerAwake()
    local userCount = 0
    Storage.GetValue("userCount", function(value)
        if value == nil then
            Storage.SetValue("userCount", 0, function(errorCode)
                userCount = 0
            end)
        else
            userCount = value
        end
    end)

    server.PlayerConnected:Connect(function(player)
        Storage.GetPlayerValue(player, "hasJoined", function(hasJoined, errorCode)
            if errorCode ~= nil and errorCode ~= 0 then
                print("Error getting hasJoined value: " .. errorCode)
                return
            end

            if hasJoined then return end
            Storage.SetPlayerValue(player, "hasJoined", true)
            Storage.IncrementValue("userCount", 1, function(errorCode)
                if errorCode ~= nil and errorCode ~= 0 then
                    print("Error incrementing user count: " .. errorCode)
                    return
                end

                userCount = userCount + 1
                UpdateCountEvent:FireAllClients(userCount)
            end)
        end)
    end)

    UpdateCountRequest:Connect(function(player)
        UpdateCountEvent:FireClient(player, userCount)
    end)
end