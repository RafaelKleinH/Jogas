//
//  SwiftUIView.swift
//  Jogas
//
//  Created by Rafael Hartmann on 16/06/25.
//

import SwiftUI

struct GameView: View {
    
    let game: SteamGamesResumed
    @State var id = UUID()
    @State var loading = true
    let cornerRadius: CGFloat
    
    init(game: SteamGamesResumed, id: UUID = UUID(), loading: Bool = true, cornerRadius: CGFloat = 8) {
        self.game = game
        self.id = id
        self.loading = loading
        self.cornerRadius = cornerRadius
    }
    
    var body: some View {
        Group {
            
            /*
             
             2
             // ASPECT RATIO 374;448
             
             there is 4 kind of image to use with steam app id.
             https://steamcdn-a.akamaihd.net/steam/apps/462780/header.jpg
             https://cdn.cloudflare.steamstatic.com/steam/apps/462780/hero_capsule.jpg
             https://cdn.cloudflare.steamstatic.com/steam/apps/462780/capsule_616x353.jpg
             https://cdn.cloudflare.steamstatic.com/steam/apps/462780/header.jpg
             https://cdn.cloudflare.steamstatic.com/steam/apps/462780/capsule_231x87.jpg
             */
            AsyncImage(url: URL(string: NetworkCore.baseURL + "/api/images/game/\(game.appid)")) { imagePhase in
                switch imagePhase {
                    
                case .success(let returnedImage):
                    returnedImage
                        .resizable()
                case .failure:
                    
                    Rectangle()
                        .fill(.ultraThickMaterial)
                        .mask(
                            Rectangle()
                                .overlay(
                                    VStack(alignment: .leading) {
                                        Spacer()
                                        Text(game.name)
                                            .font(.system(size: 32))
                                            .fontWeight(.bold)
                                            .multilineTextAlignment(.leading)
                                            .lineLimit(nil)
                                            .minimumScaleFactor(0.5)
                                            .blendMode(.destinationOut)
                                            .padding()
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        
                                    }
                                )
                        )
                    
                case .empty:
                    Rectangle()
                        .fill(.thickMaterial)
                        .overlay(
                    ProgressView()
                    
                        .onDisappear {
                            loading = false
                        }
                    )
                @unknown default:
                    Image(.defaultGame)
                        .resizable()
                }
            }
            .id(id)
            
            
        }
        .aspectRatio(374/448, contentMode: .fit)
        .cornerRadius(cornerRadius)
    }
}

