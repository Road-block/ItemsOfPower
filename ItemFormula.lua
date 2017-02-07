--[[
	### ItemsOfPower ###
	ItemsOfPower ItemFormula Class

	Thanks to lrdx
--]]

-- Libraries
local L = AceLibrary("AceLocale-2.2"):new("ItemsOfPower")
local AceOO = AceLibrary("AceOO-2.0")
local ItemBonusLib = AceLibrary("ItemBonusLib-1.0")

local db
local Formula = AceOO.Class()

-- Environment of the Formula, stats will be written into it, allows usage of math functions
local IVFD = { math = math }
setmetatable(IVFD, { ["__index"] = function() return 0 end })

function Formula.LoadSets()
  db = ItemsOfPower:AcquireDBNamespace("Formula")

  for SetName in pairs(db.profile) do
    ItemsOfPower:RegisterSet(Formula:new(SetName))
  end
end

function Formula.prototype:init(Name, argFormula)
  Formula.super.prototype.init(self)

  if not db.profile[Name] then
    db.profile[Name] = {
      Formula = argFormula or "",
    }
  end

  self.Name = Name
  self.Formula = db.profile[Name].Formula
  self:UpdatePointsFunc()

  self.Options = {
    type = "group",
    name = Name,
    desc = string.format(L["Settings for Set \"%s\"."],Name),
    args =
    {
      formula =
      {
        order = 100,
        type = "text",
        name = L["Formula"],
        desc = L["Formula"],
        usage = L["<Formula>"],
        get = function() return self.Formula or "" end,
        set = function(v)
          self.Formula = v
          self:UpdatePointsFunc()
          db.profile[Name].Formula = v
          ItemsOfPower:ClearCache()
        end
      },
    },
  }

end

function Formula.prototype:tostring()
  return "ItemsOfPower Formula " .. self.Name
end

function Formula.prototype:OnDelete()
  db.profile[self.Name] = nil
end

function Formula.prototype:UpdatePointsFunc()
  self.CalcPoints = loadstring("return " .. self.Formula)
  setfenv(self.CalcPoints, IVFD)
end

function Formula.prototype:GetEquipValue(eq)
  for k, v in pairs(eq) do
    IVFD[k] = v
  end

  local Points = self:CalcPoints()

  for k in pairs(eq) do
    IVFD[k] = nil
  end

  return Points or 0
end

function Formula.prototype:GetItemValue(ItemString)
  return self:GetEquipValue(ItemBonusLib:ScanItem(ItemString, true))
end

function Formula.prototype:Serialize()
  return { Type = "Formula", Name = self.Name, Formula = self.Formula }
end

function Formula:Deserialize(t)
  return Formula:new(t.Name, t.Formula)
end

ItemsOfPower:RegisterSetType("Formula", Formula)
