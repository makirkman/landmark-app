//
//  UserNoteAnnotation.swift
//  Landmark
//
//  Created by Max Kirkman on 17/12/18.
//  Copyright © 2018 Kirkman. All rights reserved.
//

import Foundation
import MapKit

class UserNoteAnnotation: NSObject, MKAnnotation {
	
	
	// mandatory parameters
	let identifier: String
	let coordinate: CLLocationCoordinate2D
	let title: String?
	let subtitle: String?
	// non-mandatory parameter
	let text: String?
	
	private let missingTitleError = "Error: Missing Title"
	private let missingUsernameError = "Error: Missing Username"
	
	// create a new user note at the given location
	init(identifier: String, title: String, username: String, text: String?,
		 coordinate: CLLocationCoordinate2D) {
		
		// get a unique identifier for database storage
		self.identifier = identifier
		
		// set other internal parameters
		self.coordinate = coordinate
		self.title = title
		self.subtitle = username
		self.text = text
		
		super.init()
	}

	// getters to remove ambiguity around mandatory optional-types
	func getUsername() -> String {
		return subtitle ?? missingUsernameError
	}
	func getTitle() -> String {
		return title ?? missingTitleError
	}
}
