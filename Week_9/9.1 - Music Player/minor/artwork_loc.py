print('Enter album name: ')
name = input()
print('Enter artist: ')
artist = input()

print("./images/{}_{}.bmp".format("-".join(name.split()), "-".join(artist.split())))