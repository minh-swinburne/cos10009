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

class Track
  attr_reader :title, :location

  def initialize(title, location)
    @title = title
    @location = location
  end
end

class Album
  attr_reader :title, :artist, :artwork, :tracks

  def initialize(title, artist, artwork)
    @title = title
    @artist = artist
    @artwork = ArtWork.new(artwork)
    @tracks = []
  end

  def add_track(title, location)
    @tracks << Track.new(title, location)
  end
end

class MusicPlayerMain < Gosu::Window
  TRACK_LEFT_X = 150
  ALBUM_TOP_Y = 150
  ALBUM_SPACING = 200

  def initialize
    super(600, 800)
    self.caption = "Music Player"
    @font = Gosu::Font.new(20)
    @track_font = Gosu::Font.new(16)
    @albums = []
    load_albums_and_tracks("music.txt")
    @current_album = @albums.first
    @current_track_index = 0
    @song = nil
  end

  def load_albums_and_tracks(filename)
    file = File.open(filename, "r")
    num_albums = file.gets.to_i
    num_albums.times do
      artist = file.gets.chomp
      title = file.gets.chomp
      artwork = file.gets.chomp
      album = Album.new(title, artist, artwork)
      num_tracks = file.gets.to_i
      num_tracks.times do
        track_title = file.gets.chomp
        track_location = file.gets.chomp
        album.add_track(track_title, track_location)
      end
      @albums << album
    end
    file.close
  end

  def draw
    draw_background
    draw_albums
    draw_track_list
  end

  def draw_background
    draw_quad(0, 0, TOP_COLOR,
              width, 0, TOP_COLOR,
              0, height, BOTTOM_COLOR,
              width, height, BOTTOM_COLOR,
              ZOrder::BACKGROUND)
  end

  def draw_albums
    x = 50
    @albums.each do |album|
      if album == @current_album
        draw_current_album(album, x, ALBUM_TOP_Y)
      else
        draw_album(album, x, ALBUM_TOP_Y)
      end
      x += ALBUM_SPACING
    end
  end

  def draw_current_album(album, x, y)
    draw_album(album, x, y)
    album.artwork.bmp.draw(x + 10, y + 10, ZOrder::PLAYER)
    @font.draw(album.title, x + 10, y + 170, ZOrder::UI, 1.0, 1.0, Gosu::Color::BLACK)
    @font.draw(album.artist, x + 10, y + 200, ZOrder::UI, 1.0, 1.0, Gosu::Color::BLACK)
  end

  def draw_album(album, x, y)
    album.artwork.bmp.draw(x + 10, y + 10, ZOrder::PLAYER, 0.5, 0.5)
    @font.draw(album.title, x + 10, y + 170, ZOrder::UI, 0.6, 0.6, Gosu::Color::BLACK)
    @font.draw(album.artist, x + 10, y + 200, ZOrder::UI, 0.6, 0.6, Gosu::Color::BLACK)
  end

  def draw_track_list
    y = 400
    @current_album.tracks.each_with_index do |track, i|
      if i == @current_track_index
        @track_font.draw(track.title, TRACK_LEFT_X, y, ZOrder::UI, 1.0, 1.0, Gosu::Color::YELLOW)
      else
@track_font.draw(track.title, TRACK_LEFT_X, y, ZOrder::UI, 1.0, 1.0, Gosu::Color::BLACK)
      end
      y += 20
    end
  end

  def button_down(id)
    case id
    when Gosu::MsLeft
      if area_clicked?(0, 0, width, ALBUM_TOP_Y - 10)
        album_index = ((mouse_x - 50) / ALBUM_SPACING).to_i
        @current_album = @albums[album_index]
        @current_track_index = 0
        stop_song
      elsif area_clicked?(TRACK_LEFT_X - 10, 380, width, height)
        track_index = ((mouse_y - 380) / 20).to_i
        play_track(track_index)
      end
    end
  end

  def area_clicked?(left_x, top_y, right_x, bottom_y)
    mouse_x > left_x && mouse_x < right_x && mouse_y > top_y && mouse_y < bottom_y
  end

  def stop_song
    if @song
      @song.stop
      @song = nil
    end
  end

  def play_track(index)
    stop_song
    track = @current_album.tracks[index]
    @song = Gosu::Song.new(track.location)
    @song.play(false)
    @current_track_index = index
  end
end

MusicPlayerMain.new.show if __FILE__ == $0