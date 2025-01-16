--!Type(Client)


--!SerializeField
local GuestBookListObject : GameObject = nil

local guestBookScript = nil
local GuestBookManager = require("GuestBookManager")

function self:Awake()
  if guestBookScript == nil then 
    if GuestBookListObject then 
      guestBookScript = GuestBookListObject:GetComponent(GuestBookList)
    end
  end
end

function self:Start()
  self.gameObject:GetComponent(TapHandler).Tapped:Connect(function()
    print(client.localPlayer.name .. " Tapped the guest book!")

    
    if GuestBookListObject ~= nil then
      GuestBookListObject:SetActive(true)

      -- Get the guests from the GuestBookManager
      local guests = GuestBookManager.GetGuestBook()

      -- Update the guest book list
      guestBookScript = GuestBookListObject:GetComponent(GuestBookList)
      guestBookScript.PopulateGuestBookList(guests)
    else
      print("Guest Book List Object is not set.")
    end
  end)
end