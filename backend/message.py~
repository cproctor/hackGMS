# message.py
# ----------
# This module defines the Message object.

# Authors:
# ----------
# Chris Proctor

# Python comes with a module called datetime. There's a datetime object
# inside (yes, confusing!) which can be used to represent a date and a time.
# Read more here: https://docs.python.org/2/library/datetime.html
from datetime import datetime

# And we'll need to get the database, where records of messages get stored.. 
# That's defined next door, in hack_gms_database.py
from hack_gms_database import HackGMSDatabase

# The main reason for defining a class is so that you can create
# instances of the class. This is more or less like creating a sprite in
# Scratch so that you can create clones. Our plan will be to create one
# Message object for each message in the database. We will define methods,
# which are abilities shared by each instance of the class. 
# Once we have defined Message, we will be able to import it into other 
# pieces of code (like server.py) and use it to create new Messages. For 
# example:
#
#     new_message = Message({"text": "There is no school on Monday"})
# 
class Message(object):

    # Gets all the messages in the database.
    # A classmethod is used by the class, not by instances of the class. This 
    # makes sense for a method like "get_all_messages" because that's not 
    # something a particular message knows how to do.
    @classmethod
    def get_all_messages(cls):

        # Ask the database for all the stored records of messages 
        # (in date order, please!)
        records_list = HackGMSDatabase.get_message_records()
        # Let's make a list to keep all the finished Messages
        messages_list = []
        # One by one, turn each record into a Message and add it to the list.
        for each_record in records_list:
            new_message = Message(*each_record)
            messages_list.append(new_message)
        # OK, all done. Let's return the list of messages.
        return messages_list

    # Gets a particular message in the database.
    # If it does not exist, returns None.
    @classmethod
    def get_message_by_id(cls, message_id):
        record = HackGMSDatabase.get_message_record(message_id)
        if record is not None:
            message = Message(*record)
            return message
        else:
            return None
        
    # __init__ is a sneaky method--this is what gets called when you create
    # a new Message. In the example above, we passed "There is no school on
    # Monday" into Message(). The function below is what's actually called. 
    # Every method in a class has a first argument of self. This is a reference
    # to the object itself. Humans have this built-in: if I ask you to touch
    # your ear, you will not accidentally touch someone else's ear. But 
    # instances of a class will not know themselves unless they have a 
    # variable they can use to locate themselves. Weird!
    def __init__(self, id=None, text=None, date=None):
        self.id = id
        self.text = text
        self.date = date

    # We will use this method to check whether the instance is valid. This is 
    # where we will add rules for what's required in a message. If we create a 
    # message that's not valid, we certainly don't want to save it. Instead, 
    # we will tell the user something's wrong. 
    def is_valid(self):
        # A simple rule: Messages must have a string called text and a datetime
        # called date.
        self.errors = []
        if not isinstance(self.text, basestring):
            self.errors.append("text (%s) must be a string" % self.text)
        if not isinstance(self.date, datetime):
            self.errors.append("date (%s) must be a date" % self.date)
        return not any(self.errors)

    # When you create a Message, it will only stick around until the end of the
    # program, and the program starts again each time someone loads the page.
    # But we can save a message in the database, where it will stay until 
    # we decide to delete it. 
    def save(self):
        # But we don't want junk messages getting saved. Let's report an error
        # if the message is not valid.
        if self.is_valid():
            HackGMSDatabase.save_message_record(self)
        else:
            raise ValueError("Tried to save an invalid message!")

    # Gives a version of this object that's ready to be encoded as JSON.
    def ready_for_json(self):
        return {
            "id": self.id,
            "text": self.text,
            "date": self.date.isoformat()
        }

    # Another sneaky method. This determines how the message will be printed if
    # anyone ever runs print(message). This is pretty much used when messing 
    # around or debugging.
    def __repr__(self):
        return ("Message(id=%(id)s, text=%(text)s, date=%(date)s)" % self.__dict__)
    
