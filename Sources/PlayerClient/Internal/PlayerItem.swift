//
//  File.swift
//  
//
//  Created by ErrorErrorError on 6/18/23.
//  
//

import AVFoundation
import AVKit
import Foundation

final class PlayerItem: AVPlayerItem {
    static let dashCustomPlaylistScheme = "mochi-mpd"

    internal let payload: PlayerClient.VideoCompositionItem

    private let resourceQueue: DispatchQueue

    enum ResourceLoaderError: Swift.Error {
        case responseError
        case emptyData
        case failedToCreateM3U8
    }

    init(_ payload: PlayerClient.VideoCompositionItem) {
        self.payload = payload
        self.resourceQueue = DispatchQueue(label: "playeritem-\(payload.link.absoluteString)", qos: .utility)

        let headers = payload.headers
        let url: URL

//        if payload.format == .mpd {
//            url = payload.source.url.change(scheme: Self.dashCustomPlaylistScheme)
//            //        } else if payload.subtitles.count > 0 {
//            //            url = payload.source.url.change(scheme: Self.hlsCustomPlaylistScheme)
//        } else {
//        }

        if payload.subtitles.isEmpty {
            url = payload.link
        } else {
            url = payload.link.change(scheme: Self.hlsCommonScheme)
        }

        let asset = AVURLAsset(
            url: url,
            options: ["AVURLAssetHTTPHeaderFieldsKey": headers]
        )

        super.init(asset: asset, automaticallyLoadedAssetKeys: ["duration"])
        asset.resourceLoader.setDelegate(self, queue: resourceQueue)
    }
}

// MARK: AVAssetResourceLoaderDelegate

extension PlayerItem: AVAssetResourceLoaderDelegate {
    func resourceLoader(
        _: AVAssetResourceLoader,
        shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest
    ) -> Bool {
//        if payload.source.format == .mpd {
//            if url.pathExtension == "ts" {
//                loadingRequest.redirect = URLRequest(url: url.recoveryScheme)
//                loadingRequest.response = HTTPURLResponse(
//                    url: url.recoveryScheme,
//                    statusCode: 302,
//                    httpVersion: nil,
//                    headerFields: nil
//                )
//                loadingRequest.finishLoading()
//            } else {
//                handleDASHRequest(url, callback)
//            }
//        } else {
        return handleHLSRequest(loadingRequest: loadingRequest)
//        }
    }
}

extension URL {
    func change(scheme: String) -> URL {
        var component = URLComponents(url: self, resolvingAgainstBaseURL: false)
        component?.scheme = scheme
        return component?.url ?? self
    }

    var recoveryScheme: URL {
        var component = URLComponents(url: self, resolvingAgainstBaseURL: false)
        component?.scheme = "https"
        return component?.url ?? self
    }
}
