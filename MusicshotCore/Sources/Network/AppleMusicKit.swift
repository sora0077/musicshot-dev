//
//  AppleMusicKit.swift
//  MusicshotCore
//
//  Created by 林達也 on 2018/03/04.
//  Copyright © 2018年 林達也. All rights reserved.
//

import Foundation
import AppleMusicKit

typealias GetStorefront = AppleMusicKit.GetStorefront<Entity.Storefront>
typealias GetAllStorefronts = AppleMusicKit.GetAllStorefronts<Entity.Storefront>
typealias GetMultipleStorefronts = AppleMusicKit.GetMultipleStorefronts<Entity.Storefront>
typealias GetUserStorefront = AppleMusicKit.GetUserStorefront<Entity.Storefront>

// MARK: -
typealias GetSong = AppleMusicKit.GetSong<Entity.Song, Entity.Album, Entity.Artist, Entity.Genre, Entity.Storefront>
typealias GetMultipleSongs = AppleMusicKit.GetMultipleSongs<Entity.Song, Entity.Album, Entity.Artist, Entity.Genre, Entity.Storefront>

typealias GetMusicVideo = AppleMusicKit.GetMusicVideo<Entity.MusicVideo, Entity.Album, Entity.Artist, Entity.Genre, Entity.Storefront>

typealias GetAlbum = AppleMusicKit.GetAlbum<Entity.Album, Entity.Song, Entity.MusicVideo, Entity.Artist, Entity.Storefront>

typealias GetArtist = AppleMusicKit.GetArtist<Entity.Artist, Entity.Album, Entity.Genre, Entity.Storefront>
typealias GetMultipleArtists = AppleMusicKit.GetMultipleArtists<Entity.Artist, Entity.Album, Entity.Genre, Entity.Storefront>

typealias GetGenre = AppleMusicKit.GetGenre<Entity.Genre, Entity.Storefront>
typealias GetMultipleGenres = AppleMusicKit.GetMultipleGenres<Entity.Genre, Entity.Storefront>

typealias GetCharts = AppleMusicKit.GetCharts<Entity.Song, Entity.MusicVideo, Entity.Album, Entity.Genre, Entity.Storefront>

typealias SearchResources = AppleMusicKit.SearchResources<Entity.Song, Entity.MusicVideo, Entity.Album, Entity.Artist, Entity.Storefront>
typealias GetSearchHints = AppleMusicKit.GetSearchHints<Entity.Storefront>

typealias GetTopChartGenres = AppleMusicKit.GetTopChartGenres<Entity.Genre, Entity.Storefront>

//typealias GetPlaylist = AppleMusicKit.GetPlaylist<Entity.Playlist, Entity.Curator, Entity.Song, Entity.MusicVideo, Entity.Storefront>
//typealias GetStation = AppleMusicKit.GetStation<Entity.Station, Entity.Storefront>
//typealias GetCurator = AppleMusicKit.GetCurator<Entity.Curator, Entity.Playlist, Entity.Storefront>
//typealias GetMultipleCurators = AppleMusicKit.GetMultipleCurators<Entity.Curator, Entity.Playlist, Entity.Storefront>
//typealias GetAppleCurator = AppleMusicKit.GetAppleCurator<Entity.AppleCurator, Entity.Playlist, Entity.Storefront>
//typealias GetMultipleAppleCurators = AppleMusicKit.GetMultipleAppleCurators<Entity.AppleCurator, Entity.Playlist, Entity.Storefront>
//typealias GetActivity = AppleMusicKit.GetActivity<Entity.Activity, Entity.Playlist, Entity.Storefront>
//typealias GetMultipleActivities = AppleMusicKit.GetMultipleActivities<Entity.Activity, Entity.Playlist, Entity.Storefront>
//typealias GetMultipleStations = AppleMusicKit.GetMultipleStations<Entity.Station, Entity.Storefront>
