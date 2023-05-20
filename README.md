# Backend can be found in the [backend]/server.py directory.

# The backend is a python script that uses the [flask] framework to serve the [frontend] to the user.

# The frontend is a [flutter] app that is served by the backend. The frontend is a web app that is served to the user.

# Steps to run the backend:
> Make sure that you have python3 installed </br>
> cd backend </br>
> python3 -m venv venv </br>
> source venv/bin/activate </br>
> pip install -r requirements.txt </br>
> python server.py </br>

# Steps to run the frontend:
> Make sure that you have the flutter SDK installed </br>
> cd to the root directory of the project </br>
> flutter run -d chrome --web-browser-flag "--disable-web-security" </br>


# Steps to request twitter data from the API:
> 1) Right now the API is not hosted anywhere, so you will have to run the backend locally and then make the API calls to localhost:5000</br>
> 2) To get the list of tweets for a given query along with the sentiment analysis, make a GET request to localhost:5000/twitter?query=q&limit=n where q is the query you want to search for and n is the number of tweets you want to get (default is 10). </br>
> 3) The response you will be getting will be in the form of list of JSON objects located in response['tweets']. </br>
> 4) Each JSON object will have the following fields: </br>
     tweet: The tweet text </br>
     sentiment: The sentiment of the tweet </br>
     uid: The unique id of the twitter user </br>
     date: The date of the tweet </br>

# Steps to request reddit data from the API:
> 1) Right now the API is not hosted anywhere, so you will have to run the backend locally and then make the API calls to localhost:5000</br>
> 2) To get the list of posts for a given query along with the sentiment analysis, make a GET request to localhost:5000/reddit?query=q&limit=n where q is the query you want to search for and n is the number of posts you want to get (default is 10). </br>
> 3) The response you will be getting will be in the form of list of JSON objects located in response['reddits']. </br>
> 4) Each JSON object will have the following fields: </br>
     body: The body of the post</br>
     url: The url of the post </br>
     sentiment: The sentiment of the post </br>
     uid: The unique id of the reddit user </br>
     date: The date of the post </br>



