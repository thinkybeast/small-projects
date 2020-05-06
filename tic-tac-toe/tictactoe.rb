
class Board
  WINNING_LINES = [[1, 2, 3], [4, 5, 6], [7, 8, 9]] + # rows
                  [[1, 4, 7], [2, 5, 8], [3, 6, 9]] + # cols
                  [[1, 5, 9], [3, 5, 7]]              # diags

  def initialize
    @squares = {}
    reset
  end

  # rubocop:disable Metrics/AbcSize
  def draw
    puts "     |     |"
    puts "  #{@squares[1]}  |  #{@squares[2]}  |  #{@squares[3]}"
    puts "     |     |"
    puts "-----+-----+-----"
    puts "     |     |"
    puts "  #{@squares[4]}  |  #{@squares[5]}  |  #{@squares[6]}"
    puts "     |     |"
    puts "-----+-----+-----"
    puts "     |     |"
    puts "  #{@squares[7]}  |  #{@squares[8]}  |  #{@squares[9]}"
    puts "     |     |"
  end
  # rubocop:enable Metrics/AbcSize

  def []=(key, marker)
    @squares[key].marker = marker
  end

  def unmarked_keys
    @squares.keys.select { |key| @squares[key].unmarked? }
  end

  def full?
    unmarked_keys.empty?
  end

  def someone_won?
    !!winning_marker
  end

  # returns winning marker or nil
  def winning_marker
    WINNING_LINES.each do |line|
      row = @squares.values_at(*line)
      return row.first.marker if winning_row?(row)
    end
    nil
  end

  def reset
    (1..9).each { |key| @squares[key] = Square.new() }
  end

  # Returns the key of square in row threatened by specified marker
  def threatened_square(threat_marker)
    WINNING_LINES.each do |line|
      row = @squares.values_at(*line)
      if threatened_row?(row) && row.map(&:marker).include?(threat_marker)
        return line.select { |pos| @squares[pos].unmarked? }.first
      end
    end
    nil
  end

  # Returns random key in row available to attack (add second marker)
  def attractive_square(attacking_marker)
    potential_attacks = []

    WINNING_LINES.each do |line|
      row = @squares.values_at(*line)
      if attractive_row?(row, attacking_marker)
        potential_attacks += line.select { |pos| @squares[pos].unmarked? }
      end
    end
    potential_attacks.empty? ? nil : potential_attacks.sample
  end

  private

  def threatened_row?(row)
    row.count(&:unmarked?) == 1 && row.map(&:marker).uniq.size == 2
  end

  def attractive_row?(row, marker)
    row.count(&:unmarked?) == 2 && row.map(&:marker).include?(marker)
  end

  def winning_row?(row)
    return false if row.any?(&:unmarked?)
    row.map(&:marker).uniq.size == 1
  end
end

class Square
  INITIAL_MARKER = ' '
  attr_accessor :marker

  def initialize(marker = INITIAL_MARKER)
    @marker = marker
  end

  def unmarked?
    marker == INITIAL_MARKER
  end

  def to_s
    @marker
  end
end

class Player
  attr_reader :marker
  attr_accessor :score, :name

  def initialize(name = nil, marker = nil)
    @name = name
    @marker = marker.nil? ? select_marker : marker
    @score = 0
  end

  private

  def select_marker
    marker = ''
    loop do
      print "How would you like to mark your squares? "
      marker = gets.chomp
      break if marker.size == 1 && marker.match?(/\w/)
      puts "Sorry, you must pick a single alphanumeric character."
    end
    marker
  end
end

class TTTGame
  attr_reader :board, :human, :computer, :first_mover
  COMPUTER_MARKER = 'O'
  ROUNDS_TO_WIN = 5
  MOVES_FIRST = 'choose'
  OPPONENTS = %w[Kingpin Vulture Electro Rhino Octavius]

  def initialize
    @board = Board.new
    display_welcome_message
    initialize_players
    @first_mover = determine_first_mover
    @current_marker = first_mover
  end

  # MAIN GAME LOOP
  def play
    display_start_game_message

    loop do
      display_board

      loop do
        current_player_moves
        break if board.someone_won? || board.full?
        clear_screen_and_display_board if human_turn?
      end

      update_score
      display_result
      break if game_won?
      prepare_next_round
    end

    display_game_winner
    display_goodbye_message
  end

  private

  ##### GAME SETUP METHODS

  def initialize_players
    @human = Player.new(select_name)
    @computer = Player.new(OPPONENTS.sample, COMPUTER_MARKER)
  end

  def select_name
    player_name = nil
    loop do
      puts "What shall I call you?"
      player_name = gets.chomp.strip
      break unless player_name.empty?
    end
    player_name
  end

  def determine_first_mover
    case MOVES_FIRST
    when 'human'
      human.marker
    when 'computer'
      COMPUTER_MARKER
    when 'choose'
      select_first_mover
    end
  end

  def select_first_mover
    first = nil
    loop do
      puts "Okay, #{human.name}. Who gets to go first each game??"
      print "You can select 'me', 'cpu', or 'random': "
      first = gets.chomp
      break if %w[me cpu random].include?(first)
    end

    case first
    when 'me'
      human.marker
    when 'cpu'
      COMPUTER_MARKER
    when 'random'
      [human.marker, COMPUTER_MARKER].sample
    end
  end

  ##### DISPLAY METHODS
  def display_welcome_message
    clear
    puts "Welcome to tic tac toe, my friend."
  end

  def display_start_game_message
    clear
    puts "Alright, let's begin! Today, you face #{computer.name} in tic"\
    " tac tombat."
  end

  def display_goodbye_message
    puts "Thanks for playing! Goodbye!"
  end

  def display_game_winner
    clear
    winner = game_winner == human.marker ? "You" : "The almighty computer"
    puts "#{winner} won it all, #{human.score} to #{computer.score}!"
  end

  def display_board
    puts "You're a #{human.marker}. #{computer.name} is a #{computer.marker}"
    add_padding
    display_scoreboard
    add_padding
    board.draw
    add_padding
  end

  def add_padding
    puts ""
  end

  def display_scoreboard
    puts "Score".center(17)
    puts "-----------".center(17)
    puts " #{human.name} VS #{computer.name} ".center(17)
    puts " #{human.score}  to  #{computer.score}".center(17)
  end

  def display_result
    clear_screen_and_display_board

    case board.winning_marker
    when human.marker
      puts "You won!!!!!!!!!"
    when computer.marker
      puts "Computer won......"
    else
      puts "The board is full. It's a tie ‾\\_(ツ)_/‾"
    end
  end

  def prepare_next_round
    puts "Press any key to play the next round..."
    gets
    reset
  end

  def clear_screen_and_display_board
    clear
    display_board
  end

  def clear
    system("clear") || system("cls")
  end

  def joinor(arr, delimit = ', ', join_word = 'or')
    case arr.size
    when 0
      ""
    when 1
      arr.first.to_s
    when 2
      arr.join(" #{join_word} ")
    else
      arr[-1] = "#{join_word} #{arr.last}"
      arr.join(delimit)
    end
  end

  ##### PLAYER TURN METHODS

  def current_player_moves
    human_turn? ? human_moves : computer_moves
    change_turn
  end

  def human_turn?
    @current_marker == human.marker
  end

  def change_turn
    @current_marker = human_turn? ? COMPUTER_MARKER : human.marker
  end

  def human_moves
    puts "Choose an available square: #{joinor(board.unmarked_keys)}"
    square = nil

    loop do
      square = gets.chomp.to_i
      break if board.unmarked_keys.include?(square)
      puts "Sorry, not a valid choice"
    end
    board[square] = human.marker
  end

  def computer_moves
    board[optimal_square] = computer.marker
  end

  ##### COMPUTER LOGIC
  def optimal_square
    square = find_square_to_attack
    square ||= find_square_to_defend
    square ||= find_attractive_square
    square.nil? ? board.unmarked_keys.sample : square
  end

  def find_square_to_attack
    board.threatened_square(computer.marker)
  end

  def find_square_to_defend
    board.threatened_square(human.marker)
  end

  def find_attractive_square
    return 5 if board.unmarked_keys.include?(5)
    board.attractive_square(computer.marker)
  end

  ##### END GAME METHODS
  def play_again?
    answer = nil
    loop do
      puts "would wou like to play again (y/n)?"
      answer = gets.chomp.downcase
      break if %w[y n].include? answer
      puts "Sorry, must be y or n"
    end

    answer == 'y'
  end

  def game_won?
    !!game_winner
  end

  def game_winner
    if human.score == ROUNDS_TO_WIN
      human.marker
    elsif computer.score == ROUNDS_TO_WIN
      computer.marker
    end
  end

  def update_score
    case board.winning_marker
    when human.marker
      human.score += 1
    when computer.marker
      computer.score += 1
    end
  end

  def reset
    clear
    @current_marker = first_mover
    board.reset
  end
end

##### GAME EXECUTION

game = TTTGame.new
game.play
