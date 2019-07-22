//
//  Builders.swift
//  CheckoutApplet
//
//  Created by Kyle Van Essen on 6/21/19.
//

import Foundation


public extension TableView
{    
    struct ContentBuilder
    {
        public var content : TableView.Content {
            return TableView.Content(header: self.header, footer: self.footer, sections: self.sections)
        }
        
        public var header : TableViewHeaderFooter?
        public var footer : TableViewHeaderFooter?
        
        public var sections : [TableView.Section] = []
        
        public var isEmpty : Bool {
            for section in self.sections {
                if section.rows.count > 0 {
                    return false
                }
            }
            
            return true
        }
        
        public mutating func removeEmpty()
        {
            self.sections.removeAll {
                $0.rows.count == 0
            }
        }
        
        //
        // Single Sections
        //
        
        // Adds the given section to the builder.
        public static func += (lhs : inout ContentBuilder, rhs : TableView.Section)
        {
            lhs.sections.append(rhs)
        }
        
        //
        // Arrays of Sections
        //
        
        public static func += (lhs : inout ContentBuilder, rhs : [TableView.Section])
        {
            lhs.sections += rhs
        }
    }
    
    struct SectionBuilder
    {
        public var rows : [TableViewRow] = []
        
        public var isEmpty : Bool {
            return self.rows.count == 0
        }
        
        //
        // Single Rows
        //
        
        // Adds the given row to the builder.
        public static func += <Element:TableViewCellElement>(lhs : inout SectionBuilder, rhs : TableView.Row<Element>)
        {
            lhs.rows.append(rhs)
        }
        
        // Converts `Element` which conforms to `TableViewElement` into Rows.
        public static func += <Element:TableViewCellElement>(lhs : inout SectionBuilder, rhs : Element)
        {
            let row = TableView.Row(rhs)
            
            lhs.rows.append(row)
        }
        
        //
        // Arrays of Rows
        //
        
        // Allows mixed arrays of different types of rows.
        public static func += (lhs : inout SectionBuilder, rhs : [TableViewRow])
        {
            lhs.rows += rhs
        }
        
        // Arrays of the same type of rows – allows `[.init(...)]` syntax within the array.
        public static func += <Element:TableViewCellElement>(lhs : inout SectionBuilder, rhs : [TableView.Row<Element>])
        {
            lhs.rows += rhs
        }
        
        // Converts `Element` which conforms to `TableViewRowValue` into Rows.
        public static func += <Element:TableViewCellElement>(lhs : inout SectionBuilder, rhs : [Element])
        {
            let rows = rhs.map {
                TableView.Row($0)
            }
            
            lhs.rows += rows
        }
    }
}
