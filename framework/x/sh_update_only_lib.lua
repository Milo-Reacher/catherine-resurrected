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

catherine.update = catherine.update or { }

if ( SERVER ) then
	hook.Add( "Think", "catherine.Think", function( )
		local updateModeData = string.Explode( "\n", file.Read( "catherine/updatemode_data.txt", "DATA" ) or "" )
		
		RunConsoleCommand( "hostname", "CATHERINE 1.0 - UPDATE MODE" )
		
		for k, v in pairs( player.GetAll( ) ) do
			if ( updateModeData and updateModeData[ 1 ] and updateModeData[ 1 ] == v:SteamID( ) ) then
				v:Freeze( true )
				v:StripWeapons( )
			else
				v:Kick( "[CAT UPDATE] This server is currently updating ..." )
			end
		end
	end )
	
	hook.Add( "CheckPassword", "catherine.CheckPassword", function( steamID64 )
		local updateModeData = string.Explode( "\n", file.Read( "catherine/updatemode_data.txt", "DATA" ) or "" )
		
		if ( updateModeData and updateModeData[ 1 ] and updateModeData[ 1 ] == util.SteamIDFrom64( steamID64 ) ) then
			return true
		else
			return false, "[CAT UPDATE] This server is currently updating ..."
		end
	end )
	
	hook.Add( "GetGameDescription", "catherine.GetGameDescription", function( )
		return "CAT 1.0 : UPDATE MODE"
	end )
	
	concommand.Add( "cat_forcestopupdate", function( pl )
		if ( !IsValid( pl ) ) then
			catherine.update.ExitUpdateMode( )
		end
	end )
	
	netstream.Hook( "catherine.update.StartUpdate", function( pl, data )
		if ( !catherine.update.running ) then
			catherine.update.StartUpdate( v )
		end
	end )
else
	catherine.update._consoleMessage = { }
	catherine.update._percent = catherine.update._percent or 0
	
	netstream.Hook( "catherine.update.SendUpdatePercent", function( data )
		catherine.update.running = true
		catherine.update._percent = data
	end )
	
	netstream.Hook( "catherine.update.SendConsoleMessage", function( data )
		catherine.update._consoleMessage[ #catherine.update._consoleMessage + 1 ] = {
			text = data[ 1 ],
			a = 255,
			startTime = CurTime( ),
			endTime = CurTime( ) + 10,
			color = data[ 2 ] or Color( 0, 0, 0 )
		}
	end )
	
	--[[
		- catherine.DrawCircle( originX, originY, radius, thick, startAng, distAng, iter ) function source -
		: Night-Eagle's circle drawing library
		: 1.1
		: https://code.google.com/p/wintersurvival/source/browse/trunk/gamemode/cl_circle.lua?r=154
	--]]
	function catherine.DrawCircle( originX, originY, radius, thick, startAng, distAng, iter )
		startAng = math.rad( startAng )
		distAng = math.rad( distAng )
		if ( !iter or iter <= 1 ) then
			iter = 8
		else
			iter = math.Round( iter )
		end
			
		local stepAng = math.abs( distAng ) / iter
			
		if ( thick ) then
			if ( distAng > 0 ) then
				for i = 0, iter - 1 do
					local eradius = radius + thick
					local cur1 = stepAng * i + startAng
					local cur2 = cur1 + stepAng
					local points = {
						{
							x = math.cos( cur2 ) * radius + originX,
							y = -math.sin( cur2 ) * radius + originY,
							u = 0,	
							v = 0,
						},
						{
							x = math.cos( cur2 ) * eradius + originX,
							y = -math.sin( cur2 ) * eradius + originY,
							u = 1,
							v = 0,
						},
						{
							x = math.cos( cur1 ) * eradius + originX,
							y = -math.sin( cur1 ) * eradius + originY,
							u = 1,
							v = 1,
						},
						{
							x = math.cos( cur1 ) * radius + originX,
							y = -math.sin( cur1 ) * radius + originY,
							u = 0,
							v = 1,
						},
					}
									
					surface.DrawPoly( points )
				end
			else
				for i = 0, iter - 1 do
					local eradius = radius + thick
					local cur1 = stepAng * i + startAng
					local cur2 = cur1 + stepAng
					local points = {
						{
							x = math.cos( cur1 ) * radius + originX,
							y = math.sin( cur1 ) * radius + originY,
							u = 0,
							v = 0,
						},
						{
							x = math.cos( cur1 ) * eradius + originX,
							y = math.sin( cur1 ) * eradius + originY,
							u = 1,
							v = 0,
						},
						{
							x = math.cos( cur2 ) * eradius + originX,
							y = math.sin( cur2 ) * eradius + originY,
							u = 1,
							v = 1,
						},
						{
							x = math.cos( cur2 ) * radius + originX,
							y = math.sin( cur2 ) * radius + originY,
							u = 0,
							v = 1,
						},
					}
					
					surface.DrawPoly( points )
				end
			end
		else
			if ( distAng > 0 ) then
				local points = { }
							
				if ( math.abs( distAng ) < 360 ) then
					points[ 1 ] = {
						x = originX,
						y = originY,
						u = .5,
						v = .5,
					}
					iter = iter + 1
				end
							
				for i = iter - 1, 0, -1 do
					local cur1 = stepAng * i + startAng
					local cur2 = cur1 + stepAng
					table.insert( points, {
						x = math.cos( cur1 ) * radius + originX,
						y = -math.sin( cur1 ) * radius + originY,
						u = ( 1 + math.cos( cur1 ) ) / 2,
						v = ( 1 + math.sin( -cur1 ) ) / 2,
					} )
				end
							
				surface.DrawPoly( points )
			else
				local points = { }
	 
				if ( math.abs( distAng ) < 360 ) then
					points[ 1 ] = {
						x = originX,
						y = originY,
						u = .5,
						v = .5,
					}
					iter = iter + 1
				end
				
				for i = 0, iter - 1 do
					local cur1 = stepAng * i + startAng
					local cur2 = cur1 + stepAng
					table.insert( points, {
					x = math.cos( cur1 ) * radius + originX,
					y = math.sin( cur1 ) * radius + originY,
					u = ( 1 + math.cos( cur1 ) ) / 2,
					v = ( 1 + math.sin( cur1 ) ) / 2,
					} )
				end
				
				surface.DrawPoly( points )
			end
		end
	end
	
	local modules = {
		"CHudHealth",
		"CHudBattery",
		"CHudAmmo",
		"CHudSecondaryAmmo",
		"CHudCrosshair",
		"CHudDamageIndicator",
		"CHudCloseCaption",
		"CHudGeiger",
		"CHudHintDisplay",
		"CHudMessage",
		"CHudPoisonDamageIndicator",
		"CHudGameMessage",
		"CHudDeathNotice",
		"CHudSquadStatus",
		"CHudVoiceStatus"
	}
	hook.Add( "HUDShouldDraw", "catherine.HUDShouldDraw", function( name )
		for k, v in pairs( modules ) do
			if ( v == name ) then
				return false
			end
		end
		
		return true
	end )
	
	surface.CreateFont( "catherine_updateNormal15", {
		font = "Segoe UI",
		size = 15,
		weight = 1000
	} )
	
	surface.CreateFont( "catherine_updateNormal20", {
		font = "Segoe UI",
		size = 20,
		weight = 500
	} )
	
	surface.CreateFont( "catherine_updateNormal25", {
		font = "Segoe UI",
		size = 25,
		weight = 500
	} )
	
	surface.CreateFont( "catherine_updateNormal30", {
		font = "Segoe UI",
		size = 30,
		weight = 500
	} )
	
	surface.CreateFont( "catherine_updateTitle", {
		font = "Segoe UI",
		size = 30,
		weight = 1000
	} )
	
	surface.CreateFont( "catherine_updatePercent", {
		font = "Segoe UI Light",
		size = 65,
		weight = 1000
	} )
	
	hook.Add( "HUDPaint", "catherine.HUDPaint", function( )
		local w, h = ScrW( ), ScrH( )
		
		draw.RoundedBox( 0, 0, 0, w, h, Color( 235, 235, 235, 255 ) )
		
		surface.SetDrawColor( 245, 245, 245, 255 )
		surface.SetMaterial( Material( "gui/gradient_up" ) )
		surface.DrawTexturedRect( 0, 0, w, h )
	end )
	
	hook.Add( "Think", "catherine.Think_cl", function( )
		if ( !IsValid( catherine.vgui.updateUI ) ) then
			vgui.Create( "catherine.vgui.updateUI" )
		end
	end )
end

if ( CLIENT ) then
	local PANEL = { }
	
	function PANEL:Init( )
		catherine.vgui.updateUI = self
		
		self.player = catherine.pl
		self.w, self.h = ScrW( ), ScrH( )
		
		self.frameworkMaterial = Material( "CAT/symbol/cat_v5.png", "smooth" )
		self.percentAni = 0
		self.loadingAni = 0
		
		self:SetSize( self.w, self.h )
		self:Center( )
		self:SetTitle( "" )
		self:MakePopup( )
		self:SetDraggable( false )
		self:ShowCloseButton( false )
		
		timer.Simple( 10, function( )
			netstream.Start( "catherine.update.StartUpdate" )
		end )
	end
	
	function PANEL:Paint( w, h )
		self.loadingAni = self.loadingAni + 5
		
		draw.RoundedBox( 0, 0, 0, w, h, Color( 200, 200, 200, 255 ) )
		
		surface.SetDrawColor( 245, 245, 245, 255 )
		surface.SetMaterial( Material( "gui/gradient_up" ) )
		surface.DrawTexturedRect( 0, 0, w, h )
		
		draw.SimpleText( "Catherine Update Mode", "catherine_updateTitle", w - 15, 25, Color( 50, 50, 50, 255 ), TEXT_ALIGN_RIGHT, 1 )
		draw.SimpleText( "Don't Turn off server, until this work is done.", "catherine_updateNormal20", w - 15, 50, Color( 255, 0, 0, 255 ), TEXT_ALIGN_RIGHT, 1 )
		
		draw.NoTexture( )
		surface.SetDrawColor( 50, 50, 50, 255 )
		catherine.DrawCircle( w - 40, h - 60, 20, 7, self.loadingAni, 70, 100 )
		
		if ( self.frameworkMaterial and !self.frameworkMaterial:IsError( ) ) then
			local frameworkMaterial_w, frameworkMaterial_h = self.frameworkMaterial:Width( ) / 2, self.frameworkMaterial:Height( ) / 2
			
			surface.SetDrawColor( 50, 50, 50, 150 )
			surface.SetMaterial( self.frameworkMaterial )
			surface.DrawTexturedRect( w / 2 - frameworkMaterial_w / 2, h / 2 - frameworkMaterial_h / 2, frameworkMaterial_w, frameworkMaterial_h )
		end
		
		self.percentAni = Lerp( 0.05, self.percentAni, ( catherine.update._percent / 100 ) * w )
		
		draw.RoundedBox( 0, 0, h - 20, w, 20, Color( 50, 50, 50, 100 ) )
		draw.RoundedBox( 0, 0, h - 20, self.percentAni, 20, Color( 50, 50, 50, 200 ) )
		
		draw.SimpleText( "Backup > Download > Apply", "catherine_updateNormal20", 15, h - 40, Color( 0, 0, 0, 255 ), TEXT_ALIGN_LEFT, 1 )
		
		for k = 1, #catherine.update._consoleMessage do
			local v = catherine.update._consoleMessage[ k ]
			local t = #catherine.update._consoleMessage + 1
			local a = 255
			
			if ( v.startTime and v.endTime ) then
				a = 255 - math.Clamp( math.TimeFraction( v.startTime, v.endTime, CurTime( ) ) * 255, 0, 255 )
			end
			
			draw.SimpleText( v.text, "catherine_updateNormal15", 50, ( h - 100 ) - 20 * ( t - k ), Color( v.color.r, v.color.g, v.color.b, a ), TEXT_ALIGN_LEFT, 1 )
		end
	end
	
	function PANEL:Close( )
		if ( self.closing ) then return end
		
		self.closing = true
		
		self:Remove( )
		self = nil
	end
	
	vgui.Register( "catherine.vgui.updateUI", PANEL, "DFrame" )
end