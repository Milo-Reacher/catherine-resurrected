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

catherine.effect = catherine.effect or { }
catherine.effect.lists = { }

function catherine.effect.Create( uniqueID, dataTable )
	local func = catherine.effect.lists[ uniqueID ]
	
	if ( func ) then
		func( dataTable )
	end
end

function catherine.effect.Register( uniqueID, func )
	catherine.effect.lists[ uniqueID ] = func
end

catherine.effect.Register( "BLOOD", function( dataTable )
	local ent = dataTable.ent
	
	if ( ( ent.CAT_nextBloodEffect or CurTime( ) ) <= CurTime( ) ) then
		local pos = dataTable.pos
		
		local eff = EffectData( )
		eff:SetOrigin( pos )
		eff:SetEntity( ent)
		eff:SetStart( pos )
		eff:SetScale( dataTable.scale or 0.5 )
		util.Effect( "BloodImpact", eff, true, true )
		
		for i = 1, dataTable.decalCount do
			local tr = util.TraceLine( {
				start = pos,
				endpos = pos,
				filter = ent
			} )
			
			util.Decal( "Blood", tr.HitPos + tr.HitNormal, tr.HitPos - tr.HitNormal )
		end
		
		ent.CAT_nextBloodEffect = CurTime( ) + 0.7
	end
end )