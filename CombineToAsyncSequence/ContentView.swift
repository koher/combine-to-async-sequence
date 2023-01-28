//
//  ContentView.swift
//  CombineToAsyncSequence
//
//  Created by Yuta Koshizawa on 2023/01/28.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            NavigationLink("Open") {
                CounterView()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
