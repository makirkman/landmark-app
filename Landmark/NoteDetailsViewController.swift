//
//  NoteDetailsViewController.swift
//  Landmark
//
//  Created by Max Kirkman on 17/12/18.
//  Copyright © 2018 Kirkman. All rights reserved.
//

import UIKit
import MapKit

class NoteDetailsViewController: UIViewController {

	/* text parameters */
	// must be set by preparing in previous View Controller
	var noteLatitude: String?
	var noteLongitude: String?
	
	var noteTitleText: String?
	var noteUserText: String?
	var noteTextText: String?
	/* --------------- */
	
	private let noMandatoryTextError = "Error: No Information Available"
	
	// construct the coordinates display text from passed in data
	private var noteCoordinatesText: String {
		if noteLatitude != nil, noteLongitude != nil {
			return "\t" + noteLatitude! + ",\t\t" + noteLongitude!
		}
		return noMandatoryTextError
	}
	
	/* set all text fields to show their relevant data */
	@IBOutlet weak var noteUserTextLabel: UILabel! {
		didSet {
			noteUserTextLabel.text = noteUserText ?? noMandatoryTextError
		}
	}
	@IBOutlet weak var noteCoordinatesTextLabel: UILabel! {
		didSet {
			noteCoordinatesTextLabel.text = noteCoordinatesText
		}
	}
	
	@IBOutlet weak var noteTextTextView: UITextView! {
		didSet {
			noteTextTextView.text = noteTextText
		}
	}
	/* ----------------------------------------------- */
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// display note title in the navigation bar
		self.navigationItem.title = noteTitleText
		// use large title display on iOS11 devices
		if #available(iOS 11.0, *) {
			self.navigationItem.largeTitleDisplayMode = .always
		}
	}
	
	// standard method to call before moving to a note details view
	static func moveToNoteDetailsView(for segue: UIStoryboardSegue, sender: MKAnnotation) {
		// open the view controller and note
		if let noteDetailsViewController = segue.destination as? NoteDetailsViewController {
			// assign relevant text to Note Detail parameters
			if let note = sender as? UserNoteAnnotation {
				noteDetailsViewController.noteLatitude  =
					String(format: "%.3f", note.coordinate.latitude)
				noteDetailsViewController.noteLongitude =
					String(format: "%.3f", note.coordinate.longitude)
				
				noteDetailsViewController.noteTitleText = note.getTitle()
				noteDetailsViewController.noteUserText  = note.getUsername()
				noteDetailsViewController.noteTextText  = note.text
			}
		}
	}
}
