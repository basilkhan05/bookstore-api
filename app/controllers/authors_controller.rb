class AuthorsController < ApplicationController
  before_action :set_author, only: [:show, :update, :destroy]

  # GET /authors
  def index
    @authors = Author.all

    render json: @authors
  end

  # GET /authors/1
  def show
    render json: @author, include: ['books']
  end

  # POST /authors
  def create
    @author = Author.new(author_params)

    if @author.save
      render json: @author, status: :created, location: @author
    else
      render json: @author.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /authors/1
  def update
    if @author.update(author_params)
      render json: @author
    else
      render json: @author.errors, status: :unprocessable_entity
    end
  end

  # POST /authors/github_webhook
  def github_webhook
    issue_event = JSON.parse(request.body.read)
    handler_method = "handle_github_issue_#{issue_event["action"]}"
    self.send handler_method, issue_event

    rescue JSON::ParserError => e
      render json: {:status => 400, :error => "Invalid Github Event Payload"} and return
    
    rescue NoMethodError => e
      render json: {:status => 500, :error => "Handler Method Not Implemented"} and return
  end

  # DELETE /authors/1
  def destroy
    @author.destroy
  end

  def handle_github_issue_opened(event)
    author_payload = {
      :author => {
        :name => event["issue"]["title"],
        :biography => event["issue"]["body"],
        :github_issue_id => event["issue"]["id"]
      }
    }
    params.merge!(author_payload)
    self.create
    book = Book.create(title: "Biography of #{event["issue"]["title"]}", author: @author, publisher: @author , price: 0.00)
  end

  def handle_github_issue_edited(event)
    @author = Author.find_by(:github_issue_id => event["issue"]["id"])
    author_payload = {
      :author => {
        :name => event["issue"]["title"],
        :biography => event["issue"]["body"]
      }
    }
    params.merge!(author_payload)
    self.update
  end

  def handle_github_issue_closed(event)
    @author = Author.find_by(:github_issue_id => event["issue"]["id"])
    books = Book.where(:author => @author)
    books.destroy_all
    self.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_author
      @author = Author.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def author_params
      params.require(:author).permit(:name, :biography, :github_issue_id)
    end
end
