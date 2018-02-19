require 'sprockets/manifest'

module QiniuNonDigestAssets

  def compile(*args)
    super

    environment.paths.find_all { |i| i.include? 'nondigest_assets' }.each do |src|
      if Sprockets.config[:sync].to_s == 'qiniu'
        f_src = src.to_s + '/**/*'
        path_src = Pathname.new src
        Dir.glob(f_src).select { |f| File.file?(f) }.each do |file|
          key = Pathname.new(file).relative_path_from(path_src)
          QiniuHelper.upload file, 'assets/' + key.to_s
        end
      end
    end
  end

  def remove(filename)
    super

    if Sprockets.config[:sync].to_s == 'qiniu'
      QiniuHelper.delete 'assets/' + filename.to_s
      logger.info "--> Removed from Qiniu: #{ filename }"
    end
  end

end

Sprockets::Manifest.send(:prepend, QiniuNonDigestAssets)
