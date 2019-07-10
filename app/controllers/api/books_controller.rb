class Api::BooksController < ApplicationController

  def index
    @books = Book.all
  end

  def create
    @book = Book.new(book_params)
    if @book.save
      render :show, status: :created
    else
      render json: @book.errors, status: :unprocessable_entity
    end
  end

  def show
    @book = Book.find(params[:id])
    render :show
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
    if @book.destroy
      render :show, status: :ok
    else
      render json: @book.errors, status: :unprocessable_entity
    end
  end

  private

  def book_params
    params.fetch(:book, {}).permit(
      :id, :title
    )
  end
end
