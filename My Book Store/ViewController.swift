//
//  ViewController.swift
//  My Book Store
//
//  Created by Mohammad Alkhaldi on 24/11/2024.
//

import Cocoa
import CoreData

class ViewController: NSViewController, NSTableViewDelegate {
    // For Core Data and NSArray controller
    @objc let managedObjectContext: NSManagedObjectContext
    required init?(coder: NSCoder) {
        self.managedObjectContext = (NSApp.delegate as! AppDelegate).persistentContainer.viewContext
        super.init(coder: coder)
    }
    
    func windowWillReturnUndoManager(window: NSWindow) -> UndoManager? {
        return managedObjectContext.undoManager
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Observe changes in the arrangedObjects of the array controller
        arrayController.addObserver(self, forKeyPath: "arrangedObjects", options: [.new, .initial], context: nil)

        // Update label for the initial state
        updateRecordLabel()
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "arrangedObjects" {
            updateRecordLabel()
        }
    }
    
    deinit {
        arrayController.removeObserver(self, forKeyPath: "arrangedObjects")
    }
    
    
    // MARK: - Outlet
    @IBOutlet weak var arrayController: NSArrayController!
    @IBOutlet weak var tableView: NSTableView!
    
    var isAscending = true // Tracks the sort order
    var previousTableColumn: NSTableColumn? // Tracks the previously clicked column
    
    func tableView(_ tableView: NSTableView, didClick tableColumn: NSTableColumn) {
        // Get the attribute key (identifier of the column)
        let attributeKey = tableColumn.identifier.rawValue
        
        // Create a sort descriptor based on the clicked column and sort order
        let sortDescriptor = NSSortDescriptor(key: attributeKey, ascending: isAscending)
        
        // Apply the sort descriptor to the Array Controller
        arrayController.sortDescriptors = [sortDescriptor]
        
        // Update sort indicators
        updateSortIndicator(for: tableColumn, in: tableView)
        
        // Toggle the sort order for the next click
        isAscending.toggle()
    }
    
    func updateSortIndicator(for tableColumn: NSTableColumn, in tableView: NSTableView) {
        // Clear the sort indicator from the previous column
        if let previousColumn = previousTableColumn, previousColumn != tableColumn {
            tableView.setIndicatorImage(nil, in: previousColumn)
        }
        
        // Set the sort indicator for the current column
        let sortIndicatorImage = NSImage(named: isAscending ? NSImage.touchBarGoUpTemplateName : NSImage.touchBarGoDownTemplateName)
        tableView.setIndicatorImage(sortIndicatorImage, in: tableColumn)
        
        // Update the reference to the currently sorted column
        previousTableColumn = tableColumn
    }
    
    // Add a new book
    @IBAction func addBook(_ sender: Any) {
        arrayController.add(nil)
        updateRecordLabel()
    }
    
    // Remove the selected book
    @IBAction func removeBook(_ sender: Any) {
        arrayController.remove(nil)
        updateRecordLabel()
    }
    
    // Save the changes to Core Data
    @IBAction func saveChanges(_ sender: Any) {
        do {
            try arrayController.managedObjectContext?.save()
        } catch {
            print("Failed to save: \(error)")
        }
    }
    
    // Navigate to the first book
    @IBAction func goFirst(_ sender: Any) {
        arrayController.setSelectionIndex(0)
        updateRecordLabel()
    }
    
    // Navigate to the last book
    @IBAction func goLast(_ sender: Any) {
        if let books = arrayController.arrangedObjects as? [Any] {
            if books.count > 0 {
                arrayController.setSelectionIndex(books.count - 1)
            }
        }
        updateRecordLabel()
    }
    
    // Navigate to the next book
    @IBAction func goNext(_ sender: Any) {
        let currentIndex = arrayController.selectionIndex
        if let books = arrayController.arrangedObjects as? [Any], currentIndex < books.count - 1 {
            arrayController.setSelectionIndex(currentIndex + 1)
        }
        updateRecordLabel()
    }
    
    // Navigate to the previous book
    @IBAction func goPrevious(_ sender: Any) {
        let currentIndex = arrayController.selectionIndex
        if currentIndex > 0 {
            arrayController.setSelectionIndex(currentIndex - 1)
        }
        updateRecordLabel()
    }
    
    // MARK: - Sorting
    @IBOutlet weak var sortComboBox: NSComboBox!
    @IBAction func sortBooksByAttribute(_ sender: NSComboBox) {
        // Get the selected item from the ComboBox
        let selectedAttribute = sender.stringValue.lowercased()
        
        // Ensure the selected attribute is valid
        let validAttributes = ["title", "author", "year"]
        if validAttributes.contains(selectedAttribute) {
            // Create a sort descriptor for the selected attribute
            let sortDescriptor = NSSortDescriptor(key: selectedAttribute, ascending: true)
            
            // Apply the sort descriptor to the array controller
            arrayController.sortDescriptors = [sortDescriptor]
        } else {
            print("Invalid sort attribute selected.")
        }
        updateRecordLabel()
    }
    
        // MARK: - Label Index
    @IBOutlet weak var recordLabel: NSTextField!
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        updateRecordLabel()
    }
    
    func updateRecordLabel() {
        // Get the total number of records
        let totalRecords = (arrayController.arrangedObjects as? [Any])?.count ?? 0

        // Get the currently selected index (1-based), accounting for no selection
        let selectedIndex = arrayController.selectionIndex

        // Update the label text
        if totalRecords == 0 {
            recordLabel.stringValue = "No Records"
        } else if selectedIndex == NSNotFound {
            recordLabel.stringValue = "No Selection"
        } else {
            recordLabel.stringValue = "Record \(selectedIndex + 1) of \(totalRecords)"
        }
    }
    
    
    
}
