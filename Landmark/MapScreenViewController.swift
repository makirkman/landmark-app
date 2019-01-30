//
//  MapScreenViewController.swift
//  Landmark
//
//  Created by Max Kirkman on 17/12/18.
//  Copyright © 2018 Kirkman. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import FirebaseDatabase

protocol NoteStorer {
	func storeNewNote(newNote: UserNoteAnnotation)
}

class MapScreenViewController: UIViewController, CLLocationManagerDelegate,
	MKMapViewDelegate, NoteStorer {
	
	/* Constants and Variables */
	private let defaultLocation = CLLocation(latitude: -37.814, longitude: 144.96332)
	private let defaultRadius: CLLocationDistance = 1000
	private let accountTabIndex = 1
	
	private var createdNote: UserNoteAnnotation?
	
	private var locationManager: CLLocationManager!
	private var userLocation: CLLocation?
	
	private var notes = [UserNoteAnnotation]()
	/* ----------------------- */
	
	/* Outlets and Actions */
	@IBOutlet weak var mapView: MKMapView!
	
	@IBOutlet weak var noUsernameErrorLabel: UILabel!
	
	// control movement to the NoteCreatorViewController
	@IBAction func saveNote(_ sender: UIButton) {
		// display an error message if the user has not set a username
		let username = UserDefaults.standard.string(forKey: VariableStorage.usernameDefaultsKey)
		if username?.meaningfulString != nil {
			performSegue(withIdentifier: VariableStorage.createNoteIdentifier, sender: sender)
		}
		else {
			noUsernameErrorLabel.isHidden = false
		}
		
	}
	/* ------------------- */

	// MARK: Primary View Functions
	override func viewDidLoad() {
		super.viewDidLoad()
		
		mapView.delegate = self
		
		// set the map's initial display at defaultLocation
		let initialRegion = MKCoordinateRegion(center: defaultLocation.coordinate,
					latitudinalMeters: defaultRadius, longitudinalMeters: defaultRadius)
		mapView.setRegion(initialRegion, animated: true)
		
		// start tracking user location, and move there
		trackUserLocation()
		// update map with database notes
		updateMapAnnotationsFromDatabase()
		
		// allow child views to use large title displays on the nav bar in iOS11
		if #available(iOS 11.0, *) {
			self.navigationController?.navigationBar.prefersLargeTitles = true
			self.navigationItem.largeTitleDisplayMode = .never
		}
		
		// switch to the account tab if the user has not set a username
		if UserDefaults.standard.string(forKey: VariableStorage.usernameDefaultsKey) == nil {
			tabBarController?.selectedIndex = accountTabIndex
		}
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		// hide old error messages
		noUsernameErrorLabel.isHidden = true
		
		// if a note was created, add it to the database
		if createdNote != nil {
			DatabaseManager.addNoteToDatabase(note: createdNote!)
			createdNote = nil
		}
	}

    // MARK: - Navigation
    // prepare for navigation to different View Controllers
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

		// move to note creation view
		if segue.identifier == VariableStorage.createNoteIdentifier {
			if let noteCreatorViewController = segue.destination as? NoteCreatorViewController {
				// allow the new view controller to pass back its created note
				noteCreatorViewController.delegate = self
				// pass it the user's username and location
				let username = UserDefaults.standard.string(forKey: VariableStorage.usernameDefaultsKey)
				noteCreatorViewController.username = username
				noteCreatorViewController.userLocation = userLocation?.coordinate ?? defaultLocation.coordinate
			}
		}
		
		// move to note details view
		if segue.identifier == VariableStorage.openDetailsIdentifier {
			if let note = sender as? MKAnnotation {
				NoteDetailsViewController.moveToNoteDetailsView(for: segue, sender: note)
			}
    	}
	}
	
	/* internal database management */
	private func updateMapAnnotationsFromDatabase() {
		let notesReference = DatabaseManager.databaseReference.child(DatabaseManager.notesReferenceName)
		
		// closure subscribing to database, and controlling behaviour when it changes
		notesReference.observe(.value, with: { snapshot in
			
			// make an annotation for each note, and store it in an array
			var databaseNotes = [UserNoteAnnotation]()
			for data in snapshot.children {
				if let snapshot = data as? DataSnapshot,
					let newNote = DatabaseManager.createNoteFrom(snapshot: snapshot, with: snapshot.key) {
					databaseNotes.append(newNote)
				}
			}
			
			// remove old annotations (for debug case of note change)
			self.mapView.removeAnnotations(self.notes)
			// add found annotations to map, and update stored annotations
			self.notes = databaseNotes
			self.mapView.addAnnotations(databaseNotes)
		})
	}
	/* ---------------------------- */
	
	// MARK: additional protocol functionality
	
	// store a created note in this View Controller
	func storeNewNote(newNote: UserNoteAnnotation) {
		self.createdNote = newNote
	}
	
	/* handle annotation creation, and change their appearance to	*
	 *  include information button 									*
	 * guided by tutorial at:										*
	 *  raywenderlich.com/548-mapkit-tutorial-getting-started		*/
	func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {

		// return default annotation appearance (nil) if this is the user location
		if annotation is MKUserLocation { return nil }
		
		// begin constructing a note annotation
		let identifier = "note"
		// check if there is a recycled annotation view available
		var noteView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView
		if noteView != nil {
			noteView!.annotation = annotation
		}
		// if not, construct a new one
		else {
			// create annotation & add details button
			noteView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
			noteView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
			// set general annotation parameters
			noteView!.canShowCallout = true
			noteView!.sizeToFit()
		}
		return noteView
	}
	
	// move to note details if the details button is pressed
	func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
		if control == view.rightCalloutAccessoryView {
			performSegue(withIdentifier: VariableStorage.openDetailsIdentifier, sender: view.annotation)
		}
		
	}
	
	/* manage the tracking of user location											 *
	 * guided by tutorial at:														 *
	 *  swiftdeveloperblog.com/mapview-display-users-current-location-and-drop-a-pin */
	
	// set up user location tracking
	private func trackUserLocation() {
		// assign relevant parameters
		locationManager = CLLocationManager()
		locationManager.delegate = self
		locationManager.desiredAccuracy = kCLLocationAccuracyBest
		// request authorization and begin tracking
		if CLLocationManager.locationServicesEnabled() {
			locationManager.requestWhenInUseAuthorization()
			locationManager.startUpdatingLocation()
		}
	}
	// manage user location tracking
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		
		// initial setup behaviour: determine location & zoom
		if userLocation == nil {
			if let userLocation = locations.last {
				let viewRegion = MKCoordinateRegion(center: userLocation.coordinate, latitudinalMeters: defaultRadius, longitudinalMeters: defaultRadius)
				mapView.setRegion(viewRegion, animated: true)
			}
		}
		// general behaviour: update user location
		userLocation = locations.last
	}
}
