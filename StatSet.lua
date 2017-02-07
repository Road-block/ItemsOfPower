--[[
	### ItemsOfPower ###
	ItemsOfPower StatSet Class

--]]

-- Libraries
local L = AceLibrary("AceLocale-2.2"):new("ItemsOfPower")
local AceOO = AceLibrary("AceOO-2.0")
local ItemBonusLib = AceLibrary("ItemBonusLib-1.0")

local db

local ItemBonusLibStats = {
  { "STR", "AGI", "STA", "INT", "SPI", },
  { "ATTACKPOWER", "ATTACKPOWERFERAL", "CRIT", "TOHIT", "RANGEDCRIT", "RANGEDATTACKPOWER" },
  { "DMG", "ARCANEDMG", "FIREDMG", "FROSTDMG", "HOLYDMG", "NATUREDMG", "SHADOWDMG", "SPELLCRIT", "SPELLTOHIT", "SPELLPEN" },
  { "HEAL", "MANAREG" },
  { "ARMOR", "DEFENSE", "BLOCK", "BLOCKVALUE", "DODGE", "PARRY" },
  { "ARCANERES", "FIRERES", "NATURERES", "FROSTRES", "SHADOWRES" },
  { "MANA", "HEALTH", "HEALTHREG", "FISHING", "MINING", "HERBALISM", "SKINNING" },
}

local ItemBonusLibHeaders = {
  L["Base_Stats"],
  L["Physical_DPS"],
  L["Magical_DPS"],
  L["Healing"],
  L["Tanking"],
  L["Resistances"],
  L["Misc"],
}

local StatNames = {
  ATTACKPOWERFERAL = L["Attackpower in Feral Forms"],
  CRIT = L["Crit Rating"],
  TOHIT = L["Hit Rating"],
  RANGEDCRIT = L["Ranged Crit Rating"],
  RANGEDATTACKPOWER = L["Ranged Attackpower"],
  DMG = L["Spelldamage"],
  ARCANEDMG = L["Arcane Spelldamage"],
  FIREDMG = L["Fire Spelldamage"],
  FROSTDMG = L["Frost Spelldamage"],
  HOLYDMG = L["Holy Spelldamage"],
  NATUREDMG = L["Nature Spelldamage"],
  SHADOWDMG = L["Shadow Spelldamage"],
  SPELLCRIT = L["Spell Crit Rating"],
  SPELLTOHIT = L["Spell Hit Rating"],
  SPELLPEN = L["Spell Penetration"],
  HEAL = L["Bonus Healing"],
  MANAREG = L["Mana/5sec"],
  MANA = L["Mana"],
  HEALTHREG = L["Health/5sec"],
  ARMOR = L["Base Armor"],
}

local StatDesc = {

}

local StatSet = AceOO.Class()

function StatSet.LoadSets()
  db = ItemsOfPower:AcquireDBNamespace("StatSet")

  for SetName in pairs(db.profile) do
    ItemsOfPower:RegisterSet(StatSet:new(SetName))
  end
end

function StatSet.prototype:init(Name, Stats)
  StatSet.super.prototype.init(self)

  if not db.profile[Name] then
    db.profile[Name] = {
      Stats = Stats or { },
    }
  end

  self.Name = Name
  self.Stats = db.profile[Name].Stats

  self.Options = {
    type = "group",
    name = Name,
    desc = string.format(L["Settings for Set \"%s\"."],Name),
    args =
    {
      statvalues =
      {
        order = 100,
        type = "header",
        name = L["Stat Values"],
      },
    },
  }

  for h, Stats in pairs(ItemBonusLibStats) do
    local HeaderText = ItemBonusLibHeaders[h]
    self.Options.args[HeaderText] = {
      order = 100 + h,
      type = "group",
      name = HeaderText,
      desc = HeaderText,
      args = { },
    }

    for n, iblname in pairs(Stats) do
      local get, set = "get-" .. iblname, "set-" .. iblname
      if not self[get] then
        self[get] = function()
          local _, _, stat = string.find(get, "get%-(.+)")
          return self.Stats[stat] or 0
        end
      end
      if not self[set] then
        self[set] = function(val)
          local _, _, stat = string.find(set, "set%-(.+)")
          val = tonumber(val)
          val = val == 0 and nil or val
          self.Stats[stat] = val
          ItemsOfPower:ClearCache()
        end
      end
      self.Options.args[HeaderText].args[iblname] = {
        order = n,
        type = "text",
        name = StatNames[iblname] or ItemBonusLib:GetBonusFriendlyName(iblname),
        desc = StatDesc[iblname] or StatNames[iblname] or ItemBonusLib:GetBonusFriendlyName(iblname),
        get = self[get],
        set = self[set],
        validate = tonumber,
        usage = "<Number>",
      }
    end
  end
end

function StatSet.prototype:tostring()
  return "ItemsOfPower StatSet " .. self.Name
end

function StatSet.prototype:OnDelete()
  db.profile[self.Name] = nil
end

function StatSet.prototype:GetEquipValue(eq)
  local Points = 0

  if eq then
    for StatName, StatValue in pairs(self.Stats) do
      if eq[StatName] and StatValue then
        Points = Points +(eq[StatName] * StatValue)
      end
    end
  end

  return Points
end

function StatSet.prototype:GetItemValue(ItemString)
  return self:GetEquipValue(ItemBonusLib:ScanItem(ItemString, true))
end

function StatSet.prototype:Serialize()
  return { Type = "StatSet", Name = self.Name, Stats = self.Stats }
end

function StatSet:Deserialize(t)
  return StatSet:new(t.Name, t.Stats)
end

do
  local validate, reversevalidate = { }, { }
  for h, header in ipairs(ItemBonusLibHeaders) do
    table.insert(validate, header)
    reversevalidate[header] = h
  end
  table.insert(validate, "Operators")
  table.insert(validate, "Math")
  table.insert(validate, "Example")

  local function FormulaHelp(cat)
    local help_text = ""
    if cat == "Operators" then
      help_text = "Arithmetic Operators and Parentheses: + - * / ^ ( )"
    elseif cat == "Math" then
      help_text = "Math Library methods:"
      for k, v in pairs(math) do
        help_text = help_text .. " math." .. tostring(k)
      end
    elseif cat == "Example" then
      help_text = "Example Formula: AGI*2+STR*1-(math.mod(60,7)+CRIT^2)"
    else
      help_text = string.format("ItemBonus %s Tokens: ", cat)
      for _, token in ipairs(ItemBonusLibStats[reversevalidate[cat]]) do
        help_text = help_text .. " " .. token
      end
    end
    ItemsOfPower:Print(help_text)
  end

  ItemsOfPower.Options.args.Tools.args.FormulaHelp = {
    order = 400,
    type = "text",
    name = L["Formula Help"],
    desc = L["Formula Syntax Help and Tokens"],
    get = false,
    set = function(cat) FormulaHelp(cat) end,
    validate = validate,
  }
end

ItemsOfPower:RegisterSetType("StatSet", StatSet)
