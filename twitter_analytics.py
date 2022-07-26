import boto3
import json
from datetime import datetime
import calendar
import random
import time
import sys
from tweepy.streaming import StreamListener
from tweepy import OAuthHandler
from tweepy import Stream

#Variables that contains the user credentials to access Twitter API
consumer_key = ''
consumer_secret =''
access_token = ''
access_token_secret = ''


class TweetStreamListener(StreamListener):        
    # on success
    def on_data(self, data):
        # decode json
        tweet = json.loads(data)
        # print(tweet)
        if "text" in tweet.keys():
            payload = {'id': str(tweet['id']),
                                  'tweet': str(tweet['text'].encode('utf8', 'replace')),
                                  'ts': str(tweet['created_at']),
            },
            print(payload)
            try:
                put_response = kinesis_client.put_record(
                                StreamName=stream_name,
                                Data=json.dumps(payload),
                                PartitionKey=str(tweet['user']['screen_name']))
            except (AttributeError, Exception) as e:
                print (e)
                pass
        return True
        
    # on failure
    def on_error(self, status):
        print(status)


stream_name = 'terraform-kinesis-test'  # fill the name of Kinesis data stream you created

if __name__ == '__main__':
    # create kinesis client connection
    kinesis_client = boto3.client('kinesis', 
                                  region_name='',  # enter the region
                                  aws_access_key_id='',  # fill your AWS access key id
                                  aws_secret_access_key='')  # fill you aws secret access key
    # create instance of the tweepy tweet stream listener
    listener = TweetStreamListener()
    # set twitter keys/tokens
    auth = OAuthHandler(consumer_key, consumer_secret)
    auth.set_access_token(access_token, access_token_secret)
    # create instance of the tweepy stream
    stream = Stream(auth, listener)
    # search twitter for tags or keywords from cli parameters
    query = sys.argv[1:] # list of CLI arguments 
    query_fname = ' '.join(query) # string
    stream.filter(track=query)