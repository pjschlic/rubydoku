puzzle = []
# initialize puzzle data structure
# all values are 0x1 f f -> the potential values they can be
# 1-9 each represented by a bit
(1..9).each do |row|
	row = []
	puzzle << row
	(1..9).each do |col|
		row << 0x1ff
		puts row.length
	end
end


# print the puzzle's status stuff
def print_puzz(puzz)
	puzz.each do |row|
		row.each do |tile|
			print tile
		end
		puts ""
	end
end

# this value is illegal for all other items in this row
def set_row(puz, x, y, val)
	(0..8).each do |cur_x|
		puz[y][cur_x] = puz[y][cur_x]&(~val) unless cur_x == x
		if puz[y][cur_x] == 0
			puts "ERROR!!!! ILLEGAL BOARD"
		end
	end
end

# this value is illegal for all other items in this col
def set_col(puz, x, y, val)
	(0..8).each do |cur_y|
		puz[cur_y][x] = puz[cur_y][x]&(~val) unless cur_y == y
		if puz[cur_y][x] == 0
			puts "ERROR!!!! ILLEGAL BOARD"
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
				puts "ERROR!!!! ILLEGAL BOARD"
			end
		end
	end
end

y = 0
File.open('puzzle.sudoku').each_line do |s|
  puts s
	x = 0
	s.split(" ").each do |c|
		n = c.to_i
		if n > 0 && n < 10
			puts "#{n} at (#{x},#{y})"
			val = 1 << (n-1)
			set_row(puzzle,x,y,val)
			set_col(puzzle,x,y,val)
			set_section(puzzle,x,y,val)
		end
		x = x + 1
	end
	y = y + 1
end

print_puzz(puzzle)
