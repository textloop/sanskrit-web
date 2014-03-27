class DictController < ApplicationController
	before_action :default_params, :only => :index
	before_action :validate_params, :only => :index

	# GET /dict
	def index
		@query = {}
		@results = {}

		has_search = !params[:s].nil?
		if !has_search
			return
		end

		term = params[:s]
		iscript = params[:iscript] # TODO: transliterate if needed
		oscript = params[:oscript] # TODO: add transliteration if needed
		dicts = params[:dict]

		@query = {
			:term => term,
			:iscript => iscript,
			:oscript => oscript,
			:dicts => dicts,
		}

		begin
			dicts.each do |dict_handle|
				dict = Dictionary.find_by handle: dict_handle
				results = dict.matches(term)
				@results[dict] = results
			end
		rescue Dictionary::DBError => e
			flash[:error] = "Error during search: #{e.class} #{e.message}"
		end
	end

	# GET /dict/:id # <- FIXME update to a better path
	def show
	end

	def default_params
		if !params[:s]
			return
		end

		params[:iscript] ||= 'slp1'
		params[:oscript] ||= 'devanagari'
		params[:dict] ||= []
	end

	def validate_params
		# TODO: raise if problems detected
	end
end