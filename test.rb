require 'readline'

home = ENV['HOME']
downloads_dir = "#{home}/Downloads"

Dir.chdir(downloads_dir) do
  # puts Dir.entries(".").class.name
  folders = Dir.entries(".").select {|f| (File.directory?(f) && f !~ /^\.+/ && f !~ /^\$/) }
  comp = proc {|s| folders.grep(/^#{Regexp.escape(s)}/i) }
  Readline.completion_proc = comp

  p "Please enter the project to browse (press Tab to see options): "
  while line = Readline.readline('> ', true)
    line.strip!
    if !folders.include? line
      puts "Access denied !"
    else
      Dir.chdir(line) do
        #1. Get the two file
        cuefile = Dir["*.cue"].first
        flacfile = Dir["*.flac"].first

        #2. Pass them as argument to xld and output the progression bar
        xldcommand = "xld -c \"#{cuefile}\" -f alac \"#{flacfile}\""
        IO.popen(xldcommand) {|pipe| puts pipe.gets }

        #3. Embed 'front.jpg' or 'front.png' into the new m4a files.
        front_img = Dir.glob("front.*").first
        imgcommand = "mp4art --add #{front_img} *.m4a"
        IO.popen(imgcommand) {|pipe| puts pipe.gets }

        #4. Make the booklet
        [ "front.jpg", "back.jpg", "cd.jpg" ].each {|file| `cp #{file} ./booklet` }
        Dir.chdir("./booklet") do
          Dir["*.jpg"].each do |filename|
            pdf_filename = filename.gsub(/\.jpg$/, '.pdf')
            `convert #{filename} #{pdf_filename}`
          end

          booklet_pages = [ "front.pdf" ]
          booklet_pages << Dir['*.pdf'].select {|file| file =~ /^[0-9]+.pdf/ }.sort
          booklet_pages << ["back.pdf", "cd.pdf"]

          `pdftk #{booklet_pages.join(" ")} output Livret.pdf`
          `mv Livret.pdf ../`
          `rm *.pdf`
        end
      end
    end
  end
end