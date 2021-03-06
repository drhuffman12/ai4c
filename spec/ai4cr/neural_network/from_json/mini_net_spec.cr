require "./../../../spectator_helper"

Spectator.describe "from_json" do
  describe "Ai4cr::NeuralNetwork::Cmn::MiniNet" do
    describe "#to_json and #from_json" do
      context "correctly exports and imports" do
        let(height) { 3 }
        let(width) { 2 }

        let(orig) { Ai4cr::NeuralNetwork::Cmn::MiniNet.new(height: height, width: width) }

        let(inputs_given) { [0.1, 0.2, 0.3] }
        let(outputs_expected) { [0.4, 0.5] }

        pending "the whole object" do
          # NOTE: Due to rounding errors of Float64 values during import and export of JSON, this test might fail; just re-run.

          a = JSON.parse(orig.to_json)

          a_copy = orig.class.from_json(orig.to_json)
          b = JSON.parse(a_copy.to_json)

          # NOTE: For now, mark as 'pending', but ...
          #   There are float rounding discrepancies between to/from json values.
          assert_approximate_equality_of_nested_list(b, a, 1.0e-15)
        end

        context "parts" do
          let(a_copy) { orig.class.from_json(orig.to_json) }

          it "width" do
            expect(a_copy.width).to eq(orig.width)
          end

          it "height" do
            expect(a_copy.height).to eq(orig.height)
          end

          it "height_considering_bias" do
            expect(a_copy.height_considering_bias).to eq(orig.height_considering_bias)
          end

          it "width_indexes" do
            expect(a_copy.width_indexes).to eq(orig.width_indexes)
          end

          it "height_indexes" do
            expect(a_copy.height_indexes).to eq(orig.height_indexes)
          end

          it "inputs_given" do
            assert_approximate_equality_of_nested_list(orig.inputs_given, a_copy.inputs_given)
          end

          it "outputs_guessed" do
            assert_approximate_equality_of_nested_list(orig.outputs_guessed, a_copy.outputs_guessed)
          end

          it "weights" do
            assert_approximate_equality_of_nested_list(orig.weights, a_copy.weights)
          end

          it "last_changes" do
            assert_approximate_equality_of_nested_list(orig.last_changes, a_copy.last_changes)
          end

          pending "error_stats.distance" do
            # NOTE: For now, mark as 'pending', but ...
            #   There are float rounding discrepancies between to/from json values.
            assert_approximate_equality_of_nested_list(orig.error_stats.distance, a_copy.error_stats.distance)
          end

          it "outputs_expected" do
            assert_approximate_equality_of_nested_list(orig.outputs_expected, a_copy.outputs_expected)
          end

          it "input_deltas" do
            assert_approximate_equality_of_nested_list(orig.input_deltas, a_copy.input_deltas)
          end

          it "output_deltas" do
            assert_approximate_equality_of_nested_list(orig.output_deltas, a_copy.output_deltas)
          end

          it "bias_disabled" do
            expect(a_copy.bias_disabled).to eq(orig.bias_disabled)
          end

          it "learning_rate" do
            # expect(a_copy.learning_rate).to eq(orig.learning_rate)
            assert_approximate_equality(orig.learning_rate, a_copy.learning_rate)
          end

          it "momentum" do
            assert_approximate_equality(orig.momentum, a_copy.momentum)
          end

          it "error_stats.history_size" do
            assert_approximate_equality(orig.error_stats.history_size, a_copy.error_stats.history_size)
          end

          it "error_stats.history" do
            assert_approximate_equality_of_nested_list(orig.error_stats.history, a_copy.error_stats.history)
          end

          it "learning_styles" do
            expect(a_copy.learning_styles).to eq(orig.learning_styles)
          end

          it "deriv_scale" do
            assert_approximate_equality(orig.deriv_scale, a_copy.deriv_scale)
          end
        end
      end
    end
  end
end
