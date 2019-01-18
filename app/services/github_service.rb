class GithubService

  def initialize(event)
    @event = event
    @author = Author.find_by(:github_issue_id => event["issue"]["id"])
  end

  def handle_webhook_issue_opened
    return if !@author.nil?

    author_payload = {
      :name => @event["issue"]["title"],
      :biography => @event["issue"]["body"],
      :github_issue_id => @event["issue"]["id"]
    }

    @author = Author.create(author_payload)
    book = Book.create(title: "Biography of #{@event["issue"]["title"]}", author: @author, publisher: @author, price: 0.00)
    return @author
  end

  def handle_webhook_issue_edited
    author_payload = {
      :name => @event["issue"]["title"],
      :biography => @event["issue"]["body"]
    }
    
    @author.update(author_payload)
    bio_book = @author.books.where(:price => 0).first
    bio_book.update(:title => "Biography of #{@event["issue"]["title"]}")
    return @author
  end

  def handle_webhook_issue_closed
    @author.destroy
  end

end
