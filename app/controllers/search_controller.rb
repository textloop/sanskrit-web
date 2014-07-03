require 'xpathquery/error'

class SearchController < ApplicationController
	before_action :default_params, :only => :index
	before_action :validate_params, :only => :index

	# GET /search
	def index
		@query = {}
		@results = {
			:exact => {},
			:similar => {},
			:preceding => {},
			:following => {},
		}

		has_search = !params[:q].nil?
		if !has_search
			return
		end

		term = params[:q]
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
				dict = Dictionary.find_by! handle: dict_handle

				exact_results = dict.exact_matches(term)
				@results[:exact][dict] = exact_results

				similar_results = dict.similar_matches(term)
				@results[:similar][dict] = similar_results

				preceding_results = dict.preceding_matches(term)
				@results[:preceding][dict] = preceding_results

				following_results = dict.following_matches(term)
				@results[:following][dict] = following_results
			end
		rescue XPathQuery::Error => ex
			flash.now[:error] = ex.message
			flash.now[:query] = ex.query
			flash.now[:response] = ex.response
			flash.now[:cause] = ex.cause.inspect
		end
	end

	# GET /search/:id # <- FIXME update to a better path
	def show
	end

	def default_params
		if !params[:q]
			return
		end

		params[:iscript] ||= 'slp1'
		params[:oscript] ||= 'devanagari'
		params[:dict] ||= ['monier'] # FIXME: use all dictionaries if no dict has been specified
	end

	def validate_params
		# TODO: raise if problems detected
	end
end