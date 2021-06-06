require "./../../../spectator_helper"

Spectator.describe Ai4cr::NeuralNetwork::Pmn::MiniNetData do
  let(mnd) { Ai4cr::NeuralNetwork::Pmn::MiniNetData.new }

  describe "#initialize" do
    # it "DEBUG" do
    #   p! mnd

    #   puts mnd.to_pretty_json

    #   expect(1).to eq(1)
    # end

    it "does not crash" do
      expect {
        Ai4cr::NeuralNetwork::Pmn::MiniNetData.new
      }.not_to raise_error
    end

    context "when not given a height_set nor bias" do
      let(bias_enabled_expected) { false }
      let(height_expected) { 0 }
      let(height_set_expected) {
        Hash(String,Int32).new
      }
      let(height_set_indexes_expected) {
        Hash(String,Array(Int32)).new
      }

      it "bias is disabled" do
        expect(mnd.bias_enabled).to eq(bias_enabled_expected)
      end

      it "height is 0" do
        expect(mnd.height).to eq(height_expected)
      end

      it "height_set is an empty hash" do
        expect(mnd.height_set).to eq(height_set_expected)
      end

      it "height_set_indexes is an empty hash" do
        expect(mnd.height_set_indexes).to eq(height_set_indexes_expected)
      end
    end

    context "when given a height_set and bias is (left) disabled" do
      let(bias_enabled) { false }
      let(height_foo) { 2 }
      let(height_bar) { 3 }
      let(height_set) {
        { "foo" => 2, "bar" => 3 }
      }

      let(mnd) {
        Ai4cr::NeuralNetwork::Pmn::MiniNetData.new(bias_enabled: bias_enabled, height_set: height_set)
      }

      let(bias_enabled_expected) { false }
      let(height_expected) { height_foo + height_bar }
      let(height_set_expected) {
        height_set
      }
      let(height_set_indexes_expected) {
        { "foo" => [0,1], "bar" => [2,3,4] }
      }

      # it "DEBUG" do
      #   p! mnd
  
      #   puts mnd.to_pretty_json
  
      #   expect(1).to eq(1)
      # end

      it "bias is disabled" do
        expect(mnd.bias_enabled).to eq(bias_enabled_expected)
      end

      it "height is 0" do
        expect(mnd.height).to eq(height_expected)
      end

      it "height_set is an empty hash" do
        expect(mnd.height_set).to eq(height_set_expected)
      end

      it "height_set_indexes is an empty hash" do
        expect(mnd.height_set_indexes).to eq(height_set_indexes_expected)
      end
    end

    context "when given a height_set and bias is enabled" do
      let(bias_enabled) { true }
      let(height_bias) { 1 }
      let(height_foo) { 2 }
      let(height_bar) { 3 }
      let(height_set) {
        { "bias" => 1, "foo" => 2, "bar" => 3 }
      }

      let(mnd) {
        Ai4cr::NeuralNetwork::Pmn::MiniNetData.new(bias_enabled: bias_enabled, height_set: height_set)
      }

      let(bias_enabled_expected) { true }
      let(height_expected) { height_bias + height_foo + height_bar }
      let(height_set_expected) {
        height_set
      }
      let(height_set_indexes_expected) {
        { "bias" => [0], "foo" => [1,2], "bar" => [3,4,5] }
      }

      # it "DEBUG" do
      #   p! mnd
  
      #   puts mnd.to_pretty_json
  
      #   expect(1).to eq(1)
      # end

      it "bias is disabled" do
        expect(mnd.bias_enabled).to eq(bias_enabled_expected)
      end

      it "height is 0" do
        expect(mnd.height).to eq(height_expected)
      end

      it "height_set is an empty hash" do
        expect(mnd.height_set).to eq(height_set_expected)
      end

      it "height_set_indexes is an empty hash" do
        expect(mnd.height_set_indexes).to eq(height_set_indexes_expected)
      end
    end
  end

  describe "#upsert_height" do
    context "when 'incoming_channel' does not yet exist" do
      let(incoming_channel) { "foo" }
      let(height) { rand(3) + 1 }
      let(height_set_indexes_expected_before) {
        Hash(String,Array(Int32)).new
      }
      let(height_set_indexes_expected_after) {
        {incoming_channel => (0..height-1).to_a}
      }

      it "appends the 'incoming_channel' and associated height" do
        expect(mnd.height_set_indexes).to eq(height_set_indexes_expected_before)
        mnd.upsert_height(incoming_channel: incoming_channel, height: height)
        expect(mnd.height_set_indexes).to eq(height_set_indexes_expected_after)
      end
    end
  end
end