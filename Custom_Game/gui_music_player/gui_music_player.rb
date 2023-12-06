require 'rubygems'
require 'gosu'
require './file_handling'
require 'audioinfo'

# require gem 'ruby-audioinfo' (0.5.5)

# Main features:
# 1. Display playlists in 4-panel page, allowing iterating within limit of pages number
# 2. Automatically detect and load albums correctly formatted as following:
#     - album directory is put inside the folder 'albums' and named 'album<number>' with <number> as a unique natural number (for example: album0, album1...)
#     - each album has an 'info.txt' file that follows the format:
#         <album artist>
#         <album title>
#         <release date>
#         <genre>
#         <artwork file name>
#         <number of tracks>
#         <name of first track>
#         <name of second track(if there is)>
#         ...
#     - each album also includes an artwork file with the same name as written in 'info.txt', and tracks file named after the track name, with whitespaces replaced with hyphens (for example, track 'My Love' will have its file named 'My-Love.mp3')
#     - when loaded into the program, each track will be assigned a unique ID in the format: <album order>(2)_<track order>(2), for example '01_00' is the ID for the first track in the second album. This serves the purpose of querying for the album the track is in, even when it's played from a custom playlist.
# 3. Each element hovered by the mouse will be highlighted. Selected playlist and track will be hightlighted more brightly
# 4. When selecting a playlist, its tracks will be displayed with information (name, artist, genre, release). Upon clicking on a track, it will start playing (stop any previously playing track), and show the playbar with buttons.
# 5. Play/pause the current track with the pause-play button on the playbar, stop playing (playbar will be hidden), turn on/off the repeat mode for the current playing track
# 6. Auto-playing, skip/rewind to next/previous track in the selected playlist (including albums, favourite list and custom playlists)
# 7. Add the current track to the favourite list (the first playlist) with the heart-shaped button on the playbar. On the tracks panel, there are also non-interactive heart_shaped elements indicating whether the respective track is in the favourite playlist.
# 8. Create a new custom playlist with the "NEW" button on the top left corner. Upon clicking, the program will enter the Creative Mode, which allows the user to click on wanted tracks without interrupting the possibly playing track. When done, click on that button, now named "OK".
# 9. Sort albums by artist (by alphabet), genre (by genre order: Pop, Classic, Jazz, Rock) or release date (from earliest to latest) without changing the order of favourite and custom playlists.

# Student Name: Nguyen Thi Thanh Minh (Luca)
# Student ID: 104169617


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
YELLOW = Gosu::Color.new(0xFFFFC933)
PURPLE = Gosu::Color.new(0xFFB266FF)

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

class GUIMusicPlayer < Gosu::Window
    def initialize
        super WIDTH, HEIGHT, false
        self.caption = "GUI Music Player"
        @cursor = Gosu::Image.new('images/cursor.png')

        @elements = []
        @playlists = []
        @favourite_list = Album.new(99, '', 'Favourite', 0, 0, Gosu::Image.new('images/favourite_list.bmp'), Array.new())
        # load albums from a system of folders in required format
        @albums = load_albums()
        @playlists << @favourite_list
        @playlists += @albums
        @ini_length = @playlists.length
        # calculate the total pages of 4-playlist display.
        # if the total number of playlists is not divisible by 4, the remainder part will be turned into 1
        @max_playlist_page = @playlists.length/4 + (((@playlists.length % 4) != 0)?1:0)
        # @max_playlist_page = 5 (TEST PURPOSE)

        @repeat_song = false
        @show_playbar = false
        @creative_mode = false  # for adding new custom playlists
        @stopped = false

        @selected_playlist = nil
        @selected_track = nil

        @playlist_page = 1
        @track_page = 1
        @time = Gosu.milliseconds
        @pause_play = 'pause'
    end

    # add a new custom playlist by entering the creative mode when clicking on the "New Playlist" button, until reclicking on the "Done" button
    # update
    def add_playlist()
        if @creative_mode
            # create a new list to add tracks to
            @new_list = []
            @custom_no = @playlists.length - @ini_length + 1
        else
            # initialize a new playlists and append it to the list of all playlists
            @playlists << Album.new(99 - @custom_no, '', "Custom List #{@custom_no}", 0, 0, Gosu::Image.new('images/custom_list.bmp'), @new_list)
            # reassign total playlists pages
            @max_playlist_page = @playlists.length/4 + (((@playlists.length % 4) != 0)?1:0)
        end
    end

    def sort_albums(attribute)
        albums = @playlists[1, @albums.length]  # = slice(start, length)
        i = 1
        while i < @albums.length
            j = i + 1
            while j < @albums.length + 1
                case attribute
                when 'artist'
                    if @playlists[i].artist > @playlists[j].artist
                        @playlists[i], @playlists[j] = @playlists[j], @playlists[i]
                    end
                when 'genre'
                    if @playlists[i].genre.to_i > @playlists[j].genre.to_i
                        @playlists[i], @playlists[j] = @playlists[j], @playlists[i]
                    end
                when 'release'
                    if @playlists[i].rls_date.to_i > @playlists[j].rls_date.to_i
                        @playlists[i], @playlists[j] = @playlists[j], @playlists[i]
                    end
                end
                j += 1
            end
            i += 1
        end
    end

    # Reset the current elements list every cycle to avoid overlap
    # update
    def initialize_elements()
        @elements = Array.new()
        create_playlists_panel()
        if @selected_playlist
            create_tracks_panel()
        end
        if @show_playbar
            create_playbar()
            create_progress_bar()
        end
    end

    # add a new element (an interactive "image" on the screen) to the elements list
    def add_element(*args)
        element = Element.new(*args)
        @elements << element
        return element
    end

    # draw all elements in the list onto the screen, including buttons and panels. Except for the "New Playlist" button, all buttons require loading an image
    # draw
    def draw_elements()
        for element in @elements do
            draw_rect(element.x,element.y,element.width,element.height,element.colour,element.z)
            draw_rect(element.x,element.y,element.width,element.height,element.state,element.z)
            if element.name['button']
                draw_buttons(element)
            end
        end
    end

    # load an image based on the button's name and draw it
    # draw
    def draw_buttons(element)
        path = "images/#{element.name}.png"
        img = Gosu::Image.new(path)
        img.draw(element.x, element.y, element.z)
    end

    # return true if mouse position is within an element
    def mouse_at_element(element)
        leftX = element.x
        rightX = leftX + element.width
        topY = element.y
        bottomY = topY + element.height
        if (mouse_x > leftX and mouse_x < rightX) and (mouse_y > topY and mouse_y < bottomY)
			true
		else
			false
		end
    end

    # return which (only one) element the mouse is currently on, or nil
    def iterate_element()
        for element in @elements do
            if mouse_at_element(element)
                element.state = State::HOVERED
                return element
            end
        end
        return nil # fall back
    end

    # this is basically the button_down(Gosu::MsLeft) method, but modularised to avoid overnesting
    def click_event(element)
        # select a playlist
        if element.name["playlist_display_area_"]
            index = element.name[-1].to_i + (@playlist_page - 1)*4
            @selected_playlist = @playlists[index]
            tracks_number = @selected_playlist.tracks.length
            @max_track_page = tracks_number/5 + (((tracks_number % 5) != 0)?1:0)
            @track_page = 1
        end
        # select track to play (normal) or to add to a new playlist (creative mode)
        if element.name["track_display_area_"]
            @id = element.name[-1].to_i + (@track_page - 1)*5
            @selected_track = @selected_playlist.tracks[@id]
            if @creative_mode 
                if not @new_list.include?(@selected_track)
                    @new_list << @selected_track
                end
            else
                @playing_playlist = @selected_playlist
                play_track()
            end
        end

        if element.name['volume_level_']
            level = element.name[-1].to_f + 1
            volume = level / 10
            @music_player.volume = volume
        end 

        # change playlist page, previous or next
        if element.name == 'playlist_next_button' and @playlist_page < @max_playlist_page
            @playlist_page += 1
        elsif element.name == 'playlist_prev_button' and @playlist_page > 1
            @playlist_page -= 1
        end

        # change track page
        if element.name == 'track_next_button' and @track_page < @max_track_page
            @track_page += 1
        elsif element.name == 'track_prev_button' and @track_page > 1
            @track_page -= 1
        end

        # when clicking buttons
        case element.name
        when 'pause_button'     # pause currently playing track
            @music_player.pause()
            @pause_play = 'play'
        when 'play_button'      # play/resume current track
            @music_player.play(@repeat_song)
            @pause_play = 'pause'
        when'stop_button'       # stop playing and hide the playbar
            @music_player.stop()
            @stopped = true
            @show_playbar = false
        when 'skip_button'      # go to and play the next track on the list (not on the album)
            if @id < @playing_playlist.tracks.length - 1
                @id += 1
                @selected_track = @playing_playlist.tracks[@id]
                play_track()
            end
        when 'rewind_button'    # go to and play the previous track on the list (not on the album)
            if @id > 0
                @id -= 1
                @selected_track = @playing_playlist.tracks[@id]
                play_track()
            end
        when (@repeat_song?('repeat_on_button'):('repeat_off_button'))  # turn on/off the repeat mode
            @repeat_song = !@repeat_song
            @music_player.play(@repeat_song)
        when 'new_playlist' # turn on/off the creative mode
            @creative_mode = !@creative_mode
            add_playlist()
        when 'volume_on_button'
            @music_player.volume = 0
        when 'progress_bar'
            @music_player.reposition(10)
        end

        if element.name['fav_']     # add/remove the current track to/from the favourite list
            track = @playing_track
            if @favourite_list.tracks.include?(track)
                @favourite_list.tracks.delete(track)
            else
                @favourite_list.tracks << track
            end
        end

        if element.name['sort_']
            attribute = element.name.split('_')[2]
            sort_albums(attribute)
        end
    end

    # add elements in the playlists panel
    # update
    def create_playlists_panel()
        @new_playlist_button = add_element(INDENT, (80-CREATE_HEIGHT)/2, CREATE_WIDTH, CREATE_HEIGHT, ELEMENT_COLOR, State::NORMAL, ZOrder::UI, 'new_playlist')
        sort_buttons = ['artist', 'genre', 'release']
        sort_buttons.each_with_index do |button, index|
            x = 110 + index*(BUTTON_DIM+12)
            y = (80-BUTTON_DIM)/2
            button = add_element(x, y, BUTTON_DIM, BUTTON_DIM, TRANSPARENT, State::NORMAL, ZOrder::UI, 'sort_by_' + button + '_button')
        end
        
        # display 1-4 playlists on the panel
		offset = (@playlist_page - 1) * 4
		@displayed_playlists = []
        remaining = @playlists.length - (@playlist_page-1)*4
        @playlists_this_page = ((remaining < 4)?(remaining):4)
        @playlist_display_area = Array.new(@playlists_this_page)
		index = 0
		while index < @playlists_this_page
			@displayed_playlists[index] = @playlists[index + offset]
            @playlist_display_area[index] = add_element(0, 80 + PANEL_HEIGHT*index, MENU, PANEL_HEIGHT, HIGHLIGHTED, State::NORMAL, ZOrder::PLAYER, "playlist_display_area_#{index}")
            if @selected_playlist == @displayed_playlists[index]
                @playlist_display_area[index].state = State::SELECTED
            end
			index += 1
		end

        # allow user to go to the next page if not at last page
        if @playlist_page < @max_playlist_page
            playlist_next_button = add_element(180, 492, BUTTON_DIM, BUTTON_DIM, TRANSPARENT, State::NORMAL, ZOrder::UI, 'playlist_next_button')
        end
        # allow user to go to the previous page if not at first page
        if @playlist_page > 1
            playlist_prev_button = add_element(35, 492, BUTTON_DIM, BUTTON_DIM, TRANSPARENT, State::NORMAL, ZOrder::UI, 'playlist_prev_button')
        end
    end

    # draw necessary images and text for created elements above
    # draw
    def draw_playlists_panel()
        # same button, different text based on mode
        if @creative_mode
            LARGE_TEXT.draw_text("OK", @new_playlist_button.x + 20, @new_playlist_button.y + 12, ZOrder::UI, 1.0, 1.0, WHITE)
        else
            LARGE_TEXT.draw_text("NEW", @new_playlist_button.x + 10, @new_playlist_button.y + 12, ZOrder::UI, 1.0, 1.0, WHITE)
        end

        # draw playlist info: title, artist (albums), thumbnail
		index = 0
		while index < @displayed_playlists.length
			x = @playlist_display_area[index].x + INDENT
			y = @playlist_display_area[index].y + INDENT
			@displayed_playlists[index].artwork.draw(x, y, ZOrder::UI)
			MEDIUM_TEXT.draw_text("#{@displayed_playlists[index].title.upcase}\n#{@displayed_playlists[index].artist}", x+ART_DIM+INDENT, y+INDENT, ZOrder::UI, 1.0, 1.0, BLACK)
			index += 1
		end
        LARGE_TEXT.draw_text("Page #{@playlist_page}", 82, 495, ZOrder::UI, 1.0, 1.0, WHITE)
  	end

    # similar to create_playlists_panel()
    def create_tracks_panel()
		offset = (@track_page - 1) * 5
		@displayed_tracks = []
        remaining = @selected_playlist.tracks.length - (@track_page-1)*5
        @tracks_this_page = ((remaining < 5)?(remaining):5)
        @track_display_area = Array.new(@tracks_this_page)
        fav_buttons = Array.new(@tracks_this_page)
		index = 0
		while index < @tracks_this_page
			@displayed_tracks[index] = @selected_playlist.tracks[index + offset]
            @track_display_area[index] = add_element(MENU, 80 + (ROW_HEIGHT + BAR_HEIGHT)*index + BAR_HEIGHT, WIDTH - MENU, ROW_HEIGHT, ROW_COLOR, State::NORMAL, ZOrder::PLAYER, "track_display_area_#{index}")
            if @playing_track == @displayed_tracks[index]
                @track_display_area[index].state = State::SELECTED
            end
            if @favourite_list.tracks.include?(@displayed_tracks[index])
                favourite = 'fav_on'
            else
                favourite = 'fav_off'
            end
            fav_buttons[index] = add_element(900, @track_display_area[index].y + 7, BUTTON_DIM, BUTTON_DIM, TRANSPARENT, State::NORMAL, ZOrder::UI, favourite + '_button')
			index += 1
		end

        # page display position will differ based on whether the playbar is present
        if @show_playbar
            y = 400
        else
            y = 450
        end

        # allow user to go to next/previous page if not in last/first page
        if @track_page < @max_track_page
            track_next_button = add_element(645, y+2, SMALL_BUTTON_DIM, SMALL_BUTTON_DIM, TRANSPARENT, State::NORMAL, ZOrder::UI, 'track_next_button')
        end
        if @track_page > 1
            track_prev_button = add_element(550, y+2, SMALL_BUTTON_DIM, SMALL_BUTTON_DIM, TRANSPARENT, State::NORMAL, ZOrder::UI, 'track_prev_button')
        end
    end

    # draw tracks info onto the screen
    # draw
    def draw_tracks_panel()
        draw_rect(MENU, 0, PANEL_WIDTH, 80, BLACK, ZOrder::BACKGROUND, mode=:default)
        LARGE_TEXT.draw_text(@selected_playlist.title.upcase(), TRACK_COLUMN, 15, ZOrder::BACKGROUND, 1.0, 1.0, WHITE)

        MEDIUM_TEXT.draw_text("TRACK", TRACK_COLUMN, 50, ZOrder::BACKGROUND, 1.0, 1.0, GRAY)
        MEDIUM_TEXT.draw_text("ARTIST", ARTIST_COLUMN, 50, ZOrder::BACKGROUND, 1.0, 1.0, GRAY)
        MEDIUM_TEXT.draw_text("GENRE", GENRE_COLUMN, 50, ZOrder::BACKGROUND, 1.0, 1.0, GRAY)
        MEDIUM_TEXT.draw_text("RELEASE", RELEASE_COLUMN, 50, ZOrder::BACKGROUND, 1.0, 1.0, GRAY)

        index = 0
		while index < @displayed_tracks.length
			y = @track_display_area[index].y + INDENT
			MEDIUM_TEXT.draw_text(@displayed_tracks[index].name, TRACK_COLUMN, y, ZOrder::UI, 1.0, 1.0, WHITE)
            album_id = @displayed_tracks[index].id.split('_')[0]
            album = @albums[album_id.to_i]
            MEDIUM_TEXT.draw_text(album.artist, ARTIST_COLUMN, y, ZOrder::UI, 1.0, 1.0, WHITE)            
            MEDIUM_TEXT.draw_text(GENRE_NAMES[album.genre.to_i], GENRE_COLUMN, y, ZOrder::UI, 1.0, 1.0, WHITE)           
            MEDIUM_TEXT.draw_text(album.rls_date, RELEASE_COLUMN, y, ZOrder::UI, 1.0, 1.0, WHITE)
			index += 1
		end
        if @show_playbar
            y = 400
        else
            y = 450
        end
        MEDIUM_TEXT.draw_text("Page #{@track_page}", (MENU+WIDTH-55)/2, y, ZOrder::UI, 1.0, 1.0, WHITE)
    end

    # play the currently selected track in normal mode
    # update
    def play_track()
        @pause_play = 'pause'
        @repeat_song = false
        @stopped = false
        @progress = 0

        volume = @music_player.volume if @playing_track
        @playing_track = @selected_track
        info = AudioInfo.open(@playing_track.location)
        @playing_track_length = info.length
        @time = Gosu.milliseconds

        album_id, track_order = *@playing_track.id.split('_')
        @playing_album = @albums[album_id.to_i]
        @playing_track_artist = @playing_album.artist
        @playing_track_name = @playing_track.name.upcase
        @playing_thumbnail = @playing_album.artwork
        
        @music_player = Gosu::Song.new(@playing_track.location)
        @music_player.volume = volume if volume
        @music_player.play(false)
        @show_playbar = true
    end

    def create_progress_bar()
        if @music_player.playing?
            @count_up = (Gosu.milliseconds - @time)
            seconds = @count_up / 1000
            @progress = seconds * (PANEL_WIDTH) / @playing_track_length
            @time = Gosu.milliseconds if seconds > @playing_track_length
        else
            @time = Gosu.milliseconds - @count_up
        end
    end

    # buttons on playbar
    # update
    def create_playbar()
        if @repeat_song
            repeat = 'repeat_on'
        else
            repeat = 'repeat_off'
        end
        if @favourite_list.tracks.include?(@playing_track)
            favourite = 'fav_on'
        else
            favourite = 'fav_off'
        end
        progress_bar = add_element(MENU, (HEIGHT - PANEL_HEIGHT), PANEL_WIDTH, 5, WHITE, State::NORMAL, ZOrder::PLAYER, 'progress_bar')
        playbar_buttons = ['stop', 'rewind', @pause_play, 'skip', repeat, favourite]
        playbar_buttons.each_with_index do |button, index|
            x = 654 + index * (BUTTON_DIM + 15)
            y = HEIGHT - (PANEL_HEIGHT + BUTTON_DIM)/2 + 5
            button = add_element(x, y, BUTTON_DIM, BUTTON_DIM, TRANSPARENT, State::NORMAL, ZOrder::UI, button + '_button')
        end
        if @music_player.volume == 0
            volume = 'off'
        else
            volume = 'on'
        end
        volume_button = add_element(735, 13, 20, 20, TRANSPARENT, State::NORMAL, ZOrder::UI, 'volume_' + volume + '_button')
        vol_level = Array.new(10)
        width = 10
        for index in 1..10 do
            height = 10 + index * 1.5
            x = 750 + index * (width + 5)
            y = 10 + (25 - height)
            if (@music_player.volume * 10) >= index
                color = WHITE
            else
                color = ELEMENT_COLOR
            end
            vol_level[index - 1] = add_element(x, y, width, height, color, State::NORMAL, ZOrder::UI, "volume_level_#{index - 1}")
        end
    end

    # draw playing track info: track name, current playlist (not album) and artist and buttons images
    # draw
    def draw_playbar()
        x = MENU
        y = HEIGHT-PANEL_HEIGHT
        draw_rect(x, y, PANEL_WIDTH, PANEL_HEIGHT, BLACK, ZOrder::BACKGROUND, mode=:default)
        
        draw_quad(x, y, BOTTOM_COLOR, x, (y+5), BOTTOM_COLOR, (x+@progress), (y+5), TOP_COLOR, (x+@progress), y, TOP_COLOR, ZOrder::UI, mode=:default)


        @playing_thumbnail.draw(x+INDENT, y + INDENT + 2.5, ZOrder::UI)
        if @music_player.playing?
            text = "Now playing in #{@playing_playlist.title}..."
        elsif @music_player.paused?
            text = 'Paused'
        else
            text = 'Ended'
        end
        MEDIUM_TEXT.draw_text(text, x + ART_DIM+INDENT*2, y + INDENT + 2.5, ZOrder::UI, 1.0, 1.0, GRAY)
        MEDIUM_TEXT.draw_text("#{@playing_track_name}\nby #{@playing_track_artist}", x+ART_DIM+INDENT*2, y + 40 + 2.5, ZOrder::UI, 1.0, 1.0, WHITE)

        progress = (@count_up / 1000).to_i
        progress_min = '%02d' % (progress / 60)
        progress_sec = '%02d' % (progress % 60)
        total_min = '%02d' % (@playing_track_length / 60)
        total_sec = '%02d' % (@playing_track_length % 60)
        MEDIUM_TEXT.draw_text("#{progress_min}:#{progress_sec} - #{total_min}:#{total_sec}", WIDTH - 120, y+10, ZOrder::UI, 1.0, 1.0, WHITE)

    end

    # show some info on the screen (during coding process)
    # draw
    def developer_mode()
        x = 700
        y = 380     # align to the left
        # mouse position
        SMALL_TEXT.draw_text("X: #{mouse_x}   Y: #{mouse_y}", x, y+15*0, ZOrder::UI, 1.0, 1.0, WHITE)
        # the element the mouse is currently on (if there is)
        if @element
            SMALL_TEXT.draw_text("Mouse at #{@element.name}", x, y+15*1, ZOrder::UI, 1.0, 1.0, WHITE)
        end
        # currently selected playlist
        if @selected_playlist
            SMALL_TEXT.draw_text("Selected album #{@selected_playlist.title}", x, y+15*2, ZOrder::UI, 1.0, 1.0, WHITE)
        end
        # currently selected track
        if @selected_track
            SMALL_TEXT.draw_text("Selected track #{@selected_track.name}", x, y+15*3, ZOrder::UI, 1.0, 1.0, Gosu::Color::WHITE)
        end
        if @playing_track            
            SMALL_TEXT.draw_text("Track length: #{@playing_track_length} seconds", MENU, y+15*0, ZOrder::UI, 1.0, 1.0, Gosu::Color::WHITE)
            SMALL_TEXT.draw_text("Time passed: #{@count_up/1000} seconds", MENU, y+15*1, ZOrder::UI, 1.0, 1.0, Gosu::Color::WHITE)
            SMALL_TEXT.draw_text("Volume: #{@music_player.volume}", MENU, y+15*2, ZOrder::UI, 1.0, 1.0, Gosu::Color::WHITE)
        end
        # whether the program is in creative mode (creating new playlist)
        if @creative_mode
            SMALL_TEXT.draw_text("Creative Mode on", 850, y+15*0, ZOrder::UI, 1.0, 1.0, WHITE)
        end
    end

    # draw simple background
    # draw
    def draw_background()
        draw_rect(0, 0, WIDTH, HEIGHT, BACKGROUND_COLOR, ZOrder::BACKGROUND, mode=:default)        
        draw_quad(0, 0, TOP_COLOR, 250, 0, TOP_COLOR, 0, HEIGHT, BOTTOM_COLOR, 250, HEIGHT, BOTTOM_COLOR, ZOrder::BACKGROUND, mode=:default)
        if not @selected_playlist
            LARGE_TEXT.draw_text("GUI Music Player\n104169617", 270, 20, ZOrder::UI, 1.0, 1.0, WHITE)
        end
    end

	def update
        # reset elements every single loop to avoid overlap
        initialize_elements()
        # for deverloper mode
        if iterate_element() != nil
            @element = iterate_element()
        else
            @element = nil
        end
        # automatically go to the next track of the current playlist when the current track ends
        if @music_player
            if not (@stopped or @music_player.playing? or @music_player.paused?) and (@id < @playing_playlist.tracks.length - 1)
                @id += 1
                @selected_track = @playing_playlist.tracks[@id]
                play_track()
            end
        end
	end

    def draw
        @cursor.draw(mouse_x, mouse_y, 3)
        draw_background()
        draw_elements()
        draw_playlists_panel()
        if @selected_playlist
            draw_tracks_panel()
        end
        if @show_playbar
            draw_playbar()
        end
        # the following function call is to make some information visible on the screen during coding process:
        # developer_mode()
    end

    def needs_cursor?; false; end

	def button_down(id)
		case id
	    when Gosu::MsLeft
            if iterate_element() != nil
                element = iterate_element()
                click_event(element)
            end
        when Gosu::KbUp
            if @playing_track and @music_player.volume < 1
                @music_player.volume = (@music_player.volume + 0.1).round(2)
            end
        when Gosu::KbDown
            if @playing_track and @music_player.volume > 0
                @music_player.volume = (@music_player.volume - 0.1).round(2)
            end
        when Gosu::KbRight      # go to and play the next track on the list (not on the album)
            if @id < @playing_playlist.tracks.length - 1
                @id += 1
                @selected_track = @playing_playlist.tracks[@id]
                play_track()
            end
        when Gosu::KbLeft    # go to and play the previous track on the list (not on the album)
            if @id > 0
                @id -= 1
                @selected_track = @playing_playlist.tracks[@id]
                play_track()
            end
	    end
	end

end

GUIMusicPlayer.new.show if __FILE__ == $0
