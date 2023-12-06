# string = "random string with a bunch of characters and you dunno how many of them there are"
# puts(string[-10])
# fruit = "strawberry"
# puts(fruit[0,5])
# puts(fruit[5,fruit.length])
# require 'gosu'

# # a = []
# # b = {}
# # puts(b.class)

# class NewWindow < Gosu::Window
#     def initialize
#         super(720, 480, {:fullscreen => false})
#         self.caption = "Music Player"
#         @song = Gosu::Song.new("./sounds/My-Love_Westlife.mp3")
#         @song.play(false)
#         @img = Go
#     end
# end

# # string = 'this is a string'
# # puts(string[-1])
# #NewWindow.new.show

# img = Gosu::Image.new("images/play_button.png")
# puts(img.class.name)
# if img.class.name["Gosu::Image"]
#     puts('This is an image.')
# end

# float = 4.1
# puts(float.to_i)

# int = 10/3
# puts(int)

# id = '00_06_14'
# playlist, album, track = *id.split('_').map{ |id| id.to_i }
# puts(playlist, album, track)

array1 = [13, 'char', true]
array2 = [476, 'an empty street', true]
array3 = [43, 'holy crap!', false]
array4 = [7, ' string?', false]
list = [array1, array2, array3, array4]
puts('Initial list:')
for array in list
    puts(array.to_s)
end

attribute = 0
i = 0
while i < list.length - 1
    j = i + 1
    while j < list.length
        if list[i][attribute] > list[j][attribute]
            list[i], list[j] = list[j], list[i]
        end    
        j += 1
    end
    i += 1
end
puts('Sorted list:')
for array in list
    puts(array.to_s)
end

def swap(a, b)
    a, b = b, a
end

puts(swap(45, 32))