#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU Lesser General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.

require 'rubygems'
require 'sinatra'
require 'datamapper'
require 'haml'

set :port, 8080

## MODEL

class Election
  include DataMapper::Resource
  
  property :id, Serial
  property :name, String
  property :num_votes, Integer
  
  has n, :candidates
end

class Candidate
  include DataMapper::Resource

  property :id, Serial
  property :name, String

  has n, :votes
  belongs_to :election
end

class Vote 
  include DataMapper::Resource

  property :id, Serial
  property :ip, String

  belongs_to :candidate
end

DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/electioneering.db")
DataMapper.finalize

Election.auto_upgrade!
Candidate.auto_upgrade!
Vote.auto_upgrade!

@@election = Election.first_or_create(:name => "US Presidential", :num_votes => 3)
Candidate.first_or_create(:election => @@election, :name => 'Obama')
Candidate.first_or_create(:election => @@election, :name => 'Palin')

def times_voted(ip)
  Vote.count(:conditions => ['ip = ?', ip])
end

def vote(ip, candidate)
  Vote.create(:ip => ip, :candidate => candidate) 
end

def collect_votes()
  votes = Candidate.all(:election => @@election).map{|c| [c.votes.count, c.name]}
  Hash[*votes.flatten].sort.reverse # show candidates with most votes first
end

# CONTROLLER

get '/' do
  redirect '/vote'
end

before '/vote*' do
  redirect '/results' unless times_voted(request.ip) < @@election.num_votes 
end

get '/vote' do
  @candidates = Candidate.all(:election => @@election)
  haml :candidates
end	

post '/vote/:candidate_name' do
  candidate_name = params[:candidate_name]
  candidate = Candidate.first(:name => candidate_name, :election => @@election) 
  vote(request.ip, candidate)
  redirect '/vote'
end

get '/results' do
  @votes = collect_votes 
  haml :results
end

__END__

## VIEW

@@ layout
%html
  = yield

@@ candidates
%title #{@@election.name}
%h3 Pick#{times_voted(request.ip) == 1 ? " Another":""} One#{times_voted(request.ip) == 2 ? " More":""}.
%ol
  - @candidates.each do |candidate|
    %li
      =candidate.name 
      %form{:method => "post", :action => "/vote/#{candidate.name}"}
        %input{:id => "#{candidate.name}", :value => "vote", :type => "submit"}

@@ results
%h3 Results:
%table
  - @votes.each do |num_votes, candidate|
    %tr{:id => "#{candidate}"}
      %td{:align => 'right'} #{candidate}:
      %td #{num_votes == 1 ? "1 vote" : "#{num_votes} votes"}
