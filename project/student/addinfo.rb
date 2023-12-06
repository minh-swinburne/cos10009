require './project/input_functions'
require 'date'

class Student
    attr_accessor :name, :DOB, :major, :grade, :m_mark, :p_mark, :a_mark
end

def read_info()
    student = Student.new()
    student.name = read_string("Enter student name: ")
    student.DOB = Date.parse(read_string("Enter their date of birth (dd-MM-yyyy): "))
    student.major = read_string("Enter their major: ")
    student.grade = read_string("What grade are they at?\n")
    student.m_mark = read_float("Enter their Math mark: ")
    student.p_mark = read_float("Enter their Programming mark: ")
    student.a_mark = (student.m_mark + student.p_mark) / 2
    return student
end

def print_info(s_file, info)
    s_file.puts("Name: #{info.name}")
    s_file.puts("Date of Birth: #{info.DOB.mday}-#{info.DOB.mon}-#{info.DOB.year}")
    s_file.puts("Major: #{info.major}")
    s_file.puts("Grade: #{info.grade}")
    s_file.puts("Math Mark: #{info.m_mark}")
    s_file.puts("Programming Mark: #{info.p_mark}")
    s_file.puts("GPA: #{info.a_mark}")
    s_file.puts
end

def main()
    student_list = []
    student_number = read_integer("How many students do you want to input?\n") - 1
    for i in 0..student_number
        puts("Student #{i+1}:")
        student_list << read_info()
    end
    s_file = File.new("./project/Student.txt", "w")
    for i in 0..student_number
        s_file.puts("Student #{i+1}:")
        print_info(s_file, student_list[i])
    end
end

main()
