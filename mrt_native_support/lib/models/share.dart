enum FileMimeTypes {
  imageJpeg("image/jpeg"),
  imagePng("image/png"),
  imageGif("image/gif"),
  imageBmp("image/bmp"),
  imageWebp("image/webp"),
  textPlain("text/plain");

  final String value;
  const FileMimeTypes(this.value);
}

class Share {
  final String? text;
  final String? subject;
  final String? path;
  final String? fileName;
  final FileMimeTypes? mimeType;

  bool get isFile => path != null;
  Share.text(String this.text, {this.subject})
      : path = null,
        fileName = null,
        mimeType = null;
  Share.file(String this.path, String this.fileName,
      {this.subject, this.text, this.mimeType});

  Map<String, String?> toJson() {
    return {
      "text": text,
      "subject": subject,
      "path": path,
      "mimetype": getMimeType()
    };
  }

  String? getMimeType() {
    if (mimeType != null) return mimeType?.value;
    if (path == null) return null;
    final Map<String, String> mimeTypes = {
      'jpg': 'image/jpeg',
      'jpeg': 'image/jpeg',
      'png': 'image/png',
      'gif': 'image/gif',
      'bmp': 'image/bmp',
      'webp': 'image/webp',
      'txt': 'text/plain',
    };

    final List<String> parts = path!.split('.');
    if (parts.length > 1) {
      final String extension = parts.last.toLowerCase();
      return mimeTypes[extension] ?? '*/*';
    }

    return 'data:application/octet-stream';
  }
}
