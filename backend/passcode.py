from Tkinter import *import webbrowserdef callback():    webbrowser.open_new('gms.org')top = Tk()L1 = Label(top, text="User Name")L1.grid(row=0, column=0)E1 = Entry(top, bd = 5)E1.grid(row=0, column=1)L1 = Label(top, text="Password")L1.grid(row=1, column=0)E1 = Entry(top, bd = 5)E1.grid(row=1, column=1)MyButton1 = Button(top, text="Submit", width=10, command=callback)MyButton1.grid(row=3, column=1)top.mainloop()