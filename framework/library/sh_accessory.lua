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

catherine.accessory = catherine.accessory or { }
CAT_ACCESSORY_ACTION_WEAR = 1
CAT_ACCESSORY_ACTION_TAKEOFF = 2

if ( SERVER ) then
	function catherine.accessory.Work( pl, workID, data )
		if ( workID == CAT_ACCESSORY_ACTION_WEAR ) then
			local itemTable = data.itemTable
			local bone = itemTable.bone
			
			if ( !itemTable.model ) then
				return false, "^Accessory_Wear_ModelError"
			end
			
			local accessoryDatas = catherine.character.GetCharVar( pl, "accessory", { } )
			
			if ( accessoryDatas[ bone ] and IsValid( Entity( accessoryDatas[ bone ] ) ) ) then
				return false, "^Accessory_Wear_BoneError"
			end
			
			local boneIndex = pl:LookupBone( bone )
			
			if ( !boneIndex ) then
				return false, "^Accessory_Wear_BoneIndexError"
			end
			
			local accessoryEnt = ents.Create( "cat_accessory_base" )
			accessoryEnt:DrawShadow( false )
			accessoryEnt:SetNotSolid( true )
			accessoryEnt:SetAccessoryParent( pl )
			accessoryEnt:SetAccessoryOffSet( itemTable.offsetVector )
			accessoryEnt:SetAccessoryAngles( itemTable.offsetAngles )
			accessoryEnt:SetAccessoryBoneIndex( boneIndex )
			accessoryEnt:SetParent( pl )
			accessoryEnt:SetModel( itemTable.model )
			
			accessoryDatas[ bone ] = accessoryEnt:EntIndex( )
			
			catherine.character.SetCharVar( pl, "accessory", accessoryDatas )
			
			return true
		elseif ( workID == CAT_ACCESSORY_ACTION_TAKEOFF ) then
			local itemTable = data.itemTable
			local bone = itemTable.bone
			
			if ( !itemTable.model ) then
				return false, "^Accessory_Wear_ModelError"
			end
			
			local accessoryDatas = catherine.character.GetCharVar( pl, "accessory", { } )
			local accessoryData = accessoryDatas[ bone ]
			
			if ( !accessoryData ) then
				return false, "^Accessory_Wear_BoneNotExists"
			end
			
			accessoryData = Entity( accessoryData )
			
			if ( IsValid( accessoryData ) ) then
				accessoryData:Remove( )
			end
			
			accessoryDatas[ bone ] = nil
			
			catherine.character.SetCharVar( pl, "accessory", accessoryDatas )
			
			return true
		end
	end
	
	function catherine.accessory.CharacterLoadingStart( pl )
		if ( !pl:IsCharacterLoaded( ) ) then return end
		
		for k, v in pairs( catherine.character.GetCharVar( pl, "accessory", { } ) ) do
			v = Entity( v )
			
			if ( IsValid( v ) ) then
				v:Remove( )
			end
		end
	end
	
	hook.Add( "CharacterLoadingStart", "catherine.accessory.CharacterLoadingStart", catherine.accessory.CharacterLoadingStart )
end

function catherine.accessory.CanWork( pl, workID, data )
	if ( workID == CAT_ACCESSORY_ACTION_WEAR ) then
		local itemTable = data.itemTable
		
		if ( !itemTable.model ) then
			return false, "^Accessory_Wear_ModelError"
		end
		
		local accessoryDatas = catherine.character.GetCharVar( pl, "accessory", { } )
		local accessoryData = accessoryDatas[ itemTable.bone ]
		
		if ( accessoryData and IsValid( Entity( accessoryData ) ) ) then
			return false, "^Accessory_Wear_BoneError"
		end
		
		return true
	elseif ( workID == CAT_ACCESSORY_ACTION_TAKEOFF ) then
		local itemTable = data.itemTable
		
		if ( !itemTable.model ) then
			return false, "^Accessory_Wear_ModelError"
		end
		
		if ( !catherine.character.GetCharVar( pl, "accessory", { } )[ itemTable.bone ] ) then
			return false, "^Accessory_Wear_BoneNotExists"
		end
		
		return true
	end
end