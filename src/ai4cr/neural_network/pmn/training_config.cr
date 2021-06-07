module Ai4cr
  module NeuralNetwork
    module Pmn
      class TrainingConfig
        include JSON::Serializable

        LEARNING_STYLES_DEFAULT = [LS_RELU]

        getter learning_rate : Float64 = 0.5
        getter momentum : Float64 = 0.5
        getter bias_enabled = false
        getter bias_default = 1.0
        getter learning_styles : Array(LearningStyle) = LEARNING_STYLES_DEFAULT
        getter deriv_scale : Float64 = Ai4cr::Utils::Rand.rand_excluding(scale: 0.5)
        getter weight_init_scale = 1.0
        getter history_size : Int32 = 10

        def initialize(
          learning_rate = 0.5,
          momentum = 0.5,
          bias_enabled = false,
          bias_default = 1.0,
          learning_styles = LEARNING_STYLES_DEFAULT,
          deriv_scale = Ai4cr::Utils::Rand.rand_excluding(scale: 0.5),
          weight_init_scale = 1.0,
          history_size = 10
        )
          @errors = ValidationErrorMessages.new

          validate
        end

        def validate
          @errors = ValidationErrorMessages.new

          @errors["learning_rate"] = "Must be Positive" if @learning_rate <= 0.0
          @errors["momentum"] = "Must be Positive" if @momentum <= 0.0
          @errors["bias_default"] = "Must be Positive" if @bias_default <= 0.0
          @errors["deriv_scale"] = "Must be Positive" if @deriv_scale <= 0.0
          @errors["weight_init_scale"] = "Must be Positive" if @weight_init_scale <= 0.0
          @errors["history_size"] = "Must be Positive" if @history_size <= 0
        end

        def valid?
          @errors.empty?
        end
      end
    end
  end
end
