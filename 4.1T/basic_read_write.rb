# writes the number of lines then each line as a string.

def write_data_to_file(a_file)
    file = File.new(a_file, "w")
    file.puts('5')
    file.puts('Fred')
    file.puts('Sam')
    file.puts('Jill')
    file.puts('Jenny')
    file.puts('Zorro')
    file.close
end

# reads in each line.
# Do the following in WEEK 5
# you need to change the following code
# so that it uses a loop which repeats
# acccording to the number of lines in the File
# which is given in the first line of the File
def read_data_from_file(a_file)
    file = File.new(a_file, "r") 
    count = file.gets.to_i
    for i in 0..(count - 1)
        puts(file.gets)
    end
    file.close
end

# Do the following in WEEK 4
# writes data to a file then reads it in and prints
# each line as it reads.
# you should improve the modular decomposition of the
# following by moving as many lines of code
# out of main as possible.
def main
    # open for writing
    write_data_to_file("mydata.txt")
    # open for reading
    read_data_from_file("mydata.txt")
end

main
