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

catherine.hint = catherine.hint or { }
catherine.hint.lists = { }

function catherine.hint.Register( message, canLook )
	catherine.hint.lists[ #catherine.hint.lists + 1 ] = {
		message = message,
		canLook = canLook
	}
end

function catherine.hint.Remove( index )
	table.remove( catherine.hint.lists, index )
end

function catherine.hint.GetAll( )
	return catherine.hint.lists
end

function catherine.hint.FindByIndex( index )
	return catherine.hint.lists[ index ]
end

if ( SERVER ) then
	catherine.hint.nextHintTick = catherine.hint.nextHintTick or catherine.configs.hintInterval
	
	function catherine.hint.SendHint( pl, index )
		if ( pl:GetInfo( "cat_convar_hint" ) == "0" ) then return end
		local hintTable = catherine.hint.FindByIndex( index )
		
		if ( !hintTable ) then return end
		if ( hook.Run( "PlayerShouldSendHint", pl, hintTable ) == false or ( hintTable.canLook and hintTable.canLook( pl ) == false ) ) then return end
		
		netstream.Start( pl, "catherine.hint.Receive", index )
	end
	
	function catherine.hint.SendRandomHint( pl )
		if ( pl:GetInfo( "cat_convar_hint" ) == "0" ) then return end
		local index = math.random( 1, #catherine.hint.lists )
		local hintTable = catherine.hint.FindByIndex( index )
		
		if ( !hintTable ) then return end
		if ( hook.Run( "PlayerShouldSendHint", pl, hintTable ) == false or ( hintTable.canLook and hintTable.canLook( pl ) == false ) ) then return end
		
		netstream.Start( pl, "catherine.hint.Receive", index )
	end
	
	function catherine.hint.SendHintToAllPlayer( index )
		for k, v in pairs( player.GetAllByLoaded( ) ) do
			catherine.hint.SendHint( v, index )
		end
	end
	
	function catherine.hint.SendRandomHintToAllPlayer( )
		for k, v in pairs( player.GetAllByLoaded( ) ) do
			catherine.hint.SendRandomHint( v )
		end
	end
	
	timer.Create( "Catherine.timer.hint.AutoSendRandomHintToAllPlayer", catherine.configs.hintInterval, 0, function( )
		if ( #catherine.hint.GetAll( ) != 0 ) then
			catherine.hint.SendRandomHintToAllPlayer( )
		end
	end )
else
	catherine.hint.currHint = catherine.hint.currHint or nil
	local gradient_right = Material( "VGUI/gradient-r" )
	
	netstream.Hook( "catherine.hint.Receive", function( data )
		local hintTable = catherine.hint.FindByIndex( data )
		
		if ( !hintTable ) then return end
		
		local msg = catherine.util.StuffLanguage( hintTable.message )
		
		surface.SetFont( "catherine_normal20" )
		
		local tw, th = surface.GetTextSize( msg )
		
		local hintData = {
			index = data,
			message = msg,
			time = CurTime( ) + 15,
			a = 0,
			tw = tw
		}
		
		hintData = hook.Run( "PreAddHint", catherine.pl, hintData ) or hintData
		
		catherine.hint.currHint = hintData
	end )
	
	function catherine.hint.Draw( )
		if ( !catherine.hint.currHint or GetConVarString( "cat_convar_hint" ) == "0" ) then return end
		if ( hook.Run( "ShouldDrawHint", catherine.pl, catherine.hint.currHint ) == false ) then return end
		local t = catherine.hint.currHint
		
		if ( t.time <= CurTime( ) ) then
			t.a = Lerp( 0.02, t.a, 0 )
			
			if ( math.Round( t.a ) <= 0 ) then
				catherine.hint.currHint = nil
				return
			end
		else
			t.a = Lerp( 0.02, t.a, 255 )
		end
		
		draw.SimpleText( t.message, "catherine_outline20", ScrW( ) - 10, 15, Color( 255, 255, 255, t.a ), TEXT_ALIGN_RIGHT, 1 )
	end
end

catherine.hint.Register( "^Hint_Message_01" )
catherine.hint.Register( "^Hint_Message_02" )
catherine.hint.Register( "^Hint_Message_03" )
catherine.hint.Register( "^Hint_Message_04" )
catherine.hint.Register( "^Hint_Message_05" )