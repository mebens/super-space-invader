task :default do
  puts `/Applications/love.app/Contents/MacOS/love .`
end

task :lines do
  puts `wc -l *.lua misc/*.lua entities/*.lua worlds/*.lua`
end

task :package do
  puts `zip -r --exclude=*.git* --exclude=*.bfxrlibrary --exclude=*.DS_Store* _bin/labyrinthian.love assets entities misc lib worlds *.lua`
end
