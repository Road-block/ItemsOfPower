--[[
    ### ItemsOfPower ###
    ItemsOfPower FullEquipmentFormula Class

    Thanks to lrdx
--]]

-- Libraries
local L = AceLibrary("AceLocale-2.2"):new("ItemsOfPower")
local AceOO = AceLibrary("AceOO-2.0")
local ItemBonusLib = AceLibrary("ItemBonusLib-1.0")

local db
local FullEquipmentFormula = AceOO.Class()

-- Environment of the Formula, stats will be written into it, allows usage of math functions
local IVFD = { math = math }
setmetatable(IVFD, { ["__index"] = function() return 0 end })

function FullEquipmentFormula.LoadSets()
  db = ItemsOfPower:AcquireDBNamespace("FullEquipmentFormula")

  for SetName in pairs(db.profile) do
    ItemsOfPower:RegisterSet(FullEquipmentFormula:new(SetName))
  end
end

function FullEquipmentFormula.prototype:init(Name, argFormula, argBaseEquipment)
  FullEquipmentFormula.super.prototype.init(self)

  if not db.profile[Name] then
    db.profile[Name] = {
      Formula = argFormula or "",
      BaseEquipment = argBaseEquipment or ItemBonusLib:GetUnitEquipment("player"),
    }
  end

  self.Name = Name
  self.Formula = db.profile[Name].Formula
  self:UpdatePointsFunc()
  self.BaseEquipment = db.profile[Name].BaseEquipment

  self.Options = {
    type = "group",
    name = Name,
    desc = string.format(L["Settings for Set \"%s\"."],Name),
    args =
    {
      Formula =
      {
        order = 100,
        type = "text",
        name = L["Formula"],
        desc = L["A formula using stat values of the full equipment."],
        usage = L["<Formula>"],
        get = function() return self.Formula or "" end,
        set = function(v)
          self.Formula = v
          self:UpdatePointsFunc()
          db.profile[Name].Formula = v
          ItemsOfPower:ClearCache()
        end
      },
      ParseEquipment =
      {
        order = 200,
        type = "execute",
        name = L["Use current equipment"],
        desc = L["Sets the current equipment as base for calculations."],
        func = function()
          -- copy the table, because it gets recycled
          local currentEquipment = { }
          local eq = ItemBonusLib:GetUnitEquipment("player")
          for k, v in pairs(eq) do
            currentEquipment[k] = v
          end
          self.BaseEquipment = currentEquipment
          db.profile[Name].BaseEquipment = currentEquipment
          ItemsOfPower:ClearCache()
        end
      }
    }
  }

end

function FullEquipmentFormula.prototype:tostring()
  return "ItemsOfPower FullEquipmentFormula " .. self.Name
end

function FullEquipmentFormula.prototype:OnDelete()
  db.profile[self.Name] = nil
end

function FullEquipmentFormula.prototype:UpdatePointsFunc()
  self.CalcPoints = loadstring("return " .. self.Formula)
  setfenv(self.CalcPoints, IVFD)
end

function FullEquipmentFormula.prototype:GetEquipValue(eq)
  for k, v in pairs(eq) do
    IVFD[k] = v
  end

  local Points = self:CalcPoints()

  for k in pairs(eq) do
    IVFD[k] = nil
  end

  return Points or 0
end

local ItemType2EquipLoc = {
  ["INVTYPE_AMMO"] = "Ammo",
  ["INVTYPE_HEAD"] = "Head",
  ["INVTYPE_NECK"] = "Neck",
  ["INVTYPE_SHOULDER"] = "Shoulder",
  ["INVTYPE_BODY"] = "Shirt",
  ["INVTYPE_CHEST"] = "Chest",
  ["INVTYPE_ROBE"] = "Chest",
  ["INVTYPE_WAIST"] = "Waist",
  ["INVTYPE_LEGS"] = "Legs",
  ["INVTYPE_FEET"] = "Feet",
  ["INVTYPE_HAND"] = "Hands",
  ["INVTYPE_FINGER"] = "Finger0",
  ["INVTYPE_TRINKET"] = "Trinket0",
  ["INVTYPE_CLOAK"] = "Back",
  ["INVTYPE_WEAPON"] = "MainHand",
  ["INVTYPE_SHIELD"] = "SecondaryHand",
  ["INVTYPE_2HWEAPON"] = "MainHand",
  ["INVTYPE_WEAPONMAINHAND"] = "MainHand",
  ["INVTYPE_WEAPONOFFHAND"] = "SecondaryHand",
  ["INVTYPE_HOLDABLE"] = "SecondaryHand",
  ["INVTYPE_RANGED"] = "Ranged",
  ["INVTYPE_THROWN"] = "Ranged",
  ["INVTYPE_RANGEDRIGHT"] = "Ranged",
  ["INVTYPE_RELIC"] = "Ranged",
  ["INVTYPE_TABARD"] = "Tabard",
}

function FullEquipmentFormula.prototype:GetItemValue(newItemString)
  local _, newItemLink, _, _, _, _, _, newItemType, _ = GetItemInfo(newItemString)
  local newItemEquipLoc = ItemType2EquipLoc[newItemType]

  if newItemEquipLoc and self.BaseEquipment and type(self.BaseEquipment) == "table" then
    -- Replace item and switch old item back in after calculation
    local oldItem = self.BaseEquipment[newItemEquipLoc]
    self.BaseEquipment[newItemEquipLoc] = newItemLink

    local value = self:GetEquipValue(ItemBonusLib:MergeDetails(ItemBonusLib:BuildBonusSet(self.BaseEquipment)))

    self.BaseEquipment[newItemEquipLoc] = oldItem
    return value
  else
    -- behavior like the normal formula if the item isnt equipable or no equipment set
    return self:GetEquipValue(ItemBonusLib:ScanItem(newItemString, true))
  end
end

function FullEquipmentFormula.prototype:Serialize()
  return {
    Type = "FullEquipmentFormula",
    Name = self.Name,
    Formula = self.Formula,
    BaseEquipment = self.BaseEquipment,
  }
end

function FullEquipmentFormula:Deserialize(t)
  return FullEquipmentFormula:new(t.Name, t.Formula, t.BaseEquipment)
end

ItemsOfPower:RegisterSetType("FullEquipmentFormula", FullEquipmentFormula)
