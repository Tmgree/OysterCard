require 'oystercard'


describe Oystercard do
  subject(:card) {described_class.new(journey: journey) }
  let(:journey) { double(:journey, journey_complete?: true, log_entry: nil) }
  let(:rand_num) {rand(1..40)}
  let(:entry_station){ double :station }
  let(:exit_station) { double :station }

  it 'A new card will defult have a balance of 0' do
    expect(card.balance).to eq 0
  end

  describe '#top_up' do

    it 'should increase the current balance' do
      expect{card.top_up(10)}.to change{ card.balance }.by 10
    end

    it 'should not allow a balance to exceed limit' do
      max_balance = Oystercard::BALANCE_LIMIT
      card.top_up(max_balance)
      expect{card.top_up(1)}.to raise_error "Error £#{max_balance} limit exceeded"
    end

  end

  describe '#pay' do

    it 'should deduct the correct amount from balance' do
      card.top_up(20)
      expect{ card.pay(3) }.to change{ card.balance }.by -3
    end

  end

  describe '#touch_in' do

    it 'should raise an error if balance is less than the BALANCE_MIN' do
      min_balance=Oystercard::BALANCE_MIN
      expect{card.touch_in(entry_station)}.to raise_error "Error minimum balance to touch in is #{min_balance}"
    end

    it 'should tell journey to start a new journey' do
      expect(journey).to receive(:log_entry).with(entry_station)
      card.top_up(10)
      card.touch_in(entry_station)
    end

    it 'should charge the PENALTY_FARE if previous journey was incomplete' do
      card.top_up(10)
      allow(journey).to receive(:journey_complete?).and_return(false)
      allow(journey).to receive(:fare).and_return(6)
      expect{card.touch_in(exit_station)}.to change{card.balance}.by (-6)
    end

  end

  xit 'should deduct the fare from the balance after touching out' do
    fare = Oystercard::FARE
    card.top_up(rand_num)
    card.touch_in(entry_station)
    expect{card.touch_out(exit_station)}.to change{card.balance}.by(-fare)
  end

end
