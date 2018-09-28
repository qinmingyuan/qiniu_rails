Rails.application.routes.draw do

  scope path: 'qiniu' do
    controller :qiniu do
      match :notify, via: [:get, :post]
    end
  end

end
