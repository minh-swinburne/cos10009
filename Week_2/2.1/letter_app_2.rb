# put your code here - make sure you use the input_functions to read strings and integers
require './input_functions'

# this procedure takes information of the sender, including the title, first name, last name, and address, then returns the label for the letter
def label()
    # read the sender's information as strings
    title = read_string('Please enter your title: (Mr, Mrs, Ms, Miss, Dr)')
    first_name = read_string('Please enter your first name: ')
    last_name = read_string('Please enter your last name: ')
    house_number = read_string('Please enter the house or unit number: ')
    street = read_string('Please enter the street name: ')
    suburb = read_string('Please enter the suburb: ')
    # read the postcode as an integer between 0 and 9999
    postcode = read_integer_in_range('Please enter a postcode (0000 - 9999)', 0000, 9999)
    # return the label for the letter
    value = "#{title} #{first_name} #{last_name}\n#{house_number} #{street}\n#{suburb} #{postcode}\n"
end

# this procedure takes information of the message, including the subject line and the content of the message, then returns the message to be sent
def message()
    # read the contents as strings
    subject = read_string('Please enter your message subject line: ')
    content = read_string('Please enter your message content: ')
    # return the  message to be sent
    value = "RE: #{subject}\n\n#{content}"
end

def main()
    # take the label and the message and print the complete letter
    puts(label() + message())
end

# call main() to excute the program of a letter app
main()
