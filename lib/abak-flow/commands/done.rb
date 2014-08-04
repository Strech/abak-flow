# coding: utf-8
module Abak::Flow
  module Commands
    class Done
      include ANSI::Code

      def run(args, options)
        Checkup.new.process(Array.new, ::Commander::Command::Options.new)

        branch = Branch.new(Manager.git.current_branch)

        if branch.develop? || branch.master?
          say red {
            Manager.locale.error(self,
              'branch.delete_now_allowed', branch: ANSI.bold { branch })
          }

          exit 105
        end

        delete_on_remote(branch)

        # TODO : Быть может стоит вынести это в настройки
        #        и позволить выбирать, куда отправлять
        #        при удалении ветки, а по умолчанию использовать master
        Manager.git.checkout(
          branch.extract_base_name(if_undef: Branch::MASTER))

        delete_on_local(branch)
      end

      private

      def delete_on_remote(branch)
        print white {
          Manager.locale.word(self,
            "deleting", branch: bold { branch },
                        upstream: bold { "#{Manager.repository.origin}" })
        }

        begin
          branch.delete_on_remote
        rescue
          say_branch_missed(branch, "#{Manager.repository.origin}")
        else
          say_done
        end
      end

      def delete_on_local(branch)
        print white {
          Manager.locale.word(self,
            "deleting", branch: bold { branch },
                        upstream: bold { "working tree" })
        }

        begin
          branch.delete_on_local
        rescue
          say_branch_missed(branch, "working tree")
        else
          say_done
        end
      end

      def say_done
        say green { " " << Manager.locale.word(self, "done") }
      end

      def say_branch_missed(branch, upstream)
        puts
        say yellow {
          Manager.locale.error(self,
            "branch.missed_on", branch: branch,
                                upstream: upstream)
        }
      end
    end
  end
end
