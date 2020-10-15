const functions = require('firebase-functions');

// The Firebase Admin SDK to access the Firebase Realtime Database.
const admin = require('firebase-admin');
admin.initializeApp(functions.config().firebase);
const db = admin.firestore();
const rt = admin.database();

const express = require('express');
const path = require('path');
var app = express();
const bodyParser = require('body-parser');

const accessToken = '900e84ef-0028-4f41-9481-ce1ff3ab699d';
const secret = 'AZI9szZ2TpD/YlHJ+flwW+rwiRpL28D2W6PcjSoCtqehFmLARgXDVcPl6j5H9yFxAMFCHq1pHta';

const Mux = require('@mux/mux-node');
const { Video, Data } = new Mux(accessToken, secret);


app.use(bodyParser.json());
app.use(bodyParser.urlencoded ({
      extended : true
  }));

app.use(express.static(path.join(__dirname,'public')));
app.set('views', path.join(__dirname, '/views'));
app.set('view engine', 'ejs');

// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
exports.helloWorld = functions.https.onRequest((request, response) => {
 response.send("Hello from Firebase LBTA!");
});

exports.MuxProcessing = functions.database.ref('/Mux-Processing/{ref}/{url}')
    .onWrite(async (change, context) => {

      const ref = context.params.ref;
      const getInfoProfile = admin.database().ref(`/Mux-Processing/${ref}`).once('value');
      const results = await Promise.all([getInfoProfile]);
      const infomation = results[0];
      //

      const url = infomation.val().url;


      return Video.Assets.create({

          input: url,
          "mp4_support": "standard",

      }).then(async (asset) => {

        return Video.Assets.createPlaybackId(asset.id, {
            policy: 'public',
            "mp4_support": "standard",
          }).then(async (result) => {

            const id = result.id;

            const highlightRef = db.collection('Highlights').doc(ref);

            const res = await highlightRef.update({
              Mux_processed: true,
              Mux_playbackID: id,
              status: 'Ready'});

            var rm = rt.ref('/Mux-Processing'+'/' + ref);
            rm.remove();

            console.log('Mux processed')

            return NULL;

          });

      });



});
