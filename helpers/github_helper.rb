require 'sinatra/base'

module GithubHelper
  def getUserFromGithub
      user_info = JSON.parse(RestClient.get("https://api.github.com/user",
                                            {:params => {:access_token => session[:access_token]}}))
  end

  def getAccessToken(session_code, client_id, client_secret)
      access_token = RestClient.post('https://github.com/login/oauth/access_token',
                               {:client_id => client_id,
                                :client_secret => client_secret,
                                :code => session_code},
                                :accept => :json)
  end

  def getPullRequest(repo_name, repo_state, page)
      repos = JSON.parse(RestClient.get("https://api.github.com/repos/amedia/#{repo_name}/pulls",{:params => {:state => repo_state, :page => page}, :Authorization => "token #{session[:access_token]}"}))
  end
end
