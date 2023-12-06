require 'rubygems'
require 'gosu'

class DemoWindow < Gosu::Window
 
  def initialize
    super(640, 400, false)
    self.caption = "Demo of draw_quad()"
  end

  def draw
    x = 300
    y = 200
    size = 120
    draw_quad(x-size, y-size, 0xffff8888, x+size, y-size, 0xffffffff, x-size, y+size, 0xffffffff, x+size, y+size, 0xffffffff, 0)
  end
 
end

DemoWindow.new.show