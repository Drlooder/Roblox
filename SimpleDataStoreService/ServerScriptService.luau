local DataStoreService = game:GetService("DataStoreService")
local module = {}

module.Cache = {}

local function MergeTables(oldData, newData)
	oldData = oldData or {}

	for key, value in pairs(newData) do
		if type(value) == "table" and type(oldData[key]) == "table" then
			MergeTables(oldData[key], value)
		else
			oldData[key] = value
		end
	end

	return oldData
end

function module.GetDataStoreObject(name, save)
	
	name = string.upper(name)
	
	if module.Cache[name] then
		return module.Cache[name]
	end
	
	local DataStoreObj = DataStoreService:GetDataStore(name)
	if DataStoreObj then
		
		if save	then
			local success, err = pcall(function()
				DataStoreObj:SetAsync("Hello", "World")
			end)
			
			if not success then
				warn("[DATA-STORE] ERROR SAVING "..name.." | "..err..". ACTION = GET/READ in SAVE")
			end
		end
	
		module.Cache[name] = DataStoreObj
		return DataStoreObj
	end
	
	warn("[DATA-STORE] ERROR CREATING/GETTING DATA_STORE_OBJECT. ACTION = GET_DATA_STORE_OBJECT")
	return nil
end

function module.GetData(dataStoreName, key)
	dataStoreName = string.upper(dataStoreName)
	
	local DataStoreObj: DataStore = module.GetDataStoreObject(dataStoreName)
	if DataStoreObj then
		local success, data = pcall(function()
			return DataStoreObj:GetAsync(key)
		end)
		
		if success then
			return data
		else
			warn("[DATA-STORE] ERROR GETTING DATA. ACTION = GET")
			return nil
		end
	end
	
	return nil
end

function module.SetData(dataStoreName, key, value)
	dataStoreName = string.upper(dataStoreName)
	
	local DataStoreObj: DataStore = module.GetDataStoreObject(dataStoreName)
	if DataStoreObj then
		local success, err = pcall(function ()
			DataStoreObj:SetAsync(key, value)
		end)
		
		if not success then
			warn("[DATA-STORE] ERROR WHILE SETTING DATA.".." | "..err..". ACTION = SET")
			return false
		end
		
		return true
	end
	
	return false
end

function module.UpdateData(dataStoreName, key, newData)
	dataStoreName = string.upper(dataStoreName)
	
	local DataStoreObject: DataStore = module.GetDataStoreObject(dataStoreName)
	if DataStoreObject then
		local success, err = pcall(function()
			DataStoreObject:UpdateAsync(key, function(oldData)				
				return MergeTables(oldData, newData)
			end)
		end)
		
		if not success then
			warn("[DATA-STORE] ERROR WHILE UPDATING DATA.".." | "..err..". ACTION = UPDATE")
			return false
		end
		
		return true
	end
	
	return false
end

function module.RemoveData(dataStoreName, key)
	dataStoreName = string.upper(dataStoreName)

	local DataStoreObject: DataStore = module.GetDataStoreObject(dataStoreName)
	if DataStoreObject then
		local success, err = pcall(function()
			DataStoreObject:RemoveAsync(key)
		end)

		if not success then
			warn("[DATA-STORE] ERROR WHILE REMOVING DATA.".." | "..err..". ACTION = REMOVE")
			return false
		end

		return true
	end

	return false
end

function module.HasData(dataStoreName, key)
	dataStoreName = string.upper(dataStoreName)

	local DataStoreObject: DataStore = module.GetDataStoreObject(dataStoreName)
	if DataStoreObject then
		local data = module.GetData(dataStoreName, key)
		
		if data then
			return true
		end
	end
	
	return false
end


return module
