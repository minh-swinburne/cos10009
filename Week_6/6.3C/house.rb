require 'rubygems'
require 'gosu'
require './circle'
require './bezier_curve'

# The screen has 3 layers: Background, middle, top
module ZOrder
    BACKGROUND, MIDDLE, TOP = *0..2
end

WIDTH = 800
HEIGHT = 600

# This picture is not static, it can be changed between day and night scene
# press space bar to change the scene
# There is also a controllable UFO that can be moved around
# controlled by keyboard up, down, left, right buttons

class HouseWindow < Gosu::Window
    def initialize
        super(WIDTH, HEIGHT, false)
        self.caption = 'House on the Hill'

        # This variable is for changing the scene between day and night
        @day = true

        # These variables are for a moving shape
        @shape_y = 50
        @shape_x = 400
        @img = Gosu::Image.new("./media/ufo.png")
    end

    def draw_background # draw the background (day or night)
        if @day # Draw the blue sky as the background for the picture
            color_top = 0xff_0080ff
            color_bot = 0xff_cce5ff
        else
            color_top = 0xff_001933
            color_bot = 0xff_001933
        end
        Gosu.draw_quad(0, 0, color_top, WIDTH, 0, color_top, 0, HEIGHT, color_bot, WIDTH, HEIGHT, color_bot, ZOrder::BACKGROUND, mode=:default)
    end

    def draw_house_on_hill
        # Draw a green hill
        @ground = Gosu::Image.new(Circle.new(400))
        @ground.draw(0, 400, ZOrder::MIDDLE, 1.0, 0.5, 0xff_00cc00)
        # Draw the house, including a wall, a door and a triangle roof
        # wall
        draw_rect(300, 300, 200, 200, Gosu::Color.argb(0xff_a0a0a0), ZOrder::TOP, mode=:default)
        # door
        draw_rect(360, 400, 80, 100, Gosu::Color.argb(0xff_404040), ZOrder::TOP, mode=:default)
        # roof
        draw_triangle(400, 150, Gosu::Color.argb(0xff_cc0000), 550, 300, Gosu::Color.argb(0xff_cc0000), 250, 300, Gosu::Color.argb(0xff_cc0000), ZOrder::TOP, mode=:default)
        # Draw a tree using triangles, consisting of a trunk and three layers of leaves
        # tree trunk
        draw_triangle(125, 250, Gosu::Color.argb(0xff_663300), 150, 535, Gosu::Color.argb(0xff_663300), 100, 535, Gosu::Color.argb(0xff_663300), ZOrder::TOP, mode=:default)
        # leaves layers
        draw_triangle(125, 200, Gosu::Color.argb(0xff_006600), 200, 325, Gosu::Color.argb(0xff_006600), 50, 325, Gosu::Color.argb(0xff_006600), ZOrder::TOP, mode=:default)
        draw_triangle(125, 220, Gosu::Color.argb(0xff_006600), 200, 385, Gosu::Color.argb(0xff_006600), 50, 385, Gosu::Color.argb(0xff_006600), ZOrder::TOP, mode=:default)
        draw_triangle(125, 280, Gosu::Color.argb(0xff_006600), 200, 445, Gosu::Color.argb(0xff_006600), 50, 445, Gosu::Color.argb(0xff_006600), ZOrder::TOP, mode=:default)
    end

    def draw_sky
        # Draw the sun (day) or the moon (night)
        sun_moon = Gosu::Image.new(Circle.new(50))
        if @day
            sun_moon.draw(600, 50, ZOrder::MIDDLE, 1.0, 1.0, Gosu::Color::YELLOW)
        else
            sun_moon.draw(600, 50, ZOrder::MIDDLE, 1.0, 1.0, 0xff_ffffcc)
            sun_moon.draw(630, 50, ZOrder::MIDDLE, 0.8, 0.8, 0xff_001933)
        end
        # Draw some cloud using ovals
        cloud = Gosu::Image.new(Circle.new(30))
        cloud.draw(570, 120, ZOrder::TOP, 1.2, 1.0, Gosu::Color::WHITE)
        cloud.draw(540, 135, ZOrder::TOP, 0.8, 0.7, Gosu::Color::WHITE)
        cloud.draw(620, 135, ZOrder::TOP, 1.0, 0.7, Gosu::Color::WHITE)
        # Draw two birds (day) or shooting star (night) using curves
        if @day
        # first bird
            draw_curve(200, 100, 250, 100, 210, 75, 240, 75, ZOrder::MIDDLE, Gosu::Color::BLACK, 5)
            draw_curve(150, 100, 200, 100, 160, 75, 190, 75, ZOrder::MIDDLE, Gosu::Color::BLACK, 5)
        # second bird
            draw_curve(100, 50, 125, 50, 105, 40, 120, 40, ZOrder::MIDDLE, Gosu::Color::BLACK, 3)
            draw_curve(125, 50, 150, 50, 130, 40, 145, 40, ZOrder::MIDDLE, Gosu::Color::BLACK, 3)
        else
            draw_curve(100, 50, 500, 150, 120, 50, 400, 100, ZOrder::MIDDLE, Gosu::Color::WHITE, 3)
        end
    end

    def update # control the shape to move within the picture
        # move right
        if button_down?(Gosu::KbRight) && (@shape_x < (WIDTH - @img.width))
            @shape_x += 40
        end
        # move left
        if button_down?(Gosu::KbLeft) && (@shape_x > 0)
            @shape_x -= 40
        end
        # move up
        if button_down?(Gosu::KbUp) && (@shape_y > 0)
            @shape_y -= 40
        end
        # move down
        if button_down?(Gosu::KbDown) && (@shape_y < (HEIGHT - @img.height))
            @shape_y += 40
        end
    
    end

    def draw
        draw_background
        draw_house_on_hill
        draw_sky
        @img.draw(@shape_x, @shape_y, ZOrder::TOP)
    end

    def button_down(id) # change between day and night by pressing space bar
        case id
        when Gosu::KB_SPACE
            @day = !@day
        end
    end
end

def main()
    HouseWindow.new.show
end

main() if __FILE__ == $0