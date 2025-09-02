--[[
	AccessoryDetector Module v1.0
	Created by @onlyzxv
	
	A reliable Roblox head accessory detection system that uses attachments 
	instead of AccessoryType for better accuracy and compatibility.
	
	Features:
	• Detect head accessories (Hair, Hat, Face)
	• Check if a hit part is a headshot
	• Get accessories by type
	• Reliable head part detection
	• Debug information for accessory analysis
	
	GitHub: [Your GitHub link here]
	DevForum: [Your DevForum profile here]
	
	License: MIT License
	Feel free to use, modify, and distribute!
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local AccessoryDetector = {}

-- Define attachment names for different accessory types
local ATTACHMENT_MAPPINGS = {
	-- Hair attachments
	Hair = {
		"HairAttachment",
		"HairTopAttachment", 
		"HairBackAttachment",
		"HairFrontAttachment"
	},

	-- Face attachments
	Face = {
		"FaceFrontAttachment",
		"FaceCenterAttachment",
		"NeckRigAttachment"
	},

	-- Hat attachments
	Hat = {
		"HatAttachment",
		"TopHatAttachment"
	},

	-- Head parts (for headshot detection)
	Head = {
		"HairAttachment",
		"HatAttachment", 
		"NeckRigAttachment",
		"FaceFrontAttachment",
		"FaceCenterAttachment",
		"face" -- Decal name
	}
}

--[[
	Checks if a part is a head or head-related part
	
	@param part - The part to check
	@return boolean - True if it's a head part
]]
function AccessoryDetector.IsHeadPart(part)
	if not part then return false end

	-- Direct head check
	if part.Name == "Head" or part.Name == "Cabesa" then
		return true
	end

	-- Check for face decal
	if part:FindFirstChild("face") then
		return true
	end

	-- Check for head-related attachments
	for _, attachmentName in pairs(ATTACHMENT_MAPPINGS.Head) do
		if part:FindFirstChild(attachmentName) then
			return true
		end
	end

	return false
end

--[[
	Gets the accessory type by checking its attachments
	
	@param accessory - The accessory object to check
	@return string|nil - "Hair", "Face", "Hat", "Unknown", or nil if invalid
]]
function AccessoryDetector.GetAccessoryType(accessory)
	if not accessory or not accessory:IsA("Accessory") then
		return nil
	end

	local handle = accessory:FindFirstChild("Handle")
	if not handle then return nil end

	-- Check each accessory type
	for accessoryType, attachments in pairs(ATTACHMENT_MAPPINGS) do
		if accessoryType ~= "Head" then -- Skip the combined Head category
			for _, attachmentName in pairs(attachments) do
				if handle:FindFirstChild(attachmentName) then
					return accessoryType
				end
			end
		end
	end

	return "Unknown"
end

--[[
	Gets all accessories of a specific type from a character
	
	@param character - The character to search
	@param accessoryType - "Hair", "Hat", or "Face"
	@return table - Array of accessories of the specified type
]]
function AccessoryDetector.GetAccessoriesByType(character, accessoryType)
	if not character or not ATTACHMENT_MAPPINGS[accessoryType] then
		return {}
	end

	local accessories = {}

	for _, child in pairs(character:GetChildren()) do
		if child:IsA("Accessory") then
			if AccessoryDetector.GetAccessoryType(child) == accessoryType then
				table.insert(accessories, child)
			end
		end
	end

	return accessories
end

--[[
	Checks if a character is wearing any head accessories
	
	@param character - The character to check
	@return boolean - True if wearing any head accessories
]]
function AccessoryDetector.HasHeadAccessories(character)
	if not character then return false end

	local headAccessories = 0
	headAccessories = headAccessories + #AccessoryDetector.GetAccessoriesByType(character, "Hair")
	headAccessories = headAccessories + #AccessoryDetector.GetAccessoriesByType(character, "Hat")
	headAccessories = headAccessories + #AccessoryDetector.GetAccessoriesByType(character, "Face")

	return headAccessories > 0
end

--[[
	Determines if a hit part counts as a headshot
	Works with both direct head hits and accessory hits
	
	@param hitPart - The part that was hit
	@param character - The character that was hit
	@return boolean - True if it's a valid headshot
]]
function AccessoryDetector.IsHeadshot(hitPart, character)
	if not hitPart or not character then
		return false
	end

	-- Check if the hit part itself is a head part
	if AccessoryDetector.IsHeadPart(hitPart) then
		return true
	end

	-- Check if the hit part belongs to a head accessory
	local accessory = hitPart.Parent
	if accessory and accessory:IsA("Accessory") then
		local accessoryType = AccessoryDetector.GetAccessoryType(accessory)
		if accessoryType == "Hair" or accessoryType == "Hat" or accessoryType == "Face" then
			return true
		end
	end

	return false
end

--[[
	Gets detailed accessory information for debugging purposes
	
	@param character - The character to analyze
	@return table - Detailed accessory breakdown
]]
function AccessoryDetector.GetCharacterAccessoryInfo(character)
	if not character then return {} end

	local info = {
		Hair = AccessoryDetector.GetAccessoriesByType(character, "Hair"),
		Hat = AccessoryDetector.GetAccessoriesByType(character, "Hat"),
		Face = AccessoryDetector.GetAccessoriesByType(character, "Face"),
		Total = 0
	}

	info.Total = #info.Hair + #info.Hat + #info.Face

	return info
end

return AccessoryDetector
