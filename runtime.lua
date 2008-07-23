if not arg.debugLevel then arg.debugLevel = 0 end

module('runtime',package.seeall)

-- indexed by object table, value is array + namespace indexes to ancestors
AncestorsPerObject = { }
ObjectId					 = { }
ObjectById				 = { }

function blank( name )
	local object = { }
	local objectId = #ObjectById + 1
	ObjectId[ object ]		 = objectId
	ObjectById[ objectId ] = object
	setmetatable( object, Meta )
	if name and string then
		-- runtime.string is defined in core.lua
		object.__name = string[ name ]
	end
	return object
end

--TODO: remove in favor of Mab implementation
function childFrom( parentObject, name )
	if not parentObject then
		error( "runtime.childFrom() called with no parentObject supplied.")
	end
	local object = blank( name )
	addInheritance( object, parentObject )
	if arg.debugLevel >= 4 and parentObject.__name then
		print( "Created "..luastring[parentObject.__name].." #"..ObjectId[object] )
	end
	return object
end

-- Shared by every instance
Meta = {
	__index = function( object, slotName )
		local breadthFirstQueue = { }
		local queueSize = 0
		
		local ancestors = AncestorsPerObject[ object ]
		if ancestors then
			if ancestors[2] then				
				for _,parentObject in ipairs(ancestors) do
					queueSize = queueSize + 1
					breadthFirstQueue[ queueSize ] = parentObject
				end
			else
				queueSize = queueSize + 1
				breadthFirstQueue[ queueSize ] = ancestors[1]
			end				
		end		

		local currentIndex = 1
		local currentObject = breadthFirstQueue[ currentIndex ]
		
		-- initially nil; may be set to an object by the core	
		local metaNil = Meta.nilValue
		while currentObject do
			local value = rawget( currentObject, slotName )
			if value and value ~= metaNil then
				return value
			end
			
			ancestors = AncestorsPerObject[ currentObject ]
			if ancestors then
				if ancestors[2] then
					for _,parentObject in ipairs(ancestors) do
						queueSize = queueSize + 1
						breadthFirstQueue[ queueSize ] = parentObject
					end
				else
					queueSize = queueSize + 1
					breadthFirstQueue[ queueSize ] = ancestors[1]
				end
			end

			currentIndex = currentIndex + 1
			currentObject = breadthFirstQueue[ currentIndex ]
		end

		-- Only reach here if the slot wasn't found
		return metaNil
	end
}

-- TODO: similar function to insert after a particular existing parent, by id or scope
-- TODO: detect circular references and fix, since the lookup mechanism had circular detection removed for speed
function addInheritance( childObject, parentObject, namespace, appendToEnd )
	local ancestors = AncestorsPerObject[ childObject ]
	if ancestors then
		for i,existingParent in ipairs(ancestors) do
			if existingParent == parentObject then
				table.remove( ancestors, i )
				break
			end
		end
		if appendToEnd then
			table.insert( ancestors, parentObject )
		else
			table.insert( ancestors, 1, parentObject )
		end
	else
		ancestors = { parentObject }
		AncestorsPerObject[ childObject ] = ancestors
	end
	
	if namespace then 
		ancestors[ namespace ] = parentObject
	end
	
	return childObject
end

function setInheritance( childObject, parentObject, namespace )
	AncestorsPerObject[ childObject ] = parentObject and { parentObject } or {}
	
	if namespace then 
		AncestorsPerObject[ childObject ][ namespace ] = parentObject
	end
	
	return childObject
end

function valueFromNamespace( object, slotName, namespace )
	-- Use explicit false for no namespace
	if not namespace then return object[slotName] end

	local seenObjects = { }
	local currentObject = AncestorsPerObject[ object ][ namespace ]
	while currentObject and not seenObjects[ currentObject ] do
		local value = rawget( currentObject, slotName )
		if value ~= nil and value ~= Meta.nilValue then
			return value
		end
		seenObjects[ currentObject ] = true
		currentObject = AncestorsPerObject[ currentObject ][ namespace ]
	end
	return Meta.nilValue
end

--TODO: remove in favor of Mab implementation
function isKindOf( object, ancestorObject )
	local breadthFirstQueue = { object }
	local currentIndex = 1
	local currentObject = object
	while currentObject do
		if not breadthFirstQueue[ currentObject ] then		
			if currentObject == ancestorObject then
				return true
			end

			if AncestorsPerObject[ currentObject ] then
				for _,parentObject in ipairs(AncestorsPerObject[ currentObject ]) do
					table.insert( breadthFirstQueue, parentObject )
				end
			end
			breadthFirstQueue[ currentObject ] = true
		end

		currentIndex = currentIndex + 1
		currentObject = breadthFirstQueue[ currentIndex ]
	end
	return false
end

-- TODO: remove this, as no code is using it?
-- Shallow duplicate preserving inheritance hierarchy
function duplicate( object )
	local duplicateObject = {}
	setmetatable( duplicateObject, getmetatable( object ) )
	
	for k,v in pairs(object) do
		duplicateObject[k] = v
	end
	
	AncestorsPerObject[duplicateObject] = {}
	for k,v in pairs(AncestorsPerObject[object]) do
		AncestorsPerObject[duplicateObject][k] = v
	end
	
	return duplicateObject
end

-- TODO: Remove (debug function)
function showHier( obj, depth )
	if not depth then depth = 0 end
	local indent = ("  "):rep( depth )
	print( indent .. luastring[ core.sendMessageAsString( obj, 'asCode' ) ] )
	if AncestorsPerObject[ obj ] and obj ~= core.Roots.Lawn then
		for i,ancestor in ipairs(AncestorsPerObject[obj]) do
			showHier( ancestor, depth+1 )
		end
	end
end
