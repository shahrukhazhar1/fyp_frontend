require 'securerandom'
require 'mime/types'
require 'rack'

class Utils::Utils
  class << self
    def dig(hash, ks)
      ks.each do |k|
        if hash.nil?
          return nil
        end

        hash = hash[k]
      end

      hash
    end

    def add_file_upload!(params, k, num_tries = 5)
      unless params[:question][k].blank?
        upload = params[:question][k].is_a?(String)

        filename = upload ? params[:question][k] : params[:question][k].original_filename

        extension = filename.split('.').last

        tmp_file = nil

        num_tries.times do
          random_part = SecureRandom.hex
          tmp_file = "#{Rails.root}/tmp/uploaded-#{random_part}.#{extension}"

          if File.exists?(tmp_file)
            tmp_file = nil
            next
          end

          break
        end

        fail 'Unable to add file upload' if tmp_file.nil?

        File.open(tmp_file, 'wb') do |f|
          if upload
            f.write request.body.read
          else
            f.write params[:question][k].read
          end
        end

        file = File.open(tmp_file)
        params[:question][k] = Rack::Multipart::UploadedFile.new(file.path, mime_for_file(file))
        File.delete(file.path)
      end
    end

    def add_file_upload_with_keys!(params, ks, num_tries = 5)
      unless dig(params, ks).blank?
        upload = dig(params, ks).is_a?(String)

        filename = upload ? dig(params, ks) : dig(params, ks).original_filename

        extension = filename.split('.').last

        tmp_file = nil

        num_tries.times do
          random_part = SecureRandom.hex
          tmp_file = "#{Rails.root}/tmp/uploaded-#{random_part}.#{extension}"

          if File.exists?(tmp_file)
            tmp_file = nil
            next
          end

          break
        end

        fail 'Unable to add file upload' if tmp_file.nil?

        File.open(tmp_file, 'wb') do |f|
          if upload
            f.write request.body.read
          else
            f.write dig(params, ks).read
          end
        end

        file = File.open(tmp_file)
        k = ks.pop
        dig(params, ks)[k] = Rack::Multipart::UploadedFile.new(file.path, mime_for_file(file))
        File.delete(file.path)
      end
    end

    def make_post_request_with_upload!(path, payload)
      if Rails.env.production?
        url = "#{Rails.configuration.parent_portal_url}/" + path
        uri = URI(url)

        Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
          request = Net::HTTP::Post.new(uri.request_uri)

          request.body = Rack::Multipart::Generator.new(payload).dump

          request.content_type = "multipart/form-data, boundary=#{Rack::Multipart::MULTIPART_BOUNDARY}"
          return http.request(request)
        end
      else
        url = "http://localhost:5000/" + path
        uri = URI(url)
        http    = Net::HTTP.new(uri.host, uri.port)
        request = Net::HTTP::Post.new(uri.request_uri)

        request.body = Rack::Multipart::Generator.new(payload).dump

        request.content_type = "multipart/form-data, boundary=#{Rack::Multipart::MULTIPART_BOUNDARY}"
        return http.request(request)
      end
    end

    def make_put_request_with_upload!(path, payload)
      if Rails.env.production?
        url = "#{Rails.configuration.parent_portal_url}/" + path
        uri = URI(url)

        Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
          request = Net::HTTP::Put.new(uri.request_uri)

          request.body = Rack::Multipart::Generator.new(payload).dump

          request.content_type = "multipart/form-data, boundary=#{Rack::Multipart::MULTIPART_BOUNDARY}"
          return http.request(request)
        end
      else
        url = "http://localhost:5000/" + path
        uri = URI(url)
        http    = Net::HTTP.new(uri.host, uri.port)
        request = Net::HTTP::Put.new(uri.request_uri)

        request.body = Rack::Multipart::Generator.new(payload).dump

        request.content_type = "multipart/form-data, boundary=#{Rack::Multipart::MULTIPART_BOUNDARY}"
        return http.request(request)
      end
    end

    def mime_for_file(f)
      m = MIME::Types.type_for(f.path.split('.').last)
      m.empty? ? "application/octet-stream" : m.to_s
    end
  end
end
