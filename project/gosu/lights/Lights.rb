require 'gosu'

module ZOrder
  BACKGROUND, PLAYER, UI = *0..2
end

module LightSize
  Small, Medium, Large = *1..3
end

SCREEN_SIZE = 600

LIGHT_ON_IMG = 'on_med.png'
LIGHT_OFF_IMG = 'off_med.png'

LIGHT_SML_ON_IMG = 'on_sml.png'
LIGHT_SML_OFF_IMG = 'off_sml.png'

LIGHT_LAR_ON_IMG = 'on.png'
LIGHT_LAR_OFF_IMG = 'off.png'

SWITCH_ON = 'SwitchOn.png'
SWITCH_OFF = 'SwitchOff.png'

class Light
  attr_accessor :is_on, :x_cor, :y_cor, :angle, :size
end

class Switch
  attr_accessor :switch_is_on, :switch_x, :switch_y, :light
end

class Lights < Gosu::Window
  def initialize
      super SCREEN_SIZE, SCREEN_SIZE
      self.caption = "Lights Demo"

      @my_light = Light.new()
      @my_light.is_on = true
      @my_light.x_cor = 100
      @my_light.y_cor = 150
      @my_light.angle = 0
      @my_light.size = LightSize::Medium

      @another_light = Light.new()
      @another_light.is_on = true
      @another_light.x_cor = 100
      @another_light.y_cor = 450
      @another_light.angle = 90
      @another_light.size = LightSize::Small

      @switch = Switch.new()
      @switch.switch_is_on = true
      @switch.switch_x = 400
      @switch.switch_y = 100
      @switch.light = @my_light

  end

  def draw_switch(switch)
  	if switch.switch_is_on
      image = Gosu::Image.new("./images/" + SWITCH_ON)
  	else
      image = Gosu::Image.new("./images/" + SWITCH_OFF)
    end

    image.draw(switch.switch_x, switch.switch_y, ZOrder::PLAYER)

  	if switch.light != nil
  		  Gosu.draw_rect(switch.light.x_cor, switch.light.y_cor, 10, 10, Gosu::Color::BLACK, ZOrder::UI, mode=:default)
    end
  end

  def get_light_file_name(light)
  	if light.is_on
  		name = "on"
  	else
  		name = "off"
    end

  	case light.size
    when LightSize::Small
      name = name + "_sml"
    when LightSize::Medium
  		name = name + '_med'
  	end
    name + ".png"
  end


# Students: Think about how the two following functions could be combined into one
# and also the coupling be improved:

  def mouse_over_light(x, y, light)
    if  (light.x_cor - x).abs < 100 and (light.y_cor - y).abs < 100
      true
    end
  end

  def mouse_over_switch(x, y, switch)
    if  (switch.switch_x - x) < 50 and (switch.switch_y - y) < 100
      true
    end
  end

  def toggle_switch()
  	@switch.switch_is_on = !@switch.switch_is_on
  	if @switch.light != nil
  		@switch.light.is_on = !@switch.light.is_on
  	end
  end

  def update
	end

  def clear_screen()
    if @my_light.is_on || @another_light.is_on
      color = Gosu::Color::WHITE
    else
      color = Gosu::Color::BLACK
    end
    draw_quad(
        0, 0, color,
        SCREEN_SIZE, 0, color,
        0, SCREEN_SIZE, color,
        SCREEN_SIZE, SCREEN_SIZE, color,
        ZOrder::BACKGROUND
      )
  end

  def draw_light(light)
    image = Gosu::Image.new("./images/" + get_light_file_name(light))
    image.draw_rot(light.x_cor, light.y_cor, ZOrder::PLAYER, light.angle)
  end

	def draw
    clear_screen
    draw_light(@my_light)
    draw_light(@another_light)
    draw_switch(@switch)
	end

 	def needs_cursor?; true; end

	def button_down(id)
		case id
    when Gosu::MsLeft
      if mouse_over_light(mouse_x, mouse_y, @my_light)
        @switch.light = @my_light
      end
      if mouse_over_light(mouse_x, mouse_y, @another_light)
        @switch.light = @another_light
      end
      if mouse_over_switch(mouse_x, mouse_y, @switch)
        toggle_switch
      end
    when Gosu::KB_1
      @switch.light.size = LightSize::Small
    when Gosu::KB_2
      @switch.light.size= LightSize::Medium
    when Gosu::KB_3
      @switch.light.size = LightSize::Large
	  end
	end
end

Lights.new.show if __FILE__ == $0
