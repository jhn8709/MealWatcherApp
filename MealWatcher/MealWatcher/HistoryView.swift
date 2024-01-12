//
//  HistoryView.swift
//  WatchPhoneAppDemo
//
//  Created by Jimmy Nguyen on 6/10/23.
//

import SwiftUI

/* Include this in ContentView to use this view (Program will need many changes for this to work) */
//                        Button("History") {
//                            guard let sortedList = vm.getSortedList() else {return}
//                            if sortedList.isEmpty == true {
//                                return
//                            }
//                            else {
//                                dataCount = sortedList.count
//                            }
//                            historyList = sortedList
//                            navigateToHistoryView = true
//                            print("Navigating to history view")
//                        }
//                    .navigationDestination(isPresented: $navigateToHistoryView, destination: {
//                        HistoryView(dateList: historyList, listSize: dataCount)
//                    })

struct HistoryView: View {
    
    let dateList: [String]
    let listSize: Int
    @StateObject private var vm = FileManagerViewModel()
    @State var navigateToEditView: Bool = false
//    let monthRange = 0..<2
//    let dayRange = 3..<5
//    let yearRange = 6..<10
//    let hourRange = 11..<13
//    let minuteRange = 14..<16
//    let meridiem = 17
    
    var body: some View {
        NavigationView {
            VStack {
                List(0..<listSize) { item in
                    NavigationLink(destination: {
                        SurveyView(survey: EMAQuestions, timeStamp: dateList[item])
                    }, label: {
                        HStack {
                            if item < listSize {
                                if let foodImage = vm.getImageFromFileManager(timeStamp: dateList[item], PrePostFlag: false) {
                                    Image(uiImage: foodImage)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 60)
                                }
                                else {
                                    Image(systemName: "fork.knife.circle.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 60)
                                }
                            }
                            VStack (alignment: .leading, spacing: 5) {
                                if item < listSize {
                                    let time = dateList[item]
                                    Text(time)
                                        .fontWeight(.semibold)
                                        .lineLimit(2)
                                        .minimumScaleFactor(0.5)
                                }

                            }
                        }
                    })
                }
                Button(action: {
                    /* Navigate to recording view*/
                    navigateToEditView.toggle()
                }, label: {
                    StandardButton(title: "Add New Record")
                })
                .navigationDestination(isPresented: $navigateToEditView, destination: {
                    EditView()
                })
            }
        }
        .navigationTitle("Click for survey")
    }
    
}

//struct HistoryView_Previews: PreviewProvider {
//    static var previews: some View {
//        HistoryView()
//    }
//}

struct StandardButton: View {
    
    var title: String
    
    var body: some View {
        Text(title)
            .bold()
            .font(.title2)
            .frame(width: 280, height: 50)
            .background(Color(.systemRed))
            .foregroundColor(.white)
            .cornerRadius(10)
    }
}
