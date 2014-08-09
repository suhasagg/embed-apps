require 'fusion_tables'
require 'open-uri'
require 'singleton'

class FtDao

  include Singleton

  FT_SERVICE_URL = "https://tables.googlelabs.com/api/query"
  DOC_SERVICE_URL = "https://docs.google.com/feeds/default/private/full/"

  def initialize()
    @ft = GData::Client::FusionTables.new
    @ft.clientlogin("citizencyberscience", "noisetube") # I know you know...
    @doclist = GData::Client::DocList.new(:authsub_scope => ["https://docs.google.com/feeds/"], :source => "fusiontables-v1", :version => '3.0')
    @doclist.clientlogin("citizencyberscience", "noisetube") # I know you know...
  end

  def request_sql(query, optional_params = nil)
    begin
      query = "sql=" + CGI::escape(query)
      query += optional_params unless optional_params.nil?

      @ft.post(FT_SERVICE_URL, query)
    rescue Exception => e
      raise Exception.new("Fusion table error for query: #{query} \n #{e.message} ")
    end
  end

  def request_acl(table_id, query)
    url = DOC_SERVICE_URL+table_id+"/acl"
    @doclist.post(url, query)
  end

end
