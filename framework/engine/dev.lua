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

CAT_CONFIG_DEV_MODE = false
local funcData = {
	commands = {
		{
			command = "_cat_dev_forcespawn",
			func = function( pl, cmd, args )
				pl:Spawn( )
			end
		},
		{
			command = "_cat_dev_killandspawn",
			func = function( pl, cmd, args )
				pl:KillSilent( )
				pl:Spawn( )
			end
		},
		{
			command = "_cat_dev_rebootserver",
			func = function( pl, cmd, args )
				RunConsoleCommand( "changelevel", game.GetMap( ) )
			end
		}
	},
	hooks = {
		server = { },
		client = {
			{
				hookID = "PostRenderVGUI",
				hookFunc = function( )
					local pl = catherine.pl
					local w, h = ScrW( ), ScrH( )
					
					draw.RoundedBox( 0, w - 210, 30, 210, 215, Color( 0, 0, 0, 100 ) )
					draw.SimpleText( "CAT DEVELOPMENT MODE", "catherine_normal20", w - 10, 45, Color( 255, 0, 0, 255 ), TEXT_ALIGN_RIGHT, 1 )
					draw.SimpleText( "FRAME TIME - " .. math.Round( 1 / FrameTime( ) ), "catherine_normal15", w - 10, 65, Color( 0, 255, 0, 255 ), TEXT_ALIGN_RIGHT, 1 )
					draw.SimpleText( "CUR TIME - " .. math.Round( CurTime( ) ), "catherine_normal15", w - 10, 90, Color( 255, 255, 255, 255 ), TEXT_ALIGN_RIGHT, 1 )
					draw.SimpleText( "SYS TIME - " .. math.Round( SysTime( ) ), "catherine_normal15", w - 10, 110, Color( 255, 255, 255, 255 ), TEXT_ALIGN_RIGHT, 1 )
					draw.SimpleText( "REAL TIME - " .. math.Round( RealTime( ) ), "catherine_normal15", w - 10, 130, Color( 255, 255, 255, 255 ), TEXT_ALIGN_RIGHT, 1 )
					draw.SimpleText( "FRAME NUMBER - " .. FrameNumber( ), "catherine_normal15", w - 10, 150, Color( 255, 255, 255, 255 ), TEXT_ALIGN_RIGHT, 1 )
					draw.SimpleText( "SIZE MODE - (wide:" .. w .. ", tall:" .. h .. ")", "catherine_normal15", w - 10, 170, Color( 255, 255, 255, 255 ), TEXT_ALIGN_RIGHT, 1 )
					draw.SimpleText( "OS TIME - " .. os.time( ), "catherine_normal15", w - 10, 190, Color( 255, 255, 255, 255 ), TEXT_ALIGN_RIGHT, 1 )
					
					local pos, ang = pl:GetPos( ), pl:GetAngles( )
					draw.SimpleText( "POS - <" .. math.Round( pos.x ) .. ", " .. math.Round( pos.y ) .. ", " .. math.Round( pos.z ) .. ">", "catherine_normal15", w - 10, 210, Color( 255, 255, 255, 255 ), TEXT_ALIGN_RIGHT, 1 )
					draw.SimpleText( "ANG - <" .. math.Round( ang.p ) .. ", " .. math.Round( ang.y ) .. ", " .. math.Round( ang.r ) .. ">", "catherine_normal15", w - 10, 230, Color( 255, 255, 255, 255 ), TEXT_ALIGN_RIGHT, 1 )
				end
			}
		}
	}
}

if ( CAT_CONFIG_DEV_MODE ) then
	if ( SERVER ) then
		for k, v in pairs( funcData.commands ) do
			concommand.Add( v.command, function( pl, cmd, args )
				v.func( pl, cmd, args )
			end )
		end
		
		for k, v in pairs( funcData.hooks.server ) do
			hook.Add( v.hookID, "CAT_DEV_HOOKS_" .. v.hookID, function( ... )
				v.hookFunc( ... )
			end )
		end
	else
		for k, v in pairs( funcData.hooks.client ) do
			hook.Add( v.hookID, "CAT_DEV_HOOKS_" .. v.hookID, function( ... )
				v.hookFunc( ... )
			end )
		end
	end
else
	if ( SERVER ) then
		for k, v in pairs( funcData.commands ) do
			concommand.Remove( v.command )
		end
		
		for k, v in pairs( funcData.hooks.server ) do
			hook.Remove( v.hookID, "CAT_DEV_HOOKS_" .. v.hookID )
		end
	else
		for k, v in pairs( funcData.hooks.client ) do
			hook.Remove( v.hookID, "CAT_DEV_HOOKS_" .. v.hookID )
		end
	end
end