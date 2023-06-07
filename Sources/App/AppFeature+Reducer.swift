//
//  AppFeature+Reducer.swift
//  
//
//  Created by ErrorErrorError on 4/6/23.
//  
//

import Architecture
import ComposableArchitecture
import DatabaseClient
import Discover
import ModuleLists
import Repos
import Search
import Settings
import VideoPlayerClient

extension AppFeature.Reducer {
    @ReducerBuilder<State, Action>
    public var body: some ReducerOf<Self> {
        Scope(state: \.settings.userSettings, action: /Action.InternalAction.appDelegate) {
            AppDelegateFeature.Reducer()
        }

        Reduce { state, action in
            switch action {
            case .view(.didAppear):
                break

            case let .view(.didSelectTab(tab)):
                state.selected = tab

            case .internal(.appDelegate):
                break

            case let .internal(.discover(.delegate(.playbackVideoItem(_, repoModuleID, playlist, groupId, itemId)))):
                state.videoPlayer = .init(
                    repoModuleID: repoModuleID,
                    playlist: playlist,
                    contents: .init(),
                    groupId: groupId,
                    episodeId: itemId
                )

            case let .internal(.repos(.delegate(delegate))):
                switch delegate {}

            case let .internal(.search(.delegate(.playbackVideoItem(_, repoModuleID, playlist, groupId, itemId)))):
                state.videoPlayer = .init(
                    repoModuleID: repoModuleID,
                    playlist: playlist,
                    contents: .init(),
                    groupId: groupId,
                    episodeId: itemId
                )

            case let .internal(.settings(.delegate(delegate))):
                switch delegate {}

            case .internal(.discover):
                break

            case .internal(.repos):
                break

            case .internal(.search):
                break

            case .internal(.settings):
                break

            case .internal(.videoPlayer):
                break
            }
            return .none
        }
        .ifLet(\.$videoPlayer, action: /Action.internal .. Action.InternalAction.videoPlayer) {
            VideoPlayerFeature.Reducer()
        }

        Scope(state: \.discover, action: /Action.InternalAction.discover) {
            DiscoverFeature.Reducer()
        }

        Scope(state: \.repos, action: /Action.InternalAction.repos) {
            ReposFeature.Reducer()
        }

        Scope(state: \.search, action: /Action.InternalAction.search) {
            SearchFeature.Reducer()
        }

        Scope(state: \.settings, action: /Action.InternalAction.settings) {
            SettingsFeature.Reducer()
        }
    }
}
