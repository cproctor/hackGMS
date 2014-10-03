The To-Do List
==============

Feel free to add items here, or remove anything you've finished. 

Backend
-------

- We don't know all the requirements yet, but we will definitely need to provide a way
  for the frontend to get all the current messages. This will be accomplished by the route
  `/api/messages`. So if the server is at `http://burks.girlsms.org:5000`, you (or the 
  frontend website) can get the list of messages by going to 
  `http://burks.girlsms.org:5000/api/messages`.
  
  Chris has put this route in place (in `backend/server.py`), but it doesn't currently do
  anything. Messages will be formatted in JSON (read up on this). For example, the list
  of messages might look like this:
  
      [
        {"message": "All basketball practices have been cancelled today."},
        {"message": "There is a crocodile loose in the school."}
      ]
      
  We have not yet built a way of keeping track of the messages. So for now, have the route
  return a fake list of messages.

Frontend
--------

- Create an initial look for the website, with one message in place (Just hardcode the 
  message for now with a `div` containing a typical message. Something like "All 
  basketball practices have been cancelled for this afternoon". Once we write the 
  necessary javascript, the site will ask the backend for the real list of current 
  messages, and show each one appropriately. 


Product
-------

- The frontend and backend teams need an initial list of requirements. Let's express these
  in terms of user stories. Each user story should look like this:
  
      As a ______
      So that I can ______,
      I need to ______.
      
  For example: 
  
      As an administrator,
      So that I can easily communicate a mid-day schedule change
      I need to be able to add a message to the list of messages.
      
  The frontend and UI/UX teams will think about how the user will accomplish these,
  and the backend team will build the technology needed to power the frontend. 
