//
//  VariableStorage.swift
//  Landmark
//
//  Created by Max Kirkman on 22/12/18.
//  Copyright © 2018 Kirkman. All rights reserved.
//

import Foundation

/* pure fabrication class to store static variables that are needed	*
 *  across otherwise unconnected classes, reducing coupling			*/
class VariableStorage {
	
	static let usernameDefaultsKey = "username"
	
	static let openDetailsIdentifier = "Open Details"
	static let createNoteIdentifier = "Create Note"
	
}

/* general String extension - checks that any string has at 	*
 *  least one character & not just spaces						*/
extension String {
	var meaningfulString: String? {
		if !(self.split(separator: " ")).isEmpty {
			return self
		}
		else {
			return nil
		}
	}
}
