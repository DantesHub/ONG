//
//  Date.swift
//  Resolved
//
//  Created by Dante Kim on 7/12/24.
//

import Foundation


extension Date {
    
    
  static let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    return formatter
  }()
    
    static var threeDaysAgo: Date {
        return Calendar.current.date(byAdding: .day, value: -3, to: Date()) ?? Date()
    }
    
    static func daysAgo(from: Int) -> Date {
        return Calendar.current.date(byAdding: .day, value: -from, to: Date()) ?? Date()
    }
    
    static func timeDifference(date1: String, date2: String) -> (unit: String, difference: Int) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone.current // Use the current time zone
        
        guard let firstDate = dateFormatter.date(from: date1),
              let secondDate = dateFormatter.date(from: date2) else {
            print("Error: Invalid date format", date1, date2)
            return ("Hours", 0)
        }
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day, .hour], from: firstDate, to: secondDate)
        
        if let days = components.day, days != 0 {
            return ("Days", abs(days))
        } else {
            let hours = abs(components.hour ?? 0)
            return ("Hours", hours)
        }
    }
    
    static func changeDateFormat(dateString: String, fromFormat: String, toFormat: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = fromFormat
        
        guard let date = dateFormatter.date(from: dateString) else {
            print("Error: Unable to parse the input date string")
            return dateString // Return original string if parsing fails
        }
        
        dateFormatter.dateFormat = toFormat
        return dateFormatter.string(from: date)
    }


    
    static func isFeb17() -> Bool {
        let calendar = Calendar.current
        
        var targetDateComponents = DateComponents()
        targetDateComponents.year = 2024
        targetDateComponents.month = 5
        targetDateComponents.day = 31
        
        var targetDateComponents2 = DateComponents()
        targetDateComponents2.year = 2024
        targetDateComponents2.month = 6
        targetDateComponents2.day = 7
        
        // Optionally, you can specify a time if needed
        // targetDateComponents.hour = 0
        // targetDateComponents.minute = 0
        
        // Get today's date
        let today = Date()
        
        // Compare the two dates' year, month, and day components
        let todayComponents = calendar.dateComponents([.year, .month, .day], from: today)
        
        if todayComponents.year == targetDateComponents.year &&
            todayComponents.month == targetDateComponents.month &&
            (todayComponents.day == targetDateComponents.day) {
            return true
        } else if todayComponents.year == targetDateComponents2.year &&
                    todayComponents.month == targetDateComponents2.month &&
                    (todayComponents.day == targetDateComponents2.day) {
            return true
        }  else {
            return false
        }
    }
    static func create1979() -> Date {
        let calendar = Calendar.current

        // Assuming you have a date to check

        // Create a DateComponents instance for January 1, 1979
        let targetComponents = DateComponents(year: 1979, month: 1, day: 1)
        let targetDate = calendar.date(from: targetComponents)!
        return targetDate
    }
    
    static func getTomorrowDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd"
        
        let today = Date()
        guard let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today) else {
            return ""
        }
        
        return dateFormatter.string(from: tomorrow)
    }
    
    static     func newStartDate(relapseDate: String) -> Date {
        let currentDate = Date()
        let calendar = Calendar.current
        let eightHoursAgo = calendar.date(byAdding: .hour, value: -8, to: currentDate)!
        
        switch relapseDate {
        case "Didn't Relapse":
            return currentDate // Or you might want to return nil or handle this case differently
        case "Just Now":
            return currentDate
        case "Today":
            return eightHoursAgo
        case "Yesterday":
            return calendar.date(byAdding: .day, value: -1, to: currentDate)!
        case "2 days ago":
            return calendar.date(byAdding: .day, value: -2, to: currentDate)!
        case "3 days ago":
            return calendar.date(byAdding: .day, value: -3, to: currentDate)!
        case "4 days ago":
            return calendar.date(byAdding: .day, value: -4, to: currentDate)!
        case "5 days ago":
            return calendar.date(byAdding: .day, value: -5, to: currentDate)!
        case "6 days ago":
            return calendar.date(byAdding: .day, value: -6, to: currentDate)!
        case "1 week ago":
            return calendar.date(byAdding: .day, value: -7, to: currentDate)!
        case "8 days ago":
            return calendar.date(byAdding: .day, value: -8, to: currentDate)!
        case "9 days ago":
            return calendar.date(byAdding: .day, value: -9, to: currentDate)!
        case "10 days ago":
            return calendar.date(byAdding: .day, value: -10, to: currentDate)!
        case "11 days ago":
            return calendar.date(byAdding: .day, value: -11, to: currentDate)!
        case "12 days ago":
            return calendar.date(byAdding: .day, value: -12, to: currentDate)!
        case "13 days ago":
            return calendar.date(byAdding: .day, value: -13, to: currentDate)!
        case "2 weeks ago":
            return calendar.date(byAdding: .day, value: -14, to: currentDate)!
        case "3 weeks ago":
            return calendar.date(byAdding: .day, value: -21, to: currentDate)!
        case "4 weeks ago":
            return calendar.date(byAdding: .day, value: -28, to: currentDate)!
        case "5 weeks ago":
            return calendar.date(byAdding: .day, value: -35, to: currentDate)!
        case "6 weeks ago":
            return calendar.date(byAdding: .day, value: -42, to: currentDate)!
        case "7 weeks ago":
            return calendar.date(byAdding: .day, value: -49, to: currentDate)!
        case "2+ months ago":
            return calendar.date(byAdding: .month, value: -2, to: currentDate)!
        default:
            return calendar.date(byAdding: .month, value: -14, to: currentDate)! // Default case, you might want to handle this differently
        }
    }
    
    func checkif1979(date: Date) -> Bool {
        let calendar = Calendar.current

        // Assuming you have a date to check
        let dateToCheck: Date = Date()// Your date here

        // Create a DateComponents instance for January 1, 1979
        let targetComponents = DateComponents(year: 1979, month: 1, day: 1)
        let targetDate = calendar.date(from: targetComponents)!

        // Compare the two dates
        let componentsToCheck: Set<Calendar.Component> = [.year, .month, .day]
        let dateToCheckComponents = calendar.dateComponents(componentsToCheck, from: dateToCheck)

        let isJanuaryFirst1979 = dateToCheckComponents.year == 1979 &&
                                 dateToCheckComponents.month == 1 &&
                                 dateToCheckComponents.day == 1

        return isJanuaryFirst1979
    }
    func isDateOlderThanFiveDays() -> Bool {
        let calendar = Calendar.current
        if let fiveDaysAgo = calendar.date(byAdding: .day, value: -5, to: self) {
            return self < fiveDaysAgo
        }
        return false
    }
    // yyyy-MM-dd HH:mm:ss
    func toString(format: String = "yyyy-MM-dd") -> String {
      Date.dateFormatter.dateFormat = format
      let dateString = Date.dateFormatter.string(from: self)
        if format == "hha" {
          return dateString.trimmingCharacters(in: .whitespacesAndNewlines).trimmingLeadingZerosFromTime()
        } else {
          return dateString
        }
    }
    
    func formatted() -> String {
        Date.dateFormatter.dateFormat = "MMM d"
        let dateString = Date.dateFormatter.string(from: self)
        return dateString
    }
    
    // New function to convert String to Date
      static func fromString(_ dateString: String, format: String = "yyyy-MM-dd") -> Date? {
          Date.dateFormatter.dateFormat = format
          return Date.dateFormatter.date(from: dateString)
      }
    
    func isDateYesterday() -> Bool {
        let calendar = Calendar.current
        return calendar.isDateInYesterday(self)
    }
    
    func isDateTomorrow() -> Bool {
        let calendar = Calendar.current
        return calendar.isDateInTomorrow(self)
    }
    
    func isDateToday() -> Bool {
        let calendar = Calendar.current
        return calendar.isDateInToday(self)
    }
    
    
    func isAfterSix() -> Bool {
        
        // Get the hour component of the current date
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: self)
        
        // Check if the hour is after 18 (6 PM in 24-hour format)
        if hour <= 4 {
            return true
        } else {
            return hour >= 18
        }
    }
    
    func isMidnight() -> Bool {
        
        // Get the hour component of the current date
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: self)
        
        return hour <= 4
    }
}

extension String {
    func trimmingLeadingZerosFromTime() -> String {
      let parts = self.split(separator: ":")
      guard let firstPart = parts.first else {return self}
      return firstPart.trimmingCharacters(in: .whitespacesAndNewlines) + self.suffix(from: firstPart.endIndex)
    }
    
    subscript(idx: Int) -> String {
      String(self[index(startIndex, offsetBy: idx)])
    }
}
