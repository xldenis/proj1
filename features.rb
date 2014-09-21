require 'json'
require 'fast_stemmer'
require 'csv'

Encoding.default_external = "utf-8"
def markdown_strip(md)
 strip = md.gsub(/!?\[([^\[\]\(\)]*)\]\(.*\)/,'\1') #links
 strip = strip.gsub(/\*\*?([^\*]+)\*\*?/,'\1') #emphasis
 strip = strip.gsub(/\#{1,6}\s*(\w+)\n/,'\1')
end

def tokenize(string)
  string.downcase.split.map {|w| w.gsub('^',' ').split }.flatten
  .map {|w| Stemmer::stem_word(w.gsub(/[.|,|!|?|"|:]/,'')).force_encoding('utf-8')}
end


def traverse(node, &trans)
  children = if node['replies'] && node['replies'] != ""
    node['replies']['data']['children'].map {|n| traverse(n, &trans)}
  end
  [trans.call(node)] + (children || []).flatten
end

histogram = Hash.new(0)
posts = []
ARGV.each do |file|
  comments = JSON.parse(File.read(file).force_encoding('UTF-8'))['comments']

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

  filtered.each {|row| row[:tokens].map {|tok| histogram[tok] += 1} }
  posts << filtered
end

features = histogram.sort_by {|k,v| v}.last(2500).map {|m| m[0]}

posts.each_with_index do |post,i|
  uni_mat = post.map do |comment|
    mini_histo = comment[:tokens].each_with_object(Hash.new(0)) {|w,c| c[w] += 1}
    features.map {|f| mini_histo[f]}
  end
  puts features
  name = File.basename(ARGV[i],'.json') + "_filtered.csv"
  CSV.open(name, 'w') do |csv|
    csv << features
    uni_mat.map {|u| csv << u}
  end
end
# File.open(name,'w:UTF-8') {|f| f.write(filtered.to_json)}

# name = File.basename(file,'.json') + "_filtered.csv"
#   CSV.open(name, 'w') do |csv|
#     filtered.each do |ft|
#       csv <<[ft[:author], ft[:body], ft[:subreddit], ft[:score], ft[:tokens].join(" ")]
#     end
#   end