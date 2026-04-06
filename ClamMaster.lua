-- ====================================================================================================
-- =                                      Set all locals we need                                      =
-- ====================================================================================================

-- Current Session Vars
local CSBigMouthClamCounter = 0
local CSGoldenPearlCounter = 0
local CSBlackPearlCounter = 0
local CSIridescentPearlCounter = 0
local CSSmallLustrousPearlCounter = 0
local CSLuckIdentifier = "???"
local LuckIdentifier = "???"
local SettingsLoaded = false

-- 
if (not BigMouthClamCounter) then BigMouthClamCounter = 0 end
if (not GoldenPearlCounter) then GoldenPearlCounter = 0 end
if (not BlackPearlCounter) then BlackPearlCounter = 0 end
if (not IridescentPearlCounter) then IridescentPearlCounter = 0 end
if (not SmallLustrousPearlCounter) then SmallLustrousPearlCounter = 0 end
if (not CMAutoDelete) then CMAutoDelete = false end

-- We run this just to be 100% sure that we have it.
function LoadSettings()
    if (not BigMouthClamCounter) then BigMouthClamCounter = 0 end
    if (not GoldenPearlCounter) then GoldenPearlCounter = 0 end
    if (not BlackPearlCounter) then BlackPearlCounter = 0 end
    if (not IridescentPearlCounter) then IridescentPearlCounter = 0 end
    if (not SmallLustrousPearlCounter) then SmallLustrousPearlCounter = 0 end
    if (not CMAutoDelete) then CMAutoDelete = false end
    SettingsLoaded = true
    Lucky()
end

-- Other
if (TURTLE_WOW_VERSION) then -- Adjusted to Turtle WoW, in Classic it's 0.005
    local GoldenPearlDropChance = 0.017
else
    local GoldenPearlDropChance = 0.005
end
local LootDelayTime = GetTime()
local LootDelay = 1


-- ====================================================================================================
-- =                                 Create frame and register events                                 =
-- ====================================================================================================

local f = CreateFrame("Frame");
    f:RegisterEvent("CHAT_MSG_LOOT");
    f:RegisterEvent("ADDON_LOADED");

-- ====================================================================================================
-- =                                          Event handler.                                          =
-- ====================================================================================================

f:SetScript("OnEvent", function()
    if (event == "ADDON_LOADED") and (arg1 == "ClamMaster") then
        LoadSettings()
        DEFAULT_CHAT_FRAME:AddMessage("|cffFF0000[Clam Master]|r Loaded. (/cm for more info)");
        f:UnregisterEvent("ADDON_LOADED")
-- ====================================================================================================
    elseif (event == "CHAT_MSG_LOOT") and (string.find(arg1, "You receive loot:")) then
        if (string.find(arg1, "Big%-mouth Clam")) then
            BigMouthClamCounter = BigMouthClamCounter + 1;
            CSBigMouthClamCounter = CSBigMouthClamCounter + 1;
        elseif (string.find(arg1, "Golden Pearl")) then
            GoldenPearlCounter = GoldenPearlCounter + 1;
            CSGoldenPearlCounter = CSGoldenPearlCounter + 1;
            PlaySoundFile("Interface\\AddOns\\ClamMaster\\Sounds\\GoldenPearl.ogg");
            DEFAULT_CHAT_FRAME:AddMessage("|cffFF0000[ClamMaster]|r - Congratulations, you've looted a Golden Pearl!");
        elseif (string.find(arg1, "Black Pearl")) then
            BlackPearlCounter = BlackPearlCounter + 1;
            CSBlackPearlCounter = CSBlackPearlCounter + 1;
        elseif (string.find(arg1, "Iridescent Pearl")) then
            IridescentPearlCounter = IridescentPearlCounter + 1;
            CSIridescentPearlCounter = CSIridescentPearlCounter + 1;
        elseif (string.find(arg1, "Small Lustrous Pearl")) then
            SmallLustrousPearlCounter = SmallLustrousPearlCounter + 1;
            CSSmallLustrousPearlCounter = CSSmallLustrousPearlCounter + 1;
        end
        -- Update the text if it need.
        if (SettingsLoaded) then
            Lucky()
        end
    end

end)

-- ====================================================================================================
-- =                                     OnUpdate on every frame.                                     =
-- ====================================================================================================

f:SetScript("OnUpdate", function()

    -- Delay timer
    -- The reason we delay is that if we loot to fast, then it will bug out and try to loot until we log out.
    if (GetNumRaidMembers() == 0) and ((GetTime() - LootDelayTime) > LootDelay) then
        OpenAllClams()
    end

end)

-- ====================================================================================================
-- =                          Search and open clams and delete all Clam Meat                          =
-- ====================================================================================================

function OpenAllClams()

    if (SearchClams()) then
        UseContainerItem(SearchClams())
        ClamMeatDelete()
        LootDelayTime = GetTime()
    end

end

-- ====================================================================================================

function SearchClams()

    for bag = 0, 4 do
        for slot = 1, GetContainerNumSlots(bag) do
            local BagItem = GetContainerItemLink(bag, slot)
            if (BagItem) and ((string.find(BagItem, "Big%-mouth Clam")) or (string.find(BagItem, "Thick%-shelled Clam")) or (string.find(BagItem, "Small Barnacled Clam"))) then
                return bag, slot
            end
        end
    end
    return false

end

-- ====================================================================================================

-- Delete Clam Meat
function ClamMeatDelete()

    if (CMAutoDelete == true) then
        -- Loop through out bags.
        for bag = 0, 4 do
            for slot = 1, GetContainerNumSlots(bag) do
                local BagItem = GetContainerItemLink(bag, slot)
                if (BagItem) and (string.find(BagItem, "Zesty Clam Meat")) or (string.find(BagItem, "Tangy Clam Meat")) or (string.find(BagItem, "Clam Meat")) then
                    PickupContainerItem(bag, slot)
                    DeleteCursorItem()   
                end
            end
        end
    end

end

-- ====================================================================================================
-- ====================================================================================================
-- =                                            The Widget                                            =
-- ====================================================================================================
-- ====================================================================================================

-- Widget
local WidgetFrame = CreateFrame("Frame", "CMFrame", UIParent);
    WidgetFrame:SetWidth(230)
    WidgetFrame:SetHeight(160)
    WidgetFrame:SetPoint("CENTER", 0, 0);
    WidgetFrame:SetFrameStrata("DIALOG");
    WidgetFrame:SetMovable(true);
    WidgetFrame:EnableMouse(true);
    WidgetFrame:RegisterForDrag("LeftButton")
    WidgetFrame:SetScript("OnDragStart", function()
        this:StartMoving();
    end);
    WidgetFrame:SetScript("OnDragStop", function()
        this:StopMovingOrSizing();
    end);
    WidgetFrame:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",--"Interface/DialogFrame/UI-DialogBox-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",--"Interface/DialogFrame/UI-DialogBox-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 16,
        insets = {
            left = 4,
            right = 4,
            top = 4,
            bottom = 4
        }
    });
    WidgetFrame:SetBackdropColor(0, 0, 0, 0.9)
    WidgetFrame:Hide()

-- Header Texture
local headerTexture = WidgetFrame:CreateTexture(nil, "OVERLAY")
    headerTexture:SetWidth(225)
    headerTexture:SetHeight(64)
    headerTexture:SetPoint("CENTER", 0, 64)
    headerTexture:SetTexture("Interface/DialogFrame/UI-DialogBox-Header")

-- Header
local header = WidgetFrame:CreateFontString(WidgetFrame, "OVERLAY", "GameFontNormal")
    header:SetPoint("CENTER", 0, 75)
    header:SetText("|cffFF0000Clam Master|r");

-- Items
local ItemsTitle = WidgetFrame:CreateFontString(WidgetFrame, "OVERLAY", "GameTooltipText")
    ItemsTitle:SetPoint("LEFT", 40, 45)
    ItemsTitle:SetText("|cffFF0000Items|r");

local bigMouthClamTitle = WidgetFrame:CreateFontString(WidgetFrame, "OVERLAY", "GameTooltipText")
    bigMouthClamTitle:SetPoint("LEFT", 10, 30)
    bigMouthClamTitle:SetText("|cffFFFFFFBig-mouth Clams|r");

local goldenPearlsTitle = WidgetFrame:CreateFontString(WidgetFrame, "OVERLAY", "GameTooltipText")
    goldenPearlsTitle:SetPoint("LEFT", 10, 15)
    goldenPearlsTitle:SetText("|cffFFFFFFGolden Pearls|r");

local blackPearlsTitle = WidgetFrame:CreateFontString(WidgetFrame, "OVERLAY", "GameTooltipText")
    blackPearlsTitle:SetPoint("LEFT", 10, 0)
    blackPearlsTitle:SetText("|cffFFFFFFBlack Pearls|r");

local iridescentPearlsTitle = WidgetFrame:CreateFontString(WidgetFrame, "OVERLAY", "GameTooltipText")
    iridescentPearlsTitle:SetPoint("LEFT", 10, -15)
    iridescentPearlsTitle:SetText("|cffFFFFFFIridescent Pearls|r")

local smallLustrousPearlsTitle = WidgetFrame:CreateFontString(WidgetFrame, "OVERLAY", "GameTooltipText")
    smallLustrousPearlsTitle:SetPoint("LEFT", 10, -30)
    smallLustrousPearlsTitle:SetText("|cffFFFFFFSmall Lustrous Pearls|r")

local CSLuckTitle = WidgetFrame:CreateFontString(WidgetFrame, "OVERLAY", "GameTooltipText")
    CSLuckTitle:SetPoint("LEFT", 10, -50)
    CSLuckTitle:SetText("|cfff5ef42I have been|r " .. LuckIdentifier .. " |cfff5ef42during my|r |cffFF0000LS|r")

local LuckTitle = WidgetFrame:CreateFontString(WidgetFrame, "OVERLAY", "GameTooltipText")
    LuckTitle:SetPoint("LEFT", 10, -65)
    LuckTitle:SetText("|cfff5ef42I have been|r " .. CSLuckIdentifier .. " |cfff5ef42during my|r |cffFF0000CS|r")

-- Lifetime Session
local LifetimeTitle = WidgetFrame:CreateFontString(WidgetFrame, "OVERLAY", "GameTooltipText")
    LifetimeTitle:SetPoint("Center", 50, 45)
    LifetimeTitle:SetText("|cffFF0000LS|r");

local bigMouthClamCount = WidgetFrame:CreateFontString(WidgetFrame, "OVERLAY", "GameTooltipText")
    bigMouthClamCount:SetPoint("CENTER", 50, 30)
    bigMouthClamCount:SetText("|cff00FF00".. BigMouthClamCounter .. "|r");

local goldenPearlsCount = WidgetFrame:CreateFontString(WidgetFrame, "OVERLAY", "GameTooltipText")
    goldenPearlsCount:SetPoint("CENTER", 50, 15)
    goldenPearlsCount:SetText("|cff00FF00" .. GoldenPearlCounter .. "|r");

local blackPearlsCount = WidgetFrame:CreateFontString(WidgetFrame, "OVERLAY", "GameTooltipText")
    blackPearlsCount:SetPoint("CENTER", 50, 0)
    blackPearlsCount:SetText("|cff00FF00" .. BlackPearlCounter .. "|r")

local iridescentPearlsCount = WidgetFrame:CreateFontString(WidgetFrame, "OVERLAY", "GameTooltipText")
    iridescentPearlsCount:SetPoint("CENTER", 50, -15)
    iridescentPearlsCount:SetText("|cff00FF00" .. IridescentPearlCounter .. "|r")

local smallLustrousPearlsCount = WidgetFrame:CreateFontString(WidgetFrame, "OVERLAY", "GameTooltipText")
    smallLustrousPearlsCount:SetPoint("CENTER", 50, -30)
    smallLustrousPearlsCount:SetText("|cff00FF00" .. SmallLustrousPearlCounter .. "|r");

-- Current Session
    local CurrentSessionTitle = WidgetFrame:CreateFontString(WidgetFrame, "OVERLAY", "GameTooltipText")
    CurrentSessionTitle:SetPoint("RIGHT", -20, 45)
    CurrentSessionTitle:SetText("|cffFF0000CS|r");

local csbigMouthClamCount = WidgetFrame:CreateFontString(WidgetFrame, "OVERLAY", "GameTooltipText")
    csbigMouthClamCount:SetPoint("RIGHT", -20, 30)
    csbigMouthClamCount:SetText("|cff00FF00".. CSBigMouthClamCounter .. "|r");

local csgoldenPearlsCount = WidgetFrame:CreateFontString(WidgetFrame, "OVERLAY", "GameTooltipText")
    csgoldenPearlsCount:SetPoint("RIGHT", -20, 15)
    csgoldenPearlsCount:SetText("|cff00FF00" .. CSGoldenPearlCounter .. "|r");

local csblackPearlsCount = WidgetFrame:CreateFontString(WidgetFrame, "OVERLAY", "GameTooltipText")
    csblackPearlsCount:SetPoint("RIGHT", -20, 0)
    csblackPearlsCount:SetText("|cff00FF00" .. CSBlackPearlCounter .. "|r")

local csiridescentPearlsCount = WidgetFrame:CreateFontString(WidgetFrame, "OVERLAY", "GameTooltipText")
    csiridescentPearlsCount:SetPoint("RIGHT", -20, -15)
    csiridescentPearlsCount:SetText("|cff00FF00" .. CSIridescentPearlCounter .. "|r")

local cssmallLustrousPearlsCount = WidgetFrame:CreateFontString(WidgetFrame, "OVERLAY", "GameTooltipText")
    cssmallLustrousPearlsCount:SetPoint("RIGHT", -20, -30)
    cssmallLustrousPearlsCount:SetText("|cff00FF00" .. CSSmallLustrousPearlCounter .. "|r");

-- ====================================================================================================
-- =                                         The "How lycky?"                                         =
-- ====================================================================================================

function Lucky()

    -- 
    if (not SettingsLoaded) then
        return
    end

    -- Lucky or Unlucky Lifetime Session ---
    local expectedGoldenPearlCount = (BigMouthClamCounter * GoldenPearlDropChance)

    if (expectedGoldenPearlCount >= 1) and (expectedGoldenPearlCount >= GoldenPearlCounter) then
        LuckIdentifier = "|cffC24B4BUnlucky|r"
    elseif (GoldenPearlCounter >= expectedGoldenPearlCount) then
        LuckIdentifier = "|cff51C431Lucky|r"
    end
    -- Lucky or Unlucky Current Session ---
    local csexpectedGoldenPearlCount = (CSBigMouthClamCounter * GoldenPearlDropChance)

    if (csexpectedGoldenPearlCount >= 1) and (csexpectedGoldenPearlCount >= CSGoldenPearlCounter) then
        CSLuckIdentifier = "|cffC24B4BUnlucky|r"
    elseif (CSGoldenPearlCounter > csexpectedGoldenPearlCount) then
        CSLuckIdentifier = "|cff51C431Lucky|r"
    end

    bigMouthClamCount:SetText("|cff00FF00".. BigMouthClamCounter .. "|r")
    goldenPearlsCount:SetText("|cff00FF00" .. GoldenPearlCounter .. "|r")
    blackPearlsCount:SetText("|cff00FF00" .. BlackPearlCounter .. "|r")
    iridescentPearlsCount:SetText("|cff00FF00" .. IridescentPearlCounter .. "|r")
    smallLustrousPearlsCount:SetText("|cff00FF00" .. SmallLustrousPearlCounter .. "|r")
    csbigMouthClamCount:SetText("|cff00FF00".. CSBigMouthClamCounter .. "|r")
    csgoldenPearlsCount:SetText("|cff00FF00" .. CSGoldenPearlCounter .. "|r")
    csblackPearlsCount:SetText("|cff00FF00" .. CSBlackPearlCounter .. "|r")
    csiridescentPearlsCount:SetText("|cff00FF00" .. CSIridescentPearlCounter .. "|r")
    cssmallLustrousPearlsCount:SetText("|cff00FF00" .. CSSmallLustrousPearlCounter .. "|r")
    LuckTitle:SetText("|cfff5ef42I have been|r " .. LuckIdentifier .. " |cfff5ef42during my|r |cffFF0000LS|r")
    CSLuckTitle:SetText("|cfff5ef42I have been|r " .. CSLuckIdentifier .. " |cfff5ef42during my|r |cffFF0000CS|r")

end

-- ====================================================================================================
-- =                                          Slach commands                                          =
-- ====================================================================================================

-- Prints out statistics of lifetime and current session.
SLASH_ClamMaster1 = "/cm";
SlashCmdList["ClamMaster"] = function(msg)
  DEFAULT_CHAT_FRAME:AddMessage("-----------< |cffFF0000Clam Master|r |cff00FF00Commands|r >-------------")
  DEFAULT_CHAT_FRAME:AddMessage("• |cff00FF00/cm|r - shows all of the commands available")
  DEFAULT_CHAT_FRAME:AddMessage("• |cff00FF00/cmr|r - resets current session")
  DEFAULT_CHAT_FRAME:AddMessage("• |cff00FF00/cmshow|r - shows the widget")
  DEFAULT_CHAT_FRAME:AddMessage("• |cff00FF00/cmhide|r - hides the widget")
  DEFAULT_CHAT_FRAME:AddMessage("• |cff00FF00/cmwr|r - resets the position of your widget")
  DEFAULT_CHAT_FRAME:AddMessage("• |cff00FF00/cmadt|r - toggles the auto-delete feature on/off")
  DEFAULT_CHAT_FRAME:AddMessage("• |cff00FF00/cmhl|r - tells you how lucky/unlucky you've been")
  DEFAULT_CHAT_FRAME:AddMessage("-------------------------------------------------------------")
end

-- Resets Current Session
SLASH_ClamMasterReset1 = "/cmr";
SlashCmdList["ClamMasterReset"] = function(msg)
  CSBigMouthClamCounter = 0;
  CSGoldenPearlCounter = 0;
  CSBlackPearlCounter = 0;
  CSIridescentPearlCounter = 0;
  CSSmallLustrousPearlCounter = 0;
  csexpectedGoldenPearlCount = 0;
  csbigMouthClamCount:SetText("|cff00FF00".. CSBigMouthClamCounter .. "|r")
  csgoldenPearlsCount:SetText("|cff00FF00" .. CSGoldenPearlCounter .. "|r")
  csblackPearlsCount:SetText("|cff00FF00" .. CSBlackPearlCounter .. "|r")
  csiridescentPearlsCount:SetText("|cff00FF00" .. CSIridescentPearlCounter .. "|r")
  cssmallLustrousPearlsCount:SetText("|cff00FF00" .. CSSmallLustrousPearlCounter .. "|r")
  DEFAULT_CHAT_FRAME:AddMessage("|cffFF0000[Clam Master]|r - Your current session is now reset!");
end

-- Opens Window
SLASH_ClamMasterShow1 = "/cmshow";
SlashCmdList["ClamMasterShow"] = function(msg)
  WidgetFrame:Show();
end

-- Hides Window
SLASH_ClamMasterHide1 = "/cmhide";
SlashCmdList["ClamMasterHide"] = function(msg)
  CMFrame:Hide();
end

-- Resets Current Session
SLASH_ClamMasterWidgetReset1 = "/cmwr";
SlashCmdList["ClamMasterWidgetReset"] = function(msg)
  CMFrame:ClearAllPoints()
  CMFrame:SetPoint("CENTER", 0, 0)
  DEFAULT_CHAT_FRAME:AddMessage("|cffFF0000[Clam Master]|r - The position of your widget is now reset!");
end

-- Toggles auto deletion on/off
SLASH_ClamMasterAutoDeleteToggle1 = "/cmadt";
SlashCmdList["ClamMasterAutoDeleteToggle"] = function(msg)
    if CMAutoDelete == true then 
        CMAutoDelete = false
        DEFAULT_CHAT_FRAME:AddMessage("|cffFF0000[Clam Master]|r - Auto deletion has been turned |cffFF0000OFF|r!");
    elseif CMAutoDelete == false then
        CMAutoDelete = true
        DEFAULT_CHAT_FRAME:AddMessage("|cffFF0000[Clam Master]|r - Auto deletion has been turned |cff00FF00ON|r!");
  end
end

-- Shows how Lucky/Unlucky you've been
SLASH_ClamMasterHowLucky1 = "/cmhl";
SlashCmdList["ClamMasterHowLucky"] = function(msg)
  local HowLucky = string.format("%.1f", (BigMouthClamCounter * GoldenPearlDropChance))
  DEFAULT_CHAT_FRAME:AddMessage("|cffFF0000[Clam Master]|r So far you've been " .. LuckIdentifier .. " and at this point you've obtained |cff00FF00" .. GoldenPearlCounter .. "|r |cffFDCC51Golden Pearls|r, and should've gotten |cff00FF00" .. HowLucky .. "|r |cffFDCC51Golden Pearls|r.")
end
