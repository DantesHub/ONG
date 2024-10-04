//
//  Constants.swift
//  ShipFastStarter
//
//  Created by Dante Kim on 6/20/24.
//

import Foundation


struct Constants {
    static var userId = "userId"
    static var pollIds = "pollIds"
    static var currentIndex = "currentIndex"
    static var colors = [
           "blue",
           "green",
           "lightPurple",
           "orange",
           "pink",
           "red",
           "teal",
           "yellow"
       ]
    static var sawThisInboxItem = "sawThisInboxItem"
    static var finishedPollTutorial = "finishedPollTutorial"
    static var finishedFeedTutorial = "finishedFeedTutorial"
    static var viewedNotificationIds = "viewedNotificationIds"
}

struct FirestoreCollections {
    static var users = "users"
    static var polls = "_polls"
    static var votes = "_votes"
    static var schools = "highschools"
    static var bugs = "bugs"
}
