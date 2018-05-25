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

extension ValueType {
    static let URL = ValueType(name: "URL", back: RealmType(.String, toValue: "{ URL(string: $0) }", optional: true))
    static let UIColor = ValueType(name: "UIColor", back: RealmType(.Int, toValue: "{ UIColor(hex: $0) }"))

    static let Identifier = ValueType(name: "Identifier", back: RealmType(.String, toValue: "{ Identifier(rawValue: $0) }"))
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

func write(schema: Schema) -> String {
    var output = ""

    func print(_ value: String, terminator: String = "\n") {
        Swift.print(value, terminator: terminator, to: &output)
    }
    func indent(_ level: Int = 0) -> String {
        return String(repeating: "    ", count: level)
    }
    let protocols = schema.protocols.isEmpty ? "" : ", \(schema.protocols.joined(separator: ", "))"
    print("\(indent())public final class \(schema.name): RealmSwift.Object\(protocols) {")
    if let codes = schema.code?.components(separatedBy: "\n") {
        for code in codes {
            print("\(indent())    \(code)")
        }
        print("")
    }

    if let pk = schema.props.first(where: { $0.primarykey == true }) {
        print("\(indent())    public override class func primaryKey() -> String? { return \"_\(pk.name)\" }\n")
    }

    for prop in schema.props {
        let actual = prop.type.realmType?.type ?? prop.type
        let `default` = "\(prop.default ?? prop.type.realmType?.type.value ?? prop.type.value)"
        let realmOptional = prop.optional && actual.primitive
        let realmList = prop.type.name == "Array"
        if realmList {
            print("\(indent())    private let _\(prop.name) = List<\(actual.name)>()")
        } else if realmOptional {
            print("\(indent())    private let _\(prop.name) = RealmOptional<\(actual.name)>(\(prop.default ?? "nil"))")
        } else {
            let isObject = prop.type.name == "Object"
            print("""
            \(indent())    @objc private dynamic var \
            _\(prop.name): \(actual.name)\(prop.optional && !isObject ? "?" : "")
            """, terminator: "")
            if prop.optional || isObject {
                print("")
            } else {
                print(" = \(`default`)")
            }
        }
    }

    print("")

    for prop in schema.props {
        let actual = prop.type.realmType?.type ?? prop.type
        let realmList = prop.type.name == "Array"
        let realmOptional = prop.optional && actual.primitive
        let readonly = prop.readonly ? "" : " internal(set)"

        let isObject = prop.type.name == "Object"

        let getter: String
        let value = realmOptional ? "_\(prop.name).value" : "_\(prop.name)"
        if let realmType = prop.type.realmType {
            if isObject {
                getter = "\(value)"
            } else {
                if prop.optional {
                    getter = "\(value).flatMap \(realmType.toValue)"
                } else {
                    getter = "\(realmType.toValue)(\(value))\(realmType.optional ? "!" : "")"
                }
            }
        } else {
            getter = "\(value)"
        }
        let swiftlint = getter.hasSuffix("!") ? "  // swiftlint:disable:this force_unwrapping" : ""

        if let desc = prop.description {
            print("\(indent())    /// \(desc)")
        }
        let typeName = realmList
            ? "[\(prop.type.extraInfo["identifier"]!)]"
            : isObject ? prop.type.extraInfo["identifier"]! : prop.type.name
        print("""
            \(indent())    \(prop.readonly ? "" : "@nonobjc ")\
            public\(readonly) var \(prop.name): \(typeName)\(prop.optional ? "?" : "") {
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

    print("\(indent())}\n")

    return output
}

let schemas = [
    Schema(
        name: "Activity",
        props: [
            Prop(name: "artwork",
                 type: .Object(name: "Artwork"),
                 description: "The activity artwork."),
            Prop(name: "editorialNotes",
                 type: .Object(name: "EditorialNotes"),
                 optional: true,
                 description: "(Optional) The notes about the activity that appear in the iTunes Store."),
            Prop(name: "name",
                 type: .String,
                 description: "The localized name of the activity."),
            Prop(name: "url",
                 type: .URL,
                 primarykey: true,
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
                 type: .Object(name: "Artwork"),
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
                 type: .Object(name: "EditorialNotes"),
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
                 type: .Object(name: "PlayParameters"),
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
        name: "Artwork",
        props: [
            Prop(name: "url",
                 type: .URL,
                 primarykey: true),
            Prop(name: "width",
                 type: .Int,
                 default: -1),
            Prop(name: "height",
                 type: .Int,
                 default: -1),
            Prop(name: "bgColor",
                 type: .UIColor,
                 optional: true),
            Prop(name: "textColor1",
                 type: .UIColor,
                 optional: true),
            Prop(name: "textColor2",
                 type: .UIColor,
                 optional: true),
            Prop(name: "textColor3",
                 type: .UIColor,
                 optional: true),
            Prop(name: "textColor4",
                 type: .UIColor,
                 optional: true)
        ]),
    Schema(
        name: "Song",
        protocols: ["Identifiable"],
        props: [
            Prop(name: "id",
                 type: .Identifier,
                 primarykey: true),
            Prop(name: "artistName",
                 type: .String)
        ])
]

for schema in schemas {
    print(write(schema: schema))
}
