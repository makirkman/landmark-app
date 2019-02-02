# Landmark App
#### iOS app centred around MapKit annotations.

Landmark is an application which allows a user to track their location, and save past locations to a global database, allowing other users to see a shared history.

The application uses the Firebase database service for its backend, which requires the use of podfiles to implement in a project.
It should run fine on another computer without additional setup, but for editing, the project must be opened through the ".xcworkspace" file in the project folder, not the ".xcodeproj" file.


Brief Outline of Approach:

The first - and default - tab is a MapView, which connects to a FireBase database, and displays all stored user-notes, as well as the user's current location.
The map screen allows a user to save a note of their own at their current location, through a button which segues to a new screen where note details can be entered.
Once details are entered, the note is constructed and stored in the database.
If a user taps on an annotation in the map screen, a pop-up will show the annotation's title and the name of the user who created it. If the user taps on the details button in that pop-up, the app will segue to a details screen, showing the note's title & username, as well as its coordinates and optional additional text.

The application employs a TabView to switch between its three primary View Controllers.

User notes are implemented as a class inheriting from MKUserAnnotations, the default Apple map annotation class. This allows them to be displayed and stored easily, while conforming to the Apple design guidelines.
They are created through a Note Factory, which protects creation and ensures all necessary data is always present before a Note object is actually created.

In order to place a note of their own, users must go to the second tab, and set up a username under which their notes will be stored in the database. This tab is switched to automatically on load if the user has not set a username.
This only needs to be done once, as the name is stored as a UserDefault, but it can be changed at any time.

The final tab provides search functionality, and the ability to see all notes listed with their title and username. On this screen, the user can scroll through all past notes stored in the database, or click on the search bar at the top to search for specific notes by their title, username, or additional text. If a specific note is tapped on, it will segue to the note details screen described above.