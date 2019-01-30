//
//  AccountScreenViewController.swift
//  Landmark
//
//  Created by Max Kirkman on 17/12/18.
//  Copyright © 2018 Kirkman. All rights reserved.
//

import UIKit

class AccountScreenViewController: UIViewController, UITextFieldDelegate {

	/* Constant and Variable Declarations */
	private let minimumDistanceFromTop = CGFloat(700)
	private lazy var initialUsernameTopConstant = CGFloat(usernameTopConstraint.constant)
	private let defaults = UserDefaults.standard
	/* ---------------------------------- */

	/* Outlets */
	@IBOutlet weak var usernameTextField: UITextField! {
		didSet {
			usernameTextField.delegate = self
		}
	}
	@IBOutlet weak var usernameDisplayLabel: UILabel!
	@IBOutlet weak var invalidUsernameErrorLabel: UILabel!
	
	@IBOutlet weak var accountVisualsView: UIView!
	@IBOutlet weak var usernameInputView: UIView!
	
	@IBOutlet weak var usernameTopConstraint: NSLayoutConstraint!
	/* ------- */
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// subscribe to notifications when keyboard shows or hides
		NotificationCenter.default.addObserver(self, selector: #selector(NoteCreatorViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(NoteCreatorViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
		
		// display stored username
		if let username = defaults.string(forKey: VariableStorage.usernameDefaultsKey) {
			usernameDisplayLabel.text = username
		}
		else {
			usernameDisplayLabel.text = nil
		}
	}
	
	/* respond to keyboard appearence */
	@objc func keyboardWillShow(notification: NSNotification) {
		
		// access keyboard size from notification
		guard let userInfo = notification.userInfo else { return }
		if let keyboardSize = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
			
			// access draw frame of keyboard
			let keyboardFrame = keyboardSize.cgRectValue
			
			// adjust bottom constant for keyboard appearance
			if usernameTopConstraint.constant == initialUsernameTopConstant {
				usernameTopConstraint.constant -= keyboardFrame.height
			}
		}
		else { return }
	}
	
	@objc func keyboardWillHide(notification: NSNotification) {
		usernameTopConstraint.constant = initialUsernameTopConstant
	}
	/* ------------------------------ */

	// if return is pressed, dismiss keyboard
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		return true
	}

	// if text input is a valid username, store it when editing ends
	func textFieldDidEndEditing(_ textField: UITextField) {
		if textField.text?.meaningfulString != nil {
			defaults.set(textField.text, forKey: VariableStorage.usernameDefaultsKey)
			usernameDisplayLabel.text = textField.text
			textField.text = nil
			invalidUsernameErrorLabel.isHidden = true
		}
		else {
			invalidUsernameErrorLabel.isHidden = false
		}
	}
}
