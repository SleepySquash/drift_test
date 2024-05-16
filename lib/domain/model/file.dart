import 'package:json_annotation/json_annotation.dart';

part 'file.g.dart';

abstract class StorageFile {
  StorageFile({
    required this.relativeRef,
    this.checksum,
    this.size,
  });

  final String relativeRef;
  final String? checksum;
  final int? size;

  factory StorageFile.fromJson(Map<String, dynamic> json) =>
      switch (json['runtimeType']) {
        'PlainFile' => PlainFile.fromJson(json),
        'ImageFile' => ImageFile.fromJson(json),
        _ => throw UnimplementedError(json['runtimeType'])
      };

  Map<String, dynamic> toJson() => switch (runtimeType) {
        const (PlainFile) => (this as PlainFile).toJson()
          ..['runtimeType'] = 'PlainFile',
        const (ImageFile) => (this as ImageFile).toJson()
          ..['runtimeType'] = 'ImageFile',
        _ => throw UnimplementedError(runtimeType.toString()),
      };
}

@JsonSerializable()
class PlainFile extends StorageFile {
  PlainFile({
    required super.relativeRef,
    super.checksum,
    super.size,
  });

  factory PlainFile.fromJson(Map<String, dynamic> json) =>
      _$PlainFileFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$PlainFileToJson(this);
}

@JsonSerializable()
class ImageFile extends StorageFile {
  ImageFile({
    required super.relativeRef,
    super.checksum,
    super.size,
    this.width,
    this.height,
    this.thumbhash,
  });

  final int? width;
  final int? height;
  final String? thumbhash;

  factory ImageFile.fromJson(Map<String, dynamic> json) =>
      _$ImageFileFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ImageFileToJson(this);
}
