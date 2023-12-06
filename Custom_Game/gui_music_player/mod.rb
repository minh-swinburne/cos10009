class Audiot
    attr_accessor :position
    def initialize(filename); end
    def play(looping=false); end
    def pause; end
    def paused?; end
    def stop; end
    def playing?; end
    def reposition(0); end
end