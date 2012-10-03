#!/usr/bin/env ruby

puzzle = []
# initialize puzzle data structure
# all values are 0x1 f f -> the potential values they can be
# 1-9 each represented by a bit
(1..9).each do |row|
	row = []
	puzzle << row
	(1..9).each do |col|
		row << 0x1ff
	end
	puts "new row of #{row.length}"
end
puts "total of #{puzzle.length} rows"

def panic(p)
	p.each do |r|
		r.each do |c|
			print "#{c} "
		end
		puts ""
	end
	exit
end

# print the puzzle's status stuff
def print_puzz(puzz)
	puzz.each do |row|
		row.each do |tile|
			print "#{Math.log2(tile).to_i + 1} "
		end
		puts ""
	end
end

# If the puzzle is UNDER specified, start to choose some random valid values
def solve_under_specified_puzz(puzz)
	puts "under-specified puzzle?"
	puzz.each_index do |y|
		row = puzz[y]
		row.each_index do |x|
			val = Math.log2(puzz[y][x])
			if val > 0 && val < 9 && val != val.ceil
				# find highest allowable value
				puts "Putting #{val.floor.to_i + 1} (allow #{puzz[y][x]}) at (#{x},#{y})"
				place_val(puzz,x,y,(1<<(val.floor.to_i)))
			end
		end
	end
end

# this value is illegal for all other items in this row
def set_row(puz, x, y, val)
	(0..8).each do |cur_x|
		if cur_x != x
			old = puz[y][cur_x]
			new = old&(~val)
			if new != puz[y][cur_x] # if new assignment
				if new == 0
					puts "ERROR!!!! ILLEGAL BOARD syncing row at #{cur_x},#{y} | was #{old}"
					panic(puz)
				else
					if Math.log2(new).floor == Math.log2(new) # if found final value, propagate
						puts "propogate #{new} at (#{cur_x},#{y})"
						place_val(puz,cur_x,y,new)
					else
						puz[y][cur_x] = new
					end
				end
			end
		end
	end
end

# this value is illegal for all other items in this col
def set_col(puz, x, y, val)
	(0..8).each do |cur_y|
		if cur_y != y
			old = puz[cur_y][x]
			new = puz[cur_y][x]&(~val)
			if new != puz[cur_y][x]
				if new == 0
					puts "ERROR!!!! ILLEGAL BOARD syncing column at #{x},#{cur_y} | was #{old}"
					panic(puz)
				else
					if Math.log2(new).floor == Math.log2(new)
						puts "propogate #{new} at (#{x},#{cur_y})"
						place_val(puz,x,cur_y,new)
					else
						puz[cur_y][x] = new
					end
				end
			end
		end
	end
end

# this value is illegal for all other items in this (super group?) 3x3 grid-area
def set_section(puz, x, y, val)
	top_left_x = x-(x%3)
	top_left_y = y-(y%3)
	(0..2).each do |offset_x|
		(0..2).each do |offset_y|
			cur_x = top_left_x + offset_x
			cur_y = top_left_y + offset_y
			if cur_x != x && cur_y != y
				new = puz[cur_y][cur_x]&(~val)
				if new != puz[cur_y][cur_x]
					if new == 0
						puts "ERROR!!!! ILLEGAL BOARD syncing block at #{cur_x},#{cur_y}"
						panic(puz)
					else
						if Math.log2(new).floor == Math.log2(new)
							puts "propogate #{new} at (#{cur_x},#{cur_y})"
							place_val(puz,cur_x,cur_y,new)
						else
							puz[cur_y][cur_x] = new
						end
					end
				end
			end
		end
	end
end

# take care of all logic to place a value at a place
def place_val(puz,x,y,val)
	if puz[y][x]&val == 0
		puts "ERROR INVALID PUZZLE: #{val} being placed at (#{x},#{y}) which is #{puz[y][x]}"
		panic(puzzle)
	end
	if puz[y][x] != val
		puz[y][x] = val
		set_row(puz,x,y,val)
		set_col(puz,x,y,val)
		set_section(puz,x,y,val)
	end
end

y = 0
File.open('puzzle.sudoku').each_line do |s|
	puts s
	x = 0
	s.split(" ").each do |c|
		n = c.to_i
		puts "#{n} at #{x},#{y}"
		if n > 0 && n < 10
			val = 1 << (n-1)
			puts "#{n} at (#{x},#{y}) => #{val}"
			place_val(puzzle,x,y,val)
		end
		x = x + 1
	end
	y = y + 1
end

solve_under_specified_puzz(puzzle)
print_puzz(puzzle)

