
## :bamboo: RemoteWindowHiddenAccess by Gaponovoz

###### My own program that allows remote launch & control any app/window in hidden mode!

------------

Very simple, easy to deploy and open source! Can be used to remotely launch and control any program or window, totally invisibly. Does not prevent user from using PC at the same time!

This project consists of two logical parts: "Master"(Server) and "Slave"(Client). "Master" should be installed on your server; "Slave" - on a client's PC.

------------

#### HOW TO DEPLOY & START USING:
1.  Start any Windows server (you can even use Home editions, it does not matter), any 64-bit one will be good. 
2. Forward port, say, 447 for this server. I think any port can be used. Make sure to allow firewall rules too.
3. Download this repo and unpack as c:\master-server\
4. Run DEPLOY.bat
5. The server is now added to startup and running.
6. In CodeSlave\SLAVE.ahk, change localhost:447 to your own domain/address and port.
7. Save and compile using COMPILE.bat.
8. Keep in mind that libraries "winapi.ini" and "wininet.ini" must always be next to your SLAVE.exe.
9. Run your "Slave". It should now be added when you open or refresh your "Master" (link should have been created on your server's desktop earlier by DEPLOY.bat).


------------
#### Some "Master" screenshots:

![List of "Slaves"](https://i.ibb.co/pRVn3b8/Screenshot-6.jpg "List of "Slaves"")

![Control window realtime](https://i.ibb.co/By1KJVm/Screenshot-2.jpg "Control window realtime")

![](https://i.ibb.co/JqgmQqj/Screenshot-7.jpg)

![Take images of whole desktop](https://i.ibb.co/4ZTjnKC/Screenshot-3.jpg "Take images of whole desktop")

![List of installed apps](https://i.ibb.co/n89dJw3/Screenshot-4.jpg "List of installed apps")

![](https://i.ibb.co/n7x56SP/Screenshot-5.jpg)
