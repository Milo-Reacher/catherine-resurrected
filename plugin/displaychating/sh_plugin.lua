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

local PLUGIN = PLUGIN
PLUGIN.name = "^DC_Plugin_Name"
PLUGIN.author = "L7D"
PLUGIN.desc = "^DC_Plugin_Desc"

catherine.language.Merge( "english", {
	[ "DC_Plugin_Name" ] = "Display Chating",
	[ "DC_Plugin_Desc" ] = "Drawing the message if the chatting.",
	[ "DisplayChating_Talking" ] = "Talking ..."
} )

catherine.language.Merge( "korean", {
	[ "DC_Plugin_Name" ] = "채팅 표시",
	[ "DC_Plugin_Desc" ] = "해당 사람이 채팅을 치고 있는 경우 머리 위에 메세지를 출력합니다.",
	[ "DisplayChating_Talking" ] = "말 하는 중 ..."
} )

if ( SERVER ) then return end

function PLUGIN:PostPlayerDraw( pl )
	if ( !pl:IsChatTyping( ) ) then return end
	local lp = catherine.pl
	
	if ( !pl:Alive( ) or pl:IsNoclipping( ) ) then return end
	if ( catherine.block.IsBlocked( pl, CAT_BLOCK_TYPE_ALL_CHAT ) ) then return end
	
	local a = catherine.util.GetAlphaFromDistance( lp:GetPos( ), pl:GetPos( ), 312 )
	
	if ( a <= 0 ) then return end
	
	local index = pl:LookupBone( "ValveBiped.Bip01_Head1" )
	
	if ( index ) then
		local pos = pl:GetBonePosition( index )
		
		if ( pos ) then
			pos = pos + Vector( 0, 0, 15 )
			local ang = lp:EyeAngles( )
			
			pos = pos + ang:Up( )
			ang:RotateAroundAxis( ang:Forward( ), 90 )
			ang:RotateAroundAxis( ang:Right( ), 90 )
			
			if ( !self.typingText ) then
				self.typingText = LANG( "DisplayChating_Talking" )
			end
			
			local text = self.typingText

			surface.SetFont( "catherine_outline50" )
			local tw, th = surface.GetTextSize( text )
			
			cam.Start3D2D( pos, Angle( 0, ang.y, 90 ), 0.08 )
				draw.SimpleText( text, "catherine_outline50", 0 - tw / 2, 0, Color( 255, 255, 255, a ) )
			cam.End3D2D( )
		end
	end
end

function PLUGIN:LanguageChanged( )
	self.typingText = LANG( "DisplayChating_Talking" )
end