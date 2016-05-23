require 'pry'

replay = ""

def symbol_database
  symbols = [
    "Æ", "¥", "£", "þ",
    "¢", "¿", "Ø", "®",
    "§", "¶", "±", "√",
    "π", "∞", "⋰", "Ω",
    "ڲ", "₪", "Ð", "β",
    "€", "Œ", "@", "Ž",
    "♇", "▷", "☆", "⌘",
    "⎈", "☭", "♢", "╬"
  ]
end

def get_dimensions     #I dont like how long this method is, but couldnt think of a good way to refactor
  dimensions = []
  dim_x = 1
  dim_y = 1
  puts "Lets set up the board!"
  puts "* Note: the product of the two dimensions must be even"
  puts
  until (dim_x * dim_y).even?
    validation = false
    until validation
      puts "Enter a horizontal dimension for the board between 2 and 8"
      print "> "
      dim_x = gets.chomp.to_i
      validation = dimension_validation dim_x
    end
    validation = false
    until validation
      puts "Enter a vertical dimension for the board between 2 and 8"
      print "> "
      dim_y = gets.chomp.to_i
      validation = dimension_validation dim_y
    end
    puts "product not even, try again" if (dim_x * dim_y).odd?
  end
  dimensions.push(dim_x).push(dim_y)
end

def dimension_validation dimension
  if (2..8).to_a.include? dimension
    return true
  else
    puts "invalid selection, select again"
    puts
    return false
  end
end

def generate_grid dimensions
  grid = (1..(dimensions.inject(:*))).to_a
end

def generate_game_board grid
  board = ["🂠"]*grid.length
  Hash[grid.zip(board)]
end

def generate_victory_board grid
  board = [" "]*grid.length
  Hash[grid.zip(board)]
end

def random_symbols dimensions, db
  answer = []

  selection = db.sample(dimensions.inject(:*)/2)
  answer.push(selection).push(selection).flatten!.shuffle
end

def generate_answer_key answer, grid
  Hash[grid.zip(answer)]
end

def replay? replay
  replay == "n"
end

def replay_check
  puts
  replay = ""
  until replay == "n" || replay == "y"
    puts "Do you want to play again? y or n"
    print "> "
    replay = gets.chomp
    if replay != "n" && replay != "y"
      puts "You must select y (for yes) or n (for no)!"
    end
  end
  replay
end

def game_over? game_board, answer_key, round, grid, dimensions
  if game_board == (generate_victory_board grid)
    puts
    puts "CONGRATULATIONS!  You did it!"
    puts "It took you #{round - 1} rounds, not bad!"

    display_board answer_key, grid, dimensions
    return true
  else
    return false
  end
end

def display_round round
  puts
  puts "Round #{round}"
end

def display_grid board, dimensions
  puts
  puts "key".center(dimensions.first*4)
  i = 0
  board.each do |e|
    if (i % dimensions.first == (dimensions.first - 1))
      puts board[i].to_s.center(4)
    else
      print board[i].to_s.center(4)
    end
    i += 1
  end
end

def display_board board, grid, dimensions
  puts
    puts "game board".center(dimensions.first*4)
  i = 0
  grid.each do |e|
    if (i % dimensions.first == (dimensions.first - 1))
      puts board.values_at(e).join.center(4)
    else
      print board.values_at(e).join.center(4)
    end
    i += 1
  end
end

def choose_card grid, matches
  puts
  validation = false
  until validation
    print "select a card or type 'quit' to quit > "
    card = gets.chomp
    if card == "quit"
      validation = true
    else
      card = card.to_i
      validation = card_validation card, grid, matches
    end
  end
  card
end

def card_validation card, grid, matches
  if (grid.include? card) && !(matches.include? card)
    true
  elsif (matches.include? card)
    puts "You have already matched that card"
    puts
    false
  else
    puts "invalid selection, select again"
    puts
    false
  end
end

def show_card board, answer_key, card
  board[card] = answer_key[card]

  board
end

def check_for_match board, answer_key, grid, card_1, card_2, matches
  if answer_key[card_1] == answer_key[card_2]
    matches.push(card_1).push(card_2)
    # board[card_1] = answer_key[card_1]
    # board[card_2] = answer_key[card_2]
    board[card_1] = board[card_2] = grid[card_1 - 1] = grid[card_2 - 1] = " "
  end
end

def start_next_round
  puts
  puts "Press [enter] to continue"
  gets
  system "clear"
end

until replay? replay
  round = 1
  puts "~~Memory Game~~"
  puts
  dimensions = get_dimensions
  grid = generate_grid dimensions
  grid_update = grid.clone    #grid_update is used for matches, grid is used to set up hashes
  game_board = generate_game_board grid
  answer_key = generate_answer_key random_symbols(dimensions,symbol_database), grid
  matches = []
  until game_over? game_board, answer_key, round, grid, dimensions
    display_round round
    display_board game_board, grid, dimensions
    display_grid grid_update,dimensions
    temp_board = game_board.clone   #temp_board used for displaying chosen cards without changing game_board
    card_1 = choose_card grid, matches
  break if card_1 == "quit"
    display_board show_card(temp_board, answer_key, card_1), grid_update, dimensions
    card_2 = choose_card grid, matches
  break if card_2 == "quit"
    display_board show_card(temp_board, answer_key, card_2), grid_update, dimensions
    check_for_match game_board, answer_key, grid_update, card_1, card_2, matches
    round += 1
    start_next_round
  end
  replay = replay_check
end
