module Hand
  def total
    total = hand.map(&:value).reduce(:+)
    ace_count = hand.count { |card| card.rank == 'A' }
    ace_count.times { total -= 10 if total > 21 }

    total
  end

  def show_hand
    print "#{name} has: "
    puts "#{full_hand}.  Total: #{total}"
  end

  private

  def full_hand
    @hand.join(', ')
  end
end

class Participant
  include Hand

  attr_reader :name, :stays_at

  def initialize
    @hand = []
  end

  def add_to_hand(cards)
    self.hand += cards
  end

  def must_stay?
    total >= stays_at
  end

  def busted?
    total > 21
  end

  def show_flop
    show_hand
  end

  def fresh_hand
    self.hand = []
  end

  def last_card
    hand.last
  end

  protected

  attr_accessor :hand
end

class Player < Participant
  def initialize
    super
    @name = set_name
    @stays_at = 21
  end

  def set_name
    name_choice = ''
    loop do
      puts "Before we begin, what shall I call you?"
      name_choice = gets.chomp.strip
      break unless name_choice.empty?
    end

    name_choice
  end
end

class Dealer < Participant
  attr_reader :deck

  def initialize
    super
    @name = "Dealer"
    @deck = Deck.new
    @stays_at = 17
  end

  def deal(num = 1)
    cards = []
    num.times { cards << deck.draw }
    cards
  end

  def show_flop
    print "#{name} has: "
    puts "#{self.hand.first} and unknown."
  end

  def new_deck
    @deck = Deck.new
  end
end

class Deck
  attr_reader :cards

  def initialize
    @cards = build_deck.shuffle
  end

  def draw
    cards.pop
  end

  def build_deck
    deck = []
    Card::SUITS.each do |suit|
      Card::RANKS.each do |rank|
        deck << Card.new(suit, rank)
      end
    end
    deck
  end
end

class Card
  SUITS = %w[♦ ♣ ♥ ♠]
  RANKS = %w[2 3 4 5 6 7 8 9 10 J Q K A]

  attr_reader :suit, :rank

  def initialize(suit, rank)
    @suit = suit
    @rank = rank
  end

  def value
    case rank
    when 'A' then 11
    when 'K', 'Q', 'J' then 10
    else
      rank.to_i
    end
  end

  def to_s
    "#{rank}#{suit}"
  end
end

class Game
  attr_reader :player, :dealer, :deck

  def initialize
    display_welcome_message
    @player = Player.new
    @dealer = Dealer.new
  end

  ##### DISPLAY METHODS
  def clear
    system 'clear'
  end

  def add_spacing
    puts ""
  end

  def clear_and_show_draw
    clear
    puts "#{player.name} draws a #{player.last_card}"
    add_spacing
  end

  def show_flops
    player.show_flop
    dealer.show_flop
    add_spacing
  end

  def show_hands
    player.show_hand
    dealer.show_hand
    add_spacing
  end

  def display_start_game_message
    clear
    puts "Alright #{player.name}! Let's do this!"
    add_spacing
  end

  def display_goodbye_message
    puts "Had enough already? See you next time!"
  end

  def display_welcome_message
    clear
    puts "Welcome to Twenty One!"
  end

  ##### GAME SETUP METHODS
  def deal_cards
    player.add_to_hand(dealer.deal(2))
    dealer.add_to_hand(dealer.deal(2))
  end

  ##### PLAYER TURN METHODS
  def hit_or_stay
    choice = nil
    loop do
      puts "Would you like to [h]it or [s]tay?"
      choice = gets.chomp.downcase
      break if %w[h s].include?(choice)
      puts "Sorry, please enter 'h' to hit or 's' to stay."
    end
    choice
  end

  def player_turn
    until player.must_stay?
      show_flops
      break if hit_or_stay == 's'
      player.add_to_hand(dealer.deal)
      clear_and_show_draw
    end
  end

  def dealer_turn
    until dealer.must_stay?
      dealer.add_to_hand(dealer.deal)
    end
  end

  ##### DETERMINE RESULT METHODS
  def show_result
    clear
    puts "The game is over!! Final result:"
    add_spacing
    show_hands
    winner = determine_winner
    puts winner ? "#{winner} wins!!" : "It's a tie!"
  end

  def determine_winner
    winner = winner_by_bust
    winner ||= winner_by_score
    winner
  end

  def winner_by_score
    case player.total <=> dealer.total
    when 1 then player.name
    when 0 then nil
    when -1 then dealer.name
    end
  end

  def winner_by_bust
    return "#{dealer.name} busted... #{player.name}" if dealer.busted?
    return "#{player.name} busted... #{dealer.name}" if player.busted?
    nil
  end

  ##### GAME END METHODS
  def play_again?
    choice = nil
    loop do
      puts "Would you like to play again (y/n)?"
      choice = gets.chomp.downcase
      break if %w[y n].include?(choice)
    end

    choice == 'y'
  end

  def reset
    player.fresh_hand
    dealer.fresh_hand
    dealer.new_deck
  end

  ##### GAME EXECUTION METHOD
  def start
    loop do
      display_start_game_message
      deal_cards
      player_turn
      dealer_turn unless player.busted?
      show_result
      break unless play_again?
      reset
    end

    display_goodbye_message
  end
end

Game.new.start
