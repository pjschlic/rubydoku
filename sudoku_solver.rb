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
			print "#{Math.log2(tile)} "
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
		puz[y][cur_x] = puz[y][cur_x]&(~val) unless cur_x == x
		if puz[y][cur_x] == 0
			puts "ERROR!!!! ILLEGAL BOARD syncing row at #{cur_x},#{y}"
			panic(puz)
		end
	end
end

# this value is illegal for all other items in this col
def set_col(puz, x, y, val)
	(0..8).each do |cur_y|
		puz[cur_y][x] = puz[cur_y][x]&(~val) unless cur_y == y
		if puz[cur_y][x] == 0
			puts "ERROR!!!! ILLEGAL BOARD syncing column at #{x},#{cur_y}"
			panic(puz)
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
			puz[cur_y][cur_x] = puz[cur_y][cur_x]&(~val) unless (cur_y == y && cur_x == x)
			if puz[cur_y][cur_x] == 0
				puts "ERROR!!!! ILLEGAL BOARD syncing block at #{cur_x},#{cur_y}"
				panic(puz)
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
	puz[y][x] = val
	set_row(puz,x,y,val)
	set_col(puz,x,y,val)
	set_section(puz,x,y,val)
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

print_puzz(puzzle)

solve_under_specified_puzz(puzzle)


print_puzz(puzzle)
