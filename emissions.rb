require 'nokogiri'
require 'open-uri'


page = Nokogiri::HTML(open("http://data.worldbank.org/indicator/EN.ATM.CO2E.PC"))
countries = page.css('td.views-field.views-field-country-value a')
ninestat = page.css('td.views-field.views-field-wbapi-data-value-2009.wbapi-data-value')
tenstat = page.css('td.views-field.views-field-wbapi-data-value-2010.wbapi-data-value.wbapi-data-value-last')

arr_of_ninestat = []
arr_of_tenstat= []

File.open('countries.txt','w') do |f|
  countries.each do |country|
    f.puts (country.text)
  end
end

ninestat.each do |stat|
  arr_of_ninestat << (stat.text)
end

tenstat.each do |stat|
  arr_of_tenstat << (stat.text)
end

File.open('countriesbyemissions.html', 'w') do |f|

  f.puts("<!DOCTYPE html>")
  f.puts("<head>
        <link rel='stylesheet' type='text/css' href='css/demo.css' />
    <link rel='stylesheet' type='text/css' href='css/common.css' />
        <link rel='stylesheet' type='text/css' href='css/style2.css' />
    <link href='http://fonts.googleapis.com/css?family=Open+Sans:300,700' rel='stylesheet' type='text/css' />
    <script type='text/javascript' src='js/modernizr.custom.79639.js'></script> 
    <script type='text/javascript' src='https://ajax.googleapis.com/ajax/libs/jquery/1.7.2/jquery.min.js'></script>

<script type='text/javascript'>
$(function(){
    $(countriesbyemissions.html).bind('mousemove', function(e){
        $('.imgDescription').css({
           left:  e.pageX + 5,
           top:   e.pageY - 20
        });
    });​
});
</script>

    <!--[if lte IE 8]><style>.main{display:none;} .support-note .note-ie{display:block;}</style><![endif]-->
    </head>")

  f.puts("</head>")
  f.puts("<body>")
  f.puts("<div class='header'>Change in Emissions from 2009 - 2010</div>")
  f.puts("<div class='container'><section class='main'><ul class='ch-grid'>")

  countries.each do |country|
    current_country = country.text.to_s

    if arr_of_tenstat[countries.index(country)].to_f > arr_of_ninestat[countries.index(country)].to_f
      type = "increase"
      change = arr_of_tenstat[countries.index(country)].to_f - arr_of_ninestat[countries.index(country)].to_f
    elsif arr_of_tenstat[countries.index(country)].to_f < arr_of_ninestat[countries.index(country)].to_f
      type = "reduction"
      change = arr_of_tenstat[countries.index(country)].to_f - arr_of_ninestat[countries.index(country)].to_f
    elsif (arr_of_tenstat[countries.index(country)].to_f == arr_of_ninestat[countries.index(country)].to_f) && (arr_of_tenstat[countries.index(country)].to_f > 0)
      type = "neutral"
      change = 0
    else
      type = "na"
      change = 0
    end

    if current_country.include?("(") || current_country.include?("'")
    else
      f.puts ("<span title='#{current_country}'><li><div class='ch-item #{type}' style='background-image:url(./images/flags/#{current_country.gsub(' ','-')}.png); background-repeat:no-repeat; background-size:115%; background-position:center center;'>   
        <div class='ch-info'><div class='ch-info-back'><h3>")

      if type == "na"
        f.puts("N/A</h3></div></div></div></li></span>")
      elsif type == "neutral"
        f.puts("0</h3></div></div></div></li></span>")
      elsif type == "increase"
        f.puts("+#{change.round(4)}</h3></div></div></div></li></span>")
      else
        f.puts("#{change.round(4)}</h3></div></div></div></li></span>")
      end      
    end
  end

  f.puts("</ul></section></div></body></html>")
end