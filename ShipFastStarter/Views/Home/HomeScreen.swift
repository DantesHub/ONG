//
//  HomeScreen.swift
//  ShipFastStarter
//
//  Created by Dante Kim on 6/20/24.
//

import SwiftUI

struct HomeScreen: View {

    var body: some View {
        TestDatePickerView()
    }
}


#Preview {
    HomeScreen()
}


struct TestDatePickerView: View {
    @State private var birthDate = Date.now

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                
                DatePicker(selection: $birthDate, in: ...Date.now, displayedComponents: .date) {
                    Text("Select a date")
                }
                .datePickerStyle(WheelDatePickerStyle())

            }
            .frame(width: geometry.size.width, height: geometry.size.height) // Ensure ZStack takes the full size
        }
    }
}

