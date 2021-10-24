require 'nokogiri'
require 'httparty'
require 'byebug'

def scraper(url)
    unparsed = HTTParty.get(url)
    if (unparsed == nil)
        puts 'Could not get Data. Exiting...'
        return nil

    end
    parsed = Nokogiri::HTML(unparsed.body)
    data = parsed.css('table')

    arr = []
    obj = {}

    all_keys = data.xpath("//*[@class=\"prop-nam\"]").children.css("code")
    all_types = data.xpath("//*[@class=\"prop-ect\"]")
    all_descriptions = data.xpath("//*[@class=\"prop-desc\"]")
    count = all_keys.length

    for i in 1..count-1 # hier mal bei 3 starten jeder key kann mehrere types haben
      key = String.new(all_keys[i].children[1].attributes.to_h['title'].value)
      type = String.new(all_types[i].children[1].attributes.to_h['title'].value)
      desc = String.new(all_descriptions[i].children.to_s.gsub("\n", '').squeeze(' '))

      obj[key.to_sym] = { type: type, description: desc }
    end
    puts obj
    dataToWrite = ""
      obj.each do |key, value|
        dataToWrite += "#{key.to_s} | Type: #{value[:type]} \nBeschreibung:\n#{value[:description]} \n\n"


      end

      File.write("data.txt", dataToWrite)

    return obj
end

scraper('https://schema.org/JobPosting')
