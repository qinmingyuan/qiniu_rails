module ActiveStorage
  class Analyzer
    class QiniuVideoAnalyzer < VideoAnalyzer
      def self.accept?(blob)
        blob.video? || blob.audio?
      end

      def metadata
        {
          width: width,
          height: height,
          duration: duration,
          aspect_ratio: aspect_ratio
        }.compact
      rescue
        {}
      end

      private

      def width
        video_stream['width']
      end

      def height
        video_stream['height']
      end

      def duration
        video_stream['duration']
      end

      def aspect_ratio
        video_stream['display_aspect_ratio']
      end

      def streams
        @streams ||= begin
          code, result, res = Qiniu::HTTP.api_get(blob.service.url(blob.key, fop: 'avinfo'))
          result['streams']
        end
      end

      def video_stream
        @video_stream ||= streams.detect { |stream| ['video', 'audio'].include? stream['codec_type'] } || {}
      end
    end
  end
end
