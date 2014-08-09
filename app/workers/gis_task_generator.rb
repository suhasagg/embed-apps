 class GisTaskGenerator

  include Sidekiq::Worker

  def perform(table_name,rectangle, resolution , email)

    GeoTaskGenerator.generate({:table_name=>table_name,
                               :rectangle=>rectangle,
                               :resolution=>resolution,
                                        :owner=> email })
  end

end

