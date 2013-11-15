require 'nokogiri'
require 'sinatra'

def generate_routes src
  routes = []
   
  src.each_line do |line|
    from, to = line.split(/\s+/)
   
    from.gsub!(/\A\//, '')
    to.gsub!(/\/\z/, '/index.html')
    to.gsub!(/\A\//, '')
   
    routes << { :from => from, :to => to }
  end
   
  builder = Nokogiri::XML::Builder.new do |xml|
    xml.RoutingRules {
      routes.each do |route|
        xml.RoutingRule {
          xml.Condition {
            xml.KeyPrefixEquals route[:from]
          }
   
          xml.Redirect {
            xml.ReplaceKeyWith route[:to]
          }
        }
      end
    }
  end
   
  builder.to_xml
end


get '/' do
  "
<html>
<head>
  <title>Amazon S3 Redirector</title>
</head>
<body>
<h1>Generate redirect rules for Amazon S3</h1>
<p>This is opensource <a href='https://github.com/rainforestapp/amazon-s3-redirects'>on github</a> by <a href='https://www.rainforestqa.com/'>Rainforest QA</a> from the <a href='https://gist.github.com/chitsaou/5319661'>original gist</a> by <a href='https://github.com/chitsaou'>chitsaou</a>.
<p>Example:
<pre>
/home                        /
/products/iphone/specs.html  /iphone/specs.html
/products/iphone/            /iphone/
/products/ipad/accessories/  /ipad/accessories.html
/products/ipad/              /ipad/
/products                    /
</pre>

<p>Paste your stuff in here:
<form method='post'>
  <p><textarea name='text' cols=80 rows=8></textarea>
  <p><input type='submit' value='Give me the XML'>
</form>
"
end

post '/' do
  content_type 'text/plain'
  generate_routes(params['text'])
end