# Code for running game
module GameCode
  def play_as_guesser
    code = generate_code
    (1..self.class::TURNS).each do |i|
      guess = get_guess(i)
      unless check_input_validity(guess)
        puts 'One or more colors not included in the game. Enter code again'
        guess = get_guess(i)
      end
      puts check(guess, code).join(' ')
      if i == self.class::TURNS
        puts 'Ooops, you lose'
        play_again?
      end
    end
  end

  def play_as_coder
    puts 'Enter the secret code you want the computer to guess'
    code = gets.chomp.downcase.split
    unless check_input_validity(code)
      puts 'One or more colors not included in the game. Enter code again'
      play_as_coder
    end
    guess = []
    (1..self.class::TURNS).each do |i|
      guess = i == 1 ? self.class::COMBINATIONS[7] : get_computer_guess(code, guess)
      puts check(guess, code).join(' ')
      puts "Computer's guess no. #{i}: #{guess.join(' ')}"

      if i == self.class::TURNS
        puts 'Computer failed to guess your code! You win!'
        play_again?
      end
    end
  end

  def check_input_validity(code)
    code.all? { |element| self.class::COLORS.include?(element) }
  end

  def get_computer_guess(code, guess)
    feedback = check(guess, code)
    self.class::COMBINATIONS.each do |test_code|
      self.class::COMBINATIONS.delete(test_code) unless get_feedback(guess, test_code) == feedback
    end
    self.class::COMBINATIONS[0]
  end

  def check(guess, code)
    if guess.eql?(code)
      puts guess.join(' ')
      puts get_feedback(guess, code).join(' ')
      @status == 'g' ? puts('You win!') : puts('Computer wins!')
      play_again?
    else
      get_feedback(guess, code)
    end
  end

  def get_feedback(guess, code)
    feedback = []
    guess.each_with_index do |item0, index0|
      sub_feedback = []
      code.each_with_index do |item1, index1|
        if item1 == item0 && index1 == index0
          subfeedback << '@'
        elsif item1 == item0
          subfeedback << '*'
        else
          subfeedback << 'x'
        end
      end
      # this feedback will generate a 2 x 2 array that will contain
      # repeated values for colors that have been repeated in the code and/or guess.
      feedback << sub_feedback
    end
    clean_feedback(feedback)
  end

  def clean_feedback(array)
    # remove WHITE from rows and columns which have RED in the 2D array
    2.times do
      array.each do |sub_array|
        if sub_array.include?(self.class::RED)
          sub_array.map! { |element| element == self.class::WHITE ? self.class::NONE : element }
        end
      end
      array = array.transpose
    end
    # remove repeated instances of WHITE in each row or column
    2.times do
      array.each do |sub_array|
        if sub_array.count('*') > 1
          exempt = sub_array.index('*') + 1
          (exempt..3).each { |i| sub_array[i] = 'x' }
        end
      end
      array = array.transpose
    end
    array.flatten.delete_if { |element| element == 'x' }
  end

  def play_again?
    puts 'Would you like to play again? Y or N?'
    answer = gets.chomp.upcase
    if answer == 'Y'
      MastermindGame.new
    else
      exit
    end
  end

  def get_guess(turn)
    puts "Type in your guess, you have #{self.class::TURNS + 1 - turn} turn(s) left"
    guess = gets.chomp.downcase.split
    unless guess.length == 4
      puts 'Your input is invalid. Please enter 4 valid colors'
      get_guess(turn)
    end
    guess
  end

  def generate_code
    self.class::COMBINATIONS[rand(1..self.class::COMBINATIONS.count)]
  end
end

# Initiate game, define constants
class MastermindGame
  include GameCode

  TURNS = 12
  COLORS = %w[red green blue yellow orange black]
  COMBINATIONS = COLORS.repeated_permutation(4).to_a
  RED = '@'
  WHITE = '*'
  NONE = 'x'

  def initialize
    puts 'Welcome to Mastermind.
    The code can be selected from 6 colors which are as follows:
    Red, Green, Blue, Yellow, Orange and Black'
    initialize_player
  end

  def initialize_player
    player = Player.new
    case player.status.downcase
    when 'g'
      play_as_guesser
    when 'c'
      play_as_coder
    else
      puts 'Enter: Please enter g or c to select your position'
      initialize_player
    end
  end
end

# Initialize player and position
class Player < MastermindGame
  include GameCode

  attr_reader :status

  def initialize
    puts 'Would you like to play as guesser (g) or as coder (c)'
    @status = gets.chomp
  end
end

MastermindGame.new
