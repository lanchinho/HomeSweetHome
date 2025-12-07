-- ============================
--  Home Sweet Home Minimap Button
-- ============================

-- Função principal de teleporte usando API C_Housing
local function TeleportarCasa()
    EventUtil.RegisterOnceFrameEventAndCallback("PLAYER_HOUSE_LIST_UPDATED", function(a)
        if a and a[1] then
            C_Housing.TeleportHome(a[1].neighborhoodGUID, a[1].houseGUID, a[1].plotID)
        else
            print("House not found!")
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
        tt:AddLine("Clique esquerdo: Teleportar para Casa", 1, 1, 1)
    end
})

-- Frame de inicialização
local init = CreateFrame("Frame")
init:RegisterEvent("ADDON_LOADED")
init:SetScript("OnEvent", function(self, event, loadedAddon)
    if loadedAddon ~= addonName then return end

    -- SavedVariable para posição do botão
    if not teleHouseDB then teleHouseDB = {} end
    teleHouseDB.minimap = teleHouseDB.minimap or { minimapPos = 225 }

    -- Registrar botão no minimapa
    LibDBIcon:Register("HomeSweetHome", LDB, teleHouseDB.minimap)

    self:UnregisterEvent("ADDON_LOADED")
end)

-- Slash command /teleportar
SLASH_HomeSweetHome1 = "/hsh"
SLASH_HomeSweetHome2 = "/home"
SLASH_HomeSweetHome3 = "/tphome"
SLASH_HomeSweetHome4 = "/teleport"
SlashCmdList["HomeSweetHome"] = function(msg)
    TeleportarCasa()
end