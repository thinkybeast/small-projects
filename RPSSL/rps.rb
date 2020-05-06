
# ------ MOVE CLASSES -------
class Move
  attr_reader :type
  VALUES = %w[rock paper scissors lizard spock]

  def self.random_move
    VALUES.sample
  end

  def self.valid_move?(move)
    VALUES.include?(move)
  end

  def to_s
    @type
  end
end

class Rock < Move
  def initialize
    @type = 'rock'
  end

  def >(other_move)
    (other_move.type == 'scissors') || (other_move.type == 'lizard')
  end

  def <(other_move)
    (other_move.type == 'paper') || (other_move.type == 'spock')
  end
end

class Paper < Move
  def initialize
    @type = 'paper'
  end

  def >(other_move)
    (other_move.type == 'rock') || (other_move.type == 'spock')
  end

  def <(other_move)
    (other_move.type == 'scissors') || (other_move.type == 'lizard')
  end
end

class Scissors < Move
  def initialize
    @type = 'scissors'
  end

  def >(other_move)
    (other_move.type == 'paper') || (other_move.type == 'lizard')
  end

  def <(other_move)
    (other_move.type == 'rock') || (other_move.type == 'spock')
  end
end

class Lizard < Move
  def initialize
    @type = 'lizard'
  end

  def >(other_move)
    (other_move.type == 'paper') || (other_move.type == 'spock')
  end

  def <(other_move)
    (other_move.type == 'rock') || (other_move.type == 'scissors')
  end
end

class Spock < Move
  def initialize
    @type = 'spock'
  end

  def >(other_move)
    (other_move.type == 'rock') || (other_move.type == 'scissors')
  end

  def <(other_move)
    (other_move.type == 'lizard') || (other_move.type == 'paper')
  end
end
# ------ PLAYER CLASSES -------
class Player
  attr_accessor :moves, :name, :score, :win_count
  def initialize
    @score = 0
    @moves = []
    @win_count = {
      'rock' => 0,
      'paper' => 0,
      'scissors' => 0,
      'lizard' => 0,
      'spock' => 0
    }
    set_name
  end

  def record_win
    self.score += 1
    win_count[last_move.to_s] += 1
  end

  def last_move
    moves.last
  end

  private

  def select_move(choice)
    case choice
    when 'rock'
      Rock.new
    when 'paper'
      Paper.new
    when 'scissors'
      Scissors.new
    when 'lizard'
      Lizard.new
    when 'spock'
      Spock.new
    end
  end
end

class Human < Player
  def set_name
    n = ''
    loop do
      puts "What's your name?"
      n = gets.chomp
      break unless n.empty?
      puts "Sorry, must enter a value."
    end
    self.name = n
  end

  def choose
    choice = nil
    loop do
      puts "Please choose rock, paper, scissors, lizard, or spock"
      choice = gets.chomp
      break if Move.valid_move?(choice)
      puts "Sorry, invalid choice."
    end
    moves << select_move(choice)
  end
end

class Computer < Player
  CHARACTERS = ['R2D2', 'Hal', 'Chappie', '2B']

  attr_accessor :preferences
  def initialize
    super
    @preferences = Personality.new(@name)
  end

  def set_name
    self.name = CHARACTERS.sample
  end

  def choose
    moves << select_move
  end

  def select_move
    move_preferences = []
    personality = preferences.personality
    puts personality
    Move::VALUES.each do |move|
      personality[move].times { move_preferences << move }
    end
    super(move_preferences.sample)
  end

  def react
    preferences.adjust(last_move.to_s, reaction_value)
  end

  private

  def reaction_value
    last_move = self.last_move.to_s
    move_count = moves.map(&:to_s).count(last_move)
    return 0 if move_count <= 1

    win_count = self.win_count[last_move].to_f
    win_ratio = win_count / move_count

    if win_ratio > 0.66 then 3
    elsif win_ratio < 0.33 then -3
    else 0
    end
  end
end

class Personality
  attr_reader :personality

  def initialize(character)
    rock, paper, scissors, lizard, spock = build_personality(character)
    @personality = {
      'rock'      => rock,
      'paper'     => paper,
      'scissors'  => scissors,
      'lizard'    => lizard,
      'spock'     => spock
    }
  end

  def adjust(attribute, num)
    personality[attribute] += num
    personality[attribute] = 10 if personality[attribute] > 10
    personality[attribute] = 1 if personality[attribute] < 1
  end

  def set(attribute, num)
    personality[attribute] = num
  end

  def to_s
    personality.each do |k, v|
      puts "#{k}: #{v}"
    end
  end

  private

  def build_personality(character)
    case character
    when 'R2D2'
      [7, 4, 7, 3, 5]
    when 'Hal'
      [10, 10, 10, 10, 10]
    when 'Chappie'
      [3, 8, 0, 3, 6]
    when '2B'
      [6, 6, 9, 9, 3]
    else
      [5, 5, 5, 5, 5]
    end
  end
end

# ------ GAME CLASSES -------
class RPSGame
  attr_accessor :human, :computer, :winner, :round, :win_score
  def initialize(win_score)
    @human = Human.new
    @computer = Computer.new
    @winner = ''
    @round = 1
    @win_score = win_score
  end

  def display_welcome_message
    puts "Welcome to RPS!"
    puts "Today #{human.name} faces #{computer.name}!"\
    " First to #{win_score} wins!"
    puts "Tap any key to begin..."
    gets
    clear_screen
  end

  def display_goodbye_message
    unless winner.empty?
      puts "#{winner} wins it all, #{human.score} to #{computer.score}!"
    end
    puts "Thanks for playing RPS! Good bye!"
  end

  def display_moves
    puts "#{human.name} chose #{human.moves.last}."
    puts "#{computer.name} chose #{computer.moves.last}."
  end

  def display_winner
    puts winner == 'tie' ? "It's a tie!!" : "#{winner} wins!"
  end

  def display_score
    puts "Current score:"
    puts "#{human.name} - #{human.score}"
    puts "#{computer.name} - #{computer.score}"
  end

  def display_history
    clear_screen
    puts "== Previous rounds =="
    puts "===      #{human.name} | #{computer.name}   ==="
    1.upto(round) do |r|
      puts "Round #{r}: #{human.moves[r - 1]} |"\
      " #{computer.moves[r - 1]}"
    end
    puts "\n"
  end

  def determine_winner
    human_move = human.last_move
    computer_move = computer.last_move

    if human_move > computer_move
      human.record_win
      self.winner = human.name
    elsif human_move < computer_move
      computer.record_win
      self.winner = computer.name
    else
      self.winner = 'tie'
    end
  end

  def play_again?
    display_score
    answer = nil
    loop do
      puts "Would you like to play again? (y/n)"
      answer = gets.chomp
      break if ['y', 'n'].include?(answer)
      puts "Sorry, must be y or n"
    end

    case answer
    when 'y' then return true
    when 'n'
      self.winner = ''
      return false
    end
  end

  def game_over?
    (human.score == win_score) || (computer.score == win_score)
  end

  def clear_screen
    system('clear') || system('cls')
  end

  def play
    display_welcome_message
    loop do
      human.choose
      computer.choose
      display_moves
      determine_winner
      display_winner
      break if game_over? || !play_again?
      computer.react
      display_history
      self.round += 1
    end
    display_goodbye_message
  end
end

WINNING_SCORE = 7

RPSGame.new(WINNING_SCORE).play
