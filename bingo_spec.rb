# coding: utf-8

class Bingo
  def self.generate_card
    header = " B |  I |  N |  G |  O"

    # 各列の数字を配列で取得する
    @columnB = generate_numbers_column("B")
    @columnI = generate_numbers_column("I")
    @columnN = generate_numbers_column("N")
    @columnG = generate_numbers_column("G")
    @columnO = generate_numbers_column("O")

    # 各行の文字列を作成する
    line0 = generate_line_string(0)
    line1 = generate_line_string(1)
    line2 = generate_line_string(2)
    line3 = generate_line_string(3)
    line4 = generate_line_string(4)

    # ビンゴカードを出力する
    <<-card
#{header}
#{line0}
#{line1}
#{line2}
#{line3}
#{line4}
    card
  end

  # 1列分の数字を生成し配列を返す
  def self.generate_numbers_column(column)
    # 生成対象のカラムごとに候補の数字の範囲を定義する
    if column == "B"
        numbers = ("1".."15").to_a
    elsif column == "I"
        numbers = ("16".."30").to_a
    elsif column == "N"
        numbers = ("31".."45").to_a
    elsif column == "G"
        numbers = ("46".."60").to_a
    elsif column == "O"
        numbers = ("61".."75").to_a
    end
    
    # 候補の数字から5つの数字をランダムに選び配列で返す
    # 一度選ばれた数字を候補から除くことで同じ数字が選ばれないようにしている
    column_numbers = []
    5.times do
        random = rand(0..numbers.length-1)
        selected_number = numbers[random]
        
        # 一桁の数字が選ばれた場合はスペースを加えて右詰にする
        if selected_number.length == 1
            selected_number = " " + selected_number
        end
        
        column_numbers.push(selected_number)
        numbers.delete_at(random)
    end
    column_numbers
  end

  # 1行分の文字列を生成する
  def self.generate_line_string(line_number)
    # 3行目の3列目（中央）は空白をセットする
    if line_number == 2
        line = @columnB[line_number] + " | " + @columnI[line_number] + " | " + "  "                  + " | " + @columnG[line_number] + " | " + @columnO[line_number]
    else
        line = @columnB[line_number] + " | " + @columnI[line_number] + " | " + @columnN[line_number] + " | " + @columnG[line_number] + " | " + @columnO[line_number] 
    end
  end
end

describe Bingo do
  describe '#generate_card' do
    let(:card) { Bingo.generate_card }
    let(:rows) { card.split("\n") }
    let(:table) { rows.map { |s| s.split(' | ') } }
    let(:numbers_by_col) do
      table[1..-1]
          .map { |cols| cols.map(&:to_i) }
          .transpose
    end
    it '何らかのデータが出力されること' do
      # デバッグ用に出力結果をコンソール表示する
      puts '=' * 22
      puts card
      puts '=' * 22
      expect(card.size).to be > 1
    end
    it '6行になっていること' do
      expect(rows.size).to eq 6
    end
    it '1行は22文字になっていること' do
      expect(rows.all? { |s| s.size == 22 }).to be_truthy
    end
    it '列はパイプで区切られていること' do
      rows.each do |row|
        expect(row.split(' | ').size).to eq 5
      end
    end
    it '先頭行はBINGOになっていること' do
      expect(rows.first.scan(/\w/).join).to eq 'BINGO'
    end
    it 'カラムの値は右寄せになっていること' do
      table.flatten.each do |col|
        expect(col).to match /^( [\d\w ]|\d\d)$/
      end
    end
    it '1列目の値は1～15の数字のどれかになっていること' do
      expect(numbers_by_col[0].all? { |n| (1..15).include?(n) }).to be_truthy
    end
    it '2列目の値は16～30の数字のどれかになっていること' do
      expect(numbers_by_col[1].all? { |n| (16..30).include?(n) }).to be_truthy
    end
    it '3列目の値（真ん中以外）は31～45の数字のどれかになっていること' do
      [0, 1, 3, 4].each do |index|
        expect((31..45).include?(numbers_by_col[2][index])).to be_truthy
      end
    end
    it '3列目の真ん中はスペースになっていること' do
      expect(table[3][2]).to eq '  '
    end
    it '4列目の値は46～60の数字のどれかになっていること' do
      expect(numbers_by_col[3].all? { |n| (46..60).include?(n) }).to be_truthy
    end
    it '5列目の値は61～75の数字のどれかになっていること' do
      expect(numbers_by_col[4].all? { |n| (61..75).include?(n) }).to be_truthy
    end
    it 'どの値も重複しないこと' do
      expect(numbers_by_col.flatten.uniq).to eq numbers_by_col.flatten
    end
    it '毎回結果が変わること' do
      cards = 10.times.map { Bingo.generate_card }
      expect(cards.uniq).to eq cards
    end
  end
end