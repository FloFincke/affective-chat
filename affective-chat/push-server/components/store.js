const AWS = require('aws-sdk');
const multer = require('multer');
const moment = require('moment');

AWS.config.update({ accessKeyId: process.env.AWS_ACCESS_KEY_ID, secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY });

const S3 = new AWS.S3();

const multerUpload = multer({
    storage: multer.memoryStorage(),
    // file size limitation in bytes
    limits: { fileSize: 52428800 },
});

const uploadFile = (phoneId, file, callback) => {

    const params = {
        Bucket: 'affective-chat',
        Key: phoneId + '/' + moment().format('YYYY-MM-DD_HH-mm-ss') + '.zip',
        ACL: 'public-read',
        Body: file.buffer
    };

    S3.putObject(params, function(err, data) {
        if (err) {
            console.log("Error uploading image: ", err);
            callback(err)
        } else {
            console.log("Successfully uploaded image on S3");
            callback()
        }
    })
}

module.exports = {
    multerUpload: multerUpload,
    uploadFile: uploadFile
};