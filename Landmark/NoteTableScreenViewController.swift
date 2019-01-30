//
//  NoteTableScreenViewController.swift
//  Landmark
//
//  Created by Max Kirkman on 22/12/18.
//  Copyright © 2018 Kirkman. All rights reserved.
//

import UIKit
import MapKit
import FirebaseDatabase

/* handle table view and note searching.								*
 *  search functionality based on tutorial at:							*
 *  raywenderlich.com/472-uisearchcontroller-tutorial-getting-started	*/
class NoteTableScreenViewController: UIViewController, UITableViewDataSource,
UITableViewDelegate, UISearchResultsUpdating {
	
	/* constants and variables */
	private var notes = [UserNoteAnnotation]()
	private var searchNotes = [UserNoteAnnotation]()
	
	private let searchController = UISearchController(searchResultsController: nil)
	
	private var searchBarIsEmpty: Bool {
		return searchController.searchBar.text?.isEmpty ?? true
	}
	private var searchIsActive: Bool {
		return searchController.isActive && !searchBarIsEmpty
	}
	/* ----------------------- */
	
	@IBOutlet weak var tableView: UITableView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		/* manage table view */
		self.tableView.dataSource = self
		self.tableView.delegate = self
		/* ----------------- */
		
		/* manage searching */
		self.searchController.searchResultsUpdater = self
		
		// initialise search controller properties
		self.searchController.obscuresBackgroundDuringPresentation = false
		self.searchController.searchBar.placeholder = "Find Note"
		definesPresentationContext = true
		
		if #available(iOS 11.0, *) {
			navigationItem.searchController = searchController
		} else {
			self.tableView.tableHeaderView = searchController.searchBar
		}
		/* ---------------- */
		
		updateTableFromDatabase()
		
		// allow child views to use large title displays on the nav bar in iOS11
		if #available(iOS 11.0, *) {
			self.navigationController?.navigationBar.prefersLargeTitles = true
			self.navigationItem.largeTitleDisplayMode = .never
		}
		
	}
	
	override func viewDidAppear(_ animated: Bool) {
		// deselect the previously selected row
		if let selectedRow = self.tableView.indexPathForSelectedRow {
			self.tableView.deselectRow(at: selectedRow, animated: true)
		}
	}
	
	/* table management */
	// create table view cell, and set its parameters
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		// check if there is a recycled cell available
		let identifier = "note"
		var noteCell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: identifier)
		// if not, create a new one
		if noteCell == nil {
			noteCell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
		}
		
		// determine the corresponding note for the cell
		let note: UserNoteAnnotation
		if searchIsActive {
			note = searchNotes[indexPath.row]
		}
		else {
			note = notes[indexPath.row]
		}
		
		// set the cell's parameters from the corresponding note
		noteCell!.textLabel?.text = note.getTitle()
		noteCell!.detailTextLabel?.text = note.getUsername()
		noteCell!.accessoryType = .disclosureIndicator
		
		return noteCell!
	}
	
	// determine the size of the table view to display
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if searchIsActive {
			return searchNotes.count
		}
		return notes.count
	}

	// when a note is selected, go to its details page
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let tappedNote: UserNoteAnnotation
		if searchIsActive {
			tappedNote = searchNotes[indexPath.row]
		}
		else {
			tappedNote = notes[indexPath.row]
		}
		performSegue(withIdentifier: VariableStorage.openDetailsIdentifier, sender: tappedNote)
	}
	/* ---------------- */
	
	/* search bar management */
	func updateSearchResults(for searchController: UISearchController) {
		if searchController.searchBar.text != nil {
			searchTableFor(searchText: searchController.searchBar.text!)
		}
	}
	
	private func searchTableFor(searchText: String) {
		// filter notes with a closure
		searchNotes = notes.filter({ (note: UserNoteAnnotation) -> Bool in
			// return notes with the specified title
			if note.getTitle().lowercased().contains(searchText.lowercased()) {
				return true
			}
			// return notes with the specified username
			else if note.getUsername().lowercased().contains(searchText.lowercased()) {
				return true
			}
			// return notes that contain the specified optional text
			else if note.text != nil, note.text!.lowercased().contains(searchText.lowercased()) {
				return true
			}
			return false
		})
		
		self.tableView.reloadData()
	}
	/* --------------------- */

	/* navigation */
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		// move to note details view
		if segue.identifier == VariableStorage.openDetailsIdentifier {
			if let note = sender as? MKAnnotation {
				NoteDetailsViewController.moveToNoteDetailsView(for: segue, sender: note)
			}
		}
	}
	
	/* internal database management */
	private func updateTableFromDatabase() {
		
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
			// store annotations in data array, and reload tableView
			self.notes = databaseNotes
			self.tableView.reloadData()
		})
		
	}

}
