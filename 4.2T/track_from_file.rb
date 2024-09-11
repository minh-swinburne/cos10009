# put your code here:

class Track
    attr_accessor :name, :location
end

def read_track(a_file)
    track = Track.new()
    track.name = a_file.gets
    track.location = a_file.gets
    return track
end

def print_track(track)
    puts("Track name: #{track.name}")
    puts("Track location: #{track.location}")
end

def main()
    directory = File.dirname(__FILE__)
    filename = "track.txt"
    file = File.new(File.join(directory, filename), "r")
    track = read_track(file)
    print_track(track)
end

main() if __FILE__ == $0 # leave this 