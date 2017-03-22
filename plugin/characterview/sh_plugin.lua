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
PLUGIN.name = "^CharacterView_Plugin_Name"
PLUGIN.author = "L7D"
PLUGIN.desc = "^CharacterView_Plugin_Desc"
PLUGIN.charViews = PLUGIN.charViews or { }

catherine.language.Merge( "english", {
	[ "CharacterView_Plugin_Name" ] = "Character View",
	[ "CharacterView_Plugin_Desc" ] = "Adding the Character View in the Character menu.",
	[ "CharacterView_Notify_Add" ] = "You are added character view on your position.",
	[ "CharacterView_Notify_Remove" ] = "You are removed %s's character view on your position.",
	[ "CharacterView_Notify_NoView" ] = "Doesn't have character view on this position."
} )

catherine.language.Merge( "korean", {
	[ "CharacterView_Plugin_Name" ] = "캐릭터 뷰",
	[ "CharacterView_Plugin_Desc" ] = "캐릭터 창에 위치 시점을 추가합니다.",
	[ "CharacterView_Notify_Add" ] = "당신은 현재 캐릭터 뷰를 추가했습니다.",
	[ "CharacterView_Notify_Remove" ] = "당신은 이 위치에 있는 %s개의 캐릭터 뷰를 제거했습니다.",
	[ "CharacterView_Notify_NoView" ] = "이 위치에는 캐릭터 뷰가 없습니다!"
} )

catherine.util.Include( "sv_plugin.lua" )

catherine.command.Register( {
	uniqueID = "&uniqueID_charViewAdd",
	command = "charviewadd",
	desc = "Add the Character View.",
	canRun = function( pl ) return pl:IsSuperAdmin( ) end,
	runFunc = function( pl, args )
		PLUGIN:AddCharView( pl:GetPos( ), pl:EyeAngles( ) )
		
		catherine.util.NotifyLang( pl, "CharacterView_Notify_Add" )
	end
} )

catherine.command.Register( {
	uniqueID = "&uniqueID_charViewRemove",
	command = "charviewremove",
	desc = "Remove the Character View.",
	syntax = "[Range]",
	canRun = function( pl ) return pl:IsSuperAdmin( ) end,
	runFunc = function( pl, args )
		local pos = pl:GetPos( )
		local i = 0
		local range = math.max( tonumber( args[ 1 ] or 256 ), 1 )
		
		for k, v in pairs( PLUGIN.charViews ) do
			if ( pos:Distance( v.pos ) <= range ) then
				PLUGIN.charViews[ k ] = nil
				i = i + 1
			end
		end

		if ( i == 0 ) then
			catherine.util.NotifyLang( pl, "CharacterView_Notify_NoView" )
		else
			PLUGIN:SyncViews( )
			
			catherine.util.NotifyLang( pl, "CharacterView_Notify_Remove", i )
		end
	end
} )

if ( SERVER ) then return end

PLUGIN.nextViewChange = PLUGIN.nextViewChange or RealTime( ) + 5
PLUGIN.thirdPersonChange = PLUGIN.thirdPersonChange or false

netstream.Hook( "catherine.plugin.characterview.SyncViews", function( data )
	PLUGIN.charViews = data
	
	catherine.character.SetCustomBackground( #data > 0 and true or false )
end )

function PLUGIN:ShouldDrawLocalPlayer( pl )
	if ( pl:IsActioning( ) ) then return end
	
	if ( ( IsValid( catherine.vgui.character ) or IsValid( catherine.vgui.question ) or catherine.intro.status ) and catherine.character.IsCustomBackground( ) ) then
		if ( GetConVarString( "cat_convar_thirdperson" ) == "1" ) then
			RunConsoleCommand( "cat_convar_thirdperson", "0" )
			self.thirdPersonChange = true
		end
		
		return true
	end
	
	if ( self.thirdPersonChange ) then
		RunConsoleCommand( "cat_convar_thirdperson", "1" )
		self.thirdPersonChange = false
	end
end

function PLUGIN:RenderScreenspaceEffects( )
	if ( ( IsValid( catherine.vgui.character ) or IsValid( catherine.vgui.question ) or catherine.intro.status ) and catherine.character.IsCustomBackground( ) ) then
		local tab = { }
		tab[ "$pp_colour_addr" ] = 0
		tab[ "$pp_colour_addg" ] = 0
		tab[ "$pp_colour_addb" ] = 0
		tab[ "$pp_colour_brightness" ] = 0
		tab[ "$pp_colour_contrast" ] = 1
		tab[ "$pp_colour_colour" ] = 0
		tab[ "$pp_colour_mulr" ] = 0
		tab[ "$pp_colour_mulg" ] = 0
		tab[ "$pp_colour_mulb" ] = 0
		
		tab = hook.Run( "AdjustCharacterViewColorEffectData", tab ) or tab
		
		DrawColorModify( tab )
	end
end

function PLUGIN:CalcView( pl, pos, ang, fov )
	if ( !catherine.character.IsCustomBackground( ) ) then return end
	if ( #self.charViews <= 0 ) then return end
	
	if ( IsValid( catherine.vgui.character ) or IsValid( catherine.vgui.question ) or catherine.intro.status ) then
		if ( !self.lastView ) then
			self.lastView = table.Random( self.charViews )
		end
		
		if ( self.nextViewChange <= SysTime( ) ) then
			self.lastView = table.Random( self.charViews )
			self.nextViewChange = SysTime( ) + math.random( 10, 20 )
		end
		
		if ( !self.lastPos or !self.lastAng ) then
			self.lastPos = self.lastView.pos
			self.lastAng = self.lastView.ang
		end
		
		self.lastPos = LerpVector( 0.05, self.lastPos, self.lastView.pos )
		self.lastAng = LerpAngle( 0.05, self.lastAng, self.lastView.ang )
		
		return {
			origin = self.lastPos,
			angles = self.lastAng
		}
	end
end