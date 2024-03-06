import smtplib
from email.message import EmailMessage
import ssl
import os
import mimetypes
import sys


######
######          USAGE: python emailsend.py <email_receiver>
######


if len(sys.argv) < 2:
    print("Usage: python emailsend.py <receiver_email> <raport.pdf>")
    sys.exit(1)

message = EmailMessage()

sender = "duchbozena0@gmail.com"
to_addr = sys.argv[1]
subject = "Raport"
body = "It's your raport!"

message['From'] = sender
message['To'] = to_addr
message['Subject'] = subject
message.set_content(body)

email_password = 'qlkkftpxywlidrfi'
#qlkkftpxywlidrfi
context=ssl.create_default_context()


raport = sys.argv[2]


mime_type, _ = mimetypes.guess_type(raport)
mime_type, mime_subtype = mime_type.split('/')

with open(raport, 'rb') as file:
 message.add_attachment(file.read(),
 maintype=mime_type,
 subtype=mime_subtype,
 filename=raport)

with smtplib.SMTP_SSL('smtp.gmail.com',465,context=context) as smtp:
    smtp.login("duchbozena0@gmail.com",email_password)
    smtp.sendmail(sender,to_addr,message.as_string())
    print("Email sent successfully to", to_addr)
