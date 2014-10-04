Testing Messages
================

`message.py` defines a Message object. From this directory (backend), enter interactive
Python mode (by typing `python`), and try it out. First, you need to set up the database--
this only needs to be done once:

    >>> from hack_gms_database import HackGMSDatabase
    >>> HackGMSDatabase.initialize()

Now you can create and store messages:

    >>> from message import Message
    >>> from datetime import datetime
    >>> Message.get_all_messages()
    []
    >>> my_message = Message(text="Hi there!", date=datetime.now())
    >>> my_message.save()
    >>> Message.get_all_messages()
    [Message(id=1, text=Hi there!, date=2014-10-03 21:38:01.109877)]

Variables are destroyed when a program exits, which is why we need a database. 
When we store things in a database, they will still be there next time we run
the program. 
    

