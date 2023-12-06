require 'rubygems'
require 'gosu'

module ZOrder
  BACKGROUND, MIDDLE, TOP = *0..2
end

WIN_WIDTH = 640
WIN_HEIGHT = 400
class DemoWindow < Gosu::Window
#   def initialize
#     super(WIN_WIDTH, WIN_HEIGHT, false)
#     @background = Gosu::Color::WHITE
#     @button_font = Gosu::Font.new(20)
#     @info_font = Gosu::Font.new(10)
#     @locs = [60,60]
#   end

  def initialize
    super(WIN_WIDTH, WIN_HEIGHT, false)
    @background = Gosu::Color::WHITE
    @button_font = Gosu::Font.new(20)
    @info_font = Gosu::Font.new(10)
    @locs = [60,60]
    @index = 0
  end

  def draw
 
    Gosu.draw_rect(0, 0, WIN_WIDTH, WIN_HEIGHT, @background, ZOrder::BACKGROUND, mode=:default)
    if area_clicked(mouse_x, mouse_y)
      draw_line(50, 50, Gosu::Color::BLACK, 150, 50, Gosu::Color::BLACK, ZOrder::TOP, mode=:default)
      draw_line(50, 50, Gosu::Color::BLACK, 50, 100, Gosu::Color::BLACK, ZOrder::TOP, mode=:default)
      draw_line(150, 50, Gosu::Color::BLACK, 150, 101, Gosu::Color::BLACK, ZOrder::TOP, mode=:default)
      draw_line(50, 100, Gosu::Color::BLACK, 150, 100, Gosu::Color::BLACK, ZOrder::TOP, mode=:default)
    end
    Gosu.draw_rect(50, 50, 100, 50, Gosu::Color::GREEN, ZOrder::MIDDLE, mode=:default)
    @button_font.draw_text("Click me", 60, 60, ZOrder::TOP, 1.0, 1.0, Gosu::Color::BLACK)
    @info_font.draw_text("mouse_x: #{mouse_x}", 0, 350, ZOrder::TOP, 1.0, 1.0, Gosu::Color::BLACK)
    @info_font.draw_text("mouse_y: #{mouse_y}", 100, 350, ZOrder::TOP, 1.0, 1.0, Gosu::Color::BLACK )

    # if Gosu.button_down? Gosu::MsLeft
    #     index = 0
    #     button = area_clicked(mouse_x, mouse_y)
    #     case button
    #     when 1
    #         index+=1
    #         @info_font.draw("Times Click: #{index}", 370, 350, ZOrder::TOP, 1.0, 1.0, Gosu::Color::BLACK)
    # end

    if Gosu.button_down? Gosu::MsLeft
        button = area_clicked(mouse_x, mouse_y)
        case button
        when 1
            @index += 1
            @info_font.draw("Times Click: #{@index}", 370, 350, ZOrder::TOP, 1.0, 1.0, Gosu::Color::BLACK)
        end
    end
end

  def needs_cursor?; true; end



  def area_clicked(mouse_x, mouse_y)
    if ((mouse_x > 50 and mouse_x < 150) and (mouse_y > 50 and mouse_y < 100))
      return 1
    else
    end
  end

  def button_down(id)
    if id == Gosu::KB_ESCAPE
        close
    else
        super
    end
end
end


DemoWindow.new.show