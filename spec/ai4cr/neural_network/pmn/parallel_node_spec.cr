require "./../../../spectator_helper"

Spectator.describe Ai4cr::NeuralNetwork::Pmn::ParallelNode do
  let(para_node) { Ai4cr::NeuralNetwork::Pmn::ParallelNode.new }

  describe "#initialize" do
    it "DEBUG" do
      p! para_node

      # puts para_node.to_pretty_json

      expect(1).to eq(1)
    end

    it "does not crash" do
      expect {
        Ai4cr::NeuralNetwork::Pmn::ParallelNode.new
      }.not_to raise_error
    end

    # context "when not given a height_set nor bias" do
    #   let(bias_enabled_expected) { false }
    #   let(height_expected) { 0 }
    #   let(height_set_expected) {
    #     Ai4cr::NeuralNetwork::Pmn::HeightSet.new
    #   }
    #   let(height_set_indexes_expected) {
    #     Ai4cr::NeuralNetwork::Pmn::HeightSetIndexes.new
    #   }

    #   it "bias is disabled" do
    #     expect(para_node.bias_enabled).to eq(bias_enabled_expected)
    #   end

    #   it "height is 0" do
    #     expect(para_node.height).to eq(height_expected)
    #   end

    #   # it "height_set is an empty hash" do
    #   #   expect(para_node.height_set).to eq(height_set_expected)
    #   # end

    #   it "height_set_indexes is an empty hash" do
    #     expect(para_node.height_set_indexes).to eq(height_set_indexes_expected)
    #   end

    #   it "is invalid" do
    #     expect(para_node.valid?).to be_false
    #   end

    #   context "is invalid re" do
    #     it "height" do
    #       expect(para_node.errors.keys).to contain(:height)
    #     end
    #   end
    # end

    # context "when given a height_set and bias is (left) disabled" do
    #   let(bias_enabled) { false }
    #   let(height_foo) { 2 }
    #   let(height_bar) { 3 }
    #   let(height_set) {
    #     {
    #       {from_channel: "foo", from_offset: [-1]} => 2,
    #       {from_channel: "bar", from_offset: [2]}  => 3,
    #     }
    #   }

    #   let(para_node) {
    #     Ai4cr::NeuralNetwork::Pmn::ParallelNode.new(bias_enabled: bias_enabled, height_set: height_set)
    #   }

    #   let(bias_enabled_expected) { false }
    #   let(height_expected) { height_foo + height_bar }
    #   let(height_set_expected) {
    #     height_set
    #   }
    #   let(height_set_indexes_expected) {
    #     {
    #       {from_channel: "foo", from_offset: [-1]} => [0, 1],
    #       {from_channel: "bar", from_offset: [2]}  => [2, 3, 4],
    #     }
    #   }

    #   # it "DEBUG" do
    #   #   p! para_node

    #   #   puts para_node.to_pretty_json

    #   #   expect(1).to eq(1)
    #   # end

    #   it "bias is disabled" do
    #     expect(para_node.bias_enabled).to eq(bias_enabled_expected)
    #   end

    #   it "height is 0" do
    #     expect(para_node.height).to eq(height_expected)
    #   end

    #   it "height_set is an empty hash" do
    #     expect(para_node.height_set).to eq(height_set_expected)
    #   end

    #   it "height_set_indexes is an empty hash" do
    #     expect(para_node.height_set_indexes).to eq(height_set_indexes_expected)
    #   end
    # end

    # context "when given a height_set and bias is enabled" do
    #   let(bias_enabled) { true }
    #   let(height_bias) { 1 }
    #   let(height_foo) { 2 }
    #   let(height_bar) { 3 }
    #   let(height_set) {
    #     # {"bias" => 1, "foo" => 2, "bar" => 3}

    #     {
    #       {from_channel: "bias", from_offset: [0]} => 1,
    #       {from_channel: "foo", from_offset: [-1]} => 2,
    #       {from_channel: "bar", from_offset: [2]}  => 3,
    #     }
    #   }

    #   let(para_node) {
    #     Ai4cr::NeuralNetwork::Pmn::ParallelNode.new(bias_enabled: bias_enabled, height_set: height_set)
    #   }

    #   let(bias_enabled_expected) { true }
    #   let(height_expected) { height_bias + height_foo + height_bar }
    #   let(height_set_expected) {
    #     height_set
    #   }
    #   let(height_set_indexes_expected) {
    #     # {"bias" => [0], "foo" => [1, 2], "bar" => [3, 4, 5]}
    #     {
    #       {from_channel: "bias", from_offset: [0]} => [0],
    #       {from_channel: "foo", from_offset: [-1]} => [1, 2],
    #       {from_channel: "bar", from_offset: [2]}  => [3, 4, 5],
    #     }
    #   }

    #   # it "DEBUG" do
    #   #   p! para_node

    #   #   puts para_node.to_pretty_json

    #   #   expect(1).to eq(1)
    #   # end

    #   it "bias is disabled" do
    #     expect(para_node.bias_enabled).to eq(bias_enabled_expected)
    #   end

    #   it "height is 0" do
    #     expect(para_node.height).to eq(height_expected)
    #   end

    #   it "height_set is an empty hash" do
    #     expect(para_node.height_set).to eq(height_set_expected)
    #   end

    #   it "height_set_indexes is an empty hash" do
    #     expect(para_node.height_set_indexes).to eq(height_set_indexes_expected)
    #   end
    # end
  end

  describe "#upsert_height" do
    context "when 'from_channel' does not yet exist" do
      # let(from_channel) { "foo" }
      let(from_offset) { [0] }
      let(height) { rand(3) + 1 }
      let(height_indexes_expected) { (0..height - 1).to_a }
      let(height_set_indexes_expected_before) {
        Ai4cr::NeuralNetwork::Pmn::HeightSetIndexes.new
      }
      let(height_set_indexes_expected_after) {
        {[0] => height_indexes_expected}
      }

      it "appends the heights list with associated height" do # TODO: Re-word title
        expect(para_node.height_set_indexes).to eq(height_set_indexes_expected_before)
        para_node.upsert_height(from_coord: from_offset, height: height)
        para_node.lock
        expect(para_node.height_set_indexes).to eq(height_set_indexes_expected_after)
      end
    end
  end
end
