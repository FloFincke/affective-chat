var app = require('express')();
var http = require('http').Server(app);
var io = require('socket.io')(http);

var connectedUsers = [];
var messages = [];

app.get('/', function (req, res) {
    res.send('<h1>Affective Chat</h1>');
});

http.listen(3000, function () {
    console.log('Listening on *:3000');
});

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
            // TODO: User is not connected, send push instead
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
