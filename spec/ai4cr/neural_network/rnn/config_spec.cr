require "./../../../spec_helper"
require "json"

describe Ai4cr::NeuralNetwork::Rnn::Config do
  describe "#initialize" do
    describe "when given no params" do
      rnn_config = Ai4cr::NeuralNetwork::Rnn::Config.new
      # File.write("tmp/rnn_config.json", rnn_config.to_json)

      describe "sets default values for" do
        it "qty_states_in" do
          expected_qty_states_in = 3
          rnn_config.qty_states_in.should eq(expected_qty_states_in)
        end
  
        it "qty_states_out" do
          expected_qty_states_out = 4
          rnn_config.qty_states_out.should eq(expected_qty_states_out)
        end
  
        it "qty_time_cols" do
          expected_qty_time_cols = 5
          rnn_config.qty_time_cols.should eq(expected_qty_time_cols)
        end
  
        it "qty_lpfc_layers" do
          expected_qty_lpfc_layers = 2
          rnn_config.qty_lpfc_layers.should eq(expected_qty_lpfc_layers)
        end
  
        it "qty_recent_memory" do
          expected_qty_recent_memory = 2
          rnn_config.qty_recent_memory.should eq(expected_qty_recent_memory)
        end
  
        it "structure_hidden_laters" do
          expected_structure_hidden_laters = [] of Int32
          rnn_config.structure_hidden_laters.should eq(expected_structure_hidden_laters)
        end
  
        it "disable_bias" do
          expected_disable_bias = true
          rnn_config.disable_bias.should eq(expected_disable_bias)
        end
  
        it "learning_rate" do
          expected_learning_rate = 0.25
          rnn_config.learning_rate.should eq(expected_learning_rate)
        end
  
        it "momentum" do
          expected_momentum = 0.1
          rnn_config.momentum.should eq(expected_momentum)
        end
      end

      it "exports to json as expected" do
        contents = File.read("spec/data/neural_network/rnn/config/new.defaults.json")
        expected_json = JSON.parse(contents) # so can compare w/out human readable json file formatting

        JSON.parse(rnn_config.to_json).should eq(expected_json)
      end
    end
  end
end