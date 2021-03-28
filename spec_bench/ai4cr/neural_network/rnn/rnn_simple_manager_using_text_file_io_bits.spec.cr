require "../../../../spec/spectator_helper"
require "../../../spec_bench_helper"
# require "../../../support/neural_network/data/*"

# puts Char::MAX_CODEPOINT
# puts Char::MAX_CODEPOINT.class
# # puts Char::MAX_CODEPOINT.ord

# puts Char::REPLACEMENT.ord
# puts Char::REPLACEMENT.ord > Char::MAX_CODEPOINT

# def bits_to_charaf(a)
#   puts a
#   b = a.map_with_index {|av, i| av * (2.0**i)}
#   puts b
#   puts b.sum
#   b.sum / Char::MAX_CODEPOINT
# end

# def bytes_to_charaf(bytes)
#   bytes.map{|b| [bits_to_charaf(b)]}

# end

#   a = [
#         1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0,
#         0.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0,
#         0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
#         0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
#       ]
# bytes = [
#       [
#         0.0, 1.0, 1.0, 1.0, 0.0, 1.0, 0.0, 0.0,
#         0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
#         0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
#         0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
#       ],
#       [
#         0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0,
#         0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
#         0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
#         0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
#       ],
#       [
#         0.0, 1.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0,
#         0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
#         0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
#         0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
#       ],
#     ]
# puts bits_to_charaf(a)
# puts bytes_to_charaf(bytes)

Spectator.describe Ai4cr::NeuralNetwork::Rnn::RnnSimpleManager do
  def compare_successive_training_rounds(
    io_offset, time_col_qty,
    inputs_sequence, outputs_sequence,
    hidden_layer_qty, hidden_size_given,
    qty_new_members,
    my_breed_manager, max_members,
    train_qty
  )
    # it "successive generations score better (i.e.: lower errors)" do
    # TODO: (a) move to 'spec_bench' and (b) replace here with more 'always' tests

    puts
    puts "v"*40
    puts "successive generations score better (?) .. max_members: #{max_members} .. start"
    when_before = Time.local
    puts "when_before: #{when_before}"
    puts "file_path: #{file_path}"
    puts

    params = Ai4cr::NeuralNetwork::Rnn::RnnSimple.new(
      io_offset: io_offset,
      time_col_qty: time_col_qty,
      input_size: inputs_sequence.first.first.size,
      output_size: outputs_sequence.first.first.size,
      hidden_layer_qty: hidden_layer_qty,
      hidden_size_given: hidden_size_given
    ).config

    # puts
    # puts "first_gen_members: #{first_gen_members}"
    puts "inputs_sequence.size: #{inputs_sequence.size}"
    puts "inputs_sequence.first.size: #{inputs_sequence.first.size}"
    puts "inputs_sequence.first.first.size: #{inputs_sequence.first.first.size}"
    puts "inputs_sequence.class: #{inputs_sequence.class}"
    puts "outputs_sequence.class: #{outputs_sequence.class}"
    puts "params: #{params}"

    puts "* build/train teams"
    puts "\n  * first_gen_members (building)..."
    first_gen_members = my_breed_manager.build_team(qty_new_members, **params)
    puts "\n  * second_gen_members (breeding and training; after training first_gen_members)..."
    second_gen_members = my_breed_manager.train_team_using_sequence(inputs_sequence, outputs_sequence, first_gen_members, io_set_text_file, max_members, train_qty)
    puts "\n  * third_gen_members (breeding and training; after training second_gen_members) ..."
    third_gen_members = my_breed_manager.train_team_using_sequence(inputs_sequence, outputs_sequence, second_gen_members, io_set_text_file, max_members, train_qty)

    puts "* score and stats ..."
    # puts "  * first_gen_members ..."
    p "."
    first_gen_members_scored = first_gen_members.map { |member| member.error_stats.score }.sum / qty_new_members
    first_gen_members_stats = first_gen_members.map { |member| member.error_hist_stats }

    # puts "  * second_gen_members ..."
    p "."
    second_gen_members_scored = second_gen_members.map { |member| member.error_stats.score }.sum / qty_new_members
    second_gen_members_stats = second_gen_members.map { |member| member.error_hist_stats }

    # puts "  * third_gen_members ..."
    p "."
    third_gen_members_scored = third_gen_members.map { |member| member.error_stats.score }.sum / qty_new_members
    third_gen_members_stats = third_gen_members.map { |member| member.error_hist_stats }

    puts
    puts "#train_team_using_sequence (text from Bible):"
    puts
    puts "first_gen_members_scored: #{first_gen_members_scored}"
    first_gen_members_stats.each { |m| puts m }

    puts
    puts "second_gen_members_scored: #{second_gen_members_scored}"
    second_gen_members_stats.each { |m| puts m }

    puts
    puts "third_gen_members_scored: #{third_gen_members_scored}"
    third_gen_members_stats.each { |m| puts m }

    when_after = Time.local
    puts "when_after: #{when_after}"
    when_delta = when_after - when_before
    puts "when_delta: #{(when_delta.total_seconds / 60.0).round(1)} minutes
      "
    puts
    puts "successive generations score better (?) .. max_members: #{max_members} .. end"
    puts "-"*40
    puts

    expect(second_gen_members_scored).to be < first_gen_members_scored
    expect(third_gen_members_scored).to be < second_gen_members_scored

    # end
    # rescue e
    #   # puts "e:"
    #   # puts "  class: #{e.class}"
    #   # puts "  message: #{e.message}"
    #   # puts "  backtrace: #{e.backtrace}"
    #   raise e
    # ensure
    #   when_after = Time.local
    #   puts "when_after: #{when_after}"
    #   when_delta = when_after - when_before
    #   puts "when_delta: #{when_delta.total_seconds / 60.0} minutes
    #   "
    #   puts
    #   puts "successive generations score better (?) .. max_members: #{max_members} .. end"
    #   puts "-"*40
    #   puts
  end

  let(my_breed_manager) { Ai4cr::NeuralNetwork::Rnn::RnnSimpleManager.new }

  let(train_qty) { 1 }

  let(ancestor_adam_value) { 0.1 }
  let(ancestor_eve_value) { 0.9 }

  let(config_default_randomized) {
    Ai4cr::NeuralNetwork::Rnn::RnnSimple.new.config
  }

  let(config_adam) {
    config_default_randomized.merge(
      name: "Adam",

      bias_disabled: false,
      bias_default: (ancestor_adam_value / 2.0).round(1),

      learning_rate: ancestor_adam_value,
      # momentum: (1.0 - ancestor_adam_value).round(1),
      momentum: ancestor_adam_value,
      deriv_scale: (ancestor_adam_value / 4.0).round(1),

      history_size: 3
    )
  }

  let(config_eve) {
    config_default_randomized.merge(
      name: "Eve",

      bias_disabled: false,
      bias_default: (ancestor_eve_value / 2.0).round(1),

      learning_rate: ancestor_eve_value,
      # momentum: (1.0 - ancestor_eve_value).round(1),
      momentum: ancestor_eve_value,
      deriv_scale: (ancestor_eve_value / 4.0).round(1),

      history_size: 3
    )
  }
  let(ancestor_adam) {
    ancestor = my_breed_manager.create(**config_adam)
    ancestor.mini_net_set.each do |mini_net_li|
      mini_net_li.each do |mini_net_ti|
        mini_net_ti.weights.map_with_index! do |row, i|
          row.map_with_index! do |_col, j|
            (i + j / 10.0).round(1)
          end
        end
      end
    end
    ancestor.train(inputs, outputs)
    # ancestor.train(inputs, outputs)
    ancestor
  }
  let(ancestor_eve) {
    ancestor = my_breed_manager.create(**config_eve)
    ancestor.mini_net_set.each do |mini_net_li|
      mini_net_li.each do |mini_net_ti|
        mini_net_ti.weights.map_with_index! do |row, i|
          row.map_with_index! do |_col, j|
            -(i + j / 10.0).round(1)
          end
        end
      end
    end
    ancestor.train(inputs, outputs)
    # ancestor.train(inputs, outputs)
    ancestor
  }

  let(inputs) {
    [
      [0.1, 0.2],
      [0.3, 0.4],
    ]
  }
  let(outputs) {
    [
      [0.1],
      [0.9],
    ]
  }

  let(inputs_sequence) {
    [
      [
        [0.1, 0.2],
        [0.3, 0.4],
      ],
      [
        [0.3, 0.4],
        [0.5, 0.6],
      ],
      [
        [0.5, 0.6],
        [0.7, 0.8],
      ],
    ]
  }
  let(outputs_sequence) {
    [
      [
        [0.1],
        [0.9],
      ],
      [
        [0.9],
        [0.5],
      ],
      [
        [0.5],
        [0.3],
      ],
    ]
  }

  describe "#train_team" do
    it "successive generations score better (i.e.: lower errors)" do
      # TODO: (a) move to 'spec_bench' and (b) replace here with more 'always' tests
      max_members = 10
      qty_new_members = max_members

      params = Ai4cr::NeuralNetwork::Rnn::RnnSimple.new.config

      first_gen_members = my_breed_manager.build_team(qty_new_members, **params)
      second_gen_members = my_breed_manager.train_team(inputs, outputs, first_gen_members, max_members)
      third_gen_members = my_breed_manager.train_team(inputs, outputs, second_gen_members, max_members)

      first_gen_members_scored = first_gen_members.map { |member| member.error_stats.score }.sum / qty_new_members
      first_gen_members_stats = first_gen_members.map { |member| member.error_hist_stats }

      second_gen_members_scored = second_gen_members.map { |member| member.error_stats.score }.sum / qty_new_members
      second_gen_members_stats = second_gen_members.map { |member| member.error_hist_stats }

      third_gen_members_scored = third_gen_members.map { |member| member.error_stats.score }.sum / qty_new_members
      third_gen_members_stats = third_gen_members.map { |member| member.error_hist_stats }

      puts
      puts "#train_team:"
      puts
      puts "first_gen_members_scored: #{first_gen_members_scored}"
      first_gen_members_stats.each { |m| puts m }

      puts
      puts "second_gen_members_scored: #{second_gen_members_scored}"
      second_gen_members_stats.each { |m| puts m }

      puts
      puts "third_gen_members_scored: #{third_gen_members_scored}"
      third_gen_members_stats.each { |m| puts m }

      expect(second_gen_members_scored).to be < first_gen_members_scored
      expect(third_gen_members_scored).to be < second_gen_members_scored
    end
  end

  describe "#train_team_using_sequence" do
    context "when using an arbitrary set of float values for io" do
      it "successive generations score better (i.e.: lower errors)" do
        # TODO: (a) move to 'spec_bench' and (b) replace here with more 'always' tests
        max_members = 10
        qty_new_members = max_members

        params = Ai4cr::NeuralNetwork::Rnn::RnnSimple.new.config

        first_gen_members = my_breed_manager.build_team(qty_new_members, **params)
        second_gen_members = my_breed_manager.train_team_using_sequence(inputs_sequence, outputs_sequence, first_gen_members, io_set_text_file, max_members, train_qty)
        third_gen_members = my_breed_manager.train_team_using_sequence(inputs_sequence, outputs_sequence, second_gen_members, io_set_text_file, max_members, train_qty)

        first_gen_members_scored = first_gen_members.map { |member| member.error_stats.score }.sum / qty_new_members
        first_gen_members_stats = first_gen_members.map { |member| member.error_hist_stats }

        second_gen_members_scored = second_gen_members.map { |member| member.error_stats.score }.sum / qty_new_members
        second_gen_members_stats = second_gen_members.map { |member| member.error_hist_stats }

        third_gen_members_scored = third_gen_members.map { |member| member.error_stats.score }.sum / qty_new_members
        third_gen_members_stats = third_gen_members.map { |member| member.error_hist_stats }

        puts
        puts "#train_team_using_sequence (arbitrary set of float values):"
        puts
        puts "first_gen_members_scored: #{first_gen_members_scored}"
        first_gen_members_stats.each { |m| puts m }

        puts
        puts "second_gen_members_scored: #{second_gen_members_scored}"
        second_gen_members_stats.each { |m| puts m }

        puts
        puts "third_gen_members_scored: #{third_gen_members_scored}"
        third_gen_members_stats.each { |m| puts m }

        expect(second_gen_members_scored).to be < first_gen_members_scored
        expect(third_gen_members_scored).to be < second_gen_members_scored
      end
    end

    context "when using a text file as io data" do
      # let(float_bits_from_file) { Ai4cr::Utils::Rand.text_file_to_fiod(file_path) }

      # let(train_qty) { 4 }
      # let(train_qty) { 8 }

      # Matching params in https://gist.github.com/karpathy/d4dee566867f8291f086
      # See also: https://github.com/karpathy/char-rnn
      let(train_qty) { 4 } # aka ??? aka ???
      # let(hidden_size_given) { 100 } # aka 'hidden_size'
      # let(hidden_size_given) { 160 } # aka 'hidden_size'
      let(hidden_size_given) { 200 } # aka 'hidden_size'
      # let(hidden_size_given) { 250 } # aka 'hidden_size'
      # let(hidden_size_given) { 290 } # aka 'hidden_size'
      # let(hidden_size_given) { 300 } # aka 'hidden_size'
      # let(hidden_size_given) { 320 } # aka 'hidden_size'
      let(time_col_qty) { 25 }    # aka 'seq_length' aka 'rnn_size'
      let(hidden_layer_qty) { 3 } # aka ??? aka 'num_layers'

      # # small rnn:
      # let(train_qty) { 4 }         # aka ??? aka ???
      # let(hidden_size_given) { 0 } # aka 'hidden_size'
      # let(time_col_qty) { 8 }      # aka 'seq_length' aka 'rnn_size'
      # let(hidden_layer_qty) { 2 }  # aka ??? aka 'num_layers'

      # let(io_offset) { (time_col_qty / 2).to_i }
      let(io_offset) { time_col_qty }
      let(prefix_raw_qty) { 0 }

      # # mid-sized rnn:
      # let(train_qty) { 2 } # aka ??? aka ???
      # # let(hidden_size_given) { 0 } # aka 'hidden_size'
      # # let(hidden_size_given) { 16 } # aka 'hidden_size'
      # let(hidden_size_given) { 320 } # aka 'hidden_size'
      # let(time_col_qty) { 6 }        # aka 'seq_length' aka 'rnn_size'
      # let(hidden_layer_qty) { 1 }    # aka ??? aka 'num_layers'

      # let(hidden_size_given) { 0 }
      # let(hidden_size_given) { 16 }

      # let(time_col_qty) { 4 }
      # let(hidden_layer_qty) { 1 }

      # let(time_col_qty) { 8 }
      # let(hidden_layer_qty) { 1 }

      # let(time_col_qty) { 8 }
      # let(hidden_layer_qty) { 2 }

      # let(time_col_qty) { 8 }
      # let(hidden_layer_qty) { 4 }

      # let(time_col_qty) { 10 }
      # let(hidden_layer_qty) { 4 }

      # let(time_col_qty) { 12 } # Might need to scale down the initial weights for this (and likewise for below)!
      # let(hidden_layer_qty) { 4 }

      # let(time_col_qty) { 16 }
      # let(hidden_layer_qty) { 1 }

      # let(time_col_qty) { 16 }
      # let(hidden_layer_qty) { 2 }

      # let(time_col_qty) { 16 }
      # let(hidden_layer_qty) { 4 }

      # # from ???
      # # /home/drhuffman/.crenv/versions/0.36.0/share/crystal/src/primitives.cr:255:3 in 'run'
      # #   from ???
      # # src/ai4cr/breed/manager.cr:105:17 in 'breed'
      # #   from src/ai4cr/breed/manager.cr:269:30 in '->'
      # #   from ???src/ai4cr/breed/manager.cr:105:17 in 'breed'

      # let(io_offset) { time_col_qty }

      let(file_type_raw) { Ai4cr::Utils::IoData::FileType::Raw }
      let(file_type_iod) { Ai4cr::Utils::IoData::FileType::Iod }
      # let(prefix_raw_qty) { time_col_qty }
      let(prefix_raw_char) { " " }
      let(default_to_bit_size) { 8 }

      let(io_set_text_file) do
        Ai4cr::Utils::IoData::TextFileIodBits.new(
          file_path, file_type_raw,
          prefix_raw_qty, prefix_raw_char,
          default_to_bit_size
        )
      end

      let(raw) { io_set_text_file.raw }
      let(iod) { io_set_text_file.iod }

      let(ios) { io_set_text_file.iod_to_io_set_with_offset_time_cols(time_col_qty, io_offset) }
      # let(input_set) { ios[:input_set] }
      # let(output_set) { ios[:output_set] }
      let(inputs_sequence) { ios[:input_set] }
      let(outputs_sequence) { ios[:output_set] }

      context "when the text file is very tiny (about 4kB)" do
        let(file_path) { "./spec_bench/support/neural_network/data/bible_utf/eng-web_002_GEN_01_read.txt" }

        context "with a RNN team of size" do
          let(qty_new_members) { max_members }

          # context "1" do
          #   let(max_members) { 1 }

          #   it "successive generations score better (i.e.: lower errors)" do
          #     compare_successive_training_rounds(
          #       io_offset, time_col_qty,
          #       inputs_sequence, outputs_sequence,
          #       hidden_layer_qty, hidden_size_given,
          #       qty_new_members,
          #       my_breed_manager, max_members, train_qty
          #     )
          #   end
          # end

          context "10" do
            let(max_members) { 10 }

            it "successive generations score better (i.e.: lower errors)" do
              compare_successive_training_rounds(
                io_offset, time_col_qty,
                inputs_sequence, outputs_sequence,
                hidden_layer_qty, hidden_size_given,
                qty_new_members,
                my_breed_manager, max_members, train_qty
              )
            end
          end

          # context "2" do
          #   let(max_members) { 2 }

          #   it "successive generations score better (i.e.: lower errors)" do
          #     compare_successive_training_rounds(
          #       io_offset, time_col_qty,
          #       inputs_sequence, outputs_sequence,
          #       hidden_layer_qty, hidden_size_given,
          #       qty_new_members,
          #       my_breed_manager, max_members, train_qty
          #     )
          #   end
          # end

          context "3" do
            let(max_members) { 3 }

            it "successive generations score better (i.e.: lower errors)" do
              compare_successive_training_rounds(
                io_offset, time_col_qty,
                inputs_sequence, outputs_sequence,
                hidden_layer_qty, hidden_size_given,
                qty_new_members,
                my_breed_manager, max_members, train_qty
              )
            end
          end

          context "4" do
            let(max_members) { 4 }

            it "successive generations score better (i.e.: lower errors)" do
              compare_successive_training_rounds(
                io_offset, time_col_qty,
                inputs_sequence, outputs_sequence,
                hidden_layer_qty, hidden_size_given,
                qty_new_members,
                my_breed_manager, max_members, train_qty
              )
            end
          end

          context "8" do
            let(max_members) { 8 }

            pending "successive generations score better (i.e.: lower errors)" do
              compare_successive_training_rounds(
                io_offset, time_col_qty,
                inputs_sequence, outputs_sequence,
                hidden_layer_qty, hidden_size_given,
                qty_new_members,
                my_breed_manager, max_members, train_qty
              )
            end
          end

          # context "16" do
          #   let(max_members) { 16 }

          #   # TODO: How many team members shall/can we try?
          #   #   Currently, we're getting:
          #   #     mmap(PROT_NONE) failed
          #   #     Program received and didn't handle signal IOT (6)
          #   pending "successive generations score better (i.e.: lower errors)" do
          #     compare_successive_training_rounds(
          #       io_offset, time_col_qty,
          #       inputs_sequence, outputs_sequence,
          #       hidden_layer_qty, hidden_size_given,
          #       qty_new_members,
          #       my_breed_manager, max_members, train_qty
          #     )
          #   end
          # end
        end
      end

      context "when the text file is tiny (about 8kB)" do
        let(file_path) { "./spec_bench/support/neural_network/data/bible_utf/eng-web_002_GEN_chap1-2.txt" }

        context "with a RNN team of size" do
          let(qty_new_members) { max_members }

          # context "1" do
          #   let(max_members) { 1 }

          #   it "successive generations score better (i.e.: lower errors)" do
          #     compare_successive_training_rounds(
          #       io_offset, time_col_qty,
          #       inputs_sequence, outputs_sequence,
          #       hidden_layer_qty, hidden_size_given,
          #       qty_new_members,
          #       my_breed_manager, max_members, train_qty
          #     )
          #   end
          # end

          # context "2" do
          #   let(max_members) { 2 }

          #   it "successive generations score better (i.e.: lower errors)" do
          #     compare_successive_training_rounds(
          #       io_offset, time_col_qty,
          #       inputs_sequence, outputs_sequence,
          #       hidden_layer_qty, hidden_size_given,
          #       qty_new_members,
          #       my_breed_manager, max_members, train_qty
          #     )
          #   end
          # end

          context "3" do
            let(max_members) { 3 }

            it "successive generations score better (i.e.: lower errors)" do
              compare_successive_training_rounds(
                io_offset, time_col_qty,
                inputs_sequence, outputs_sequence,
                hidden_layer_qty, hidden_size_given,
                qty_new_members,
                my_breed_manager, max_members, train_qty
              )
            end
          end

          context "4" do
            let(max_members) { 4 }

            it "successive generations score better (i.e.: lower errors)" do
              compare_successive_training_rounds(
                io_offset, time_col_qty,
                inputs_sequence, outputs_sequence,
                hidden_layer_qty, hidden_size_given,
                qty_new_members,
                my_breed_manager, max_members, train_qty
              )
            end
          end

          context "8" do
            let(max_members) { 8 }

            pending "successive generations score better (i.e.: lower errors)" do
              compare_successive_training_rounds(
                io_offset, time_col_qty,
                inputs_sequence, outputs_sequence,
                hidden_layer_qty, hidden_size_given,
                qty_new_members,
                my_breed_manager, max_members, train_qty
              )
            end
          end

          #     # context "16" do
          #     #   let(max_members) { 16 }

          #     #   # TODO: How many team members shall/can we try?
          #     #   #   Currently, we're getting:
          #     #   #     mmap(PROT_NONE) failed
          #     #   #     Program received and didn't handle signal IOT (6)
          #     #   pending "successive generations score better (i.e.: lower errors)" do
          #     #     compare_successive_training_rounds(
          #     #       io_offset, time_col_qty,
          #     #       inputs_sequence, outputs_sequence,
          #     #       hidden_layer_qty, hidden_size_given,
          #     #       qty_new_members,
          #     #       my_breed_manager, max_members, train_qty
          #     #     )
          #     #   end
          #     # end
        end
      end

      context "when the text file is small (about 13kB)" do
        let(file_path) { "./spec_bench/support/neural_network/data/bible_utf/eng-web_002_GEN_chap1-4.txt" }

        context "with a RNN team of size" do
          let(qty_new_members) { max_members }

          # context "1" do
          #   let(max_members) { 1 }

          #   it "successive generations score better (i.e.: lower errors)" do
          #     compare_successive_training_rounds(
          #       io_offset, time_col_qty,
          #       inputs_sequence, outputs_sequence,
          #       hidden_layer_qty, hidden_size_given,
          #       qty_new_members,
          #       my_breed_manager, max_members, train_qty
          #     )
          #   end
          # end

          # context "2" do
          #   let(max_members) { 2 }

          #   it "successive generations score better (i.e.: lower errors)" do
          #     compare_successive_training_rounds(
          #       io_offset, time_col_qty,
          #       inputs_sequence, outputs_sequence,
          #       hidden_layer_qty, hidden_size_given,
          #       qty_new_members,
          #       my_breed_manager, max_members, train_qty
          #     )
          #   end
          # end

          context "3" do
            let(max_members) { 3 }

            it "successive generations score better (i.e.: lower errors)" do
              compare_successive_training_rounds(
                io_offset, time_col_qty,
                inputs_sequence, outputs_sequence,
                hidden_layer_qty, hidden_size_given,
                qty_new_members,
                my_breed_manager, max_members, train_qty
              )
            end
          end

          context "4" do
            let(max_members) { 4 }

            it "successive generations score better (i.e.: lower errors)" do
              compare_successive_training_rounds(
                io_offset, time_col_qty,
                inputs_sequence, outputs_sequence,
                hidden_layer_qty, hidden_size_given,
                qty_new_members,
                my_breed_manager, max_members, train_qty
              )
            end
          end

          context "8" do
            let(max_members) { 8 }

            pending "successive generations score better (i.e.: lower errors)" do
              compare_successive_training_rounds(
                io_offset, time_col_qty,
                inputs_sequence, outputs_sequence,
                hidden_layer_qty, hidden_size_given,
                qty_new_members,
                my_breed_manager, max_members, train_qty
              )
            end
          end

          #     # context "16" do
          #     #   let(max_members) { 16 }

          #     #   # TODO: How many team members shall/can we try?
          #     #   #   Currently, we're getting: (TBD)
          #     #   pending "successive generations score better (i.e.: lower errors)" do
          #     #     compare_successive_training_rounds(
          #     #       io_offset, time_col_qty,
          #     #       inputs_sequence, outputs_sequence,
          #     #       hidden_layer_qty, hidden_size_given,
          #     #       qty_new_members,
          #     #       my_breed_manager, max_members, train_qty
          #     #     )
          #     #   end
          #     # end
        end
      end
    end
  end
end