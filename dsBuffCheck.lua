

-- Define buffs to track (modify these with your desired buffs and icons)
local buffs = {
  ["Warlock"] = { buffName = "Demon Armor", iconTexture = "spell_shadow_demonarmor.blp" },
  ["Mage"] = { buffName = "Frost Armor", iconTexture = "spell_frost_icicles.blp", 
                 -- Add another buff for Arcane Intellect
                 additionalBuffs = { {buffName = "Arcane Intellect", iconTexture = "spell_holy_magicaura.blp"} } },
  ["Priest"] = { buffName = "Battle Shout", iconTexture = "spell_warcraft_battle_shout.blp",
                 -- Add multiple buffs for Priest
                 additionalBuffs = { {buffName = "Prayer of Fortitude", iconTexture = "spell_holy_fortitude.blp"},
                                     {buffName = "Divine Spirit", iconTexture = "spell_holy_powerfortitude.blp"} } },
  ["Warrior"] = { buffName = "Battle Shout", iconTexture = "spell_warcraft_battle_shout.blp" },
}

-- Create a frame to hold the icon
local frame = CreateFrame("Frame")
frame:SetWidth(32)
frame:SetHeight(32)
frame:SetAlpha(0)  -- Initially invisible

local icon = frame:CreateTexture()
icon:SetAllPoints()
icon:SetTexture(1)

-- Function to check buff and update icon
local function UpdateBuffIcon(unitClass)
  local buffInfo = buffs[unitClass]
  if buffInfo then
    local hasBuff = UnitAura("player", buffInfo.buffName) ~= nil
    frame:SetAlpha(hasBuff and 0 or 1)  -- Show if missing, hide if present
    icon:SetTexture(buffInfo.iconTexture)
  end
end

-- Update icon on combat events or unit change
frame:RegisterEvent("UNIT_AURA")
frame:RegisterEvent("UNIT_ENTER_COMBAT")
frame:RegisterEvent("UNIT_LEAVE_COMBAT")
frame:SetScript("OnEvent", function(self, event)
  if event == "UNIT_AURA" or event == "UNIT_ENTER_COMBAT" then
    UpdateBuffIcon(UnitClass("player"))
  end
end)

-- Flash the icon on update (optional, comment out to disable flashing)
local flashAlpha = 0
local flashTimer = CreateTimer(0.1, function()
  if frame:GetAlpha() > 0 then
    flashAlpha = math.sin(GetTime() * 10) * 0.5 + 0.5
    frame:SetAlpha(flashAlpha)
  end
end)

-- Update buff on login and class change
UpdateBuffIcon(UnitClass("player"))

-- Show the frame on screen (adjust coordinates as needed)
frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 10, -10)











-- dsBuffCheck.lua

local dsBuffCheck = CreateFrame("Frame", "dsBuffCheckFrame", UIParent)
dsBuffCheck:SetSize(64, 64)
dsBuffCheck:SetPoint("CENTER")
dsBuffCheck:Hide()

dsBuffCheck.texture = dsBuffCheck:CreateTexture(nil, "BACKGROUND")
dsBuffCheck.texture:SetAllPoints()

-- Table to store class-specific buff information
local classBuffs = {
    ["WARLOCK"] = {
        {name = "Demon Armor", icon = "Interface\\Icons\\Spell_Shadow_RagingScream"}
    },
    ["MAGE"] = {
        {name = "Frost Armor", icon = "Interface\\Icons\\Spell_Frost_FrostArmor02"},
        {name = "Arcane Intellect", icon = "Interface\\Icons\\Spell_Holy_MagicalSentry"}
    },
    ["WARRIOR"] = {
        {name = "Battle Shout", icon = "Interface\\Icons\\Ability_Warrior_BattleShout"}
    },
    ["PRIEST"] = {
        {name = "Prayer of Fortitude", icon = "Interface\\Icons\\Spell_Holy_PrayerOfFortitude"},
        {name = "Divine Spirit", icon = "Interface\\Icons\\Spell_Holy_DivineSpirit"}
    }
    -- Add more classes and their buffs here
}

local function CheckBuff(buffName)
    for i = 1, 32 do
        local name = UnitBuff("player", i)
        if not name then break end
        if name == buffName then
            return true
        end
    end
    return false
end

local function OnEvent(self, event, ...)
    if event == "PLAYER_ENTERING_WORLD" then
        local _, class = UnitClass("player")
        self.playerClass = class
        if classBuffs[class] then
            self.buffIndex = 1
            self.texture:SetTexture(classBuffs[class][self.buffIndex].icon)
        else
            print("dsBuffCheck: Unsupported class")
            return
        end
    end

    if event == "PLAYER_ENTERING_WORLD" or event == "UNIT_AURA" then
        if not self.playerClass or not classBuffs[self.playerClass] then return end

        local buffs = classBuffs[self.playerClass]
        local allBuffsPresent = true

        for i, buff in ipairs(buffs) do
            if not CheckBuff(buff.name) then
                allBuffsPresent = false
                self.buffIndex = i
                self.texture:SetTexture(buff.icon)
                break
            end
        end

        if allBuffsPresent then
            self:Hide()
            self.flash = false
        else
            self:Show()
            self.flash = true
        end
    end
end

dsBuffCheck:RegisterEvent("PLAYER_ENTERING_WORLD")
dsBuffCheck:RegisterEvent("UNIT_AURA")
dsBuffCheck:SetScript("OnEvent", OnEvent)

-- Minimap Button
local MinimapButton = CreateFrame("Button", "dsBuffCheckMinimapButton", Minimap)
MinimapButton:SetFrameStrata("MEDIUM")
MinimapButton:SetSize(32, 32)
MinimapButton:SetFrameLevel(8)
MinimapButton:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

MinimapButton.icon = MinimapButton:CreateTexture(nil, "BACKGROUND")
MinimapButton.icon:SetTexture("Interface\\Icons\\Spell_Holy_MagicalSentry")
MinimapButton.icon:SetSize(20, 20)
MinimapButton.icon:SetPoint("CENTER")

MinimapButton.border = MinimapButton:CreateTexture(nil, "OVERLAY")
MinimapButton.border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
MinimapButton.border:SetSize(54, 54)
MinimapButton.border:SetPoint("TOPLEFT")

MinimapButton:SetScript("OnClick", function(self, button)
    if button == "LeftButton" then
        if not dsBuffCheckConfigFrame then
            CreateConfigFrame()
        end
        dsBuffCheckConfigFrame:Show()
    elseif button == "RightButton" then
        dsBuffCheck:UnregisterEvent("UNIT_AURA")
        dsBuffCheck:Hide()
        print("dsBuffCheck: Disabled")
    end
end)

-- Configuration Frame
local function CreateConfigFrame()
    local frame = CreateFrame("Frame", "dsBuffCheckConfigFrame", UIParent, "BasicFrameTemplateWithInset")
    frame:SetSize(300, 200)
    frame:SetPoint("CENTER")
    frame:Hide()

    frame.title = frame:CreateFontString(nil, "OVERLAY")
    frame.title:SetFontObject("GameFontHighlight")
    frame.title:SetPoint("LEFT", frame.TitleBg, "LEFT", 5, 0)
    frame.title:SetText("dsBuffCheck Configuration")

    -- Demo BuffCheck Icon Toggle
    local demoCheckButton = CreateFrame("CheckButton", nil, frame, "UICheckButtonTemplate")
    demoCheckButton:SetPoint("TOPLEFT", 10, -30)
    demoCheckButton.text:SetText("Show Demo BuffCheck Icon")
    demoCheckButton:SetScript("OnClick", function(self)
        if self:GetChecked() then
            dsBuffCheck:Show()
        else
            dsBuffCheck:Hide()
        end
    end)

    -- Minimum Level Slider
    local minLevelSlider = CreateFrame("Slider", nil, frame, "OptionsSliderTemplate")
    minLevelSlider:SetPoint("TOPLEFT", 10, -70)
    minLevelSlider:SetMinMaxValues(1, 60)
    minLevelSlider:SetValue(1)
    minLevelSlider:SetValueStep(1)
    minLevelSlider:SetObeyStepOnDrag(true)
    minLevelSlider.text = minLevelSlider:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    minLevelSlider.text:SetPoint("TOP", minLevelSlider, "BOTTOM", 0, -5)
    minLevelSlider.text:SetText("Minimum Level: 1")

    minLevelSlider:SetScript("OnValueChanged", function(self, value)
        self.text:SetText("Minimum Level: " .. math.floor(value))
        dsBuffCheck.minLevel = math.floor(value)
    end)
end

-- OnUpdate Script for Flashing
dsBuffCheck:SetScript("OnUpdate", function(self, elapsed)
    if not self.flash then return end
    self.flashTime = (self.flashTime or 0) + elapsed
    if self.flashTime > 0.5 then
        self:SetAlpha(self:GetAlpha() == 1 and 0 or 1)
        self.flashTime = 0
    end
end)




















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
