require 'gosu'

module Genre
    POP, CLASSIC, JAZZ, ROCK = *1..4
end

IMAGE_DIR = 'images'
ALBUM_DIR = 'albums'
GENRE_NAMES = ['Null', 'Pop', 'Classic', 'Jazz', 'Rock']

class Album
    attr_accessor :id, :artist, :title, :rls_date, :genre, :artwork, :tracks
    def initialize (id, artist, title, rls_date, genre, artwork, tracks)
        @id = id
        @artist = artist
        @title = title
        @rls_date = rls_date
        @genre = genre
        @artwork = artwork
        @tracks = tracks
    end
end

class Track
    attr_accessor :id, :name, :location
    def initialize (id, name, location)
        @id = id
        @name = name
        @location = location
    end
end

def get_file_path(filename)
    return File.join(File.dirname(__FILE__), filename)
end

def read_image(filename)
    return Gosu::Image.new(get_file_path(File.join(IMAGE_DIR, filename)))
end

def read_track(info_file, album_id, track_index)
    track_id = "#{album_id}_#{('%02d' % track_index)}"
    track_name = info_file.gets.chomp
    filename = track_name.split().join('-') + '.mp3'
    track_location = get_file_path(File.join(ALBUM_DIR, album_id, filename))
    return Track.new(track_id, track_name, track_location)
end

def read_tracks(info_file, album_id)
    tracks = Array.new
    track_count = info_file.gets.to_i
    track_index = 0
    while track_index < track_count
        track = read_track(info_file, album_id, track_index)
        tracks << track
        track_index += 1
    end
    return tracks
end

def read_album(album_index)
    album_id = '%02d' % album_index
    info_file = File.new(get_file_path(File.join(ALBUM_DIR, album_id, 'info.txt')))

    artist = info_file.gets.chomp
    title = info_file.gets.chomp
    rls_date = info_file.gets.chomp
    genre = info_file.gets.to_i
    artwork_filename = info_file.gets.chomp
    artwork = read_image(artwork_filename)
    tracks = read_tracks(info_file, album_id)

    album = Album.new(album_id, artist, title, rls_date, genre, artwork, tracks)
    info_file.close
    return album
end

def read_albums
    albums = Array.new
    album_count = Dir.children(get_file_path(ALBUM_DIR)).length
    album_index = 1
    while album_index < album_count
        album = read_album(album_index)
        albums << album
        album_index += 1
    end
    return albums
end

def main
    puts get_file_path('images/album.bmp')
    artwork = read_image('custom_list.bmp')
    # puts artwork
    albums = read_albums()
    albums.each do |album|
        puts "Album: #{album.title}"
        puts "Artist: #{album.artist}"
        puts "Release Date: #{album.rls_date}"
        puts "Genre: #{GENRE_NAMES[album.genre]}"
        album.tracks.each do |track|
            puts "Track: #{track.name}"
            puts "Location: #{track.location}"
        end
    end
end

main if __FILE__ == $0