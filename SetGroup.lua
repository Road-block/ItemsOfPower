--[[
	### ItemsOfPower ###
	ItemsOfPower SetGroup Class

--]]

-- Libraries
local L = AceLibrary("AceLocale-2.2"):new("ItemsOfPower")
local AceOO = AceLibrary("AceOO-2.0")
local ItemBonusLib = AceLibrary("ItemBonusLib-1.0")

local db

local Group = AceOO.Class()

function Group.LoadSets()
  db = ItemsOfPower:AcquireDBNamespace("Group")

  for SetName in pairs(db.profile) do
    ItemsOfPower:RegisterSet(Group:new(SetName))
  end
end

function Group.prototype:init(Name, Sets)
  Group.super.prototype.init(self)

  if not db.profile[Name] then
    db.profile[Name] = {
      Sets = Sets or { },
    }
  end

  self.Name = Name
  self.Sets = db.profile[Name].Sets

  self.Options = {
    type = "group",
    name = Name,
    desc = string.format(L["Settings for Set \"%s\"."],Name),
    args =
    {
      sets =
      {
        order = 100,
        type = "header",
        name = L["Set Values"],
      },
    },
  }

  ItemsOfPower:RegisterEvent("ItemValue_SetsChanged", function() self:Update() end)
end

function Group.prototype:Update()
  local n = 100

  -- Remove old sets
  for SetName, Options in pairs(self.Options.args) do
    if Options.order > 100 and not ItemsOfPower.SetByName[SetName] then
      self.Options.args[SetName] = nil
      self.Sets[SetName] = nil
    end
  end

  -- Add new sets
  for _, Set in pairs(ItemsOfPower.SetByName) do
    if Set ~= self and not self.Options.args[Set.Name] then
      local get, set = "get-" .. Set.Name, "set-" .. Set.Name
      if not self[get] then
        self[get] = function()
          local _, _, setname = string.find(get, "get%-(.+)")
          return self.Sets[setname] or 0
        end
      end
      if not self[set] then
        self[set] = function(val)
          local _, _, setname = string.find(set, "set%-(.+)")
          val = tonumber(val)
          val = val == 0 and nil or val
          self.Sets[setname] = val
          ItemsOfPower:ClearCache()
        end
      end
      n = n + 1
      self.Options.args[Set.Name] = {
        order = n,
        type = "text",
        name = Set.Name,
        desc = L["Defines the value for this set."],
        get = self[get],
        set = self[set],
        validate = tonumber,
        usage = "<Number>"
      }
    end
  end
end

function Group.prototype:tostring()
  return "ItemsOfPower Group " .. self.Name
end

function Group.prototype:OnDelete()
  db.profile[self.Name] = nil
end

function Group.prototype:GetEquipValue(eq)
  local Points = 0

  if eq then
    for SetName, SetValue in pairs(self.Sets) do
      if ItemsOfPower.SetByName[SetName] then
        Points = Points +(ItemsOfPower.SetByName[SetName]:GetEquipValue(eq) * SetValue)
      end
    end
  end

  return Points
end

function Group.prototype:GetItemValue(ItemString)
  return self:GetEquipValue(ItemBonusLib:ScanItem(ItemString, true))
end

function Group.prototype:Serialize()
  return { Type = "Group", Name = self.Name, Sets = self.Sets }
end

function Group:Deserialize(t)
  return Group:new(t.Name, t.Sets)
end

ItemsOfPower:RegisterSetType("Group", Group)
