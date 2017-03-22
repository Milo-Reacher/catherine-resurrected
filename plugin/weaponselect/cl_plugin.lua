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
PLUGIN.slotData = PLUGIN.slotData or { }
PLUGIN.currSlot = PLUGIN.currSlot or 1
PLUGIN.nextBind = PLUGIN.nextBind or 0
PLUGIN.canSelect = false
PLUGIN.maxX = PLUGIN.maxX or 0

local catherine_util_stuffLanguage = catherine.util.StuffLanguage
local gradient_left = Material( "gui/gradient" )

catherine.hud.RegisterBlockModule( "CHudWeaponSelection" )

function PLUGIN:PlayerBindPress( pl, bind, pressed )
	if ( hook.Run( "ShouldChangeWeapon", pl ) == false ) then return end
	local weaponsCount = #pl:GetWeapons( )
	
	if ( weaponsCount == 0 ) then return end
	
	if ( bind == "+attack" and pressed ) then
		if ( self.canSelect ) then
			local selectWeapon = self.slotData[ self.currSlot ]
			
			if ( selectWeapon and pl:HasWeapon( selectWeapon.uniqueID ) ) then
				for k, v in pairs( self.slotData ) do
					v.targetA = 0
					v.autoFade = CurTime( )
				end
			
				RunConsoleCommand( "cat_plugin_ws_select", selectWeapon.uniqueID )
				
				surface.PlaySound( "ui/buttonclickrelease.wav" )
			end
			
			self.canSelect = false
			
			return true
		end
	end
	
	if ( self.nextBind <= CurTime( ) ) then
		if ( ( bind == "invnext" or bind == "slot1" ) and pressed ) then
			if ( self.currSlot < weaponsCount ) then
				self.currSlot = self.currSlot + 1
			elseif ( self.currSlot >= weaponsCount ) then
				self.currSlot = 1
			end
			
			surface.PlaySound( "common/talk.wav" )
			
			hook.Run( "WeaponSlotChanged", pl, self.currSlot )
			
			self.nextBind = CurTime( ) + 0.08
			
			for k, v in pairs( self.slotData ) do
				v.a = 255
				v.targetA = 255
				v.autoFade = CurTime( ) + 3
			end
			
			self.canSelect = true
			
			return true
		elseif ( ( bind == "invprev" or bind == "slot2" ) and pressed ) then
			if ( self.currSlot > 1 ) then
				self.currSlot = self.currSlot - 1
			elseif ( self.currSlot <= 1 ) then
				self.currSlot = weaponsCount
			end
			
			surface.PlaySound( "common/talk.wav" )
			
			hook.Run( "WeaponSlotChanged", pl, self.currSlot )
			
			self.nextBind = CurTime( ) + 0.08
			
			for k, v in pairs( self.slotData ) do
				v.a = 255
				v.targetA = 255
				v.autoFade = CurTime( ) + 3
			end
			
			self.canSelect = true
			
			return true
		end
	end
end

function PLUGIN:ShouldChangeWeapon( pl )
	if ( pl:InVehicle( ) ) then
		return false
	end
	
	local wep = pl:GetActiveWeapon( )
	
	if ( IsValid( wep ) and wep:GetClass( ) == "weapon_physgun" and pl:KeyDown( IN_ATTACK ) ) then
		return false
	end
end

function PLUGIN:ShouldDrawWeaponSelect( pl )
	if ( !catherine.pl:IsCharacterLoaded( ) or !catherine.pl:Alive( ) ) then
		return false
	end
end

function PLUGIN:HUDDraw( )
	if ( hook.Run( "ShouldDrawWeaponSelect", catherine.pl ) == false ) then return end
	if ( #self.slotData == 0 ) then return end
	
	local scrW, scrH = ScrW( ), ScrH( )
	local x = scrW * 0.25
	local y = scrH * 0.5 - ( #self.slotData * 30 ) / 2
	
	for k, v in pairs( self.slotData ) do
		if ( v.autoFade <= CurTime( ) ) then
			v.targetA = 0
		end
		
		v.a = Lerp( 0.5, v.a, v.targetA )
		
		if ( math.Round( v.a ) <= 0 ) then continue end
		
		surface.SetFont( "catherine_normal20" )
		
		local tw, th = surface.GetTextSize( v.name )
		
		draw.RoundedBox( 0, x - 5, y - th / 2, tw + 10, th, Color( 50, 50, 50, v.a ) )
		draw.SimpleText( v.name, "catherine_normal20", x, y, Color( 255, 255, 255, v.a ), TEXT_ALIGN_LEFT, 1 )
		
		if ( self.currSlot == k ) then
			local markupObject = v.markupObject
				
			if ( markupObject ) then
				local y2 = ( scrH * 0.5 - ( #self.slotData * 30 ) / 2 ) - 10
				
				surface.SetDrawColor( 50, 50, 50, v.a )
				surface.SetMaterial( gradient_left )
				surface.DrawTexturedRect( self.maxX + 20, y2, 230, markupObject:GetHeight( ) + 10 )
				
				markupObject:Draw( self.maxX + 30, y2 + 5, 0, TEXT_ALIGN_LEFT, v.a )
			end
		end
		
		if ( self.maxX < x + tw ) then
			self.maxX = x + tw
		end
		
		y = y + 30
	end
	
	y = ( scrH * 0.5 - ( #self.slotData * 30 ) / 2 ) - 40
	
	local lastSlot = self.slotData[ #self.slotData ]
	
	draw.RoundedBox( 0, x - 20, y + ( self.currSlot * 30 ), 10, 20, Color( 50, 50, 50, lastSlot.a ) )
end

function PLUGIN:Refresh( pl, id, uniqueID )
	if ( id == 1 ) then
		for k, v in pairs( self.slotData ) do
			if ( v.uniqueID == uniqueID ) then
				return
			end
		end
		
		local wep = pl:GetWeapon( uniqueID )
		
		if ( !IsValid( wep ) ) then return end
		
		local markupText = "<font=catherine_normal20>"
		local markupObject = nil
		local markupFound = false
		
		if ( wep.Instructions and wep.Instructions != "" ) then
			markupText = markupText .. "<color=220,220,220,255>" .. LANG( "Weapon_Instructions_Title" ) .. "</color>\n<font=catherine_normal15>" .. catherine_util_stuffLanguage( wep.Instructions ) .. "</font>\n\n"
			markupFound = true
		end
		
		if ( wep.Author and wep.Author != "" ) then
			markupText = markupText .. "<color=220,220,220,255>" .. LANG( "Weapon_Author_Title" ) .. "</color>\n<font=catherine_normal15>" .. catherine_util_stuffLanguage( wep.Author ) .. "</font>\n\n"
			markupFound = true
		end
		
		if ( wep.Purpose and wep.Purpose != "" ) then
			markupText = markupText .. "<color=220,220,220,255>" .. LANG( "Weapon_Purpose_Title" ) .. "</color>\n<font=catherine_normal15>" .. catherine_util_stuffLanguage( wep.Purpose ) .. "</font>\n\n"
			markupFound = true
		end
		
		if ( markupFound ) then
			markupObject = markup.Parse( markupText .. "</font>", 230 )
		end

		self.slotData[ #self.slotData + 1 ] = {
			name = wep:GetPrintName( ),
			uniqueID = wep:GetClass( ),
			markupObject = markupObject,
			a = 0,
			targetA = 0,
			autoFade = CurTime( ) + 3
		}
	elseif ( id == 2 ) then
		for k, v in pairs( self.slotData ) do
			if ( v.uniqueID == uniqueID ) then
				table.remove( self.slotData, k )
				
				return
			end
		end
	elseif ( id == 3 ) then
		self.currSlot = 1
		self.slotData = { }
	elseif ( id == 4 ) then
		self.currSlot = 1
		self.slotData = { }
		
		for k, v in pairs( pl:GetWeapons( ) ) do
			if ( !IsValid( v ) ) then continue end
			local markupText = "<font=catherine_normal20>"
			local markupObject = nil
			local markupFound = false
			
			if ( v.Instructions and v.Instructions != "" ) then
				markupText = markupText .. "<color=220,220,220,255>" .. LANG( "Weapon_Instructions_Title" ) .. "</color>\n<font=catherine_normal15>" .. catherine_util_stuffLanguage( v.Instructions ) .. "</font>\n\n"
				markupFound = true
			end
			
			if ( v.Author and v.Author != "" ) then
				markupText = markupText .. "<color=220,220,220,255>" .. LANG( "Weapon_Author_Title" ) .. "</color>\n<font=catherine_normal15>" .. catherine_util_stuffLanguage( v.Author ) .. "</font>\n\n"
				markupFound = true
			end
			
			if ( v.Purpose and v.Purpose != "" ) then
				markupText = markupText .. "<color=220,220,220,255>" .. LANG( "Weapon_Purpose_Title" ) .. "</color>\n<font=catherine_normal15>" .. catherine_util_stuffLanguage( v.Purpose ) .. "</font>\n\n"
				markupFound = true
			end
			
			if ( markupFound ) then
				markupObject = markup.Parse( markupText .. "</font>", 230 )
			end

			self.slotData[ #self.slotData + 1 ] = {
				name = v:GetPrintName( ),
				uniqueID = v:GetClass( ),
				markupObject = markupObject,
				a = 0,
				targetA = 0,
				autoFade = CurTime( ) + 3
			}
		end
	end
end

netstream.Hook( "catherine.plugin.weaponselect.Refresh", function( data )
	if ( !IsValid( catherine.pl ) ) then return end
	
	PLUGIN:Refresh( catherine.pl, data[ 1 ], data[ 2 ] )
end )