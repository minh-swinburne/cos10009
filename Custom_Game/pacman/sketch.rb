class Pacman
    attr_accessor :position
  
    def initialize
      @position = [0, 0]
    end
  
    def move(direction, grid)
      case direction
      when 'up'
        @position[1] += 1 if @position[1] grid.length - 1
      when 'down'
        @position[1] -= 1 if @position[1] > 0
      when 'left'
        @position[0] -= 1 if @position[0] > 0
      when 'right'
        @position[0] += 1 if @position[0] < grid[0].length - 1
      end
    end
  end
  
  class Game
   initialize
      @pacman = Pacman.new
      @grid = Array.new(5) { Array.new(5, '.') }
    end
  
    def start
      loop do
        print_grid
        puts "Enter a direction for Pacman to move (up, down, left, right):"
        direction = gets.chomp
        @pacman.move(direction, @grid)
      end
    end
  
    def print_grid
      @grid.each_with_index do |row, i|
        row.each_with_index do |cell, j|
          if @pacman.position == [j, i]
            print 'P '
          else
            print '. '
          end
        end
        puts
      end
    end
  end
  
  game = Game.new
  game.start
  