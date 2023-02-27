//----------Server for RemoteWindowHiddenAccess by Gaponovoz-----------


//=================Settings and usings======================
const express = require('express');
const fileUpload = require('express-fileupload');
const app = express();
const fs = require('fs');
var path = require('path');
const FormData = require('form-data');
const bodyParser = require('body-parser');
app.use(bodyParser.json());       
app.use(bodyParser.urlencoded({ extended: true})); 
app.use(fileUpload({
	createParentPath : true,
	limits: { fileSize: 10 * 1024 * 1024 },
	abortOnLimit : true,
}));
//app.use('/.well-known/acme-challenge/', express.static('C:/master-server/cert')); //for lets-encrypt certificate only!
//==========================================================


//=================GET request for file get=================
app.get('/', function(req, res)
{
	try
	{
	res.sendFile(req.query.GetFile, {root: 'C:/master-server/public/'});
	console.log(Date() + " " + req.ip + " got " + req.query.GetFile);
	}
	catch (error)
	{
	res.send("oops");
	}
});
//==========================================================


//===============POST request for file upload===============
app.post('/', function(req, res)
{
	let FileToUpload = req.files.FileToUpload;
	const { FutureFilePath } = req.body;
	let uploadPath = 'C:/master-server/public/' + FutureFilePath;
	
	FileToUpload.mv(uploadPath, function(err) { //move somewhere on my server
	if (err)
		return res.send("oops");
	
	console.log(Date() + " " + req.ip + " uploaded " + uploadPath);
	
	res.send('200.');
	});
});
//==========================================================


//============DELETE request for file delete================
app.delete('/', function(req, res)
{
	const { FileToDelete } = req.body;
	let deletePath = 'C:/master-server/public/' + FileToDelete;
	
	try
	{
	fs.unlinkSync(deletePath);
	console.log(Date() + " " + req.ip + " deleted " + deletePath);
	res.send("200.");
	}
	catch(error)
	{
	res.send("oops.");
	}

});
//==========================================================


//==============Starting server and listening===============
app.listen(447, () => {
  console.log(Date() + ": Server up and listening.");
});
//==========================================================