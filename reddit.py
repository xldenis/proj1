import praw

r = praw.Reddit('PRAW related-question monitor by u/_Daimon_ v 1.0'
                    'Url: https://praw.readthedocs.org/en/latest/'
                    'pages/writing_a_bot.html')

r.login()
all = r.get_subreddit('all')
posts = all.get_top_from_all(limit=1000)
for post in posts:
    print post
