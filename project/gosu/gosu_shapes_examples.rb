require 'rubygems'
require 'gosu'
require './circle'
require './input_functions'
require './bezier_curve'

# The screen has layers: Background, middle, top
module ZOrder
    BACKGROUND, MIDDLE, TOP = *0..2
end

class DemoWindow < Gosu::Window
    def initialize
        super(640, 400, false)
    end
  
    def draw
        # see www.rubydoc.info/github/gosu/gosu/Gosu/Color for colours
        draw_quad(0, 0, 0xff_ffffff, 640, 0, 0xff_ffffff, 0, 400, 0xff_ffffff, 640, 400, 0xff_ffffff, ZOrder::BACKGROUND)
        draw_quad(5, 10, Gosu::Color::BLUE, 200, 10, Gosu::Color::AQUA, 5, 150, Gosu::Color::FUCHSIA, 200, 150, Gosu::Color::RED, ZOrder::MIDDLE)
        draw_triangle(50, 50, Gosu::Color::GREEN, 100, 50, Gosu::Color::GREEN, 50, 100, Gosu::Color::GREEN, ZOrder::MIDDLE, mode=:default)
        draw_line(200, 200, Gosu::Color::BLACK, 350, 350, Gosu::Color::BLACK, ZOrder::TOP, mode=:default)
        # draw_rect works a bit differently:
        Gosu.draw_rect(300, 200, 100, 50, Gosu::Color::BLACK, ZOrder::TOP, mode=:default)
  
        # Circle parameter - Radius
        img2 = Gosu::Image.new(Circle.new(50))
        # Image draw parameters - x, y, z, horizontal scale (use for ovals), vertical scale (use for ovals), colour
        # Colour - use Gosu::Image::{Colour name} or .rgb({red},{green},{blue}) or .rgba({alpha}{red},{green},{blue},)
        # Note - alpha is used for transparency.
        # drawn as an elipse (0.5 width:)
        img2.draw(200, 200, ZOrder::TOP, 0.5, 1.0, Gosu::Color::BLUE)
        # drawn as a red circle:
        img2.draw(300, 50, ZOrder::TOP, 1.0, 1.0, 0xff_ff0000)
        # drawn as a red circle with transparency:
        img2.draw(300, 250, ZOrder::TOP, 1.0, 1.0, 0x64_ff0000)
    end
end

class R_Window < Gosu::Window
    def initialize
        super(640, 480, false)
        self.caption = 'Rectangles Drawing'
    end

    def draw
        Gosu.draw_rect(10, 10, 70, 30, Gosu::Color::BLUE, ZOrder::TOP, mode=:default)
        Gosu.draw_rect(100, 10, 70, 10, Gosu::Color::FUCHSIA, ZOrder::TOP, mode=:default)
        Gosu.draw_rect(170, 10, 10, 30, Gosu::Color::FUCHSIA, ZOrder::TOP, mode=:default)
        Gosu.draw_rect(100, 30, 70, 10, Gosu::Color::FUCHSIA, ZOrder::TOP, mode=:default)
        Gosu.draw_rect(100, 10, 10, 30, Gosu::Color::FUCHSIA, ZOrder::TOP, mode=:default)
    end
end

class HouseWindow < Gosu::Window
    def initialize
        super(800, 600, false)
        self.caption = 'House Drawing'
    end

    def draw
        draw_rect(0, 0, 800, 600, Gosu::Color::WHITE, ZOrder::BACKGROUND, mode=:default)
        ground = Gosu::Image.new(Circle.new(400))
        ground.draw(0, 400, ZOrder::MIDDLE, 1.0, 0.5, Gosu::Color::GREEN)
        draw_rect(300, 300, 200, 200, Gosu::Color::GRAY, ZOrder::TOP, mode=:default)
        draw_triangle(400, 150, Gosu::Color::RED, 550, 300, Gosu::Color::RED, 250, 300, Gosu::Color::RED, ZOrder::TOP, mode=:default)
        sun = Gosu::Image.new(Circle.new(50))
        sun.draw(600, 50, ZOrder::MIDDLE, 1.0, 1.0, Gosu::Color::YELLOW)
        cloud = Gosu::Image.new(Circle.new(30))
        cloud.draw(570, 120, ZOrder::TOP, 1.2, 1.0, Gosu::Color::CYAN)
        cloud.draw(540, 135, ZOrder::TOP, 0.8, 0.7, Gosu::Color::CYAN)
        cloud.draw(620, 135, ZOrder::TOP, 1.0, 0.7, Gosu::Color::CYAN)
    end
end

def main()
    finished = false
    begin    
        puts('Options:')
        puts('1. Draw two rectangles')
        puts('2. Draw a house')
        puts('3. Draw different shapes')
        puts('4. Exit')
        choice = read_integer_in_range("Please enter your choice:", 1, 4)
        case choice
        when 1
            R_Window.new.show
        when 2
            HouseWindow.new.show
        when 3
            DemoWindow.new.show
        when 4
            finished = true
        else
        puts "Please select again"
        end
    end until finished
end

main()