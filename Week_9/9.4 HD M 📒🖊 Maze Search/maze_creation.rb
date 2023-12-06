require 'gosu'

module ZOrder
  BACKGROUND, MIDDLE, TOP = *0..2
end

MAP_WIDTH = 200
MAP_HEIGHT = 200
CELL_DIM = 20

class Cell
  # have a pointer to the neighbouring cells
  attr_accessor :north, :south, :east, :west, :vacant, :visited, :on_path

  def initialize()
    # Set the pointers to nil
    @north = nil
    @south = nil
    @east = nil
    @west = nil
    # record whether this cell is vacant
    # default is not vacant i.e is a wall.
    @vacant = false
    # this stops cycles - set when you travel through a cell
    @visited = false
    @on_path = false
  end
end

# Instructions:
# Left click on cells to create a maze with at least one path moving from left to right.  The right click on a cell for the program to find a path through the maze. When a path is found it will be displayed in red.
class GameWindow < Gosu::Window

  # initialize creates a window with a width and a height
  # and a caption. It also sets up any variables to be used.
  # This is procedure i.e the return value is 'undefined'
  def initialize
    super MAP_WIDTH, MAP_HEIGHT, false
    self.caption = "Maze Creation"
    @path = nil
    @path_found = false

    x_cell_count = MAP_WIDTH / CELL_DIM
    y_cell_count = MAP_HEIGHT / CELL_DIM

    @columns = Array.new(x_cell_count)
    column_index = 0

    # first create cells for each position
    while (column_index < x_cell_count)
      row = Array.new(y_cell_count)
      @columns[column_index] = row
      row_index = 0
      while (row_index < y_cell_count)
        cell = Cell.new()
        @columns[column_index][row_index] = cell
        row_index += 1
      end
      column_index += 1
    end

    # now set up the neighbour links
    # You need to do this using a while loop with another
    # nested while loop inside.
    # We carries this out with each column.
    column_index = 0

    while (column_index < x_cell_count)
      row_index = 0
      while (row_index < y_cell_count)
        cell = @columns[column_index][row_index]
        # the pointers of each cell are nil by default, so we just need to change where needed
        unless row_index == 0 # set up the cells on the upward side except the first cell of the column
          cell.north = @columns[column_index][row_index - 1]
        end
        unless row_index == (y_cell_count - 1) # set up the cells on the downward side except the last cell of the column
          cell.south = @columns[column_index][row_index + 1]
        end
        unless column_index == 0 # set up the cells on the left side except the first column
          cell.west = @columns[column_index - 1][row_index]
        end
        unless column_index == (x_cell_count - 1) # set up the cells on the right side except the last column
          cell.east = @columns[column_index + 1][row_index]
        end
        # print out the state of neighbour of each column of cells
        # The .nil? method return a boolean value: true when the variable is nil and false when it has some value
        # '? 0 : 1' is a type of operator in ruby called ternary operator. It checks the boolean value in front, returns 0 if true and 1 if false.
        puts("Cell x: #{column_index}, y: #{row_index} north:#{cell.north.nil? ? 0 : 1} south: #{cell.south.nil? ? 0 : 1} east: #{cell.east.nil? ? 0 : 1} west: #{cell.west.nil? ? 0 : 1}")
        row_index += 1
      end
      puts('------------ End of Column -------------')
      column_index += 1
    end

  end

  # this is called by Gosu to see if should show the cursor (or mouse)
  def needs_cursor?
    true
  end

  # Returns an array of the cell x and y coordinates that were clicked on
  def mouse_over_cell(mouse_x, mouse_y)
    if mouse_x <= CELL_DIM
      cell_x = 0
    else
      cell_x = (mouse_x / CELL_DIM).to_i
    end

    if mouse_y <= CELL_DIM
      cell_y = 0
    else
      cell_y = (mouse_y / CELL_DIM).to_i
    end
    return [cell_x, cell_y]
  end

  # start a recursive search for paths from the selected cell
  # it searches till it hits the East 'wall' then stops
  # it does not necessarily find the shortest path

  # Completing this function is NOT NECESSARY for the Maze Creation task
  # complete the following for the Maze Search task - after
  # we cover Recusion in the lectures.

  # But you DO need to complete it later for the Maze Search task
  def search(cell_x, cell_y)

    if (cell_x == ((MAP_WIDTH / CELL_DIM) - 1))
      if (ARGV.length > 0) # debug
        puts "End of one path x: " + cell_x.to_s + " y: " + cell_y.to_s
      end
      @path_found = true
      return [[cell_x, cell_y]]  # We are at the east wall - exit
    else
    

      if (ARGV.length > 0) # debug
        puts "Searching. In cell x: " + cell_x.to_s + " y: " + cell_y.to_s
      end

      # INSERT MISSING CODE HERE!! You need to have 4 'if' tests to
      # check each surrounding cell. Make use of the attributes for
      # cells such as vacant, visited and on_path.
      # Cells on the outer boundaries will always have a nil on the
      # boundary side

      # Priority order: east > south > north > west
      neighbours = [[cell_x+1,cell_y], [cell_x,cell_y+1], [cell_x,cell_y-1], [cell_x-1,cell_y]]
      index = 0
      path = nil

      # pick one of the possible paths that is not nil (if any):
      while path == nil and index < neighbours.length
        x = neighbours[index][0]
        y = neighbours[index][1]
        cell = @columns[x][y]
        if cell and cell.vacant and !cell.visited
          cell.visited = true
          path = search(x, y)
        end
        index += 1
      end
      
      # Alternative solution:

      # cell = @columns[cell_x][cell_y]
      # north_path = cell.north
      # west_path = cell.west
      # east_path = cell.east
      # south_path = cell.south
      
      # x = cell_x
      # y = cell_y

      # if east_path && east_path.vacant && !east_path.visited
      #   path = east_path
      #   path_found = true
      #   path.visited = true
      #   path = search(x + 1, y)
      # end

      # if path == nil && south_path && south_path.vacant && !south_path.visited
      #   path = south_path
      #   path_found = true
      #   path.visited = true
      #   path = search(x, y + 1)
      # end
      
      # if path == nil && north_path && north_path.vacant && !north_path.visited
      #   path = north_path
      #   path_found = true
      #   path.visited = true
      #   path = search(x, y - 1)
      # end

      # if path == nil && west_path && west_path.vacant && !west_path.visited
      #   path = west_path
      #   path_found = true
      #   path.visited = true
      #   path = search(x - 1, y)
      # end

      # A path was found:
      if (path != nil)
        if (ARGV.length > 0) # debug
          puts "Added x: " + cell_x.to_s + " y: " + cell_y.to_s
        end
        return [[cell_x,cell_y]].concat(path)
      else
        if (ARGV.length > 0) # debug
          puts "Dead end x: " + cell_x.to_s + " y: " + cell_y.to_s
        end
        return nil  # dead end
      end
    end
  end

  # Reacts to button press
  # left button marks a cell vacant
  # Right button starts a path search from the clicked cell
  def button_down(id)
    case id
      when Gosu::MsLeft
        cell = mouse_over_cell(mouse_x, mouse_y)
        if (ARGV.length > 0) # debug
          puts("Cell clicked on is x: " + cell[0].to_s + " y: " + cell[1].to_s)
        end
        @columns[cell[0]][cell[1]].vacant = true
      when Gosu::MsRight
        cell = mouse_over_cell(mouse_x, mouse_y)
        @path = search(cell[0], cell[1])
      end
  end

  # This will walk along the path setting the on_path for each cell
  # to true. Then draw checks this and displays them a red colour.
  def walk(path)
      index = path.length
      count = 0
      while (count < index)
        cell = path[count]
        @columns[cell[0]][cell[1]].on_path = true
        count += 1
      end
  end

  # Put any work you want done in update
  # This is a procedure i.e the return value is 'undefined'
  def update
    if (@path != nil)
      if (ARGV.length > 0) # debug
        puts "Displaying path"
        puts @path.to_s
      end
      walk(@path)
      @path = nil
    end
    if !@path_found     # reset a failed search (no valid path)
      @columns.each do |column|
        column.each do |cell|
          cell.visited = false
        end
      end
    end
  end

  # Draw (or Redraw) the window
  # This is procedure i.e the return value is 'undefined'
  def draw

    x_cell_count = MAP_WIDTH / CELL_DIM
    y_cell_count = MAP_HEIGHT / CELL_DIM

    column_index = 0
    while (column_index < x_cell_count)
      row_index = 0
      while (row_index < y_cell_count)

        if (@columns[column_index][row_index].vacant)
          color = Gosu::Color::YELLOW
        else
          color = Gosu::Color::GREEN
        end
        if (@columns[column_index][row_index].on_path)
          color = Gosu::Color::RED
        end

        Gosu.draw_rect(column_index * CELL_DIM, row_index * CELL_DIM, CELL_DIM, CELL_DIM, color, ZOrder::TOP, mode=:default)

        row_index += 1
      end
      column_index += 1
    end
  end
end

window = GameWindow.new
window.show