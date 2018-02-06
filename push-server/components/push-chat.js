const apn = require('apn');
const moment = require('moment');
const app = require('../app');
const server = require('http').Server(app);
const io = require('socket.io')(server);
const database = require('./database');
const pushService = require('./pushService');

server.listen(3001);

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

io.on('connection', function(socket) {
    console.log('a user connected');

    socket.on("connectUser", function(username) {
        console.log('connectUser: ' + username);
        connectedUsers[username] = socket.id;
        console.log(connectedUsers);
    });

    socket.on('getNewMessages', function(username) {
        console.log('getNewMessages for: ' + username);
        var newMessages = messages[username];
        console.log(newMessages);
        io.to(socket.id).emit('newMessages', newMessages);
        delete messages[username];
    });

    socket.on('newMessage', function(conversationId, body, sender, recipient, timestamp) {
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
            /*if (recipient in messages) {
                console.log('user is not connected, push message');
                messages[recipient].push(newMessage);
            } else {
                console.log('user is not connected, create messages for recipient and add message');
                messages[recipient] = [newMessage];
            }*/

            database.Phone.find({ username: recipient }).find({ username: recipient }).sort({ createdAt: -1 }).limit(1).exec(function(err, phones) {
                pushService.newPush(phones[0]._id, phones[0].token, {'message': newMessage.sender + ':' + newMessage.body, 'duration': duration, 'timeout': timeout}, true);
            });
        }
    });

    socket.on('appBackgrounded', function(username) {
        console.log('appBackgrounded');
        socket.disconnect();
        delete connectedUsers[username];
    })

    socket.on('disconnect', function() {
        console.log('user disconnected');
    });
});