RSpectacles::App.helpers do
  def versioned_stylesheet(stylesheet)
    checksum = File.mtime(File.join(public_dir, 'css', "#{stylesheet}.css")).to_i
    url "/css/#{stylesheet}.css?#{checksum}"
  end

  def versioned_javascript(js)
    checksum = File.mtime(File.join(public_dir, 'js', "#{js}.js")).to_i
    url "/js/#{js}.js?#{checksum}"
  end

  def public_dir
    File.expand_path('../../app/public', __FILE__)
  end
end
