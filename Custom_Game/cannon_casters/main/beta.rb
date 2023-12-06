require 'gosu'
require './questions'

module ZOrder
    BACKGROUND, MIDDLE, TOP = *0..2
end

module Screen_State
    Main_Menu = 0
    Play_Stage = 1
    Quiz = 2
end

WIDTH = 1280
HEIGHT = 720
AIM_DIM = 100
PI = 3.1416

INDENT_X = 150
INDENT_Y = 100

FISH_NAMES = ['angelfish', 'butterflyfish', 'clownfish', 'jellyfish', 'lanternfish', 'pufferfish', 'seahorse', 'shark', 'trout']

class Element
    attr_accessor :x, :y, :width, :height, :img, :normal, :hovered, :pressed, :name, :factor, :direction
    
    def initialize(x, y, width, height, img_normal, img_hovered = nil, img_pressed = nil, name)
      @x = x
      @y = y
      @width = width
      @height = height
      @normal = img_normal
      @hovered = img_hovered
      @pressed = img_pressed
      @img = @normal
      @name = name
    end
end

class Fish
    attr_accessor :name, :img, :score

    def initialize(name, img, score)
        @name = name
        @img = img
        @score = score
    end
end

class Weapon
    attr_accessor :x, :y, :angle, :img, :goal_x, :goal_y, :time

    def initialize(x, y, angle, img)
        @x = x
        @y = y
        @angle = angle
        @img = img
    end
end 

class CannonCasters < Gosu::Window
    def initialize
        super(WIDTH, HEIGHT, false)
        self.caption = 'Cannon Casters'

        # background animation
        @delay_time = 1
        @bg_common = 'shipwreck_'
        @title = Gosu::Image.new("assets/title400.png")
        @aim = Gosu::Image.new("assets/aim_mark.png")
        @choice_img = Gosu::Image.load_tiles("assets/choice_button.png", 395, 150)
        @board_img  = Gosu::Image.new("assets/board.png")

        @aim_x = @aim_y = @time = @elapsed_time = @cycle = 0
        @speed_right = @speed_left = @speed_up = @speed_down = 1
        @font = Gosu::Font.new(20)
        @large_font = Gosu::Font.new(30, :name => 'Consolas', :bold => true)

        @screen = Screen_State::Main_Menu
        @play = false
        @bgm = Gosu::Song.new('assets/Underwater Ambience.mp3')
        @bgm.play(true)

        # difficulty multipliers
        @easy = 1
        @medium = 1.5
        @hard = 2

        @aim_y = HEIGHT/2 - AIM_DIM/2
        @aim_x = WIDTH/2 - AIM_DIM/2

        @questions = read_questions()
        setup_buttons()
        setup_fish()
        setup_weapon()
    end

    def mouse_at_button(button)
        leftX = button.x - button.width/2
        rightX = leftX + button.width
        topY = button.y - button.height/2
        bottomY = topY + button.height
        if (mouse_x > leftX and mouse_x < rightX) and (mouse_y > topY and mouse_y < bottomY)
            button.img = button.hovered
			return true
		else
            button.img = button.normal
			false
		end
    end

    def clicked_button(button)
        if mouse_at_button(button) and Gosu.button_down?(Gosu::MS_LEFT)
            button.img = button.pressed
            return true
        else
            return false
        end
    end

    def setup_buttons()
        @buttons = Array.new()
        ngb_normal, ngb_hovered, ngb_clicked = Gosu::Image.load_tiles("assets/newgame_button.png", 171, 50)
        @new_game_button = Element.new(WIDTH/2, 575, ngb_normal.width, ngb_normal.height, ngb_normal, ngb_hovered, ngb_clicked, 'new_game')
    end

    def setup_fish()
        @fish_list = []
        @fish = []
        count = FISH_NAMES.length
        index = 0
        while index < count
            fish_img = Gosu::Image.new("assets/#{FISH_NAMES[index]}.png")
            fish = Fish.new(FISH_NAMES[index], fish_img, 100)
            @fish_list << fish
            index += 1
        end
    end

    def setup_weapon()
        cannon_img = Gosu::Image.new('assets/cannon.png')
        x = WIDTH / 2
        y = HEIGHT - cannon_img.height / 2
        @cannon = Weapon.new(x, y, 0, cannon_img)
        @bullets = []
        @bullet_speed = 20
        @bullet_img = Gosu::Image.new('assets/bullet.png')
        @bullet_created = false
        @nets = []
        @net_exist_time = 2
        @net_img = Gosu::Image.new('assets/net.png')
    end

    def new_fish()
        fish = @fish_list[rand(@fish_list.length)]
        left = (rand(2) == 1)?(true):(false)
        if left     # from left to right
            x = - fish.img.width
            factor = -1.0
            direction = 1
        else        # from right o left
            x = WIDTH
            factor = 1.0
            direction = 0
        end
        if fish.name == 'jellyfish'      # from down to up
            x = rand(WIDTH - fish.img.width)
            y = HEIGHT
            direction = 2
        else
            y = rand(HEIGHT - fish.img.height)
        end
        fish = Element.new(x, y, fish.img.width, fish.img.height, fish.img, fish.name)
        fish.factor = factor
        fish.direction = direction
        @fish << fish
    end

    def new_bullet(x_offset, y_offset)
        bullet = Weapon.new(@cannon.x, @cannon.y, @cannon.angle, @bullet_img)
        bullet.goal_x = bullet.x + x_offset
        bullet.goal_y = bullet.y + y_offset
        @bullets << bullet
    end

    def bullet_explode(bullet)
        net = Weapon.new(bullet.goal_x, bullet.goal_y, 0, @net_img)
        net.time = Gosu.milliseconds
        @nets << net
        @bullets.delete(bullet)
    end

    def fish_caught?()
        for net in @nets
            net_leftX = net.x + 25
            net_rightX = net.x + net.img.width - 25
            net_topY = net.y + 25
            net_bottomY = net.y + net.img.height - 25
            for fish in @fish
                fish_leftX = fish.x
                fish_rightX = fish.x + fish.img.width
                fish_topY = fish.y
                fish_bottomY = fish.y + fish.img.height
                if (fish_leftX < net_rightX and fish_rightX > net_leftX) and (fish_topY < net_bottomY and fish_bottomY > net_topY) and (Gosu.milliseconds - net.time < 500)
                    puts("Net: left = #{net_leftX}; right = #{net_rightX}; top = #{net_topY}; bottom = #{net_bottomY}\nFish: right = #{fish_rightX}; left = #{fish_leftX}; bottom = #{fish_bottomY}; top = #{fish_topY}")
                    return true
                end
            end
        end
        return false
    end

    def new_question()
        random = rand(@questions.length)
        @question = @questions[random]
        @screen = Screen_State::Quiz
        @choice_boxes = Array.new(4)
        base_x = INDENT_X + (WIDTH - INDENT_X*2) / 4
        base_y = 350
        width = @choice_img[0].width
        height = @choice_img[0].height
        indent_x = (WIDTH - INDENT_X*2) / 2
        indent_y = 25
        for index in 0..3
            row = (index > 1)?1:0
            column = index % 2
            x = base_x + indent_x*column
            y = base_y + (height + indent_y)*row
            @choice_boxes[index] = Element.new(x, y, width, height, @choice_img[0], @choice_img[1], @choice_img[2], "choice_button_#{index}")
        end
    end

    def check_answer(choice)
        if choice == @question.correct
            

    def update

        case @screen
        when Screen_State::Main_Menu            
            if clicked_button(@new_game_button)
                @play = true
            end
        when Screen_State::Play_Stage
            if button_down?(Gosu::KbRight) && (@aim_x < (WIDTH - 80))
                @speed_right += 2
                @aim_x += @speed_right
            else
                @speed_right = 10
            end
        
            if button_down?(Gosu::KbLeft) && (@aim_x > -20)
                @speed_left += 2
                @aim_x -= @speed_left
            else
                @speed_left = 10
            end
        
            if button_down?(Gosu::KbUp) && (@aim_y > -20)
                @speed_down += 1
                @aim_y -= @speed_down
            else
                @speed_down = 5
            end
        
            if button_down?(Gosu::KbDown) && (@aim_y < (HEIGHT - @cannon.img.height))
                @speed_up += 1
                @aim_y += @speed_up
            else
                @speed_up = 5
            end

            x_offset = @aim_x + (@aim.width - WIDTH) / 2
            y_offset = @aim_y - HEIGHT + (@aim.height + @cannon.img.height) / 2
            radian = Math.atan2(y_offset, x_offset)
            @cannon.angle = radian * 180 / PI + 90

            if button_down?(Gosu::KbSpace) and !@bullet_created
                @bullet_created = true
                new_bullet(x_offset, y_offset)
                distance = Math.sqrt(x_offset**2 + y_offset**2)
            elsif !button_down?(Gosu::KbSpace)
                @bullet_created = false
            end
                
            now = Gosu.milliseconds
            if now - @time >= (@delay_time * 1000)
                @elapsed_time += 1
                @time = now
                new_fish()
            end

            for fish in @fish
                case fish.direction
                when 0          # from right to left
                    fish.x -= 5
                when 1
                    fish.x += 5
                when 2
                    fish.y -= 3
                end
            end

            for bullet in @bullets
                if (bullet.x < bullet.goal_x and bullet.angle > 0) or (bullet.x > bullet.goal_x and bullet.angle < 0)
                    angle_rad = (bullet.angle - 90) * PI / 180
                    move_x = @bullet_speed * Math.cos(angle_rad)
                    move_y = @bullet_speed * Math.sin(angle_rad)
                    bullet.x += move_x
                    bullet.y += move_y
                else
                    bullet_explode(bullet)
                end
            end

            if fish_caught?()
                new_question()
                @questions.delete(@question) if @questions.include?(@question)
            end
            
        when Screen_State::Quiz
            if button_down?(Gosu::KbEscape)
                @screen = Screen_State::Play_Stage
            end
            for index in 0..3
                if clicked_button(@choice_boxes[index])
                    choice = index
                    @play = true
            end
        end

        if @play and not Gosu.button_down?(Gosu::MS_LEFT)
            @screen = Screen_State::Play_Stage
            @fish_onscreen = Array.new()
            @time = Gosu.milliseconds
            @play = false
        end
    end

    def draw_buttons()
        case @screen
        when Screen_State::Main_Menu
            @buttons = [@new_game_button]
        when Screen_State::Play_Stage
            @buttons = []
        when Screen_State::Quiz
            @buttons = @choice_boxes
        end
        for button in @buttons
            button.img.draw_rot(button.x, button.y, ZOrder::MIDDLE)
        end
    end

    def draw_fish()
        for fish in @fish
            fish.img.draw(fish.x, fish.y, ZOrder::MIDDLE, fish.factor, 1.0)
        end
    end

    def draw_weapon()
        @cannon.img.draw_rot(@cannon.x, @cannon.y, ZOrder::TOP, @cannon.angle)
        for bullet in @bullets
            bullet.img.draw_rot(bullet.x, bullet.y, ZOrder::MIDDLE, bullet.angle)
        end
        
        for net in @nets
            now = Gosu.milliseconds
            if now - net.time < (@net_exist_time * 1000)
                net.img.draw_rot(net.x, net.y, ZOrder::TOP, 0)
            else
                @nets.delete(net)
            end
        end
    end

    def find_text_width(text)
        return Gosu::Image.from_markup(text, @large_font.height, :font => 'Consolas', :bold => true).width
    end

    def truncate_text(text)        
        limit = WIDTH - INDENT_X*2 - 200
        words = text.split
        lines = Array.new()        
        truncated = false
            index = 0
            while !truncated
                lines[index] = words.clone
                while find_text_width(lines[index].join(' ')) > limit
                    lines[index].pop
                end
                words = words[lines[index].length..]
                if find_text_width(words.join(' ')) < limit
                    truncated = true
                    lines[index+1] = words
                end
                index += 1
            end
        return lines
    end

    def draw_question()
        @board_img.draw_rot(WIDTH / 2, HEIGHT / 2, ZOrder::BACKGROUND)
        if @question
            limit = WIDTH - INDENT_X*2 - 200
            text_width = find_text_width(@question.quest)
            if text_width > limit
                lines = truncate_text(@question.quest)                
                lines.each_with_index do |line, index|
                    @large_font.draw_text_rel(line.join(' '), WIDTH/2, 180 + @large_font.height * index, ZOrder::MIDDLE, 0.5, 0.5)
                end
            else
                @large_font.draw_text_rel(@question.quest, WIDTH/2, 200, ZOrder::MIDDLE, 0.5, 0.5)
            end
            base_x = 400
            base_y = 450
            width = 250
            height = 50
            indent_x = 150
            indent_y = 25
            for index in 0...4
                choice = @question.choices[index]
                row = (index > 1)?1:0
                column = index % 2
                x = base_x + (width + indent_x)*column
                y = base_y + (height + indent_y)*row
                @large_font.draw_text_rel(choice, @choice_boxes[index].x, @choice_boxes[index].y, ZOrder::TOP, 0.5, 0.5, 1.0, 1.0, Gosu::Color::BLACK)
            end
        end
    end

    def draw_bg
        bg_name = @bg_common + ('%03d' % @cycle) + '.png'
        @background = Gosu::Image.new("./assets/background/" + bg_name)
        @cycle += 1
        if @cycle == 251
            @cycle = 0
        end
        @background.draw(0, 0, ZOrder::BACKGROUND)
        #draw_rect(0,0,1920,1080,Gosu::Color::BLACK,ZOrder::BACKGROUND,mode=:default)
    end

    def draw_spec()        
        # specifications
        @font.draw_text("Time: #{@time}   Elapsed time: #{@elapsed_time}", 10, 640, z = ZOrder::TOP, 1.0, 1.0, Gosu::Color::WHITE)
        @font.draw_text("Screen: #{@screen}   Hovered? - #{(@new_game_button.img == @new_game_button.hovered)}", 10, 660, z = ZOrder::TOP, 1.0, 1.0, Gosu::Color::WHITE)
        @font.draw_text("X: #{mouse_x}  Y: #{mouse_y}\nL: #{@speed_left}  R: #{@speed_right}  U: #{@speed_up} D: #{@speed_down}", 10, 680, z = ZOrder::TOP, 1.0, 1.0, Gosu::Color::WHITE)

        x_offset = @aim_x + (@aim.width - WIDTH) / 2
        y_offset = @aim_y - HEIGHT + (@aim.height + @cannon.img.height) / 2
        radian = Math.atan2(y_offset, x_offset)
        @font.draw_text("X Offset: #{x_offset}  Y offset: #{y_offset}", WIDTH - 250, 680, ZOrder::TOP, 1.0, 1.0, Gosu::Color::WHITE)

        @font.draw_text("Bullet Created: #{@bullet_created}", WIDTH - 250, 660, ZOrder::TOP, 1.0, 1.0, Gosu::Color::WHITE)

        bullet = @bullets[@bullets.length - 1]
        @font.draw_text("Bullet X: #{bullet.x.round(2)}; Y: #{bullet.y.round(2)}; Goal X: #{bullet.goal_x}; Goal Y: #{bullet.goal_y}; Angle: #{bullet.angle}", WIDTH - 550, 700, ZOrder::TOP, 1.0, 1.0, Gosu::Color::WHITE) rescue nil
    end

    def draw
        draw_bg()
        case @screen
        when Screen_State::Main_Menu
            @title.draw(440, 100, ZOrder::MIDDLE)
        when Screen_State::Play_Stage
            @aim.draw(@aim_x, @aim_y, ZOrder::TOP)
            draw_fish()
            draw_weapon()
        when Screen_State::Quiz
            draw_question()
        end        
        draw_buttons()
        
        # credit
        @font.draw_text("Swinburne University of Technology - Swinburne Vietnam\nNguyen Thi Thanh Minh - 104169617", 10, 10, z = ZOrder::TOP, 1.0, 1.0, Gosu::Color::WHITE)
        draw_spec()
    end

    def needs_cursor?; true; end
end

def main()
    on = true
    CannonCasters.new.show
    if !on

    end
end

main() if __FILE__ == $0