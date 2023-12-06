require 'gosu'

module ZOrder
    BACKGROUND, MIDDLE, TOP = *0..2
end

WIDTH = 1280
HEIGHT = 720

class CannonCasters < Gosu::Window
    def initialize
        super(WIDTH, HEIGHT, false)
        self.caption = 'Cannon Casters'

    end
end
print("%03d" % 2)