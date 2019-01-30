//
//  NoteCreatorViewController.swift
//  Landmark
//
//  Created by Max Kirkman on 18/12/18.
//  Copyright © 2018 Kirkman. All rights reserved.
//

import UIKit
import MapKit

class NoteCreatorViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {
	
	/* general parameters */
	private lazy var initialBottomConstraintConstant = CGFloat(wholeViewBottomConstraint.constant)

	// text view constants
	private let textViewPlaceholderText = "Note Text (optional)"
	private let textViewPlaceholderTextColor = #colorLiteral(red: 0.7928509116, green: 0.7881390452, blue: 0.7964736819, alpha: 1)
	private let textViewBorderColor: CGColor = #colorLiteral(red: 0.8640654683, green: 0.8589296937, blue: 0.8680138588, alpha: 1)
	private let textViewTextColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
	private let textViewRadius = CGFloat(5)
	private let textViewBorderWidth = CGFloat(1)

	// program control parameters
	private var noteCreator: NoteCreator?
	var delegate: NoteStorer?
	
	// user data parameters - passed from previous View Controller
	var username: String?
	var userLocation: CLLocationCoordinate2D?
	/* ------------------ */

	// MARK: Outlets & Actions
	
	// handle view & constraints
	@IBOutlet weak var wholeViewBottomConstraint: NSLayoutConstraint!
	@IBOutlet weak var wholeViewTopConstraint: NSLayoutConstraint!
	
	@IBOutlet weak var invalidTitleErrorLabel: UILabel!
	
	/* handle text input */
	@IBOutlet weak var noteTitleTextField: UITextField! {
		didSet {
			noteTitleTextField.delegate = self
		}
	}
	// give the text view appropriate coloring & placeholder
	@IBOutlet weak var noteTextTextView: UITextView! {
		didSet {
			noteTextTextView.delegate = self
			// set placeholder
			noteTextTextView.text = textViewPlaceholderText
			noteTextTextView.textColor = textViewPlaceholderTextColor
			// set view outline
			noteTextTextView.layer.cornerRadius = textViewRadius
			noteTextTextView.layer.borderColor = textViewBorderColor
			noteTextTextView.layer.borderWidth = textViewBorderWidth

		}
	}
	/* ----------------- */
	
	/* store note information and leave view */
	@IBAction func SaveNote(_ sender: Any) {
		
		// store any input in text fields
		storeAllTextFields()
		
		// if the note could be constructed, store the note, and pop this view
		if let newNote = noteCreator?.createUserLocationNote() {
			delegate?.storeNewNote(newNote: newNote)
			self.navigationController?.popViewController(animated: true)
		}
		// if it couldn't, prompt user to enter a valid Note Title
		else {
			showErrorLabel(for: invalidTitleErrorLabel)
		}
	}
	/* ------------------------------------- */

	// MARK: General Methods
	// initial setup
	override func viewDidLoad() {
        super.viewDidLoad()

		// subscribe to notifications when keyboard shows or hides
		NotificationCenter.default.addObserver(self, selector: #selector(NoteCreatorViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(NoteCreatorViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
		
		// set up note creation to begin
		if username != nil, userLocation != nil {
			let latitude = userLocation!.latitude
			let longitude = userLocation!.longitude
			self.noteCreator = NoteCreator(username: username!,
					   latitude: latitude, longitude: longitude)
		}
    }

	/* handle keyboard appearence */
	@objc func keyboardWillShow(notification: NSNotification) {
		
		// access keyboard size from notification
		if let userInfo = notification.userInfo,
		 let keyboardSize = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
			// access draw frame of keyboard
			let keyboardFrame = keyboardSize.cgRectValue
			
			// adjust bottom constant for keyboard appearance
			if wholeViewBottomConstraint.constant == initialBottomConstraintConstant {
				wholeViewBottomConstraint.constant += keyboardFrame.height
			}

		}
	}

	@objc func keyboardWillHide(notification: NSNotification) {
		wholeViewBottomConstraint.constant = initialBottomConstraintConstant
	}
	/* -------------------------- */

	/* helper functions */
	// save data in all text fields
	private func storeAllTextFields() {
		// save note title if it is not empty
		if noteCreator != nil, noteTitleTextField.text?.meaningfulString != nil {
			noteCreator!.setTitle(as: noteTitleTextField.text)
			hideErrorLabel(for: invalidTitleErrorLabel)
		}
		else {
			showErrorLabel(for: invalidTitleErrorLabel)
		}
		// save note text if it is not the placeholder
		if noteCreator != nil, noteTextTextView.text != textViewPlaceholderText {
			noteCreator?.setNoteText(as: noteTextTextView.text)
		}
	}
	
	// show/hide an error label
	private func showErrorLabel(for label : UILabel) {
		label.isHidden = false
	}
	private func hideErrorLabel(for label: UILabel) {
		label.isHidden = true
	}
	
	// in text fields, dismiss keyboard if return is pressed
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		return true
	}
	// in text view, clear placeholder text when editing starts
	func textViewDidBeginEditing(_ textView: UITextView) {
		if textView.text == textViewPlaceholderText {
			textView.text = nil
			textView.textColor = textViewTextColor
		}
	}
	/* ---------------- */
}
