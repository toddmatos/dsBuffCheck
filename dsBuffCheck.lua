
local frame = CreateFrame("Frame", "FrostArmorReminder", UIParent)
frame:SetWidth(32)
frame:SetHeight(32)
frame:SetPoint("CENTER", UIParent, "CENTER", 0, 200)
frame:Hide()

local texture = frame:CreateTexture(nil, "ARTWORK")
texture:SetAllPoints(frame)
texture:SetTexture("Interface\\Icons\\Spell_Frost_FrostArmor02")

local frostArmorTextureName = "Spell_Frost_FrostArmor02"  -- Extract filename

local function CheckFrostArmor()
  if UnitClass("player") ~= "Mage" then
    frame:Hide()
    return
  end

  local hasFrostArmor = false
  for i = 1, 32 do  -- Iterate through buff slots
    local name = UnitBuff("player", i)
    print (name)
    if not name then break end

    local prefix = "Interface\\Icons\\"

    -- Use string.gsub to remove the prefix
    local iconname = string.gsub(name, prefix, "")


    if iconname == "Spell_Frost_FrostArmor02" then  -- Check for buff name
      hasFrostArmor = true
      break
    end
  end

  if not hasFrostArmor then
    frame:Show()
  else
    frame:Hide()
  end
end

local flashTimer = 0
local flashState = true

frame:SetScript("OnUpdate", function()
  flashTimer = flashTimer + arg1
  if flashTimer > 0.5 then
    flashTimer = 0
    flashState = not flashState
    if flashState then
      texture:SetAlpha(1)
    else
      texture:SetAlpha(0.5)
    end
  end
end)

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("UNIT_AURA")  -- Might be more reliable than PLAYER_AURAS_CHANGED
eventFrame:SetScript("OnEvent", function()
  if event == "PLAYER_ENTERING_WORLD" or event == "UNIT_AURA" and arg1 == "player" then
    CheckFrostArmor()
  end
end)

-- Initial check
CheckFrostArmor()
