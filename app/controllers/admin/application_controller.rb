class Admin::ApplicationController < ApplicationController
  layout 'admin/application'
  http_basic_authenticate_with name: "master", password: "asai"
end
