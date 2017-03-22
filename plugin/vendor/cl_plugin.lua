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

netstream.Hook( "catherine.plugin.vendor.RefreshRequest", function( data )
	if ( IsValid( catherine.vgui.vendor ) ) then
		catherine.vgui.vendor:InitializeVendor( Entity( data ) )
		catherine.vgui.vendor:ChangeMode( catherine.vgui.vendor.currMenu )
	end
end )

netstream.Hook( "catherine.plugin.vendor.VendorUse", function( data )
	if ( IsValid( catherine.vgui.vendor ) ) then
		catherine.vgui.vendor:Remove( )
		catherine.vgui.vendor = nil
	end
	
	catherine.vgui.vendor = vgui.Create( "catherine.vgui.vendor" )
	catherine.vgui.vendor:InitializeVendor( Entity( data ) )
end )