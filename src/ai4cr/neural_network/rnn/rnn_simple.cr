require "./concerns/simple/aliases.cr"
require "./concerns/common/props_and_inits.cr"
require "./concerns/simple/pai_distinct.cr"
require "./concerns/common/calc_guess.cr"
require "./concerns/simple/cg_distinct.cr"
require "./concerns/common/train_and_adjust.cr"
require "./concerns/simple/taa_distinct.cr"
require "./concerns/simple/roll_ups.cr"
require "./concerns/common/data_utils.cr"

module Ai4cr
  module NeuralNetwork
    module Rnn
      # module Concerns::Simple
      #   alias InputSetGiven = Array(Array(Float64))
      #   alias OutputSetGiven = Array(Array(Float64))
      # end
      class RnnSimple
        # Simple RNN w/ inputs, hidden forward-feeding recurrent layer(s), outputs, and some other params

        include JSON::Serializable

        include Ai4cr::Breed::Client

        include Concerns::Common::PropsAndInits
        include Concerns::Simple::PaiDistinct

        include Concerns::Common::CalcGuess
        include Concerns::Simple::CgDistinct

        include Concerns::Common::TrainAndAdjust
        include Concerns::Simple::TaaDistinct

        include Concerns::Simple::RollUps
        include Concerns::Common::DataUtils

        def clone
          a_clone = RnnSimple.new(
            name: self.name.clone,

            history_size: self.history_size.clone,

            io_offset: self.io_offset.clone,
            time_col_qty: self.time_col_qty.clone,
            input_size: self.input_size.clone,
            output_size: self.output_size.clone,
            hidden_layer_qty: self.hidden_layer_qty.clone,
            hidden_size_given: self.hidden_size_given.clone,

            learning_styles: self.learning_styles.clone,

            bias_disabled: self.bias_disabled.clone,
            bias_default: self.bias_default.clone,

            learning_rate: self.learning_rate.clone,
            momentum: self.momentum.clone,
            deriv_scale: self.deriv_scale.clone,
          )
          a_clone.mini_net_set = self.mini_net_set.clone

          a_clone
        end
      end
    end
  end
end
