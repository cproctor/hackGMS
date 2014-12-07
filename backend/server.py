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

# The following libraries were written by other people. You can read all about
# them--look them up online!
from flask import Flask, render_template, make_response, request
from datetime import datetime
import json

# Then we will import stuff from other files in backend. You can read about
# these functions by opening the other files in this folder.
from message import Message
from hack_gms_database import HackGMSDatabase, close_connection
from helpers import get_date_from_json, get_settings, set_up_log

# Create the app
app = Flask(__name__, template_folder="../frontend", static_folder="../frontend/static")

# Before the first request comes in, check to make sure the database has the required 
# tables in place. Otherwise, create them.
@app.before_first_request
def make_sure_the_database_is_ready():
    if HackGMSDatabase.schema_is_present():
        app.logger.info(" * All required tables were found in the database.")
    else:
        app.logger.warn(" * Initializing the database.")
        HackGMSDatabase.initialize()

# This tells the app to close the database connection every time a request finishes
@app.teardown_appcontext
def when_the_request_ends(exception):
    close_connection(exception)


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
settings = get_settings()
set_up_log()
app.debug = settings['debug_mode']
app.logger.info(" * Press Control+C to stop the server. Log messages are being "+
        "saved to %s" % settings['log_file'])
app.run(host=settings['host'], port=settings['port'])
