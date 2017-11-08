/*


IDEEN:

man könnte mongoDB nutzen um einen Überblick über die Devices zu erhalten --> https://github.com/agenda/agenda

1. Register device (token, createdAt)
2. schedule first push
3. if push is sent schedule next (random time inbetween)

4. wenn data is received -> Log in MongoDB and save Data somewhere else (maybe S3) -> https://www.npmjs.com/package/s3


Für den Chat könnte man eigentlich ne socket sache basteln,d ann sollte kein großer Act sein. 

*/

var express = require('express')
var apn = require('apn');
var mongoose = require('mongoose');


//Express Setup

var app = express()
var port = process.env.PORT || 8080;

var bodyParser = require('body-parser');
app.use(bodyParser.json()); // support json encoded bodies
app.use(bodyParser.urlencoded({ extended: true })); // support encoded bodies


//MongoDB Setup

mongoose.connect('mongodb://localhost/affective', { useMongoClient: true });
mongoose.Promise = global.Promise;

var Phone = mongoose.model('Phone', { token: String, createdAt: Date });

//Push Setup

var options = {
    token: {
        key: "./AuthKey_T3G5YPJ4L9.p8",
        keyId: "T3G5YPJ4L9",
        teamId: "C7PLUFBAM2"
    },
    production: false
};

var apnProvider = new apn.Provider(options);


// API

app.post('/newDevice', function(req, res) {
    //Register device (token, createdAt)

    //schedule first push
});

app.post('/newData', function(req, res) {
    //Log in DB
    //Save in S3
});


function newPush() {
    //schedule push and put next schdule in callback
    //Log that in MongoDB

    let deviceToken = '9cf9ea6ddbdb00ae5a3d6f9f84613aecf8ab746230a829195ebaccf165063f9b';

    let note = new apn.Notification();
    note.expiry = Math.floor(Date.now() / 1000) + 3600; // Expires 1 hour from now.
    note.badge = 3;
    note.sound = "ping.aiff";
    note.alert = "\uD83D\uDCE7 \u2709 You have a new message";
    note.payload = { 'messageFrom': 'John Appleseed' };
    note.topic = "de.lmu.ifi.mobile.affective-chat";

    apnProvider.send(note, deviceToken).then((result) => {
        console.log(new Date() + "-- pushed to :" + deviceToken);
        jobs[deviceToken].cancel();
    });
}
newPush();


/*
var jobs = {};

app.post('/addPush', function(req, res) {

    //get device token
    var deviceToken = req.body.token;

    //get date
    var t = new Date(req.body.date);

    //get type
    var type = req.body.type;


    //remove this when going into production
    t = new Date();
    t.setSeconds(t.getSeconds() + 10);
    
    //schedule notification
    jobs[deviceToken] = schedule.scheduleJob(t, function(deviceToken) {

        //build notification
        var note = new apn.Notification();
        note.expiry = Math.floor(Date.now() / 1000) + 3600; // Expires 1 hour from now.
        note.badge = 0;
        note.sound = null;
        note.alert = null;
        note.contentAvailable = 1;
        note.topic = "de.lmu.ifi.mobile.bringmehome";
        note.payload = {'type': type};
        apnProvider.send(note, deviceToken).then((result) => {
          console.log(new Date() + "-- pushed to :" + deviceToken);
          jobs[deviceToken].cancel();
        });

    }.bind(null,deviceToken));

    res.sendStatus(200);
});

*/

var server = app.listen(port, function() {

    var host = server.address().address
    var port = server.address().port

    console.log("app listening at http://" + host + ":" + port)

});