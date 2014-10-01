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
from flask import Flask, render_template

# There, see! We made the app. 
app = Flask(__name__, template_folder="../frontend", static_folder="../frontend/static")
app.debug=True

# Here we are saying what should happen when a user visits /, or the main page
# of the site
@app.route('/')
def mainPage():
    return render_template('index.html')

# Here we are saying what should happen when a user visits /test
@app.route('/test')
def testPage():
    return "The test worked!"

# It would be nice if we could see the server's status
@app.route('/api/status')
def statusPage():
    return "This will be the status page."
    
# TODO Here's another 
def getMessages():
    


# Now that we've created the app, let's run it!
app.run(host='0.0.0.0')

#test during OH