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

  FileUtils.mkdir_p(Rails.root.join('tmp/files'))
  FileUtils.mkdir_p(Rails.root.join('tmp/files/7d'))
  FileUtils.mkdir_p(Rails.root.join('tmp/files/28d'))
  FileUtils.mkdir_p(Rails.root.join('tmp/files/quarantine'))
  FileUtils.mkdir_p(Rails.root.join('tmp/files/encrypted_data'))
end
