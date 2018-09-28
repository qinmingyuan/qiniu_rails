Rails.application.routes.draw do

  scope :admin, as: 'admin', module: 'rails_sync_admin' do
    resources :sync_audits do
      post :sync, on: :collection
      post :batch, on: :collection
      patch :apply, on: :member
    end
  end

end
