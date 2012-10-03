#!/usr/bin/env ruby


class Tile
  attr_reader :value, :value_mask, :x, :y
  def initialize
    # initialize puzzle data structure
    # all values are 0x1 f f -> the potential values they can be
    # 1-9 each represented by a bit
    @value_mask = 0x1ff
  end
  def valid?
    neighbors do |neighbor|
      if neighbor.value == @value
        return false
      end
    end
    return true
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
      raise
    end
    if value != @value
      puts "placing value #{value} at #{@x},#{@y}"
      @value=value
      self.mask(0x0)
      neighbors do |neighbor|
        neighbor.mask(~(1 << (@value-1)))
      end
      # mask_constraints(~(1 << (@value-1)))
    end
  end
  def neighbors
    yield_row {|tile| yield(tile)}
    yield_col {|tile| yield(tile)}
    yield_section {|tile| yield(tile)}
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
        raise
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
    cost = 0
    cur_mask = @value_mask
    while cur_mask > 0 # count my options
      cur_mask = cur_mask >> 1
      cost = cost+1
    end
    neighbors do |neighbor| # count the options my neighbors would lose if I become this
      if (1 << (val-1)) & neighbor.value_mask > 0
        cost = cost + 1
      end
    end
    return cost
  end

  # this value is illegal for all other items in this row
  def yield_row
    (0..8).each do |cur_x|
      if cur_x != @x
        cur_tile = @puzzle[@y][cur_x]
        yield(cur_tile)
      end
    end
  end

  # this value is illegal for all other items in this (super group?) 3x3 grid-area
  def yield_section
    top_left_x = @x-(@x%3)
    top_left_y = @y-(@y%3)
    (0..2).each do |offset_x|
      (0..2).each do |offset_y|
        cur_x = top_left_x + offset_x
        cur_y = top_left_y + offset_y
        if cur_x != @x && cur_y != @y # already got row/col/self
          cur_tile = @puzzle[cur_y][cur_x]
          yield(cur_tile)
        end
      end
    end
  end

  # this value is illegal for all other items in this col
  def yield_col
    (0..8).each do |cur_y|
      if cur_y != @y
        cur_tile = @puzzle[cur_y][@x]
        yield(cur_tile)
      end
    end
  end

  def copy(new_puzzle)
    t = Tile.new
    t.set(new_puzzle,@x,@y)
    t.set_value(@value)
    t.set_mask(@value_mask)
    t
  end
  # create some methods for copy which don't do propogation/etc
  def set_value(v)
    @value = v
  end
  def set_mask(mask)
    @value_mask = mask
  end
end


def panic(p)
  puts "panic!"
  print_puzz(p)
  success = true
  p.each do |row|
    row.each do |tile|
      success = success && tile.valid?
    end
  end
  if success
    puts "success!!!!"
  else
    puts "error!!!!!"
  end
  exit
end

def success(p)
  puts "success"
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
  candidate_values = [] # pairs: [tile,value,cost]
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
          candidate_values << [tile,cur_val,cur_cost]
          # puts "cost of #{cur_val} => (#{tile.x},#{tile.y}) is #{cur_cost}"
        end
        cur_val = cur_val+1
        cur_mask = cur_mask >> 1
      end
    end
  end
  # puts candidate_values.inspect
  if candidate_values.length == 0
    success(puzz)
  else
    while candidate_values.length > 0 do
      # puts "choose a good candidate to set the value on"
      candidate_values.sort! {|one,two| one[2] <=> two[2] }
      # puts candidate_values.inspect
      next_puz = copy_puzz(puzz)
      chosen = candidate_values.shift
      begin
        next_puz[chosen.y][chosen.x].value = chosen[1]
        solve(next_puzz)
      rescue
        puts "learned that #{chosen[1]} does NOT go at #{chosen[0].x},#{chosen[0].y}"
        puzz[chosen[0].y][chosen[0].x].mask(~(1<<(chosen[1]-1)))
      end
    end
  end
  panic(puzz)
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
      begin
        puzzle[y][x].value = n
      rescue
        panic(puzzle)
      end
    end
    x = x + 1
  end
  y = y + 1
end

solve(puzzle)

