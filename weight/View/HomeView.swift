//
//  HomeView.swift
//  weight
//
//  Created by berkay on 25.07.2022.
//

import SwiftUI

struct HomeView: View {
    @FetchRequest(sortDescriptors: [SortDescriptor(\.time, order: .reverse)]) var things: FetchedResults<WeightEntity>

    var body: some View {
        NavigationView {
            List {
                Section {
                    HStack {
                        VStack {
                            Text("Initial").font(.callout).fontWeight(.bold)
                            Text(String(format: "%.1f kg", 105.0))
                        }
                        Spacer()
                        Divider()
                        Spacer()
                        VStack {
                            Text("Last").font(.callout).fontWeight(.bold)
                            Text(String(format: "%.1f kg", 98.3))
                        }
                        Spacer()
                        Divider()
                        Spacer()
                        VStack {
                            Text("Difference").font(.callout).fontWeight(.bold)
                            Text(String(format: "%.1f kg", 6.7))
                        }

                    }.padding()
                }
                Section {
                    Button {
                        //
                    } label: {
                        HStack {
                            Text("Add current weight")
                            Spacer()
                            Image(systemName: "plus")
                        }.padding().foregroundColor(.white)
                    }
                }.listRowBackground(Color.purple)
                Section {
                    VStack(spacing: 16) {
                        HStack {
                            Spacer()
                            Image(systemName: "square.fill").foregroundColor(.green)
                            Text("Mean")
                            Image(systemName: "square.fill").foregroundColor(.red)
                            Text("Goal")
                            Image(systemName: "square.fill").foregroundColor(.blue)
                            Text("Weight")
                            Spacer()
                        }
                    }
                }
            }.navigationTitle("Summary")
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
