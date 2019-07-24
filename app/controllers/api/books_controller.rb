class Api::BooksController < ApplicationController
  require 'net/http'
  require 'uri'

  def index
    @books = Book.all
  end

  def create
    @book = Book.new(book_params)
    @notify = Notify.new
    if @book.save
      render :show, status: :created
      @notify.send("#{@book.title}がリリースいたしました！")
      @notify.send("http://fullout.jp")
    else
      render json: @book.errors, status: :unprocessable_entity
    end
  end

  def show
    @book = Book.find(params[:id])
    render :show, status: :ok
  end

  def update
    @book = Book.find(params[:id])
    if @book.update(book_params)
      render :show, status: :ok
    else
      render json: @book.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @book = Book.find(params[:id])
    @notify = Notify.new
    if @book.destroy
      render :show, status: :ok
      @notify.send("すみませんが、#{@book.title}はこれからサービスが終了されました。")
    else
      render json: @book.errors, status: :unprocessable_entity
    end
  end

  private

  def book_params
    params.fetch(:book, {}).permit(
      :id, :title, :author, :publisher, :genre
      )
  end
end
