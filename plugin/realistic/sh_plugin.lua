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
PLUGIN.name = "^Realistic_Plugin_Name"
PLUGIN.author = "Black Tea, L7D"
PLUGIN.desc = "^Realistic_Plugin_Desc"

catherine.language.Merge( "english", {
	[ "Option_Str_Realistic_Name" ] = "Enable Realistic Effect",
	[ "Option_Str_Realistic_Desc" ] = "Enable the Realistic effect.",
	[ "Option_Str_Mosue_Smoothing_Scale_Name" ] = "Mouse Smoothing Effect Scale",
	[ "Option_Str_Mosue_Smoothing_Scale_Desc" ] = "Changed the Effect scale of the Mouse Smoothing.",
	[ "Option_Str_Mosue_Smoothing_Scale_Option01" ] = "High",
	[ "Option_Str_Mosue_Smoothing_Scale_Option02" ] = "Medium",
	[ "Option_Str_Mosue_Smoothing_Scale_Option03" ] = "Low",
	[ "Option_Str_Mosue_Smoothing_Scale_Option04" ] = "None",
	[ "Option_Category_Realistic" ] = "Realistic Effect",
	[ "Realistic_Plugin_Name" ] = "Realistic Effect",
	[ "Realistic_Plugin_Desc" ] = "Good stuff."
} )

catherine.language.Merge( "korean", {
	[ "Option_Str_Realistic_Name" ] = "사실적인 효과 활성화",
	[ "Option_Str_Realistic_Desc" ] = "사실적인 효과를 활성화 합니다.",
	[ "Option_Str_Mosue_Smoothing_Scale_Name" ] = "마우스 스무딩 효과 강도",
	[ "Option_Str_Mosue_Smoothing_Scale_Desc" ] = "마우스 스무딩 효과의 강도를 조정합니다.",
	[ "Option_Str_Mosue_Smoothing_Scale_Option01" ] = "높음",
	[ "Option_Str_Mosue_Smoothing_Scale_Option02" ] = "보통",
	[ "Option_Str_Mosue_Smoothing_Scale_Option03" ] = "낮음",
	[ "Option_Str_Mosue_Smoothing_Scale_Option04" ] = "없음",
	[ "Option_Category_Realistic" ] = "사실적인 효과",
	[ "Realistic_Plugin_Name" ] = "사실적인 효과",
	[ "Realistic_Plugin_Desc" ] = "여러가지 사실적인 효과를 추가합니다."
} )

if ( SERVER ) then return end

PLUGIN.config = { }
PLUGIN.config.noHeadbobWeaponClass = {
	"weapon_physgun",
	"gmod_tool",
}
PLUGIN.currAng = PLUGIN.currAng or Angle( 0, 0, 0 )
PLUGIN.currPos = PLUGIN.currPos or Vector( 0, 0, 0 )
PLUGIN.targetAng = PLUGIN.targetAng or Angle( 0, 0, 0 )
PLUGIN.targetPos = PLUGIN.targetPos or Vector( 0, 0, 0 )
PLUGIN.resultAng = PLUGIN.resultAng or Angle( 0, 0, 0 )

local velo = FindMetaTable( "Entity" ).GetVelocity
local twoD = FindMetaTable( "Vector" ).Length2D
local math_Clamp = math.Clamp

function PLUGIN:Initialize( )
	CAT_CONVAR_REALISTIC = CreateClientConVar( "cat_convar_realistic", "1", true, true )
	CAT_CONVAR_MOUSE_SMOOTHING_SCALE = CreateClientConVar( "cat_convar_mouse_smoothing_scale", "1", true, true )
end

function PLUGIN:CalcView( pl, pos, ang, fov )
	if ( GetConVarString( "cat_convar_realistic" ) == "0" ) then return end
	if ( IsValid( catherine.vgui.character ) or IsValid( catherine.vgui.question ) ) then return end
	if ( pl:CanOverrideView( ) or pl:GetViewEntity( ) != pl ) then return end
	local wep = pl:GetActiveWeapon( )
	
	if ( IsValid( wep ) ) then
		if ( table.HasValue( self.config.noHeadbobWeaponClass, wep:GetClass( ) ) ) then
			return
		end
	end
	
	local mouseSmoothingScale = 0
	
	if ( GetConVarString( "cat_convar_mouse_smoothing_scale" ) == "1" ) then
		mouseSmoothingScale = 19
	elseif ( GetConVarString( "cat_convar_mouse_smoothing_scale" ) == "2" ) then
		mouseSmoothingScale = 16
	elseif ( GetConVarString( "cat_convar_mouse_smoothing_scale" ) == "3" ) then
		mouseSmoothingScale = 13
	end
	
	local realTime = RealTime( )
	local frameTime = FrameTime( )
	local vel = math.floor( twoD( velo( pl ) ) )
	
	if ( pl:OnGround( ) ) then
		local walkSpeed = pl:GetWalkSpeed( )
		
		if ( vel > walkSpeed + 5 ) then
			local runSpeed = pl:GetRunSpeed( )
			
			local perc = math_Clamp( vel / runSpeed * 100, 0.5, 5 )
			self.targetAng = Angle( math.abs( math.cos( realTime * ( runSpeed / 33 ) ) * 0.4 * perc ), math.sin( realTime * ( runSpeed / 29 ) ) * 0.5 * perc, 0 )
			self.targetPos = Vector( 0, 0, math.sin( realTime * ( runSpeed / 30 ) ) * 0.4 * perc )
		else
			local perc = math_Clamp( ( vel / walkSpeed * 100 ) / 30, 0, 4 )
			self.targetAng = Angle( math.cos( realTime * ( walkSpeed / 8 ) ) * 0.2 * perc, 0, 0 )
			self.targetPos = Vector( 0, 0, ( math.sin( realTime * ( walkSpeed / 8 ) ) * 0.5 ) * perc )
		end
	else
		if ( pl:IsNoclipping( ) or !pl:OnGround( ) ) then
			self.targetPos = Vector( 0, 0, 0 )
			self.targetAng = Angle( 0, 0, 0 )
		else
			if ( pl:WaterLevel( ) >= 2 ) then
				self.targetPos = Vector( 0, 0, 0 )
				self.targetAng = Angle( 0, 0, 0 )
			else
				vel = math.abs( pl:GetVelocity( ).z )
				local af = 0
				local perc = math_Clamp( vel / 200, 0.1, 8 )
				
				if ( perc > 1 ) then
					af = perc
				end
				
				self.targetAng = Angle( math.cos( realTime * 15 ) * 2 * perc + math.Rand( -af * 2, af * 2 ), math.sin( realTime * 15 ) * 2 * perc + math.Rand( -af * 2, af * 2 ) ,math.Rand( -af * 5, af * 5 ) )
				self.targetPos = Vector( math.cos( realTime * 15 ) * 0.5 * perc, math.sin( realTime * 15 ) * 0.5 * perc, 0 )
			end
		end
	end
	
	if ( mouseSmoothingScale != 0 ) then
		self.resultAng = LerpAngle( math_Clamp( math_Clamp( frameTime, 1 / 120, 1 ) * mouseSmoothingScale, 0, 5 ), self.resultAng, ang )
	else
		self.resultAng = ang
	end
	
	self.currAng = LerpAngle( frameTime * 10, self.currAng, self.targetAng )
	self.currPos = LerpVector( frameTime * 10, self.currPos, self.targetPos )
	
	return {
		origin = pos + self.currPos,
		angles = self.resultAng + self.currAng,
		fov = fov
	}
end

catherine.option.Register( "CONVAR_REALISTIC", "cat_convar_realistic", "^Option_Str_Realistic_Name", "^Option_Str_Realistic_Desc", "^Option_Category_Realistic", CAT_OPTION_SWITCH )
catherine.option.Register( "CONVAR_MOUSE_SMOOTHING_SCALE", "cat_convar_mouse_smoothing_scale", "^Option_Str_Mosue_Smoothing_Scale_Name", "^Option_Str_Mosue_Smoothing_Scale_Desc", "^Option_Category_Realistic", CAT_OPTION_LIST, function( )
	local result = {
		data = {
			{
				func = function( )
					RunConsoleCommand( "cat_convar_mouse_smoothing_scale", "3" )
				end,
				name = LANG( "Option_Str_Mosue_Smoothing_Scale_Option01" )
			},
			{
				func = function( )
					RunConsoleCommand( "cat_convar_mouse_smoothing_scale", "2" )
				end,
				name = LANG( "Option_Str_Mosue_Smoothing_Scale_Option02" )
			},
			{
				func = function( )
					RunConsoleCommand( "cat_convar_mouse_smoothing_scale", "1" )
				end,
				name = LANG( "Option_Str_Mosue_Smoothing_Scale_Option03" )
			},
			{
				func = function( )
					RunConsoleCommand( "cat_convar_mouse_smoothing_scale", "0" )
				end,
				name = LANG( "Option_Str_Mosue_Smoothing_Scale_Option04" )
			}
		},
		curVal = "0"
	}
	
	for i = 4, 1, -1 do
		if ( GetConVarString( "cat_convar_mouse_smoothing_scale" ) == tostring( 4 - i ) ) then
			result.curVal = LANG( "Option_Str_Mosue_Smoothing_Scale_Option0" .. i )
		end
	end
	
	return result
end )