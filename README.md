# Bookstore API

## Ruby and Rails Version

- Ruby version 2.4.1
- Rails version 5.2.2

Note: The following setup instructions are for MacOS

## Getting started

### Clone the repository locally

`git clone <repo-url>`

### Local App Setup

`cd bookstore-api`

Install all required gems

`bundle install`

Run data base migrations

`rake db:migrate`

Load the seed data for Authors, Books and Publishers

`rake db:seed`

Run custom rake task to update all authors in the app on Github issues. This will require you Github username and password without any quotes. Please make sure Two-factor authentication is disabled for this rake task. This rake task assumes your github repo is `basilkhan05/bookstore-api`

`rake "github:populate_authors_as_issues[{{github.username}}, {{github.password}}]"`

## Install Ngrok

To install Ngrok run:

`homebrew install ngrok`

OR 

Go to [ngrok - download](https://ngrok.com/download), to download the ngrok executable.

Copy/move the file over to the `/usr/local/bin/` directory.

## Setup environment variables

- Create a `.env` file in the root of your application
- Run the following to generate a `<<secret_token>>`

`ruby -rsecurerandom -e 'puts SecureRandom.hex(20)'`

Copy and store the token in the .env file as

`GITHUB_WEBHOOK_SECRET_TOKEN=<<secret_token>>`


## Start your local server

Run the rails server to see your application live.

`rails server`

Look for `=> Your Ngrok URL -->` in the console output after starting the rails server, like below

```
=> Booting Puma
=> Rails 5.2.2 application starting in development
=> Run `rails server -h` for more startup options
=> Your Ngrok URL --> http://031c2a54.ngrok.io
Puma starting in single mode...
* Version 3.12.0 (ruby 2.4.1-p111), codename: Llamas in Pajamas
* Min threads: 5, max threads: 5
* Environment: development
* Listening on tcp://0.0.0.0:3000
Use Ctrl-C to stop
```

In this case, you want to use `http://031c2a54.ngrok.io` as your BASE_URL for the Github webhook URL setup.


## Setup Webhook in Github

In Github, go to your `bookstore-api` repo Settings page. Click on Webhooks and `Add Webhook` and set the following parameters:

- Payload URL to `{{BASE_URL}}/authors/github_webhook` and 
- Content Type to `application/json`
- Add the same `<<secret_token>>` from the `Setup environment variables` section above
- Select `Let me select individual events` and click on `Issues` only.
- Set to `Active`
- Enable the Webhook
