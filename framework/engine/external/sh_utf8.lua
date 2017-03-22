--[[
	GLib UTF-8 Library
	https://github.com/notcake/glib/blob/master/lua/glib/unicode/utf8.lua
]]--

local math_floor    = math.floor
local string_byte   = string.byte
local string_char   = string.char
local string_len    = string.len
local string_lower  = string.lower
local string_find   = string.find
local string_format = string.format
local string_gsub   = string.gsub
local string_sub    = string.sub
local string_upper  = string.upper
local table_concat  = table.concat

local function utf8bytes(char, offset)
	if char == "" then return -1 end
	offset = offset or 1
	
	local byte = string_byte (char, offset)
	local length = 1
	if byte >= 128 then
		-- multi-byte sequence
		if byte >= 240 then
			-- 4 byte sequence
			length = 4
			if #char < 4 then return -1, length end
			byte = (byte % 8) * 262144
			byte = byte + (string_byte (char, offset + 1) % 64) * 4096
			byte = byte + (string_byte (char, offset + 2) % 64) * 64
			byte = byte + (string_byte (char, offset + 3) % 64)
		elseif byte >= 224 then
			-- 3 byte sequence
			length = 3
			if #char < 3 then return -1, length end
			byte = (byte % 16) * 4096
			byte = byte + (string_byte (char, offset + 1) % 64) * 64
			byte = byte + (string_byte (char, offset + 2) % 64)
		elseif byte >= 192 then
			-- 2 byte sequence
			length = 2
			if #char < 2 then return -1, length end
			byte = (byte % 32) * 64
			byte = byte + (string_byte (char, offset + 1) % 64)
		else
			-- this is a continuation byte
			-- invalid sequence
			byte = -1
		end
	else
		-- single byte sequence
	end
	return byte, length
end

local function utf8char(byte)
	local utf8 = ""
	if byte < 0 then
		utf8 = ""
	elseif byte <= 127 then
		utf8 = string_char (byte)
	elseif byte < 2048 then
		utf8 = string_format ("%c%c",     192 + math_floor (byte / 64),     128 + (byte % 64))
	elseif byte < 65536 then
		utf8 = string_format ("%c%c%c",   224 + math_floor (byte / 4096),   128 + (math_floor (byte / 64) % 64),   128 + (byte % 64))
	elseif byte < 2097152 then
		utf8 = string_format ("%c%c%c%c", 240 + math_floor (byte / 262144), 128 + (math_floor (byte / 4096) % 64), 128 + (math_floor (byte / 64) % 64), 128 + (byte % 64))
	end
	return utf8
end

local function utf8len(str)
	local _, length = string_gsub (str, "[^\128-\191]", "")
	return length
end

local function iterator(str, offset)
	offset = offset or 1
	if offset <= 0 then offset = 1 end
	
	return function ()
			if offset > #str then return nil, #str + 1 end
			
			-- Inline expansion of GLib.UTF8.SequenceLength (str, offset)
			local length
			local byte = string_byte (str, offset)
			if not byte then length = 0
			elseif byte >= 240 then length = 4
			elseif byte >= 224 then length = 3
			elseif byte >= 192 then length = 2
			else length = 1 end
			
			local character = string_sub (str, offset, offset + length - 1)
			local lastOffset = offset
			offset = offset + length
			return character, lastOffset
	end
end

local function utf8sub(str, offset, startCharacter, endCharacter)
	if not str then return "" end
	
	if offset < 1 then offset = 1 end
	local charactersSkipped = offset - 1
	
	if startCharacter > #str - charactersSkipped then return "" end
	if endCharacter then
		if endCharacter < startCharacter then return "" end
		if endCharacter > #str - charactersSkipped then endCharacter = nil end
	end

	local iterator = iterator(str, offset)
	
	local nextCharacter = 1
	while nextCharacter < startCharacter do
		iterator ()
		nextCharacter = nextCharacter + 1
	end
	
	local _, startOffset = iterator ()
	if not startOffset then return "" end
	nextCharacter = nextCharacter + 1
	if not endCharacter then
		return string_sub (str, startOffset)
	end
	
	while nextCharacter <= endCharacter do
		iterator ()
		nextCharacter = nextCharacter + 1
	end
	
	local _, endOffset = iterator ()
	if endOffset then
		return string_sub (str, startOffset, endOffset - 1)
	else
		return string_sub (str, startOffset)
	end
end

if !string.utf8bytes then
	string.utf8bytes = utf8bytes
end

if !string.utf8char then
	string.utf8char = utf8char
end

if !string.utf8len then
	string.utf8len = utf8len
end

if !string.utf8len then
	string.utf8len = utf8len
end

if !string.utf8sub then
	string.utf8sub = function(str, startCharacter, endCharacter)
		return utf8sub(str, 1, startCharacter, endCharacter)
	end
end