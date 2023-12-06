def sum_product_calc(a, b)
    sum = a + b
    product = a * b
    return [sum, product]
end

def compare(a, b)
    if a > b
        puts('Sum is larger than product.')
    elsif a < b
        puts('Sum is smaller than product.')
    else
        puts('Sum is equal to product.')
    end
end

bee = sum_product_calc(13, 4)
puts compare(bee[0], bee[1])