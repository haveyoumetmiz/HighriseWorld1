--!Type(UI)

--!SerializeField
local Title : string = "Guest Book"
--!SerializeField
local CloseButtonText : string = "Close"
--!SerializeField
local MaxGuests : number = 15

--!Bind
local _Title : UILabel = nil
--!Bind
local _CloseLabel : UILabel = nil

--!Bind
local _CloseButton : VisualElement = nil
--!Bind
local _ScrollView : UIScrollView = nil

-- Function to initialize the guest book screen
function InitializeGuestBookScreen()
  _Title:SetPrelocalizedText(Title)
  _CloseLabel:SetPrelocalizedText(CloseButtonText)
end

InitializeGuestBookScreen()

-- Function to close the guest book screen
_CloseButton:RegisterPressCallback(function()
  -- Disable the guest book screen
  self.gameObject:SetActive(false)
end, true, true, true)

-- Function to add a guest to the guest book list
function AddGuest(name, date)
  local _guest = VisualElement.new()
  _guest:AddToClassList("guest")

  local _name = UILabel.new()
  _name:SetPrelocalizedText(name)
  _name:AddToClassList("name")

  local _date = UILabel.new()
  _date:SetPrelocalizedText(date)
  _date:AddToClassList("date")

  _guest:Add(_name)
  _guest:Add(_date)

  return _guest
end

-- Function to populate the guest book list
function PopulateGuestBookList(guestList)
  _ScrollView:Clear()

  local sortedGuestList = SortGuestBook(guestList)
  for i, guest in ipairs(sortedGuestList) do
    local _guest = AddGuest(guest.name, guest.date)
    _ScrollView:Add(_guest)
  end
end

-- Function to convert string date "2024-07-16" to sortable date "20240716"
function ConvertDateFormat(date)
  local year, month, day = date:match("(%d+)-(%d+)-(%d+)")
  return year .. month .. day
end

-- Function to sort guestbook by latest date and maximum number of guests to display
function SortGuestBook(guestList)
  -- Sort the guest list by last joined date
  table.sort(guestList, function(a, b)
    return ConvertDateFormat(a.date) > ConvertDateFormat(b.date)
  end)

  -- Cap the list to the maximum number of guests to display
  if MaxGuests > 100 then
    MaxGuests = 100
    print("Capping the maximum number of guests to display to 100.")
  end

  while #guestList > MaxGuests do
    table.remove(guestList, #guestList) -- Remove oldest guest to keep the latest ones
  end

  return guestList
end
