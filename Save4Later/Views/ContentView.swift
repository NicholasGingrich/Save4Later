//
//  ContentView.swift
//  Save4Later
//
//  Created by Nicholas Gingrich on 6/13/25.
//

import SwiftUI

struct ContentView: View {
    @State private var savedItem = ModelData().savedItems.first!
    var body: some View {
       SavedItemDetail(savedItem: savedItem)
    }
}

#Preview {
    ContentView()
        .environment(ModelData())
}
