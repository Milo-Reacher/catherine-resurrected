--[[
< CATHERINE > - A free role-playing framework for Garry's Mod.
Development and design by L7D.

Catherine is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Catherine.  If not, see <http://www.gnu.org/licenses/>.
]]--

catherine.attribute = catherine.attribute or { lists = { } }

function catherine.attribute.Register( attributeTable )
	if ( !attributeTable or !attributeTable.index ) then return end
	
	attributeTable.default = attributeTable.default or 0
	attributeTable.max = attributeTable.max or 100
	
	if ( SERVER and attributeTable.image ) then
		resource.AddFile( attributeTable.image )
	end
	
	catherine.attribute.lists[ attributeTable.uniqueID ] = attributeTable
	
	return attributeTable.uniqueID
end

function catherine.attribute.New( uniqueID )
	return { uniqueID = uniqueID, index = table.Count( catherine.attribute.lists ) + 1 }
end

function catherine.attribute.GetAll( )
	return catherine.attribute.lists
end

function catherine.attribute.FindByID( id )
	return catherine.attribute.lists[ id ]
end

function catherine.attribute.FindByIndex( index )
	for k, v in pairs( catherine.attribute.GetAll( ) ) do
		if ( v.index == index ) then
			return v
		end
	end
end

function catherine.attribute.Include( dir )
	for k, v in pairs( file.Find( dir .. "/attribute/*.lua", "LUA" ) ) do
		catherine.util.Include( dir .. "/attribute/" .. v, "SHARED" )
	end
end

catherine.attribute.Include( catherine.FolderName .. "/framework" )

if ( SERVER ) then
	catherine.attribute.randomSaver = catherine.attribute.randomSaver or { }
	
	function catherine.attribute.GetRandom( pl )
		local steamID = pl:SteamID( )
		local data = catherine.attribute.randomSaver[ steamID ]
		
		if ( data ) then
			for k, v in pairs( data ) do
				local attributeTable = catherine.attribute.FindByID( v.uniqueID )
				
				if ( !attributeTable ) then
					local newData = { }
			
					math.randomseed( os.time( ) )
					
					for i = 1, 3 do
						local randomAttCalc, max = catherine.attribute.GetRandomCalc( newData )
						
						if ( randomAttCalc ) then
							newData[ #newData + 1 ] = {
								uniqueID = randomAttCalc,
								amount = math.random( catherine.configs.charMakeRandomAttributeMinPoint, math.min( catherine.configs.charMakeRandomAttributeMaxPoint, max ) )
							}
						else
							continue
						end
					end
					
					catherine.attribute.randomSaver[ steamID ] = newData
					
					return newData
				end
			end
			
			return catherine.attribute.randomSaver[ steamID ]
		else
			local newData = { }
			
			math.randomseed( os.time( ) )
			
			for i = 1, 3 do
				local randomAttCalc, max = catherine.attribute.GetRandomCalc( newData )
				
				if ( randomAttCalc ) then
					newData[ #newData + 1 ] = {
						uniqueID = randomAttCalc,
						amount = math.random( catherine.configs.charMakeRandomAttributeMinPoint, math.min( catherine.configs.charMakeRandomAttributeMaxPoint, max ) )
					}
				else
					continue
				end
			end
			
			catherine.attribute.randomSaver[ steamID ] = newData
			
			return newData
		end
	end
	
	function catherine.attribute.GetRandomCalc( currentCalcData )
		local blackList = table.Copy( catherine.configs.charMakeRandomAttributeBlacklist )
		local attTable = table.Copy( catherine.attribute.lists )
		local convert = { }
		
		for k, v in pairs( currentCalcData ) do
			blackList[ #blackList + 1 ] = v.uniqueID
		end
		
		for k, v in pairs( blackList ) do
			attTable[ v ] = nil
		end
		
		if ( table.Count( attTable ) > 0 ) then
			for k, v in pairs( attTable ) do
				convert[ #convert + 1 ] = { v.uniqueID, v.max }
			end
			
			local result = convert[ math.random( 1, #convert ) ]
			
			return result[ 1 ], result[ 2 ]
		else
			return false
		end
	end
	
	function catherine.attribute.ResetRandom( pl )
		if ( catherine.attribute.randomSaver[ pl:SteamID( ) ] ) then
			catherine.attribute.randomSaver[ pl:SteamID( ) ] = nil
		end
	end
	
	function catherine.attribute.AddTemporaryIncreaseProgress( pl, uniqueID, amount, removeTime )
		if ( hook.Run( "PlayerShouldAttributeIncreased", pl, uniqueID, amount, removeTime ) == false ) then return end
		local attributeTable = catherine.attribute.FindByID( uniqueID )
		
		if ( !attributeTable ) then return end
		
		local attribute = catherine.character.GetVar( pl, "_att", { } )
		
		removeTime = removeTime or 5
		
		if ( attribute[ uniqueID ] ) then
			local temporaryTable = catherine.character.GetCharVar( pl, "attribute_temporary", { increase = { }, decrease = { } } )
			
			if ( attributeTable.max < attribute[ uniqueID ].progress + amount ) then return end
			
			local increaseTable = temporaryTable.increase[ uniqueID ]
			
			increaseTable = {
				amount = amount,
				removeTime = removeTime
			}
			
			temporaryTable.increase[ uniqueID ] = increaseTable
			
			catherine.character.SetCharVar( pl, "attribute_temporary", temporaryTable )
			
			local charID = pl:GetCharacterID( )
			local timerID = "Catherine.timer.attribute.TemporaryIncreaseRemove." .. pl:SteamID( ) .. "." .. uniqueID .. "." .. charID
			local removeTime2 = removeTime
			
			timer.Remove( timerID )
			timer.Create( timerID, 3, 0, function( )
				if ( !IsValid( pl ) or charID != pl:GetCharacterID( ) ) then
					timer.Remove( timerID )
					return
				end
				
				if ( removeTime2 - 3 <= 0 ) then
					catherine.attribute.RemoveTemporaryIncreaseProgress( pl, uniqueID )
					timer.Remove( timerID )
					return
				end
				
				local attributeTable = catherine.attribute.FindByID( uniqueID )
				
				if ( !attributeTable ) then
					timer.Remove( timerID )
					return
				end
				
				local temporaryTable = catherine.character.GetCharVar( pl, "attribute_temporary", { increase = { }, decrease = { } } )
				
				if ( temporaryTable.increase[ uniqueID ] ) then
					if ( !temporaryTable.increase[ uniqueID ].removeTime or !temporaryTable.increase[ uniqueID ].amount ) then
						timer.Remove( timerID )
						return
					end
					
					temporaryTable.increase[ uniqueID ].removeTime = removeTime2 - 3
					removeTime2 = removeTime2 - 3
					
					catherine.character.SetCharVar( pl, "attribute_temporary", temporaryTable )
				else
					timer.Remove( timerID )
				end
			end )
		end
		
		hook.Run( "AttributeIncreased", pl, uniqueID, amount, removeTime )
	end
	
	function catherine.attribute.AddTemporaryDecreaseProgress( pl, uniqueID, amount, removeTime )
		if ( hook.Run( "PlayerShouldAttributeDecreased", pl, uniqueID, amount, removeTime ) == false ) then return end
		local attributeTable = catherine.attribute.FindByID( uniqueID )
		
		if ( !attributeTable ) then return end
		
		local attribute = catherine.character.GetVar( pl, "_att", { } )
		
		removeTime = removeTime or 5
		
		if ( attribute[ uniqueID ] ) then
			local temporaryTable = catherine.character.GetCharVar( pl, "attribute_temporary", { increase = { }, decrease = { } } )
			local progress = attribute[ uniqueID ].progress
			
			if ( progress < amount ) then
				amount = progress
			end
			
			local decreaseTable = temporaryTable.decrease[ uniqueID ]
			
			decreaseTable = {
				amount = amount,
				removeTime = removeTime
			}
			
			temporaryTable.decrease[ uniqueID ] = decreaseTable
			
			catherine.character.SetCharVar( pl, "attribute_temporary", temporaryTable )
			
			local charID = pl:GetCharacterID( )
			local timerID = "Catherine.timer.attribute.TemporaryDecreaseRemove." .. pl:SteamID( ) .. "." .. uniqueID .. "." .. charID
			local removeTime2 = removeTime
			
			timer.Remove( timerID )
			timer.Create( timerID, 3, 0, function( )
				if ( !IsValid( pl ) or charID != pl:GetCharacterID( ) ) then
					timer.Remove( timerID )
					return
				end
				
				if ( removeTime2 - 3 <= 0 ) then
					catherine.attribute.RemoveTemporaryDecreaseProgress( pl, uniqueID )
					timer.Remove( timerID )
					return
				end
				
				local attributeTable = catherine.attribute.FindByID( uniqueID )
				
				if ( !attributeTable ) then
					timer.Remove( timerID )
					return
				end
				
				local temporaryTable = catherine.character.GetCharVar( pl, "attribute_temporary", { increase = { }, decrease = { } } )
				
				if ( temporaryTable.decrease[ uniqueID ] ) then
					if ( !temporaryTable.decrease[ uniqueID ].removeTime or !temporaryTable.decrease[ uniqueID ].amount ) then
						timer.Remove( timerID )
						return
					end
					
					temporaryTable.decrease[ uniqueID ].removeTime = removeTime2 - 3
					removeTime2 = removeTime2 - 3
					
					catherine.character.SetCharVar( pl, "attribute_temporary", temporaryTable )
				else
					timer.Remove( timerID )
				end
			end )
		end
		
		hook.Run( "AttributeDecreased", pl, uniqueID, amount, removeTime )
	end
	
	function catherine.attribute.RemoveTemporaryIncreaseProgress( pl, uniqueID )
		if ( hook.Run( "PlayerShouldAttributeRemoveTemporaryIncrease", pl, uniqueID ) == false ) then return end
		local attributeTable = catherine.attribute.FindByID( uniqueID )
		
		if ( !attributeTable ) then return end
		
		local attribute = catherine.character.GetVar( pl, "_att", { } )
		
		if ( attribute[ uniqueID ] ) then
			local temporaryTable = catherine.character.GetCharVar( pl, "attribute_temporary", { increase = { }, decrease = { } } )
			
			if ( temporaryTable.increase[ uniqueID ] ) then
				temporaryTable.increase[ uniqueID ] = nil
			end
			
			catherine.character.SetCharVar( pl, "attribute_temporary", temporaryTable )
			
			hook.Run( "AttributeRemoveTemporaryIncrease", pl, uniqueID )
		end
	end
	
	function catherine.attribute.RemoveTemporaryDecreaseProgress( pl, uniqueID )
		if ( hook.Run( "PlayerShouldAttributeRemoveTemporaryDecrease", pl, uniqueID ) == false ) then return end
		local attributeTable = catherine.attribute.FindByID( uniqueID )
		
		if ( !attributeTable ) then return end
		
		local attribute = catherine.character.GetVar( pl, "_att", { } )
		
		if ( attribute[ uniqueID ] ) then
			local temporaryTable = catherine.character.GetCharVar( pl, "attribute_temporary", { increase = { }, decrease = { } } )
			
			if ( temporaryTable.decrease[ uniqueID ] ) then
				temporaryTable.decrease[ uniqueID ] = nil
			end
			
			catherine.character.SetCharVar( pl, "attribute_temporary", temporaryTable )
			
			hook.Run( "AttributeRemoveTemporaryDecrease", pl, uniqueID )
		end
	end
	
	function catherine.attribute.ClearTemporaryProgress( pl )
		if ( catherine.character.GetCharVar( pl, "attribute_temporary" ) ) then
			catherine.character.SetCharVar( pl, "attribute_temporary", nil )
		end
	end
	
	function catherine.attribute.SetProgress( pl, uniqueID, progress )
		local attributeTable = catherine.attribute.FindByID( uniqueID )
		
		if ( !attributeTable ) then return end
		
		local attribute = catherine.character.GetVar( pl, "_att", { } )
		
		if ( attribute[ uniqueID ] ) then
			attribute[ uniqueID ].progress = math.Clamp( progress, 0, attributeTable.max )
		else
			attribute[ uniqueID ] = {
				per = 0,
				progress = math.Clamp( progress, 0, attributeTable.max )
			}
		end
		
		catherine.character.SetVar( pl, "_att", attribute )
		
		hook.Run( "AttributeChanged", pl, uniqueID, attribute[ uniqueID ], "set" )
	end
	
	function catherine.attribute.AddProgress( pl, uniqueID, progress )
		local attributeTable = catherine.attribute.FindByID( uniqueID )
		
		if ( !attributeTable ) then return end
		
		local attribute = catherine.character.GetVar( pl, "_att", { } )
		
		if ( attribute[ uniqueID ] ) then
			if ( attribute[ uniqueID ].progress >= attributeTable.max ) then return end
			
			attribute[ uniqueID ].progress = math.Clamp( attribute[ uniqueID ].progress + progress, 0, attributeTable.max )
		else
			attribute[ uniqueID ] = {
				per = 0,
				progress = attributeTable.default
			}
		end
		
		catherine.character.SetVar( pl, "_att", attribute )
		
		hook.Run( "AttributeChanged", pl, uniqueID, attribute[ uniqueID ], "add" )
	end
	
	function catherine.attribute.RemoveProgress( pl, uniqueID, progress )
		local attributeTable = catherine.attribute.FindByID( uniqueID )
		
		if ( !attributeTable ) then return end
		
		local attribute = catherine.character.GetVar( pl, "_att", { } )
		
		if ( attribute[ uniqueID ] ) then
			attribute[ uniqueID ].progress = math.Clamp( attribute[ uniqueID ].progress - progress, 0, attributeTable.max )
			
			catherine.character.SetVar( pl, "_att", attribute )
			
			hook.Run( "AttributeChanged", pl, uniqueID, attribute[ uniqueID ], "remove" )
		end
	end
	
	function catherine.attribute.GetProgress( pl, uniqueID )
		local attribute = catherine.character.GetVar( pl, "_att", { } )
		
		if ( attribute[ uniqueID ] ) then
			local forceProgress = hook.Run( "AttributeAdjustGetProgress", pl, uniqueID )
			
			if ( forceProgress and type( forceProgress ) == "number" ) then
				return forceProgress
			end
			
			local progress = attribute[ uniqueID ].progress
			local temporaryTable = catherine.character.GetCharVar( pl, "attribute_temporary", { increase = { }, decrease = { } } )
			
			if ( temporaryTable.increase[ uniqueID ] ) then
				progress = progress + temporaryTable.increase[ uniqueID ].amount
			end
			
			if ( temporaryTable.decrease[ uniqueID ] ) then
				progress = progress - temporaryTable.decrease[ uniqueID ].amount
			end
			
			return progress
		else
			return 0
		end
	end
	
	function catherine.attribute.CreateNetworkRegistry( pl, charVars )
		if ( !charVars._att ) then return end
		local attribute = charVars._att
		local changed = false
		local count = table.Count( attribute )
		local attributeAll = catherine.attribute.GetAll( )
		
		for k, v in pairs( attribute ) do
			if ( catherine.attribute.FindByID( k ) ) then continue end
			
			attribute[ k ] = nil
			changed = true
		end
		
		if ( count != table.Count( attributeAll ) ) then
			for k, v in pairs( attributeAll ) do
				if ( attribute[ k ] ) then continue end
				
				attribute[ k ] = {
					per = 0,
					progress = v.default
				}
				changed = true
			end
		end
		
		if ( changed ) then
			catherine.character.SetVar( pl, "_att", attribute )
		end
		
		timer.Simple( 1, function( )
			local temporaryTable = catherine.character.GetCharVar( pl, "attribute_temporary", { increase = { }, decrease = { } } )
			local charID = pl:GetCharacterID( )
			local steamID = pl:SteamID( )
			
			for k, v in pairs( temporaryTable.increase ) do
				local timerID = "Catherine.timer.attribute.TemporaryIncreaseRemove." .. steamID .. "." .. k .. "." .. charID
				local removeTime = v.removeTime
				
				timer.Remove( timerID )
				timer.Create( timerID, 3, 0, function( )
					if ( !IsValid( pl ) or charID != pl:GetCharacterID( ) ) then
						timer.Remove( timerID )
						return
					end
					
					if ( removeTime - 3 <= 0 ) then
						catherine.attribute.RemoveTemporaryIncreaseProgress( pl, k )
						timer.Remove( timerID )
						return
					end
					
					local attributeTable = catherine.attribute.FindByID( k )
					
					if ( !attributeTable ) then
						timer.Remove( timerID )
						return
					end
					
					local temporaryTable = catherine.character.GetCharVar( pl, "attribute_temporary", { increase = { }, decrease = { } } )
					
					if ( temporaryTable.increase[ k ] ) then
						if ( !temporaryTable.increase[ k ].removeTime or !temporaryTable.increase[ k ].amount ) then
							timer.Remove( timerID )
							return
						end
						
						temporaryTable.increase[ k ].removeTime = removeTime - 3
						removeTime = removeTime - 3
						
						catherine.character.SetCharVar( pl, "attribute_temporary", temporaryTable )
					else
						timer.Remove( timerID )
					end
				end )
			end
			
			for k, v in pairs( temporaryTable.decrease ) do
				local timerID = "Catherine.timer.attribute.TemporaryDecreaseRemove." .. steamID .. "." .. k .. "." .. charID
				local removeTime = v.removeTime
				
				timer.Remove( timerID )
				timer.Create( timerID, 3, 0, function( )
					if ( !IsValid( pl ) or charID != pl:GetCharacterID( ) ) then
						timer.Remove( timerID )
						return
					end
					
					if ( removeTime - 3 <= 0 ) then
						catherine.attribute.RemoveTemporaryDecreaseProgress( pl, k )
						timer.Remove( timerID )
						return
					end
					
					local attributeTable = catherine.attribute.FindByID( k )
					
					if ( !attributeTable ) then
						timer.Remove( timerID )
						return
					end
					
					local temporaryTable = catherine.character.GetCharVar( pl, "attribute_temporary", { increase = { }, decrease = { } } )
					
					if ( temporaryTable.decrease[ k ] ) then
						if ( !temporaryTable.decrease[ k ].removeTime or !temporaryTable.decrease[ k ].amount ) then
							timer.Remove( timerID )
							return
						end
						
						temporaryTable.decrease[ k ].removeTime = removeTime - 3
						removeTime = removeTime - 3
						
						catherine.character.SetCharVar( pl, "attribute_temporary", temporaryTable )
					else
						timer.Remove( timerID )
					end
				end )
			end
		end )
	end
	
	hook.Add( "CreateNetworkRegistry", "catherine.attribute.CreateNetworkRegistry", catherine.attribute.CreateNetworkRegistry )
else
	function catherine.attribute.GetProgress( uniqueID )
		local forceProgress = hook.Run( "AttributeAdjustGetProgress", uniqueID )
		
		if ( forceProgress and type( forceProgress ) == "number" ) then
			return forceProgress
		end
		
		local attribute = catherine.character.GetVar( catherine.pl, "_att", { } )
		
		return attribute[ uniqueID ] and attribute[ uniqueID ].progress or 0
	end
	
	function catherine.attribute.GetTemporaryProgress( uniqueID )
		local forceProgress = { hook.Run( "AttributeAdjustGetTemporaryProgress", uniqueID ) }
		
		if ( forceProgress and type( forceProgress[ 1 ] ) == "number" and type( forceProgress[ 2 ] ) == "number" ) then
			return unpack( forceProgress )
		end
		
		local temporaryTable = catherine.character.GetCharVar( catherine.pl, "attribute_temporary", { increase = { }, decrease = { } } )
		local result = { 0, 0 }
		
		if ( temporaryTable.increase[ uniqueID ] ) then
			result[ 1 ] = temporaryTable.increase[ uniqueID ].amount
		end
		
		if ( temporaryTable.decrease[ uniqueID ] ) then
			result[ 2 ] = temporaryTable.decrease[ uniqueID ].amount
		end
		
		return unpack( result )
	end
end