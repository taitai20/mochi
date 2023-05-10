//
//  AppFeature+Reducer.swift
//  
//
//  Created by ErrorErrorError on 4/6/23.
//  
//

import Architecture
import ComposableArchitecture
import Discover
import ModuleLists
import Repos
import Search
import Settings

extension AppFeature.Reducer {
    @ReducerBuilder<State, Action>
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .view(.didAppear):
                break

            case let .view(.didSelectTab(tab)):
                state.selected = tab

            case let .internal(.discover(.delegate(delegate))):
                switch delegate {
                case .openModules:
                    state.destination = .sheet(.moduleLists(.init()))
                }

            case let .internal(.repos(.delegate(delegate))):
                switch delegate {}

            case let .internal(.search(.delegate(delegate))):
                switch delegate {
                case .tappedOpenModules:
                    state.destination = .sheet(.moduleLists(.init()))
                }

            case let .internal(.settings(.delegate(delegate))):
                switch delegate {}

            case let .internal(.destination(.presented(.sheet(.moduleLists(.delegate(delegate)))))):
                switch delegate {
                case .didSelectModule:
                    state.destination = nil
                }

            case .internal(.destination(.dismiss)):
                state.destination = nil

            case .internal(.discover):
                break

            case .internal(.repos):
                break

            case .internal(.search):
                break

            case .internal(.settings):
                break

            case .internal(.destination):
                break

            case .delegate:
                break
            }
            return .none
        }
        .ifLet(\.$destination, action: /Action.InternalAction.destination) {
            AppFeature.Destination()
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
