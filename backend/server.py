# server.py
# ---------
# This script starts the backend server, so that requests from clients
# can be served. Clientswill ask for all the current messages, create messages,
# and delete messages, and the server will fulfill these requests.

# After running this script, you should be able to visit the following URLs in 
# your browser:

#   http://localhost:5000
#   http://localhost:5000/test

# When you want to stop the server, press control-C.

# flask is a small web application framework we'll use. Most of the hard work
# is already done for us!
# You can read about flask here: http://flask.pocoo.org/
from flask import Flask

# There, see! We made the app. 
app = Flask(__name__)

# Here we are saying what should happen when a user visits /, or the main page
# of the site
@app.route('/')
def mainPage():
    return "Hi! This is the message app!"

# Here we are saying what should happen when a user visits /test
@app.route('/test')
def testPage():
    return "The test worked!"


# Now that we've created the app, let's run it!
app.run()
