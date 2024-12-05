class Api::V1::ProfilesController < ApplicationController
    def index
        @profiles = Profile.all
        render json: @profiles
    end
    def show
        @profile = Profile.find(params[:id])
    end
end
