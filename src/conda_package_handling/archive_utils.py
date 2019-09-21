from . import archive_utils_cy
from .exceptions import ArchiveCreationError, InvalidArchiveError


def _to_bytes(s):
    if isinstance(s, bytes):
        return s
    return s.encode('utf-8')


def extract_file(tarball):
    tarball_bytes = _to_bytes(tarball)
    result, error_str = archive_utils_cy.extract_file(tarball_bytes)
    if result:
        raise InvalidArchiveError(tarball, error_str.decode('utf-8'))


def create_archive(fullpath, files, compression_filter, compression_opts):
    print("in archive_utils.create_archive fullpath {}".format(fullpath))
    fullpath = _to_bytes(fullpath)
    print("in archive_utils.create_archive _to_bytes(fullpath) {}".format(fullpath))
    compression_filter = _to_bytes(compression_filter)
    compression_opts = _to_bytes(compression_opts)
    files = [_to_bytes(f) for f in files]
    result, error_str, error_file = archive_utils_cy.create_archive(
        fullpath, files, compression_filter, compression_opts)
    if result:
        message = error_str.decode('utf-8')
        if len(error_file):
            message += " while writing file: " + error_file.decode('utf-8')
        raise ArchiveCreationError(message)

# create_archive('C:\\Users\\rdonnelly\\cluster.tgz', ['C:\\opt\\asrc\\conda-package-handling\\tests\\data\\unicode-test\\unicode-files\\❤'], 'tbz2', '')
create_archive('C:\\Users\\rdonnelly\\cluster-empty.tgz', [], 'gzip', '')
create_archive('C:\\Users\\rdonnelly\\cluster.tgz', ['C:\\opt\\asrc\\conda-package-handling\\tests\\data\\unicode-test\\unicode-files\\❤'], 'bzip2', '')
