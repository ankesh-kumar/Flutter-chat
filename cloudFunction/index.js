const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp(functions.config().firebase);

const firestore = functions.firestore;

exports.onUserStatusChange = functions.database
	.ref('/status/{id}')
	.onUpdate(event => {
		
		var db = admin.firestore();
		
		
		//const usersRef = firestore.document('/users/' + event.params.userId);
		const usersRef = db.collection("users");
		var snapShot = event.data;
		
		return event.data.ref.once('value')
			.then(statusSnap => snapShot.val())
			.then(status => {
				if (status === 'offline'){
					usersRef
						.doc(event.params.id)
						.set({
							isOnline: false,
							last_active: Date.now()
						}, {merge: true});
				}
			})
	});