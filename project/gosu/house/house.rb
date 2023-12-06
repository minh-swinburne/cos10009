require 'rubygems'
require 'gosu'
require './circle'
require './input_functions'
require './bezier_curve'

# The screen has layers: Background, middle, top
module ZOrder
    BACKGROUND, MIDDLE, TOP = *0..2
end

class HouseWindow < Gosu::Window
    def initialize
        super(800, 600, false)
        self.caption = 'Love Palace'
    end

    def draw
        draw_rect(0, 0, 800, 600, Gosu::Color::WHITE, ZOrder::BACKGROUND, mode=:default)
        ground = Gosu::Image.new(Circle.new(400))
        ground.draw(0, 400, ZOrder::MIDDLE, 1.0, 0.5, Gosu::Color::GREEN)
        draw_rect(300, 300, 200, 200, Gosu::Color.argb(0xff_FF8000), ZOrder::TOP, mode=:default)
        draw_rect(360, 400, 80, 100, Gosu::Color.argb(0xff_F9F2CE), ZOrder::TOP, mode=:default)
        draw_triangle(400, 150, Gosu::Color.argb(0xff_cc0000), 550, 300, Gosu::Color.argb(0xff_cc0000), 250, 300, Gosu::Color.argb(0xff_cc0000), ZOrder::TOP, mode=:default)
        sun = Gosu::Image.new(Circle.new(50))
        sun.draw(600, 50, ZOrder::MIDDLE, 1.0, 1.0, Gosu::Color::YELLOW)
        cloud = Gosu::Image.new(Circle.new(30))
        cloud.draw(570, 120, ZOrder::TOP, 1.2, 1.0, Gosu::Color::CYAN)
        cloud.draw(540, 135, ZOrder::TOP, 0.8, 0.7, Gosu::Color::CYAN)
        cloud.draw(620, 135, ZOrder::TOP, 1.0, 0.7, Gosu::Color::CYAN)
        draw_curve(200, 100, 250, 100, 210, 75, 240, 75, ZOrder::TOP, Gosu::Color::BLACK, 5)
        draw_curve(150, 100, 200, 100, 160, 75, 190, 75, ZOrder::TOP, Gosu::Color::BLACK, 5)
        draw_curve(100, 50, 125, 50, 105, 40, 120, 40, ZOrder::TOP, Gosu::Color::BLACK, 3)
        draw_curve(125, 50, 150, 50, 130, 40, 145, 40, ZOrder::TOP, Gosu::Color::BLACK, 3)
        draw_triangle(125, 250, Gosu::Color.argb(0xff_663300), 150, 535, Gosu::Color.argb(0xff_663300), 100, 535, Gosu::Color.argb(0xff_663300), ZOrder::TOP, mode=:default)
        draw_triangle(125, 160, Gosu::Color.argb(0xff_006600), 200, 325, Gosu::Color.argb(0xff_006600), 50, 325, Gosu::Color.argb(0xff_006600), ZOrder::TOP, mode=:default)
        draw_triangle(125, 220, Gosu::Color.argb(0xff_006600), 200, 385, Gosu::Color.argb(0xff_006600), 50, 385, Gosu::Color.argb(0xff_006600), ZOrder::TOP, mode=:default)
        draw_triangle(125, 280, Gosu::Color.argb(0xff_006600), 200, 445, Gosu::Color.argb(0xff_006600), 50, 445, Gosu::Color.argb(0xff_006600), ZOrder::TOP, mode=:default)
    end
end

def main()
    HouseWindow.new.show
end

main()