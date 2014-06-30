require 'rspec'

class Discount
  BASE_PRICE = 8

  DISCOUNTS = {
    1 => 0,
    2 => BASE_PRICE * 0.05 * 2,
    3 => BASE_PRICE * 0.1 * 3,
    4 => BASE_PRICE * 0.2 * 4,
    5 => BASE_PRICE * 0.25 * 5,
  }



  def self.calculate(books)
    initial_price = books.count * 8

    # discount = SetFinder.new(books).sets.map { |set| DISCOUNTS[set] }.reduce(:+)

    discounts = books.permutation(books.count).map do |sorted_books|
      SetFinder.new(sorted_books).sets.map { |set| DISCOUNTS[set] }.reduce(:+)
    end

    initial_price - discounts.max
  end

end


class SetFinder


  attr_reader :superset



  def initialize(superset)
    @superset = superset
  end



  def sets
    unique_sets = []

    superset.each do |item|
      unique_sets.sort! { |a, b| a.count <=> b.count }

      add_item_to_set(item, unique_sets)
    end

    unique_sets.map &:count
  end



  private

  def add_item_to_set(item, unique_sets)
    added_to_set = false

    unique_sets.each do |set|
      if !set.include? item
        set << item
        added_to_set = true
        break
      end
    end

    unique_sets << [item] unless added_to_set

    unique_sets
  end
end


describe SetFinder do

  it "should gave back zero for empty set" do
    subject = SetFinder.new []

    expect(subject.sets).to eq []
  end


  it "should gave back [1] if one set in the superset" do
    subject = SetFinder.new %w[anything]

    expect(subject.sets).to eq [1]
  end


  it "should gave back [2] if the superset has only two unique elements" do
    subject = SetFinder.new %w[anything otherthing]

    expect(subject.sets).to eq [2]
  end

  it "should gave back [2,1] if the superset has two unique elements" do
    subject = SetFinder.new %w[anything otherthing anything]

    expect(subject.sets).to eq [2, 1]
  end

  it "should gave back [2,1] if the superset has two unique elements" do
    subject = SetFinder.new %w[anything anything otherthing anything otherthing]

    expect(subject.sets).to eq [2, 1, 2]
  end


end


describe Discount do

  it "should be no discount for one book" do
    expect(Discount.calculate %w[1]).to eq 8
  end


  it "should be no discount for the same book twice" do
    expect(Discount.calculate %w[1 1]).to eq 16
  end


  it "should give discount for the two different books" do
    expect(Discount.calculate %w[1 2]).to eq 15.2
  end


  it "should give discount for a set only" do
    expect(Discount.calculate %w[1 1 2]).to eq 23.2
  end


  {
    %w[1 1 2 2] => 30.4,
    %w[1 2 2 3 4 5] => 38,
    %w[1 2 3] => 24 - 2.4,
    %w[1 1 2 2 3 3 4 5] => 51.2,
    %w[1 1 1 1 1 2 2 2 2 2 3 3 3 3 4 4 4 4 4 5 5 5 5] => 141.2,
  }.each do |books, price|
    it "should pay #{price} for the books #{books.inspect}" do
      expect(Discount.calculate books).to eq price
    end
  end
end

