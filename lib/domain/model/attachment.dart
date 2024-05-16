import 'package:json_annotation/json_annotation.dart';

import 'file.dart';

part 'attachment.g.dart';

abstract class Attachment {
  Attachment({
    required this.id,
    required this.original,
    required this.filename,
  });

  factory Attachment.fromJson(Map<String, dynamic> json) =>
      switch (json['runtimeType']) {
        'ImageAttachment' => ImageAttachment.fromJson(json),
        'FileAttachment' => FileAttachment.fromJson(json),
        _ => throw UnimplementedError(json['runtimeType'])
      };

  AttachmentId id;
  StorageFile original;
  String filename;

  Map<String, dynamic> toJson() => switch (runtimeType) {
        const (ImageAttachment) => (this as ImageAttachment).toJson()
          ..['runtimeType'] = 'ChatMessage',
        const (FileAttachment) => (this as FileAttachment).toJson()
          ..['runtimeType'] = 'FileAttachment',
        _ => throw UnimplementedError(runtimeType.toString()),
      };
}

@JsonSerializable()
class ImageAttachment extends Attachment {
  ImageAttachment({
    required super.id,
    required super.original,
    required super.filename,
    required this.big,
    required this.medium,
    required this.small,
  });

  ImageFile big;
  ImageFile medium;
  ImageFile small;

  factory ImageAttachment.fromJson(Map<String, dynamic> json) =>
      _$ImageAttachmentFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ImageAttachmentToJson(this);
}

@JsonSerializable()
class FileAttachment extends Attachment {
  FileAttachment({
    required super.id,
    required super.original,
    required super.filename,
  });

  factory FileAttachment.fromJson(Map<String, dynamic> json) =>
      _$FileAttachmentFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$FileAttachmentToJson(this);
}

@JsonSerializable()
class AttachmentId {
  const AttachmentId(this.val);

  final String val;

  @override
  int get hashCode => val.hashCode;

  @override
  bool operator ==(Object other) => other is AttachmentId && val == other.val;

  @override
  String toString() => val;

  factory AttachmentId.fromJson(Map<String, dynamic> json) =>
      _$AttachmentIdFromJson(json);
  Map<String, dynamic> toJson() => _$AttachmentIdToJson(this);
}
