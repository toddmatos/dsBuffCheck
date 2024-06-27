-- Define a table containing class and buff information
local classBuffs = {
  ["MAGE"] = {
    "Arcane Intellect",
    "Frost Armor",
    "Mana Shield",
  },
  ["WARRIOR"] = {
    "Battle Shout",
    "Demoralizing Shout",
    "Berserker Rage",
  },
  ["PRIEST"] = {
    "Power Word: Fortitude",
    "Power Word: Shield",
    "Renew",
  },
  -- Add entries for other classes as needed
}

-- Function to retrieve buffs for a specific class
local function getClassBuffs(className)
  if classBuffs[className] then
    return classBuffs[className]
  else
    return nil -- Class not found in the table
  end
end

-- Example usage
local mageBuffs = getClassBuffs("MAGE")

if mageBuffs then
  -- Loop through the retrieved buffs and display them (replace print with your desired output)
  for _, buffName in ipairs(mageBuffs) do
    print(buffName)
  end
else
  print("Mage buffs not found")
end
