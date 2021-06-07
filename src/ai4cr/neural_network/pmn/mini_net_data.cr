module Ai4cr
  module NeuralNetwork
    module Pmn
      class MiniNetData
        include JSON::Serializable

        # LEARNING_STYLES_DEFAULT = LS_RELU

        # # calc_guess props
        # property learning_styles = LEARNING_STYLES_DEFAULT

        # property bias_default = 1.0
        # property bias_disabled = false
        # property learning_rate : Float64 = Ai4cr::Utils::Rand.rand_excluding
        # property momentum : Float64 = Ai4cr::Utils::Rand.rand_excluding

        # property deriv_scale : Float64 = Ai4cr::Utils::Rand.rand_excluding(scale: 0.5)

        getter node : ParallelNode
        # getter training_config : TrainingConfig
        getter name : String
        # getter width : Int32

        # getter height_set : HeightSet
        # getter height_set_indexes : HeightSetIndexes
        # getter height : Int32
        # getter height_with_bias : Int32

        getter errors = Hash(Symbol, String).new

        getter weight_sets = Hash(String, Array(Array(Float64))).new

        # def initialize(@training_config = TrainingConfig.new, @height_set = HeightSet.new, @width = 0)
        def initialize(
          @node : ParallelNode,
          @name = ""
          # @training_config = TrainingConfig.new,
          # @name = "",
          # @width = 0
        )
          # @height_set = HeightSet.new
          # @height_set_indexes = HeightSetIndexes.new
          # upsert_height(from_channel: "bias", from_offset: [0], height: 1) if bias_enabled
          # reset_height_set_indexes
          validate
        end

        def validate
          @errors = Hash(Symbol, String).new
        end

        def valid?
          @errors.empty?
        end

        def training_config
          node.training_config
        end

        def coord
          node.coord
        end

        def width
          node.width
        end

        def bias_enabled
          training_config.bias_enabled
        end

        # # def reset_height_set_indexes
        # #   h_from = 0

        # #   @height_set.map_with_index do |h, i|
        # #     h_to = h_from + h - 1
        # #     range = (h_from..h_to)
        # #     h_from += h
        # #   end
        # # end

        # getter height_considering_bias = -1
        # getter width_indexes = Array(Int32).new
        # getter height_indexes = Array(Int32).new

        # property weight_init_scale : Float64
        # property weights = Array(Array(Float64)).new

        # property inputs_given = Array(Float64).new
        # property outputs_guessed = Array(Float64).new

        # # train_and_adjust props
        # property outputs_expected = Array(Float64).new
        # property output_deltas = Array(Float64).new
        # property last_changes = Array(Array(Float64)).new # aka previous weights
        # property output_errors = Array(Float64).new
        # property input_deltas = Array(Float64).new

        # def config
        #   {
        #     height:          @height,
        #     width:           @width,
        #     learning_styles: @learning_styles,

        #     deriv_scale: @deriv_scale,

        #     bias_disabled: @bias_disabled,
        #     bias_default:  @bias_default,

        #     learning_rate: @learning_rate,
        #     momentum:      @momentum,
        #     history_size:  history_size,

        #     name:              name,
        #     weight_init_scale: @weight_init_scale,
        #   }
        # end

        # def clone
        #   a_clone = self.class.new(
        #     height: self.height, width: self.width,
        #     learning_styles: self.learning_styles,

        #     deriv_scale: self.deriv_scale,

        #     bias_disabled: self.bias_disabled, bias_default: self.bias_default,

        #     learning_rate: self.learning_rate, momentum: self.momentum,
        #     history_size: self.history_size,

        #     name: self.name
        #   )

        #   # calc_guess
        #   a_clone.weights = self.weights.clone
        #   a_clone.inputs_given = self.inputs_given.clone
        #   a_clone.outputs_guessed = self.outputs_guessed.clone

        #   # train_and_adjust
        #   a_clone.outputs_expected = self.outputs_expected.clone
        #   a_clone.output_deltas = self.output_deltas.clone
        #   a_clone.last_changes = self.last_changes.clone
        #   a_clone.output_errors = self.output_errors.clone
        #   a_clone.input_deltas = self.input_deltas.clone

        #   a_clone
        # end

        # def initialize(
        #   @height = 2, @width = 2,
        #   @learning_styles : LearningStyle = LEARNING_STYLES_DEFAULT,

        #   @deriv_scale = Ai4cr::Utils::Rand.rand_excluding(scale: 0.5),

        #   bias_disabled = false, @bias_default = 1.0,

        #   @learning_rate : Float64? = nil, momentum : Float64? = nil,
        #   history_size : Int32 = 10,

        #   name : String? = "",

        #   @weight_init_scale = 1.0
        # )
        #   # TODO: switch 'bias_disabled' to 'bias_enabled' and adjust defaulting accordingly
        #   @bias_disabled = bias_disabled

        #   # Will be updated from 'internal' mini_net
        #   @learning_rate = learning_rate.nil? || learning_rate.as(Float64) <= 0.0 ? Ai4cr::Utils::Rand.rand_excluding : learning_rate.as(Float64)
        #   @momentum = momentum && momentum.as(Float64) > 0.0 ? momentum.as(Float64) : Ai4cr::Utils::Rand.rand_excluding

        #   @name = name.nil? ? "" : name

        #   init_network

        #   @error_stats = Ai4cr::ErrorStats.new(history_size)
        # end

        # def structure
        #   [height, width]
        # end

        # def init_network
        #   init_net_re_structure
        #   init_net_re_guess
        #   init_net_re_train
        # end

        # def init_net_re_structure
        #   @height_considering_bias = @height + (@bias_disabled ? 0 : 1)
        #   @height_indexes = Array.new(@height_considering_bias) { |i| i }
        #   @width_indexes = Array.new(width) { |i| i }
        #   # Weight initialization (https://medium.com/datadriveninvestor/deep-learning-best-practices-activation-functions-weight-initialization-methods-part-1-c235ff976ed)
        #   # * Xavier initialization mostly used with tanh and logistic activation function
        #   # * He-initialization mostly used with ReLU or it’s variants — Leaky ReLU.

        #   # @weights = @height_indexes.map { @width_indexes.map { @weight_init_scale * Ai4cr::Utils::Rand.rand_neg_one_to_pos_one_no_zero } }

        #   @weights = @height_indexes.map do
        #     @width_indexes.map do
        #       w = @weight_init_scale * Ai4cr::Utils::Rand.rand_neg_one_to_pos_one_no_zero
        #       # (w.nan? ? 0.0 : w)
        #       Float64.avoid_extremes(w)
        #     end
        #   end
        # end

        # def init_net_re_guess
        #   @inputs_given = Array.new(@height_considering_bias, 0.0)
        #   @inputs_given[-1] = bias_default unless @bias_disabled
        #   @outputs_guessed = Array.new(width, 0.0)
        # end

        # def init_net_re_train
        #   @outputs_expected = Array.new(width, 0.0)
        #   @output_deltas = Array.new(width, 0.0)

        #   @last_changes = Array.new(@height_considering_bias, Array.new(width, 0.0))
        #   @output_errors = @width_indexes.map { 0.0 }
        #   @input_deltas = Array.new(@height_considering_bias, 0.0)
        # end

        # # misc guesses*
        # def guesses_best
        #   # TODO: Make this JSON-loadable and customizable
        #   case @learning_styles
        #   when LS_PRELU # LearningStyle::Prelu
        #     guesses_ceiled
        #   when LS_RELU # LearningStyle::Rel
        #     guesses_ceiled
        #   when LS_SIGMOID # LearningStyle::Sigmoid
        #     guesses_rounded
        #   when LS_TANH # LearningStyle::Tanh
        #     guesses_rounded
        #   else
        #     raise "Unsupported LearningStyle"
        #   end
        # end

        # # def guesses_best
        # #   # default set below, but might be different per subclass
        # #   guesses_as_is
        # # end

        # def guesses_as_is
        #   # outputs_guessed in sorted/top/bottom/etc order
        #   @outputs_guessed
        # end

        # def guesses_sorted
        #   @outputs_guessed.map_with_index { |o, idx| [idx, o].sort }
        # end

        # def guesses_rounded
        #   # good for MiniNet::Sigmoid; and maybe MiniNetRanh
        #   @outputs_guessed.map(&.round)
        # end

        # def guesses_ceiled
        #   # good for Relu
        #   @outputs_guessed.map(&.ceil)
        # end

        # def guesses_top_n(n = @outputs_guessed.size)
        #   guesses_sorted[0..(n - 1)]
        # end

        # def guesses_bottom_n(n = @outputs_guessed.size)
        #   guesses_sorted.reverse[0..(n - 1)]
        # end
      end
    end
  end
end
