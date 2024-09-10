# put your code here - make sure you use the input_functions to read strings and integers
require_relative 'input_functions'

# returns the title for the label of the letter
def read_name()
    title = read_string('Please enter your title: (Mr, Mrs, Ms, Miss, Dr)')
    first_name = read_string('Please enter your first name:')
    last_name = read_string('Please enter your last name:')
    return title, first_name, last_name
end    

# return the address for the label of the letter
def read_address()
    # the house number, street name and suburb are strings, the postcode is an integer
    house_number = read_string('Please enter the house or unit number:')
    street = read_string('Please enter the street name:')
    suburb = read_string('Please enter the suburb:')
    # read the postcode as an integer between 0 and 9999
    postcode = read_integer_in_range('Please enter a postcode (0000 - 9999)', 0000, 9999)
    return house_number, street, suburb, postcode
end

# returns the message to be sent
def read_message()
    # read the contents as strings
    subject = read_string('Please enter your message subject line:')
    message = read_string('Please enter your message content:')
    # return the  message to be sent
    return subject, message
end

# prints the letter in required format
def print_letter(name, address, content)
    puts("#{name[0]} #{name[1]} #{name[2]}")
    puts("#{address[0]} #{address[1]}")
    puts("#{address[2]} #{address[3]}")
    puts("RE: #{content[0]}")
    puts()
    puts(content[1])
end

def main()
    # take the label and the message and print the complete letter
    print_letter(read_name(), read_address(), read_message())
end

# call main to excute the program
main()
