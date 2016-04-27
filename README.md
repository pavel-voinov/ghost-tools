# ghost-tools
My personal shell and SQL scripts, etc.

Requirements:
  * exiv2 package (http://www.exiv2.org) - to parse Exif metadata in image files
  * mediainfo package (http://mediainfo.sourceforge.net) - for video files

I used recent versions available for raspbian wizzy.

Usage is easy:
- copy your photos and video to any temporary dir (e.g. /media/storage/Photos/tmp)
- make this /media/storage/Photos/tmp as current
- execute `rename_media_files.sh` - this script renames all supported media files to format "YYYY-MM-DD_HH24-MI-SS_<CameraModel>.<extention in upper case>" based on Exif/media info of files.
- if there was no metadata in media files or it was an error to export them you see something like this:
  File "IMG_12345.JPG". No Exif data found. TS: 2015-08-12_22-21-14
Where TS: ... shows file timestamp.
- then call `move_files_by_year_month.sh` to move files based on their names into directories /media/NS4300/Photos/YYYY/MM/.
  Base directory /media/NS4300/Photos is default if it's not specified as first parameter of `move_files_by_year_month.sh` script.
  `move_files_by_year_month.sh` does:
    - check if file with the same name exists in target directory
    - if it exists (assumin all indexed versions too), has the same size and md5sum than source file will be deleted
    - if it exists byt has different size new file will be created with indexed name <file_name>_001... or <file_name>_002, ...
- If there are some file without metadata are remained in temporary source directory and I trust their timestamps I run `rename_media_files.sh Y` to rename files by the similar template "YYYY-MM-DD_HH24-MI-SS_<original filename>.<extention in upper case>" but based on file timestamp.
- another call of `move_files_by_year_month.sh` is needed then to move files to /media/NS4300/Photos/YYYY/MM/ or wherever specified.

Some additional scripts and commands help to keep metadata and files' timestamps in sync:
- `fix_mtime.sh` - fix modification timestamp of file according to it's metadata of filename
- `fix_exif_metadata.sh` - set Exif metadata of images to file timestamps (Exif.Photo.DateTimeOriginal and Exif.Photo.DateTimeDigitized)
- `fix_dirs_time.sh` - set timestamps of YYYY dirs to 1st January of corresponding year and timestamp of YYYY/MM dirs to 1st of day of corresponding month.
