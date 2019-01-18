class AuthorsController < ApplicationController
  include GithubWebhookHelper
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
    webhook_body = request.body.read
    verify_signature(webhook_body, request.env['HTTP_X_HUB_SIGNATURE'])
    issue_event = JSON.parse(webhook_body)

    github_service = GithubService.new(issue_event)
    handler_method = "handle_webhook_issue_#{issue_event["action"]}"
    
    @author = github_service.send handler_method
    render json: @author

    rescue JSON::ParserError => e
      render json: {:status => 400, :error => "Invalid Github Event Payload"} and return
    
    rescue RuntimeError => e
      render json: {:status => 401, :error => e.message} and return

    rescue NoMethodError => e
      render json: {:status => 500, :error => "Handler Method Not Implemented"} and return
  end

  # DELETE /authors/1
  def destroy
    @author.destroy
  end

  def verify_signature(body, x_hub_signature)
    signature = 'sha1=' + OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha1'),  Rails.application.secrets.github_webhook_secret_token, body)
    raise "Signatures don't match" unless Rack::Utils.secure_compare(signature, x_hub_signature)
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
