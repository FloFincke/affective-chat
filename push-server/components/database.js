const mongoose = require('mongoose');

const db = mongoose.connect('mongodb://localhost/affective', { useMongoClient: true });
mongoose.Promise = global.Promise;

const Phone = mongoose.model('Phone', { username: String, token: String, createdAt: Date });

const Log = mongoose.model('Log', { id: String, content: String, createdAt: Date });

const MESSAGES = {
    NEW_DATA: "new data arrived",
    NEW_PUSH_SENT: "new push sent"
};

module.exports = {
	db: db,
	Phone: Phone,
	Log: Log,
	MESSAGES: MESSAGES
};

