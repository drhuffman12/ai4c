module Ai4cr
  module Breed
    class StructureError < ArgumentError; end

    abstract class Manager(T)
      # To avoid Neural Networks's getting stuck on wrong answers,
      #   we introduce the option to
      #     (a) Train (1 or more times) a team of X members, where members are of compatible configurations,
      #         but have some value variations (e.g.: learning rate, weights, etc).
      #     (b) Cross-breed a team of NN's (to help avoid issues re gradient-descent and dead nodes) results in a new team including:
      #         * parents (as-is)
      #         * half of the children created via random delta offsets
      #         * half of the children created via an 'estimated-better' delta offset (trying to estimate a 'more zero' error configuration)
      #     (c) (Re-)train the parent team members and the child team members.
      #     (d) Keep only the top X scoring team members from the parent and the child teams.
      #     (e) This *should* cause the subsequent team's average error score to decrease.
      # One effect of this is that when training/cross-breeding/(re-)training,
      #   (a) the 'parent team members' don't get as many rounds of training
      #   (b) the 'child team members' help cover the range of possible NN configurations
      # So, you might want to try different team sizes and compare the results:
      #   * Smaller teams will get more training per NN.
      #   * Larger teams will get more configurations explored (and avoid getting stuck on wrong answers).
      # For example, see:
      #   * [spec/ai4cr/breed/manager_spec.cr](spec/ai4cr/breed/manager_spec.cr)
      #   * [spec_bench/ai4cr/neural_network/cmn/mini_net_manager_spec.cr](spec_bench/ai4cr/neural_network/cmn/mini_net_manager_spec.cr)

      # CHARTER = AsciiBarCharter.new(0.0, 1.0, 2.to_i8, true, false)
      CHARTER = begin
        min = 0.0
        max = 1.0
        precision = 2.to_i8
        in_bw = true
        reversed = false

        AsciiBarCharter.new(min: min, max: max, precision: precision, in_bw: in_bw, inverted_colors: reversed)
      end

      QTY_NEW_MEMBERS_DEFAULT = 10
      MAX_MEMBERS_DEFAULT     = QTY_NEW_MEMBERS_DEFAULT
      PURGE_ERROR_LIMIT_SCALE = 1 # 1e4 # 1e12

      STEP_MINOR = 4
      STEP_MAJOR = 4 * STEP_MINOR
      STEP_SAVE  = 4 * STEP_MAJOR

      ############################################################################
      # TODO: WHY is this required?
      # NOTE: Sub-classes MUST include the following two lines:
      include JSON::Serializable
      class_getter counter : CounterSafe::Exclusive = CounterSafe::Exclusive.new

      ############################################################################

      def initialize; end

      def counter
        @@counter
      end

      def counter_reset(value = 0)
        @@counter.reset(T.name, value)
      end

      def gen_params
        T.new.config
      end

      def create(**params)
        # i.e.: via NO parents
        channel = Channel(Int32).new
        spawn do
          value = @@counter.inc(T.name)
          channel.send(value)
        end
        birth_id = channel.receive

        child = T.new(**params)

        child.birth_id = birth_id

        child
      end

      def estimate_better_delta(ancestor_a : T, ancestor_b : T)
        # Note: We could use 'score' instead of 'distance', but I think 'distance' is best if we're breeding after each training io pair.
        estimate_better_delta(ancestor_a.error_stats.distance, ancestor_b.error_stats.distance)
      end

      def estimate_better_delta(error_a : Float64, error_b : Float64)
        # An error value of '0.0' is when you're at the soultion.
        # The error values are assumed to be positive (i.e.: radius from solution), but could be negative.
        # So, the solution should be where the two errors overlap.
        # Of course if the solution is not along the line between 'a' and 'b',
        #   then you'll need to diverge from that line.

        vector_a_to_b = error_b - error_a
        # i.e.:
        #   zero = error_a + delta * vector_a_to_b
        #   zero - error_a = delta * vector_a_to_b
        #   (zero - error_a) / vector_a_to_b = delta
        #   delta = (- error_a) / vector_a_to_b
        # So, return: - error_a / vector_a_to_b (but avoid div by zero)

        # Avoid div by 0 with rand, else better guess:
        vector_a_to_b == 0.0 ? Ai4cr::Utils::Rand.rand_excluding(scale: 2, offset: -0.5) : -error_a / vector_a_to_b
      end

      def breed(parent_a : T, parent_b : T, delta = 0.5)
        breed_validations(parent_a, parent_b, delta)

        # i.e.: VIA parents
        birth_id = breed_counter_tick
        child = copy_and_mix(parent_a, parent_b, delta)
        child = breed_id_and_delta(child, birth_id, parent_a, parent_b, delta)
        child.error_stats = Ai4cr::ErrorStats.new(parent_a.error_stats.history_size)

        child
      end

      def breed_validations(parent_a : T, parent_b : T, delta)
        raise StructureError.new("Parents must be Breed Clients!") unless T < Breed::Client
      end

      def breed_counter_tick
        channel = Channel(Int32).new
        spawn do
          channel.send(@@counter.inc(T.name))
        end
        channel.receive
      end

      def breed_id_and_delta(child, birth_id, parent_a, parent_b, delta)
        child.birth_id = birth_id
        child.parent_a_id = parent_a.birth_id
        child.parent_b_id = parent_b.birth_id
        child.breed_delta = delta

        child
      end

      def copy_and_mix(parent_a, parent_b, delta)
        child = parts_to_copy(parent_a, parent_b, delta)
        mix_parts(child, parent_a, parent_b, delta)
      end

      def parts_to_copy(parent_a : T, parent_b : T, delta)
        # By default, we just copy everything from parent_a.
        parent_a.clone
      end

      # abstract
      def mix_parts(child : T, parent_a : T, parent_b : T, delta)
        # Sub-classes should do some sort of property mixing based on delta and both parents.
        # Typically, do something in sub-class's 'mix_one_part_number(..)' ...
        # e.g:
        # (a) some_value = mix_one_part_number(parent_a.some_value, parent_b.some_value, delta)
        #     child.some_value = some_value
        # (b) some_array = mix_nested_parts(parent_a.some_array, parent_b.some_array, delta)
        #     child.some_array = some_array
        # (c) some_string = mix_nested_parts(parent_a.some_string, parent_b.some_string, delta)
        #     child.some_string = some_string

        # And then be sure to call 'super' or specifically return 'child'
        child
      end

      def mix_one_part_number(parent_a_part : Number, parent_b_part : Number, delta)
        vector_a_to_b = parent_b_part - parent_a_part
        v = parent_a_part + (delta * vector_a_to_b)
        # (v.nan? ? 0.0 : v) # JSON doesn't like NaN and the calc's don't either, so kill (zero-out) this part
        Float64.avoid_extremes(v)
      end

      def mix_one_part_string(parent_a_part : String, parent_b_part : String, delta)
        # TODO: Add code/classes to verify
        # NOTE: Sub-classes might want to adjust the logic for this
        delta < 0.5 ? parent_a_part : parent_b_part
      end

      def mix_nested_parts(parent_a_part, parent_b_part, delta)
        # TODO: Expand to handle other nested data types, such as
        # * hashes
        # * characters
        case
        when parent_a_part.is_a?(String) && parent_b_part.is_a?(String)
          mix_one_part_string(parent_a_part, parent_b_part, delta)
        when parent_a_part.is_a?(Number) && parent_b_part.is_a?(Number)
          mix_one_part_number(parent_a_part, parent_b_part, delta)
        when parent_a_part.responds_to?(:each) && parent_b_part.responds_to?(:each) && parent_a_part.size == parent_b_part.size
          # NOTE: This works for arrays, but not hashes.
          [parent_a_part, parent_b_part].transpose.map { |tran| va = tran[0]; vb = tran[1]; mix_nested_parts(va, vb, delta) }
        else
          raise "Unhandled values; parent_a_part, parent_b_part == #{[parent_a_part, parent_b_part]}, classes: #{[parent_a_part.class, parent_b_part.class]}"
        end
      end

      def build_team(qty_new_members : Int32 = QTY_NEW_MEMBERS_DEFAULT) : Array(T)
        params = gen_params.merge(name: "p")
        channel = Channel(T).new
        (1..qty_new_members).map do
          spawn do
            channel.send(create(**params))
          end
        end
        (1..qty_new_members).map { channel.receive }
      end

      def build_team(qty_new_members : Int32, **params) : Array(T)
        channel = Channel(T).new
        (1..qty_new_members).map do
          spawn do
            channel.send(create(**params))
          end
        end
        (1..qty_new_members).map { channel.receive }
      end

      def build_team : Array(T)
        qty_new_members = QTY_NEW_MEMBERS_DEFAULT
        params = gen_params.merge(name: "P")
        channel = Channel(T).new
        (1..qty_new_members).map do
          spawn do
            channel.send(create(**params))
          end
        end
        (1..qty_new_members).map { channel.receive }
      end

      def train_team(inputs, outputs, team_members : Array(T), max_members = MAX_MEMBERS_DEFAULT, train_qty = 1, and_cross_breed = true)
        team_members = train_team_in_parallel(inputs, outputs, team_members, train_qty)

        if team_members.size > 1 && and_cross_breed
          team_members = cross_breed(team_members)
          team_members = train_team_in_parallel(inputs, outputs, team_members, train_qty)
        else
          team_members = train_team_in_parallel(inputs, outputs, team_members, train_qty)
        end

        (team_members.sort_by(&.error_stats.distance))[0..max_members - 1]
        # (team_members.sort_by(&.error_stats.score))[0..max_members - 1]
      end

      # ameba:disable Metrics/CyclomaticComplexity
      def train_team_using_sequence(
        inputs_sequence, outputs_sequence,
        team_members : Array(T),

        io_set_text_file : Ai4cr::Utils::IoData::Abstract?,

        max_members = MAX_MEMBERS_DEFAULT,
        train_qty = 1, and_cross_breed = true,
        purge_error_limit = -1,
        verbose = true
      )
        # TODO: split up into smaller pieces
        if purge_error_limit == -1
          # This is mainly for Relu, but could be adapted for other training types
          # puts "outputs_sequence.size: #{outputs_sequence.size}"
          # puts "outputs_sequence.first.size: #{outputs_sequence.first.size}"
          # puts "outputs_sequence.first.first.size: #{outputs_sequence.first.first.size}"
          a = PURGE_ERROR_LIMIT_SCALE
          b = outputs_sequence.first.size
          c = (!outputs_sequence.first.first.is_a?(Float64)) ? outputs_sequence.first.first.size : 1.0
          purge_error_limit = a * b * c
        end

        beginning = Time.local
        before = beginning

        list = Array(Int32).new
        hist = Hash(Int32, Int32).new(0)
        perc = Hash(Int32, Float64).new(0.0)
        recent_hists = Array(Hash(Int32, Int32)).new
        max_hists = 10
        i_max = inputs_sequence.size
        tc_size = outputs_sequence.first.size

        inputs_sequence.each_with_index do |inputs, i|
          outputs = outputs_sequence[i]

          if verbose
            if i % STEP_MAJOR == 0
              puts "\n  inputs_sequence (a) i: #{i} of #{inputs_sequence.size} at #{Time.local}" # if i % STEP_MAJOR == 0 # TODO: Remove before merging

              if !io_set_text_file.nil?
                puts "  inputs_sequence GIVEN (a): "
                puts "    aka: '#{io_set_text_file.class.convert_iod_to_raw(inputs)}'"

                puts "      outputs EXPECTED (a): "
                puts "        aka: '#{io_set_text_file.class.convert_iod_to_raw(outputs)}'"
                print "\n    "
              end
            elsif i % STEP_MINOR == 0
              print "."
            end
          end

          team_members = purge_replace(team_members, purge_error_limit, i)
          team_members = train_team_in_parallel(inputs, outputs, team_members, train_qty)

          if verbose
            if i % STEP_MAJOR == 0
              puts
              team_members.each { |member| puts "    " + member.error_hist_stats(in_bw: true) }
            end
          end

          if team_members.size > 1 && and_cross_breed
            team_members = cross_breed(team_members)

            if verbose
              if i % STEP_MAJOR == 0
                puts "\n  inputs_sequence (b) i: #{i} of #{inputs_sequence.size} at #{Time.local}"

                if !io_set_text_file.nil?
                  puts "  inputs_sequence GIVEN (a): "
                  puts "    aka: '#{io_set_text_file.class.convert_iod_to_raw(inputs)}'"

                  puts "      outputs EXPECTED (a): "
                  puts "        aka: '#{io_set_text_file.class.convert_iod_to_raw(outputs)}'?"
                  print "\n    "
                end
              elsif i % STEP_MINOR == 0
                print "."
              end
            end

            team_members = train_team_in_parallel(inputs, outputs, team_members, train_qty)

            if verbose
              if i % STEP_MAJOR == 0 && !io_set_text_file.nil?
                puts
                team_members.each do |member|
                  # Thanks to the 'hardware' shard:
                  puts "System info:"
                  memory = Hardware::Memory.new
                  p! memory.percent.round(1)

                  outputs_str_expected = io_set_text_file.class.convert_iod_to_raw(outputs)
                  outputs_str_actual = io_set_text_file.class.convert_iod_to_raw(member.outputs_guessed)
                  output_str_matches = outputs_str_expected.each_char.map_with_index do |ose, oi|
                    ose.to_s == outputs_str_actual[oi].to_s ? 1 : 0
                  end

                  puts
                  puts "  inputs_sequence GIVEN (a): "
                  puts "    aka: '#{io_set_text_file.class.convert_iod_to_raw(inputs)}'"
                  puts "      outputs EXPECTED (a): "
                  puts "        aka: '#{outputs_str_expected}'?"
                  print "\n    "
                  puts "      outputs Actual (b): "
                  puts "        aka: '#{outputs_str_actual}'!"
                  puts "          " + member.error_hist_stats(in_bw: true)

                  qty_correct = output_str_matches.sum
                  percent_correct = 100.0 * qty_correct / tc_size

                  correct_plot = CHARTER.plot(output_str_matches, false)
                  member.error_stats.update_history_correct_plot(correct_plot)
                  puts "          percent_correct: #{qty_correct} of #{tc_size} => #{correct_plot} => #{percent_correct}%"
                  list << qty_correct

                  puts "          certainty:"
                  data_ce = member.outputs_guessed.map do |gptc|
                    val = io_set_text_file.iod_certainty(gptc)
                    val = 1 if val.nil? || val.infinite?
                    val
                  end
                  puts "            data: #{data_ce}"
                  puts "            graph: #{CHARTER.plot(data_ce, false)}"

                  puts
                end
              end
            end
          else
            if verbose
              if i % STEP_MAJOR == 0
                puts "\n  inputs_sequence (c) i: #{i} of #{inputs_sequence.size} at #{Time.local}" # if i % STEP_MAJOR == 0 # TODO: Remove before merging
                print "\n    "
              elsif i % STEP_MINOR == 0
                print "."
              end
            end

            team_members = train_team_in_parallel(inputs, outputs, team_members, train_qty)

            if verbose
              if i % STEP_MAJOR == 0
                puts
                team_members.each do |member|
                  puts "      outputs Actual (c): '#{member.outputs_guessed}'"

                  if !io_set_text_file.nil?
                    puts "        aka: '#{io_set_text_file.class.convert_iod_to_raw(member.outputs_guessed)}'"
                    puts "          " + member.error_hist_stats(in_bw: true)
                    puts
                  end
                end
              end
            end
          end

          team_members = purge_replace(team_members, purge_error_limit, i)
          team_members = (team_members.sort_by(&.error_stats.distance))[0..max_members - 1]
          # team_members = (team_members.sort_by(&.error_stats.score))[0..max_members - 1]

          if verbose && i % STEP_MAJOR == 0
            after = Time.local

            puts "="*80
            puts "Currently:"
            p! Time.local
            p! i
            p! (after - before)
            p! (after - beginning)
            puts "ETA (duration):"
            p! (after - beginning) * i_max / (i + 1)
            puts "-"*80
            puts "Percent Complete:"
            p! (i + 1) / i_max
            puts "ETA (time):"
            p! beginning + ((after - beginning) * i_max / (i + 1))
            puts "-"*80

            # Thanks to the 'hardware' shard:
            puts "System info:"
            memory = Hardware::Memory.new
            p! memory.percent.round(1)
            puts "^"*80

            # Now for some percent-correct stat's:
            (tc_size + 1).times do |qc|
              hist[qc] = 0
              perc[qc] = 0.0
            end
            list.each do |qc|
              hist[qc] += 1
            end
            hist_qty = hist.values.sum
            (tc_size + 1).times do |qc|
              perc[qc] = (100.0 * hist[qc] / hist_qty).round(1)
            end

            recent_hists << hist.clone
            recent_hists = recent_hists[-max_hists..-1] if recent_hists.size > max_hists

            p! hist
            p! perc
            p! perc.values.sum

            # perc_vals = perc.values.map(&./(100))
            # p! CHARTER.plot(perc_vals, false)

            # p! recent_hists
            recent_hists.each { |h| puts CHARTER.plot(h.values.map(&./(100)), false) }

            puts "-"*80

            list = Array(Int32).new
            hist = Hash(Int32, Int32).new(0)
            perc = Hash(Int32, Float64).new(0.0)

            if i % STEP_SAVE == 0 || i == i_max - 1
              member_size = team_members.size
              time_formated = Time.local.to_s.gsub(" ", "_").gsub(":", "_")
              folder_path = "./tmp/#{self.class.name.gsub("::", "-")}/#{time_formated}"

              team_members.each_with_index do |member, j|
                begin
                  # recent_hists_last_chart = CHARTER.plot(recent_hists.last.values.map(&./(100)), false)
                  # file_path = "#{folder_path}/#{member.birth_id}_step_#{i}(#{recent_hists_last_chart}).json"

                  # member.update_history_correct_plot(CHARTER.plot(hist.clone.values.map(&./(100)), false))
                  fp = folder_path
                  ms = member_size
                  bi = member.birth_id
                  cp = member.error_stats.hist_correct_plot.last
                  eh = member.error_hist_stats(in_bw: true).gsub("'", "").gsub("=>", "aka").gsub("@", "at")
                  file_path = "#{fp}/(#{j}_of_#{ms})_birth_id(#{bi})_step(#{i})_corrects(#{cp})_error_hist(#{eh}).json"

                  Dir.mkdir_p(folder_path)
                  begin
                    File.write(file_path, member.to_json)
                  rescue e
                    # probably something like: `Unhandled exception: Infinity not allowed in JSON (JSON::Error)`
                    # ... in which case, we probably can't really use the net anyways.
                    msg = {
                      member_birth_id: member.birth_id,
                      error:           {
                        klass:     e.class.name,
                        message:   e.message,
                        backtrace: e.backtrace,
                      },
                      member: member,
                    }
                    File.write(file_path + ".ERROR.txt", msg.pretty_inspect)
                  end
                rescue e
                  msg = {
                    member_birth_id: member.birth_id,
                    error:           {
                      klass:     e.class.name,
                      message:   e.message,
                      backtrace: e.backtrace,
                    },
                    member: member,
                  }
                  p! msg.pretty_inspect
                end
              end
            end

            before = after
          end

          team_members
        end

        p! recent_hists

        team_members
      end

      def purge_replace(team_members, purge_error_limit, i)
        config = team_members.first.config.clone

        target_size = team_members.size

        purge_qty = 0

        team_members.map! do |member|
          # Note: We could use 'score' instead of 'distance', but I think 'distance' is best if we're breeding after each training io pair.
          d = member.error_stats.distance
          # d = member.error_stats.score
          case
          when d.nan? || d.infinite?
            # We need to move away from this member's configuration completely

            purge_qty += 1
            name = "Pr"
            puts "\n---- i: #{i}, REPLACING member.birth_id: #{member.birth_id}; name: #{name}, err_stat_dist: #{d}, delta: N/A ----\n"
            # TODO: replace above 'puts' with: 'block_simple_logger.call(..) if block_simple_logger'

            new_rand_member = create(**config).tap(&.name=(name))
          when d > purge_error_limit
            # We need to move away from this member's configuration,
            #   but don't want to totally 'forget' all the training results/adjustments,
            #   so we'll create a new randomly seeded member and breed the two members.

            purge_qty += 1
            name = "pb"
            delta = Ai4cr::Utils::Rand.rand_excluding(scale: 2, offset: -1.0)
            puts "\n---- i: #{i}, REPLACING member.birth_id: #{member.birth_id}; name: #{name}, err_stat_dist: #{d}, delta: #{delta} ----\n"

            new_rand_member = create(**config)
            breed(member, new_rand_member, delta).tap(&.name=(name))
          else
            # Member ok as-is...
            # NOTE: Member will have 'd:' of '-1' if member is new!
            puts "\n---- i: #{i}, keeping member.birth_id: #{member.birth_id}; name: #{member.name}, err_stat_dist: #{d}, delta: n/a ----\n"

            member
          end
        end

        if purge_qty > 0
          puts "\n**** i: #{i}, purge_error_limit: #{purge_error_limit}; purge_qty: #{purge_qty} out of #{target_size} at #{Time.local} ****\n"
        else
          puts "\n**** i: #{i}, purge_error_limit: #{purge_error_limit}; purge_qty: #{purge_qty} out of #{target_size} at #{Time.local} **** (NO PURGES) ****\n"
        end

        team_members
      end

      # ameba:enable Metrics/CyclomaticComplexity

      def train_team_in_parallel(inputs, outputs, team_members, train_qty)
        if team_members.size > 1
          channel = Channel(T).new
          team_members.each do |member|
            spawn do
              train_qty == 1 ? member.train(inputs, outputs) : train_qty.times { member.train(inputs, outputs) }
              channel.send(member)
            end
          end
          (1..team_members.size).map { channel.receive }
        elsif team_members.size == 1
          member = team_members.first
          train_qty == 1 ? member.train(inputs, outputs) : train_qty.times { member.train(inputs, outputs) }
          team_members
        else
          raise "No team members!"
        end
      end

      def cross_breed(team_members : Array(T))
        raise "Can't cross-breed when less than 2 team member" if team_members.size < 2

        channel = Channel(T).new

        team_members.each_with_index do |member_i, i|
          team_members.each_with_index do |member_j, j|
            spawn do
              contestant = if i == j
                             # Don't bother breeding a member with itself
                             member_i.tap(&.name=("S")) # same
                           elsif i < j
                             # Try to guess a delta that is closer to a zero error
                             delta = estimate_better_delta(member_i, member_j)
                             breed(member_i, member_j, delta).tap(&.name=("z")) # target zero delta
                           else
                             # Just take a chance with a random delta
                             delta = Ai4cr::Utils::Rand.rand_excluding(scale: 2, offset: -0.5)
                             breed(member_i, member_j, delta).tap(&.name=("r")) # random delta
                           end

              channel.send contestant
            end
          end
        end

        (1..team_members.size).flat_map { team_members.map { channel.receive } }
      end

      def eval_team(team_members, inputs)
        team_members.map do |member|
          member.eval(inputs)
        end
      end

      def eval_team_in_parallel_using_sequence(team_members, inputs_sequence)
        inputs_sequence.map do |inputs|
          eval_team_in_parallel(team_members, inputs)
        end
      end

      def eval_team_in_parallel(team_members, inputs)
        channel = Channel(Hash(Int32, Array(Float64))).new
        team_members.each_with_index do |member, i|
          spawn do
            guess = member.eval(inputs)
            channel.send({i => guess})
          end
        end

        guesses = Hash(Int32, Array(Float64)).new
        (1..team_members.size).map do
          hash = channel.receive
          raise "OOPS; too many channel.receive's at once!!!" if hash.keys.size > 1
          guesses[hash.keys.first] = hash[hash.keys.first]
        end

        guesses.keys.sort!.map! { |k| guesses[k] }
      end
    end
  end
end
