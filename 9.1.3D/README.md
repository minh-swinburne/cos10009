# GUI Music Player

Student Name: Nguyen Thi Thanh Minh (Luca)

Student ID: 104169617

All required and optional functions in the 9.1.3D task included

## Main features:

  1. Display playlists in 4-panel page, allowing iterating within limit of pages number

  2. Automatically detect and load albums that are correctly formatted as following:

     - album directory is put inside the folder `albums` and named `<number(2)>` with `<number(2)>` as a 2-digit number (for example: 00, 01...)

     - each album has an `info.txt` file that follows the format:

      ```
        <album artist>
        <album title>
        <release date>
        <genre>
        <artwork file name>
        <number of tracks>
        <name of first track>
        <name of second track(if there is)>
        ...
      ```
      
     - each album also includes track files each named after the track name as written in `info.txt`, with whitespaces replaced with hyphens (for example, track `My Love` will have its file named `My-Love.mp3`). The album artwork files are in the `images` folder

     - when loaded into the program, each track will be assigned a unique ID in the format: `<album ID>(2)_<track ID>(2)`, for example '01_00' is the ID for the first track in the second album. This serves the purpose of querying for the album the track is in, even when it's played from a custom playlist.

  3. Each element hovered by the mouse will be highlighted. Selected playlist and track will be hightlighted more brightly

  4. When selecting a playlist, its tracks will be displayed with information (name, artist, genre, release). Upon clicking on a track, it will start playing (stop any previously playing track), and show the playbar with buttons.

  5. Play/pause the current track with the pause-play button on the playbar, stop playing (playbar will be hidden), turn on/off the repeat mode for the current playing track

  6. Auto-playing, skip/rewind to next/previous track in the selected playlist (including albums, favourite list and custom playlists)

  7. Add the current track to the favourite list (the first playlist) with the heart-shaped button on the playbar. On the tracks panel, there are also non-interactive heart_shaped elements indicating whether the respective track is in the favourite playlist.

  8. Create a new custom playlist with the "NEW" button on the top left corner. Upon clicking, the program will enter the Creative Mode, which allows the user to click on wanted tracks without interrupting the possibly playing track. When done, click on that button, now named "OK".

  9. Sort albums by artist (by alphabet), genre (by genre order: Pop, Classic, Jazz, Rock) or release date (from earliest to latest) without changing the order of favourite and custom playlists.