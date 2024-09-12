require_relative 'input_functions'

module Genre
    POP, CLASSIC, JAZZ, ROCK = *1..4
end

$genre_names = ['Null', 'Pop', 'Classic', 'Jazz', 'Rock']

class Album
	attr_accessor :artist, :title, :rls_date, :genre, :tracks
	def initialize (artist, title, rls_date, genre, tracks)
		@artist = artist
		@title = title
		@rls_date = rls_date
		@genre = genre
		@tracks = tracks
	end
end

class Track
	attr_accessor :name, :location
	def initialize (name, location)
		@name = name
		@location = location
	end
end

# Reads in and returns a single track from the given file
def read_track(music_file)
	name = music_file.gets.chomp
    loc = music_file.gets.chomp
    track = Track.new(name, loc)
    return track
end

# Returns an array of tracks read from the given file
def read_tracks(music_file)
	count = music_file.gets.to_i()
  	tracks = Array.new()
    index = 0
    while index < count
      	track = read_track(music_file)
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
		print("Track #{index+1}: ")
        print_track(tracks[index])
        index += 1
    end
end

# Reads in and returns a single album from the given file, with all its tracks
def read_album(music_file)
  	# read in all the Album's fields/attributes including all the tracks
	album_artist = music_file.gets.chomp
	album_title = music_file.gets.chomp
	album_rls_date = music_file.gets.chomp
	album_genre = music_file.gets.chomp
	tracks = read_tracks(music_file)
	album = Album.new(album_artist, album_title, album_rls_date, album_genre, tracks)
	return album
end

# Returns an array of albums read from the given file, with all tracks for each album
def read_albums(music_file)
	count = music_file.gets.to_i
	albums = Array.new()
	index = 0
	while index < count
		album = read_album(music_file)
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
	puts("Genre is #{album.genre.to_s} - #{$genre_names[album.genre.to_i]}")
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
		print("#{index+1}. ")
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
	while index < $genre_names.length
		puts("#{index}. #{$genre_names[index]}")
		index += 1
	end
	choice = read_integer_in_range("Please enter your choice:", 1, $genre_names.length)
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
  		read_string("All #{$genre_names[choice]} albums displayed. Press enter to continue")
	else
		read_string("No #{$genre_names[choice]} albums found. Press enter to continue")
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
	puts("Genre is #{album.genre.to_s} - #{$genre_names[album.genre.to_i]}")
    read_string('Press enter to return to the main menu')
end

def main()
	loaded = false	# Requires albums to be loaded by option 1 before proceeding with option 2 or 3
	finished = false	# Keeps the user in the main menu until exiting with option 5
  	begin
    	puts('Main Menu:')
		puts('1. Read in Albums')
		puts('2. Display Albums')
		puts('3. Select an Album to play')
		puts('4. Update an existing Album')
	  	puts('5. Exit the application')
    	choice = read_integer("Please enter your choice:")
    	case choice
    	when 1
			file_name = read_string("Please enter the filename:")	# Reads in the filename of the albums information file
            path = File.join(File.dirname(__FILE__), file_name)
			music_file = File.new(path, "r")
			albums = read_albums(music_file)
			#print_album(album)
			music_file.close()
			loaded = true
			read_string('You read in albums. Press enter to continue')
    	when 2
			if loaded
				puts()
	      		display_albums(albums)
			else
				read_string('No albums to display, please read in albums first. Press enter to continue')
			end
		when 3
			if loaded
				puts()
	      		play_album(albums)
			else
				read_string('No albums to play, please read in albums first. Press enter to continue')
			end
        when 4
			if loaded
				puts()
	      		update_album(albums)
			else
				read_string('No albums to update, please read in albums first. Press enter to continue')
			end
		when 5
			puts()
      		finished = true
    	else
      		puts("Please select again")
			puts()
    	end
  	end until finished
end

main() if __FILE__ == $0
