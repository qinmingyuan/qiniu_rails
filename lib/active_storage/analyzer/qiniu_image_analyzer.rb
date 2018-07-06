module ActiveStorage
  class Analyzer
    class QiniuImageAnalyzer < ImageAnalyzer

      def metadata
        code, result, res = Qiniu::HTTP.api_get(blob.service.url(blob.key, fop: 'imageInfo'))
        result.symbolize_keys
      rescue
        {}
      end

    end
  end
end