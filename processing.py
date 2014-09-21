import json, os, nltk, operator

def flatten(root):
    flat = []

    if 'body' in root:
        flat.append(root['body'])

    replies = root.get('replies', {})
    if isinstance(replies, dict):
        replies = replies.get('data', {})
        replies = replies.get('children', [])
        for reply in replies:
            flat += flatten(reply)

    return flat

from nltk.corpus import stopwords
from nltk.tokenize import RegexpTokenizer
stop = stopwords.words('english')

for filename in os.listdir('.'):
    f = open(filename, 'r')
    j = json.load(f)
    f.close()
    words = []
    for toplevel in j['comments']:
        flat = flatten(toplevel)
        flat = ' '.join(flat)
        tokenizer = RegexpTokenizer(r'\w+')
        words += [ w.lower() for w in tokenizer.tokenize(flat) if w not in stop]


    pr = nltk.probability.FreqDist(words)
    sorted_x = sorted(pr.iteritems(), key=operator.itemgetter(1))
    print sorted_x[-10:-1]


