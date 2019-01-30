//
//  NoteCreator.swift
//  Landmark
//
//  Created by Max Kirkman on 18/12/18.
//  Copyright © 2018 Kirkman. All rights reserved.
//

import Foundation
import MapKit
import FirebaseDatabase

/* Class to regulate note creation */
class NoteCreator {
	
	// parameters required for note creation
	private(set) var username: String
	private(set) var coordinate: CLLocationCoordinate2D
	private(set) var identifier: String?
	private(set) var noteTitle: String?
	// parameters optional for note creation
	private(set) var noteText: String?

	init(username: String, latitude: Double, longitude: Double) {
		self.username = username
		self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
	}
	
	// create & return a new note, only if there is a valid note title available
	func createUserLocationNote() -> UserNoteAnnotation? {
		if noteTitle != nil {
			// if no identifier has been pre-set, get a new one
			if identifier == nil {
				identifier = DatabaseManager.getNewNoteIdentifier()
			}
			// create a new note with stored data
			return UserNoteAnnotation(identifier: identifier!, title: noteTitle!, username: username, text: noteText, coordinate: coordinate)
		}
		else {
			return nil
		}
	}
	
	/* setters to ensure optionals are only filled with meaningful data */
	func setTitle(as newTitle: String?) {
		noteTitle = newTitle?.meaningfulString
	}
	
	func setNoteText(as newText: String?) {
		noteText = newText?.meaningfulString
	}
	/* ---------------------------------------------------------------- */
	
	// setter to prevent identifier from being overwritten if it has been set
	func setIdentifier(as newIdentifier: String) {
		if identifier == nil {
			identifier = newIdentifier
		}
	}
}
