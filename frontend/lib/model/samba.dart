enum SortBy {
  name,
  date,
  type,
  size
}

enum FileType {
  text,
  image,
  video,
  audio,
  directory,
  unknown
}

FileType fileTypeFrom(String filetype) {
  if (filetype == "text") {
    return FileType.text;
  } else if (filetype == "image") {
    return FileType.image;
  } else if (filetype == "video") {
    return FileType.video;
  } else if (filetype == "audio") {
    return FileType.audio;
  } else if (filetype == "directory") {
    return FileType.directory;
  } else {
    return FileType.unknown;
  }
}

class SambaFile {
  final String name;
  final String path;
  final DateTime lastModified;
  final int? size;
  final FileType filetype;

  SambaFile({
    required this.name,
    required this.path,
    required this.lastModified,
    this.size,
    required this.filetype
  });

  factory SambaFile.fromJson(Map<String, dynamic> json) {
    return SambaFile(
      name: json["name"],
      path: json["path"],
      lastModified: _parse(json["lastModified"]),
      size: json["size"],
      filetype: fileTypeFrom(json["filetype"])
    );
  }
}

const Map<String, String> _months = {
  "Jan": "01",
  "Feb": "02",
  "Mar": "03",
  "Apr": "04",
  "May": "05",
  "Jun": "06",
  "Jul": "07",
  "Aug": "08",
  "Sep": "09",
  "Oct": "10",
  "Nov": "11",
  "Dec": "12"
};

DateTime _parse(String input) {
  final parts = input.split(" ");
  if (parts.length == 1) {
    return DateTime.parse(input);
  }

  final month = parts[1];
  final string = "${parts[5]}-${_months[month]}-${parts[2]} ${parts[3]}";

  return DateTime.parse(string);
}