Dir.chdir(".") do
  #1. Get the two file
  cuefile = Dir.glob("*.cue").first
  flacfile = Dir.glob("*.flac").first

  # #2. Pass them as argument to xld and output the progression bar
  xldcommand = "xld -c \"#{cuefile}\" -f alac \"#{flacfile}\""
  IO.popen(xldcommand) {|pipe| puts pipe.gets }
    pipe.gets
  end

  #3. Embed 'front.jpg' or 'front.png' into the new m4a files.
  front_img = Dir.glob("front.*").first
  imgcommand = "mp4art --add #{front_img} *.m4a"
  IO.popen(imgcommand) {|pipe| puts pipe.gets }

  #4. Make the booklet
  [ "front.jpg", "back.jpg", "cd.jpg" ].each {|file| `cp #{file} ./booklet`}
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