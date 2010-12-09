require 'rubygems'
require 'sinatra'
require 'datamapper'
require 'haml'

set :port, 8080

Candidates = [ 'Obama', 'Palin' ] 
NumVotes = 3

class Votes 
  include DataMapper::Resource
  property :id, Serial
  property :ip, String
  property :candidate, String
end

DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/electioneering.db")
DataMapper.finalize
Votes.auto_upgrade!

before '/vote*' do 
  redirect '/results' unless times_voted(request.ip) < NumVotes  
end

get '/vote' do
  haml :candidates
end	

post '/vote/:candidate' do
  vote(request.ip, params[:candidate])
  redirect '/vote'
end

get '/results' do
  haml :results
end

def times_voted(ip)
  Votes.count(:conditions => ['ip = ?', ip])
end

def vote(ip, candidate)
  Votes.create(:ip => ip, :candidate => candidate) 
end

def print_votes(candidate)
  num_votes = Votes.count(:conditions => ['candidate = ?', candidate])
  num_votes == 1 ? "1 vote" : "#{num_votes} votes"
end

__END__

@@ layout
%html
  = yield

@@ candidates
%h3 Pick#{times_voted(request.ip) == 1 ? " Another":""} One#{times_voted(request.ip) == 2 ? " More":""}.
%ol
  - Candidates.each do |candidate|
    %li
      =candidate 
      %form{:method => "post", :action => "/vote/#{candidate}"}
        %input{:value => "vote", :type => "submit"}

@@ results
%h3 Results:
%table
  - Candidates.each do |candidate|
    %tr 
      %td{:align => 'right'} #{candidate}:
      %td #{print_votes(candidate)}
