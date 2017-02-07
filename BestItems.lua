--[[
	### ItemsOfPower ###
	Best Items

--]]

local L = AceLibrary("AceLocale-2.2"):new("ItemsOfPower")
local Gratuity = AceLibrary("Gratuity-2.0")

local tinsert = table.insert

local class = ItemsOfPower:select(2, UnitClass("player"))

local Slots = { }

-- ItemTypes
local Armor = { "Armor" }
local Weapon = { "Weapon" }

-- ItemSubTypes:
local Misc = { "Miscellaneous" }
local Default

if class == "DRUID" then
  Default = { "Leather", "Cloth" }

  Slots.Mainhand = { ItemType = "Weapon", ItemSubTypes = { "Daggers", "One-Handed Maces", "Fist Weapons" }, ItemEquipLocs = { "INVTYPE_WEAPONMAINHAND", "INVTYPE_WEAPON", "INVTYPE_2HWEAPON" } }
  Slots.Offhand = { ItemType = "Armor", ItemSubTypes = Misc, ItemEquipLocs = { "INVTYPE_HOLDABLE" } }
  Slots.TwoHand = { ItemType = "Weapon", ItemSubTypes = { "Two-Handed Maces", "Staves" }, ItemEquipLocs = { "INVTYPE_2HWEAPON" } }

  Slots.Ranged = { ItemType = "Armor", ItemSubTypes = { "Idols" }, ItemEquipLocs = { "INVTYPE_RELIC" } }
elseif class == "HUNTER" then
  Default = { "Mail", "Leather" }
  local Weapons = { "Daggers", "One-Handed Swords", "One-Handed Axes", "Fist Weapons" }

  Slots.Mainhand = { ItemType = "Weapon", ItemSubTypes = Weapons, ItemEquipLocs = { "INVTYPE_WEAPONMAINHAND", "INVTYPE_WEAPON", "INVTYPE_2HWEAPON" } }
  Slots.Offhand = { ItemType = "Weapon", ItemSubTypes = Weapons, ItemEquipLocs = { "INVTYPE_WEAPONOFFHAND", "INVTYPE_WEAPON" } }
  Slots.TwoHand = { ItemType = "Weapon", ItemSubTypes = { "Two-Handed Swords", "Two-Handed Axes", "Staves", "Polearms" }, ItemEquipLocs = { "INVTYPE_2HWEAPON" } }

  Slots.Ranged = { ItemType = "Weapon", ItemSubTypes = { "Crossbows", "Bows", "Guns", "Thrown" }, ItemEquipLocs = { "INVTYPE_RANGEDRIGHT", "INVTYPE_THROWN", "INVTYPE_RANGED" } }
elseif class == "MAGE" then
  Default = { "Cloth" }

  Slots.Mainhand = { ItemType = "Weapon", ItemSubTypes = { "Daggers", "One-Handed Swords" }, ItemEquipLocs = { "INVTYPE_WEAPONMAINHAND", "INVTYPE_WEAPON", "INVTYPE_2HWEAPON" } }
  Slots.Offhand = { ItemType = "Armor", ItemSubTypes = Misc, ItemEquipLocs = { "INVTYPE_HOLDABLE" } }
  Slots.TwoHand = { ItemType = "Weapon", ItemSubTypes = { "Staves" }, ItemEquipLocs = { "INVTYPE_2HWEAPON" } }

  Slots.Ranged = { ItemType = "Weapon", ItemSubTypes = { "Wands" }, ItemEquipLocs = { "INVTYPE_RANGEDRIGHT" } }
elseif class == "PALADIN" then
  Default = { "Plate", "Mail", "Leather", "Cloth" }

  Slots.Mainhand = { ItemType = "Weapon", ItemSubTypes = { "One-Handed Swords", "One-Handed Maces", "One-Handed Axes" }, ItemEquipLocs = { "INVTYPE_WEAPONMAINHAND", "INVTYPE_WEAPON", "INVTYPE_2HWEAPON" } }
  Slots.Offhand = { ItemType = "Armor", ItemSubTypes = { "Miscellaneous", "Shields" }, ItemEquipLocs = { "INVTYPE_HOLDABLE", "INVTYPE_SHIELD" } }
  Slots.TwoHand = { ItemType = "Weapon", ItemSubTypes = { "Two-Handed Swords", "Two-Handed Axes", "Two-Handed Maces", "Polearms" }, ItemEquipLocs = { "INVTYPE_2HWEAPON" } }

  Slots.Ranged = { ItemType = "Armor", ItemSubTypes = { "Librams" }, ItemEquipLocs = { "INVTYPE_RELIC" } }
elseif class == "PRIEST" then
  Default = { "Cloth" }

  Slots.Mainhand = { ItemType = "Weapon", ItemSubTypes = { "Daggers", "One-Handed Maces" }, ItemEquipLocs = { "INVTYPE_WEAPONMAINHAND", "INVTYPE_WEAPON" } }
  Slots.Offhand = { ItemType = "Armor", ItemSubTypes = Misc, ItemEquipLocs = { "INVTYPE_HOLDABLE" } }
  Slots.TwoHand = { ItemType = "Weapon", ItemSubTypes = { "Staves" }, ItemEquipLocs = { "INVTYPE_2HWEAPON" } }

  Slots.Ranged = { ItemType = "Weapon", ItemSubTypes = { "Wands" }, ItemEquipLocs = { "INVTYPE_RANGEDRIGHT" } }
elseif class == "ROGUE" then
  Default = { "Leather" }
  local Weapons = { "Daggers", "One-Handed Maces", "One-Handed Swords", "Fist Weapons" }

  Slots.Mainhand = { ItemType = "Weapon", ItemSubTypes = Weapons, ItemEquipLocs = { "INVTYPE_WEAPONMAINHAND", "INVTYPE_WEAPON" } }
  Slots.Offhand = { ItemType = "Weapon", ItemSubTypes = Weapons, ItemEquipLocs = { "INVTYPE_WEAPONOFFHAND", "INVTYPE_WEAPON" } }

  Slots.Ranged = { ItemType = "Weapon", ItemSubTypes = { "Crossbows", "Bows", "Guns", "Thrown" }, ItemEquipLocs = { "INVTYPE_RANGEDRIGHT", "INVTYPE_THROWN", "INVTYPE_RANGED" } }
elseif class == "SHAMAN" then
  Default = { "Mail", "Leather", "Cloth" }
  local Weapons = { "Daggers", "One-Handed Maces", "One-Handed Axes", "Fist Weapons" }

  Slots.Mainhand = { ItemType = "Weapon", ItemSubTypes = Weapons, ItemEquipLocs = { "INVTYPE_WEAPONMAINHAND", "INVTYPE_WEAPON" } }
  Slots.Offhand = { ItemType = "Weapon", ItemSubTypes = Weapons, ItemEquipLocs = { "INVTYPE_WEAPONOFFHAND", "INVTYPE_WEAPON" } }
  Slots.OffhandI = { ItemType = "Armor", ItemSubTypes = { "Shields", "Miscellaneous" }, ItemEquipLocs = { "INVTYPE_SHIELD", "INVTYPE_HOLDABLE" } }
  Slots.TwoHand = { ItemType = "Weapon", ItemSubTypes = { "Two-Handed Maces", "Two-Handed Axes", "Staves" }, ItemEquipLocs = { "INVTYPE_2HWEAPON" } }

  Slots.Ranged = { ItemType = "Armor", ItemSubTypes = { "Crossbows", "Bows", "Guns", "Thrown" }, ItemEquipLocs = { "INVTYPE_RANGEDRIGHT", "INVTYPE_THROWN", "INVTYPE_RANGED" } }
elseif class == "WARLOCK" then
  Default = { "Cloth" }

  Slots.Mainhand = { ItemType = "Weapon", ItemSubTypes = { "Daggers", "One-Handed Swords" }, ItemEquipLocs = { "INVTYPE_WEAPONMAINHAND", "INVTYPE_WEAPON" } }
  Slots.Offhand = { ItemType = "Armor", ItemSubTypes = Misc, ItemEquipLocs = { "INVTYPE_HOLDABLE" } }
  Slots.TwoHand = { ItemType = "Weapon", ItemSubTypes = { "Staves" }, ItemEquipLocs = { "INVTYPE_2HWEAPON" } }

  Slots.Ranged = { ItemType = "Weapon", ItemSubTypes = { "Wands" }, ItemEquipLocs = { "INVTYPE_RANGEDRIGHT" } }
elseif class == "WARRIOR" then
  Default = { "Plate", "Mail", "Leather" }
  local Weapons = { "Daggers", "One-Handed Swords", "One-Handed Maces", "One-Handed Axes", "Fist Weapons" }

  Slots.Mainhand = { ItemType = "Weapon", ItemSubTypes = Weapons, ItemEquipLocs = { "INVTYPE_WEAPONMAINHAND", "INVTYPE_WEAPON" } }
  Slots.Offhand = { ItemType = "Weapon", ItemSubTypes = Weapons, ItemEquipLocs = { "INVTYPE_WEAPONOFFHAND", "INVTYPE_WEAPON" } }
  Slots.OffhandI = { ItemType = "Armor", ItemSubTypes = { "Shields" }, ItemEquipLocs = { "INVTYPE_SHIELD" } }
  Slots.TwoHand = { ItemType = "Weapon", ItemSubTypes = { "Two-Handed Swords", "Two-Handed Maces", "Two-Handed Axes", "Staves", "Polearms" }, ItemEquipLocs = { "INVTYPE_2HWEAPON" } }

  Slots.Ranged = { ItemType = "Weapon", ItemSubTypes = { "Crossbows", "Bows", "Guns", "Thrown" }, ItemEquipLocs = { "INVTYPE_RANGEDRIGHT", "INVTYPE_THROWN", "INVTYPE_RANGED" } }
end

Slots.Head = { ItemType = "Armor", ItemSubTypes = Default, ItemEquipLocs = { "INVTYPE_HEAD" } }
Slots.Shoulder = { ItemType = "Armor", ItemSubTypes = Default, ItemEquipLocs = { "INVTYPE_SHOULDER" } }
Slots.Chest = { ItemType = "Armor", ItemSubTypes = Default, ItemEquipLocs = { "INVTYPE_CHEST", "INVTYPE_ROBE" } }
Slots.Wrist = { ItemType = "Armor", ItemSubTypes = Default, ItemEquipLocs = { "INVTYPE_WRIST" } }
Slots.Hand = { ItemType = "Armor", ItemSubTypes = Default, ItemEquipLocs = { "INVTYPE_HAND" } }
Slots.Waist = { ItemType = "Armor", ItemSubTypes = Default, ItemEquipLocs = { "INVTYPE_WAIST" } }
Slots.Legs = { ItemType = "Armor", ItemSubTypes = Default, ItemEquipLocs = { "INVTYPE_LEGS" } }
Slots.Feet = { ItemType = "Armor", ItemSubTypes = Default, ItemEquipLocs = { "INVTYPE_FEET" } }

Slots.Neck = { ItemType = "Armor", ItemSubTypes = Misc, ItemEquipLocs = { "INVTYPE_NECK" } }
Slots.Finger = { ItemType = "Armor", ItemSubTypes = Misc, ItemEquipLocs = { "INVTYPE_FINGER" } }
Slots.Trinket = { ItemType = "Armor", ItemSubTypes = Misc, ItemEquipLocs = { "INVTYPE_TRINKET" } }

Slots.Back = { ItemType = "Armor", ItemSubTypes = { "Cloth" }, ItemEquipLocs = { "INVTYPE_CLOAK" } }

local function round(num, idp)
  local mult = 10 ^(idp or 0)
  return math.floor(num * mult + 0.5) / mult
end

local function ItemIsUsable(id)
  Gratuity:SetHyperlink("item:" .. id)

  for i = 1, Gratuity:NumLines() do
    local cR, cG, cB = Gratuity.vars.Llines[i]:GetTextColor()
    if cR > 0.9 and cG < 0.2 and cB < 0.2 then
      return false
    end

    cR, cG, cB = Gratuity.vars.Rlines[i]:GetTextColor()
    if cR > 0.9 and cG < 0.2 and cB < 0.2 then
      return false
    end
  end

  return true
end

local Qualities = { 3, 4, 5 }
local comparePoints = function(v1, v2)
  return v1 and v2 and tonumber(v1.Points) > tonumber(v2.Points)
end
function ItemsOfPower:GetBestItems(Slot)
  if not Slots[Slot] then return end

  local SlotName = Slot
  Slot = Slots[Slot]

  local Items = ItemsOfPower:GetItems(Qualities, Slot.ItemType, Slot.ItemSubTypes, Slot.ItemEquipLocs, UnitLevel("player"))

  for SetId, Set in pairs(ItemsOfPower.SetById) do
    if ItemsOfPower.db.profile.DisplayInTooltip[Set.Name] then
      GameTooltip:Hide()

      ItemsOfPower:Print(string.format(L["Scanned |cffffff78%d|r Items for Set |cffffff78%s|r, which fit into the |cffffff78%s|r slot:"], table.getn(Items), Set.Name, SlotName))
      if table.getn(Items) == 0 then return end

      -- Set enchant id
      local eId, i1, i2
      local slot1, slot2 = ItemsOfPower:GetInventorySlot(Items[1])

      if slot1 then i1 = ItemsOfPower:ItemLinkToItemString(GetInventoryItemLink("player", slot1)) end
      if slot2 then i2 = ItemsOfPower:ItemLinkToItemString(GetInventoryItemLink("player", slot2)) end

      if i1 then eId = ItemsOfPower:select(3, ItemsOfPower:strsplit(":", i1)) end
      if i2 and not eId then eId = ItemsOfPower:select(3, ItemsOfPower:strsplit(":", i2)) end

      local ItemsTable = ItemsOfPower.tnew()
      for _, ItemId in pairs(Items) do
        local Item = ItemsOfPower.tnew()
        Item.ItemId = ItemId
        Item.ItemString = ItemsOfPower:GetItemString(ItemId, eId)
        Item.Points = Set:GetItemValue(Item.ItemString)
        if tonumber(Item.Points) then
          tinsert(ItemsTable, Item)
        end
      end
      if table.getn(ItemsTable) > 1 then
        table.sort(ItemsTable, comparePoints)
      end

      local c1, c2
      if i1 then c1 = round(Set:GetItemValue(i1), ItemsOfPower.db.profile.Round[Set.Name]) end
      if i2 then c2 = round(Set:GetItemValue(i2), ItemsOfPower.db.profile.Round[Set.Name]) end

      for i = 1, 15 do
        local Item = ItemsTable[i]
        if not Item then break end
        local b = round(Item.Points, ItemsOfPower.db.profile.Round[Set.Name])

        ItemsOfPower:Print(i .. ".", ItemsOfPower:ItemStringToItemLink(Item.ItemString),
        ItemsOfPower:Compare(ItemsOfPower.db.profile.Tooltip.Compare, ItemsOfPower.db.profile.Tooltip.ShowPoints,
        ItemsOfPower.db.profile.Tooltip.SwapColors, ItemsOfPower.db.profile.Tooltip.SwapComparison,
        b, c1, c2))

        -- Show only better items, but at least one
        if (c1 and c1 >= b or not c1) and(c2 and c2 >= b or not c2) and(c1 or c2) then break end
      end

      ItemsOfPower.tddel(ItemsTable)
    end
  end
  ItemsOfPower.tdel(Items)
end

function ItemsOfPower:GetItems(filterQuality, filterItemType, filterSubType, filterEquipLoc, filterMaxLevel)
  local items = { }

  for i = 1, 25000 do
    -- vanilla highest item id?
    local itemName, itemLink, itemRarity, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc = GetItemInfo(i)

    local matching =(not not itemName) and(filterMaxLevel >= itemMinLevel) and(filterItemType == itemType)
    local match = false

    if matching and filterQuality and type(filterQuality) == "table" then
      for _, q in pairs(filterQuality) do
        if itemRarity == q then
          match = true
          break
        end
      end
      matching = match
    end

    if matching and filterSubType and type(filterSubType) == "table" then
      match = false
      for _, t in pairs(filterSubType) do
        if itemSubType == t then
          match = true
          break
        end
      end
      matching = match
    end

    if matching and filterEquipLoc and type(filterEquipLoc) == "table" then
      match = false
      for _, l in pairs(filterEquipLoc) do
        if itemEquipLoc == l then
          match = true
          break
        end
      end
      matching = match
    end

    if matching then tinsert(items, i) end
  end

  local usableItems = { }
  for _, i in pairs(items) do
    if ItemIsUsable(i) then tinsert(usableItems, i) end
  end

  return usableItems
end

ItemsOfPower.Options.args.Tools.args.BestItems = {
  order = 300,
  type = "text",
  name = L["Best Items"],
  desc = L["Best Items"],
  get = false,
  set = function(EquipLoc) ItemsOfPower:GetBestItems(EquipLoc) end,
  validate = { "Head", "Neck", "Shoulder", "Back", "Chest", "Wrist", "Hand", "Waist", "Legs", "Feet", "Finger", "Trinket", "Mainhand", "Offhand", "OffhandI", "TwoHand", "Ranged" },
}
