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
from flask import Flask, render_template, make_response, request

# Then we'll be wanting the Message object because it has lots of great powers.
# See message.py to find out about this one. We also need access to the database
# for creating and deleting records.
from message import Message
from hack_gms_database import HackGMSDatabase
from helpers import get_date_from_json

from datetime import datetime

# Here are a few pretty standard libraries... read up on them if interested.
import json
import yaml
import os

# We'll go ahead and load the settings from the settings file.

settings_filename = os.path.join(os.path.dirname(__file__), 'settings.yaml')
with open(settings_filename) as settings_file:
    settings = yaml.load(settings_file.read())

# There, see! We made the app. 
app = Flask(__name__, template_folder="../frontend", static_folder="../frontend/static")
app.debug=True


# Here we are saying what should happen when a user visits /, or the main page
# of the site
@app.route('/')
def mainPage():
    return render_template('index.html')
    
# This renders the about page.
@app.route('/about')
def aboutPage():
    return render_template('about.html')

# Here we are saying what should happen when a user visits /test
@app.route('/test')
def testPage():
    return "The test worked!"

# Renders new-message page.
@app.route('/newmessage')
def newmessagePage():
   return render_template('newmessage.html')

# It would be nice if we could see the server's status (Chris will do this)
@app.route('/api/status')
def statusPage():
    return "This will be the status page."
    
# This should return the current list of messages.
@app.route('/api/messages')
def getMessages():
    messages_list = Message.get_all_messages()

    # Make a new list, swapping each message for a ready_for_json version of itself
    messages_as_json_list = [each_message.ready_for_json() for each_message in messages_list]

    # We need to get fancy here beacuse we want to set a response header--
    # a little hint telling the recipient what kind of thing is coming. 
    # In this case, we want to set the Content-Type header to "application/json",
    # so the Javascript knows to decode the response appropriately. 
    response = make_response(json.dumps(messages_as_json_list), 200)
    response.headers['Content-Type'] = "application/json"
    return response

# When someone sends a POST with valid JSON to this URL, a new message
# will be created.
@app.route('/api/messages/create', methods=["POST"])
def createNewMessage():
    text = request.json.get("text")
    date = datetime.utcnow()
    new_message = Message(text=text, date=date)
    if new_message.is_valid():
        HackGMSDatabase.create_message_record(new_message)
        response = make_response(json.dumps(new_message.ready_for_json()), 200)
    else:
        error_list = '; '.join(new_message.errors)
        response = make_response("There were errors creating your message: %s" % error_list, 400)
    return response

# Deletes the message with the specified id if it exists.
# If it does not exist, do nothing and report that the delete
# was unsuccessful.
@app.route('/api/messages/delete/<int:message_id>')
def deleteMessage(message_id):
    message_to_delete = Message.get_message_by_id(message_id)
    if message_to_delete is not None:
        HackGMSDatabase.delete_message_record(message_to_delete)
        response = make_response("Message %s was deleted." % message_id, 200)
    else:
        response = make_response("Message %s does not exist." % message_id, 404)
    return response 

# Now that we've created the app, let's run it!
app.run(host=settings['host'], port=settings['port'])
