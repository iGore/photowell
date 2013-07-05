# Compile stylesheets
guard 'compass', :configuration_file => "compass.rb" do
    watch(/^_scss\/(.*)\.scss/)
end
 
guard 'process', :name => 'Minify CSS', :command => 'juicer merge css/style.css --force -c none' do
    watch %r{css/style\.css}
end
 
guard 'process', :name => 'Combine Javascript from CoffeeScript', :command => 'coffee -cbj js/app.js _coffee/' do
    watch %r{_coffee/.+\.coffee}
end
 
guard 'process', :name => 'Minify application javascript', :command => 'juicer merge js/app.js --force -s' do
    watch %r{app/app\.js}
end
 
# Watch for modifications in application.css and application.js
# and reload the browser if so
guard 'livereload', :apply_js_live => true, :apply_css_live => true do
    watch(%r{css/style\.css})
    watch(%r{js/app\.js})
end