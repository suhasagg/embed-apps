require 'geo_ruby'

module GeoTaskGenerator


  def GeoTaskGenerator.generate(options)

    #create an ft table table
    table_id=FtDao.instance.create_table(options[:table_name], [
        {"name"=>"task_id", "type"=>"number"},
        {"name"=>"area", "type"=>"location"},
        {"name"=>"state", "type"=>"number"},
        {"name"=>"gold_answer", "type"=>"string"}
    ])

    # set permission exportable
    FtDao.instance.set_exportable(table_id)
    FtDao.instance.change_ownership(table_id, options[:owner])

    # generate tasks
    ft_rows=[]
    i=0
    generate_cells(options[:rectangle], options[:resolution]) do |input|
      row="<Polygon><outerBoundaryIs><coordinates> #{input[:lng_ne]},#{input[:lat_sw]} #{input[:lng_ne]},#{input[:lat_ne]} #{input[:lng_sw]},#{input[:lat_ne]} #{input[:lng_sw]},#{input[:lat_sw]} #{input[:lng_ne]},#{input[:lat_sw]}</coordinates></outerBoundaryIs></Polygon>"
      ft_rows<<{:task_id=>i, :area=>row, :gold_answer=>nil, :state=>1}
      i=i+1

    end

    FtDao.instance.enqueue(table_id, ft_rows)

    return table_id
  end


  def GeoTaskGenerator.generate_cells(rectangle, resolution)

    lng_ne=rectangle["lng_ne"]
    lat_ne=rectangle["lat_ne"]
    lng_sw=rectangle["lng_sw"]
    lat_sw=rectangle["lat_sw"]

    ne=GeoRuby::SimpleFeatures::Point.from_x_y(lng_ne, lat_ne)
    n_w=GeoRuby::SimpleFeatures::Point.from_x_y(lng_sw, lat_ne)
    s_e=GeoRuby::SimpleFeatures::Point.from_x_y(lng_ne, lat_sw)

    lng_distance=ne.ellipsoidal_distance(n_w)
    lat_distance=ne.ellipsoidal_distance(s_e)

    div_lat=(lat_distance/(resolution["lat"].to_f*1000)).ceil
    div_lng=(lng_distance/(resolution["lng"].to_f*1000)).ceil

    res_lat=((lat_ne-lat_sw)/div_lat)
    res_lng =((lng_ne-lng_sw)/div_lng)

    0.upto(div_lat.to_i-1) do |i|
      0.upto(div_lng.to_i-1) do |j|
        cell_lat_sw=lat_sw+res_lat*i
        cell_lng_sw=lng_sw+res_lng*j
        cell_lat_ne=cell_lat_sw+res_lat
        cell_lng_ne=cell_lng_sw+res_lng
        task_input ={:lat_ne=>cell_lat_ne,
                     :lng_ne=>cell_lng_ne,
                     :lat_sw=>cell_lat_sw,
                     :lng_sw=>cell_lng_sw}
        yield(task_input)
      end
    end
  end
end