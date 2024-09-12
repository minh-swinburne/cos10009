require_relative 'input_functions'

# Task 6.1 T - use the code from 5.1 to help with this

class Track
	attr_accessor :name, :location

	def initialize (name, location)
		@name = name
		@location = location
	end
end

# Reads in and returns a single track from the given file

def read_track(music_file)
	# fill in the missing code
    name = music_file.gets.chomp
    loc = music_file.gets.chomp
    track = Track.new(name, loc)
    return track
end

# Returns an array of tracks read from the given file

def read_tracks(music_file)
	
	count = music_file.gets().chomp.to_i()
  	tracks = Array.new()

  # Put a while loop here which increments an index to read the tracks
    index = 0
    while index < count
      	track = read_track(music_file)
  	    tracks << track
        index += 1
    end
	return tracks
end

# Takes an array of tracks and prints them to the terminal

def print_tracks(tracks)
	# print all the tracks use: tracks[x] to access each track.
    index = 0
    while index < tracks.length
        print_track(tracks[index])
        index += 1
    end
end

# Takes a single track and prints it to the terminal
def print_track(track)
    # track.title and track.file_location are invalid attributes of the Track class so we need to change to .name and .location
  	puts(track.name)
	puts(track.location)
end


# search for track by name.
# Returns the index of the track or -1 if not found
def search_for_track_name(tracks, search_string)
    index = 0
    found_index = -1
# Put a while loop here that searches through the tracks
# Use the read_string() function from input_functions.
# NB: you might need to use .chomp to compare the strings correctly

# Put your code here.
    while index < tracks.length
        if tracks[index].name == search_string
            found_index = index
        end
        index += 1
    end
    return found_index
end


# Reads in an Album from a file and then prints all the album
# to the terminal

def main()
    path = File.join(File.dirname(__FILE__), "album.txt")
  	music_file = File.new(path, "r")
	tracks = read_tracks(music_file)
    print_tracks(tracks)
  	music_file.close()

  	search_string = read_string("Enter the track name you wish to find: ")
  	index = search_for_track_name(tracks, search_string)
  	if index > -1
   		puts("Found #{tracks[index].name}\n at #{index}")
  	else
    	puts("Entry not Found")
  	end
end

main()

