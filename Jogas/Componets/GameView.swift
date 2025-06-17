//
//  SwiftUIView.swift
//  Jogas
//
//  Created by Rafael Hartmann on 16/06/25.
//

import SwiftUI

struct GameView: View {
    
    let game: SteamGamePersistent
    @State var id = UUID()
    @State var loading = true
    @State var urlFinal = "hero_capsule"
    
    var body: some View {
        ZStack(alignment: .bottom) {
            if game.imgDownloaded {
                Image(uiImage: UIImage(data: game.downloadedImg!)!)
                    .resizable()
                    .scaledToFill()
                
            } else {
                /*
                 
                 2


                 there is 4 kind of image to use with steam app id.
                 https://steamcdn-a.akamaihd.net/steam/apps/462780/header.jpg
                 https://cdn.cloudflare.steamstatic.com/steam/apps/462780/hero_capsule.jpg
                 https://cdn.cloudflare.steamstatic.com/steam/apps/462780/capsule_616x353.jpg
                 https://cdn.cloudflare.steamstatic.com/steam/apps/462780/header.jpg
                 https://cdn.cloudflare.steamstatic.com/steam/apps/462780/capsule_231x87.jpg
                 */
                AsyncImage(url: URL(string: "https://steamcdn-a.akamaihd.net/steam/apps/\(game.appid)/\(urlFinal).jpg")) { imagePhase in
                    switch imagePhase {
                        
                    case .success(let returnedImage):
                        returnedImage
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    case .failure:
                        Image(.defaultGame)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .overlay(content: {
                                VStack(spacing: 24) {
                                    Button {
                                        id = UUID()
                                        loading = true
                                    } label: {
                                        Text("RELOAD")
                                    }
                                    
                                    Button {
                                        loading = true
                                        urlFinal = "capsule_616x353"
                                    } label: {
                                        Text("BAIXAR HEADER")
                                    }
                                }

                            })
                    case .empty:
                        Image(.defaultGame)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .overlay(content: {
                                ProgressView()
                            })
                            .onDisappear {
                                loading = false
                            }
                    @unknown default:
                        Image(.defaultGame)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    }
                }
                .id(id)
            }
            
            VStack {
                HStack(alignment: .center) {
                    Text(game.name)
                        .font(.headline)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                        .padding(.vertical)
                    Spacer()
                }
                .background(BlurView(style: .systemUltraThinMaterial))
            }
        }
        .cornerRadius(8)
    }
}

#Preview {
    GameView(game: .init(appid: 462780, name: "Dragon Ball Sparking Zero", imgUrl: nil, playtime: 0, playtimeWindows: 0, playtimeMac: 0, playtimeLinux: 0, playtimeDeck: 0, rtimeLastPlayed: 0, imgDownloaded: false))
}
