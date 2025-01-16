--!SerializeField
local Destination : Transform = nil

local canTeleport = false

local teleportRequest = Event.new("TeleportRequest")
local teleportEvent = Event.new("TeleportEvent")

local TeleportUIScript = nil

function self:ClientAwake()
    TeleportUIScript = self.transform.parent.gameObject:GetComponent(TeleporterUi)

    function ToggleTeleporterUI(canTeleport)
        TeleportUIScript.SetVisible(canTeleport, self.gameObject)
    end

    function Teleport()
        teleportRequest:FireServer(Destination.position)
    end

    function self:OnTriggerEnter(other : Collider)
        local playerCharacter = other.gameObject:GetComponent(Character)
        if playerCharacter == nil then return end  -- Exit if no Character component

        local player = playerCharacter.player
        if client.localPlayer == player then
            canTeleport = true
            ToggleTeleporterUI(canTeleport)
        end
    end 
    function self:OnTriggerExit(other : Collider)
        local playerCharacter = other.gameObject:GetComponent(Character)
        if playerCharacter == nil then return end  -- Exit if no Character component

        local player = playerCharacter.player
        if client.localPlayer == player then
            canTeleport = false
            ToggleTeleporterUI(canTeleport)
        end
    end

    teleportEvent:Connect(function(player, pos)
        Destination.gameObject:GetComponent(ParticleSystem):Play()
        player.character:Teleport(Destination.position)
        player.character:MoveTo(Destination.position)
    end)
end

function self:ServerAwake()
    teleportRequest:Connect(function(player, pos)
        player.character.transform.position = pos
        teleportEvent:FireAllClients(player)
    end)
end