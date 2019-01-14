module GithubWebhookHelper

  def handle_github_issue_opened(event)
    @author = Author.find_by(:github_issue_id => event["issue"]["id"])
    return if !@author.nil?

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

end
