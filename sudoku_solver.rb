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

File.open('puzzle.sudoku').each_line{ |s|
  puts s
}
