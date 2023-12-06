require 'gosu'
require './input_functions'

  module Genre
    POP, CLASSIC, JAZZ, ROCK = *1..4
  end
  
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

  class ArtWork
	attr_accessor :bmp

	def initialize (file)
		@bmp = Gosu::Image.new(file)
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
  
  # Reads in and returns a single track from the given file
  def read_track(dir, music_file, album_id, index)
      id = "#{album_id}_#{('%02d' % index)}"
      name = music_file.gets.chomp
      loc = dir + name.split().join('-') + '.mp3'
      track = Track.new(id, name, loc)
      return track
  end
  
  # Returns an array of tracks read from the given file
  def read_tracks(dir, music_file, album_id)
      count = music_file.gets.to_i()
        tracks = Array.new()
      index = 0
      while index < count
            track = read_track(dir, music_file, album_id, index)
            tracks << track
          index += 1
      end
      return tracks
  end
  
  # Takes a single track and prints it to the terminal
  def print_track(track)
        puts(track.name)
      puts("Location: #{track.location}")
  end
  
  # Takes an array of tracks and prints them to the terminal
  def print_tracks(tracks)
      # print all the tracks using tracks[index] to access each track.
      index = 0
      while index < tracks.length
          print("Track ID#{tracks[index].id}: ")
          print_track(tracks[index])
          index += 1
      end
  end
  
  # Reads in and returns a single album from the given file, with all its tracks
  def read_album(dir, index)
        # read in all the Album's fields/attributes including all the tracks
      file_name = 'info.txt'
      music_file = File.new(dir + file_name)
      album_id = ('%02d' % index)
      album_artist = music_file.gets.chomp
      album_title = music_file.gets.chomp
      album_rls_date = music_file.gets.chomp
      album_genre = music_file.gets.chomp
      album_artwork = ArtWork.new(dir + music_file.gets.chomp).bmp
      tracks = read_tracks(dir, music_file, album_id)
      music_file.close()
      album = Album.new(album_id, album_artist, album_title, album_rls_date, album_genre, album_artwork, tracks)
      return album
  end
  
  # Returns an array of albums read from the given file, with all tracks for each album
  def read_albums(dir, count)
      albums = Array.new()
      index = 0
      while index < count
          dir = "albums/album#{index}/"
          album = read_album(dir, index)
          albums << album
          index += 1
      end
      return albums
  end
  
  # Takes a single album and prints it to the terminal along with all its tracks
  def print_album(album)
      puts(album.title)
      puts("Artist: #{album.artist}")
      puts("Release Date: #{album.rls_date}")
      puts("Genre is #{album.genre.to_s} - #{GENRE_NAMES[album.genre.to_i]}")
      # print out the tracks
      print_tracks(album.tracks)
  end
  
  # Displays albums, whether all or by genre
  def display_albums(albums)
      returned = false # Keeps the user in this menu until returning to the main menu with option 3
      begin
          puts('Display Albums Menu:')
          puts('1. Display All Albums')
          puts('2. Display Albums by Genre')
          puts('3. Return to Main Menu')
            choice = read_integer("Please enter your choice:")
            case choice
            when 1
              puts()
              display_all(albums)
            when 2
              puts()
              display_by_genre(albums)
            when 3
              puts()
              returned = true
            else	# invalid input case
              puts "Please select again"
              puts()
            end
      end until returned
  end
  
  # Lists all albums with a primary key, or album number (technically just their position in the albums array)
  def display_all(albums)
      index = 0
      while index < albums.length
          print("ID#{albums[index].id}. ")
          print_album(albums[index])
          puts()
          index += 1
      end
        read_string("All albums displayed. Press enter to continue")
  end
  
  # Requires the user to input a genre number. If valid, prints all the albums in that genre along with tracks
  def display_by_genre(albums)
      puts('Available Genres:') # Lists all available genres
      index = 1
      while index < GENRE_NAMES.length
          puts("#{index}. #{GENRE_NAMES[index]}")
          index += 1
      end
      choice = read_integer_in_range("Please enter your choice:", 1, GENRE_NAMES.length)
      puts()
      count = 0 # Counts the number of albums in that particular genre
      index = 0
      while index < albums.length
          if albums[index].genre.to_i == choice	# Prints out albums matching that genre
              print("#{count+1}. ")
              print_album(albums[index])
              puts()
              count += 1
          end
          index += 1
      end
      unless count == 0
            read_string("All #{GENRE_NAMES[choice]} albums displayed. Press enter to continue")
      else
          read_string("No #{GENRE_NAMES[choice]} albums found. Press enter to continue")
      end
  end
  
  # Asks for an album key, then a track number. If both valid, play the track (pretended)
  def play_album(albums)
      key = read_integer_in_range('Please enter the primary key for an album:', 1, albums.length)
      album = albums[key-1]
      tracks = album.tracks
      puts()
      puts("Found album #{album.title} (#{album.artist}, #{album.rls_date}):")	
      unless tracks.length == 0
          print_tracks(tracks)
          choice = read_integer_in_range('Please enter a track number:', 1, tracks.length)
          track = tracks[choice-1]
          puts("Playing track #{track.name} from album #{album.title}")
          sleep(5)	# Delay for 5 seconds as a pretention of 'track playing'
          read_string('Track played. Press enter to continue')
      else	# Chosen album has no tracks
              read_string('No tracks to play. Press enter to continue')
      end
  end
  
  # Updates an existing album's title or genre (one thing each time)
  def update_album(albums)
      display_all(albums) # Lists all albums before asking for a key
      key = read_integer_in_range('Please enter the primary key of the album your want to update:', 1, albums.length)
      album = albums[key-1]
      puts("Chose album #{album.title} (#{album.artist}, #{album.rls_date}).\n")
      puts('Update Menu:')
      puts('1. Update Album Title')
      puts('2. Update Album Genre')
      choice = read_integer_in_range("Please enter your choice:", 1, 2)
      case choice
      when 1  # Updates title
          new_title = read_string('Please enter a new title for the album:')
          album.title = new_title
      when 2  # Updates genre
          new_genre = read_string('Please enter a new genre for the album:')
          album.genre = new_genre
      end
      puts()
      puts('Updated album:')  # Displays updated album
      puts("Title: #{album.title}")
      puts("Artist: #{album.artist}")
      puts("Release Date: #{album.rls_date}")
      puts("Genre is #{album.genre.to_s} - #{GENRE_NAMES[album.genre.to_i]}")
      read_string('Press enter to return to the main menu')
  end

def load_albums()
    album_dirs = Dir.children("albums")
    albums = read_albums("albums", album_dirs.length)
    return albums
end

def main()
    albums = load_albums()
    display_all(albums)
end

main() if __FILE__ == $0