const functions = require('firebase-functions');

// The Firebase Admin SDK to access the Firebase Realtime Database.
const admin = require('firebase-admin');
admin.initializeApp(functions.config().firebase);
const db = admin.firestore();
const rt = admin.database();
const http = require('http');
const https = require('https');
const request = require('request');
const express = require('express');
const path = require('path');
var app = express();
const bodyParser = require('body-parser');

const accessToken = 'eeee4a87-bcf3-4ba3-8dbd-4b2b9d4a39f7';
const secret = '1noR31utvv295Ccoz1vmO0VOlN4d3d3rDaAMV4RF6Azis9GKywyQJ4tZtbjsUwIxrADQbTIhQjd';

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

exports.MuxProcessing = functions.database.ref('/Mux-Processing/{ref}/{urls}')
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
              h_status: 'Ready',
              Mux_assetID: asset.id});

            var rm = rt.ref('/Mux-Processing'+'/' + ref);
            rm.remove();

            console.log('Mux processed')

            return NULL;

          });

      });



});

exports.MuxDelete = functions.database.ref('/Mux-Deleting/{ref}/{id}')
    .onWrite(async (change, context) => {

      const ref = context.params.ref;
      const getInfoProfile = admin.database().ref(`/Mux-Deleting/${ref}`).once('value');
      const results = await Promise.all([getInfoProfile]);
      const infomation = results[0];
      //

      const id = infomation.val().id;

      Video.Assets.del(id);

      var rm = rt.ref('/Mux-Deleting'+'/' + ref);
      rm.remove();

      console.log('Mux-deleted')


});


exports.CmtDelete = functions.database.ref('/Cmt-Deleting/{ref}/{id}')
    .onWrite(async (change, context) => {

      const ref = context.params.ref;
      const commentRef = db.collection('Comments');

      var rm = rt.ref('/Cmt-Deleting'+'/' + ref);
      rm.remove();

      const snapshot = await commentRef.where('isReply', '==', true).where('cmt_status', '==', 'valid').where('root_id', '==', ref).get();

      if (snapshot.empty) {
          console.log('No matching documents.');
          return;

      }

      var count = 0
      var total = snapshot.size
      var dict = [];

      snapshot.forEach(doc => {

        dict.push({
            ITEM_ID: doc.id
        });

      });

      console.log(dict)
      MarkDelItem(0, dict)

});

async function MarkDelItem(index, dict) {

    if (index < dict.length) {

      var item = dict[index];

      const updateRef = db.collection('Comments').doc(`${item.ITEM_ID}`);

      const res = await updateRef.update({

          cmt_status: "deleted-by-root",
          updated_timeStamp: admin.firestore.Timestamp.now()

      })

      console.log("Del item ", `${item.ITEM_ID}`, index, "of ", dict.length);

      index++
      MarkDelItem(index, dict);


    }




}
