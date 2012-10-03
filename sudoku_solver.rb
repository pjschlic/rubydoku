#!/usr/bin/env ruby


class Tile
  attr_reader :value, :value_mask, :x, :y
  def initialize
    # initialize puzzle data structure
    # all values are 0x1 f f -> the potential values they can be
    # 1-9 each represented by a bit
    @value_mask = 0x1ff
  end
  def set(puzzle,x,y)
    @puzzle=puzzle
    @x=x
    @y=y
  end
  def value=(value)
    # propogate the value
    if @value&value == 0
      puts "ERROR INVALID PUZZLE: #{value} being set at (#{@x},#{@y}) which is #{@value} with mask #{@value_mask}"
      panic(@puzzle)
    end
    if value != @value
      puts "placing value #{value} at #{@x},#{@y}"
      @value=value
      self.mask(0x0)
      mask_constraints(~(1 << (@value-1)))
    end
  end
  def mask(mask)
    if @value_mask == 0
      return
    end
    if mask == 0
      # our value was found, we are icing our old mask
      @value_mask = 0
    else
      new_mask = @value_mask & mask
      if @value_mask == 0
        puts "ERROR INVALID PUZZLE: 0x#{mask.to_s(16)} being applied at (#{@x},#{@y}) which is #{@value_mask}"
        panic(@puzzle)
      end
      if new_mask != @value_mask
        @value_mask = new_mask
        if Math.log2(@value_mask).floor == Math.log2(@value_mask) # if only one value is set
          puts "new value found through mask #{Math.log2(@value_mask).to_i+1} at #{@x},#{@y}"
          self.value = Math.log2(@value_mask).to_i+1
        end
      end
    end
  end

  def cost_to_place(val)
    row_cost(val)
    col_cost(val)
    section_cot(val)
  end

  # take care of all logic to place a value at a place
  def mask_constraints(mask)
    puts "masking constraints #{mask.to_s(16)}"
    mask_row(mask)
    mask_col(mask)
    mask_section(mask)
  end

  # this value is illegal for all other items in this row
  def mask_row(mask)
    (0..8).each do |cur_x|
      if cur_x != @x
        cur_tile = @puzzle[@y][cur_x]
        cur_tile.mask(mask)
      end
    end
  end

  # this value is illegal for all other items in this (super group?) 3x3 grid-area
  def mask_section(mask)
    top_left_x = @x-(@x%3)
    top_left_y = @y-(@y%3)
    (0..2).each do |offset_x|
      (0..2).each do |offset_y|
        cur_x = top_left_x + offset_x
        cur_y = top_left_y + offset_y
        if cur_x != @x && cur_y != @y
          cur_tile = @puzzle[cur_y][cur_x]
          cur_tile.mask(mask)
        end
      end
    end
  end

  # this value is illegal for all other items in this col
  def mask_col(mask)
    (0..8).each do |cur_y|
      if cur_y != @y
        cur_tile = @puzzle[cur_y][@x]
        cur_tile.mask(mask)
      end
    end
  end

  def copy(new_puzzle)
    t = Tile.new
    t.set(new_puzzle,@x,@y)
    t.value = self.value
    t.mask(self.value_mask)
    t
  end
end


def panic(p)
  puts "panic!"
  print_puzz(p)
  exit
end

# copy all values of "from" to "to"
def copy_puzz(from)
  to = []
  from.each do |row|
    new_row = []
    to << new_row
    row.each do |tile|
      new_row << tile.copy(to)
    end
  end
  to
end

# print the puzzle's status stuff
def print_puzz(puzz)
  puzz.each do |row|
    row.each do |tile|
      print "#{(!tile.value.nil? && tile.value > 0) ? tile.value : '.'} "
    end
    puts ""
  end
end

# we need to choose a value to "set" - we need to remember it and DFS our way through t puzzle
# We prefer placing values which:
# 1. Get us closer to the solution
#   solved bt doing DFS
# 2. Have the most constraints on them
#   prefer to place numbers in tiles with very few potential values
# 3. Prefer to choose values which constrain others least
# 
# on preference, we'll count the number of constraints placing a particular value would cause and choose lowest value
def solve(puzz)
  puts "choose a good candidate to set the value on"
  candidate_values = [] # pairs: [value,cost]
  stack = [] # stack of tile states to solve from
  # examine candidates
  puzz.each_index do |y|
    row = puzz[y]
    row.each_index do |x|
      tile = puzz[y][x]
      cur_mask = tile.value_mask
      cur_val = 1
      while cur_mask > 0 do
        if cur_val & 1 > 0
          cur_cost = tile.cost_to_place(cur_val)
          candidate_values << [cur_val, cur_cost]
        end
        cur_val = cur_val+1
        cur_mask = cur_mask >> 1
      end
    end
  end
end


#Array.new(9,Array.new(9,Tile.new))
puzzle = []
(0..8).each do |y|
  row = []
  puzzle << row
  (0..8).each do |x|
    row << Tile.new
  end
end
(0..8).each do |y|
  (0..8).each do |x|
    puzzle[y][x].set(puzzle,x,y) # set this tile's location in the grand scheme of things
  end
  puts "row of length #{puzzle[y].length}"
end
puts "total of #{puzzle.length} rows"
print_puzz(puzzle)
y = 0
puts "starting puzzle:"
File.open('puzzle.sudoku').each_line do |s|
  puts s
  x = 0
  s.split(" ").each do |c|
    t=puzzle[y][x]
    n = c.to_i
    puts "#{n} at #{x},#{y}"
    if n > 0 && n < 10
      puts "#{n} at (#{x},#{y}) => #{n}"
      puzzle[y][x].value = n
    end
    x = x + 1
  end
  y = y + 1
end

solve(puzzle)
print_puzz(puzzle)

