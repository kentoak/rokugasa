import sys
sys.path.append('/home/pi/.local/lib/python3.9/site-packages')
import tweepy
import time

str = ''.join(sys.argv[1:])
CONSUMER_KEY=""
CONSUMER_SECRET=""
ACCESS_TOKEN=""
ACCESS_TOKEN_SECRET=""

auth = tweepy.OAuthHandler(CONSUMER_KEY,CONSUMER_SECRET)
auth.set_access_token(ACCESS_TOKEN, ACCESS_TOKEN_SECRET)
t = tweepy.API(auth)
str1 = str.replace('\\n',"\\n\\")
t.update_status(status=str1)
