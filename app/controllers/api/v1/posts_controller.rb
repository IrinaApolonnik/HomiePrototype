class Api::V1::PostsController < ApplicationController
    def index
        @posts = Post.all
        render json: @posts
    end
    def show
        @post = Post.find(params[:id])
    end
end
