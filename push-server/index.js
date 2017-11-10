/*

IDEEN:

1. Register device (token, createdAt)
2. schedule first push
3. if push is sent schedule next (random time inbetween)

4. wenn data is received -> Log in MongoDB and save Data in S3


Für den Chat könnte man eigentlich ne socket sache basteln,d ann sollte kein großer Act sein. 

*/

const express = require('express');
const apn = require('apn');
const mongoose = require('mongoose');
const AWS = require('aws-sdk');
const moment = require('moment');

/* --- Express Setup --- */

const app = express()
const port = process.env.PORT || 8080;

const bodyParser = require('body-parser');
app.use(bodyParser.json()); // support json encoded bodies
app.use(bodyParser.urlencoded({ extended: true })); // support encoded bodies

/* --- MongoDB Setup --- */

mongoose.connect('mongodb://localhost/affective', { useMongoClient: true });
mongoose.Promise = global.Promise;

const Phone = mongoose.model('Phone', { username: String, token: String, createdAt: Date });

const Log = mongoose.model('Log', { id: String, content: String, createdAt: Date });

const MESSAGES = {
    NEW_DATA: "new data arrived",
    NEW_PUSH_SCHEDULED: "new push scheduled",
    NEW_PUSH_SENT: "new push sent"
};

/* --- Push Setup --- */

const apnOptions = {
    token: {
        key: "./AuthKey_T3G5YPJ4L9.p8",
        keyId: "T3G5YPJ4L9",
        teamId: "C7PLUFBAM2"
    },
    production: false
};

const apnProvider = new apn.Provider(apnOptions);

/* --- S3 Setup --- */

AWS.config.update({ accessKeyId: process.env.AWS_ACCESS_KEY_ID, secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY });

const S3 = new AWS.S3();


/* --- API --- */


//Register device (receives token and username)

app.post('/newDevice', function(req, res) {

    if (req.body.username && req.body.token) {
        let date = new Date();
        let phone = new Phone({
            username: req.body.username,
            token: req.body.token,
            createdAt: date
        });

        phone.save(function(err, data) {
            if (err) {
                console.log(err);
                res.status(500).send(err);
            } else {
                console.log(date + ' -- Registered phone of ' + username + ' with token: ' + token);

                //TODO: schedule first push

                res.send(data.id);
            }
        });

    } else {
        res.sendStatus(422);
    }

});

app.post('/newData', function(req, res) {

    if (req.body.id) {
        Phone.findOne({ '_id': req.body.id }, function(err, phone) {
            if (phone) {
                //Save in S3
                S3.getSignedUrl('putObject', {
                    Bucket: 'affective-chat',
                    Key: phone.id + '/' + req.query.file_name, //filename should be YYYY-MM-DD_hh-mm-ss
                    ContentType: req.query.file_type
                }, function(err, data) {
                    if (err) return res.send('Error with S3')

                    res.json({
                        signed_request: data,
                        url: 'https://s3.amazonaws.com/' + S3_BUCKET + '/' + phone.id + '/' + req.query.file_name
                    })
                });

                //Log in DB
                let log = new Log({
                    id: phone._id,
                    content: MESSAGES.NEW_DATA,
                    createdAt: new Date()
                });

                log.save(function(err, data) {
                    if (err) {
                        console.log(err);
                        res.status(500).send(err);
                    } else {
                        console.log(date + ' -- new data from phone with id: ' + phone._id);
                        res.sendStatus(200);
                    }
                });

            } else {
                res.status(422).send('Phone not found');
            }
        });

    } else {
        res.sendStatus(422);
    }

});


function newPush(phoneId, token) {
    //schedule push and put next schdule in callback
    //Log that in DB
    let log = new Log({
        id: phoneId,
        content: MESSAGES.NEW_PUSH_SCHEDULED, //maybe add more here like when its scheduled etc.
        createdAt: new Date()
    });

    log.save(function(err, data) {
        if (err) {
            console.log(err);
            res.status(500).send(err);
        } else {
            console.log(date + ' -- new push scheduled for phone with id: ' + phone._id);
            res.sendStatus(200);
        }
    });

    //let deviceToken = '9cf9ea6ddbdb00ae5a3d6f9f84613aecf8ab746230a829195ebaccf165063f9b';

    let note = new apn.Notification();
    note.expiry = Math.floor(Date.now() / 1000) + 3600; // Expires 1 hour from now.
    note.badge = 3;
    note.sound = "ping.aiff";
    note.alert = "\uD83D\uDCE7 \u2709 You have a new message";
    note.payload = { 'messageFrom': 'John Appleseed' };
    note.topic = "de.lmu.ifi.mobile.affective-chat";

    apnProvider.send(note, deviceToken).then((result) => {
        console.log(new Date() + "-- pushed to :" + deviceToken);
        
        let log = new Log({
            id: phoneId,
            content: MESSAGES.NEW_PUSH_SENT,
            createdAt: new Date()
        });

        log.save(function(err, data) {
            if (err) {
                console.log(err);
                res.status(500).send(err);
            } else {
                console.log(date + ' -- new push sent to phone with id: ' + phoneId);
                res.sendStatus(200);
            }
        });
    });
}


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