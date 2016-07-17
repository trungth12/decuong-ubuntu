class MyUploader < CarrierWave::Uploader::Base
  storage :file

  def extension_white_list
    %w(pdf)
  end
  def filename
    model.ma_mon_hoc + ".pdf"
  end

end