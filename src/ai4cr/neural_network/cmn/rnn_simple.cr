require "json"
require "./learning_style.cr"
require "./rnn_concerns/calc_guess.cr"
require "./rnn_concerns/props_and_inits.cr"
require "./rnn_concerns/train_and_adjust.cr"
require "./rnn_concerns/roll_ups.cr"
require "./rnn_concerns/split_training_data.cr"

# require "./rnn_concerns/train_in_sequence.cr" # TODO!

module Ai4cr
  module NeuralNetwork
    module Cmn
      alias TrainingData = Array(NamedTuple(
        ins: Array(Array(Float64)),
        outs: Array(Array(Float64))))

      class RnnSimple
        # Simple RNN w/ inputs, hidden forward-feeding recurrent layer(s), outputs, and some other params
        include JSON::Serializable

        include RnnConcerns::PropsAndInits
        include RnnConcerns::CalcGuess
        include RnnConcerns::TrainAndAdjust
        include RnnConcerns::RollUps
        include RnnConcerns::SplitTrainingData
        # include RnnConcerns::TrainInSequence # TODO!
      end
    end
  end
end
