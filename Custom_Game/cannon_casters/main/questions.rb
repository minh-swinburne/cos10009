class Question
    attr_accessor :id, :quest, :choices, :correct

    def initialize(id, quest, choices, correct)
        @id = id
        @quest = quest
        @choices = choices
        @correct = correct
    end
end

def read_questions()
    filename = 'game_questions.txt'
    file = File.new(filename, 'r')
    count = file.gets.to_i
    questions = Array.new()
    index = 0
    while index < count
        question = read_question(file)
        questions << question
        index += 1
    end
    return questions
end

def read_question(file)
    id = '%02d' % (file.gets.chomp)
    quest = file.gets.chomp
    choices = read_choices(file)
    correct = file.gets.chomp.to_i - 1
    question = Question.new(id, quest, choices, correct)
    return question
end

def read_choices(file)
    count = 4
    choices = Array.new()
    index = 0
    while index < count
        choice = file.gets.chomp
        choices << choice
        index += 1
    end
    return choices
end

def print_questions(questions)
    count = questions.length
    index = 0
    while index < count
        question = questions[index]
        index += 1
        print(index.to_s + '. ')
        print_question(question)
    end
end

def print_question(question)
    quest = question.quest
    puts(quest)
    choices = question.choices
    letters = ['A', 'B', 'C', 'D']
    for index in 0..3
        puts("#{letters[index]} - #{choices[index]}")
    end
end

def main()
    questions = read_questions()
    print_questions(questions)
end

main() if __FILE__ == $0

