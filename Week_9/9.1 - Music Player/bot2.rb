require 'rubygems'
require 'gosu'

TOP_COLOR = Gosu::Color.new(0xFF1EB1FA)
BOTTOM_COLOR = Gosu::Color.new(0xFF1D4DB5)

module ZOrder
  BACKGROUND, PLAYER, UI = *0..2
end

class ArtWork
  attr_accessor :bmp

  def initialize(file)
    @bmp = Gosu::Image.new(file)
  end
end

class Album
  attr_accessor :title, :artwork, :tracks

  def initialize(title, artwork)
    @title = title
    @artwork = artwork
    @tracks = []
  end
end

class Track
  attr_accessor :title, :location

  def initialize(title, location)
    @title = title
    @location = location
  end
end

class MusicPlayerMain < Gosu::Window
  def initialize
    super 600, 800
    self.caption = "Music Player"

    @albums = []
    read_albums_from_file("music.txt")

    @current_album = nil
    @current_track = nil

    @track_font = Gosu::Font.new(20)

    @play_button = Gosu::Image.new("images/play.png")
    @pause_button = Gosu::Image.new("images/pause.png")
    @next_button = Gosu::Image.new("images/next.png")
    @prev_button = Gosu::Image.new("images/prev.png")

    @play_button_x = 200
    @play_button_y = 600

    @progress_bar_x = 250
    @progress_bar_y = 600
    @progress_bar_width = 200
    @progress_bar_height = 20

    @progress = 0.0
    @playing = false
  end

  def read_albums_from_file(file)
    File.open(file, "r") do |f|
      num_albums = f.readline.to_i

      num_albums.times do
        artist = f.readline.chomp
        album_title = f.readline.chomp
        artwork_file = f.readline.chomp
        num_tracks = f.readline.to_i

        album = Album.new(album_title, ArtWork.new(artwork_file))

        num_tracks.times do
          track_title = f.readline.chomp
          track_location = f.readline.chomp
          album.tracks << Track.new(track_title, track_location)
        end

        @albums << album
      end
    end
  end

  def draw_albums
    x = 50
    y = 100

    @albums.each do |album|
      album.artwork.bmp.draw(x, y, ZOrder::UI)
      @track_font.draw(album.title, x, y + album.artwork.bmp.height + 10, ZOrder::UI, 1.0, 1.0, Gosu::Color::BLACK)

      y += album.artwork.bmp.height + 100
    end
  end

  def draw_tracks(album)
    x = 400
    y = 100

    album.tracks.each_with_index do |track, index|
      if track == @current_track
        @track_font.draw("Now playing: #{track.title}", x, y, ZOrder::UI, 1.0, 1.0, Gosu::Color::GREEN)
      else
        @track_font.draw(track.title, x, y, ZOrder::UI, 1.0, 1.0, Gosu::Color::BLACK)
      end

      y += 30
    end
  end

  def draw_background
    draw_quad(0, 0, TOP_COLOR,
              width, 0, TOP_COLOR,
              0, height, BOTTOM_COLOR,
              width, height, BOTTOM_COLOR,
              ZOrder::BACKGROUND)
  end

  def draw
    draw_background
    draw_albums

    if @current_album
      draw_tracks(@current_album)
    end

    if @playing
      @pause_button.draw(@play_button_x, @play_button_y, ZOrder::UI)
    else
      @play_button.draw(@play_button_x, @play_button_y, ZOrder::UI)
    end

    @next_button.draw(@play_button_x + 100, @play_button_y, ZOrder::UI)
    @prev_button.draw(@play_button_x - 100, @play_button_y, ZOrder::UI)

    draw_progress_bar
  end

  def draw_progress_bar
    progress_width = @progress * @progress_bar_width

    Gosu.draw_rect(@progress_bar_x, @progress_bar_y, progress_width, @progress_bar_height, Gosu::Color::GREEN, ZOrder::UI)
    Gosu.draw_rect(@progress_bar_x + progress_width, @progress_bar_y, @progress_bar_width - progress_width, @progress_bar_height, Gosu::Color::GRAY, ZOrder::UI)
  end

  def needs_cursor?
    true
  end

  def button_down(id)
    case id
    when Gosu::MsLeft
      handle_click
    end
  end

  def handle_click
    if @playing
      @playing = false
      # Pause the current track
    else
      if @current_album
        @playing = true
        # Play the current track
      end
    end
  end

  def update
    # Update the progress bar based on the current track's playback position
    if @playing
      @progress += 0.01
      @progress = 0.0 if @progress > 1.0
    end
  end
end

MusicPlayerMain.new.show if __FILE__ == $0
