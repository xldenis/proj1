require 'json'
require 'fast_stemmer'
require 'csv'

Encoding.default_external = "utf-8"
def markdown_strip(md)
 strip = md.gsub(/!?\[(\w*)\]\(\w*\)/,'\1') #links
 strip = strip.gsub(/[**?|__?](.+)[**?|__?]/,'\1') #emphasis
 strip = strip.gsub(/\#{1,6}\s*(\w+)\n/,'\1')
end

def tokenize(string)
  string.split.map {|w| Stemmer::stem_word(w.gsub('.','')).force_encoding('utf-8')}
end


def traverse(node, &trans)
  children = if node['replies'] && node['replies'] != ""
    node['replies']['data']['children'].map {|n| traverse(n, &trans)}
  end
  [trans.call(node)] + (children || []).flatten
end

comments = JSON.parse(File.read(ARGV[0]).force_encoding('UTF-8'))['comments']

filtered = comments.map do |com| 
  traverse(com) do |comment|
    body_string = markdown_strip(comment['body'])
    {
      author: comment['author'],
      body: body_string,
      subreddit: comment['subreddit'],
      score: comment['score'],
      tokens: tokenize(body_string),
    }
  end
end.flatten

puts filtered.to_json
name = File.basename(ARGV[0],'.json') + "_filtered.csv"

CSV.open(name, 'w') do |csv|
  filtered.each do |ft|
    csv <<[ft[:author], ft[:body], ft[:subreddit], ft[:score], ft[:tokens].join(" ")]
  end
end
# File.open(name,'w:UTF-8') {|f| f.write(filtered.to_json)}