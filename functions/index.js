const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

// Google Maps APIキーを返す関数
exports.getGoogleMapsApiKey = functions.https.onRequest((req, res) => {
  // CORS設定
  res.set('Access-Control-Allow-Origin', '*');
  res.set('Access-Control-Allow-Methods', 'GET');
  res.set('Access-Control-Allow-Headers', 'Content-Type');

  if (req.method === 'OPTIONS') {
    res.status(204).send('');
    return;
  }

  // 本番用のAPIキーを返す
  const apiKey = functions.config().googlemaps?.apikey || 'YOUR_PRODUCTION_API_KEY';
  
  res.json({ apiKey });
});
