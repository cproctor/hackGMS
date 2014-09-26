Running the Server
==================

As you work on building the server, you will want to run it, to make sure it works. 


Installation
------------

Our server uses some other libraries to do its work:

- flask

For each library, you need to make sure it's installed on your machine. Luckily, there's
an easy way to install new Python libraries: `easy_install`! To install flask, run this
in Terminal (the `sudo` command at the beginning tells the computer you want to be a 
super-user, so you have access to system areas of the computer. You'll need to enter your
password):

    sudo easy_install flask
    
Running the server
------------------

Now you can run the server. From Terminal, just run this:

    python server.py
    
You should see the server program start, and when you go to http://localhost:5000 with 
a web browser, you'll see the project homepage! The Terminal window will show you the
requests coming in. When you want to stop the server, press Control and C at the same time.
