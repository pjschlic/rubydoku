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



puzzle.each do |row|
	row.each do |tile|
		print tile
	end
	puts ""
end

def set_row(puz, x, y, val)
end

y = 0
File.open('puzzle.sudoku').each_line do |s|
  puts s
	x = 0
	s.split(" ").each do |c|
		n = c.to_i
		if n > 0 && n < 10
			puts "#{n} at (#{x},#{y})"
			val = 1 << n
			set_row(puzzle,x,y,val)
		end
		x = x + 1
	end
	y = y + 1
end
