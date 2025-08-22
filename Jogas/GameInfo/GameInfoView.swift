//
//  GameInfoView.swift
//  Jogas
//
//  Created by Rafael Hartmann on 13/08/25.
//

import SwiftUI

struct GameInfoView: View {
    @Namespace var namespace
    @ObservedObject var viewModel: GameInfoViewModel
    @EnvironmentObject
    var appCoordinator: AppCoordinator
    
    init(viewModel: GameInfoViewModel) {
        self.viewModel = viewModel
    }
    
    // MARK: - Computed Properties
    
    private var loadingView: some View {
        VStack {
            Image(systemName: "sparkles")
                .padding(.top, 40)
            
            Text("Generating Description...")
                .padding(.bottom, 40)
        }
    }
    
    private var retryView: some View {
        VStack {
            Image(systemName: "sparkles")
                .padding(.top, 40)
            
            Text("Tap to try again...")
                .padding(.bottom, 40)
        }
    }
    
    private var aiPrecisionDisclaimer: some View {
        HStack(alignment: .center) {
            Spacer()
            Text("AI-generated content - precision may vary")
                .font(.caption2)
            
            Image(systemName: "exclamationmark.triangle.fill")
                .resizable()
                .frame(width: 12, height: 12)
            
            Spacer()
        }
        .foregroundStyle(.secondary)
        .padding(.horizontal)
        .padding(.top, 8)
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            switch viewModel.gameDetailStatus {
            case .success:
                if let game = viewModel.gameInfo {
                    gameContentView(for: game)
                        .sheet(isPresented: $viewModel.isPresenting, content: {
                            RatingView(
                                firstSliderValue: $viewModel.firstSliderValue,
                                lastSliderValue: $viewModel.lastSliderValue,
                                firstDragValue: $viewModel.firstDragValue,
                                lastDragValue: $viewModel.lastDragValue,
                                isPresenting: $viewModel.isPresenting,
                                action: {
                                    Task {
                                        await viewModel.postRating()
                                    }
                                }
                            )
                            .presentationDetents([.height(340)])
                            .presentationDragIndicator(.visible)
                            .presentationCornerRadius(24)
                        })
                }
            case .failure:
                failureView
            case .idle, .loading:
                loadingGameView
            }
        }
        .ignoresSafeArea(.container, edges: .top)
        .defaultScrollAnchor(viewModel.gameDetailStatus == .success ? .top : .center, for: .alignment)
        .navigationDestination(for: GameInfoDestination.self) { value in
            switch value {
            case .GameRating:
                EmptyView()
            case .GameSpoiler(let text):
                GameSpoilerView(viewModel: .init(spoilerText: text, gameId: viewModel.gameId))
            }
        }
        .task {
            if viewModel.gameDetailStatus == .idle {
                await viewModel.getGameDetail(gameId: viewModel.gameId)
            }
        }
    }
    
    // MARK: - View Components
    
    @ViewBuilder
    private func gameContentView(for game: SteamGame) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            // Game Image and Title
            gameHeaderView(game: game)
            
            // Description Section
            descriptionSection(game: game)
            
            // Personal Rating Section
            personalRatingSection(game: game)
            
            // Public Rating Section
            publicRatingSection(game: game)
            
            // Play Time Section
            playTimeSection(game: game)
            
            // Story Summary Section
            storySummarySection()
            
        }
        
    }
    
    private func gameHeaderView(game: SteamGame) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            GameView(game: .init(appid: game.appid, name: game.name), cornerRadius: 0)
                .background(MainBackground())
            
            Text(game.name)
                .font(.largeTitle)
                .fontWeight(.black)
                .padding(.horizontal)
                .padding(.top, 32)
        }
    }
    
    private func descriptionSection(game: SteamGame) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Description")
                .sectionTitle()
            AIDisclaimer()
            
            Group {
                if let description = game.description {
                    Text(AttributedString(description))
                        .padding()
                } else {
                    descriptionLoadingView
                }
            }
            .background(RoundedRectangle(cornerRadius: 8).fill(.ultraThinMaterial))
            .appleIntelligenceEffect(isActive: $viewModel.descLoading)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .padding(.horizontal)
        }
    }
    
    @ViewBuilder
    private var descriptionLoadingView: some View {
        HStack {
            Spacer()
            switch viewModel.descStatus {
            case .idle, .loading:
                loadingView
                    .task {
                        await viewModel.getGameDescription(gameId: viewModel.gameId)
                    }
            case .failure:
                retryView
                    .onTapGesture {
                        Task {
                            await viewModel.getGameDescription(gameId: viewModel.gameId)
                        }
                    }
            case .success:
                EmptyView()
            }
            Spacer()
        }
    }
    
    private func personalRatingSection(game: SteamGame) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Personal Rating")
                .sectionTitle()
            
            if let rating = game.userRating {
                ratingDisplayView(rating: rating, isPersonal: true)
                    .padding(.top)
            }
            
            rateGameButton(hasExistingRating: game.userRating != nil)
        }
    }
    
    private func publicRatingSection(game: SteamGame) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Public Rating")
                .sectionTitle()
            AIDisclaimer()
            
            if let rating = game.averageRating {
                VStack(spacing: 0) {
                    ratingDisplayView(rating: rating, isPersonal: false)
                    aiPrecisionDisclaimer
                }
            } else {
                publicRatingLoadingView
            }
        }
    }
    
    private func ratingDisplayView(rating: Decimal, isPersonal: Bool) -> some View {
        HStack(alignment: .center) {
            Spacer()
            Text(rating.formatted(.number.precision(.fractionLength(1)).locale(Locale(identifier: "en_US"))))
                .font(.system(size: 64))
                .fontWeight(.heavy)
                .padding()
            Spacer()
        }
        .background(RoundedRectangle(cornerRadius: 8).fill(.ultraThinMaterial))
        .appleIntelligenceEffect(isActive: isPersonal ? .constant(false) : $viewModel.ratingLoading)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .padding(.horizontal)
    }
    
    private func rateGameButton(hasExistingRating: Bool) -> some View {
        Button {
            viewModel.isPresenting = true
        } label: {
            HStack(alignment: .center) {
                Spacer()
                Text(hasExistingRating ? "Rate Again" : "Rate Game")
                Image(systemName: "star.fill")
                Spacer()
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 8).fill(.ultraThinMaterial))
        }
        .padding(.top)
        .padding(.horizontal)
    }
    
    @ViewBuilder
    private var publicRatingLoadingView: some View {
        Group {
            HStack {
                Spacer()
                VStack {
                    Image(systemName: "sparkles")
                        .padding(.top, 40)
                    
                    Text("Generating Rating...")
                        .padding(.bottom, 40)
                }
                Spacer()
            }
            .task {
                await viewModel.getGameAverageRating(gameId: viewModel.gameId)
            }
        }
        .background(RoundedRectangle(cornerRadius: 8).fill(.ultraThinMaterial))
        .appleIntelligenceEffect(isActive: $viewModel.ratingLoading)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .padding(.horizontal)
    }
    
    private func playTimeSection(game: SteamGame) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Play Time")
                .sectionTitle()
            
            // Platform-specific play times
            VStack(spacing: 0) {
                playTimePlatformView(title: "Total:", time: game.playtime_forever, systemImage: "globe.americas.fill")
                lineView()
                
                playTimePlatformView(title: "Steam Deck:", time: game.playtime_deck_forever, systemImage: "steamdeck", isSystemName: false)
                lineView()
                
                playTimePlatformView(title: "Linux:", time: game.playtime_linux_forever, systemImage: "linux", isSystemName: false)
                lineView()
                
                playTimePlatformView(title: "Windows:", time: game.playtime_windows_forever, systemImage: "windows", isSystemName: false)
                lineView()
                playTimePlatformView(title: "macOS:", time: game.playtime_mac_forever, systemImage: "apple.logo")
            }
            .background(RoundedRectangle(cornerRadius: 12).fill(.ultraThinMaterial))
            .padding(.horizontal)
            .padding(.top)
        }
    }
    
    private func playTimePlatformView(title: String, time: Int, systemImage: String? = nil, isSystemName: Bool = true) -> some View {
        HStack(alignment: .center) {
            
            if let systemImage = systemImage, isSystemName {
                Image(systemName: systemImage)
                    .resizable()
                    .foregroundStyle(.imageBackground)
                    .scaledToFit()
                    .frame(height: 24)
            } else if let imageName = systemImage, !isSystemName {
                Image(imageName)
                    .resizable()
                    .foregroundStyle(.imageBackground)
                    .scaledToFit()
                    .frame(height: 24)
            }
            
            Text(title)
                .font(.body)
            
            Text(viewModel.calculatePlaytime(time))
                .font(.body)
                .bold()
            
            Spacer()
        }
        .padding()
    }
    
    private func lineView() -> some View {
        Rectangle()
            .frame(height: 0.75)
            .foregroundColor(.gray.opacity(0.3))
    }
    
    private func storySummarySection() -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Story Summary")
                .sectionTitle()
            AIDisclaimer()
            
            VStack {
                Button {
                    appCoordinator.path.append(GameInfoDestination.GameSpoiler(text: viewModel.gameInfo?.storyResume))
                } label: {
                    
                    HStack(alignment: .center) {
                        Spacer()
                        Text("Generate")
                        Image(systemName: "sparkles")
                        Spacer()
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 8).fill(.ultraThinMaterial))
                }
                .padding(.horizontal)
                
                HStack(alignment: .center) {
                    Text("This section may contain story spoilers")
                        .font(.caption2)
                    
                    Image(systemName: "exclamationmark.triangle.fill")
                        .resizable()
                        .frame(width: 12, height: 12)
                }
                .foregroundStyle(.secondary)
                .padding(.horizontal)
            }
        }
    }
    
    
    // Failure
    
    private var failureView: some View {
        VStack(alignment: .center) {
            Spacer()
            Image(systemName: "arrow.trianglehead.2.clockwise.rotate.90")
                .resizable()
                .scaledToFit()
                .frame(width: 64)
                .padding()
            
            Text("Failed to load game information. Tap to reload.")
            Spacer()
        }
        .foregroundStyle(.secondary)
        .onTapGesture {
            Task {
                await viewModel.getGameDetail(gameId: viewModel.gameId)
            }
        }
    }
    
    // Loading
    
    private var loadingGameView: some View {
        VStack {
            Spacer()
            ProgressView("Loading game information...")
            Spacer()
        }
    }
}

// MARK: - View Extensions
extension View {
    func sectionTitle() -> some View {
        self
            .font(.headline)
            .padding(.horizontal)
            .padding(.top, 24)
    }
}

// MARK: - Previews
#Preview {
    GameInfoView(viewModel: GameInfoViewModel(gameId: "200260"))
}
