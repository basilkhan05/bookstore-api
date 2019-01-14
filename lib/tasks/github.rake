namespace :github do
  
  desc "Github task to populate Authors' name and biography as Github Issues"
  task :populate_authors_as_issues, [:login, :password] => :environment do |t, args|
    login = args[:login]
    password = args[:password]
    client = Octokit::Client.new(:login => login, :password => password)
    Author.where(:github_issue_id => nil).each do |author|
      issue = client.create_issue("basilkhan05/bookstore-api", author.name, author.biography)
      # Update author with associated Github Issue ID
      author.update(:github_issue_id => issue.id)
    end
  end

end
