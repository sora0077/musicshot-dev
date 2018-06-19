#!/usr/bin/swift

import Foundation

struct ValueType {
    class RealmType {
        var type: ValueType
        var toValue: String
        var toRealm: String?
        var optional: Bool

        init(_ type: ValueType, toValue: String, toRealm: String? = nil, optional: Bool = false) {
            (self.type, self.toValue, self.toRealm, self.optional)
                = (type, toValue, toRealm, optional)
        }
    }
    var name: String
    var value: String
    var primitive: Bool
    var extraInfo: [String: String]
    var realmType: RealmType?

    init(name: String, value: String = "", primitive: Bool = false, extra info: [String: String] = [:], back: RealmType? = nil) {
        self.name = name
        self.value = value
        self.primitive = primitive
        extraInfo = info
        realmType = back
    }
}

extension ValueType {
    static let Bool     = ValueType(name: "Bool", value: "false", primitive: true)
    static let Int      = ValueType(name: "Int", value: "0", primitive: true)
    static let Int8     = ValueType(name: "Int8", value: "0", primitive: true)
    static let Int16    = ValueType(name: "Int16", value: "0", primitive: true)
    static let Int32    = ValueType(name: "Int32", value: "0", primitive: true)
    static let Int64    = ValueType(name: "Int64", value: "0", primitive: true)
    static let Double   = ValueType(name: "Double", value: "0", primitive: true)
    static let Float    = ValueType(name: "Float", value: "0", primitive: true)
    static let String   = ValueType(name: "String", value: "\"\"")
    static let Date     = ValueType(name: "Date", value: ".distantPast")
    static let Data     = ValueType(name: "Data", value: "Data()")

    static func Object(name: String) -> ValueType {
        return ValueType(name: "Object", extra: ["identifier": name],
                         back: RealmType(ValueType(name: name + "!"), toValue: "nop"))
    }

    static func Array(name: String) -> ValueType {
        return ValueType(name: "Array", extra: ["identifier": name],
                         back: RealmType(ValueType(name: name), toValue: "Array"))
    }
}

struct Prop {
    var name: String
    var type: ValueType
    var optional: Bool = false
    var readonly: Bool = true
    var primarykey: Bool?
    var `default`: Any?
    var description: String?

    init(name: String,
         type: ValueType,
         optional: Bool = false,
         readonly: Bool = true,
         primarykey: Bool? = nil,
         `default`: Any? = nil,
         description: String? = nil) {
        (self.name, self.type, self.optional, self.readonly, self.primarykey, self.default, self.description)
            = (name, type, optional, readonly, primarykey, `default`, description)
    }
}

struct Schema {
    var namespace: String?
    var name: String
    var protocols: [String]
    var code: String?
    var props: [Prop]

    init(namespace: String? = nil, name: String, protocols: [String] = [], code: String? = nil, props: [Prop]) {
        (self.namespace, self.name, self.protocols, self.code, self.props)
            = (namespace, name, protocols, code, props)
    }
}

func log(_ any: Any...) {
    print(any)
}

func writeSchemaForDomain(_ schema: Schema) -> String {
    var output = ""

    func print(_ value: String, terminator: String = "\n") {
        Swift.print(value, terminator: terminator, to: &output)
    }
    func indent(_ level: Int = 0) -> String {
        return String(repeating: "    ", count: level)
    }
    var protocols = schema.protocols.filter { $0 != "Identifiable" }
    let isEntity = schema.protocols.contains("Identifiable")
    if isEntity {
        protocols.insert("Entity", at: 0)
    }
    let protocolString = protocols.isEmpty ? "" : ": \(protocols.joined(separator: ", "))"
    print("\(indent())open class \(schema.name)\(protocolString) {")
    if let codes = schema.code?.components(separatedBy: "\n") {
        for code in codes {
            print("\(indent())    \(code)")
        }
        print("")
    }

    if isEntity, let pk = schema.props.first(where: { $0.primarykey == true }) {
        let actual = pk.type.realmType?.type ?? pk.type
        print("\(indent())    public typealias Identifier = Tagged<\(schema.name), \(actual.name)>")
        print("")
        print("\(indent())    public init(id: Identifier) {")
        print("\(indent())        self.id = id")
        print("\(indent())    }")
        print("")
    } else {
        print("\(indent())    public init() {}")
        print("")
    }
    for prop in schema.props {
        let realmList = prop.type.name == "Array"
        let isObject = prop.type.name == "Object"
        let typeName = realmList
            ? "[\(prop.type.extraInfo["identifier"]!)]"
            : isObject ? prop.type.extraInfo["identifier"]! : prop.type.name

        if let desc = prop.description {
            print("\(indent())    /// \(desc)")
        }
        if typeName == "Identifier" {
            print("\(indent())    public let \(prop.name): \(typeName)")
        } else {
            print("\(indent())    open var \(prop.name): \(typeName)\(prop.optional ? "?" : "") { fatalError(\"abstract\") }")
        }
    }

    print("\(indent())}\n")

    return output
}

func writeSchemaForRepository(_ schema: Schema) -> String {
    var output = ""

    func print(_ value: String, terminator: String = "\n") {
        Swift.print(value, terminator: terminator, to: &output)
    }
    func indent(_ level: Int = 0) -> String {
        return String(repeating: "    ", count: level)
    }
    print("\(indent())extension \(schema.name): EntityConvertible {")
    print("\(indent())    typealias Impl = \(schema.name)Impl")
    print("\(indent())    typealias Storage = Impl.Storage")
    print("")
    print("\(indent())    var storage: Storage { return (self as! \(schema.name)Impl)._storage }  // swiftlint:disable:this force_cast")
    print("\(indent())}")
    print("")
    print("\(indent())final class \(schema.name)Impl: \(schema.name), EntityImplConvertible {")
    print("\(indent())    @objc(\(schema.name)Storage)")
    print("\(indent())    final class Storage: RealmSwift.Object {")
    if let pk = schema.props.first(where: { $0.primarykey == true }) {
        print("\(indent())        override class func primaryKey() -> String? { return \"\(pk.name)\" }\n")
    }

    for prop in schema.props {
        let actual = prop.type.realmType?.type ?? prop.type
        let `default` = "\(prop.default ?? prop.type.realmType?.type.value ?? prop.type.value)"
        let realmOptional = prop.optional && actual.primitive
        let realmList = prop.type.name == "Array"
        let isObject = prop.type.name == "Object"
        func getTypeName() -> String {
            guard isObject || realmList else { return actual.name }
            if actual.name == "String" { return actual.name }
            return actual.name.replacingOccurrences(of: "!", with: "") + "Impl.Storage"
        }
        if realmList {
            print("\(indent())        let \(prop.name) = List<\(getTypeName())>()")
        } else if realmOptional {
            print("\(indent())        let \(prop.name) = RealmOptional<\(getTypeName())>(\(prop.default ?? "nil"))")
        } else {
            print("""
            \(indent())        @objc dynamic var \
            \(prop.name): \(getTypeName())\(isObject ? "!" : "")\(prop.optional && !isObject ? "?" : "")
            """, terminator: "")
            if prop.optional || isObject {
                print("")
            } else {
                print(" = \(`default`)")
            }
        }
    }

    print("\(indent())    }\n")
    print("\(indent())    fileprivate let _storage: Storage\n")
    print("\(indent())    init(storage: Storage) {")
    print("\(indent())        self._storage = storage")
    let isEntity = schema.protocols.contains("Identifiable")
    if isEntity {
        print("\(indent())        super.init(id: .init(rawValue: storage.id))")
    } else {
        print("\(indent())        super.init()")
    }
    print("\(indent())    }")
    print("")
    print("\(indent())    convenience init?(storage: Storage?) {")
    print("\(indent())        guard let storage = storage else { return nil }")
    print("\(indent())        self.init(storage: storage)")
    print("\(indent())    }")
    print("")

    for prop in schema.props {
        let actual = prop.type.realmType?.type ?? prop.type
        let realmList = prop.type.name == "Array"
        let realmOptional = prop.optional && actual.primitive
        let readonly = prop.readonly ? "" : " internal(set)"

        let isObject = prop.type.name == "Object"
        let typeName = realmList
            ? "[\(prop.type.extraInfo["identifier"]!)]"
            : isObject ? prop.type.extraInfo["identifier"]! : prop.type.name

        if prop.name == "id" { continue }

        let getter: String
        let value = realmOptional ? "_storage.\(prop.name).value" : "_storage.\(prop.name)"
        if let realmType = prop.type.realmType {
            if isObject {
                getter = "\(typeName)Impl(storage: \(value))"
            } else {
                if prop.optional {
                    getter = "\(value).flatMap \(realmType.toValue)"
                } else if realmList && prop.type.extraInfo["identifier"] == "Preview" {
                    getter = "\(value).map(\(prop.type.extraInfo["identifier"]!)Impl.init(storage:))"
                } else {
                    getter = "\(realmType.toValue)(\(value))\(realmType.optional ? "!" : "")"
                }
            }
        } else {
            getter = "\(value)"
        }
        let swiftlint = getter.hasSuffix("!") ? "  // swiftlint:disable:this force_unwrapping" : ""

        print("""
            \(indent())    \(prop.readonly ? "" : "@nonobjc ")\
            override var \(prop.name): \(typeName)\(prop.optional ? "?" : "") {
            """, terminator: "")
        if prop.readonly {
            print(" return \(getter) }\(swiftlint)")
        } else {
            print("")
            print("\(indent())        get { return \(getter) }\(swiftlint)")
            if let realmType = prop.type.realmType {
                if prop.optional {
                    if let toRealm = realmType.toRealm {
                        print("\(indent())        set { \(value) = newValue.flatMap \(toRealm) }")
                    }
                } else {
                    print("\(indent())        set { \(value) = newValue }")
                }
            } else {
                print("\(indent())        set { \(value) = newValue }")
            }
            print("\(indent())    }")
        }
    }

    print("\(indent())}\n\n")
    print("\(indent())extension \(schema.name)Impl: CustomStringConvertible {\n")
    print("\(indent())    var description: String { return _storage.description }")
    print("\(indent())}\n")

    return output
}

extension ValueType {
    static let URL = ValueType(name: "URL", back: RealmType(.String, toValue: "{ URL(string: $0) }", optional: true))
    static let UIColor = ValueType(name: "UIColor", back: RealmType(.Int, toValue: "{ UIColor(hex: $0) }"))

    static let Identifier = ValueType(name: "Identifier", back: RealmType(.String, toValue: "{ Identifier(rawValue: $0) }"))

    static let Artwork = Object(name: "Artwork")
    static let EditorialNotes = Object(name: "EditorialNotes")
    static let PlayParameters = Object(name: "PlayParameters")
}

let schemas = [
    Schema(
        name: "Activity",
        protocols: ["Identifiable"],
        props: [
            Prop(name: "id",
                 type: .Identifier,
                 primarykey: true,
                 description: "Persistent identifier of the resource. This member is required."),
            Prop(name: "artwork",
                 type: .Artwork,
                 description: "The activity artwork."),
            Prop(name: "editorialNotes",
                 type: .EditorialNotes,
                 optional: true,
                 description: "(Optional) The notes about the activity that appear in the iTunes Store."),
            Prop(name: "name",
                 type: .String,
                 description: "The localized name of the activity."),
            Prop(name: "url",
                 type: .URL,
                 description: "The URL for sharing an activity in the iTunes Store.")
        ]),
    Schema(
        name: "Album",
        protocols: ["Identifiable"],
        props: [
            Prop(name: "id",
                 type: .Identifier,
                 primarykey: true,
                 description: "Persistent identifier of the resource. This member is required."),
            Prop(name: "albumName",
                 type: .String,
                 optional: true,
                 description: "(Optional) The name of the album the music video appears on."),
            Prop(name: "artistName",
                 type: .String,
                 description: "The artist’s name."),
            Prop(name: "artwork",
                 type: .Artwork,
                 description: "The album artwork."),
            Prop(name: "contentRating",
                 type: .String,
                 optional: true,
                 description: "(Optional) The RIAA rating of the content. The possible values for this rating are clean and explicit. No value means no rating."),
            Prop(name: "copyright",
                 type: .String,
                 optional: true,
                 description: "(Optional) The copyright text."),
            Prop(name: "editorialNotes",
                 type: .EditorialNotes,
                 optional: true,
                 description: "(Optional) The notes about the album that appear in the iTunes Store."),
            Prop(name: "genreNames",
                 type: .Array(name: "String"),
                 description: "The names of the genres associated with this album."),
            Prop(name: "isComplete",
                 type: .Bool,
                 description: "Indicates whether the album is complete. If true, the album is complete; otherwise, it is not. An album is complete if it contains all its tracks and songs."),
            Prop(name: "isSingle",
                 type: .Bool,
                 description: "Indicates whether the album contains a single song."),
            Prop(name: "name",
                 type: .String,
                 description: "The localized name of the album."),
            Prop(name: "recordLabel",
                 type: .String,
                 description: "The name of the record label for the album."),
            Prop(name: "releaseDate",
                 type: .Date,
                 description: "The release date of the album in YYYY-MM-DD format."),
            Prop(name: "playParams",
                 type: .PlayParameters,
                 optional: true,
                 description: "(Optional) The parameters to use to playback the tracks of the album."),
            Prop(name: "trackCount",
                 type: .Int,
                 description: "The number of tracks."),
            Prop(name: "url",
                 type: .URL,
                 description: "The URL for sharing an album in the iTunes Store.")
            ]),
    Schema(
        name: "AppleCurator",
        protocols: ["Identifiable"],
        props: [
            Prop(
                name: "id",
                type: .Identifier,
                primarykey: true,
                description: "Persistent identifier of the resource. This member is required."),
            Prop(
                name: "artwork",
                type: .Artwork,
                description: "The curator artwork."),
            Prop(
                name: "editorialNotes",
                type: .EditorialNotes,
                optional: true,
                description: "(Optional) The notes about the curator that appear in the iTunes Store."),
            Prop(
                name: "name",
                type: .String,
                description: "The localized name of the curator."),
            Prop(
                name: "url",
                type: .URL,
                description: "The URL for sharing an curator in the iTunes Store.")
        ]),
    Schema(
        name: "Artist",
        protocols: ["Identifiable"],
        props: [
            Prop(
                name: "id",
                type: .Identifier,
                primarykey: true,
                description: "Persistent identifier of the resource. This member is required."),
            Prop(
                name: "genreNames",
                type: .Array(name: "String"),
                description: "The names of the genres associated with this artist."),
            Prop(
                name: "editorialNotes",
                type: .EditorialNotes,
                description: "(Optional) The notes about the artist that appear in the iTunes Store."),
            Prop(
                name: "name",
                type: .String,
                description: "The localized name of the curator."),
            Prop(
                name: "url",
                type: .URL,
                description: "The URL for sharing an curator in the iTunes Store.")
        ]),
    Schema(
        name: "Artwork",
        props: [
            Prop(name: "width",
                 type: .Int,
                 default: -1,
                 description: "The maximum width available for the image."),
            Prop(name: "height",
                 type: .Int,
                 default: -1,
                 description: "The maximum height available for the image."),
            Prop(name: "url",
                 type: .URL,
                 primarykey: true,
                 description: "The URL to request the image asset. The image file name must be preceded by {w}x{h}, as placeholders for the width and height values described above (for example, {w}x{h}bb.jpg)."),
            Prop(name: "bgColor",
                 type: .UIColor,
                 optional: true,
                 description: "(Optional) The average background color of the image."),
            Prop(name: "textColor1",
                 type: .UIColor,
                 optional: true,
                 description: "(Optional) The primary text color that may be used if the background color is displayed."),
            Prop(name: "textColor2",
                 type: .UIColor,
                 optional: true,
                 description: "(Optional) The secondary text color that may be used if the background color is displayed."),
            Prop(name: "textColor3",
                 type: .UIColor,
                 optional: true,
                 description: "(Optional) The tertiary text color that may be used if the background color is displayed."),
            Prop(name: "textColor4",
                 type: .UIColor,
                 optional: true,
                 description: "(Optional) The final post-tertiary text color that maybe be used if the background color is displayed.")
        ]),
//    Schema(
//        name: "Chart",
//        props: [
//            Prop(
//                name: "id",
//                type: .Identifier,
//                primarykey: true,
//                description: "Persistent identifier of the resource. This member is required."),
//            Prop(
//                name: "name",
//                type: .String,
//                description: "The localized name for the chart."),
//            Prop(
//                name: "chart",
//                type: .String,
//                description: "The chart identifier."),
//            Prop(
//                name: "href",
//                type: .URL,
//                description: "The URL for the chart."),
//            Prop(
//                name: "data",
//                type: .String,
//                description: "An array of the objects that were requested ordered by popularity. For example, if songs were specified as the chart type in the request, the array contains Song objects."),
//            Prop(
//                name: "next",
//                type: .URL,
//                optional: true,
//                description: "(Optional) The URL for the next page."),
//        ]),
    Schema(
        name: "Curator",
        protocols: ["Identifiable"],
        props: [
            Prop(
                name: "id",
                type: .Identifier,
                primarykey: true,
                description: "Persistent identifier of the resource. This member is required."),
            Prop(
                name: "artwork",
                type: .Artwork,
                description: "The curator artwork."),
            Prop(
                name: "editorialNotes",
                type: .EditorialNotes,
                optional: true,
                description: "(Optional) The notes about the curator."),
            Prop(
                name: "name",
                type: .String,
                description: "The localized name of the curator."),
            Prop(
                name: "url",
                type: .URL,
                description: "The URL for sharing a curator in Apple Music.")
        ]),
    Schema(
        name: "EditorialNotes",
        props: [
            Prop(
                name: "standard",
                type: .String,
                description: "Notes shown when the content is being prominently displayed."),
            Prop(
                name: "short",
                type: .String,
                description: "Abbreviated notes shown in-line or when the content is shown alongside other content.")
        ]),
    Schema(
        name: "Genre",
        protocols: ["Identifiable"],
        props: [
            Prop(name: "id",
                 type: .Identifier,
                 primarykey: true,
                 description: "Persistent identifier of the resource. This member is required."),
            Prop(
                name: "name",
                type: .String,
                primarykey: true,
                description: "The localized name of the genre.")
        ]),
    Schema(
        name: "MusicVideo",
        protocols: ["Identifiable"],
        props: [
            Prop(
                name: "id",
                type: .Identifier,
                primarykey: true,
                description: "Persistent identifier of the resource. This member is required."),
            Prop(
                name: "albumName",
                type: .String,
                optional: true,
                description: "(Optional) The name of the album the music video appears on."),
            Prop(
                name: "artistName",
                type: .String,
                description: "The artist’s name."),
            Prop(
                name: "artwork",
                type: .Artwork,
                description: "The artwork for the music video’s associated album."),
            Prop(
                name: "contentRating",
                type: .String,
                optional: true,
                description: "(Optional) The RIAA rating of the content. The possible values for this rating are clean and explicit. No value means no rating."),
            Prop(
                name: "durationInMillis",
                type: .Int,
                optional: true,
                description: "(Optional) The duration of the music video in milliseconds."),
            Prop(
                name: "editorialNotes",
                type: .EditorialNotes,
                description: "(Optional) The editorial notes for the music video."),
            Prop(
                name: "genreNames",
                type: .Array(name: "String"),
                description: "The music video’s associated genres."),
            Prop(
                name: "isrc",
                type: .String,
                description: "The ISRC (International Standard Recording Code) for the music video."),
            Prop(
                name: "name",
                type: .String,
                description: "The localized name of the music video."),
            Prop(
                name: "playParams",
                type: .PlayParameters,
                optional: true,
                description: "(Optional) The parameters to use to playback the music video."),
            Prop(
                name: "previews",
                type: .Array(name: "Preview"),
                description: "The preview assets for the music video."),
            Prop(
                name: "releaseDate",
                type: .Date,
                description: "The release date of the music video in YYYY-MM-DD format."),
            Prop(
                name: "trackNumber",
                type: .Int,
                optional: true,
                description: "(Optional) The number of the music video in the album’s track list."),
            Prop(
                name: "url",
                type: .URL,
                description: "A clear url directly to the music video."),
            Prop(
                name: "videoSubType",
                type: .String,
                optional: true,
                description: "(Optional) The video subtype associated with the content.")
        ]),
    Schema(
        name: "PlayParameters",
        protocols: ["Identifiable"],
        props: [
            Prop(
                name: "id",
                type: .Identifier,
                primarykey: true,
                description: "The ID of the content to use for playback."),
            Prop(
                name: "kind",
                type: .String,
                description: "The kind of the content to use for playback.")
        ]),
    Schema(
        name: "Playlist",
        protocols: ["Identifiable"],
        props: [
            Prop(
                name: "id",
                type: .Identifier,
                primarykey: true,
                description: "Persistent identifier of the resource. This member is required."),
            Prop(
                name: "artwork",
                type: .Artwork,
                optional: true,
                description: "(Optional) The playlist artwork."),
            Prop(
                name: "curatorName",
                type: .String,
                optional: true,
                description: "(Optional) The display name of the curator."),
            Prop(
                name: "editorialNotes",
                type: .EditorialNotes,
                description: "(Optional) A description of the playlist."),
            Prop(
                name: "lastModifiedDate",
                type: .Date,
                description: "The date the playlist was last modified."),
            Prop(
                name: "name",
                type: .String,
                description: "The localized name of the album."),
            Prop(
                name: "playlistType",
                type: .String,
                description: "The type of playlist."),
            Prop(
                name: "playParams",
                type: .PlayParameters,
                optional: true,
                description: "(Optional) The parameters to use to playback the tracks in the playlist."),
            Prop(
                name: "url",
                type: .URL,
                description: "The URL for sharing an album in the iTunes Store.")
        ]),
    Schema(
        name: "Preview",
        props: [
            Prop(
                name: "url",
                type: .URL,
                primarykey: true,
                description: "The preview URL for the content."),
            Prop(
                name: "artwork",
                type: .Artwork,
                optional: true,
                description: "(Optional) The preview artwork for the associated music video.")
        ]),
    Schema(
        name: "Song",
        protocols: ["Identifiable"],
        props: [
            Prop(
                name: "id",
                type: .Identifier,
                primarykey: true,
                description: "Persistent identifier of the resource. This member is required."),
            Prop(
                name: "albumName",
                type: .String,
                description: "The name of the album the song appears on."),
            Prop(
                name: "artistName",
                type: .String,
                description: "The artist’s name."),
            Prop(
                name: "artwork",
                type: .Artwork,
                description: "The album artwork."),
            Prop(
                name: "composerName",
                type: .String,
                optional: true,
                description: "(Optional) The song’s composer."),
            Prop(
                name: "contentRating",
                type: .String,
                optional: true,
                description: "(Optional) The RIAA rating of the content. The possible values for this rating are clean and explicit. No value means no rating."),
            Prop(
                name: "discNumber",
                type: .Int,
                description: "The disc number the song appears on."),
            Prop(
                name: "durationInMillis",
                type: .Int,
                optional: true,
                description: "(Optional) The duration of the song in milliseconds."),
            Prop(
                name: "editorialNotes",
                type: .EditorialNotes,
                description: "(Optional) The notes about the song that appear in the iTunes Store."),
            Prop(
                name: "genreNames",
                type: .Array(name: "String"),
                description: "The genre names the song is associated with."),
            Prop(
                name: "isrc",
                type: .String,
                description: "The ISRC (International Standard Recording Code) for the song."),
            Prop(
                name: "movementCount",
                type: .Int,
                optional: true,
                description: "(Optional, classical music only) The movement count of this song."),
            Prop(
                name: "movementName",
                type: .String,
                optional: true,
                description: "(Optional, classical music only) The movement name of this song."),
            Prop(
                name: "movementNumber",
                type: .Int,
                optional: true,
                description: "(Optional, classical music only) The movement number of this song."),
            Prop(
                name: "name",
                type: .String,
                description: "The localized name of the song."),
            Prop(
                name: "playParams",
                type: .PlayParameters,
                optional: true,
                description: "(Optional) The parameters to use to playback the song."),
            Prop(
                name: "previews",
                type: .Array(name: "Preview"),
                description: "The preview assets for the song."),
            Prop(
                name: "releaseDate",
                type: .Date,
                description: "The release date of the music video in YYYY-MM-DD format."),
            Prop(
                name: "trackNumber",
                type: .Int,
                description: "The number of the song in the album’s track list."),
            Prop(
                name: "url",
                type: .URL,
                description: "The URL for sharing a song in the iTunes Store."),
            Prop(
                name: "workName",
                type: .String,
                optional: true,
                description: "(Optional, classical music only) The name of the associated work.")
        ]),
    Schema(
        name: "Station",
        protocols: ["Identifiable"],
        props: [
            Prop(
                name: "id",
                type: .Identifier,
                primarykey: true,
                description: "Persistent identifier of the resource. This member is required."),
            Prop(
                name: "artwork",
                type: .Artwork,
                description: "The radio station artwork."),
            Prop(
                name: "durationInMillis",
                type: .Int,
                optional: true,
                description: "(Optional) The duration of the stream. Not emitted for 'live' or programmed stations."),
            Prop(
                name: "editorialNotes",
                type: .EditorialNotes,
                description: "(Optional) The notes about the station that appear in Apple Music."),
            Prop(
                name: "episodeNumber",
                type: .Int,
                optional: true,
                description: "(Optional) The episode number of the station. Only emitted when the station represents an episode of a show or other content."),
            Prop(
                name: "isLive",
                type: .Bool,
                description: "Indicates whether the station is a live stream."),
            Prop(
                name: "name",
                type: .String,
                description: "The localized name of the station."),
            Prop(
                name: "url",
                type: .URL,
                description: "The URL for sharing a station in Apple Music.")
        ]),
    Schema(
        name: "Storefront",
        protocols: ["Identifiable"],
        props: [
            Prop(
                name: "id",
                type: .Identifier,
                primarykey: true,
                description: "Persistent identifier of the resource. This member is required."),
            Prop(
                name: "name",
                type: .String,
                description: "The localized name of the storefront."),
            Prop(
                name: "supportedLanguageTags",
                type: .Array(name: "String"),
                description: "The localizations that the storefront supports, represented as an array of language tags."),
            Prop(
                name: "defaultLanguageTag",
                type: .String,
                description: "The default language for the storefront, represented as a language tag.")
        ])
]

for schema in schemas {
    let domain = """
    //
    //  \(schema.name).swift
    //  MusicshotDomain
    //
    //  Created by 林達也.
    //  Copyright © 2018年 林達也. All rights reserved.
    //

    import Foundation

    \(writeSchemaForDomain(schema))
    """

    let repository = """
    //
    //  \(schema.name).swift
    //  MusicshotRepository
    //
    //  Created by 林達也.
    //  Copyright © 2018年 林達也. All rights reserved.
    //

    import Foundation
    import RealmSwift
    import MusicshotDomain

    \(writeSchemaForRepository(schema))
    """

    try! domain.write(toFile: "./MusicshotDomain/Sources/Model/Entity/\(schema.name).swift", atomically: true, encoding: .utf8)
    try! repository.write(toFile: "./MusicshotRepository/Sources/Model/Entity/\(schema.name).swift", atomically: true, encoding: .utf8)
}
