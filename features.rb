require 'json'
require 'fast_stemmer'
require 'csv'

Encoding.default_external = "utf-8"

# String markdown formatting from text
def markdown_strip(md)
 strip = md.gsub(/!?\[([^\[\]\(\)]*)\]\(.*\)/,'\1') #links
 strip = strip.gsub(/\*\*?([^\*]+)\*\*?/,'\1') #emphasis
 strip = strip.gsub(/\#{1,6}\s*(\w+)\n/,'\1')
 strip = strip.gsub(/https?:\/\/\S+/,'\1')
end

# split text and remove punctuation before stemming words
def tokenize(string)
  string.downcase.split.map {|w| w.gsub('^',' ').split }.flatten
  .map {|w| Stemmer::stem_word(w.gsub(/[.|,|!|?|"|:]/,'')).force_encoding('utf-8')}
end

# convenient tree iterator to recurse over the comment trees in json
def traverse(node, &trans)
  children = if node['replies'] && node['replies'] != ""
    node['replies']['data']['children'].map {|n| traverse(n, &trans)}
  end
  [trans.call(node)] + (children || []).flatten
end

# keep track of global word frequencies
histogram = Hash.new(0)
posts = []
# read all file paths from STDIN
ARGV.each do |file|
  #comment section of post
  comments = JSON.parse(File.read(file).force_encoding('UTF-8'))['comments']
  filtered = comments.map do |com| 
    traverse(com) do |comment|
      # extract text
      body_string = markdown_strip(comment['body'])
      {
        author: comment['author'], #unused feature
        body: body_string,
        subreddit: comment['subreddit'], #label
        score: comment['score'], #unused feature
        tokens: tokenize(body_string),
      }
    end
  end.flatten

  filtered.each {|row| row[:tokens].map {|tok| histogram[tok] += 1} } # update global histogram
  posts << filtered
end

features = histogram.sort_by {|k,v| v}.last(2500).map {|m| m[0]} # sort in increasing order and extract top 2.5k words

posts.each_with_index do |post,i|
  unigram_mat = post.map do |comment|  # count occurence of the words from features in all comments
    mini_histo = comment[:tokens].each_with_object(Hash.new(0)) {|w,c| c[w] += 1}
    features.map {|f| mini_histo[f]}
  end
  name = "#{File.basename(ARGV[i],'.json')}_#{post.first[:subreddit]}.csv" # write frequency matrix to csv
  CSV.open(name, 'w') do |csv|
    csv << features
    unigram_mat.map {|u| csv << u}
  end
end

