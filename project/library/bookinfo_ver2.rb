require './library/input_functions'

class Book
    attr_accessor :name, :type, :YoP, :author, :pages, :price
end

def read_info()
    book_list = []
    book_number = read_integer("How many books do you want to borrow?\n") - 1
    for i in 0..book_number
        book = Book.new()
        puts("Book #{i+1}:")
        book.name = read_string("Enter the name of the book: ")
        book.type = read_string("Enter its type (novel/comics/engineering...): ")
        book.YoP = read_integer("Enter its year of publishment: ")
        book.author = read_string("Enter the author's name: ")
        book.pages = read_integer("How many pages does it have?\n")
        book.price = read_float("Enter its price in USD: ")
        book_list << book
    end
    return book_list, book_number
end

def print_info(b_file, list, number)
    file = File.new(b_file, "w")
    for i in 0..number
        file.puts("Book #{i+1}:")
        file.puts("Name: #{list[i].name}")
        file.puts("Type: #{list[i].type}")
        file.puts("Year of Publishment: #{list[i].YoP}")
        file.puts("Author: #{list[i].author}")
        file.puts("Pages: #{list[i].pages}")
        file.puts("Price: $#{list[i].price.round(2)}")
        file.puts
    end
end

def main()
    borrow = read_info()
    print_info("./library/Library.txt", borrow[0], borrow[1])
end

main() if __FILE__ == $0
