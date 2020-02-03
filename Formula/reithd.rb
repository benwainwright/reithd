class Reithd < Formula
  desc 'Never have to think about Reith again'
  url 'https://github.com/benwainwright/reithd/releases/download/0.0.8/reithd'
  sha256 'a31f4f4314983b3b3798b35cf58602749f0b07fe59d1066a9f42fcda8b3d8230'
  def install
    bin.install "reithd"
  end

  plist_options :startup => true

  def plist; <<~EOS
  <?xml version="1.0" encoding="UTF-8"?>
  <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
  <plist version="1.0">
  <dict>
      <key>Label</key>
      <string>#{plist_name}</string>
      <key>ProgramArguments</key>
      <array>
          <string>/usr/local/bin/reithd</string>
          <string>start</string>
      </array>
      <key>RunAtLoad</key>
      <true/>
      <key>StandardErrorPath</key>
      <string>/tmp/reithd.stderr</string>
      <key>StandardOutPath</key>
      <string>/tmp/reithd.stdout</string>
  </dict>
  </plist>
  EOS
  end
end
