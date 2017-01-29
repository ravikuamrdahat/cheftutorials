#
# Author:: Adam Jacob (<adam@chef.io>)
# Copyright:: Copyright 2008-2016, Chef Software Inc.
# Author:: Doug MacEachern (<dougm@vmware.com>)
# Copyright:: Copyright 2010-2016, VMware, Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require "open3"

class Chef
  module Mixin
    module Command
      module Windows
        def popen4(cmd, args = {}, &b)
          # By default, we are waiting before we yield the block.
          args[:waitlast] ||= false

          #XXX :user, :group, :environment support?

          Open3.popen3(cmd) do |stdin, stdout, stderr, cid|
            if b
              if args[:waitlast]
                b[cid, stdin, stdout, stderr]
                # send EOF so that if the child process is reading from STDIN
                # it will actually finish up and exit
                stdin.close_write
              else
                o = StringIO.new
                e = StringIO.new

                stdin.close

                stdout.sync = true
                stderr.sync = true

                line = stdout.gets(nil)
                if line
                  o.write(line)
                end
                line = stderr.gets(nil)
                if line
                  e.write(line)
                end
                o.rewind
                e.rewind
                b[cid, stdin, o, e]
              end
            else
              [cid, stdin, stdout, stderr]
            end
          end
          $?
        end

      end
    end
  end
end
