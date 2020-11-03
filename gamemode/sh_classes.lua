-- ENUMERATION FOR CLASS CATEGORIES
CLASS_CATEGORY_NONE = 0
CLASS_CATEGORY_LIGHT = 1
CLASS_CATEGORY_HEAVY = 2
CLASS_CATEGORY_SUPPORT = 3
CLASS_CATEGORY_COUNT = CLASS_CATEGORY_SUPPORT

function GM:RegisterClass(sClassName, tClassTable)
    local gm = GMEMODE or GM

    table.insert(gm.Classes, tClassTable)
    tClassTable.Index = #gm.Classes

    gm.Classes[sClassName] = tClassTable
end

function GM:InitializeClasses()
    self.Classes = {}

    local included = {}

    local classfiles, classdirectories = file.Find(self.FolderName.."/gamemode/classes/*", "LUA")
    table.sort(classfiles)
    table.sort(classdirectories)

    for i, filename in ipairs(classfiles) do
		if string.sub(filename, -4) == ".lua" then -- Just in case
			CLASS = {}

			AddCSLuaFile("classes/"..filename)
			include("classes/"..filename)

			if CLASS.Name then
				self:RegisterClass(CLASS.Name, CLASS)
			else
				ErrorNoHalt("CLASS "..filename.." has no 'Name' member!")
			end

			included[filename] = CLASS
			CLASS = nil
		end
	end

	for i, foldername in ipairs(classdirectories) do
		local basefn = "classes/"..foldername.."/"

		CLASS = {}
		if CLIENT then
			include(basefn.."client.lua")
		end
		if SERVER then
			AddCSLuaFile(basefn.."client.lua")
			include(basefn.."server.lua")
		end

		if CLASS.Name then
			self:RegisterClass(CLASS.Name, CLASS)
		else
			ErrorNoHalt("CLASS "..foldername.." has no 'Name' member!")
		end

		included[foldername..".lua"] = CLASS
		CLASS = nil
	end

	for k, v in pairs(self.Classes) do
		local base = v.Base
		if base then
			base = base..".lua"
			if included[base] then
				local old_Hidden = v.Hidden
				local old_Unlocked = v.Unlocked

				table.Inherit(v, included[base])

				-- Don't inherit these.
				v.Hidden = old_Hidden
				v.Unlocked = old_Unlocked

			else
				ErrorNoHalt("CLASS "..tostring(v.Name).." uses base class "..base.." but it doesn't exist!")
			end
		end
	end

	--self:ReorderClasses()
end

if not GAMEMODE or (GAMEMODE and not GAMEMODE.Classes) then
    GM:InitializeClasses()
end
