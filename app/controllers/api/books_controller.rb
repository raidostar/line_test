class Api::BooksController < ApplicationController

  def index
    @books = Book.all
  end

  def create
    @book = Book.new(book_params)
    @notify = Notify.new
    if @book.save
      render :show, status: :created
      @notify.send("#{@book.title}がリリースいたしました")
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
      @notify.send("#{@book.title}のサービスが終了致しました")
    else
      render json: @book.errors, status: :unprocessable_entity
    end
  end

  private

  def book_params
    params.fetch(:book, {}).permit(
      :id, :title, :author, :publisher, :genre, :release_at
      )
  end
end
