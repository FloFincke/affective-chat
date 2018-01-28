const apn = require('apn');
const moment = require('moment');
const io = require('socket.io')(http);
const database = require('./database');

/* Variables */

const duration = (process.env.DURATION || 5) * 60; //5 min --> time of tracking
// const pushScheduleTime = (process.env.PUSH_SCHEDULE_TIME || 5); //5 min --> time until next push
const timeout = (process.env.TIMEOUT || 5) * 60; //5 min --> time until a 'not in the mood' is triggered

const apnOptions = {
    token: {
        key: "AuthKey_T3G5YPJ4L9.p8",
        keyId: "T3G5YPJ4L9",
        teamId: "C7PLUFBAM2"
    },
    production: false
};

let connectedUsers = [];
let messages = [];
let apnProvider;

io.on('connection', function (socket) {
    console.log('a user connected');

    socket.on("connectUser", function (username) {
        console.log('connectUser: ' + username);
        connectedUsers[username] = socket.id;
        console.log(connectedUsers);
    });

    socket.on('getNewMessages', function (username) {
        console.log('getNewMessages for: ' + username);
        var newMessages = messages[username];
        console.log(newMessages);
        io.to(socket.id).emit('newMessages', newMessages);
        delete messages[username];
    });

    socket.on('newMessage', function (conversationId, body, sender, recipient, timestamp) {
        console.log('newMessage: ' + body + ' from ' + sender + ' to ' + conversationId);
        var newMessage = {
            body: body,
            sender: sender,
            conversationId: conversationId,
            timestamp: timestamp
        };
        if (recipient in connectedUsers) {
            console.log('user is connected, emit message');
            io.to(connectedUsers[recipient]).emit("newMessage", newMessage);
        } else {
            if (recipient in messages) {
                console.log('user is not connected, push message');
                messages[recipient].push(newMessage);
            } else {
                console.log('user is not connected, create messages for recipient and add message');
                messages[recipient] = [newMessage];
            }
            apnProvider = new apn.Provider(apnOptions);
            database.Phone.find({username:recipient}).find({username:recipient}).sort({createdAt:-1}).limit(1).exec(function(err, phone) {
                newPush(phone._id, phone.token);
            });
        }
    });

    socket.on('appBackgrounded', function (username) {
        console.log('appBackgrounded');
        socket.disconnect();
        delete connectedUsers[username];
    })

    socket.on('disconnect', function () {
        console.log('user disconnected');
    });
});


function newPush(phoneId, token) {
    //schedule push and put next schdule in callback
    //Log that in DB
    const note = new apn.Notification();
    note.expiry = Math.floor(Date.now() / 1000) + 3600; // Expires 1 hour from now.
    note.badge = 0;
    note.sound = null;
    note.alert = null;
    note.contentAvailable = 1;
    note.payload = { 'duration': duration, 'timeout': timeout };
    note.topic = "de.lmu.ifi.mobile.affective-chat";

    apnProvider.send(note, token).then((result) => {

        //TODO: check for errors
        console.log(new Date() + " -- " + JSON.stringify(result));

        pushesLeft--;

        if(pushesLeft == 0) {
            apnProvider.shutdown();
        }

        const log = new database.Log({
            id: phoneId,
            content: database.MESSAGES.NEW_PUSH_SENT,
            createdAt: new Date()
        });

        log.save(function(err, data) {
            if (err) {
                console.log(err);
            } else {
                console.log(new Date + ' -- new push sent to phone with token: ' + phoneId);
            }
        });
    });
}