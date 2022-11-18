local _, playerClass = UnitClass("player")
if playerClass ~= "MAGE" then
	print("MageButtons disabled, you are not a mage :(")
	return 0
end

local addonName, addon = ...
local debug = 0
local AceGUI = LibStub("AceGUI-3.0")
local btnTbl = {}
local directionTbl = {}


-- Main options panel
mbPanel = CreateFrame("Frame")
mbPanel.name = addonName
InterfaceOptions_AddCategory(mbPanel)

-- Title Text
local title = mbPanel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
title:SetPoint("TOPLEFT", 16, -16)
title:SetText(addonName)

-- Label for dropdown boxes
local usageText = mbPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
usageText:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -70)
usageText:SetJustifyH("LEFT")
usageText:SetText("Button Order (left to right, or top to bottom):")

-- Bottom usage text
local usageText2 = mbPanel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
usageText2:SetPoint("TOP", 0, -420)
usageText2:SetJustifyH("CENTER")
usageText2:SetText("Some changes require a reload UI (/reload) to work, such as reordering menus.")

if UnitLevel("player") < 60 then
	local usageText3 = mbPanel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
	usageText3:SetPoint("TOP", usageText2, "BOTTOM", 0, -10)
	usageText3:SetJustifyH("CENTER")
	usageText3:SetText("And learning new spells from trainers.")
end

---------------------------------
-- Checkbox for Button Borders --
---------------------------------
local mbBorderCheck = CreateFrame("CheckButton", "mbBorderCheck", mbPanel, "InterfaceOptionsCheckButtonTemplate")
mbBorderCheckText:SetText("Hide button borders")
mbBorderCheck.tooltipText = "Hides the default button borders / make buttons square"

-- Load the current checkbox state when the options panel opens
mbBorderCheck:SetScript("OnShow", 
	function()
		local borderStatus = MageButtons:getSV("borderStatus", "borderStatus") or 1
		
		if ( borderStatus == 1 ) then
			mbBorderCheck:SetChecked(true)
		else
			mbBorderCheck:SetChecked(false)
		end
	end
)
mbBorderCheck:SetPoint("TOPLEFT", mbPanel, "TOPLEFT", 20, -40)

-- Store checkbox state in SavedVariables
mbBorderCheck:SetScript("OnClick", 
	function()
		if (mbBorderCheck:GetChecked()) then 
			if ( debug >= 1 ) then print("Checked!") end
			borderTbl = {
				borderStatus = 1,
			}

			MageButtonsDB["borderStatus"] = borderTbl
		else 
			if ( debug >= 1 ) then print("Unchecked :(") end
			borderTbl = {
				borderStatus = 0,
			}

			MageButtonsDB["borderStatus"] = borderTbl
		end
	end
);

---------------------------------
-- Checkbox for minimap button --
---------------------------------
local mbMapCheck = CreateFrame("CheckButton", "mbMapCheck", mbPanel, "InterfaceOptionsCheckButtonTemplate")
mbMapCheckText:SetText("Show minimap button")
mbMapCheck.tooltipText = "Show or Hide the minimap button"

-- Load the current checkbox state when the options panel opens
mbMapCheck:SetScript("OnShow", 
	function()
		local maptbl = MageButtonsDB["minimap"]
		
		if ( maptbl.icon == 1 ) then
			mbMapCheck:SetChecked(true)
		else
			mbMapCheck:SetChecked(false)
		end
	end
)
mbMapCheck:SetPoint("TOPLEFT", mbPanel, "TOPLEFT", 20, -60)

-- Store checkbox state in SavedVariables
mbMapCheck:SetScript("OnClick", 
	function()
		if (mbMapCheck:GetChecked()) then 
			if ( debug >= 1 ) then print("Checked!") end
			mapTbl = {
				icon = 1,
			}

			MageButtonsDB["minimap"] = mapTbl
			local tog = 1
			MageButtons:maptoggle(tog)
		else 
			if ( debug >= 1 ) then print("Unchecked :(") end
			mapTbl = {
				icon = 0,
			}

			MageButtonsDB["minimap"] = mapTbl
			local tog = 0
			MageButtons:maptoggle(tog)
		end
		
	end
);

-----------------------------
-- Checkbox for frame lock --
-----------------------------
local mbLockCheck = CreateFrame("CheckButton", "mbLockCheck", mbPanel, "InterfaceOptionsCheckButtonTemplate")
mbLockCheckText:SetText("Lock / Unlock")
mbLockCheck.tooltipText = "Lock or Unlock the buttons frame"

-- Load the current checkbox state when the options panel opens
mbLockCheck:SetScript("OnShow", 
	function()
		local lockStatus = MageButtons:getSV("framelock", "lock") or 0
		
		if ( lockStatus == 1 ) then
			mbLockCheck:SetChecked(true)
		else
			mbLockCheck:SetChecked(false)
		end
	end
)
mbLockCheck:SetPoint("LEFT", mbBorderCheck, "RIGHT", 150, 0)

-- Store checkbox state in SavedVariables
mbLockCheck:SetScript("OnClick", 
	function()
		if (mbLockCheck:GetChecked()) then 
			if ( debug >= 1 ) then print("Checked!") end
			lockTbl = {
				lock = 1,
			}

			MageButtonsDB["framelock"] = lockTbl
			
			MageButtonsConfig:SetMovable(false)
			MageButtonsConfig:EnableMouse(false)
			MageButtonsFrame:SetBackdropColor(0, 0, 0, 0)
			lockStatus = 1
		else 
			if ( debug >= 1 ) then print("Unchecked :(") end
			lockTbl = {
				lock = 0,
			}

			MageButtonsDB["framelock"] = lockTbl
			
			MageButtonsConfig:SetMovable(true)
			MageButtonsConfig:EnableMouse(true)
			MageButtonsFrame:SetBackdropColor(0, .7, 1, 1)
			lockStatus = 0
		end
		
	end
);

---------------------------------------
-- Checkbox for Show Required Levels --
---------------------------------------
local mbLevelsCheck = CreateFrame("CheckButton", "mbLevelsCheck", mbPanel, "InterfaceOptionsCheckButtonTemplate")
mbLevelsCheckText:SetText("Show Required Levels")
mbLevelsCheck.tooltipText = "Show required levels in tooltip for food/water ranks"

-- Load the current checkbox state when the options panel opens
mbLevelsCheck:SetScript("OnShow", 
	function()
		local levelStatus = MageButtons:getSV("showlevels", "levels") or 1

		if ( levelStatus == 1 ) then
			mbLevelsCheck:SetChecked(true)
		else
			mbLevelsCheck:SetChecked(false)
		end
	end
)
mbLevelsCheck:SetPoint("LEFT", mbLockCheck, "RIGHT", 150, 0)

-- Store checkbox state in SavedVariables
mbLevelsCheck:SetScript("OnClick", 
	function()
		if (mbLevelsCheck:GetChecked()) then 
			if ( debug >= 1 ) then print("Checked!") end
			levelTbl = {
				levels = 1,
			}

			MageButtonsDB["showlevels"] = levelTbl

			levelStatus = 1
		else 
			if ( debug >= 1 ) then print("Unchecked :(") end
			levelTbl = {
				levels = 0,
			}

			MageButtonsDB["showlevels"] = levelTbl

			levelStatus = 0
		end
		
	end
);


----------------------------
-- Checkbox for mouseover --
----------------------------
local mbMouseoverCheck = CreateFrame("CheckButton", "mbMouseoverCheck", mbPanel, "InterfaceOptionsCheckButtonTemplate")
mbMouseoverCheckText:SetText("Mouseover")
mbMouseoverCheck.tooltipText = "Display menu buttons on mouseover.\n\nNote: Background Frame Padding must be >= half of Button Padding to work.\nOtherwise there will be gaps between buttons and the menus will close."

-- Load the current checkbox state when the options panel opens
mbMouseoverCheck:SetScript("OnShow", 
	function()
		local mouseoverStatus = MageButtons:getSV("mouseover", "mouseover") or 0
		
		if ( mouseoverStatus == 1 ) then
			mbMouseoverCheck:SetChecked(true)
		else
			mbMouseoverCheck:SetChecked(false)
		end
	end
)
mbMouseoverCheck:SetPoint("LEFT", mbMapCheck, "RIGHT", 150, 0)

-- Store checkbox state in SavedVariables
mbMouseoverCheck:SetScript("OnClick", 
	function()
		if (mbMouseoverCheck:GetChecked()) then 
			if ( debug >= 1 ) then print("Checked!") end
			moTbl = {
				mouseover = 1,
			}

			MageButtonsDB["mouseover"] = moTbl
		else 
			if ( debug >= 1 ) then print("Unchecked :(") end
			moTbl = {
				mouseover = 0,
			}

			MageButtonsDB["mouseover"] = moTbl
		end
		
	end
);

----------------
--   Events   --
----------------
local function onevent(self, event, arg1, ...)
	if(event == "ADDON_LOADED" and arg1 == "MageButtons") then

		local buttonNames = {"a", "b", "c", "d", "e", "f"}
		local button1value = "none"
		local btnNumber = 1
		local buttonvalue = MageButtonsDB["btnNumber" .. btnNumber]

		-- list of choices
		buttonTypeTable = { "Water", "Food", "Teleports", "Portals", "Gems", "Polymorph", "none"}
		categories = { "Water", "Food", "Teleports", "Portals", "Gems", "Polymorph"}
		
		local i = 1
		local yoffset = -30

		btnTbl["a"] = MageButtons:getSV("buttons", "a")
		btnTbl["b"] = MageButtons:getSV("buttons", "b")
		btnTbl["c"] = MageButtons:getSV("buttons", "c")
		btnTbl["d"] = MageButtons:getSV("buttons", "d")
		btnTbl["e"] = MageButtons:getSV("buttons", "e")
		btnTbl["f"] = MageButtons:getSV("buttons", "f")
		
		for i = 1, 6, 1 do
			buttonKey = buttonNames[i]
			defaultValue = "set me!"
			if i == 1 then
				btype1 = MageButtons:getSV("buttons", "a") or defaultValue
				buttonTypeTable1 = { "_"..btype1.."_", "Water", "Food", "Teleports", "Portals", "Gems", "Polymorph", "none"}
			elseif i == 2 then
				btype2 = MageButtons:getSV("buttons", "b") or defaultValue
				buttonTypeTable2 = { "_"..btype2.."_", "Water", "Food", "Teleports", "Portals", "Gems", "Polymorph", "none"}
			elseif i == 3 then
				btype3 = MageButtons:getSV("buttons", "c") or defaultValue
				buttonTypeTable3 = { "_"..btype3.."_", "Water", "Food", "Teleports", "Portals", "Gems", "Polymorph", "none"}
			elseif i == 4 then
				btype4 = MageButtons:getSV("buttons", "d") or defaultValue
				buttonTypeTable4 = { "_"..btype4.."_", "Water", "Food", "Teleports", "Portals", "Gems", "Polymorph", "none"}
			elseif i == 5 then
				btype5 = MageButtons:getSV("buttons", "e") or defaultValue
				buttonTypeTable5 = { "_"..btype5.."_", "Water", "Food", "Teleports", "Portals", "Gems", "Polymorph", "none"}
			elseif i == 6 then
				btype6 = MageButtons:getSV("buttons", "f") or defaultValue
				buttonTypeTable6 = { "_"..btype6.."_", "Water", "Food", "Teleports", "Portals", "Gems", "Polymorph", "none"}
			end
			
			--------------------
			-- Dropdown Boxes --
			--------------------
			local obj = [[if not buttonTypes]] .. i .. [[ then
			   CreateFrame("Button", "buttonTypes]] .. i .. [[", mbPanel, "UIDropDownMenuTemplate")
			end
			
			buttonTypes]] .. i .. [[:ClearAllPoints()
			buttonTypes]] .. i .. [[:SetPoint("TOPLEFT", mbMapCheck, "BOTTOMLEFT", -2, ]] .. yoffset.. [[)
			buttonTypes]] .. i .. [[:Show()
			
			local buttonLabel]] .. i .. [[ = mbPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
			buttonLabel]] .. i .. [[:SetPoint("RIGHT", buttonTypes]] .. i .. [[, "LEFT", 7, 0)
			buttonLabel]] .. i .. [[:SetJustifyH("LEFT")
			buttonLabel]] .. i .. [[:SetText("]] .. i .. [[")
			]]
			local cmdRun = assert(loadstring(obj))
			cmdRun()
			
			-- return dropdown selection and
			-- dropdown box properties
			if i == 1 then
				local function OnClick(self)
					UIDropDownMenu_SetSelectedID(buttonTypes1, self:GetID(), text, value)
					if self.value ~= nil then btnTbl["a"] = self.value end
					return btnTbl[buttonKey]
				end
				
				local c = 1
				
				local function initialize(self, level)
					
					for k,v in pairs(buttonTypeTable1) do
						if c > 1 then
							info = UIDropDownMenu_CreateInfo(); info.text = v; info.value = v; info.func = OnClick; UIDropDownMenu_AddButton(info, level)
						end
						c = c + 1
					end
					-- info = UIDropDownMenu_CreateInfo()
					-- info.text = "Water"
					-- info.value = "Water"
					-- info.func = OnClick
					-- UIDropDownMenu_AddButton(info, level)
					
					-- info = UIDropDownMenu_CreateInfo()
					-- info.text = "Food"
					-- info.value = "Food"
					-- info.func = OnClick
					-- UIDropDownMenu_AddButton(info, level)
					
					-- info = UIDropDownMenu_CreateInfo()
					-- info.text = "Teleports"
					-- info.value = "Teleports"
					-- info.func = OnClick
					-- UIDropDownMenu_AddButton(info, level)
					
					-- info = UIDropDownMenu_CreateInfo()
					-- info.text = "Portals"
					-- info.value = "Portals"
					-- info.func = OnClick
					-- UIDropDownMenu_AddButton(info, level)
					
					-- info = UIDropDownMenu_CreateInfo()
					-- info.text = "Gems"
					-- info.value = "Gems"
					-- info.func = OnClick
					-- UIDropDownMenu_AddButton(info, level)
					
					-- info = UIDropDownMenu_CreateInfo()
					-- info.text = "Polymorph"
					-- info.value = "Polymorph"
					-- info.func = OnClick
					-- UIDropDownMenu_AddButton(info, level)
					
					-- info = UIDropDownMenu_CreateInfo()
					-- info.text = "none"
					-- info.value = "none"
					-- info.func = OnClick
					-- UIDropDownMenu_AddButton(info, level)
					
				end
			
				UIDropDownMenu_Initialize(buttonTypes1, initialize)
				
			elseif i == 2 then
				local function OnClick(self)
					UIDropDownMenu_SetSelectedID(buttonTypes2, self:GetID(), text, value)
					btnTbl["b"] = self.value
					if self.value ~= nil then btnTbl["b"] = self.value end
					return btnTbl[buttonKey]
				end
				
				c = 1
				local function initialize(self, level)
				for k,v in pairs(buttonTypeTable2) do
						if c > 1 then
							info = UIDropDownMenu_CreateInfo(); info.text = v; info.value = v; info.func = OnClick; UIDropDownMenu_AddButton(info, level)
						end
						c = c + 1
					end
				end
			
				UIDropDownMenu_Initialize(buttonTypes2, initialize)
			elseif i == 3 then
				local function OnClick(self)
					UIDropDownMenu_SetSelectedID(buttonTypes3, self:GetID(), text, value)
					btnTbl["c"] = self.value
					if self.value ~= nil then btnTbl["c"] = self.value end
					return btnTbl[buttonKey]
				end
				
				c = 1
				local function initialize(self, level)
				for k,v in pairs(buttonTypeTable3) do
						if c > 1 then
							info = UIDropDownMenu_CreateInfo(); info.text = v; info.value = v; info.func = OnClick; UIDropDownMenu_AddButton(info, level)
						end
						c = c + 1
					end
				end
			
				UIDropDownMenu_Initialize(buttonTypes3, initialize)
			elseif i == 4 then
				local function OnClick(self)
					UIDropDownMenu_SetSelectedID(buttonTypes4, self:GetID(), text, value)
					btnTbl["d"] = self.value
					if self.value ~= nil then btnTbl["d"] = self.value end
					return btnTbl[buttonKey]
				end
				
				c = 1
				local function initialize(self, level)
				for k,v in pairs(buttonTypeTable4) do
						if c > 1 then
							info = UIDropDownMenu_CreateInfo(); info.text = v; info.value = v; info.func = OnClick; UIDropDownMenu_AddButton(info, level)
						end
						c = c + 1
					end
				end
			
				UIDropDownMenu_Initialize(buttonTypes4, initialize)
			elseif i == 5 then
				local function OnClick(self)
					UIDropDownMenu_SetSelectedID(buttonTypes5, self:GetID(), text, value)
					btnTbl["e"] = self.value
					if self.value ~= nil then btnTbl["e"] = self.value end
					return btnTbl[buttonKey]
				end
				
				c = 1
				local function initialize(self, level)
				for k,v in pairs(buttonTypeTable5) do
						if c > 1 then
							info = UIDropDownMenu_CreateInfo(); info.text = v; info.value = v; info.func = OnClick; UIDropDownMenu_AddButton(info, level)
						end
						c = c + 1
					end
				end
			
				UIDropDownMenu_Initialize(buttonTypes5, initialize)
			elseif i == 6 then
				local function OnClick(self)
					UIDropDownMenu_SetSelectedID(buttonTypes6, self:GetID(), text, value)
					btnTbl["f"] = self.value
					if self.value ~= nil then btnTbl["f"] = self.value end
					return btnTbl[buttonKey]
				end
				
				c = 1
				local function initialize(self, level)
				for k,v in pairs(buttonTypeTable6) do
						if c > 1 then
							info = UIDropDownMenu_CreateInfo(); info.text = v; info.value = v; info.func = OnClick; UIDropDownMenu_AddButton(info, level)
						end
						c = c + 1
					end
				end
			
				UIDropDownMenu_Initialize(buttonTypes6, initialize)
			end
			
			local obj2 = [[UIDropDownMenu_SetWidth(buttonTypes]] .. i .. [[, 100);
			UIDropDownMenu_SetButtonWidth(buttonTypes]] .. i .. [[, 124)
			UIDropDownMenu_JustifyText(buttonTypes]] .. i .. [[, "LEFT")
			
			]]
			local cmdRun2 = assert(loadstring(obj2))
			cmdRun2()
			yoffset = yoffset - 20
		end
		
		
		-------------------------------------------
		--- Drop Down Menu for Growth Direction ---
		-------------------------------------------
		local direction = MageButtons:getSV("growth", "direction")
		if direction == 0 then
			direction = "Vertical"
		end
		directionTbl["direction"] = direction
		
		if not growthDirectionBox then
		   CreateFrame("Button", "growthDirectionBox", mbPanel, "UIDropDownMenuTemplate")
		end
		 
		growthDirectionBox:ClearAllPoints()
		growthDirectionBox:SetPoint("TOPLEFT", mbMapCheck, "BOTTOMLEFT", 0, -190)
		growthDirectionBox:Show()
		
		-- list of choices
		local directions = {
			direction,
			"Horizontal",
			"Vertical",
		}

		-- return dropdown selection
		local function OnClick(self)
			UIDropDownMenu_SetSelectedID(growthDirectionBox, self:GetID(), text, value)
			growthDirection = self.value
			if ( debug == 2 ) then print(growthDirection) end
			directionTbl["direction"] = growthDirection
			return growthDirection
		end
		
		-- dropdown box properties
		local function initialize(self, level)
			local info = UIDropDownMenu_CreateInfo()
			for k,v in pairs(directions) do
				info = UIDropDownMenu_CreateInfo()
				info.text = v
				info.value = v
				info.func = OnClick
				UIDropDownMenu_AddButton(info, level)
			end
		end

		UIDropDownMenu_Initialize(growthDirectionBox, initialize)
		UIDropDownMenu_SetWidth(growthDirectionBox, 100);
		UIDropDownMenu_SetButtonWidth(growthDirectionBox, 124)
		UIDropDownMenu_SetSelectedID(growthDirectionBox, 1)
		UIDropDownMenu_JustifyText(growthDirectionBox, "LEFT")
		
		growthDirectionBox.Label = growthDirectionBox:CreateFontString(nil, 'ARTWORK', 'GameFontWhiteSmall')
		growthDirectionBox.Label:SetPoint("BOTTOMLEFT", growthDirectionBox, "TOPLEFT", 10, 1)
		growthDirectionBox.Label:SetText("Growth Direction:")
		
		
		-------------------------------------------
		--- Drop Down Menu for Button Direction ---
		-------------------------------------------
		local buttonDir = MageButtons:getSV("growth", "buttons")
		if buttonDir == 0 then
			buttonDir = "Left"
		end
		directionTbl["buttons"] = buttonDir
		
		if not buttonDirectionBox then
		   CreateFrame("Button", "buttonDirectionBox", mbPanel, "UIDropDownMenuTemplate")
		end
		 
		buttonDirectionBox:ClearAllPoints()
		buttonDirectionBox:SetPoint("TOPLEFT", mbMapCheck, "BOTTOMLEFT", 0, -250)
		buttonDirectionBox:Show()
		
		-- list of choices
		local buttonDirs = {
			buttonDir,
			"Left",
			"Right",
			"Up",
			"Down",
		}

		-- return dropdown selection
		local function OnClick(self)
			UIDropDownMenu_SetSelectedID(buttonDirectionBox, self:GetID(), text, value)
			buttonDirection = self.value
			if ( debug == 2 ) then print(buttonDirection) end
			directionTbl["buttons"] = buttonDirection
			return buttonDirection
		end
		
		-- dropdown box properties
		local function initialize(self, level)
			local info = UIDropDownMenu_CreateInfo()
			for k,v in pairs(buttonDirs) do
				info = UIDropDownMenu_CreateInfo()
				info.text = v
				info.value = v
				info.func = OnClick
				UIDropDownMenu_AddButton(info, level)
			end
		end

		UIDropDownMenu_Initialize(buttonDirectionBox, initialize)
		UIDropDownMenu_SetWidth(buttonDirectionBox, 100);
		UIDropDownMenu_SetButtonWidth(buttonDirectionBox, 124)
		UIDropDownMenu_SetSelectedID(buttonDirectionBox, 1)
		UIDropDownMenu_JustifyText(buttonDirectionBox, "LEFT")
		
		buttonDirectionBox.Label = buttonDirectionBox:CreateFontString(nil, 'ARTWORK', 'GameFontWhiteSmall')
		buttonDirectionBox.Label:SetPoint("BOTTOMLEFT", buttonDirectionBox, "TOPLEFT", 10, 1)
		buttonDirectionBox.Label:SetText("Menu Growth Direction:")
		
		---------------------------------------
		-- Color picker for background color --
		-- (largely borrowed from TidyPlates)--
		---------------------------------------		
		local workingFrame
		local function ChangeColor(cancel)
			local a, r, g, b
			if cancel then
				--r,g,b,a = unpack(ColorPickerFrame.startingval )
				workingFrame:SetBackdropColor(unpack(ColorPickerFrame.startingval ))
			else
				a, r, g, b = OpacitySliderFrame:GetValue(), ColorPickerFrame:GetColorRGB();
				workingFrame:SetBackdropColor(r,g,b,1-a)
				redBox:SetText(r)
				blueBox:SetText(b)
				greenBox:SetText(g)
				alphaBox:SetText(1-a)
				if workingFrame.OnValueChanged then workingFrame:OnValueChanged() end
			end
		end

		local function ShowColorPicker(cpframe)
			local r,g,b,a = cpframe:GetBackdropColor()
			workingFrame = cpframe
			ColorPickerFrame.func, ColorPickerFrame.opacityFunc, ColorPickerFrame.cancelFunc = 	ChangeColor, ChangeColor, ChangeColor;
			ColorPickerFrame.startingval  = {r,g,b,a}
			ColorPickerFrame:SetColorRGB(r,g,b);
			ColorPickerFrame.hasOpacity = true
			ColorPickerFrame.opacity = 1 - a
			ColorPickerFrame:SetFrameStrata(cpframe:GetFrameStrata())
			ColorPickerFrame:SetFrameLevel(cpframe:GetFrameLevel()+1)
			ColorPickerFrame:Hide(); ColorPickerFrame:Show(); -- Need to activate the OnShow handler.
		end
		
		-- Save the RGBA values to Saved Variables
		local redValue = MageButtons:getSV("bgcolor", "red") or .1
		local greenValue = MageButtons:getSV("bgcolor", "green") or .1
		local blueValue = MageButtons:getSV("bgcolor", "blue") or .1
		local alphaValue = MageButtons:getSV("bgcolor", "alpha") or 1
		
		local colorbox = CreateFrame("Button", colorbox, mbPanel, "BackdropTemplate")
		colorbox:SetWidth(24)
		colorbox:SetHeight(24)
		colorbox:SetPoint("LEFT", usageText, "RIGHT", 80, -20)
		colorbox:SetBackdrop({bgFile = "Interface\\ChatFrame\\ChatFrameColorSwatch",
												edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
												tile = false, tileSize = 16, edgeSize = 8,
												insets = { left = 1, right = 1, top = 1, bottom = 1 }});
		colorbox:SetBackdropColor(redValue, greenValue, blueValue, alphaValue);
		colorbox:SetScript("OnClick",function() 
			local rc, bc gc, al = ShowColorPicker(colorbox) 
		end)
				
		colorbox.Label = colorbox:CreateFontString(nil, 'ARTWORK', 'GameFontWhiteSmall')
		colorbox.Label:SetPoint("BOTTOMLEFT", colorbox, "TOPLEFT", -10, 3)
		colorbox.Label:SetText("Frame Background Color (R, G, B, A):")

		colorbox.GetValue = function() local color = {}; color.r, color.g, color.b, color.a = colorbox:GetBackdropColor(); return color end
		colorbox.SetValue = function(self, color) 
			colorbox:SetBackdropColor(color.r, color.g, color.b, color.a)
		end
			
		--------------------------------
		-- Text boxes for RGBA values --
		--------------------------------
		redBox = CreateFrame("EditBox", redBox, mbPanel, "InputBoxTemplate")
		redBox:SetWidth(30)
		redBox:SetHeight(30)
		redBox:SetPoint("LEFT", colorbox, "RIGHT", 20, 0)
		redBox:SetMaxLetters(4)
		redBox:SetHyperlinksEnabled(false)
		redBox:SetText(redValue)
		redBox:SetAutoFocus(false)
		redBox:SetCursorPosition(0)
		
		greenBox = CreateFrame("EditBox", greenBox, mbPanel, "InputBoxTemplate")
		greenBox:SetWidth(30)
		greenBox:SetHeight(30)
		greenBox:SetPoint("LEFT", redBox, "RIGHT", 10, 0)
		greenBox:SetMaxLetters(4)
		greenBox:SetHyperlinksEnabled(false)
		greenBox:SetText(greenValue)
		greenBox:SetAutoFocus(false)
		greenBox:SetCursorPosition(0)
		
		blueBox = CreateFrame("EditBox", blueBox, mbPanel, "InputBoxTemplate")
		blueBox:SetWidth(30)
		blueBox:SetHeight(30)
		blueBox:SetPoint("LEFT", greenBox, "RIGHT", 10, 0)
		blueBox:SetMaxLetters(4)
		blueBox:SetHyperlinksEnabled(false)
		blueBox:SetText(blueValue)
		blueBox:SetAutoFocus(false)
		blueBox:SetCursorPosition(0)
		
		alphaBox = CreateFrame("EditBox", alphaBox, mbPanel, "InputBoxTemplate")
		alphaBox:SetWidth(30)
		alphaBox:SetHeight(30)
		alphaBox:SetPoint("LEFT", blueBox, "RIGHT", 10, 0)
		alphaBox:SetMaxLetters(4)
		alphaBox:SetHyperlinksEnabled(false)
		alphaBox:SetText(alphaValue)
		alphaBox:SetAutoFocus(false)
		alphaBox:SetCursorPosition(0)
		
		------------------------------
		-- Text box for button size --
		------------------------------
		local buttonSize = MageButtons:getSV("buttonSettings", "size") or 26
		buttonSizeBox = CreateFrame("EditBox", buttonSizeBox, mbPanel, "InputBoxTemplate")
		buttonSizeBox:SetWidth(30)
		buttonSizeBox:SetHeight(30)
		buttonSizeBox:SetPoint("TOPLEFT", colorbox, "BOTTOMLEFT", 0, -40)
		buttonSizeBox:SetMaxLetters(4)
		buttonSizeBox:SetHyperlinksEnabled(false)
		buttonSizeBox:SetText(buttonSize)
		buttonSizeBox:SetAutoFocus(false)
		buttonSizeBox:SetCursorPosition(0)
		
		buttonSizeBox.Label = colorbox:CreateFontString(nil, 'ARTWORK', 'GameFontWhiteSmall')
		buttonSizeBox.Label:SetPoint("BOTTOMLEFT", buttonSizeBox, "TOPLEFT", -10, 1)
		buttonSizeBox.Label:SetText("Button Size:")
		
		---------------------------------
		-- Text box for button padding --
		---------------------------------
		local paddingSize = MageButtons:getSV("buttonSettings", "padding") or 5
		buttonPaddingBox = CreateFrame("EditBox", buttonPaddingBox, mbPanel, "InputBoxTemplate")
		buttonPaddingBox:SetWidth(30)
		buttonPaddingBox:SetHeight(30)
		buttonPaddingBox:SetPoint("TOPLEFT", colorbox, "BOTTOMLEFT", 0, -100)
		buttonPaddingBox:SetMaxLetters(4)
		buttonPaddingBox:SetHyperlinksEnabled(false)
		buttonPaddingBox:SetText(paddingSize)
		buttonPaddingBox:SetAutoFocus(false)
		buttonPaddingBox:SetCursorPosition(0)
		
		buttonPaddingBox.Label = colorbox:CreateFontString(nil, 'ARTWORK', 'GameFontWhiteSmall')
		buttonPaddingBox.Label:SetPoint("BOTTOMLEFT", buttonPaddingBox, "TOPLEFT", -10, 1)
		buttonPaddingBox.Label:SetText("Button Padding:")
		
		-------------------------------------
		-- Text box for background padding --
		-------------------------------------
		local bgPaddingSize = MageButtons:getSV("buttonSettings", "bgpadding") or 2.5
		bgPaddingBox = CreateFrame("EditBox", bgPaddingBox, mbPanel, "InputBoxTemplate")
		bgPaddingBox:SetWidth(30)
		bgPaddingBox:SetHeight(30)
		bgPaddingBox:SetPoint("TOPLEFT", colorbox, "BOTTOMLEFT", 0, -160)
		bgPaddingBox:SetMaxLetters(4)
		bgPaddingBox:SetHyperlinksEnabled(false)
		bgPaddingBox:SetText(bgPaddingSize)
		bgPaddingBox:SetAutoFocus(false)
		bgPaddingBox:SetCursorPosition(0)
		
		bgPaddingBox.Label = colorbox:CreateFontString(nil, 'ARTWORK', 'GameFontWhiteSmall')
		bgPaddingBox.Label:SetPoint("BOTTOMLEFT", bgPaddingBox, "TOPLEFT", -10, 1)
		bgPaddingBox.Label:SetText("Background Frame Padding:")

	end
end

--------------------------------------------------
--- Save items when the Okay button is pressed ---
--------------------------------------------------
mbPanel.okay = function (self)
	if debug >= 1 then print("saving...") end
	
	local bgColorTbl = { red = redBox:GetText(),
						 blue = blueBox:GetText(),
						 green = greenBox:GetText(),
						 alpha = alphaBox:GetText(),
					}
					
	local buttonSettingsTbl = { size = buttonSizeBox:GetText(),
								padding = buttonPaddingBox:GetText(), 
								bgpadding = bgPaddingBox:GetText() }
	
	MageButtonsDB["buttons"] = btnTbl
	MageButtonsDB["growth"] = directionTbl
	MageButtonsDB["bgcolor"] = bgColorTbl
	MageButtonsDB["buttonSettings"] = buttonSettingsTbl
	
	growthDir = directionTbl["direction"]
	menuDir = directionTbl["buttons"]
	btnSize = buttonSettingsTbl["size"]
	padding = buttonSettingsTbl["padding"]
	if mbBorderCheck:GetChecked() then border = 1 else border = 0 end
	backdropPadding = buttonSettingsTbl["bgpadding"]
	backdropRed = bgColorTbl["red"]
	backdropGreen = bgColorTbl["green"]
	backdropBlue = bgColorTbl["blue"]
	backdropAlpha = bgColorTbl["alpha"]
	
	MageButtons:makeBaseButtons()
	
	if debug >= 1 then print("saved") end
end

-- Register Events
mbPanel:RegisterEvent("ADDON_LOADED")
mbPanel:SetScript("OnEvent", onevent)

