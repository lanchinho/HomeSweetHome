-- ============================
--  Home Sweet Home Minimap Button
-- ============================

-- Function to open house selection dialog
local function AbrirDialogoCasas(houses)
    if not houses or #houses == 0 then
        print("No houses were found!")
        return
    end

    local frame = CreateFrame("Frame", "HomeSweetHomeDialog", UIParent, "BasicFrameTemplateWithInset")
    frame:SetSize(250, 150)
    frame:SetPoint("CENTER")
    frame.title = frame:CreateFontString(nil, "OVERLAY")
    frame.title:SetFontObject("GameFontHighlight")
    frame.title:SetPoint("TOP", frame, "TOP", 0, -10)
    frame.title:SetText("Select a house")

    local dropdown = CreateFrame("Frame", "HomeSweetHomeDropdown", frame, "UIDropDownMenuTemplate")
    dropdown:SetPoint("TOP", frame, "TOP", 0, -40)

    local selectedHouse = nil

    UIDropDownMenu_SetWidth(dropdown, 180)
    UIDropDownMenu_SetText(dropdown, "Select a house")

    UIDropDownMenu_Initialize(dropdown, function(self, level, menuList)
        local info = UIDropDownMenu_CreateInfo()
        for i, house in ipairs(houses) do
            info.text = house.name or ("Casa " .. i)
            info.func = function()
                UIDropDownMenu_SetSelectedID(dropdown, i)
                selectedHouse = house
            end
            UIDropDownMenu_AddButton(info)
        end
    end)

    local teleportButton = CreateFrame("Button", nil, frame, "GameMenuButtonTemplate")
    teleportButton:SetPoint("BOTTOM", frame, "BOTTOM", 0, 20)
    teleportButton:SetSize(120, 30)
    teleportButton:SetText("Teleport")
    teleportButton:SetScript("OnClick", function()
        if selectedHouse then                        
            C_Housing.TeleportHome(selectedHouse.neighborhoodGUID, selectedHouse.houseGUID, selectedHouse.plotID)
            frame:Hide()
        else
            print("You gotta select a house first!")
        end
    end)
end

-- main teleport function using API C_Housing
local function TeleportarCasa(arg)
    local query = arg and arg:match("^%s*(.-)%s*$") or nil -- trim spaces

    EventUtil.RegisterOnceFrameEventAndCallback("PLAYER_HOUSE_LIST_UPDATED", function(houses)
        if houses and #houses > 0 then
            if query and query ~= "" then                
                local idx = tonumber(query)
                if idx and houses[idx] then
                    local h = houses[idx]
                    C_Housing.TeleportHome(h.neighborhoodGUID, h.houseGUID, h.plotID)
                    return
                else
                    print("Invalid Number. Available houses:")
                    for i, h in ipairs(houses) do
                        print(string.format("%d: %s", i, h.name or ("House " .. i)))
                    end
                end
            else                
                AbrirDialogoCasas(houses)
            end
        else
            print("No houses were found!")
        end
    end)

    C_Housing.GetPlayerOwnedHouses()
end

local addonName = ...
local LibDBIcon = LibStub("LibDBIcon-1.0")
local LDB = LibStub("LibDataBroker-1.1"):NewDataObject("HomeSweetHome", {
    type = "launcher",
    icon = "Interface\\AddOns\\HomeSweetHome\\ui_homestone-64.blp",
    label = "HomeSweetHome",
    OnClick = function(_, button)
        if button == "LeftButton" then
            TeleportarCasa()
        end
    end,
    OnTooltipShow = function(tt)
        tt:AddLine("Home Sweet Home")
        tt:AddLine("Left click: Select a house to teleport to", 1, 1, 1)
    end
})

-- Init Frame
local init = CreateFrame("Frame")
init:RegisterEvent("ADDON_LOADED")
init:SetScript("OnEvent", function(self, event, loadedAddon)
    if loadedAddon ~= addonName then return end

    if not teleHouseDB then teleHouseDB = {} end
    teleHouseDB.minimap = teleHouseDB.minimap or { minimapPos = 225 }

    LibDBIcon:Register("HomeSweetHome", LDB, teleHouseDB.minimap)

    self:UnregisterEvent("ADDON_LOADED")
end)

-- Slash commands
SLASH_HomeSweetHome1 = "/hsh"
SLASH_HomeSweetHome2 = "/home"
SLASH_HomeSweetHome3 = "/tp"
SlashCmdList["HomeSweetHome"] = function(msg)
    TeleportarCasa(msg)
end