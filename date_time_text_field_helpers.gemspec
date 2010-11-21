Gem::Specification.new do |s|
  s.name = 'date_time_text_field_helpers'
  s.version = '0.0.6'
  s.homepage = 'http://github.com/adzap/date_time_text_field_helpers'
  s.author = 'Adam Meehan'
  s.email = 'adam.meehan@gmail.com'
  s.add_dependency 'rails'
  s.files = Dir['lib/**/*.rb', 'javascripts/*.js']
  s.has_rdoc = true
  s.extra_rdoc_files << 'README'
  s.rdoc_options << '--main' << 'README'
  s.summary = 'Date helpers like built-in but text fields instead of selects'
  s.description = <<-DESCRIPTION
    Works much like the buit-in date helpers that Rails provides but
    instead of being selects are simple text fields so the user can
    just type them in.
  DESCRIPTION
end
