import praw, json

# Tells the json encoder how to serialize comments and submission.
def serial(obj):
    if isinstance(obj, praw.objects.Comment):
        return obj.json_dict
    elif isinstance(obj, praw.objects.Submission):
        return obj.json_dict
    else:
        return obj

r = praw.Reddit('COMP-598 ML BOT'
                'Url: www.cs.mcgill.ca')


r.login('en4bz')
# Get all top post from this week. Currently the first page (25 posts)
# Need to set 'limit=x' to get x posts.
posts = r.get_subreddit('funny').get_top_from_week()
for post in posts:
    print 'pulling comments from', post
    # Expand all 'more comments'. This is the same as going through all the 
    # links on the webpage and expanding them. It will only expand links with
    # with more than 'threshold=2' children.
    post.replace_more_comments(limit=None, threshold=2)
    print 'complete'    
    post_info = {'meta': post.json_dict, 'comments': post.comments}
    # write to file
    f = open(str(post), 'w')
    json.dump(post_info, f, default=serial)
    f.close()
