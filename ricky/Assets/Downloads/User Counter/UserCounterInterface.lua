--!Type(UI)

--!Bind
local userCounterText : UILabel = nil

--!SerializeField
local counterMessage : string = "Unique Users"

function UpdateMessage(count)
    if counterMessage == nil or counterMessage == "" then
        userCounterText:SetPrelocalizedText(count)
    else
        userCounterText:SetPrelocalizedText(count .. " " .. counterMessage)
    end
end

function self:ClientAwake()
    UpdateMessage(0)
end

function SetUserCount(count)
    UpdateMessage(count)
end