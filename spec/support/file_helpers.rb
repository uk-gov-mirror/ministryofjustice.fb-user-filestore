def purge_quarantine!
  FileUtils.rm_f(Dir.glob(Rails.root.join('tmp/files/quarantine/*')))
  FileUtils.rm_f(Dir.glob(Rails.root.join('tmp/files/encrypted_data/*')))
end

def purge_uploaded_files!
  FileUtils.rm_f(Dir.glob(Rails.root.join('tmp/files/*d/*')))
end

def reset_test_directories!
  purge_quarantine!
  purge_uploaded_files!

  FileUtils.mkdir(Rails.root.join('tmp/files')) unless File.exist?(Rails.root.join('tmp/files'))
  FileUtils.mkdir(Rails.root.join('tmp/files/7d')) unless File.exist?(Rails.root.join('tmp/files/7d'))
  FileUtils.mkdir(Rails.root.join('tmp/files/28d')) unless File.exist?(Rails.root.join('tmp/files/28d'))
  FileUtils.mkdir(Rails.root.join('tmp/files/quarantine')) unless File.exist?(Rails.root.join('tmp/files/quarantine'))
  FileUtils.mkdir(Rails.root.join('tmp/files/encrypted_data')) unless File.exist?(Rails.root.join('tmp/files/encrypted_data'))
end
