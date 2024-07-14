Mime::Type.register "text/csv", :csv

ActionController::Renderers.add :csv do |object, options|
  filename = options[:filename] || 'data'
  default_headers = options[:default_headers] || []
  str = CSV.generate do |csv|
    csv << (object.first.keys rescue default_headers  )# Adds the headers
    object.each do |row|
      csv << row.values
    end
  end
  send_data str, type: Mime[:csv], disposition: "attachment; filename=#{filename}.csv"
end
