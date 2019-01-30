//
//  DatabaseManager.swift
//  Landmark
//
//  Created by Max Kirkman on 24/12/18.
//  Copyright © 2018 Kirkman. All rights reserved.
//

import Foundation
import FirebaseDatabase

/* static class allowing controlled access to program's database */
class DatabaseManager {
	
	static let databaseReference = Database.database().reference()
	
	/* database subsection names */
	static let notesReferenceName = "notes"
	static let usersReferenceName = "users"
	
	static let userReferenceName  = "user"
	static let titleReferenceName = "title"
	static let textReferenceName  = "text"
	
	static let latitudeReferenceName = "latitude"
	static let longitudeReferenceName = "longitude"
	/* ------------------------- */
	
	static let databaseErrorMessage = "Database Error!"

	static func addNoteToDatabase(note: UserNoteAnnotation) {
		
		/* store the note ID */
		let userReference = databaseReference.child(usersReferenceName).child(note.getUsername())
		let noteIDsReference = userReference.child(notesReferenceName)
		noteIDsReference.child("\(note.identifier)").setValue(true)
		/* ----------------- */
		
		/* store the note's internal data */
		let notesReference = databaseReference.child(notesReferenceName).child(note.identifier)
		
		notesReference.child("\(latitudeReferenceName)").setValue(note.coordinate.latitude)
		notesReference.child("\(longitudeReferenceName)").setValue(note.coordinate.longitude)
		notesReference.child("\(titleReferenceName)").setValue(note.getTitle())
		notesReference.child("\(userReferenceName)").setValue(note.getUsername())
		notesReference.child("\(textReferenceName)").setValue(note.text)
		/* ------------------------------ */
	}
	
	// create a user note from stored database data
	static func createNoteFrom(snapshot: DataSnapshot, with identifier: String) -> UserNoteAnnotation? {
		
		guard let value = snapshot.value as? NSDictionary else { return nil }

		// if all mandatory paramaters were successfully read
		if let latitude = value[latitudeReferenceName] as? Double,
		let longitude = value[longitudeReferenceName] as? Double,
		let username = value[userReferenceName] as? String,
		let title = value[titleReferenceName] as? String {
			
			// read optional parameters, and build a note
			let text = value[textReferenceName] as? String
			let noteCreator = NoteCreator(username: username, latitude: latitude, longitude: longitude)
			noteCreator.setIdentifier(as: identifier)
			noteCreator.setTitle(as: title)
			noteCreator.setNoteText(as: text)
		
			return noteCreator.createUserLocationNote()
		}
		else { return nil }
	}
	
	// get a unique identifier for a new note
	static func getNewNoteIdentifier() -> String {
		// generate a new empty child with a unique key in the database
		let newChild = databaseReference.child(notesReferenceName).childByAutoId()
		// return the unique key so it can be stored
		return newChild.key ?? databaseErrorMessage
	}
	
}

