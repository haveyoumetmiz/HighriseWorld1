local buttonTapRequest = Event.new("ButtonTapRequest")
local buttonTapEvent = Event.new("ButtonTapEvent")

function self:ClientAwake()
    self.gameObject:GetComponent(TapHandler).Tapped:Connect(function()
        -- Insert code to execute locally when the button is tapped
        buttonTapRequest:FireServer() -- Send a Request to the Server
    end)

    buttonTapEvent:Connect(function()
        -- Insert code to execute on all clients when the button is tapped by any one
        print("Hello World")
        -- To show which client is saying hello world, concatenate 'Hello World' with client.localPlayer.name
        print(client.localPlayer.name .. ": Hello World")
    end)
end

function self:ServerAwake()
    buttonTapRequest:Connect(function()
        buttonTapEvent:FireAllClients() -- Send an Event to all Clients
    end)
end
