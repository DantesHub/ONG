//
//  HighSchoolScreen.swift
//  ONG
//
//  Created by Dante Kim on 9/2/24.
//

import Foundation
import SwiftUI

struct HighSchoolScreen: View {
    @StateObject private var viewModel = HighSchoolViewModel()
    @FocusState private var isSearchFocused: Bool
    
    var body: some View {
        NavigationView {
            VStack {
                SearchBar(text: $viewModel.searchQuery)
                    .focused($isSearchFocused)
                
                List(viewModel.schools) { school in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(school.name)
                            .font(.headline)
                        Text("\(school.city), \(school.state)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 8)
                }
                .listStyle(PlainListStyle())
            }
            .navigationTitle("High School Search")
        }
        .onAppear {
            isSearchFocused = true
        }
    }
}

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            TextField("Search for schools", text: $text)
                .padding(7)
                .padding(.horizontal, 25)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .overlay(
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 8)
                        
                        if !text.isEmpty {
                            Button(action: {
                                self.text = ""
                            }) {
                                Image(systemName: "multiply.circle.fill")
                                    .foregroundColor(.gray)
                                    .padding(.trailing, 8)
                            }
                        }
                    }
                )
                .padding(.horizontal, 10)
        }
    }
}

struct HighSchoolScreen_Previews: PreviewProvider {
    static var previews: some View {
        HighSchoolScreen()
    }
}
