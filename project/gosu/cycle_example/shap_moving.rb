require 'gosu'

module ZOrder
  BACKGROUND, MIDDLE, TOP = *0..2
end

WIDTH = 400
HEIGHT = 500
SHAPE_DIM = 50

# Instructions:
# Fix the following code so that:
# 1. The shape also can be moved up and down
# 2. the shape does not move out of the window area

class GameWindow < Gosu::Window

  # initialize creates a window with a width an a height
  # and a caption. It also sets up any variables to be used.
  # This is procedure i.e the return value is 'undefined'
  def initialize
    super(WIDTH, HEIGHT, false)
    self.caption = "Shape Moving"

    @shape_y = HEIGHT / 2
    @shape_x = WIDTH / 2
    @img = Gosu::Image.new("./media/ufo.png")
    @locs = []
  end

  def button_down(id)
    case id
        when Gosu::MsLeft
            if (mouse_x < (WIDTH - SHAPE_DIM)) && mouse_y < (HEIGHT - SHAPE_DIM)
                @shape_x = mouse_x
                @shape_y = mouse_y
            end
        end
  end

  # Put any work you want done in update
  # This is a procedure i.e the return value is 'undefined'
  def update

    if button_down?(Gosu::KbRight) && (@shape_x < (WIDTH - SHAPE_DIM))
        @shape_x += 4
    end

    if button_down?(Gosu::KbLeft) && (@shape_x > 0)
        @shape_x -= 4
    end

    if button_down?(Gosu::KbUp) && (@shape_y > 0)
        @shape_y -= 4
    end

    if button_down?(Gosu::KbDown) && (@shape_y < (HEIGHT - SHAPE_DIM))
        @shape_y += 4
    end

  end

  # Draw (or Redraw) the window
  # This is procedure i.e the return value is 'undefined'
  def draw
    @img.draw(@shape_x, @shape_y, ZOrder::TOP)
  end
end

window = GameWindow.new
window.show
