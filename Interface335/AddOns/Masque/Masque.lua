--[[

	This file is part of 'Masque', an add-on for World of Warcraft. For bug reports,
	suggestions and license information, please visit https://github.com/SFX-WoW/Masque.

	* File...: Masque.lua
	* Author.: StormFX

	Add-On Setup

]]

local MASQUE, Core = ...

assert(LibStub, MASQUE.." requires LibStub.")

----------------------------------------
-- Lua
---

local print = print

----------------------------------------
-- Locals
---

local Masque = LibStub("AceAddon-3.0"):NewAddon(MASQUE)

-- @ Locales\enUS
local L = Core.Locale

-- Client Version
local WOW_RETAIL = (select(4, GetBuildInfo()) > 20000) and true or nil
Core.WOW_RETAIL = WOW_RETAIL

-- Classic-Compatible New Line
Core.CRLF = "\n "

----------------------------------------
-- API
---

do
	local VERSION = 90002
	Core.API = LibStub:NewLibrary(MASQUE, VERSION)

	----------------------------------------
	-- Internal
	---

	Core.API_VERSION = VERSION
	Core.OLD_VERSION = 70200

	-- Core Info
	Core.Version = GetAddOnMetadata(MASQUE, "Version")
	Core.Authors = {
		"StormFX",
		"|cff999999JJSheets|r",
	}
	Core.Websites = {
		"https://github.com/SFX-WoW/Masque",
		"https://www.wowace.com/projects/masque",
		"https://www.curseforge.com/wow/addons/masque",
		"https://www.wowinterface.com/downloads/info12097",
	}
end

----------------------------------------
-- Add-On
---

-- ADDON_LOADED Event
function Masque:OnInitialize()
	local Defaults = {
		profile = {
			Debug = false,
			SkinInfo = true,
			StandAlone = false,
			Groups = {
				["*"] = {
					Backdrop = false,
					Colors = {},
					Disabled = false,
					Gloss = false,
					Inherit = true,
					Pulse = true,
					Shadow = false,
					SkinID = "Classic",
				},
			},
			LDB = {
				hide = true,
				minimapPos = 220,
				radius = 80,
			},
		},
	}

	local db = LibStub("AceDB-3.0"):New("MasqueDB", Defaults, true)
	db.RegisterCallback(Core, "OnProfileChanged", "UpdateProfile")
	db.RegisterCallback(Core, "OnProfileCopied", "UpdateProfile")
	db.RegisterCallback(Core, "OnProfileReset", "UpdateProfile")
	Core.db = db

	local LDS = WOW_RETAIL and LibStub("LibDualSpec-1.0", true)
	if LDS then
		LDS:EnhanceDatabase(Core.db, MASQUE)
	end

	SLASH_MASQUE1 = "/msq"
	SLASH_MASQUE2 = "/masque"

	SlashCmdList["MASQUE"] = function(Cmd, ...)
		if Cmd == "debug" then
			Core.ToggleDebug()
		else
			Core:ToggleOptions()
		end
	end
end

-- PLAYER_LOGIN Event
function Masque:OnEnable()
	local Setup = Core.Setup
	if Setup then
		Setup("Core")
		Setup("LDB")
	end

	if Core.Queue then
		Core.Queue:ReSkin()
	end
end

-- Wrapper for the DB:CopyProfile method.
function Masque:CopyProfile(Name, Silent)
	Core.db:CopyProfile(Name, Silent)
end

-- Wrapper for the DB:SetProfile method.
function Masque:SetProfile(Name)
	Core.db:SetProfile(Name)
end

----------------------------------------
-- Core
---

-- Toggles debug mode.
function Core.ToggleDebug()
	local db = Core.db.profile
	local Debug = not db.Debug

	db.Debug = Debug
	Core.Debug = Debug

	if Debug then
		print("|cffffff99"..L["Masque debug mode enabled."].."|r")
	else
		print("|cffffff99"..L["Masque debug mode disabled."].."|r")
	end
end

-- Updates on profile activity.
function Core:UpdateProfile()
	self.Debug = self.db.profile.Debug

	local Global = self.GetGroup()
	Global:__Update()

	self.Setup("Info")

	local LDBI = LibStub("LibDBIcon-1.0", true)
	if LDBI then
		LDBI:Refresh(MASQUE, Core.db.profile.LDB)
	end
end
