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

catherine.cash = catherine.cash or { singular = "Dollar", plural = "Dollars" }

function catherine.cash.GetOnlySingular( )
	return catherine.cash.singular
end

function catherine.cash.GetOnlyPlural( )
	return catherine.cash.plural
end

function catherine.cash.GetName( )
	return catherine.cash.singular, catherine.cash.plural
end

function catherine.cash.SetName( singular, plural )
	catherine.cash.singular = singular
	catherine.cash.plural = plural
end

function catherine.cash.GetCompleteName( amount )
	return amount .. " " .. ( amount > 1 and catherine.cash.plural or catherine.cash.singular )
end

function catherine.cash.Has( pl, amount )
	if ( amount < 0 ) then
		return false
	end
	
	return catherine.cash.Get( pl ) >= amount
end

function catherine.cash.Get( pl )
	return tonumber( catherine.character.GetVar( pl, "_cash", 0 ) )
end

if ( SERVER ) then
	function catherine.cash.Set( pl, amount )
		amount = tonumber( amount )
		
		if ( !amount ) then return false end
		
		catherine.character.SetVar( pl, "_cash", math.max( amount, 0 ) )
		
		return true
	end
	
	function catherine.cash.Give( pl, amount )
		amount = tonumber( amount )
		
		if ( !amount ) then return false end
		
		catherine.character.SetVar( pl, "_cash", math.max( catherine.cash.Get( pl ) + amount, 0 ) )
		
		return true
	end

	function catherine.cash.Take( pl, amount )
		amount = tonumber( amount )
		
		if ( !amount ) then return false end
		
		catherine.character.SetVar( pl, "_cash", math.max( catherine.cash.Get( pl ) - amount, 0 ) )
		
		return true
	end
	
	function catherine.cash.Spawn( pos, ang, amount )
		amount = tonumber( amount )
		
		if ( !amount or amount <= 0 ) then return false end
		
		catherine.item.Spawn( "wallet", pos, ang, { amount = amount } )
	end
end