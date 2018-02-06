const Agenda = require('agenda');
const moment = require('moment');
const pushService = require('./pushService');
const database = require('./database');

/* Variables */

const duration = (process.env.DURATION || 5) * 60; //5 min --> time of tracking
const pushScheduleTime = (process.env.PUSH_SCHEDULE_TIME || 5); //5 min --> time until next push
const timeout = (process.env.TIMEOUT || 5) * 60; //5 min --> time until a 'not in the mood' is triggered

const agenda = new Agenda();

database.connection.once('open', function() {
    agenda.mongo(database.db);

    agenda.define('push', function(job, done) {
        database.Phone.find({}).exec(function(err, phones) {
            phones.forEach(function(phone) {
                pushService.newPush(phone._id, phone.token, { 'duration': duration, 'timeout': timeout }, true);
            });
            done()
        });
    });
});



agenda.on('ready', function() {
    //sends first push right away and the following in regular intervals of 25min
    agenda.every(pushScheduleTime + ' minutes', 'push');
    agenda.start();
});



module.exports = agenda;