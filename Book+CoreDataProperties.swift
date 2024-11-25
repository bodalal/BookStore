//
//  Book+CoreDataProperties.swift
//  My Book Store
//
//  Created by Mohammad Alkhaldi on 24/11/2024.
//
//

import Foundation
import CoreData


extension Book {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Book> {
        return NSFetchRequest<Book>(entityName: "Book")
    }

    @NSManaged public var author: String?
    @NSManaged public var note: String?
    @NSManaged public var title: String?
    @NSManaged public var year: String?

}

extension Book : Identifiable {

}
