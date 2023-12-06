# print('Enter track name: ')
# name = input()
# print('Enter artist: ')
# artist = input()

# print("./sounds/{}_{}.mp3".format("-".join(name.split()), "-".join(artist.split())))

def location(file_name):
    print("sounds/{}.mp3".format(file_name))
    
location(input())