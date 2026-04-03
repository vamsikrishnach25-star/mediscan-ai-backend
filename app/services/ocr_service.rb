require 'rtesseract'

class OcrService
  def self.extract_text(image_path)

    image = RTesseract.new(
      image_path.to_s,
      psm: 6
    )

    image.to_s
  end
end