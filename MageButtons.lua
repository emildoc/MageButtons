-- debug, set debug level
-- 0: no debug, 1: minimal, 2: all
local debug = 0

local _, playerClass = UnitClass("player")
if playerClass ~= "MAGE" then
	print("MageButtons disabled, you are not a mage :(")
	return 0
end

local AceGUI = LibStub("AceGUI-3.0")
MageButtons = LibStub("AceAddon-3.0"):NewAddon("MageButtons", "AceEvent-3.0")
local addonName, addon = ...
local ldb = LibStub("LibDataBroker-1.1")
local channel = "RAID"
local MageButtonsMinimapIcon = LibStub("LibDBIcon-1.0")
local db
local castTable = {}
local lockStatus = 1
local showLevels = 1
local WaterSpells, FoodSpells, TelportsSpells, PortalsSpells, GemsSpells, PolymorphSpells = {}, {}, {}, {}, {}, {}
local WaterTable, FoodTable, TeleportsTable, PortalsTable, GemsTable, PolymorphTable = {}, {}, {}, {}, {}, {}

_G[addonName] = addon
addon.healthCheck = true


-- Add entries to keybinds page
BINDING_HEADER_MAGEBUTTONS = "MageButtons"
BINDING_NAME_MAGEBUTTONS_BUTTON1 = "Button 1"
BINDING_NAME_MAGEBUTTONS_BUTTON2 = "Button 2"
BINDING_NAME_MAGEBUTTONS_BUTTON3 = "Button 3"
BINDING_NAME_MAGEBUTTONS_BUTTON4 = "Button 4"
BINDING_NAME_MAGEBUTTONS_BUTTON5 = "Button 5"
BINDING_NAME_MAGEBUTTONS_BUTTON6 = "Button 6"

-- Saved Variables
MageButtonsDB = {}
if MageButtonsDB == nil then
	MageButtonsDB["position"] = {}
	MageButtonsDB["water"] = {}
	MageButtonsDB["food"] = {}
	MageButtonsDB["teleport"] = {}
	MageButtonsDB["portal"] = {}
	MageButtonsDB["managem"] = {}
	MageButtonsDB["ai"] = {}
end


-- slash commands
SlashCmdList["MAGEBUTTONS"] = function(inArgs)

	local wArgs = strtrim(inArgs)
	if wArgs == "" then
		print("usage: /magebuttons lock|move|unlock, minimap 0|1, config")
	elseif wArgs == "minimap 1" or wArgs == "minimap 0" then
		cmdarg, tog = string.split(" ", wArgs)
		MageButtons:maptoggle(tog)
	elseif wArgs == "move" or wArgs == "unlock" then
		lockStatus = addon:getSV("framelock", "lock")
		if lockStatus == 1 then
			addon:unlockAnchor()
		else
			addon:lockAnchor()
		end
	elseif wArgs == "lock" then
		addon:lockAnchor()
	elseif wArgs == "config" then
		InterfaceOptionsFrame_OpenToCategory(mbPanel)
		InterfaceOptionsFrame_OpenToCategory(mbPanel)
	else
		print("usage: /MageButtons lock|move|unlock")
	end

end
SLASH_MAGEBUTTONS1 = "/magebuttons"

-- Set some default values
local xOffset = 0
local yOffset = 0
local totalHeight, totalWidth, backdropPadding = 0, 0, 5
local backdropAnchor = "TOP"
local backdropParentAnchor = "BOTTOM"
--local backdropOffset = 0
local frameBG = "Interface\\ChatFrame\\ChatFrameBackground"
local growthDir, menuDir, btnSize, padding, border, backdropPadding, backdropRed, backdropGreen, backdropBlue, backdropAlpha, mouseover = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil


------------------
--- Main frame ---
------------------
MageButtonsConfig = CreateFrame("Frame", "MageButtonsFrame", UIParent, "BackdropTemplate")
MageButtonsConfig:SetMovable(false)
MageButtonsConfig:EnableMouse(false)
MageButtonsConfig:RegisterForDrag("LeftButton")
MageButtonsConfig:SetScript("OnDragStart", MageButtonsConfig.StartMoving)
MageButtonsConfig:SetScript("OnDragStop", MageButtonsConfig.StopMovingOrSizing)
MageButtonsConfig:SetPoint("CENTER", UIParent, "CENTER", 200, 0)
MageButtonsConfig:SetSize(40, 10)
-- SetPoint is done after ADDON_LOADED

MageButtonsFrame.texture = MageButtonsFrame:CreateTexture(nil, "BACKGROUND")
MageButtonsFrame.texture:SetAllPoints(MageButtonsFrame)
MageButtonsFrame:SetBackdrop({bgFile = [[Interface\ChatFrame\ChatFrameBackground]]})
MageButtonsFrame:SetBackdropColor(0, 0, 0, 0)

local buttonTypes = { "Water", "Food", "Teleports", "Portals", "Gems", "Polymorph"}
local btnSize = 0

local spellNames = {}
local spellLevels = {
	["5504"] = 1,
	["5505"] = 5,
	["5506"] = 15,
	["6127"] = 25,
	["10138"] = 35,
	["10139"] = 45,
	["10140"] = 55,
	["37420"] = 65,
	["43987"] = 70,
	["27090"] = 70,
	["43518"] = 75,
	["43523"] = 80,
	["587"] = 1,
	["597"] = 5,
	["990"] = 15,
	["6129"] = 25,
	["10144"] = 35,
	["10145"] = 45,
	["28612"] = 55,
	["33717"] = 70,
	["58659"] = 80,
}

--------------
--- Events ---
--------------
local function onevent(self, event, arg1, ...)
	--print(event)
	
	-- Stuff to do after addon is loaded
	if(event == "ADDON_LOADED" and arg1 == "MageButtons") then	
		-- Needs a slight delay on initial startup, don't know why
		C_Timer.After(0, function()
			C_Timer.After(2, function()
			
				-- Set up lists of spells
				WaterSpells = {5504, 5505, 5506, 6127, 10138, 10139, 10140, 37420, 27090, 43523, 42955, 42956}
				FoodSpells = {587, 597, 990, 6129, 10144, 10145, 28612, 43987, 33717, 43523, 58659}
				TelportsSpells = {}
				PortalsSpells = {}
				if UnitFactionGroup("player") == "Alliance" then
					TeleportsSpells = {3565, 3561, 3562, 32271, 49359, 33690, 53140}
					PortalsSpells = {11419, 10059, 11416, 32266, 49360, 33691, 53142}
				else
					TeleportsSpells = {3566, 3563, 3567, 32272, 49358, 35715, 53140}
					PortalsSpells = {11420, 11418, 11417, 32267, 49361, 35717, 53142}
				end
				GemsSpells = {759, 3552, 10053, 10054, 27101, 42985}
				
				if IsPlayerSpell(12826) then sheep = 12826
				elseif IsPlayerSpell(12825) then sheep = 12825
				elseif IsPlayerSpell(12824) then sheep = 12824
				elseif IsPlayerSpell(118) then sheep = 118
				else sheep = 9999 end
				PolymorphSpells = {sheep, 28272, 28271, 28270}
				
				
				local spellTables = {}
				spellTables["Water"] = {5504, 5505, 5506, 6127, 10138, 10139, 10140, 37420, 43987, 27090, 43518, 43523, 42955, 42956}
				spellTables["Food"] = {587, 597, 990, 6129, 10144, 10145, 28612, 43987, 33717, 43518, 43523, 58659}
				if UnitFactionGroup("player") == "Alliance" then
					spellTables["Teleports"] = {3565, 3561, 3562, 32271, 49359, 33690, 53140}
					spellTables["Portals"] = {11419, 10059, 11416, 32266, 49360, 33691, 53142}
				else
					spellTables["Teleports"] = {3566, 3563, 3567, 32272, 49358, 35715, 53140}
					spellTables["Portals"] = {11420, 11418, 11417, 32267, 49361, 35717, 53142}
				end
				spellTables["Gems"] = {759, 3552, 10053, 10054, 27101, 42985}
				spellTables["Polymorph"] = {sheep, 28272, 28271, 28270}
				
				----------------------------------------
				-- Create tables from the spell lists --
				----------------------------------------
				-- for k = 1, #buttonTypes, 1 do
					-- local btnType = buttonTypes[k]
					
					-- For each type of spell in buttonTypes table
					--   get number of spells
					--   create table of that type with spells that are known (trained)
					--if btnType ~= nil and btnType ~= "none" then

						-- local obj2 = btnType .. [[Table = {}
						-- for i = 1, #]] .. btnType .. [[Spells, 1 do
							-- if IsPlayerSpell(]] .. btnType .. [[Spells[i]) then
								
								-- local ]] .. btnType .. [[Name = GetSpellInfo(]] .. btnType .. [[Spells[i]) .. "(" .. GetSpellSubtext(]] .. btnType .. [[Spells[i]) .. ")"

								-- table.insert(]] .. btnType .. [[Table, ]] .. btnType .. [[Name)
							-- end
						-- end	]]
						
						WaterTable = {}
						for i = 1, #WaterSpells, 1 do
							if IsPlayerSpell(WaterSpells[i]) then
								local WaterName = GetSpellInfo(WaterSpells[i]) .. "(" .. GetSpellSubtext(WaterSpells[i]) .. ")"
								table.insert(WaterTable, WaterName)
							end
						end
						
						FoodTable = {}
						for i = 1, #FoodSpells, 1 do
							if IsPlayerSpell(FoodSpells[i]) then
								local FoodName = GetSpellInfo(FoodSpells[i]) .. "(" .. GetSpellSubtext(FoodSpells[i]) .. ")"
								table.insert(FoodTable, FoodName)
							end
						end
						
						TeleportsTable = {}
						for i = 1, #TeleportsSpells, 1 do
							if IsPlayerSpell(TeleportsSpells[i]) then
								local TeleportsName = GetSpellInfo(TeleportsSpells[i]) .. "(" .. GetSpellSubtext(TeleportsSpells[i]) .. ")"
								table.insert(TeleportsTable, TeleportsName)
							end
						end
						
						PortalsTable = {}
						for i = 1, #PortalsSpells, 1 do
							if IsPlayerSpell(PortalsSpells[i]) then
								local PortalsName = GetSpellInfo(PortalsSpells[i]) .. "(" .. GetSpellSubtext(PortalsSpells[i]) .. ")"
								table.insert(PortalsTable, PortalsName)
							end
						end
						
						GemsTable = {}
						for i = 1, #GemsSpells, 1 do
							if IsPlayerSpell(GemsSpells[i]) then
								local GemsName = GetSpellInfo(GemsSpells[i]) .. "(" .. GetSpellSubtext(GemsSpells[i]) .. ")"
								table.insert(GemsTable, GemsName)
							end
						end
						
						PolymorphTable = {}
						for i = 1, #PolymorphSpells, 1 do
							if IsPlayerSpell(PolymorphSpells[i]) then
								local PolymorphName = GetSpellInfo(PolymorphSpells[i]) .. "(" .. GetSpellSubtext(PolymorphSpells[i]) .. ")"
								table.insert(PolymorphTable, PolymorphName)
							end
						end
						
						-- execute the above command
						-- local cmdRun2 = assert(loadstring(obj2))
						-- cmdRun2()
					-- end
				-- end
				
				-- Get saved frame location
				local relPoint, anchorX, anchorY = addon:getAnchorPosition()
				MageButtonsConfig:ClearAllPoints()
				MageButtonsConfig:SetPoint(relPoint, UIParent, relPoint, anchorX, anchorY)
				
				

				addon:makeBaseButtons()

				-----------------
				-- Data Broker --
				-----------------
				lockStatus = addon:getSV("framelock", "lock")
				
				db = LibStub("AceDB-3.0"):New("MageButtonsDB", SettingsDefaults)
				MageButtonsDB.db = db;
				MageButtonsMinimapData = ldb:NewDataObject("MageButtons",{
					type = "data source",
					text = "MageButtons",
					icon = "Interface/Icons/Spell_Holy_MagicalSentry.blp",
					OnClick = function(self, button)
						if button == "RightButton" then
							if IsShiftKeyDown() then
								MageButtons:maptoggle("0")
								print("MageButtons: Hiding icon, re-enable with: /MageButtons minimap 1")
							else
								InterfaceOptionsFrame_OpenToCategory(mbPanel)
								InterfaceOptionsFrame_OpenToCategory(mbPanel)
								InterfaceOptionsFrame_OpenToCategory(mbPanel)
							end
						
						elseif button == "LeftButton" then
							if lockStatus == 0 then
								-- Not locked, lock it and save the anchor position
								addon:lockAnchor()
							else
								-- locked, unlock
								addon:unlockAnchor()
							end
						end
					end,
					
					-- Minimap Icon tooltip
					OnTooltipShow = function(tooltip)
						tooltip:AddLine("|cffffffffMageButtons|r\nLeft-click to lock/unlock.\nRight-click to configure.\nShift+Right-click to hide minimap button.")
					end,
				})
				
				-- display the minimap icon?
				local mmap = addon:getSV("minimap", "icon") or 1
				if mmap == 1 then
					MageButtonsMinimapIcon:Register("mageButtonsIcon", MageButtonsMinimapData, MageButtonsDB)
					addon:maptoggle(1)
				else
					addon:maptoggle(0)
				end
			end); --end of 2 second delay
		end); --end of 0 second delay
	end
end

-------------------------------
--- Minimap toggle function ---
-------------------------------
function addon:maptoggle(mtoggle)
	if ( debug == 1 ) then print("icon state: " .. mtoggle) end
	
	local mmTbl = {
		icon = mtoggle
	}
	
	MageButtonsDB["minimap"] = mmTbl
	
	if mtoggle == "0" or mtoggle == 0 then
		if ( debug >= 1 ) then print("hiding icon") end
		MageButtonsMinimapIcon:Hide("mageButtonsIcon")
	else
		if (MageButtonsMinimapIcon:IsRegistered("mageButtonsIcon")) then
			MageButtonsMinimapIcon:Show("mageButtonsIcon")
		else
			MageButtonsMinimapIcon:Register("mageButtonsIcon", MageButtonsMinimapData, MageButtonsDB)
			MageButtonsMinimapIcon:Show("mageButtonsIcon")
		end
	end
end

------------------------
-- Lock/Unlock anchor --
------------------------
function addon:lockAnchor()
	MageButtonsConfig:SetMovable(false)
	MageButtonsConfig:EnableMouse(false)
	MageButtonsFrame:SetBackdropColor(0, 0, 0, 0)

	local _, _, relativePoint, xPos, yPos = MageButtonsConfig:GetPoint()
	addon:setAnchorPosition(relativePoint, xPos, yPos)
	lockStatus = 1
	lockTbl = {
		lock = 1,
	}

	MageButtonsDB["framelock"] = lockTbl
end

function addon:unlockAnchor()
MageButtonsConfig:SetMovable(true)
	MageButtonsConfig:EnableMouse(true)
	MageButtonsFrame:SetBackdropColor(0, .7, 1, 1)
	lockStatus = 0
	lockTbl = {
		lock = 0,
	}

	MageButtonsDB["framelock"] = lockTbl
end

------------------------------
-- Retrieve anchor position --
------------------------------
function addon:getAnchorPosition()
	local posTbl = MageButtonsDB["position"]
	if posTbl == nil then
		return "CENTER", 200, -200
	else
		-- Table exists, get the value if it is defined
		relativePoint = posTbl["relativePoint"] or "CENTER"
		xPos = posTbl["xPos"] or 200
		yPos = posTbl["yPos"] or -200
		return relativePoint, xPos, yPos
	end
end

--------------------------
-- Save anchor position --
--------------------------
function addon:setAnchorPosition(relativePoint, xPos, yPos)
	posTbl = {
		relativePoint = relativePoint,
		xPos = xPos,
		yPos = yPos,
	}

	MageButtonsDB["position"] = posTbl
	
	--MageButtonsConfig:SetPoint("CENTER", xPos, yPos)
end

local baseButtons = {}
local baseButtonBackdrops = {}
local baseButtonBackdropFrames = {}
local menuStatus = {}
local teleportButtons, portalButtons, polymorphButtons = {}, {}, {}
local buttonBackdrops = {}
local buttonStore = {}
local backdropStore = {}

------------------
-- Base Buttons --
------------------
function addon:makeBaseButtons()
	local baseSpells = { Water = WaterTable[#WaterTable], Food = FoodTable[#FoodTable], Teleports = TeleportsTable[#TeleportsTable], Portals = PortalsTable[#PortalsTable], Gems = GemsTable[#GemsTable], Polymorph = PolymorphTable[#PolymorphTable]}
	local spellCounts = {Water = #WaterTable, Food = #FoodTable, Teleports = #TeleportsTable, Portals = #PortalsTable, Gems = #GemsTable, Polymorph = #PolymorphTable}
	local createButtonMenu = {addon:getSV("buttons", "a") or buttonTypes[1], addon:getSV("buttons", "b") or buttonTypes[2], 
							  addon:getSV("buttons", "c") or buttonTypes[3], addon:getSV("buttons", "d") or buttonTypes[4], 
							  addon:getSV("buttons", "e") or buttonTypes[5], addon:getSV("buttons", "f") or buttonTypes[6]}

	-- These store the menu state for each button (0 = closed, 1 = open)
	WaterMenu, FoodMenu, TeleportsMenu, PortalsMenu, GemsMenu, PolymorphMenu = 0, 0, 0, 0, 0, 0
	
	-- Pull items from Saved Variables
	growthDir = addon:getSV("growth", "direction") or "Horizontal"
	menuDir = addon:getSV("growth", "buttons") or "Up"
	btnSize = addon:getSV("buttonSettings", "size") or 26
	padding = addon:getSV("buttonSettings", "padding") or 5
	border = addon:getSV("borderStatus", "borderStatus") or 1
	backdropPadding = addon:getSV("buttonSettings", "bgpadding") or 2.5
	backdropRed = addon:getSV("bgcolor", "red") or .1
	backdropGreen = addon:getSV("bgcolor", "green") or .1
	backdropBlue = addon:getSV("bgcolor", "blue") or .1
	backdropAlpha = addon:getSV("bgcolor", "alpha") or 1
	mouseover = MageButtons:getSV("mouseover", "mouseover") or 0

	local keybindTable = {"MAGEBUTTONS_BUTTON1", "MAGEBUTTONS_BUTTON2", "MAGEBUTTONS_BUTTON3", "MAGEBUTTONS_BUTTON4", "MAGEBUTTONS_BUTTON5", "MAGEBUTTONS_BUTTON6"}
	
	local j = 0
	for j = 1, #createButtonMenu, 1 do
		--createItem = createButtonMenu[j]
		local btnType = createButtonMenu[j]
		local baseSpell = baseSpells[btnType]
		local spellCount = spellCounts[btnType]
		--local keybind = "U"

		if baseSpell ~= nil and baseSpell ~= "none" then
			--keybind = GetBindingKey("MAGEBUTTONS_BUTTON1")
			--print(keybind)
			
			-- Hide the button if it already exists
			if baseButtons[btnType] then
				baseButtons[btnType]:Hide()
			end
			
			-- Create new button
			local baseButton = CreateFrame("Button", btnType .. "Base", MageButtonsConfig, "SecureActionButtonTemplate");
			baseButton:RegisterForClicks("LeftButtonDown", "RightButtonDown")
			baseButton:SetAttribute("*type1", "spell");
			baseButton:SetAttribute("spell", baseSpell);
			
			-- Get keybindings
			--print(GetBindingKey(keybindTable[j]))
			if GetBindingKey(keybindTable[j]) ~= nil then
				--print("bound")
				keybind = GetBindingKey(keybindTable[j])
				SetBindingClick(keybind, baseButton:GetName());
			end
			
			-- default menu status to 0 (closed)
			menuStatus[j] = 0
			
			-- Set the click properties of the button
			-- Left click: cast spell; Right click: open or close menu
			baseButton:SetScript("PostClick", function(self, button)
				if button == "RightButton" then
					if menuStatus[j] == 0 then
						MageButtons:showButtons(btnType, spellCount)
						menuStatus[j] = 1
					else
						MageButtons:hideButtons(btnType, spellCount)
						menuStatus[j] = 0
					end
				else
					MageButtons:hideButtons(btnType, spellCount)
					menuStatus[j] = 0
				end
			end)
			

			-- Button properties
			baseButton:SetPoint("TOP", MageButtonsFrame, "BOTTOM", xOffset, yOffset)
			baseButton:SetSize(btnSize, btnSize)
			baseButton:SetFrameStrata("HIGH")
			baseButton.t = baseButton:CreateTexture(nil, "BACKGROUND")
			local _, _, buttonTexture = GetSpellInfo(baseSpell)
			baseButton.t:SetTexture(buttonTexture)
			
			if border == 1 then
				baseButton.t:SetTexCoord(0.06,0.94,0.06,0.94)
			end
			baseButton.t:SetAllPoints()
			
			-- Tooltip
			baseButton:SetScript("OnEnter",function(self,motion)
				GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
				GameTooltip:ClearAllPoints()
				GameTooltip:SetPoint("BOTTOMLEFT", baseButton, "TOPRIGHT", 10, 5)
				GameTooltip:SetSpellBookItem(MageButtons:getTooltipNumber(baseSpell), BOOKTYPE_SPELL)
				GameTooltip:Show()
				
				if mouseover == 1 then
					-- Display menu on mouseover
					MageButtons:showButtons(btnType, spellCount)
				end
			end)
			
			baseButton:SetScript("OnLeave",function(self,motion)
				GameTooltip:Hide()
				
				if mouseover == 1 then
					-- Hide menu
					MageButtons:hideButtons(btnType, spellCount)
				end
			end)
			
			-- Store the button in a table for easy access
			baseButtons[btnType] = baseButton



			-- Hide the background if it already exits
			if baseButtonBackdrops[btnType] then
				baseButtonBackdrops[btnType]:Hide()
			end
			
			-- Create new backdrop
			local baseButtonBackdrop = CreateFrame("Frame", "baseButtonBackdropFrame" .. j, UIParent, "BackdropTemplate")
			baseButtonBackdrop:ClearAllPoints()
			baseButtonBackdrop:SetPoint("CENTER", baseButtons[btnType], "CENTER", 0, 0)
			baseButtonBackdrop:SetSize(btnSize + backdropPadding * 2, btnSize + backdropPadding * 2)
			
			-- Store it in table
			baseButtonBackdrops[btnType] = baseButtonBackdrop

			baseButtonBackdrops[btnType].texture = baseButtonBackdrops[btnType]:CreateTexture(nil, "BACKGROUND")
			baseButtonBackdrops[btnType].texture:ClearAllPoints()
			baseButtonBackdrops[btnType].texture:SetAllPoints(baseButtonBackdrops[btnType])
			baseButtonBackdrops[btnType]:SetBackdrop({bgFile = "Interface\\ChatFrame\\ChatFrameBackground"})
			baseButtonBackdrops[btnType]:SetBackdropColor(backdropRed, backdropGreen, backdropBlue, backdropAlpha)
			
			if mouseover == 1 then
				baseButtonBackdrops[btnType]:SetScript("OnEnter",function(self,motion)
					-- Display menu on mouseover
					MageButtons:showButtons(btnType, spellCount)
				end)

				baseButtonBackdrops[btnType]:SetScript("OnLeave",function(self,motion)
					-- Hide menu
					MageButtons:hideButtons(btnType, spellCount)
				end)
			end

			-- Show the backdrop
			baseButtons[btnType]:Show()
			

			-- Determine the growth criteria based on user settings
			if growthDir == "Vertical" then
				yOffset = yOffset - (btnSize + padding)
				totalHeight = -(yOffset - backdropPadding)
				totalWidth = btnSize + backdropPadding + backdropPadding
				xOffset = 0
			elseif growthDir == "Horizontal" then
				yOffset = 0
				xOffset = xOffset + (btnSize + padding)
				totalHeight = btnSize + backdropPadding + backdropPadding
				totalWidth = xOffset + backdropPadding
				backdropAnchor = "TOPLEFT"
				backdropParentAnchor = "BOTTOM"
				--backdropOffset = -(btnSize / 2 + backdropPadding)
			else
				print("MageButtons: Invalid growth direction")
			end
		end
		
	end
	

	-- Create the menu buttons for each spell type
	showLevels = MageButtons:getSV("showlevels", "levels") or 1
	MageButtons:makeButtons("Water", WaterTable)
	MageButtons:makeButtons("Food", FoodTable)
	MageButtons:makeButtons("Teleports", TeleportsTable)
	MageButtons:makeButtons("Portals", PortalsTable)
	MageButtons:makeButtons("Gems", GemsTable)
	MageButtons:makeButtons("Polymorph", PolymorphTable)
	
	xOffset = 0
	yOffset = 0
end

-----------------------
-- Make menu buttons --
-----------------------
function addon:makeButtons(btnType, typeTable)
	-- Create buttons of the requested type
	-- type = Portal, Water, etc
	-- typeTable = table of values from the start of this file (WaterTable, etc)
	-- i = index to define unique button names (PortalsButton1, PortalsButton2, etc)
	local btnAnchor = nil
	local parentAnchor = nil
	local xOffset = 0
	local yOffset = 0
	
	local spellCounts = {Water = #WaterTable, Food = #FoodTable, Teleports = #TeleportsTable, Portals = #PortalsTable, Gems = #GemsTable, Polymorph = #PolymorphTable}
	local spellCount = spellCounts[btnType]
	
	--print(btnSize, menuDir)

	if menuDir == "Down" then
		--yOffset = yOffset - (btnSize + padding)
		btnAnchor = "TOP"
		parentAnchor = "BOTTOM"
		yOffset = -padding
		yOffsetGrowth = -(btnSize + padding)
		xOffsetGrowth = 0
	elseif menuDir == "Up" then
		--yOffset = yOffset + (btnSize + padding)
		btnAnchor = "BOTTOM"
		parentAnchor = "TOP"
		yOffset = padding
		yOffsetGrowth = btnSize + padding
		xOffsetGrowth = 0
	elseif menuDir == "Right" then
		--xOffset = xOffset + (btnSize + padding)
		btnAnchor = "LEFT"
		parentAnchor = "RIGHT"
		xOffset = padding
		yOffsetGrowth = 0
		xOffsetGrowth = btnSize + padding
	elseif menuDir == "Left" then
		--yOffset = 0
		--xOffset = xOffset - (btnSize + padding)	
		btnAnchor = "RIGHT"
		parentAnchor = "LEFT"
		xOffset = -padding
		yOffsetGrowth = 0
		xOffsetGrowth = -(btnSize + padding)
	else
		print("MageButtons: Invalid growth direction")
	end
	
	local i
	for i = 1, #typeTable, 1 do
		if typeTable[i] ~= nil then

			-- Hide the button if it already exists
			if buttonStore[btnType .. i] then
				backdropStore[btnType .. i]:Hide()
				buttonStore[btnType .. i]:Hide()
			end

			-- Create new button
			local button = CreateFrame("Button", "button", MageButtonsConfig)
			button:ClearAllPoints()

			button:SetPoint(btnAnchor, baseButtons[btnType], parentAnchor, xOffset, yOffset)
			button:SetSize(btnSize, btnSize)
			button:SetFrameStrata("HIGH")
			button:SetScript("OnClick", function()
				MageButtons:hideButtons(btnType, #typeTable)
				baseButtons[btnType]:SetAttribute("spell", typeTable[i])
				local _, _, buttonTexture = GetSpellInfo(typeTable[i])
				baseButtons[btnType].t:ClearAllPoints()
				baseButtons[btnType].t:SetTexture(nil)
				baseButtons[btnType].t:SetTexture(buttonTexture)
				baseButtons[btnType].t:SetAllPoints()
				
				baseButtons[btnType]:SetScript("OnEnter",function(self,motion)
					GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
					GameTooltip:ClearAllPoints()
					GameTooltip:SetPoint("BOTTOMLEFT", self, "TOPRIGHT", 10, 5)
					
					-- Get Tooltip from spellbook
					-- Only works for lower ranks if "Show all spell ranks" is checked in the spellbook
					local tooltipNum = MageButtons:getTooltipNumber(typeTable[i])
					if tooltipNum ~= nil then
						GameTooltip:SetSpellBookItem(MageButtons:getTooltipNumber(typeTable[i]), BOOKTYPE_SPELL)
					else
						-- spell was not found, just display the name
						GameTooltip:SetText(typeTable[i])
					end
					
					if mouseover == 1 then
						-- Display menu on mouseover
						MageButtons:showButtons(btnType, spellCount)
					end
					
					GameTooltip:Show()
				end)

				baseButtons[btnType]:SetScript("OnLeave",function(self,motion)
					GameTooltip:Hide()
					
					if mouseover == 1 then
						-- Hide menu
						MageButtons:hideButtons(btnType, spellCount)
					end
				end)
			end)
			
			-- Tooltip
			button:SetScript("OnEnter",function(self,motion)
				GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
				GameTooltip:ClearAllPoints()
				GameTooltip:SetPoint("BOTTOMLEFT", self, "TOPRIGHT", 10, 5)
				
				-- Get Tooltip from spellbook
				-- Only works for lower ranks if "Show all spell ranks" is checked in the spellbook
				local tooltipNum = MageButtons:getTooltipNumber(typeTable[i])
				if tooltipNum ~= nil then
					GameTooltip:SetSpellBookItem(MageButtons:getTooltipNumber(typeTable[i]), BOOKTYPE_SPELL)
					if showLevels == 1 then
						local level = addon:showLevel(typeTable[i])
						if level ~= nil then
							GameTooltip:AddLine("Level " .. level)
						end
					end
				else
					-- spell was not found, just display the name
					GameTooltip:SetText(typeTable[i])
					if showLevels == 1 then
						local level = addon:showLevel(typeTable[i])
						if level ~= nil then
							GameTooltip:AddLine("Level " .. level)
						end
					end
				end
				
				GameTooltip:Show()
				
				if mouseover == 1 then
					-- Display menu on mouseover
					addon:showButtons(btnType, spellCount)
				end
			end)
			
			button:SetScript("OnLeave",function(self,motion)
				GameTooltip:Hide()
				
				if mouseover == 1 then
					-- Hide menu
					addon:hideButtons(btnType, spellCount)
				end
			end)
			
			-- Store the button in a table
			buttonStore[btnType .. i] = button

			button.t = button:CreateTexture(nil, "BACKGROUND")
			local _, _, buttonTexture2 = GetSpellInfo(typeTable[i])
			button.t:SetTexture(buttonTexture2)
			if border == 1 then
				button.t:SetTexCoord(0.1,0.9,0.1,0.9)
			end
			button.t:SetAllPoints()
			

			-- Create button background
			local buttonBackdrop = CreateFrame("Frame", btnType .. "buttonBackdropFrame" .. i, UIParent, "BackdropTemplate")
			buttonBackdrop:SetPoint("CENTER", buttonStore[btnType .. i], "CENTER", 0, 0)
			buttonBackdrop:SetSize(btnSize + backdropPadding * 2, btnSize + backdropPadding * 2)

			buttonBackdrop.texture = buttonBackdrop:CreateTexture(nil, "BACKGROUND")
			buttonBackdrop.texture:ClearAllPoints(buttonBackdrop)
			buttonBackdrop.texture:SetAllPoints(buttonBackdrop)
			buttonBackdrop:SetBackdrop({bgFile = "Interface\\ChatFrame\\ChatFrameBackground"})
			buttonBackdrop:SetBackdropColor(backdropRed, backdropGreen, backdropBlue, backdropAlpha)
			buttonBackdrop:SetFrameStrata("HIGH")
			
			if mouseover == 1 then
				buttonBackdrop:SetScript("OnEnter",function(self,motion)
					-- Display menu on mouseover
					addon:showButtons(btnType, spellCount)
				end)
				
				buttonBackdrop:SetScript("OnLeave",function(self,motion)
					-- Hide menu
					addon:hideButtons(btnType, spellCount)
				end)
			end
						
			backdropStore[btnType .. i] = buttonBackdrop
		
			backdropStore[btnType .. i]:Hide()
			buttonStore[btnType .. i]:Hide()
			
			yOffset = yOffset + yOffsetGrowth
			xOffset = xOffset + xOffsetGrowth
		end
	end
end

-- Show the menu buttons
function addon:showButtons(btnType, count)
	for i = 1, count, 1 do
		buttonStore[btnType .. i]:Show()
		backdropStore[btnType .. i]:Show()
	end
end

-- Hide the menu buttons
function addon:hideButtons(btnType, count)
	for i = 1, count, 1 do
		buttonStore[btnType .. i]:Hide()
		backdropStore[btnType .. i]:Hide()
	end
end

-- Get tooltip information
function addon:getTooltipNumber(spellName)
	local slot = 1
	while true do
		local spell, rank = GetSpellBookItemName(slot, BOOKTYPE_SPELL)
		if rank ~= nil then
			spell = spell .. "(" .. rank .. ")"
		end

		if (not spell) then
			break
		elseif (spell == spellName) then
			return slot
		end
	   slot = slot + 1
	end
end

-- Function to retrieve Saved Variables
function addon:getSV(category, variable)
	local vartbl = MageButtonsDB[category]
	
	if vartbl == nil then
		vartbl = {}
	end
	
	if ( vartbl[variable] ~= nil ) then
		--print("getSV - " .. variable .. ": " .. vartbl[variable])
		return vartbl[variable]
	else
		return nil
	end
end

function addon:showLevel(spellName)
-- Add level requirement
	local level = 0

	if showLevels then
		local _, _, _, _, _, _, spellID = GetSpellInfo((spellName))
		local level = spellLevels[tostring(spellID)]
		--rint(typeTable[i], level)
		--print(typeTable[i], spellID, level)
		--GameTooltip:AddLine(level)
		return level
	end
end

-- Not used
-- function addon:getButtonType(btnNumber)
	-- local buttontbl = MageButtonsDB["buttons"]
	-- if ( buttontbl[btnNumber] == "none" ) then
		-- return "none"
	-- else
		-- return buttontbl[btnNumber]
	-- end
-- end

-- Register Events
MageButtonsConfig:RegisterEvent("ADDON_LOADED")
MageButtonsConfig:RegisterEvent("PLAYER_ALIVE")
MageButtonsConfig:RegisterEvent("SPELLS_CHANGED")
MageButtonsConfig:RegisterEvent("PLAYER_ENTERING_WORLD")
MageButtonsConfig:SetScript("OnEvent", onevent)