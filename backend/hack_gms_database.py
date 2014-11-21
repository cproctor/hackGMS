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


# Set-up code. We need to find out where we are. We will agree that the 
# database file (where the data actually gets stored) will be in the
# same directory as this file, and will have the name 
# "hack_gms_database.sqlite3". Therefore we can locate this file (or
# it will be created if it doesn't exist), and create a connection to 
# the database.
location_of_this_folder = path.dirname(path.abspath(__file__))
database_file_name = "hack_gms_database.sqlite3"
database_file = path.join(location_of_this_folder, database_file_name)

connection = sqlite3.connect(database_file, 
        detect_types=sqlite3.PARSE_DECLTYPES|sqlite3.PARSE_COLNAMES,
        check_same_thread=False)

create_table_test = 0


class HackGMSDatabase(object):

    @classmethod
    def create_message_table_if_necessary(cls):
        try:
            cursor = connection.cursor()
            cursor.execute("""
                CREATE TABLE messages (
                    id INTEGER PRIMARY KEY,
                    text TEXT,
                    date TIMESTAMP
                );
            """)
            connection.commit();
            cursor.close();    
        except sqlite3.Error as e:
            if e.args[0] != "table messages already exists":
                print "An error occurred:", e.args[0]
        

    # Destroy everything in the database, even the structure of the tables,
    # and rebuild it from scratch. Careful with this one!
    @classmethod
    def initialize(cls):
        cursor = connection.cursor()
        # Bye.
        cursor.execute("DROP TABLE IF EXISTS messages;")
        # Oh hello there!
        HackGMSDatabase.create_message_table_if_necessary()
        cursor.close()


    # Get all the message records.
    @classmethod
    def get_message_records(cls):
        global create_table_test
        if create_table_test == 0:
            create_table_test = 1
            HackGMSDatabase.create_message_table_if_necessary()
    
        cursor = connection.cursor()
        cursor.execute("select * from messages where julianday('now') - julianday(messages.date) < 2 order by date desc");
        message_records = cursor.fetchall()
        cursor.close()
        return message_records

    # Get a particular record by its id. 
    @classmethod
    def get_message_record(cls, message_id):
        cursor = connection.cursor()
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
        cursor = connection.cursor()
        cursor.execute(
            "INSERT INTO messages VALUES (NULL,?,?);", 
            (message.text, message.date)
        )
        connection.commit()
        message.id = cursor.lastrowid
        cursor.close()

    # Update a record that exists.
    @classmethod
    def update_message_record(cls, message):
        cursor = connection.cursor()
        cursor.execute(
            "UPDATE messages SET (text= ?, date= ? ) WHERE id = ?;",
            (message.text, message.date, (message.id,))
        )
        connection.commit()
        cursor.close()

    # Delete a record.
    @classmethod
    def delete_message_record(cls, message):
        cursor = connection.cursor()
        cursor.execute("DELETE FROM messages WHERE id = ?;", (message.id,))
        connection.commit()
        cursor.close()
        message.id = None
        


