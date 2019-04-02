File.open(Rails.root.join('config/clamd/production.conf'), 'w') do |f|
  f.write "TCPSocket 3310"
  f.write "\n"
  f.write "TCPAddr #{ENV['AV_HOST']}"
  f.write "\n"
end
