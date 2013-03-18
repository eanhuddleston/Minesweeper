class M

  attr_reader :bombs, :view, :model

  def initialize
    @model = create_model
    @view = []
    @bombs = []
  end

  def insert_bombs
    until @bombs.count == 10
      i = Random.new.rand(0..8)
      j = Random.new.rand(0..8)
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
      unless row < 0 or row > 8 or pos < 0 or pos > 8
        if @model[row][pos] == "B"
          bomb_count += 1
        end
      end
    end

    bomb_count
  end

  def create_model
    model = []
    (0..8).each do |i|
      model[i] = []
      (0..8).each do |j|
        model[i][j] = "*"
      end
    end
    model
  end

  def print_board(board)
    board.each do |line|
      puts line.join(" ")
    end
  end
end