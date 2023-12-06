# this returns the index of the item or -1 if it is not found
def search_array(a, search_item)
	index = 0
	found_index = -1
	while (index < a.length)
		if (a[index] == search_item)
			found_index = index
		end
		index += 1
	end
	return found_index	
end

def main
	my_array = ["apple", "pear", "banana", "orange"]
	result = search_array(my_array, "orange")
	puts "The index of the item searched for is #{result}"	
end

main

