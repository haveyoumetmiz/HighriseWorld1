--!Type(UI)

--!Bind
local _instructions : UILabel = nil

--!Bind
local _SignButton : VisualElement = nil
--!Bind
local _CancelButton : VisualElement = nil

-- Require the guest book manager, to manage the storage and events
local Manager = require("GuestBookManager")

-- Change the fullText to the message you want to display

--!SerializeField
local fullText : string = "Hello {{user}},\n\nWelcome to our community! We're excited to have you here. Dive in, experiment, and enjoy all the possibilities. Leave your mark in our guest book and share your thoughts with us.\n\nHappy exploring!"

local currentIndex = 0 -- Start from the first character

local function typeWriterEffect()

  if fullText == nil then 
    print("GuestBookScreen: fullText is nil, please set the fullText property.")
    return
  end
  
  -- Check if the text has {{user}} and replace it with the player's name
  fullText = string.gsub(fullText, "{{user}}", client.localPlayer.name)

  currentIndex = currentIndex + 1 -- Move to the next character
  if currentIndex <= #fullText then
      -- Set the text up to the current index, simulating typing
      _instructions:SetPrelocalizedText(string.sub(fullText, 1, currentIndex))
      -- Call this function again after a short delay to add the next character
      Timer.After(0.05, typeWriterEffect)
  end
end

-- Start the typewriter effect
typeWriterEffect()

_SignButton:RegisterPressCallback(function()
  print(client.localPlayer.name .. " signed the guest book!")

  -- Trigger the event to add the player's name to the guest book
  Manager.InsertNewGuest(client.localPlayer.name)

  self.gameObject:SetActive(false)
end)

_CancelButton:RegisterPressCallback(function()
  print(client.localPlayer.name .. " canceled signing the guest book.")

  -- Cancel the typing effect if the player closes the guest book
  currentIndex = #fullText
  _instructions:SetPrelocalizedText(fullText)
  
  self.gameObject:SetActive(false)
end)

-- Function to convert {{user}} to the player's name
function ConvertUserTag(text: string)
  return text:gsub("{{user}}", client.localPlayer.name)
end