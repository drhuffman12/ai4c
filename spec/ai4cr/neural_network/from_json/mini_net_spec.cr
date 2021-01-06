require "./../../../spec_helper"
require "./../../../spectator_helper"

Spectator.describe "from_json" do
  describe "Ai4cr::NeuralNetwork::Cmn::MiniNet" do
    let(klass) { Ai4cr::NeuralNetwork::Cmn::MiniNet }

    context "defaults" do
      let(height) { 3 }
      let(width) { 2 }

      let(mini_net) { klass.new(height: height, width: width) }

      context "correctly exports and imports" do
        let(orig) { mini_net }
        let(tj) { orig.to_json }
        let(fj) { klass.from_json(tj) }

        xit "the whole object" do
          # Maybe the nesting level or rounding causes issues?
          expect(fj).to eq(orig)
          # expect(fj.to_json).to eq(orig.to_json)
          # TODO: add JSON-friendly versions of below!
          # assert_approximate_equality_of_nested_list(orig.to_json, fj.to_json)
        end

        it "width" do
          expect(fj.width).to eq(orig.width)
        end

        it "height" do
          expect(fj.height).to eq(orig.height)
        end

        it "height_considering_bias" do
          expect(fj.height_considering_bias).to eq(orig.height_considering_bias)
        end

        it "width_indexes" do
          expect(fj.width_indexes).to eq(orig.width_indexes)
        end

        it "height_indexes" do
          expect(fj.height_indexes).to eq(orig.height_indexes)
        end

        it "inputs_given" do
          assert_approximate_equality_of_nested_list(orig.inputs_given, fj.inputs_given)
        end

        it "outputs_guessed" do
          assert_approximate_equality_of_nested_list(orig.outputs_guessed, fj.outputs_guessed)
        end

        it "weights" do
          assert_approximate_equality_of_nested_list(orig.weights, fj.weights)
        end

        it "last_changes" do
          assert_approximate_equality_of_nested_list(orig.last_changes, fj.last_changes)
        end

        it "error_total" do
          assert_approximate_equality_of_nested_list(orig.error_total, fj.error_total)
        end

        it "outputs_expected" do
          assert_approximate_equality_of_nested_list(orig.outputs_expected, fj.outputs_expected)
        end

        it "input_deltas" do
          assert_approximate_equality_of_nested_list(orig.input_deltas, fj.input_deltas)
        end

        it "output_deltas" do
          assert_approximate_equality_of_nested_list(orig.output_deltas, fj.output_deltas)
        end

        it "disable_bias" do
          expect(fj.disable_bias).to eq(orig.disable_bias)
        end

        it "learning_rate" do
          # expect(fj.learning_rate).to eq(orig.learning_rate)
          assert_approximate_equality(orig.learning_rate, fj.learning_rate)
        end

        it "momentum" do
          assert_approximate_equality(orig.momentum, fj.momentum)
        end

        # it "error_distance" do
        #   assert_approximate_equality(orig.error_distance, fj.error_distance)
        # end

        it "error_distance_history_max" do
          assert_approximate_equality(orig.error_distance_history_max, fj.error_distance_history_max)
        end

        it "error_distance_history" do
          assert_approximate_equality_of_nested_list(orig.error_distance_history, fj.error_distance_history)
        end

        it "learning_style" do
          expect(fj.learning_style).to eq(orig.learning_style)
        end

        it "deriv_scale" do
          assert_approximate_equality(orig.deriv_scale, fj.deriv_scale)
        end
      end
    end
  end
end
