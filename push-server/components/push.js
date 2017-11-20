const Agenda = require('agenda');
const apn = require('apn');

const database = require('./database');

/* Variables */

const duration = 20 * 60; //20 min --> time of tracking
const pushScheduleTime = 20;

const apnOptions = {
    token: {
        key: "AuthKey_T3G5YPJ4L9.p8",
        keyId: "T3G5YPJ4L9",
        teamId: "C7PLUFBAM2"
    },
    production: false
};

const apnProvider = new apn.Provider(apnOptions);

const agenda = new Agenda();
agenda.mongo(database.db);

agenda.define('push', function(job, done) {
    database.Phone.find({}).exec(function(err, phones) {
        phones.forEach(function(phone) {
            newPush(phone._id, phone.token);
        });
        done();
    });
});

agenda.on('ready', function() {
    //sends first push right away and the following in regular intervals of 25min

    agenda.every(pushScheduleTime + ' minutes', 'push');
    agenda.start();
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
    note.payload = { 'duration': duration };
    note.topic = "de.lmu.ifi.mobile.affective-chat";

    apnProvider.send(note, token).then((result) => {

        //TODO: check for errors
        console.log(new Date() + "-- pushed to :" + token);

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


module.exports = agenda;