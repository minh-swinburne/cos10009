require 'gosu'
require './questions'
require './score'

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
    attr_accessor :x, :y, :width, :height, :img, :normal, :hovered, :pressed, :name, :factor, :direction, :time
    
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
        super(WIDTH, HEIGHT, true)
        self.caption = 'Cannon Casters'

        # background animation
        @delay_time = 3
        @bg_common = 'shipwreck_'

        @score = @aim_x = @aim_y = @time = @elapsed_time = @cycle = @correct_time = 0
        @speed_right = @speed_left = @speed_up = @speed_down = 1

        @screen = Screen_State::Main_Menu
        @play = false
        @answered = false
        @fish_caught = false

        # difficulty multipliers
        @easy = 1
        @medium = 1.5
        @hard = 2

        @aim_y = HEIGHT/2 - AIM_DIM/2
        @aim_x = WIDTH/2 - AIM_DIM/2

        @questions = read_questions()

        setup_assets()
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
    
    def setup_assets()
        @title = Gosu::Image.new("assets/title.png")
        @play_text = Gosu::Image.from_text('PLAY', 72, :font => 'Showcard Gothic')
        @aim = Gosu::Image.new("assets/aim_mark.png")
        @button_img = Gosu::Image.load_tiles("assets/choice_button.png", 395, 150)
        @board_img  = Gosu::Image.new("assets/board.png")
        @correct = Gosu::Image.new("assets/correct_choice.png")
        @wrong = Gosu::Image.new("assets/wrong_choice.png")
        @flag = Gosu::Image.new("assets/flag1.png")
        
        @bgm = Gosu::Sample.new('assets/Underwater Ambience.mp3')
        @bgm.play(1, 1, true)
        @correct_sfx = Gosu::Song.new('assets/correct_choice.mp3')
        @wrong_sfx = Gosu::Song.new('assets/wrong_choice.mp3')
        @explode_sfx = Gosu::Song.new('assets/explode.mp3')
        @shoot_sfx = Gosu::Song.new('assets/shoot.mp3')
        
        @font = Gosu::Font.new(20)
        @large_font = Gosu::Font.new(30, :name => 'Consolas', :bold => true)
        @play_font = Gosu::Font.new(40, :name => 'Showcard Gothic')
    end

    def setup_buttons()
        @buttons = Array.new()
        ngb_normal, ngb_hovered, ngb_clicked = @button_img
        @new_game_button = Element.new(WIDTH/2, 600, ngb_normal.width, ngb_normal.height, ngb_normal, ngb_hovered, ngb_clicked, 'new_game')
        @reset_score_button = Element.new(WIDTH-100, 50, 200, 100, ngb_normal, ngb_hovered, ngb_clicked, 'reset_score')
        @quit_button = Element.new(WIDTH-100, HEIGHT-50, 200, 100, ngb_normal, ngb_hovered, ngb_clicked, 'quit')
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
        # fish = @fish_list[3]
        fish = @fish_list[rand(@fish_list.length)]
        left = (rand(2) == 1)?(true):(false)
        if left     # from left to right
            x = - fish.img.width / 2
            factor = -1.0
            direction = 1
        else        # from right to left
            x = WIDTH + fish.img.width / 2
            factor = 1.0
            direction = 0
        end
        if fish.name == 'jellyfish'      # from down to up
            # x = 0
            x = rand((fish.img.width/2)..(WIDTH - fish.img.width/2))
            # x += fish.img.width if factor == -1.0
            y = HEIGHT + fish.img.height / 2
            direction = 2
        else
            y = rand((fish.img.height/2)..(HEIGHT - fish.img.height - @cannon.img.height))
        end
        fish = Element.new(x, y, fish.img.width, fish.img.height, fish.img, fish.name)
        fish.factor = factor
        fish.direction = direction
        fish.time = Gosu.milliseconds
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

    def fish_caught_time()
        for net in @nets
            net_centerX = net.x
            net_centerY = net.y
            for fish in @fish
                fish_centerX = fish.x
                exception = ['angelfish', 'clownfish', 'lanternfish', 'pufferfish', 'seahorse', 'trout']
                if exception.include?(fish.name)
                    case fish.factor
                    when 1.0
                        fish_centerX -= 25
                    when -1.0
                        fish_centerX += 25
                    end
                    end
                fish_centerY = fish.y
                if ((net_centerX - fish_centerX).abs < fish.width/2) and ((net_centerY - fish_centerY).abs < fish.height/2) and (Gosu.milliseconds - net.time < 100)
                    @fish_caught = true
                    @fish.delete(fish)
                    return net.time, @fish.index(fish)
                end
            end
        end
        return 0, @fish.length
    end

    def new_question()
        random = rand(@questions.length)
        # random = 30
        @question = @questions[random]
        @screen = Screen_State::Quiz
        @choice_boxes = Array.new(4)
        base_x = INDENT_X + (WIDTH - INDENT_X*2) / 4
        base_y = 350
        width = @button_img[0].width
        height = @button_img[0].height
        indent_x = (WIDTH - INDENT_X*2) / 2
        indent_y = 25
        for index in 0..3
            row = (index > 1)?1:0
            column = index % 2
            x = base_x + indent_x*column
            y = base_y + (height + indent_y)*row
            @choice_boxes[index] = Element.new(x, y, width, height, @button_img[0], @button_img[1], @button_img[2], "choice_button_#{index}")
        end
    end

    def check_answer(choice)
        if choice == @question.correct
            @correct_time = Gosu.milliseconds
            img = @correct
            @answered = true
            sfx = @correct_sfx
            @score += 1
        else
            img = @wrong
            sfx = @wrong_sfx
            @score = 0
        end
        sfx.play
        @choice_boxes[choice].normal = img
        @choice_boxes[choice].hovered = img
        @choice_boxes[choice].pressed = img
    end

    def update

        if @questions == nil
            @questions = read_questions()
        end

        case @screen
        when Screen_State::Main_Menu            
            if clicked_button(@new_game_button)
                @play = true
                @bgm = Gosu::Sample.new('assets/Veluriyam.mp3')
                @bgm.play(1, 1, true)
            end
        when Screen_State::Play_Stage

            if clicked_button(@reset_score_button)
                @score = 0
            end

            if clicked_button(@quit_button)
                @screen = Screen_State::Main_Menu
                @play = false
                @score = 0
                @bgm = Gosu::Sample.new('assets/Underwater Ambience.mp3')
                @bgm.play(1, 1, true)
            end

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
                @shoot_sfx.play(false)
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
                fish.y += 2 * Math.sin((Gosu.milliseconds + fish.time) / 500)
                if fish.x < -fish.width/2 or fish.x > (WIDTH + fish.width/2) or fish.y < -fish.height or fish.y > HEIGHT
                    @fish.delete(fish)
                end
            end

            for bullet in @bullets
                if (bullet.x < bullet.goal_x and bullet.angle > 0) or (bullet.x > bullet.goal_x and bullet.angle < 0) or (bullet.y > bullet.goal_y)
                    angle_rad = (bullet.angle - 90) * PI / 180
                    move_x = @bullet_speed * Math.cos(angle_rad)
                    move_y = @bullet_speed * Math.sin(angle_rad)
                    bullet.x += move_x
                    bullet.y += move_y
                else
                    bullet_explode(bullet)
                    @explode_sfx.play(false)
                end
            end

            time = fish_caught_time()[0]
            if @fish_caught and (Gosu.milliseconds - time > 200)
                @fish_caught = false
                new_question()
                @questions.delete(@question) if @questions.include?(@question)
            end
            
        when Screen_State::Quiz
            if button_down?(Gosu::KbEscape)
                @screen = Screen_State::Play_Stage
            end
            for index in 0..3
                if clicked_button(@choice_boxes[index]) and !@answered
                    check_answer(index)
                end
            end
            if (@answered) and (Gosu.milliseconds - @correct_time > (@net_exist_time * 1000))
                @answered = false
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
            @buttons = [@reset_score_button, @quit_button]
        when Screen_State::Quiz
            @buttons = @choice_boxes
        end
        for button in @buttons
            if button.name == 'reset_score'
                button.img.draw_rot(button.x, button.y, ZOrder::MIDDLE, 0, 0.5, 0.5, (200.0/395), (2.0/3))
                @play_font.draw_text_rel('RESET', button.x, button.y + 5, ZOrder::MIDDLE, 0.5, 0.5, 1.0, 1.0, Gosu::Color::BLACK)
            elsif button.name == 'quit'
                button.img.draw_rot(button.x, button.y, ZOrder::MIDDLE, 0, 0.5, 0.5, (200.0/395), (2.0/3))
                @play_font.draw_text_rel('QUIT', button.x, button.y + 5, ZOrder::MIDDLE, 0.5, 0.5, 1.0, 1.0, Gosu::Color::BLACK)
            else
                button.img.draw_rot(button.x, button.y, ZOrder::MIDDLE)
            end
        end
    end

    def draw_fish()
        for fish in @fish
            fish.img.draw_rot(fish.x, fish.y, ZOrder::MIDDLE, 0, 0.5, 0.5, fish.factor, 1.0)
            if fish.factor == -1.0
                case fish.name
                when 'angelfish'
                    x, y = 109, 43
                when 'butterflyfish'
                    x, y = 201, 17
                when 'clownfish'
                    x, y = 110, 65
                when 'jellyfish'
                    x, y = 122, 126
                when 'lanternfish'
                    x, y = 133, 83
                when 'pufferfish'
                    x, y = 142, 103
                when 'seahorse'
                    x, y = 52, 51
                when 'shark'
                    x, y = 221, 38
                when 'trout'
                    x, y = 234, 63
                end
                x = fish.width - (x + @flag.width)
                @flag.draw(fish.x - fish.width/2 + x, fish.y - fish.height/2 + y, ZOrder::MIDDLE)
            end
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

    def truncate_text(text, limit)
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
                lines = truncate_text(@question.quest, limit)                
                lines.each_with_index do |line, index|
                    @large_font.draw_text_rel(line.join(' '), WIDTH/2, 180 + @large_font.height * index, ZOrder::MIDDLE, 0.5, 0.5)
                end
            else
                @large_font.draw_text_rel(@question.quest, WIDTH/2, 200, ZOrder::MIDDLE, 0.5, 0.5)
            end
            for index in 0...4
                choice = @question.choices[index]
                text_width = find_text_width(choice)
                limit = @choice_boxes[index].width - 80
                if text_width > limit
                    lines = truncate_text(choice, limit)                
                    lines.each_with_index do |line, i|
                        puts line.join(' ')
                        @large_font.draw_text_rel(line.join(' '), @choice_boxes[index].x, @choice_boxes[index].y - 15 + (@large_font.height + 5) * i, ZOrder::TOP, 0.5, 0.5, 1, 1, Gosu::Color::BLACK)
                    end
                else
                    @large_font.draw_text_rel(choice, @choice_boxes[index].x, @choice_boxes[index].y, ZOrder::TOP, 0.5, 0.5, 1.0, 1.0, Gosu::Color::BLACK)
                end
            end
        end
    end

    def draw_score()
        @board_img.draw(0, 0, ZOrder::MIDDLE, 0.18, 0.12)
        @play_font.draw_text("Score: #{@score}", 20, 20, ZOrder::TOP, 1.0, 1.0, Gosu::Color::BLACK)
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
        @font.draw_text("Time: #{Gosu.milliseconds / 1000}   Elapsed time: #{@elapsed_time}", 10, 640, z = ZOrder::TOP, 1.0, 1.0, Gosu::Color::WHITE)
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
            @title.draw_rot(WIDTH/2, 266, ZOrder::MIDDLE)
            @play_text.draw_rot(WIDTH/2, 610, ZOrder::TOP, 0, 0.5, 0.5, 1, 1, Gosu::Color::BLACK)
        when Screen_State::Play_Stage
            @aim.draw(@aim_x, @aim_y, ZOrder::TOP)
            draw_fish()
            draw_weapon()
            draw_score()
        when Screen_State::Quiz
            draw_question()
        end        
        draw_buttons()
        
        # credit
        @font.draw_text("Swinburne University of Technology - Swinburne Vietnam, Danang Campus\nMade by TMinh, with the help of Dr Tin, Dr Loc & Ms Ngan", 0, HEIGHT - @font.height*2, z = ZOrder::TOP, 1.0, 1.0, Gosu::Color::WHITE)
        # draw_spec()
        # main() if __FILE__ == $0
    end

    def needs_cursor?; true; end
end

def main()
    CannonCasters.new.show
end

main() if __FILE__ == $0