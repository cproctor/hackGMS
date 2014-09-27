# Copyright (c) 2014 The Girls' Middle School
# Permission is hereby granted, free of charge, to any person obtaining a copy 
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights 
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell 
# copies of the Software, and to permit persons to whom the Software is 
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in 
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, 
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE 
# SOFTWARE.

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
app = Flask(__name__, template_folder="../frontend")
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


# Now that we've created the app, let's run it!
app.run(host='0.0.0.0')
