//
//  ContentView.swift
//  AppleWalletUI
//
//  Created by ugur cakmak on 1.12.2020.
//  Copyright © 2020 ugur cakmak. All rights reserved.
//

import SwiftUI
import AVKit

struct ContentView : View {
    
    @State var isOpenedDetailScreen = false
    @State var videoCardClicked = CardModel(color: .black)

    var body: some View {
        ZStack{
            if isOpenedDetailScreen {
                CardDetail(isCardDetailClosed: $isOpenedDetailScreen, videoCardClicked: $videoCardClicked)
                    .transition(.move(edge: .bottom))
            }else{
                ScrollView{
                    VStack {
                        ForEach(videoList){ card in
                            ZStack {
                                ForEach(0..<card.videos.count, id: \.self) { index in
                                    GeometryReader{ geo in
                                        VideoCardView(videoModel: card.videos[index], color: card.color).onTapGesture {
                                            videoCardClicked = card
                                            withAnimation {
                                                isOpenedDetailScreen.toggle()
                                            }
                                        }
                                    }
                                    .offset(x: CGFloat(0), y: CGFloat(index*15))
                                    .frame(height: 90)
                                }
                            }
                            
                        }
                    }
                    
                }
                .cornerRadius(10)
                .frame(height: UIScreen.main.bounds.height - 100)
                .transition(.move(edge: .bottom))
            }
        }
    }
}

struct CardDetail: View {
    
    @Binding var isCardDetailClosed: Bool
    @Binding var videoCardClicked: CardModel
    
    let cardWidth = UIScreen.main.bounds.width * 0.9
    let cardHeight = UIScreen.main.bounds.height * 0.6
    let screenHeight = UIScreen.main.bounds.height
    let screenWidth = UIScreen.main.bounds.width
    
    @State var opacity: Double = 0
    @State var currentIndex: Int = 0
    
    @GestureState private var translation: CGFloat = 0
    
    var body: some View {
        GeometryReader{ geometry in
            HStack {
                ForEach(videoCardClicked.videos){ video in
                    VStack {
                        VideoPlayer(player: getAVPlayer(video.fileName))
                            .frame(width: cardWidth, height: cardHeight)
                            .cornerRadius(20)
                        Text(video.videoTitle)
                            .frame(width: cardWidth, height: 60, alignment: .center)
                            .foregroundColor(Color.init(.black))
                    }

                    
                }
            }
            .frame(width: geometry.size.width, alignment: .leading)
            .offset(x: -CGFloat(currentIndex) * (geometry.size.width * 0.9) + 10,
                    y : (geometry.size.height - (geometry.size.height * 0.6))/3)
            .offset(x: self.translation)
            .animation(.interactiveSpring())
            .gesture(
                DragGesture().updating(self.$translation) { value, state, _ in
                    state = value.translation.width
                }.onEnded { value in
                    let offset = value.translation.width / geometry.size.width
                    let newIndex = (CGFloat(self.currentIndex) - offset).rounded()
                    self.currentIndex = min(max(Int(newIndex), 0), videoCardClicked.videos.count - 1)
                }
            )
            
            
            Button(action: {
                withAnimation {
                    isCardDetailClosed.toggle()
                }
            }){
                Text("Done").font(.title).fontWeight(.bold).foregroundColor(.black)
            }.offset(x: 20, y: 60)
            .opacity(opacity)
            .onAppear {
                let animation = Animation.easeIn(duration: 0.4).delay(0.4)
                
                return withAnimation(animation) {
                    self.opacity = 1
                }
            }
        }
        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
    }
    
    func getAVPlayer(_ fileName: String) -> AVPlayer {
        let avPlayer = AVPlayer(url:  Bundle.main.url(forResource: fileName, withExtension: "mp4")!)
        avPlayer.seek(to: CMTime(seconds: 5, preferredTimescale: CMTimeScale(1)))
        
        return avPlayer
    }
}

struct VideoCardView: View {
    var videoModel: VideoModel
    var color: Color
    
    var body: some View {
        RoundedRectangle(cornerRadius: 10)
            .shadow(color: .black, radius: 3, x: 0, y: 0)
            .frame(width: UIScreen.main.bounds.width, height: 300)
            .foregroundColor(color).zIndex(0)
        HStack{
            Spacer()
            Text(videoModel.videoTitle)
                .foregroundColor(.black)
                .fontWeight(.bold)
                .offset(y: 10)
            Spacer()
        }
        
    }
}

struct CardModel: Identifiable, Hashable {
    var id = UUID()
    var color: Color
    var videos = [VideoModel]()
}

struct VideoModel: Identifiable, Hashable {
    var id = UUID()
    var fileName: String
    var videoTitle: String
}

var videoList = [
    CardModel(color: .green, videos: [VideoModel(fileName: "benjamin", videoTitle: "Rozz Kalliope & Ece Seçkin - Benjamins 3")]),
    CardModel(color: .red, videos: [
                    VideoModel(fileName: "Ceza_Suspus", videoTitle: "Ceza - Suspus"),
                    VideoModel(fileName: "Ceza_Beatcoin", videoTitle: "Ceza - Beatcoin")
               ]),
    CardModel(color: .yellow, videos: [VideoModel(fileName: "mannish", videoTitle: "Muddy Waters - Mannish Boy")]),
    CardModel(color: .blue, videos: [VideoModel(fileName: "great_balls", videoTitle: "Jerry Lee Lewis - Great Balls Of Fire")]),
    CardModel(color: .orange,
                 videos: [
                    VideoModel(fileName: "Boom", videoTitle: "John Lee Hooker - Boom Boom"),
                    VideoModel(fileName: "shake", videoTitle: "John Lee Hooker - Shake It Baby"),
                    VideoModel(fileName: "blues", videoTitle: "John Lee Hooker - Hobo blues")
                 ]),
    CardModel(color: .pink, videos: [VideoModel(fileName: "kibir", videoTitle: "Contra - Kibir")]),
    CardModel(color: .gray, videos: [VideoModel(fileName: "norm_ender", videoTitle: "Norm Ender - İhtiyacım Yok")]),
    CardModel(color: .purple, videos: [VideoModel(fileName: "gazapizm", videoTitle: "Gazapizm - Perişan ft. Gaye Su Akyol")]),
    CardModel(color: .green, videos: [VideoModel(fileName: "chuck_berry", videoTitle: "Chuck Berry - Johnny B. Goode live")]),
    CardModel(color: .red, videos: [VideoModel(fileName: "ayben", videoTitle: "Ayben - Yol Ver")])
]

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
