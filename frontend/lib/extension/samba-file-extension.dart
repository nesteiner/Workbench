import 'package:frontend/model/samba.dart';

extension SambaFileExtensions on List<SambaFile> {
  List<SambaFile> get sortByName {
    final List<SambaFile> dirs = [];
    final List<SambaFile> files = [];

    for (final entity in this) {
      if (entity.filetype == FileType.directory) {
        dirs.add(entity);
      } else if (entity.filetype != FileType.unknown) {
        files.add(entity);
      }
    }

    dirs.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    files.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    return [...dirs, ...files];
  }

  List<SambaFile> get sortByDate {
    final files = [...this];
    files.sort((a, b) => b.lastModified.compareTo(a.lastModified));
    return files;
  }

  List<SambaFile> get sortByType {
    final List<SambaFile> dirs = [];
    final List<SambaFile> files = [];

    for (final entity in this) {
      if (entity.filetype == FileType.directory) {
        dirs.add(entity);
      } else if (entity.filetype != FileType.unknown) {
        files.add(entity);
      }
    }

    dirs.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    files.sort((a, b) => a.name.toLowerCase().split(".").last.compareTo(b.name.toLowerCase().split(".").last));

    return [...dirs, ...files];
  }

  List<SambaFile> get sortBySize {
    final List<SambaFile> dirs = [];
    final List<SambaFile> files = [];

    for (final entity in this) {
      if (entity.filetype == FileType.directory) {
        dirs.add(entity);
      } else if (entity.filetype != FileType.unknown) {
        files.add(entity);
      }
    }

    dirs.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    files.sort((a, b) => b.size!.compareTo(b.size!));

    return [...dirs, ...files];
  }
}