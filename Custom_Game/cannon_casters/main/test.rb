require 'gosu'

LIMIT = 5000

def text_width(text)
    return Gosu::Image.from_markup(text, 30, :font => 'Consolas', :bold => true).width
end

string_a = 'this is a string'
array_a = string_a.split
a = array_a.length
width_a = text_width(string_a)

string_b = 'In the rapidly evolving field of technology, where advancements in artificial intelligence, machine learning, and internet of things have revolutionized industries across the globe, the integration of IoT devices and sensors into a smart agriculture system model for small fields inside residential areas, specifically targeting the Katu community, a minor ethnic group residing in Danang, Vietnam, holds immense potential to enhance agricultural practices, optimize resource management, improve crop yields, minimize environmental impact, and empower local farmers with real-time data insights and remote control capabilities, thereby fostering sustainable and efficient farming practices, enabling better decision-making, and driving economic growth and social development within the community while also presenting certain challenges such as ensuring reliable connectivity, addressing potential security vulnerabilities, mitigating the limitations of Wi-Fi range and interference, and managing power consumption to ensure long-term viability and successful implementation of the proposed solution.'
array_b = string_b.split
width_b = text_width(string_b)
puts width_b, array_b.length

if width_b > LIMIT
    truncated = false
    words_left = array_b
    lines = []
    index = 0
    while !truncated
        puts index
        lines[index] = words_left.clone
        while text_width(lines[index].join(' ')) > LIMIT
            lines[index].pop
        end
        puts lines[index].join(' ')
        words_left = words_left[lines[index].length..]
        if text_width(words_left) < LIMIT
            lines[index+1] = words_left
            truncated = true
        end
        index += 1
    end
    lines.each do |line|
        puts line.join(' ')
    end
end
