--[[
	### ItemsOfPower ###
	ItemsOfPower Core

	Used Libraries:
	Ace2, GratuityLib, Deformat, ItemBonusLib
--]]

ItemsOfPower = AceLibrary("AceAddon-2.0"):new("AceEvent-2.0", "AceConsole-2.0", "AceHook-2.1", "AceDB-2.0", "AceDebug-2.0", "AceComm-2.0", "FuBarPlugin-2.0")
ItemsOfPower.revision = tonumber(string.sub("$Revision: 101 $", 12, -3))
ItemsOfPower.version = "r" .. ItemsOfPower.revision
ItemsOfPower.date = string.sub("$Date: 2017-01-22 17:23:20 -0400 (Sun, 22 Jan 2017) $", 8, 17)

-- Libraries
local L = AceLibrary("AceLocale-2.2"):new("ItemsOfPower")
local R = setmetatable( { }, { ["__index"] = function(t) L:GetReverseTranslation(t) end })

local AceOO = AceLibrary("AceOO-2.0")
local Gratuity = AceLibrary("Gratuity-2.0")
local Tablet = AceLibrary("Tablet-2.0")
local Dewdrop = AceLibrary("Dewdrop-2.0")
local ItemBonusLib = AceLibrary("ItemBonusLib-1.0")

local self = ItemsOfPower
local tnew, tdel, tnewHash, tddel, tcnt
do
  local list = setmetatable( { }, { __mode = 'k' })
  function tnew(...)
    local t = next(list)
    if t then
      list[t] = nil
      for i = 1, ItemsOfPower:select('#', unpack(arg)) do
        t[i] = ItemsOfPower:select(i, unpack(arg))
      end
      return t
    else
      return { unpack(arg) }
    end
  end

  function tnewHash(...)
    local t = next(list)
    if t then
      list[t] = nil
    else
      t = { }
    end
    for i = 1, ItemsOfPower:select('#', unpack(arg)), 2 do
      t[ItemsOfPower:select(i, unpack(arg))] = ItemsOfPower:select(i + 1, unpack(arg))
    end
    return t
  end

  function tdel(t)
    for k in pairs(t) do
      t[k] = nil
    end
    list[t] = true
    return nil
  end

  function tddel(t)
    if type(t) ~= "table" then
      return nil
    end
    for k, v in pairs(t) do
      t[k] = tddel(v)
    end
    return tdel(t)
  end

  function tcnt(t)
    if (type(t)) ~= "table" then return nil end
    local count = 0
    for _, _ in pairs(t) do
      count = count + 1
    end
    return count
  end
end
self.tnew, self.tdel, self.tddel, self.tnewHash, self.tcnt = tnew, tdel, tddel, tnewHash, tcnt

-- Table for Sets
local SetByName = { }
self.SetByName = SetByName
local SetById = { }
self.SetById = SetById

-- Table for SetTypes
local SetTypes = { }
self.SetTypes = SetTypes

local PlayerValueFrame
local InspectValueFrame
local TooltipTextCache
local TooltipTextCache2

-- AceOptions Table
local Options = {
  type = "group",
  args =
  {
    header =
    {
      order = 1,
      type = "header",
      name = "|cFF77BBFF" .. "ItemsOfPower" .. " |c88888888" .. self.version,
      icon = "Interface\\Icons\\INV_Misc_QirajiCrystal_05",
      iconHeight = 24,
      iconWidth = 24,
    },
    Sets =
    {
      order = 2,
      type = "group",
      name = L["Sets"],
      desc = L["Configuration of ItemsOfPower Sets."],
      args =
      {
        New =
        {
          order = 1,
          type = "group",
          name = L["New"],
          desc = L["Creates new Sets."],
          args = { },
        },
      },
    },
    Settings =
    {
      type = "group",
      name = L["Settings"],
      desc = L["General settings about ItemsOfPower."],
      args =
      {
        Modifications =
        {
          order = 1,
          type = "group",
          name = L["Item Modifications"],
          desc = L["How enchants should be handled."],
          args =
          {
            Enchants =
            {
              order = 1,
              type = "text",
              name = L["Enchants"],
              desc = L["Defines if item enchants should be included in the calculation."],
              get = function() return self.db.profile.Modifications.Enchants end,
              set = function(v) self.db.profile.Modifications.Enchants = v self:ClearCache() end,
              validate = { L["Ignore"], L["Do nothing"], L["Always own"], L["Fill with own"] },
            },
          },
        },
        Tooltip =
        {
          order = 2,
          type = "group",
          name = L["Tooltip"],
          desc = L["Tooltip Display Settings"],
          args =
          {
            Enable =
            {
              order = 1,
              type = "toggle",
              name = L["Enable"],
              desc = L["Enables ALL tooltip display."],
              get = function() return self.db.profile.Tooltip.Enable end,
              set = function(v)
                self.db.profile.Tooltip.Enable = v
                if v then
                  self:TipHook()
                else
                  self:TipUnhook()
                end
                self:ClearCache()
              end,
            },
            ShowPoints =
            {
              order = 2,
              type = "toggle",
              name = L["Show Points"],
              desc = L["Shows the Setpoints of an item in its tooltip."],
              get = function() return self.db.profile.Tooltip.ShowPoints end,
              set = function(v) self.db.profile.Tooltip.ShowPoints = v self:ClearCache() end,
            },
            Compare =
            {
              order = 3,
              type = "text",
              name = L["Compare"],
              desc = L["If and how informations of other equipped items should be displayed."],
              get = function() return self.db.profile.Tooltip.Compare end,
              set = function(v) self.db.profile.Tooltip.Compare = v self:ClearCache() end,
              validate = { L["Don't Compare"], L["Absolute"], L["Delta"], L["Percent"] },
            },
            SwapColor =
            {
              order = 4,
              type = "toggle",
              name = L["Swap Colors"],
              desc = L["Swap the comparison colors?"],
              get = function() return self.db.profile.Tooltip.SwapColors end,
              set = function(v) self.db.profile.Tooltip.SwapColors = v self:ClearCache() end,
            },
            SwapComparison =
            {
              order = 4,
              type = "toggle",
              name = L["Swap Comparison"],
              desc = L["Swap the comparison (+5 becomes -5)?"],
              get = function() return self.db.profile.Tooltip.SwapComparison end,
              set = function(v) self.db.profile.Tooltip.SwapComparison = v self:ClearCache() end,
            },
            RightSide =
            {
              order = 5,
              type = "toggle",
              name = L["Right Side"],
              desc = L["Displays item values on the right side."],
              get = function() return self.db.profile.Tooltip.RightSide end,
              set = function(v) self.db.profile.Tooltip.RightSide = v self:ClearCache() end,
            },
          },
        },
        EQValue =
        {
          order = 3,
          type = "group",
          name = L["Player Equip Value"],
          desc = L["All ItemValues of a player"],
          args =
          {
            self =
            {
              order = 1,
              type = "group",
              name = "Self",
              desc = "Own equipment value",
              args =
              {
                enabled =
                {
                  order = 2,
                  type = "toggle",
                  name = L["Enabled"],
                  desc = L["Shows own equipment value in the charsheet."],
                  get = function() return self.db.profile.PlayerValue.Self.Enabled end,
                  set = function(v)
                    self.db.profile.PlayerValue.Self.Enabled = v
                    if v then
                      if not PlayerValueFrame then self:CreatePlayerValueFrame() end
                      PlayerValueFrame:Show()
                    else
                      if PlayerValueFrame then PlayerValueFrame:Hide() end
                    end
                    self:ClearCache()
                  end,
                },
              }
            },
            Inspect =
            {
              order = 2,
              type = "group",
              name = "Inspect",
              desc = "Inspect equipment value",
              args =
              {
                Enabled =
                {
                  order = 1,
                  type = "toggle",
                  name = L["Enabled"],
                  desc = L["Print out targets Equipment Value while inspecting."],
                  get = function() return self.db.profile.PlayerValue.Inspect.Enabled end,
                  set = function(v)
                    self.db.profile.PlayerValue.Inspect.Enabled = v
                    if v then
                      if not InspectValueFrame then
                        self:CreateInspectValueFrame()
                      else
                        InspectValueFrame:Show()
                        self:UpdateInspectValueFrame()
                      end
                    else
                      if InspectValueFrame then InspectValueFrame:Hide() end
                    end
                  end,
                },
                ShowPoints =
                {
                  order = 2,
                  type = "toggle",
                  name = L["Show Points"],
                  desc = L["Shows the equipment value of a player."],
                  get = function() return self.db.profile.PlayerValue.Inspect.ShowPoints end,
                  set = function(v) self.db.profile.PlayerValue.Inspect.ShowPoints = v self:ClearCache() self:UpdateInspectValueFrame(true) end,
                  disabled = function() return not(self.db.profile.PlayerValue.Inspect.Enabled) end,
                },
                Compare =
                {
                  order = 3,
                  type = "text",
                  name = L["Compare Mode"],
                  desc = L["How your equipment points should be compared to your targets."],
                  get = function() return self.db.profile.PlayerValue.Inspect.Compare end,
                  set = function(v) self.db.profile.PlayerValue.Inspect.Compare = v self:ClearCache() self:UpdateInspectValueFrame(true) end,
                  validate = { L["Don't Compare"], L["Absolute"], L["Delta"], L["Percent"] },
                  disabled = function() return not(self.db.profile.PlayerValue.Inspect.Enabled) end,
                },
                SwapColor =
                {
                  order = 4,
                  type = "toggle",
                  name = L["Swap Colors"],
                  desc = L["Swap the comparison colors?"],
                  get = function() return self.db.profile.PlayerValue.Inspect.SwapColors end,
                  set = function(v) self.db.profile.PlayerValue.Inspect.SwapColors = v self:ClearCache() self:UpdateInspectValueFrame(true) end,
                  disabled = function() return not(self.db.profile.PlayerValue.Inspect.Enabled) end,
                },
                SwapComparison =
                {
                  order = 5,
                  type = "toggle",
                  name = L["Swap Comparison"],
                  desc = L["Swap the comparison (+5 becomes -5)?"],
                  get = function() return self.db.profile.PlayerValue.Inspect.SwapComparison end,
                  set = function(v) self.db.profile.PlayerValue.Inspect.SwapComparison = v self:ClearCache() self:UpdateInspectValueFrame(true) end,
                  disabled = function() return not(self.db.profile.PlayerValue.Inspect.Enabled) end,
                },
              },
            },
          },
        },
        Sorting =
        {
          order = 4,
          type = "group",
          name = L["Sorting"],
          desc = L["Settings about custom Set ordering."],
          args =
          {
            Enable =
            {
              order = 1,
              type = "toggle",
              name = L["Enable"],
              desc = L["Enables or disables custom sorting of Sets."],
              set = function(v)
                if v then
                  self.db.profile.SetIds = { }
                  for SetId, Set in pairs(SetById) do
                    self.db.profile.SetIds[Set.Name] = SetId
                  end
                  self:UpdateSorting()
                  self:ClearCache()
                else
                  if self.db.profile.SetIds and type(self.db.profile.SetIds) == "table" then
                    self.db.profile.SetIds = tdel(self.db.profile.SetIds)
                  end
                end
              end,
              get = function() return self.db.profile.SetIds and type(self.db.profile.SetIds) == "table" end,
            },
          },
        },
      },
    },
    Tools =
    {
      type = "group",
      name = L["Tools"],
      desc = L["Tools"],
      args = { },
    },
  },
}
self.Options = Options

local DefaultSettings = {
  Tooltip =
  {
    Enable = true,
    RightSide = false,
    ShowPoints = true,
    Compare = L["Absolute"],
    SwapColors = false,
    SwapComparison = false,
  },
  Modifications =
  {
    Enchants = L["Always own"],
  },
  PlayerValue =
  {
    Self =
    {
      Enabled = false,
      FrameHeight = 105,
      FrameWidth = 200,
      FrameBackgroundColor = { 0, 0, 0, 0.3 },
      BorderColor = { 1, 1, 1, 1 },
    },
    Inspect =
    {
      Enabled = false,
      ShowPoints = true,
      Compare = L["Absolute"],
      SwapColors = false,
      SwapComparison = false,
      FrameHeight = 105,
      FrameWidth = 173,
      FrameBackgroundColor = { 0, 0, 0, 0.3 },
      BorderColor = { 1, 1, 1, 1 },
    },
  },
  DisplayInTooltip =
  {
    ["*"] = true,
  },
  Round =
  {
    ["*"] = 1,
  },
  Color =
  {
    ["*"] = { r = 1.0, g = 1.0, b = 1.0 },
  },
  -- SetIds = nil,
}

function ItemsOfPower:OnInitialize()
  self:RegisterDB("ItemsOfPowerDB", "ItemsOfPowerDBPerChar")
  self:RegisterDefaults("profile", DefaultSettings)
  self:SetCommPrefix("ItemsOfPower")
  self:RegisterComm("ItemsOfPower", "WHISPER")

  TooltipTextCache = setmetatable( { }, { __mode = "kv" })
  TooltipTextCache2 = setmetatable( { }, { __mode = "kv" })

  self:RegisterChatCommand( { "/ipw", "/itempower" }, Options)

  -- FuBar
  self.hasIcon = true
  self.hasNoText = false
  self.defaultPosition = "RIGHT"
  self.cannotDetachTooltip = true
  self.overrideMenu = true
  self.independentProfile = true
  self.hideWithoutStandby = true
  self.hideMenuTitle = true
  self.blizzardTooltip = true

  self:SetIcon("Interface\\Icons\\INV_Misc_QirajiCrystal_05")

  self.OnMenuRequest = Options

  function self:OnDataUpdate()
    self:UpdateText()
  end

  function self:OnTextUpdate()
    self:SetText("ItemsOfPower")
  end

  function self:OnClick()
    -- Waterfall:Open("ItemsOfPower")
  end

  function self:OnTooltipUpdate()
    Tablet:SetHint("|cffffff00Right-Click|r to change settings via Dewdrop.")
  end
end

local first = true
function ItemsOfPower:OnEnable()
  if first then
    first = false

    -- Load sets
    for _, SetClass in pairs(SetTypes) do
      SetClass.LoadSets()
    end

    self:ClearCache()
  end

  if self.db.profile.Tooltip.Enable then
    self:TipHook(self.AddDataToTooltip, "item")
  end

  if self.db.profile.PlayerValue.Self.Enabled and not PlayerValueFrame then
    self:CreatePlayerValueFrame()
  end

  if self.db.profile.PlayerValue.Inspect.Enabled then
    self:CreateInspectValueFrame()
  end

  self:RegisterEvent("ItemBonusLib_Update", "UpdatePlayerEquipment")
end

function ItemsOfPower:OnDisable()
  self:TipUnhook()
  if PlayerValueFrame then PlayerValueFrame:Hide() end
  if InspectValueFrame then InspectValueFrame:Hide() end
end

function ItemsOfPower:ClearCache()
  for key in pairs(TooltipTextCache) do
    TooltipTextCache[key] = nil
  end
  for key in pairs(TooltipTextCache2) do
    TooltipTextCache2[key] = nil
  end

  self:UpdatePlayerValueFrame()
end


--[[
#############################
--    EQ Value Frames
--############################
--]]

function ItemsOfPower:CreatePlayerValueFrame()
  if PlayerValueFrame then return end
  local frame = CreateFrame("Frame", "ItemValuePlayerValueFrame", CharacterModelFrame)
  frame:SetFrameStrata("HIGH")
  frame:SetWidth(200)
  frame:SetHeight(100)

  local text = frame:CreateFontString("ItemValuePlayerValueFrameFontstring", "HIGH")
  text:SetFontObject(GameFontHighlight)
  text:SetFont(text:GetFont(), 12)
  text:SetJustifyH("LEFT")
  text:SetJustifyV("BOTTOM")

  text:SetPoint("TOPLEFT", frame, 5, 5)
  text:SetPoint("TOPRIGHT", frame, 5, 5)
  text:SetPoint("BOTTOMRIGHT", frame, 5, 5)
  text:SetPoint("BOTTOMLEFT", frame, 5, 5)

  text:SetText("")

  frame.text = text

  frame:SetBackdrop( {
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    tile = false,
    tileSize = 0,
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    edgeSize = 10,
    insets = { left = 2, right = 2, top = 2, bottom = 2 },
  } )
  frame:SetBackdropColor(0, 0, 0, 0.3)

  frame:EnableMouse(true)
  frame:SetPoint("BOTTOMLEFT", 2, 30)

  PlayerValueFrame = frame
  self.PlayerValueFrame = frame

  Dewdrop:Register(frame, "children", Options.args.Settings.args.EQValue.args.self)

  -- self:UpdatePlayerEquipment()
  frame:Show()
end

function ItemsOfPower:UpdatePlayerEquipment()
  self.EquipStats = self:GetUnitEquipment("player")

  self:ClearCache()
end

function ItemsOfPower:UpdatePlayerValueFrame()
  if not(PlayerValueFrame) then return end
  local PlayerValueStringTable = { }

  for SetId, Set in pairs(SetById) do
    if self.db.profile.DisplayInTooltip[Set.Name] then
      local points = floor(Set:GetEquipValue(self.EquipStats))
      local colorName = ItemsOfPower:ColorText(Set.Name, self.db.profile.Color[Set.Name])
      table.insert(PlayerValueStringTable, colorName .. ": " .. points)
    end
  end

  local PlayerValueString = table.concat(PlayerValueStringTable, "\n")
  tdel(PlayerValueStringTable)

  PlayerValueFrame.text:SetText(PlayerValueString)
end

function ItemsOfPower:CreateInspectValueFrame()
  if InspectValueFrame then return end
  if not InspectPaperDollFrame then InspectFrame_LoadUI() end

  local frame = CreateFrame("Frame", "ItemValueInspectValueFrame", InspectPaperDollFrame)
  frame:SetFrameStrata("HIGH")
  frame:SetWidth(173)
  frame:SetHeight(105)

  local text = frame:CreateFontString("ItemValueInspectValueFrameFontstring", "HIGH")
  text:SetFontObject(GameFontHighlight)
  text:SetFont(text:GetFont(), 12)
  text:SetJustifyH("LEFT")
  text:SetJustifyV("BOTTOM")

  text:SetPoint("TOPLEFT", frame, 5, 5)
  text:SetPoint("TOPRIGHT", frame, 5, 5)
  text:SetPoint("BOTTOMRIGHT", frame, 5, 5)
  text:SetPoint("BOTTOMLEFT", frame, 5, 5)
  text:SetText("")
  frame.text = text

  frame:SetBackdrop( {
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    tile = false,
    tileSize = 0,
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    edgeSize = 10,
    insets = { left = 2, right = 2, top = 2, bottom = 2 },
  } )
  frame:SetBackdropColor(0, 0, 0, 0.3)
  frame:EnableMouse(true)

  frame:SetPoint("BOTTOMLEFT", 75, 140)

  InspectValueFrame = frame
  self.InspectValueFrame = frame

  Dewdrop:Register(frame, "children", Options.args.Settings.args.EQValue.args.inspect)

  frame:SetScript("OnUpdate", self.UpdateInspectValueFrame)
  frame:Show()
end

do
  -- ItemsOfPower:UpdateInspectValueFrame(force)
  local OldInspectName

  function ItemsOfPower:UpdateInspectValueFrame(force)
    if not(InspectValueFrame and InspectPaperDollFrame:IsVisible()) then return end
    local InspectName = UnitName(InspectFrame.unit)
    if (not force) and(InspectName == OldInspectName) or not InspectName then return end
    OldInspectName = InspectName

    local UnitEquip = ItemsOfPower:GetInspectEquipment()

    ItemsOfPower:Debug("UpdateInspectValueFrame")

    local InspectValueStringTable = { }

    for SetId, Set in pairs(SetById) do
      if ItemsOfPower.db.profile.DisplayInTooltip[Set.Name] then
        local ownpoints = floor(Set:GetEquipValue(ItemsOfPower.EquipStats))
        local unitpoints = floor(Set:GetEquipValue(UnitEquip))
        if unitpoints then
          table.insert(InspectValueStringTable, Set.Name .. ": " ..
          ItemsOfPower:Compare(
          ItemsOfPower.db.profile.PlayerValue.Inspect.Compare,
          ItemsOfPower.db.profile.PlayerValue.Inspect.ShowPoints,
          ItemsOfPower.db.profile.PlayerValue.Inspect.SwapColors,
          ItemsOfPower.db.profile.PlayerValue.Inspect.SwapComparison,
          unitpoints, ownpoints)
          )
        end
      end
    end

    local InspectValueString = table.concat(InspectValueStringTable, "\n")

    InspectValueFrame.text:SetText(InspectValueString)

    tdel(InspectValueStringTable)
  end
end


--[[
#############################
--    Set Handling
--############################
--]]

do
  -- ItemsOfPower:RegisterSet(Set)
  local validname = function(v) return v and strlen(v) >= 3 and not strfind(v, "[%s%.]+") end

  function ItemsOfPower:RegisterSet(Set)
    local SetName = Set.Name
    if SetByName[SetName] then
      self:Print(string.format(L["Error: Set |cffffff78%s|r already exists!"], SetName))
      return
    end

    if not Set.Options.args.Name then
      Set.Options.args.Name = {
        order = 1,
        type = "text",
        name = L["Name"],
        desc = L["Renames the Set."],
        set = function(v) self:RenameSet(Set, v) end,
        get = function() return Set.Name end,
        usage = "<New_Name>",
        validate = validname
      }
    end
    if not Set.Options.args.DisplayInTooltip then
      Set.Options.args.DisplayInTooltip = {
        order = 2,
        type = "toggle",
        name = L["Display In Tooltip"],
        desc = L["Defines if the item value for this set should be displayed in item tooltips."],
        set = function(v)
          self.db.profile.DisplayInTooltip[SetName] = not not v
          self:ClearCache()
        end,
        get = function() return self.db.profile.DisplayInTooltip[SetName] end
      }
    end

    if not Set.Options.args.Delete then
      Set.Options.args.Delete = {
        type = "execute",
        order = 3,
        name = "Delete",
        desc = "Deletes this Set.",
        func = function(v) self:UnregisterSet(Set) end,
        passValue = Set
      }
    end

    if not Set.Options.args.Round then
      Set.Options.args.Round = {
        type = "range",
        order = 4,
        name = L["Round"],
        desc = L["Round"],
        min = - 5,
        max = 5,
        step = 1,
        set = function(v)
          self.db.profile.Round[SetName] = floor(v)
          self:ClearCache()
        end,
        get = function() return self.db.profile.Round[SetName] end
      }
    end

    if not Set.Options.args.Send then
      Set.Options.args.Send = {
        type = "text",
        order = 5,
        name = L["Send To"],
        desc = L["Sends this Set to another ItemsOfPower user."],
        usage = "<Player Name>",
        set = function(v) self:SendStatSet(Set, v) end,
        get = false,
        validate = validname
      }
    end

    if not Set.Options.args.Color then
      Set.Options.args.Color = {
        type = "color",
        order = 6,
        name = L["Colorize"],
        desc = L["Colorize the text of this ItemsOfPower set."],
        get = function()
          local c = self.db.profile.Color[SetName]
          return c.r, c.g, c.b
        end,
        set = function(r, g, b)
          self.db.profile.Color[SetName] = { r = r, g = g, b = b }
        end,
        hasAlpha = false,
      }
    end

    Options.args.Sets.args[SetName] = Set.Options

    SetByName[SetName] = Set
    if self.db.profile.SetIds and self.db.profile.SetIds[SetName] then
      local id = self.db.profile.SetIds[SetName]
      if not SetById[id] then
        SetById[id] = Set
        Set.Id = id
      end
    else
      table.insert(SetById, Set)
      Set.Id = table.getn(SetById)
    end

    self:ClearCache()
    self:UpdateSorting()
    self:TriggerEvent("ItemValue_SetsChanged")
  end
end

function ItemsOfPower:SwapSets(Set1, Set2)
  SetById[Set1.Id] = nil
  SetById[Set2.Id] = nil

  SetById[Set2.Id] = SetByName[Set1.Name]
  SetById[Set1.Id] = SetByName[Set2.Name]

  Set1.Id, Set2.Id = Set2.Id, Set1.Id
  self.db.profile.SetIds[Set1.Name] = Set1.Id
  self.db.profile.SetIds[Set2.Name] = Set2.Id

  self:ClearCache()
  self:UpdateSorting()
  self:TriggerEvent("ItemValue_SetsChanged")
end

function ItemsOfPower:UnregisterSet(Set)

  local SetName = Set.Name
  if not SetByName[SetName] then
    return string.format(L["Error: Set \"%s\" doesn't exist!"], SetName)
  end

  Set:OnDelete()
  Options.args.Sets.args[SetName] = nil

  SetByName[SetName] = nil

  for i = Set.Id, table.getn(SetById) -1 do
    SetById[i] = SetById[i + 1]
    SetById[i].Id = SetById[i].Id - 1
  end
  SetById[table.getn(SetById)] = nil

  self.db.profile.DisplayInTooltip[SetName] = nil
  self.db.profile.Round[SetName] = nil
  self.db.profile.Color[SetName] = nil
  if self.db.profile.SetIds and self.db.profile.SetIds[SetName] then self.db.profile.SetIds[SetName] = nil end

  self:ClearCache()
  self:UpdateSorting()
  self:TriggerEvent("ItemValue_SetsChanged")
  Dewdrop:Close(1)
end

function ItemsOfPower:RenameSet(OldSet, NewName)
  -- Serializes old set, changes the name and deserializes to a new object
  assert(OldSet)
  assert(not SetByName[NewName])

  local t = OldSet:Serialize()
  t.Name = NewName
  local NewSet = SetTypes[t.Type]:Deserialize(t)
  assert(NewSet)

  self:RegisterSet(NewSet)
  self:UnregisterSet(OldSet)
end

function ItemsOfPower:RegisterSetType(SetClassName, SetClass)
  assert(SetClass)
  assert(SetClassName)

  SetTypes[SetClassName] = SetClass
  Options.args.Sets.args.New.args[SetClassName] = {
    type = "text",
    name = string.format(L["New %s"],SetClassName),
    desc = string.format(L["Creates a new %s."],SetClassName),
    usage = L["<Name>"],
    get = false,
    set = function(name)
      self:Print(string.format(L["Creating new |cffffff78%s|r: |cffffff78%s|r..."], SetClassName, name))
      self:RegisterSet(SetClass:new(name))
      self:ClearCache()
    end,
    validate = function(v)
      return v and type(v) == "string" and strlen(v) >= 3 and not strfind(v, "[%s%.]+")
    end,
  }

  if db then
    SetClass.LoadSets()
  end
end

local function MoveSet(Set)
  local TargetSet
  if IsShiftKeyDown() then
    TargetSet = SetById[Set.Id + 1]
  else
    TargetSet = SetById[Set.Id - 1]
  end

  if not TargetSet or TargetSet == Set then return end

  ItemsOfPower:SwapSets(Set, TargetSet)
end

do
  -- ItemsOfPower:UpdateSorting()
  local hiddenf = function() return not self.db.profile.SetIds end

  function ItemsOfPower:UpdateSorting()
    if not self.db.profile.SetIds then return end

    local n = 100

    -- Remove old sets
    for i, SetOptions in pairs(Options.args.Settings.args.Sorting.args) do
      if SetOptions.order >= n and not SetByName[SetOptions.passValue.Name] then
        Options.args.Settings.args.Sorting.args[i] = nil
      end
    end

    for SetId, Set in pairs(SetById) do
      if Options.args.Settings.args.Sorting.args[Set.Name] then
        -- Update order
        Options.args.Settings.args.Sorting.args[Set.Name].order = n + SetId
        Options.args.Settings.args.Sorting.args[Set.Name].name = SetId .. ". " .. Set.Name
      else
        -- Add new sets
        Options.args.Settings.args.Sorting.args[Set.Name] = {
          order = n + Set.Id,
          type = "execute",
          name = SetId .. ". " .. Set.Name,
          desc = L["Moves the Set one place up (or down if <SHIFT> key is held)"],
          func = MoveSet,
          passValue = Set,
          hidden = hiddenf
        }
      end
    end
  end
end

-- Set Sharing
function ItemsOfPower:SendStatSet(Set, PlayerName)
  self:Print(string.format(L["Sending Set |cffffff78%s|r to player |cffffff78%s|r..."], Set.Name, PlayerName))
  self:SendCommMessage("WHISPER", PlayerName, Set:Serialize())
end

function ItemsOfPower:OnCommReceive(prefix, sender, distribution, t)
  assert(t and type(t) == "table", "Set invalid.")
  assert(t.Name and type(t.Name) == "string", "Name invalid.")
  assert(t.Type and type(t.Type) == "string", "Type invalid.")
  assert(SetTypes[t.Type], t.Type .. " Type unknown.")

  local SetType = t.Type
  self:Print(string.format(L["Received |cffffff78%s|r named |cffffff78%s|r from player |cffffff78%s|r."], SetType, t.Name, sender))
  StaticPopupDialogs["ITEMVALUE_NEW_SET_RECEIVED"].text = string.format(L["Received |cffffff78%s|r named |cffffff78%s|r from player |cffffff78%s|r."], SetType, t.Name, sender)
  t.Name = t.Name .. " - " .. sender

  local Set = SetTypes[SetType]:Deserialize(t)
  if not Set then self:Print(string.format(L["Error: Couldn't Deserialize |cffffff78%s|r!"], SetType)) return end

  StaticPopupDialogs["ITEMVALUE_NEW_SET_RECEIVED"].OnAccept = function()
    self:RegisterSet(Set)
  end

  StaticPopup_Show("ITEMVALUE_NEW_SET_RECEIVED")
end

StaticPopupDialogs["ITEMVALUE_NEW_SET_RECEIVED"] = {
  text = "",
  button1 = L["Accept"],
  button2 = L["Decline"],
  timeout = 0,
  hideOnEscape = 1,
  OnDecline = function()
    StaticPopupDialogs["ITEMVALUE_NEW_SET_RECEIVED"].OnAccept = nil
  end
}


--[[
#############################
--    Utility functions
--############################
--]]

local function round(num, idp)
  local mult = 10 ^(idp or 0)
  return math.floor(num * mult + 0.5) / mult
end

do
  -- ItemsOfPower:Compare(CompMode, ShowBase, ReverseColor, SwapComparison, ...)
  local cBetter = "|cFF00FF00"
  local cWorse = "|cFFFF0000"
  local cEqual = "|cFFFFFF00"

  local function Color(reverse, b, v)
    if reverse then
      if (b > v) then
        return cWorse
      elseif (b < v) then
        return cBetter
      else
        return cEqual
      end
    else
      if (b > v) then
        return cBetter
      elseif (b < v) then
        return cWorse
      else
        return cEqual
      end
    end
  end

  local function FormatNumber(n)
    if n > 0 then
      return "+" .. round(n, 1)
    else
      return round(n, 1) .. ""
    end
  end

  local CompModes = {
    -- ["Don't Compare"] = nil,
    ["Absolute"] = function(b, v)
      return v
    end,
    ["Delta"] = function(b, v)
      return FormatNumber(b - v)
    end,
    ["Percent"] = function(b, v)
      return(b > 0 and(FormatNumber(v / b * 100 - 100)) .. "%") or "+"
    end
  }

  function ItemsOfPower:Compare(CompMode, ShowBase, ReverseColor, SwapComparison, ...)
    local b = ItemsOfPower:select(1, unpack(arg))

    local lines = { }

    if ShowBase then
      table.insert(lines, b)
    end

    local i = 2
    local v = ItemsOfPower:select(2, unpack(arg))
    while v do
      if CompModes[CompMode] then
        table.insert(lines, Color(ReverseColor, b, v))
        if ShowBase then
          table.insert(lines, " (")
        elseif i > 2 then
          table.insert(lines, " ")
        end
        if SwapComparison then
          table.insert(lines, CompModes[CompMode](v, b))
        else
          table.insert(lines, CompModes[CompMode](b, v))
        end
        if ShowBase then
          table.insert(lines, ")")
        end
        table.insert(lines, "|r")
      end
      i = i + 1
      v = ItemsOfPower:select(i, unpack(arg))
    end

    local text = table.concat(lines)
    tdel(lines)

    return text
  end

  function ItemsOfPower:ColorText(txt, ...)
    assert(txt and type(txt) == "string", "Invalid argument(s) to ColorText")
    local targ1 = type(arg[1])
    local color = arg[1]
    local r, g, b
    if targ1 == "table" then
      if color.r then
        r, g, b = color.r, color.g, color.b
      else
        r, g, b = unpack(color)
      end
    elseif targ1 == "number" then
      r, g, b = tonumber(arg[1]) or 1, tonumber(arg[2]) or 1, tonumber(arg[3]) or 1
    else
      return txt
    end
    return string.format("|cff%02x%02x%02x%s|r", r * 255, g * 255, b * 255, txt)
  end

  function ItemsOfPower:strsplit(sep, s)
    local sep, fields = sep or ":", { }
    local pattern = string.format("([^%s]+)", sep)
    string.gsub(s, pattern, function(c) fields[table.getn(fields) + 1] = c end)
    return unpack(fields)
  end

  function ItemsOfPower:select(index, ...)
    assert(tonumber(index) or index == "#", "Invalid argument #1 to select(). Usage: select(\"#\"|int,...)")
    if index == "#" then return arg.n end
    local sub = { }
    for i = index, arg.n do
      sub[table.getn(sub) + 1] = arg[i]
    end
    return unpack(sub)
  end
end


--[[
#############################
--    Tooltip Handling
--############################
--]]

function ItemsOfPower:TipHook()
  self:SecureHook(GameTooltip, "SetBagItem", function(this, bag, slot)
    ItemsOfPower.AddDataToTooltip(GameTooltip, GetContainerItemLink(bag, slot))
  end
  )
  self:SecureHook(GameTooltip, "SetLootItem", function(this, slot)
    ItemsOfPower.AddDataToTooltip(GameTooltip, GetLootSlotLink(slot))
  end
  )
  self:SecureHook(GameTooltip, "SetQuestItem", function(this, unit, slot)
    ItemsOfPower.AddDataToTooltip(GameTooltip, GetQuestItemLink(unit, slot))
  end
  )
  self:SecureHook(GameTooltip, "SetQuestLogItem", function(this, sOpt, slot)
    ItemsOfPower.AddDataToTooltip(GameTooltip, GetQuestLogItemLink(sOpt, slot))
  end
  )
  self:SecureHook(GameTooltip, "SetTradeSkillItem", function(this, skill, slot)
    local link =(slot) and GetTradeSkillReagentItemLink(skill, slot) or GetTradeSkillItemLink(skill)
    ItemsOfPower.AddDataToTooltip(GameTooltip, link)
  end
  )
  self:SecureHook(GameTooltip, "SetMerchantItem", function(this, slot)
    ItemsOfPower.AddDataToTooltip(GameTooltip, GetMerchantItemLink(slot))
  end
  )
  self:SecureHook(GameTooltip, "SetAuctionItem", function(this, unit, slot)
    ItemsOfPower.AddDataToTooltip(GameTooltip, GetAuctionItemLink(unit, slot))
  end
  )
  self:SecureHook(GameTooltip, "SetLootRollItem", function(this, id)
    ItemsOfPower.AddDataToTooltip(GameTooltip, GetLootRollItemLink(id))
  end
  )
  self:Hook(GameTooltip, "SetInventoryItem", function(this, unit, slot)
    local sItem, sCooldown, sRepair = self.hooks[GameTooltip]["SetInventoryItem"](this, unit, slot)
    if (not sItem) then return nil end
    if (slot > 39) then
      -- bank

    end
    ItemsOfPower.AddDataToTooltip(GameTooltip, GetInventoryItemLink(unit, slot))
    return sItem, sCooldown, sRepair
  end
  )
  self:SecureHook("SetItemRef", function(link, name, button)
    if (link and name and ItemRefTooltip) then
      if (strsub(link, 1, 6) ~= "Player") then
        if (ItemRefTooltip:IsVisible()) then
          if (not DressUpFrame:IsVisible()) then
            ItemsOfPower.AddDataToTooltip(ItemRefTooltip, link)
          end
          ItemRefTooltip.isDisplayDone = nil
        end
      end
    end
  end
  )
end

function ItemsOfPower:TipUnhook()
  self:UnhookAll()
end

function ItemsOfPower.AddDataToTooltip(Tooltip, argItemLink, argItemString)
  local ItemString = argItemString or ItemsOfPower:ItemLinkToItemString(argItemLink)
  if not ItemString then return end

  local text = TooltipTextCache[ItemString]

  if ItemsOfPower.db.profile.Tooltip.RightSide then
    local text2 = TooltipTextCache2[ItemString]
    if not(text and text2) then
      text, text2 = ItemsOfPower:GetTooltipText(ItemString)
      TooltipTextCache[ItemString] = text
      TooltipTextCache2[ItemString] = text2
    end
    Tooltip:AddDoubleLine(text, text2)
  else
    if not text then
      text = ItemsOfPower:GetTooltipText(ItemString)
      TooltipTextCache[ItemString] = text
    end
    Tooltip:AddLine(text)
  end

  Tooltip:Show()
end

do
  -- ItemsOfPower:GetTooltipText(ItemString)
  local BaseItem = { }
  local CompareItem1 = { }
  local CompareItem2 = { }

  function ItemsOfPower:GetTooltipText(ItemString)
    -- Check if enchant link
    if strfind(ItemString, ":") ~= 5 then return "", "" end
    BaseItem.ItemString = ItemString

    local ItemEquipLoc = ItemsOfPower:select(8, GetItemInfo(ItemString))

    local OwnItem = self:IsEquippedItem(ItemString, ItemEquipLoc)

    if ItemEquipLoc and not(self.db.profile.Tooltip.Compare == "None" or OwnItem) then
      local slot1, slot2 = self:GetInventorySlot(BaseItem.ItemString)
      if slot1 then
        CompareItem1.ItemString = self:ItemLinkToItemString(GetInventoryItemLink("player", slot1))
        CompareItem1.Enabled =(type(CompareItem1.ItemString) == "string") and string.len(CompareItem1.ItemString) > 10
      else
        CompareItem1.Enabled = false
      end
      if slot2 then
        CompareItem2.ItemString = self:ItemLinkToItemString(GetInventoryItemLink("player", slot2))
        CompareItem2.Enabled =(type(CompareItem2.ItemString) == "string") and string.len(CompareItem2.ItemString) > 10
      else
        CompareItem2.Enabled = false
      end
    else
      CompareItem1.Enabled = false
      CompareItem2.Enabled = false
    end

    self:ApplyItemModifications(BaseItem, CompareItem1.Enabled and CompareItem1, CompareItem2.Enabled and CompareItem2)

    local text, text2

    for SetId, Set in pairs(SetById) do
      local SetPointsB, SetPoints1, SetPoints2
      if self.db.profile.DisplayInTooltip[Set.Name] then

        SetPointsB = round(Set:GetItemValue(BaseItem.ItemString), self.db.profile.Round[Set.Name])
        if CompareItem1.Enabled then
          SetPoints1 = round(Set:GetItemValue(CompareItem1.ItemString), self.db.profile.Round[Set.Name])
        end
        if CompareItem2.Enabled then
          SetPoints2 = round(Set:GetItemValue(CompareItem2.ItemString), self.db.profile.Round[Set.Name])
        end

        if (SetPointsB > 0)
          or(SetPoints1 and SetPointsB ~= SetPoints1)
          or(SetPoints2 and SetPointsB ~= SetPoints2) then

          local line =(SetPoints1 or SetPoints2) and self:Compare(self.db.profile.Tooltip.Compare,
          self.db.profile.Tooltip.ShowPoints, self.db.profile.Tooltip.SwapColors, self.db.profile.Tooltip.SwapComparison,
          SetPointsB, SetPoints1, SetPoints2) or SetPointsB

          local colorName = ItemsOfPower:ColorText(Set.Name, self.db.profile.Color[Set.Name])

          if self.db.profile.Tooltip.RightSide then
            text =((text and(text ~= "") and(text .. "\n")) or "") .. colorName
            text2 =((text2 and(text2 ~= "") and(text2 .. "\n")) or "") .. line
          else
            text =((text and(text ~= "") and(text .. "\n")) or "") .. colorName .. ": " .. line
          end
        end
      end
    end

    return text or "", text2 or ""
  end
end

do
  -- ItemsOfPower:ApplyItemModifications(BaseItem, CompareItem1, CompareItem2)
  local function FillItemInfos(Item)
    if not Item then return end
    local _, iId, eId, sId, uId = ItemsOfPower:strsplit(":", Item.ItemString)
    Item.iId = iId or "0"
    Item.eId = eId or "0"
    Item.sId = sId or "0"
    Item.uId = uId or "0"

  end

  function ItemsOfPower:ApplyItemModifications(BaseItem, CompareItem1, CompareItem2)
    FillItemInfos(BaseItem)
    FillItemInfos(CompareItem1)
    FillItemInfos(CompareItem2)

    -- Apply Enchant Settings
    if self.db.profile.Modifications.Enchants == L["Always own"] then
      if CompareItem1 or CompareItem2 then
        BaseItem.eId =(CompareItem1 and CompareItem1.eId) or CompareItem2.eId
      end
    elseif self.db.profile.Modifications.Enchants == L["Fill with own"] then
      if BaseItem.eId == "0" and(CompareItem1 or CompareItem2) then
        BaseItem.eId =(CompareItem1 and CompareItem1.eId) or(CompareItem2 and CompareItem2.eId) or "0"
      end
    elseif self.db.profile.Modifications.Enchants == L["Ignore"] then
      BaseItem.eId = "0"
      if CompareItem1 then CompareItem1.eId = "0" end
      if CompareItem2 then CompareItem2.eId = "0" end
    end

    BaseItem.ItemString = self:GetItemString(BaseItem.iId, BaseItem.eId, BaseItem.sId, BaseItem.uId)
    self:Debug(BaseItem.ItemString)
    if CompareItem1 then
      CompareItem1.ItemString = self:GetItemString(CompareItem1.iId, CompareItem1.eId, CompareItem1.sId, CompareItem1.uId)
      self:Debug(CompareItem1.ItemString)
    end
    if CompareItem2 then
      CompareItem2.ItemString = self:GetItemString(CompareItem2.iId, CompareItem2.eId, CompareItem2.sId, CompareItem2.uId)
      self:Debug(CompareItem2.ItemString)
    end
  end
end


--[[
#############################
--    Item functions
--############################
--]]

do
  -- ItemsOfPower:GetInventorySlot(ItemLink)
  local slot1 = {
    INVTYPE_AMMO = 0,
    INVTYPE_GUNPROJECTILE = 0,
    INVTYPE_BOWPROJECTILE = 0,
    INVTYPE_HEAD = 1,
    INVTYPE_NECK = 2,
    INVTYPE_SHOULDER = 3,
    INVTYPE_BODY = 4,
    INVTYPE_CHEST = 5,
    INVTYPE_ROBE = 5,
    INVTYPE_WAIST = 6,
    INVTYPE_LEGS = 7,
    INVTYPE_FEET = 8,
    INVTYPE_WRIST = 9,
    INVTYPE_HAND = 10,
    INVTYPE_FINGER = 11,
    INVTYPE_TRINKET = 13,
    INVTYPE_CLOAK = 15,
    INVTYPE_WEAPON = 16,
    INVTYPE_2HWEAPON = 16,
    INVTYPE_WEAPONMAINHAND = 16,
    INVTYPE_WEAPONOFFHAND = 17,
    INVTYPE_SHIELD = 17,
    INVTYPE_HOLDABLE = 17,
    INVTYPE_RANGED = 18,
    INVTYPE_RANGEDRIGHT = 18,
    INVTYPE_RELIC = 18,
    INVTYPE_GUN = 18,
    INVTYPE_CROSSBOW = 18,
    INVTYPE_WAND = 18,
    INVTYPE_THROWN = 18,
    INVTYPE_TABARD = 19,
  }

  local slot2 = {
    INVTYPE_FINGER = 12,
    INVTYPE_TRINKET = 14,
    INVTYPE_WEAPON = 17,
    INVTYPE_2HWEAPON = 17,
  }

  function ItemsOfPower:GetInventorySlot(ItemLink)
    local ItemEquipLoc = ItemsOfPower:select(8, GetItemInfo(ItemLink))
    if not ItemEquipLoc then return end

    local s1, s2 = slot1[ItemEquipLoc], slot2[ItemEquipLoc]

    return s1, s2
  end

  function ItemsOfPower:IsEquippedItem(ItemString, ItemEquipLoc)
    if not ItemEquipLoc then return false end
    local s1, s2 = slot1[ItemEquipLoc], slot2[ItemEquipLoc]
    if s1 then
      return ItemString == self:ItemLinkToItemString(GetInventoryItemLink("player", s1))
    elseif s2 then
      return ItemString == self:ItemLinkToItemString(GetInventoryItemLink("player", s2))
    end
  end
end

function ItemsOfPower:ItemLinkToItemString(ItemLink)
  if not ItemLink then return end
  local il, _, ItemString = strfind(ItemLink, "^|%x+|H(.+)|h%[.+%]")
  return il and ItemString or ItemLink
end

function ItemsOfPower:ItemStringToItemLink(ItemString)
  local itemName, itemString, itemQuality = GetItemInfo(ItemString)
  if not itemName then Gratuity:SetHyperlink(ItemString) return ItemString end
  local c = ITEM_QUALITY_COLORS[tonumber(itemQuality)]
  local Item = string.format("\124H%s\124h[%s]\124h", itemString, itemName)
  local ItemLink = self:ColorText(Item, c)
  return ItemLink
end

function ItemsOfPower:GetItemString(itemId, enchantId, suffixId, uniqueId)
  return "item:" .. itemId .. ":" ..(enchantId or 0) .. ":" ..(suffixId or 0) .. ":" ..(uniqueId or 0)
end

function ItemsOfPower:GetItemLink(itemId, enchantId, suffixId, uniqueId)
  local itemString = self:GetItemString(itemId, enchantId, suffixId, uniqueId)
  local itemLink = self:ItemStringToItemLink(itemString)
  return itemLink
end

function ItemsOfPower:GetUnitEquipment(unit)
  if not unit then return end
  return ItemBonusLib:MergeDetails(
  ItemBonusLib:BuildBonusSet(
  ItemBonusLib:GetUnitEquipment(
  unit
  )))
end


do
  -- ItemsOfPower:GetInspectEquipment()
  local slots = {
    ["Head"] = true,
    ["Neck"] = true,
    ["Shoulder"] = true,
    ["Shirt"] = true,
    ["Chest"] = true,
    ["Waist"] = true,
    ["Legs"] = true,
    ["Feet"] = true,
    ["Wrist"] = true,
    ["Hands"] = true,
    ["Finger0"] = true,
    ["Finger1"] = true,
    ["Trinket0"] = true,
    ["Trinket1"] = true,
    ["Back"] = true,
    ["MainHand"] = true,
    ["SecondaryHand"] = true,
    ["Ranged"] = true,
    ["Tabard"] = true,
  }

  for s in pairs(slots) do
    slots[s] = GetInventorySlotInfo(s .. "Slot")
  end

  local eq = { }

  function ItemsOfPower:GetInspectEquipment()
    if not InspectFrame.unit then return end

    if UnitName(InspectFrame.unit) == UnitName("player") then return self.EquipStats end

    for i in pairs(eq) do
      eq[i] = nil
    end

    for slot, id in pairs(slots) do
      eq[slot] = GetInventoryItemLink(InspectFrame.unit, id)
    end

    return ItemBonusLib:MergeDetails(ItemBonusLib:BuildBonusSet(eq))
  end
end

--[[
#############################
--    Debug & Test functions
--############################
--]]
do
  -- ItemsOfPower:Benchmark()
  local t
  local function start()
    t = GetTime()
  end
  local function stop(text)
    local d = floor((GetTime() - t) * 1000)
    ItemsOfPower:Print(text .. ":", d .. "ms")
  end

  function ItemsOfPower:Benchmark()
    start()
    for i = 1, 100 do
      self:RegisterSet(SetTypes.StatSet:new("BenchmarkSet_" .. i))
    end
    stop("Creating 100 StatSets")

    start()
    for i = 1, 100 do
      self:UnregisterSet(self.SetByName["BenchmarkSet_" .. i])
    end
    stop("Deleting 100 StatSets")
  end
end
