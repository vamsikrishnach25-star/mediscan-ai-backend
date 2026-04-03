class BiomarkerExtractorService
  def self.extract(text)

    data = {}

    hb = text.match(/Hemoglobin.*?(\d{2,3})/)
    rbc = text.match(/RBC.*?(\d{1,2}\.?\d?)/)
    wbc = text.match(/(WBC|WaC).*?(\d{3,5})/)
    platelets = text.match(/Platelet.*?(\d{5,6})/)

    data[:hemoglobin] = hb[1].to_f / 10 if hb
    data[:rbc] = rbc[1].to_f if rbc
    data[:wbc] = wbc[2].to_i if wbc
    data[:platelets] = platelets[1].to_i if platelets

    data
  end
end