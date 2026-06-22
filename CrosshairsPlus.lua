--[[
    CrosshairsPlus v1.0
    Based on Crosshairs by Semlar (WotLK backport: Kader)
    Extended by xLT69x
    /chp  — open settings   /chp reset — restore defaults
]]

-- ============================================================
-- DIAGNOSTIC FRAME  — created FIRST so it survives if anything
-- below crashes.  Even if rest of file errors, this frame's
-- OnEvent is already registered and will fire at login.
-- ============================================================
do
    local _d = CreateFrame("Frame")
    _d:RegisterEvent("PLAYER_ENTERING_WORLD")
    _d:SetScript("OnEvent", function(self)
        self:UnregisterAllEvents()
        if not LibStub then
            DEFAULT_CHAT_FRAME:AddMessage("|cffff4444CrosshairsPlus|r ERROR: LibStub is nil — libs did not load at all")
            return
        end
        if not LibStub("LibNameplates-1.0", true) then
            DEFAULT_CHAT_FRAME:AddMessage("|cffff4444CrosshairsPlus|r ERROR: LibNameplates-1.0 failed to register (lib crash or missing file)")
        end
        -- If both are fine, the main frame's PLAYER_ENTERING_WORLD
        -- handler will print the "loaded!" message instead.
    end)
end

-- ============================================================
-- Lib check  — use silent=true so LibStub returns nil instead
-- of throwing a Lua error when LibNameplates isn't registered
-- ============================================================
local LibNameplates = LibStub and LibStub("LibNameplates-1.0", true)
if not LibNameplates then return end

-- ============================================================
-- Constants
-- ============================================================
local ASSET = "Interface\\AddOns\\CrosshairsPlus\\Assets\\"

local CIRCLE_TEX = {
    ASSET.."circle",
    ASSET.."Circle0",
    ASSET.."Circle2",
    ASSET.."Circle3",
    ASSET.."Circle4",
    ASSET.."CircleGlow",
}
local CIRCLE_NAMES = { "Original","Style 2","Style 3","Style 4","Style 5","Glow" }

local DEFAULTS = {
    alpha       = 0.75,
    lineAlpha   = 0.5,
    scale       = 1.0,
    showLines   = true,
    circleStyle = 1,
    showArrows  = true,
    rotSpeed    = 5,
    rotCW       = false,
    colorMode   = "class",
}

-- ============================================================
-- Upvalues  (kept in sync with DB so fade helpers are correct)
-- ============================================================
local alpha      = 0.75
local lineAlpha  = 0.5
local showLines  = true
local showArrows = true
local speed      = 0.1   -- fade duration in seconds

-- ============================================================
-- Localise globals  (identical to working Crosshairs)
-- ============================================================
local UIFrameFadeIn        = UIFrameFadeIn
local CreateFrame          = CreateFrame
local tonumber             = tonumber
local strmatch             = strmatch or string.match
local UnitClass            = UnitClass
local UnitIsPlayer         = UnitIsPlayer
local UnitIsTapped         = UnitIsTapped
local UnitIsTappedByPlayer = UnitIsTappedByPlayer
local UnitIsUnit           = UnitIsUnit
local UnitSelectionColor   = UnitSelectionColor

-- ============================================================
-- UI scale  — identical calc to working Crosshairs, but the
-- whole block is wrapped in pcall so a nil/OOB resolution index
-- (windowed mode, custom res) can never crash the addon
-- ============================================================
local uiScale = 1
do
    local ok, val = pcall(function()
        local h = select(2, strmatch(
            ({GetScreenResolutions()})[GetCurrentResolution()],
            "(%d+)x(%d+)"))
        h = tonumber(h)
        return (h and h > 0) and (768 / h) or 1
    end)
    if ok and val then uiScale = val end
end
local lineWidth = uiScale * 2

-- ============================================================
-- Frame  (identical to working Crosshairs)
-- ============================================================
local f = CreateFrame("frame", "CrosshairsPlusFrame", UIParent)
f:SetFrameLevel(0)
f:SetFrameStrata("BACKGROUND")
f:SetPoint("CENTER")
f:SetSize(64 * uiScale, 64 * uiScale)

-- Circle texture  (child of UIParent so alpha==0 hides it while
-- the frame itself can be shown/hidden for layout purposes)
local circle = UIParent:CreateTexture(nil, "ARTWORK")
circle:SetTexture(ASSET.."circle")
circle:SetAllPoints(f)
circle:SetAlpha(alpha)
circle:SetBlendMode("ADD")

-- Line textures  (children of f)
local left   = f:CreateTexture(nil, "ARTWORK")
local right  = f:CreateTexture(nil, "ARTWORK")
local top    = f:CreateTexture(nil, "ARTWORK")
local bottom = f:CreateTexture(nil, "ARTWORK")
for _, t in ipairs({left, right, top, bottom}) do
    t:SetTexture([[Interface\Buttons\WHITE8X8]])
    t:SetVertexColor(1, 1, 1, alpha)
    t:SetBlendMode("ADD")
end
left:SetPoint("RIGHT",  f, "LEFT",    8,  0);  left:SetSize(2000, lineWidth)
right:SetPoint("LEFT",  f, "RIGHT",  -8,  0);  right:SetSize(2000, lineWidth)
top:SetPoint("BOTTOM",  f, "TOP",     0, -8);  top:SetSize(lineWidth, 2000)
bottom:SetPoint("TOP",  f, "BOTTOM",  0,  8);  bottom:SetSize(lineWidth, 2000)

-- Arrow ring  (child of UIParent, same as original)
local tx = UIParent:CreateTexture(nil, "ARTWORK")
tx:SetTexture(ASSET.."arrows")
tx:SetAllPoints(f)
tx:SetBlendMode("ADD")

-- Rotation animation  (identical to working Crosshairs)
local ag       = tx:CreateAnimationGroup()
local rotation = ag:CreateAnimation("Rotation")
rotation:SetDegrees(-360)
rotation:SetDuration(5)
ag:SetLooping("REPEAT")

-- ============================================================
-- Hide / Show  — HookScript registered BEFORE f:Hide() so
-- the initial hide correctly zeroes all alpha values
-- ============================================================
local function HideEverything()
    UIFrameFadeIn(circle, speed, alpha,     0)
    UIFrameFadeIn(left,   speed, lineAlpha, 0)
    UIFrameFadeIn(right,  speed, lineAlpha, 0)
    UIFrameFadeIn(top,    speed, lineAlpha, 0)
    UIFrameFadeIn(bottom, speed, lineAlpha, 0)
    UIFrameFadeIn(tx,     speed, alpha,     0)
    ag:Stop()
    f.plate = nil
end

local function ShowEverything()
    UIFrameFadeIn(circle, speed, 0, alpha)
    if showLines then
        UIFrameFadeIn(left,   speed, 0, lineAlpha)
        UIFrameFadeIn(right,  speed, 0, lineAlpha)
        UIFrameFadeIn(top,    speed, 0, lineAlpha)
        UIFrameFadeIn(bottom, speed, 0, lineAlpha)
    end
    if showArrows then
        UIFrameFadeIn(tx, speed, 0, alpha)
        ag:Play()
    end
end

f:HookScript("OnHide", HideEverything)
f:HookScript("OnShow", ShowEverything)
f:Hide()

-- Set initial line alpha (identical to working Crosshairs)
local function SetLineAlpha(a)
    left:SetAlpha(a); right:SetAlpha(a); top:SetAlpha(a); bottom:SetAlpha(a)
end
SetLineAlpha(lineAlpha)

-- ============================================================
-- Color helpers
-- ============================================================
local function SetColor(r, g, b)
    circle:SetVertexColor(r, g, b)
    left:SetVertexColor(r, g, b)
    right:SetVertexColor(r, g, b)
    top:SetVertexColor(r, g, b)
    bottom:SetVertexColor(r, g, b)
    tx:SetVertexColor(r, g, b)
end

-- Choose color based on colorMode setting (or class if no DB)
local function PickColor()
    local r, g, b = 1, 1, 1
    local cm = CrosshairsPlusDB and CrosshairsPlusDB.colorMode or "class"
    if UnitIsTapped("target") and not UnitIsTappedByPlayer("target") then
        r, g, b = 0.5, 0.5, 0.5
    elseif cm == "class" and UnitIsPlayer("target") then
        local _, class = UnitClass("target")
        if class and RAID_CLASS_COLORS and RAID_CLASS_COLORS[class] then
            local c = RAID_CLASS_COLORS[class]
            r, g, b = c.r, c.g, c.b
        else
            r, g, b = 0.274, 0.705, 0.392
        end
    else
        r, g, b = UnitSelectionColor("target")
    end
    return r, g, b
end

local function FocusPlate(plate)
    f:ClearAllPoints()
    f:SetPoint("CENTER", plate)
    f:Show()
    f.plate = plate
    SetColor(PickColor())
end

-- ============================================================
-- Apply settings to live textures
-- ============================================================
local function ApplySettings()
    local DB = CrosshairsPlusDB
    if not DB then return end

    alpha      = DB.alpha     or 0.75
    lineAlpha  = DB.lineAlpha or 0.5
    showLines  = (DB.showLines  ~= false)
    showArrows = (DB.showArrows ~= false)

    local s = DB.scale or 1.0
    f:SetSize(64 * uiScale * s, 64 * uiScale * s)

    local idx = DB.circleStyle or 1
    circle:SetTexture(CIRCLE_TEX[idx] or CIRCLE_TEX[1])

    rotation:SetDuration(DB.rotSpeed or 5)
    rotation:SetDegrees((DB.rotCW) and 360 or -360)
end

-- ============================================================
-- Event handlers  (identical structure to working Crosshairs)
-- ============================================================
function f:PLAYER_TARGET_CHANGED()
    if UnitExists("target") then
        local nameplate = LibNameplates:GetNameplateByGUID(UnitGUID("target"))
        if nameplate then
            FocusPlate(nameplate)
            return
        end
    end
    self.plate = nil
    self:Hide()
end

function f:LibNameplates_FoundGUID(_, nameplate, guid, unit)
    if nameplate and UnitIsUnit("target", unit) then
        FocusPlate(nameplate)
    end
end

function f:LibNameplates_RecycleNameplate(_, nameplate)
    if nameplate and self.plate == nameplate then
        self.plate = nil
        self:Hide()
    end
end

function f:ADDON_LOADED(name)
    if name ~= "CrosshairsPlus" then return end
    self:UnregisterEvent("ADDON_LOADED")

    -- Initialise SavedVariables
    CrosshairsPlusDB = CrosshairsPlusDB or {}
    for k, v in pairs(DEFAULTS) do
        if CrosshairsPlusDB[k] == nil then
            CrosshairsPlusDB[k] = v
        end
    end

    ApplySettings()

    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    LibNameplates.RegisterCallback(self, "LibNameplates_FoundGUID")
    LibNameplates.RegisterCallback(self, "LibNameplates_RecycleNameplate")
end

function f:PLAYER_ENTERING_WORLD()
    self:UnregisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("PLAYER_TARGET_CHANGED")
    self:PLAYER_TARGET_CHANGED()
    -- Silence the diagnostic frame (it already fired before this)
    DEFAULT_CHAT_FRAME:AddMessage("|cff22ff44CrosshairsPlus|r loaded!  Type |cffffff00/chp|r to open settings.")
end

f:RegisterEvent("ADDON_LOADED")
f:SetScript("OnEvent", function(self, event, ...)
    return self[event] and self[event](self, ...)
end)

-- ============================================================
-- Settings panel  (built lazily on first /chp call)
-- Futuristic dark-HUD style
-- ============================================================
local cfgPanel

local function BuildPanel()
    -- ── outer frame ──────────────────────────────────────────
    cfgPanel = CreateFrame("Frame", "CrosshairsPlusCfg", UIParent)
    cfgPanel:SetSize(330, 544)
    cfgPanel:SetPoint("CENTER")
    cfgPanel:SetMovable(true)
    cfgPanel:EnableMouse(true)
    cfgPanel:RegisterForDrag("LeftButton")
    cfgPanel:SetScript("OnDragStart", cfgPanel.StartMoving)
    cfgPanel:SetScript("OnDragStop",  cfgPanel.StopMovingOrSizing)
    cfgPanel:SetFrameStrata("HIGH")

    -- Dark background with 1-px sharp cyan border
    cfgPanel:SetBackdrop({
        bgFile   = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        tile = true, tileSize = 4, edgeSize = 1,
        insets = {left = 1, right = 1, top = 1, bottom = 1},
    })
    cfgPanel:SetBackdropColor(0.04, 0.07, 0.14, 0.97)
    cfgPanel:SetBackdropBorderColor(0, 0.78, 1, 1)

    -- Inner accent line below header
    local headerLine = cfgPanel:CreateTexture(nil, "ARTWORK")
    headerLine:SetTexture([[Interface\Buttons\WHITE8X8]])
    headerLine:SetVertexColor(0, 0.78, 1, 0.6)
    headerLine:SetSize(310, 1)
    headerLine:SetPoint("TOPLEFT", 10, -52)

    -- Corner accents (top-left, top-right, bottom-left, bottom-right)
    local function Corner(px, py, w, h)
        local c = cfgPanel:CreateTexture(nil, "OVERLAY")
        c:SetTexture([[Interface\Buttons\WHITE8X8]])
        c:SetVertexColor(0, 0.9, 1, 1)
        c:SetSize(w, h)
        c:SetPoint("TOPLEFT", px, py)
    end
    Corner(0,   0,   10, 2);  Corner(0,   0,   2, 10)   -- top-left  (horiz, vert)
    Corner(320, 0,   10, 2);  Corner(328, 0,   2, 10)   -- top-right
    Corner(0,  -542, 10, 2);  Corner(0,  -532, 2, 10)   -- bottom-left
    Corner(320,-542, 10, 2);  Corner(328,-532, 2, 10)   -- bottom-right

    -- ── title area ────────────────────────────────────────────
    local ttl = cfgPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    ttl:SetPoint("TOPLEFT", 14, -14)
    ttl:SetText("|cff00ccffCROSSHAIRS|cff0077ffPLUS|r")

    local ver = cfgPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    ver:SetPoint("BOTTOMLEFT", ttl, "BOTTOMRIGHT", 6, 1)
    ver:SetText("|cff336688v1.0|r")

    local made = cfgPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    made:SetPoint("TOPLEFT", ttl, "BOTTOMLEFT", 0, -2)
    made:SetText("|cff005577Made by |r|cffffd700xLT69x|r")

    local closeBtn = CreateFrame("Button", nil, cfgPanel, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", -1, -1)
    closeBtn:SetScript("OnClick", function() cfgPanel:Hide() end)

    -- ── helpers ───────────────────────────────────────────────
    -- Section header: cyan label + full-width dim divider below
    local function SHdr(txt, y)
        -- label
        local l = cfgPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        l:SetPoint("TOPLEFT", 14, y)
        l:SetText("|cff00ccff\xE2\x96\xba|r |cff00aaffUPPER" )  -- placeholder; overwritten below
        l:SetText("|cff00ccff\xE2\x96\xba|r |cff00aaff"..txt.."|r")
        -- thin divider line under label
        local div = cfgPanel:CreateTexture(nil, "ARTWORK")
        div:SetTexture([[Interface\Buttons\WHITE8X8]])
        div:SetVertexColor(0, 0.6, 0.9, 0.25)
        div:SetSize(302, 1)
        div:SetPoint("TOPLEFT", 14, y - 16)
    end

    -- Value display (right-aligned current value)
    local function ValLbl(y)
        local l = cfgPanel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        l:SetPoint("TOPRIGHT", -14, y)
        l:SetTextColor(0, 0.9, 1)
        return l
    end

    -- Slider factory
    local sliderCount = 0
    local function MakeSlider(name, y, lo, hi, step)
        sliderCount = sliderCount + 1
        local n = "CHPSl"..sliderCount
        local sl = CreateFrame("Slider", n, cfgPanel, "OptionsSliderTemplate")
        sl:SetPoint("TOPLEFT", 14, y)
        sl:SetWidth(302)
        sl:SetMinMaxValues(lo, hi)
        sl:SetValueStep(step)
        _G[n.."Low"]:SetText(tostring(lo))
        _G[n.."High"]:SetText(tostring(hi))
        _G[n.."Text"]:SetText("")
        return sl
    end

    -- ── CIRCLE STYLE  (y = -58) ───────────────────────────────
    SHdr("Circle Style", -58)
    local circLbl = cfgPanel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    circLbl:SetPoint("TOPLEFT", 72, -80)
    circLbl:SetWidth(180)
    circLbl:SetJustifyH("LEFT")
    circLbl:SetTextColor(1, 1, 1)

    local circPrev = CreateFrame("Button", nil, cfgPanel, "UIPanelButtonTemplate")
    circPrev:SetSize(26, 20); circPrev:SetText("<")
    circPrev:SetPoint("TOPLEFT", 14, -78)
    local circNext = CreateFrame("Button", nil, cfgPanel, "UIPanelButtonTemplate")
    circNext:SetSize(26, 20); circNext:SetText(">")
    circNext:SetPoint("LEFT", circPrev, "RIGHT", 4, 0)

    local function CircRefresh()
        local DB = CrosshairsPlusDB
        circLbl:SetText(DB and CIRCLE_NAMES[DB.circleStyle] or "?")
    end
    circPrev:SetScript("OnClick", function()
        local DB = CrosshairsPlusDB; if not DB then return end
        DB.circleStyle = DB.circleStyle - 1
        if DB.circleStyle < 1 then DB.circleStyle = #CIRCLE_TEX end
        circle:SetTexture(CIRCLE_TEX[DB.circleStyle] or CIRCLE_TEX[1])
        CircRefresh()
    end)
    circNext:SetScript("OnClick", function()
        local DB = CrosshairsPlusDB; if not DB then return end
        DB.circleStyle = DB.circleStyle + 1
        if DB.circleStyle > #CIRCLE_TEX then DB.circleStyle = 1 end
        circle:SetTexture(CIRCLE_TEX[DB.circleStyle] or CIRCLE_TEX[1])
        CircRefresh()
    end)

    -- ── SCALE  (y = -110) ─────────────────────────────────────
    SHdr("Scale", -110)
    local scaleVal = ValLbl(-110)
    local scaleSl  = MakeSlider("scale", -128, 0.5, 3.0, 0.05)
    _G["CHPSl"..sliderCount.."Low"]:SetText("0.5")
    scaleSl:SetScript("OnValueChanged", function(self, v)
        v = math.floor(v / 0.05 + 0.5) * 0.05
        scaleVal:SetText(string.format("%.2f", v))
        local DB = CrosshairsPlusDB; if not DB then return end
        DB.scale = v; f:SetSize(64 * uiScale * v, 64 * uiScale * v)
    end)

    -- ── OPACITY  (y = -172) ───────────────────────────────────
    SHdr("Opacity", -172)
    local alphaVal = ValLbl(-172)
    local alphaSl  = MakeSlider("alpha", -190, 0.05, 1.0, 0.05)
    _G["CHPSl"..sliderCount.."Low"]:SetText("0")
    alphaSl:SetScript("OnValueChanged", function(self, v)
        v = math.floor(v / 0.05 + 0.5) * 0.05
        alphaVal:SetText(string.format("%.2f", v))
        local DB = CrosshairsPlusDB; if not DB then return end
        DB.alpha = v; alpha = v
    end)

    -- ── LINES  (y = -236) ─────────────────────────────────────
    SHdr("Lines", -236)
    local linesCB = CreateFrame("CheckButton", "CHPLinesCB", cfgPanel, "UICheckButtonTemplate")
    linesCB:SetPoint("TOPLEFT", 14, -256)
    _G["CHPLinesCBText"]:SetText("|cffccccccShow lines|r")
    linesCB:SetScript("OnClick", function(self)
        local v = self:GetChecked() and true or false
        local DB = CrosshairsPlusDB; if not DB then return end
        DB.showLines = v; showLines = v
    end)

    SHdr("Line Opacity", -286)
    local lineAlphaVal = ValLbl(-286)
    local lineAlphaSl  = MakeSlider("linealpha", -304, 0.0, 1.0, 0.05)
    _G["CHPSl"..sliderCount.."Low"]:SetText("0")
    lineAlphaSl:SetScript("OnValueChanged", function(self, v)
        v = math.floor(v / 0.05 + 0.5) * 0.05
        lineAlphaVal:SetText(string.format("%.2f", v))
        local DB = CrosshairsPlusDB; if not DB then return end
        DB.lineAlpha = v; lineAlpha = v; SetLineAlpha(v)
    end)

    -- ── ARROWS  (y = -350) ────────────────────────────────────
    SHdr("Arrows", -350)
    local arrowsCB = CreateFrame("CheckButton", "CHPArrowsCB", cfgPanel, "UICheckButtonTemplate")
    arrowsCB:SetPoint("TOPLEFT", 14, -370)
    _G["CHPArrowsCBText"]:SetText("|cffccccccShow arrows|r")
    arrowsCB:SetScript("OnClick", function(self)
        local v = self:GetChecked() and true or false
        local DB = CrosshairsPlusDB; if not DB then return end
        DB.showArrows = v; showArrows = v
        if v then if f:IsShown() then ag:Play() end else ag:Stop() end
    end)

    local rotCWCB = CreateFrame("CheckButton", "CHPRotCWCB", cfgPanel, "UICheckButtonTemplate")
    rotCWCB:SetPoint("LEFT", arrowsCB, "RIGHT", 60, 0)
    _G["CHPRotCWCBText"]:SetText("|cffccccccClockwise|r")
    rotCWCB:SetScript("OnClick", function(self)
        local v = self:GetChecked() and true or false
        local DB = CrosshairsPlusDB; if not DB then return end
        DB.rotCW = v
        ag:Stop(); rotation:SetDegrees(v and 360 or -360)
        if showArrows and f:IsShown() then ag:Play() end
    end)

    SHdr("Rotation Speed  (sec/turn)", -400)
    local rotSpeedVal = ValLbl(-400)
    local rotSpeedSl  = MakeSlider("rotspeed", -418, 1, 30, 1)
    rotSpeedSl:SetScript("OnValueChanged", function(self, v)
        v = math.floor(v + 0.5)
        rotSpeedVal:SetText(v.."s")
        local DB = CrosshairsPlusDB; if not DB then return end
        DB.rotSpeed = v
        ag:Stop(); rotation:SetDuration(v)
        if showArrows and f:IsShown() then ag:Play() end
    end)

    -- ── COLOR MODE  (y = -462) ────────────────────────────────
    SHdr("Color Mode", -462)
    local colorLbl = cfgPanel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    colorLbl:SetPoint("TOPLEFT", 72, -484)
    colorLbl:SetWidth(190)
    colorLbl:SetJustifyH("LEFT")
    colorLbl:SetTextColor(1, 1, 1)

    local colorPrev = CreateFrame("Button", nil, cfgPanel, "UIPanelButtonTemplate")
    colorPrev:SetSize(26, 20); colorPrev:SetText("<")
    colorPrev:SetPoint("TOPLEFT", 14, -482)
    local colorNext = CreateFrame("Button", nil, cfgPanel, "UIPanelButtonTemplate")
    colorNext:SetSize(26, 20); colorNext:SetText(">")
    colorNext:SetPoint("LEFT", colorPrev, "RIGHT", 4, 0)

    local function ColorRefresh()
        local DB = CrosshairsPlusDB
        local m = DB and DB.colorMode or "class"
        colorLbl:SetText(m == "class" and "Class Color" or "Reaction Color")
    end
    local function ToggleColor()
        local DB = CrosshairsPlusDB; if not DB then return end
        DB.colorMode = (DB.colorMode == "class") and "reaction" or "class"
        ColorRefresh()
    end
    colorPrev:SetScript("OnClick", ToggleColor)
    colorNext:SetScript("OnClick", ToggleColor)

    -- ── bottom bar ────────────────────────────────────────────
    local barLine = cfgPanel:CreateTexture(nil, "ARTWORK")
    barLine:SetTexture([[Interface\Buttons\WHITE8X8]])
    barLine:SetVertexColor(0, 0.78, 1, 0.4)
    barLine:SetSize(310, 1)
    barLine:SetPoint("BOTTOMLEFT", 10, 34)

    local resetBtn = CreateFrame("Button", nil, cfgPanel, "UIPanelButtonTemplate")
    resetBtn:SetSize(116, 22)
    resetBtn:SetText("Reset Defaults")
    resetBtn:SetPoint("BOTTOMLEFT", 14, 9)
    resetBtn:SetScript("OnClick", function()
        local DB = CrosshairsPlusDB; if not DB then return end
        for k, v in pairs(DEFAULTS) do DB[k] = v end
        ApplySettings()
        scaleSl:SetValue(DB.scale); alphaSl:SetValue(DB.alpha)
        lineAlphaSl:SetValue(DB.lineAlpha); rotSpeedSl:SetValue(DB.rotSpeed)
        linesCB:SetChecked(DB.showLines and 1 or 0)
        arrowsCB:SetChecked(DB.showArrows and 1 or 0)
        rotCWCB:SetChecked(DB.rotCW and 1 or 0)
        CircRefresh(); ColorRefresh()
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ccffCrosshairsPlus|r: Settings reset to defaults.")
    end)

    local cred = cfgPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    cred:SetPoint("BOTTOMRIGHT", -14, 12)
    cred:SetText("|cff003355Made by |r|cff00aaff\xE2\x97\x86 |r|cffffd700xLT69x|r")

    -- ── populate controls from current DB ─────────────────────
    function cfgPanel:Refresh()
        local DB = CrosshairsPlusDB; if not DB then return end
        CircRefresh(); ColorRefresh()
        scaleSl:SetValue(DB.scale);         scaleVal:SetText(string.format("%.2f", DB.scale))
        alphaSl:SetValue(DB.alpha);         alphaVal:SetText(string.format("%.2f", DB.alpha))
        lineAlphaSl:SetValue(DB.lineAlpha); lineAlphaVal:SetText(string.format("%.2f", DB.lineAlpha))
        rotSpeedSl:SetValue(DB.rotSpeed);   rotSpeedVal:SetText(DB.rotSpeed.."s")
        linesCB:SetChecked(DB.showLines   and 1 or 0)
        arrowsCB:SetChecked(DB.showArrows and 1 or 0)
        rotCWCB:SetChecked(DB.rotCW       and 1 or 0)
    end

    -- Start hidden so the first /chp correctly shows the panel
    cfgPanel:Hide()
end

-- ============================================================
-- Slash command
-- ============================================================
SLASH_CROSSHAIRSPLUS1 = "/crosshairsplus"
SLASH_CROSSHAIRSPLUS2 = "/chp"
SlashCmdList["CROSSHAIRSPLUS"] = function(msg)
    msg = (msg or ""):lower():match("^%s*(.-)%s*$") or ""
    if msg == "" or msg == "config" or msg == "settings" then
        if not cfgPanel then BuildPanel() end
        if cfgPanel:IsShown() then cfgPanel:Hide()
        else cfgPanel:Refresh(); cfgPanel:Show() end
    elseif msg == "reset" then
        local DB = CrosshairsPlusDB
        if DB then
            for k, v in pairs(DEFAULTS) do DB[k] = v end
            ApplySettings()
            DEFAULT_CHAT_FRAME:AddMessage("|cff22ff44CrosshairsPlus|r: Settings reset to defaults.")
        end
    else
        DEFAULT_CHAT_FRAME:AddMessage("|cff22ff44CrosshairsPlus|r v1.0  -  by xLT69x")
        DEFAULT_CHAT_FRAME:AddMessage("  |cffffff00/chp|r          open/close settings")
        DEFAULT_CHAT_FRAME:AddMessage("  |cffffff00/chp reset|r    restore defaults")
    end
end
