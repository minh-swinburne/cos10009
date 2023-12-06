
class MyRecord
    attr_accessor :name, :age
    def initialize(name, age)
      @name = name
      @age = age
    end
end

# Sort from largest to smallest age depending on direction
def compare(a, b)
  if (a > b)
    return true
  end
  return false
end

# Return true if the conditions are both true or both false
def same_boolean(a, b)
  if (a^b)
    return false
  end
  return true
end

# sort list according to direction 
def sort(arr, direction)
  item_count = arr.length 
# Now let's use bubble sort. Swap pairs iteratively as we loop through the
# array from the beginning of the array to the second-to-last value
  for i in (0..item_count - 2)
    # From arr[i + 1] to the end of the array
    for j in ((i + 1)..item_count - 1)
      # The values will be swapped in 2 situations:
      # 1. The first value is greater than the second value and in small-to-large direction
      # 2. The first value is smaller than the second value and in large-to-small direction
      if same_boolean(direction, compare(arr[i].age, arr[j].age))
        arr[i], arr[j] = arr[j], arr[i]
      end
    end
  end
  return arr
end

# Read the data from the file and print out each line
def read(aFile)
  people = []
  # Defensive programming:
  count = aFile.gets
  puts("first line: #{count}")
  if (is_numeric?(count))
    count = count.to_i
  else
    count = 0
    puts "Error: first line of file is not a number"
  end

  index = 0
  while (index < count)
    name = aFile.gets
    age = aFile.gets.to_i
    record = MyRecord.new(name, age)
    people << record
    puts "Line read: " + name
    index += 1
  end
  return people
end

def print_array(list)
  puts("Printing list: number of elements: #{list.length}")
  i = 0
  while (i < list.length)
    puts("Name: #{list[i].name} Age: #{list[i].age}")
    i = i + 1
  end
end

# Write data to a file then read it in and print it out
def main
  aFile = File.new("data.txt", "r") # open for writing
  people = read(aFile)
  aFile.close

  sorted_people = sort(people, true)
  # true for small-to-large sorting, false for large-to-small
  
  print_array(sorted_people)
end

# returns true if a string contains only digits
def is_numeric?(obj)
  if /[^0-9]/.match(obj) == nil
    return false
  end
  return true
end

main

