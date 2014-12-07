# hack_gms_database
# =================
# Author: Chris Proctor
#
# Provides access to a simple database where we can store things so they
# stick around between runs of the program. The code in this file digs
# a little deeper--it will probably be quite confusing if you're new to 
# Python, and isn't written with a lot of explanatory comments. 
# This module exists so you don't have to think about all this anywhere
# else.

import sqlite3
import os.path as path
from flask import g

# Using the pattern from here: http://flask.pocoo.org/docs/0.10/patterns/sqlite3/
location_of_this_folder = path.dirname(path.abspath(__file__))
database_file_name = "hack_gms_database.sqlite3"
database_file = path.join(location_of_this_folder, database_file_name)

# Gets a database connection, creating it if necessary.
def get_db():
    db = getattr(g, '_database', None)
    if db is None:
        db = g._database = sqlite3.connect(database_file, 
                detect_types=sqlite3.PARSE_DECLTYPES|sqlite3.PARSE_COLNAMES,
                check_same_thread=False)
    return db

# Closes the database connection, if it's still open.
# This function should be called at the app.teardown_appcontext hook
def close_connection(exception):
    db = getattr(g, '_database', None)
    if db is not None:
        db.close()

class HackGMSDatabase(object):

    required_tables = ['messages', 'users']

    # Checks whether the schema (the table structure) is present in the 
    # database. When the app starts up, it will use this function to 
    # check whether we need to initialize. 
    @classmethod
    def schema_is_present(cls):
        cursor = get_db().cursor()
        cursor.execute("SELECT name FROM sqlite_master WHERE type='table';")
        table_names = [name[0] for name in cursor.fetchall()]
        for table_name in cls.required_tables:
            if not table_name in table_names:
                return False
        return True

    # Destroy everything in the database, even the structure of the tables,
    # and rebuild it from scratch. Careful with this one!
    @classmethod
    def initialize(cls):
        cursor = get_db().cursor()
        cursor.execute("DROP TABLE IF EXISTS messages;")
        cursor.execute("DROP TABLE IF EXISTS users;");
        cursor.execute("""
            CREATE TABLE messages (
                id INTEGER PRIMARY KEY,
                text TEXT,
                author TEXT,
                date TIMESTAMP
            );
        """)
        cursor.execute("""
            CREATE TABLE users (
                id INTEGER PRIMARY KEY,
                text fullname
            );
        """)
        cursor.close()
        get_db().commit();


    # Get all the message records.
    @classmethod
    def get_message_records(cls):
        cursor = get_db().cursor()
        cursor.execute("select * from messages where julianday('now') - julianday(messages.date) < 2 order by date desc");
        message_records = cursor.fetchall()
        cursor.close()
        return message_records

    # Get a particular record by its id. 
    @classmethod
    def get_message_record(cls, message_id):
        cursor = get_db().cursor()
        cursor.execute("SELECT * FROM messages WHERE id = ?;", (message_id,))
        record = cursor.fetchone()
        cursor.close()
        return record

    # If this message has no record in the database, let's create it. 
    # Otherwise, we need to update the record. We can tell which record
    # we're looking for by id. Messages get an ID when they are saved.
    @classmethod
    def save_message_record(cls, message):
        if message.id is None:
            cls.create_message_record(message)
        else:
            cls.update_message_record(message)

    # Create a new record.
    @classmethod
    def create_message_record(cls, message):
        cursor = get_db().cursor()
        cursor.execute(
            "INSERT INTO messages VALUES (NULL,?,?,?);", 
            (message.text, message.author, message.date)
        )
        get_db().commit()
        message.id = cursor.lastrowid
        cursor.close()

    # Update a record that exists.
    @classmethod
    def update_message_record(cls, message):
        cursor = get_db().cursor()
        cursor.execute(
            "UPDATE messages SET (text= ?, author= ?, date= ? ) WHERE id = ?;",
            (message.text, message.author, message.date, (message.id,))
        )
        get_db().commit()
        cursor.close()

    # Delete a record.
    @classmethod
    def delete_message_record(cls, message):
        cursor = get_db().cursor()
        cursor.execute("DELETE FROM messages WHERE id = ?;", (message.id,))
        get_db().commit()
        cursor.close()
        message.id = None
        
