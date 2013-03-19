require 'yaml'

class M

  attr_reader :bombs, :view, :model

  def initialize(board_size = 9)
    @board_size = board_size - 1
    @model = create_board("_")
    @view = create_board("*")
    @bombs = []
    @bomb_count = get_bomb_count
    @flags = []
    @game_status = "playing"
    insert_bombs
    insert_numbers
  end

  def get_bomb_count
    if @board_size == 8
      bomb_count = 10
    else
      bomb_count = 40
    end

    bomb_count
  end

  def insert_bombs
    until @bombs.count == @bomb_count
      i = Random.new.rand(0..@board_size)
      j = Random.new.rand(0..@board_size)
      @bombs << [i,j] unless @bombs.include?([i,j])
    end
    @bombs.each do |bomb|
      @model[bomb[0]][bomb[1]] = "B"
    end
  end

  def insert_numbers
    @model.each_with_index do |row, i|
      row.each_with_index do |position, j|
        next if @model[i][j] == "B"
        bomb_count = count_adjacent_bombs([i,j])
        @model[i][j] = bomb_count unless (bomb_count == 0)
      end
    end
  end

  def count_adjacent_bombs(curr_pos)
    bomb_count = 0
    trans_array = [ [0,-1], [1,-1], [1,0],
                  [1,1], [0,1], [-1,1],
                  [-1,0], [-1,-1] ]
    trans_array.each do |trans|
      row, pos = (curr_pos[0] + trans[0]), (curr_pos[1] + trans[1])
      unless row < 0 or row > (@board_size) or pos < 0 or pos > (@board_size)
        if @model[row][pos] == "B"
          bomb_count += 1
        end
      end
    end

    bomb_count
  end

  def process_all_around_blank(starting_coord)
    queue = []
    queue << starting_coord

    until queue.empty?
      coord = queue.shift
      trans_array = [ [0,-1], [1,-1], [1,0],
                    [1,1], [0,1], [-1,1],
                    [-1,0], [-1,-1] ]

      trans_array.each do |trans|
        row, pos = (coord[0] + trans[0]), (coord[1] + trans[1])
        unless row < 0 or row > @board_size or pos < 0 or pos > @board_size
          if @model[row][pos] != "_"
            reveal_in_view([row, pos])
          elsif @model[row][pos] == "_" && @view[row][pos] == "*" && @view[row][pos] != 'F'
            queue << [row, pos]
            reveal_in_view([row, pos])
          end
        end
      end
    end
  end

  def play
    puts "Input Format: (r)eveal/(f)ormat 0-8 0-8"
    puts "Example: r 1 3"

    until @game_status == "lose" or @game_status == "win"
      option, coord = collect_input

      case option
      when "f"
        set_flag(coord)
        if @flags.count == @bomb_count
          if all_flags_correct?
            @game_status = "win"
          else
            @game_status = "lose"
          end
        end
      when "r"
        process_selection(coord)
      when "s"
        save_to_file
        puts "Game saved to ./saved_game.yaml"
        break
      end
      puts "You win!" if @game_status == "win"
      puts "You suck!" if @game_status == "lose"
      print_board(@view)
      insert_blank_lines(2)
    end
  end

  def save_to_file
    File.open("saved_game.yaml", "w"){|file| YAML.dump(self,file)}
  end

  def insert_blank_lines(num)
    num.times { puts "" }
  end

  def collect_input
    input = gets.chomp.split(" ")
    return input[0], [input[1].to_i, input[2].to_i]
  end

  def all_flags_correct?
    if @flags.sort == @bombs.sort
      true
    else
      false
    end
  end

  def process_selection(users_choice)
    #curr_coord = queue.shift
    val = @model[users_choice[0]][users_choice[1]]
    if val == 'B'
      @bombs.each { |bomb| reveal_in_view(bomb) }
      @game_status = "lose"
    elsif val != '_'
      reveal_in_view(users_choice)
    else #it equaled "_"
      reveal_in_view(users_choice)
      process_all_around_blank(users_choice)
    end
  end

  def reveal_in_view(coord)
    @view[coord[0]][coord[1]] = @model[coord[0]][coord[1]]
  end

  def create_board(value)
    model = []
    (0..@board_size).each do |i|
      model[i] = []
      (0..@board_size).each do |j|
        model[i][j] = value
      end
    end
    model
  end

  def set_flag(coord)
    @flags << coord
    @view[coord[0]][coord[1]] = 'F'
  end

  def print_board(board)
    board.each do |line|
      puts line.join(" ")
    end
  end
end

if $PROGRAM_NAME == __FILE__
  if ARGV[0]
    file = ARGV.pop
    a = YAML.load_file(file)
    a.play
  else
    a = M.new
    a.play
  end
end