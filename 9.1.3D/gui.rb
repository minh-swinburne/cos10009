require 'gosu'

BACKGROUND_COLOR = Gosu::Color.new(0xFF202020)
ROW_COLOR = Gosu::Color.new(0xFF101010)
ELEMENT_COLOR = Gosu::Color.new(0xFF555555)
TOP_COLOR = Gosu::Color.new(0xFF1EB1FA)
BOTTOM_COLOR = Gosu::Color.new(0xFF1D4DB5)
HIGHLIGHTED = Gosu::Color.new(0x22FFFFFF)

TRANSPARENT = Gosu::Color.new(0x00FFFFFF)
WHITE = Gosu::Color::WHITE
GRAY = Gosu::Color.new(0xFFC3C3C3)
BLACK = Gosu::Color::BLACK

WIDTH = 1920/2
HEIGHT = 1080/2

MENU = 250
ART_DIM = 70
BUTTON_DIM = 35
SMALL_BUTTON_DIM = INDENT = 15

CREATE_WIDTH = 81
CREATE_HEIGHT = 50
PANEL_WIDTH = WIDTH - MENU
PANEL_HEIGHT = 100
BAR_HEIGHT = 10
ROW_HEIGHT = 50

TRACK_COLUMN = 280
ARTIST_COLUMN = 560
GENRE_COLUMN = 720
RELEASE_COLUMN = 820


LARGE_TEXT = Gosu::Font.new(30, {:bold => true})
MEDIUM_TEXT = Gosu::Font.new(20)
SMALL_TEXT = Gosu::Font.new(15) # for developer mode

module ZOrder
    BACKGROUND, PLAYER, UI = *0..2
end

module State
    NORMAL = Gosu::Color.new(0x00FFFFFF)
    HOVERED = Gosu::Color.new(0x33FFFFFF)
    SELECTED = Gosu::Color.new(0x66FFFFFF)
end

class Element
    attr_accessor :x, :y, :width, :height, :colour, :state, :z, :name

    def initialize(x, y, width, height, colour, state, z, name)
        @name = name
        @x = x
        @y = y
        @width = width
        @height = height
        @colour = colour
        @state = state
        @z = z
    end
end