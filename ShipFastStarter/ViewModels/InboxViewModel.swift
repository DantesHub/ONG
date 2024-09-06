//
//  InboxViewModel.swift
//  ONG
//
//  Created by Dante Kim on 9/6/24.
//

import Foundation


class InboxViewModel: ObservableObject {
    @Published var tappedNotification: Bool = false
    @Published var selectedVote: Poll? 

    
}