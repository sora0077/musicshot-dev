//
//  AppleMusicKit.swift
//  MusicshotRepository
//
//  Created by 林達也 on 2018/06/16.
//  Copyright © 2018年 林達也. All rights reserved.
//

import Foundation
import AppleMusicKit

typealias GetStorefront = AppleMusicKit.GetStorefront<StorefrontImpl.Storage>
typealias GetAllStorefronts = AppleMusicKit.GetAllStorefronts<StorefrontImpl.Storage>
typealias GetMultipleStorefronts = AppleMusicKit.GetMultipleStorefronts<StorefrontImpl.Storage>
typealias GetUserStorefront = AppleMusicKit.GetUserStorefront<StorefrontImpl.Storage>

// MARK: -
typealias GetSong = AppleMusicKit.GetSong<SongImpl.Storage, AlbumImpl.Storage, ArtistImpl.Storage, GenreImpl.Storage, StorefrontImpl.Storage>
typealias GetMultipleSongs = AppleMusicKit.GetMultipleSongs<SongImpl.Storage, AlbumImpl.Storage, ArtistImpl.Storage, GenreImpl.Storage, StorefrontImpl.Storage>

typealias GetMusicVideo = AppleMusicKit.GetMusicVideo<MusicVideoImpl.Storage, AlbumImpl.Storage, ArtistImpl.Storage, GenreImpl.Storage, StorefrontImpl.Storage>
typealias GetMultipleMusicVideos = AppleMusicKit.GetMultipleMusicVideos<MusicVideoImpl.Storage, AlbumImpl.Storage, ArtistImpl.Storage, GenreImpl.Storage, StorefrontImpl.Storage>

typealias GetAlbum = AppleMusicKit.GetAlbum<AlbumImpl.Storage, SongImpl.Storage, MusicVideoImpl.Storage, ArtistImpl.Storage, StorefrontImpl.Storage>
typealias GetMultipleAlbums = AppleMusicKit.GetMultipleAlbums<AlbumImpl.Storage, SongImpl.Storage, MusicVideoImpl.Storage, ArtistImpl.Storage, StorefrontImpl.Storage>

typealias GetArtist = AppleMusicKit.GetArtist<ArtistImpl.Storage, AlbumImpl.Storage, GenreImpl.Storage, StorefrontImpl.Storage>
typealias GetMultipleArtists = AppleMusicKit.GetMultipleArtists<ArtistImpl.Storage, AlbumImpl.Storage, GenreImpl.Storage, StorefrontImpl.Storage>

typealias GetGenre = AppleMusicKit.GetGenre<GenreImpl.Storage, StorefrontImpl.Storage>
typealias GetMultipleGenres = AppleMusicKit.GetMultipleGenres<GenreImpl.Storage, StorefrontImpl.Storage>

typealias GetCharts = AppleMusicKit.GetCharts<SongImpl.Storage, MusicVideoImpl.Storage, AlbumImpl.Storage, GenreImpl.Storage, StorefrontImpl.Storage>

typealias SearchResources = AppleMusicKit.SearchResources<SongImpl.Storage, MusicVideoImpl.Storage, AlbumImpl.Storage, ArtistImpl.Storage, StorefrontImpl.Storage>
typealias GetSearchHints = AppleMusicKit.GetSearchHints<StorefrontImpl.Storage>

typealias GetTopChartGenres = AppleMusicKit.GetTopChartGenres<GenreImpl.Storage, StorefrontImpl.Storage>

//typealias GetPlaylist = AppleMusicKit.GetPlaylist<Entity.Playlist, Entity.Curator, SongImpl.Storage, MusicVideoImpl.Storage, StorefrontImpl.Storage>
//typealias GetStation = AppleMusicKit.GetStation<Entity.Station, StorefrontImpl.Storage>
//typealias GetCurator = AppleMusicKit.GetCurator<Entity.Curator, Entity.Playlist, StorefrontImpl.Storage>
//typealias GetMultipleCurators = AppleMusicKit.GetMultipleCurators<Entity.Curator, Entity.Playlist, StorefrontImpl.Storage>
//typealias GetAppleCurator = AppleMusicKit.GetAppleCurator<Entity.AppleCurator, Entity.Playlist, StorefrontImpl.Storage>
//typealias GetMultipleAppleCurators = AppleMusicKit.GetMultipleAppleCurators<Entity.AppleCurator, Entity.Playlist, StorefrontImpl.Storage>
//typealias GetActivity = AppleMusicKit.GetActivity<Entity.Activity, Entity.Playlist, StorefrontImpl.Storage>
//typealias GetMultipleActivities = AppleMusicKit.GetMultipleActivities<Entity.Activity, Entity.Playlist, StorefrontImpl.Storage>
//typealias GetMultipleStations = AppleMusicKit.GetMultipleStations<Entity.Station, StorefrontImpl.Storage>
