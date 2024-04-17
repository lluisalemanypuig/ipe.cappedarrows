----------------------------------------------------------------------
-- Draw capped arrows between two points
----------------------------------------------------------------------

--[[
This file is an extension of the drawing editor Ipe (ipe7.sourceforge.net)

Copyright (c) 2020 Lluís Alemany-Puig

This file can be distributed and modified under the terms of the GNU General
Public License as published by the Free Software Foundation; either version
3, or (at your option) any later version.

This file is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
details.

You can find a copy of the GNU General Public License at
"http://www.gnu.org/copyleft/gpl.html", or write to the Free
Software Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
--]]

--[[
You'll find the instruction manual at:

https://github.com/lluisalemanypuig/ipe.cappedarrows
--]]


label = "Capped arrows"

about = [[
Draw a straight arrow between two selected points with a specified radius of separation
]]

function error_dialog(model, error_msg)
	local d = ipeui.Dialog(model.ui:win(), "Capped arrows")
	d:add("label", "label", {label = error_msg}, 1, 1)
	d:addButton("ok", "&Ok", "accept")
	return d
end

function make_dialog(model)
	local d = ipeui.Dialog(model.ui:win(), "Capped arrows")
	d:add("label", "label", {label = "Base"}, 1, 1)
	d:add("label", "label", {label = "Head"}, 2, 1)
	
	d:add("base_dist", "input", {}, 1, 2, 1, 1)
	d:add("head_dist", "input", {}, 2, 2, 1, 1)
	
	d:addButton("ok", "&Ok", "accept")
	d:addButton("cancel", "&Cancel", "reject")
	return d
end

function add_segment(model, p, q, r1, r2)
	print("p:", _G.type(p))
	print("q:", _G.type(q))

	local pq = (q - p):normalized()
	print("pq=", pq)

	local P = p + pq*r1
	local Q = q - pq*r2

	-- prepare binding
	local segment_as_table = {type="segment", P,Q}
	--    this is actually a table that represents a SHAPE
	local segment_as_curve = {type="curve", closed = false, segment_as_table}
	-- make Path object
	local segment = ipe.Path(model.attributes, {segment_as_curve})
	model:creation("Added segment (chord)", segment)
end

function run(model)
	local p = model:page()
	
	if not p:hasSelection() then
		d = error_dialog(model, "No selection")
		d:execute()
		return
	end
	
	local selection = {}
	for i, obj, sel, layer in p:objects() do
		if sel then
			selection[#selection + 1] = i
		end
	end
	
	if #selection ~= 2 then
		d = error_dialog(model, "Select only 2 points")
		d:execute()
		return
	end
	
	local d = make_dialog(model)
	if not d:execute() then
		return
	end
	
	local r1 = d:get("base_dist")
	local r2 = d:get("head_dist")

	for key, value in ipairs(selection) do
		print(key, value)
	end

	local P = p:bbox(selection[1]):topRight()
	local Q = p:bbox(selection[2]):topRight()
	
	add_segment(model, P, Q, r1, r2)
	
	model.ui:update()
end
