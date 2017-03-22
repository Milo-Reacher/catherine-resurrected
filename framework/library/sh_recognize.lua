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

catherine.recognize = catherine.recognize or { }

if ( SERVER ) then
	function catherine.recognize.DoKnow( pl, code, target )
		target = { target } or nil
		
		if ( code == 0 ) then
			target = target or catherine.chat.GetListener( pl, "ic" )
		else
			target = catherine.chat.GetListener( pl, code == 1 and "whisper" or "yell" )
		end
		
		for k, v in pairs( target or { } ) do
			if ( pl == v ) then continue end
			if ( !IsValid( v ) ) then continue end
			
			catherine.recognize.RegisterKnow( pl, v )
		end
		
		catherine.util.PlaySimpleSound( pl, "buttons/button17.wav" )
	end
	
	function catherine.recognize.RegisterKnow( pl, target )
		local recognizeList = catherine.character.GetCharVar( target, "recognize", { } )
		
		recognizeList[ #recognizeList + 1 ] = pl:GetCharacterID( )
		
		recognizeList = hook.Run( "AdjustRecognizeInfo", pl, target, recognizeList ) or recognizeList
		
		catherine.character.SetCharVar( target, "recognize", recognizeList )
	end
	
	function catherine.recognize.Initialize( pl )
		catherine.character.SetCharVar( pl, "recognize", { } )
	end
	
	netstream.Hook( "catherine.recognize.DoKnow", function( pl, data )
		catherine.recognize.DoKnow( pl, data[ 1 ], data[ 2 ] )
	end )
else
	netstream.Hook( "catherine.recognize.SelectMenu", function( )
		if ( IsValid( catherine.vgui.recognize ) ) then
			catherine.vgui.recognize:Remove( )
			catherine.vgui.recognize = nil
		end
		
		catherine.vgui.recognize = vgui.Create( "catherine.vgui.recognize" )
	end )
end

function catherine.recognize.IsKnowTarget( pl, target )
	local factionTable = catherine.faction.FindByIndex( target:Team( ) )
	
	return ( factionTable and factionTable.alwaysRecognized ) and true or table.HasValue( catherine.character.GetCharVar( pl, "recognize", { } ), target:GetCharacterID( ) )
end

local META = FindMetaTable( "Player" )

function META:IsKnow( target )
	local factionTable = catherine.faction.FindByIndex( target:Team( ) )
	
	return ( factionTable and factionTable.alwaysRecognized ) and true or table.HasValue( catherine.character.GetCharVar( self, "recognize", { } ), target:GetCharacterID( ) )
end