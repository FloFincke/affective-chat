const Agenda = require('agenda');
const apn = require('apn');

const database = require('./database');

const apnOptions = {
    token: {
        key: "AuthKey_T3G5YPJ4L9.p8",
        keyId: "T3G5YPJ4L9",
        teamId: "C7PLUFBAM2"
    },
    production: false
};

const apnProvider = new apn.Provider(apnOptions);


function newPushSchedule(phoneId) {
    const agenda = new Agenda();
    agenda.mongo(database.db);

    newPush(phoneId)

    agenda.define('push', function(job, done) {
        newPush(phoneId);
        done();
    });

    agenda.on('ready', function() {
        //sends first push right away and the following in regular intervals of 25min
        agenda.every('25 minutes', 'push');
        agenda.start();
    });

}

function newPush(phoneId) {
    //schedule push and put next schdule in callback
    //Log that in DB
    database.Phone.findOne({ _id: phoneId }, function(err, phone) {
        const note = new apn.Notification();
        note.expiry = Math.floor(Date.now() / 1000) + 3600; // Expires 1 hour from now.
        note.badge = 3;
        note.sound = "ping.aiff";
        note.alert = "\uD83D\uDCE7 \u2709 You have a new message";
        note.payload = { 'messageFrom': 'John Appleseed' };
        note.topic = "de.lmu.ifi.mobile.affective-chat";

        apnProvider.send(note, phone.token).then((result) => {

        	//TODO: check for errors
            console.log(new Date() + "-- pushed to :" + phone.token);

            const log = new database.Log({
                id: phoneId,
                content: database.MESSAGES.NEW_PUSH_SENT,
                createdAt: new Date()
            });

            log.save(function(err, data) {
                if (err) {
                    console.log(err);
                } else {
                    console.log(new Date + ' -- new push sent to phone with id: ' + phoneId);
                }
            });
        });
    });

}


module.exports = newPushSchedule;