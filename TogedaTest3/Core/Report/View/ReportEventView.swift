//
//  ReportEventView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 19.06.24.
//

import SwiftUI

struct ReportEventView: View {
    var event: Components.Schemas.PostResponseDto
    @State var showPhotoView = false
    @State var showAbusiveTextView = false
    @State var abusiveTexDescription: String = ""
    @State var showAdvertizingView = false
    @State var advertizingDescription: String = ""
    @State var showScamView = false
    @State var other = false
    @State var otherDescription: String = ""
    
    @Environment(\.dismiss) var dismiss
    var body: some View {
        NavigationStack{
            VStack{
                ZStack{
                    Text("Report")
                        .bold()
                        .padding()
                    HStack{
                        Spacer()
                        Button{
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                        }
                        
                    }
                }
                .padding(.horizontal)
                .frame(maxWidth: .infinity)
                
                Divider()
                
                Text("Your report is anonymus. Also if someone is in immediate danger, call the local emergency services - don't wait.")
                    .font(.footnote)
                    .foregroundStyle(.gray)
                    .padding()
                
                ScrollView{
                    LazyVStack(alignment:.leading){
                        Divider()
                        
                        Button{
                            showPhotoView = true
                        } label: {
                            HStack(){
                                Text("Inappropriate photos")
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                            }
                            .padding()
                        }

                        Button{
                            showAbusiveTextView = true
                        } label: {
                            HStack(){
                                Text("Abusive text")
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                            }
                            .padding()
                        }
                        
                        Button{
                            showAdvertizingView = true
                        } label: {
                            HStack(){
                                Text("Advertizing")
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                            }
                            .padding()
                        }
                        
                        Button{
                            showScamView = true
                        } label: {
                            HStack(){
                                Text("Scam")
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                            }
                            .padding()
                        }
                        
                        Button{
                            other = true
                        } label: {
                            HStack(){
                                Text("Other")
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                            }
                            .padding()
                        }
                    }
                }
                .scrollIndicators(.hidden)
            }
            .navigationBarBackButtonHidden(true)
            .navigationDestination(isPresented: $showPhotoView) {
                InappropriatePhotoReport()
            }
            .navigationDestination(isPresented: $showAdvertizingView) {
                GeneralSubmitReportView(title: "Report Case: Advertizing", description: $advertizingDescription, onSubmit: {
                    
                })
            }
            .navigationDestination(isPresented: $showAbusiveTextView) {
                GeneralSubmitReportView(title: "Report Case: AbusiveText", description: $abusiveTexDescription, onSubmit: {
                    
                })
            }
            .navigationDestination(isPresented: $other) {
                GeneralSubmitReportView(title: "Report Case: Other", description: $otherDescription, onSubmit: {
                    
                })
            }
            .navigationDestination(isPresented: $showScamView) {
                EventScamReportView()
            }
        }
    }
}

#Preview {
    ReportEventView(event: MockPost)
}
