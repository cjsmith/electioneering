require 'sinatra'
require 'datamapper'
require  'dm-migrations'

candidates = ['science', 'math']

DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/blog.db")

class Candidates
    include DataMapper::Resource
    property :name, Serial
    property :num_votes, Integer
end

DataMapper.finalize

# automatically create the post table
Candidates.auto_migrate! unless Candidates.table_exists?

def vote_option(name)
	"<li><form method='post' action='/#{name}'>#{name}<input value='vote' type='submit'/></form></li>"
end

get '/' do
	"<h2>Pick one:</h2><ol>" + candidates.map{|candidate| display_candidate(candidate)}.join('<br/>') + "</ol>"
end	

post '/:name' do
	name = params[:name]
	candidate = Candidates.first_or_create(:name => option)
	candidate.num_votes += 1
	candidate.save!	
	redirect '/results'
end

get '/results' do
	Candidates.all.map{|candidate| "<li>#{candidate.name} = #{candidate.num_votes.to_s}</li>"}.join('<br>')
end



