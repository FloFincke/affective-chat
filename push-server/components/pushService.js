const apn = require('apn');
const database = require('./database');
let apnProvider;

const apnOptions = {
    token: {
        key: "AuthKey_T3G5YPJ4L9.p8",
        keyId: "T3G5YPJ4L9",
        teamId: "C7PLUFBAM2"
    },
    production: false
};

function newPush(phoneId, token, payload, isSilent) {
    apnProvider = new apn.Provider(apnOptions);

    //schedule push and put next schdule in callback
    //Log that in DB
    const note = new apn.Notification();
    note.expiry = Math.floor(Date.now() / 1000) + 3600; // Expires 1 hour from now.
    note.badge = 0;
    note.sound = isSilent ? null : "ping.aiff";
	  note.alert = isSilent ? null : payload.message;
    note.contentAvailable = 1;
    note.payload = payload;
    note.topic = "de.lmu.ifi.mobile.affective-chat";

    apnProvider.send(note, token).then((result) => {
      console.log(result);

      apnProvider.shutdown();

      const log = new database.Log({
          id: phoneId,
          content: database.MESSAGES.NEW_PUSH_SENT,
          createdAt: new Date()
      });

      log.save(function(err, data) {
          if (err) {
              console.log(err);
          } else {
              console.log(new Date + ' -- new push sent to phone with phoneId: ' + phoneId);
          }
      });
    });
}

module.exports = {
	newPush: newPush,
};