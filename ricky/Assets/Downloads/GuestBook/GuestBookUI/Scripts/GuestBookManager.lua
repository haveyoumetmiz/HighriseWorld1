--!Type(Module)

-- Event to trigger when a new guest signs the book
local InsertGuestNameEvent = Event.new("InsertGuestNameEvent")

local GetGuestsRequest = Event.new("GetGuestsRequest")
local GetGuestsResponse = Event.new("GetGuestsResponse")
local GetGuestBookEvent = Event.new("GetGuestBookEvent")

--!SerializeField
local GuestBookUI : GameObject = nil

-- Table to store the guests (name, date)
local guests = {} -- Global table
local totalGuests = 0

InsertNewGuest = function(playerName: string)
  if playerName ~= client.localPlayer.name then return end
  InsertGuestNameEvent:FireServer()
end

GetGuestBook = function()
  return guests
end

function self:ClientAwake()
  -- Requesting the guests from the server
  GetGuestsRequest:FireServer()

  -- Overwrite the guests with the updated list
  GetGuestsResponse:Connect(function(newGuests)
    guests = newGuests
    totalGuests = #newGuests

    -- Is the player in the guest book? if not, show the guest book UI
    local playerName = client.localPlayer.name
    local isPlayerInGuestBook = false
    
    for _, guest in ipairs(guests) do
      if guest.name == playerName then
        isPlayerInGuestBook = true
        break
      end
    end
  
    if not isPlayerInGuestBook then
      GuestBookUI:SetActive(true)
    end
  end)

  GetGuestBookEvent:Connect(function(newGuests)
    guests = newGuests
    totalGuests = #newGuests
  end)
end

local function ConvertDateFormat(dateStr)
  -- Parse the date string
  local pattern = "(%a+) (%a+) (%d+) (%d+):(%d+):(%d+) (%d+)"
  local dayOfWeek, month, day, hour, min, sec, year = dateStr:match(pattern)

  -- Create a table for month conversion
  local months = {Jan = "01", Feb = "02", Mar = "03", Apr = "04", May = "05", Jun = "06",
                  Jul = "07", Aug = "08", Sep = "09", Oct = "10", Nov = "11", Dec = "12"}

  -- Format the date to "YYYY-MM-DD"
  local formattedDate = string.format("%04d-%02d-%02d", year, months[month], day)
  return formattedDate
end

local function SortByDate()
  table.sort(guests, function(a, b)
    return ConvertDateFormat(a.date) > ConvertDateFormat(b.date)
  end)
end

function self:ServerAwake()
  -- Get the stored data from the server
  Storage.GetValue("Guests", function(value)
    if value == nil then value = {} end
    guests = value

    totalGuests = #guests
  end)

  InsertGuestNameEvent:Connect(function(player)
    local playerName = player.name
    
    -- Check if the player is already in the guest book
    for _, guest in ipairs(guests) do
      if guest.name == playerName then
        print(playerName .. " is already in the guest book.")
        return -- Player is already in the guest book, so we return early
      end
    end
    
    -- Add the new guest to the table
    table.insert(guests, {name = playerName, date = ConvertDateFormat(os.date("%c"))})
    totalGuests = totalGuests + 1
  
    -- Print the updated total number of guests
    print(playerName .. " signed the guest book, we now have " .. totalGuests .. " guests!")
  
    -- Save the updated table to the server
    Storage.SetValue("Guests", guests)

    -- Send the updated list to all clients
    GetGuestBookEvent:FireAllClients(guests)
  end)

  GetGuestsRequest:Connect(function(player)
    -- Send the guests to the client
    Storage.GetValue("Guests", function(value)
      if value == nil then value = {} end
      -- If the list is over 100, only send the last 100 guests (sorted by date)
      if #value > 100 then
        SortByDate()
        for i = 1, #value - 100 do
          table.remove(value, 1)
        end
      end
      
      GetGuestsResponse:FireClient(player, value)
    end)
  end)
end