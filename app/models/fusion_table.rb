class FusionTable

  MAXIMUM_INSERT = 499 #maximum insert queries according to https://developers.google.com/fusiontables/docs/developers_guide

  TABLE_BASE_URL = "https://www.google.com/fusiontables/DataSource?docid="
  GOOGLE_TABLE_REG = /https:\/\/www\.google\.com\/fusiontables\/DataSource\?docid=(.*)/


  def self.create(table_name, columns, exportable = false, owner_email = nil)
    fields = columns.map { |col| "'#{col["name"]}': #{col["type"].upcase}" }.join(", ")
    resp = FtDao.instance.request_sql("CREATE TABLE '#{table_name}' (#{fields})", "&encid=true")
    table_id = resp.body.split("\n")[1].chomp

    ft = FusionTable.new(table_id)
    ft.enable_exportable if exportable  # set permission exportable
    ft.owner_email= owner_email unless owner_email.nil?
    ft
  end

  def initialize (table_id_or_url)
    @queries = []
    if table_id_or_url[/http/].nil?
      @table_id = table_id_or_url
    else
      @table_id = GOOGLE_TABLE_REG.match(table_id_or_url)[1]
    end
  end

  def url
    TABLE_BASE_URL + @table_id
  end

  def schema
    resp = request_sql("DESCRIBE #{@table_id}")
    resp.body.split("\n")[1..-1].map do |col|
      col = col.split(",")
      {"name" => col[1], "type" => col[2]}
    end
  end

  def drop
    request_sql("DELETE FROM #{@table_id}")
  end

  def add_row(row, force_sync = false)
    raise ArgumentError unless (row.is_a? Hash)

    @queries << "INSERT INTO #{@table_id} (#{row.keys.join(",")}) VALUES (#{row.values.map { |value| "'#{value}'" }.join(",")});"
    self.flush() if (@queries.size >= MAXIMUM_INSERT) || force_sync
  end


  def import(task_column)
    request_sql("SELECT #{task_column}, count() FROM #{@table_id} group by #{task_column} ").body.split("\n")[1..-1].each do |cols|
      cols = cols.split(",")
      yield(cols[0])
    end
  end

  def clone(owner_email = nil)
    FusionTable.create("Data", self.schema, true, owner_email)
  end

  def enable_exportable
    acl_entry_visibility = <<-EOF
    <entry xmlns="http://www.w3.org/2005/Atom" xmlns:gAcl='http://schemas.google.com/acl/2007'> <category scheme='http://schemas.google.com/g/2005#kind' term='http://schemas.google.com/acl/2007#accessRule'/><gAcl:role value='reader'/> <gAcl:scope type="default"/> </entry>
    EOF
    FtDao.instance.request_acl(@table_id,acl_entry_visibility)
  end

  # Connect to service
  def owner_email=(email_owner)
    role = (email_owner[/@gmail/].nil?) ? "writer" : "owner"
    #generate queries for changing permission
    acl_entry_owner = <<-EOF
    <entry xmlns="http://www.w3.org/2005/Atom" xmlns:gAcl='http://schemas.google.com/acl/2007'><category scheme='http://schemas.google.com/g/2005#kind' term='http://schemas.google.com/acl/2007#accessRule'/> <gAcl:role value='#{role}'/> <gAcl:scope type='user' value='#{email_owner}'/></entry>
    EOF
    FtDao.instance.request_acl(@table_id,acl_entry_owner)
  end

  def request_sql(query, optional_params = nil)
    #delegate to FTDAO
    FtDao.instance.request_sql(query, optional_params)
  end

  def flush()
      if @queries.size > 0
        request_sql(@queries.join(""))
        @queries = []
      end
  end
end