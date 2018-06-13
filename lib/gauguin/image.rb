require 'mini_magick'
require 'forwardable'

module Gauguin
  class Image
    extend Forwardable
    attr_accessor :image
    delegate [:color_histogram, :columns, :rows, :write] => :image

    def initialize(path = nil)
      return unless path
      self.image = MiniMagick::Image.open(path)
    end

    def self.blank(columns, rows)
      tmp = Tempfile.new(%W[mini_magick_ .jpg])
      `convert -size #{columns}x#{rows} xc:transparent #{tmp.path}`
      MiniMagick::Image.new(tmp.path, tmp)
    end

    def pixel(magic_pixel)
      Pixel.new(magic_pixel)
    end

    def pixel_color(row, column, *args)
      magic_pixel = self.image.pixel_color(row, column, *args)
      pixel(magic_pixel)
    end

    class Pixel
      MAX_CHANNEL_VALUE = 257
      MAX_TRANSPARENCY = 65535

      def initialize(magic_pixel)
        @magic_pixel = magic_pixel
      end

      def transparent?
        @magic_pixel.opacity >= MAX_TRANSPARENCY
      end

      def to_rgb
        [:red, :green, :blue].map do |color|
          @magic_pixel.send(color) / MAX_CHANNEL_VALUE
        end
      end
    end
  end
end

