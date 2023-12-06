require './library/input_functions'
require 'date'

class Book
    attr_accessor :name, :type, :YoP, :author, :pages, :price
end

def read_info()
    book = Book.new()
    book.name = read_string("Enter the name of the book: ")
    book.type = read_string("Enter its type (novel/comics/engineering...): ")
    book.YoP = read_integer("Enter its year of publishment: ")
    book.author = read_string("Enter the author's name: ")
    book.pages = read_integer("How many pages does it have?\n")
    book.price = read_float("Enter its price in USD: ")
    return book
end

def print_info(s_file, info)
    s_file.puts("Name: #{info.name}")
    s_file.puts("Type: #{info.type}")
    s_file.puts("Year of Publishment: #{info.YoP}")
    s_file.puts("Author: #{info.author}")
    s_file.puts("Pages: #{info.pages}")
    s_file.puts("Price: $#{info.price.rou}")
    s_file.puts
end

def main()
    book_list = []
    book_number = read_integer("How many books do you want to borrow?\n") - 1
    for i in 0..book_number
        puts("Book #{i+1}:")
        book_list << read_info()
    end
    s_file = File.new("./library/Library.txt", "w")
    for i in 0..book_number
        s_file.puts("Book #{i+1}:")
        print_info(s_file, book_list[i])
    end
end

main() if __FILE__ == $0
