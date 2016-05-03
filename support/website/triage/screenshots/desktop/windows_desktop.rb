module Triage
  module Screenshots
    module Desktop
      module WindowsDesktop
        @@isDesktopServerAvailable = true
        def self.desktop
          puts '---> WindowsDesktop::taking desktop snapshot ' + (ENV['WINDOWS_DESKTOP'].nil?? '0':ENV['WINDOWS_DESKTOP'])
        end

        def self.createClientSocket
          if @@isDesktopServerAvailable
            begin
              @@s = TCPSocket.open('127.0.0.1',8000) if @@isDesktopServerAvailable
              puts Time.now.to_s + '---> WindowsDesktop::Created desktop connection'
            rescue => e
              @@isDesktopServerAvailable = false
              puts Time.now.to_s + '---> WindowsDesktop::Not available'
            end
          end
          @@isDesktopServerAvailable
        end

        def self.getDesktop
          return unless createClientSocket
          pid = Process.pid.to_s
          bpath = (ENV['BUILD_URL'].nil?? '':ENV['BUILD_URL'])
          processId = pid + '|' + bpath
          f = nil
          begin
            f = File.open(ENV['HOME'] + '/' + pid + '.pid', 'w')
            f.write(bpath)
          rescue IOError => e
            #some error occur, dir not writable etc.
          ensure
            f.close unless f.nil?
          end
          puts Time.now.to_s + "---> WindowsDesktop::Get desktop:        #{processId}"
          @@s.puts('GET ' + processId)               # Send request
          ENV['WINDOWS_DESKTOP'] = @@s.readline                                # Read complete response
          puts Time.now.to_s + "---> WindowsDesktop::Got desktop:        #{ENV['WINDOWS_DESKTOP']}"
        end

        def self.switchDesktop
          return unless createClientSocket
          puts Time.now.to_s + '---> WindowsDesktop::switchDesktop' + ENV['WINDOWS_DESKTOP']
          @@s.puts('SWITCH ' + ENV['WINDOWS_DESKTOP'])               # Send request
          ENV['WINDOWS_DESKTOP'] = @@s.readline
          puts Time.now.to_s + '---> WindowsDesktop::desktop switched ' + ENV['WINDOWS_DESKTOP']
        end

        def self.releaseDesktopConnection
          return unless @@isDesktopServerAvailable
          puts Time.now.to_s + '---> WindowsDesktop::Destroy desktop connection'
          @@s.puts('DONE')
          if @@s
            @@s.close
            @@s = nil
          end
        end

        def self.releaseDesktop
          return unless createClientSocket
          # puts Time.now.to_s + "---> WindowsDesktop::Releasing desktop:        #{ENV['WINDOWS_DESKTOP']}"
          @@s.puts('RELEASE ' + ENV['WINDOWS_DESKTOP'])               # Send request
          ENV['WINDOWS_DESKTOP'] = @@s.readline
          # puts Time.now.to_s + '---> WindowsDesktop::desktop released ' + ENV['WINDOWS_DESKTOP']
          releaseDesktopConnection
        end
      end
    end
  end
end