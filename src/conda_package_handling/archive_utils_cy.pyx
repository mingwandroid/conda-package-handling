# Cython wrapper around archive_utils_c

from libc.stdlib cimport free


cdef extern from "archive_utils_c.c":
    void * prepare_gnutar_archive(
        const char *outname_u8, const char *filtername, const char *opts,
        const char **err_str_u8, Py_ssize_t *err_str_u8)
    void close_archive(void *a)
    void * prepare_entry()
    void close_entry(void *entry)
    int add_file(void *a, void *entry, const char *filename_u8, const char ** err_str_u8, Py_ssize_t * err_str_u8_len)
    int extract_file_c(const char *filename_u8, const char ** err_str_u8, Py_ssize_t * err_str_u8_len)

def return_utf8(s):
    if isinstance(s, str):
        return s.encode('utf-8')
    if isinstance(s, (int, float, complex)):
        return str(s).encode('utf-8')
    try:
        return s.encode('utf-8')
    except TypeError:
        try:
            return str(s).encode('utf-8')
        except AttributeError:
            return s
    except AttributeError:
        return s
    return s # assume it was already utf-8


def extract_file(tarball):
    """Extract a tarball into the current directory."""
    cdef const char *err_str_u8 = NULL
    cdef Py_ssize_t err_str_u8_len = 0
    tb_utf8 = return_utf8(tarball)
    result = extract_file_c(tb_utf8, &err_str_u8, &err_str_u8_len)
    if result:
        return 1, <bytes> err_str_u8
    return 0, b''

'''
def to_python_string(err_str_u8, err_str_u8_len):
    err_str_py = None
    try:
        err_str_py = err_str_u8[:err_str_u8_len]  # Performs a copy of the data
    finally:
        free(err_str_u8)
    return err_str_py
'''

def create_archive(fullpath, files, compression_filter, compression_opts):
    """ Create a compressed gnutar archive. """
    cdef void *a
    cdef void *entry
    cdef char *err_str_u8 = NULL
    cdef Py_ssize_t err_str_u8_len = 0
    a = prepare_gnutar_archive(return_utf8(fullpath),
                               return_utf8(compression_filter),
                               return_utf8(compression_opts),
                               &err_str_u8, &err_str_u8_len)
    print("about to call to_python_string")

    err_str_py = None
    try:
        err_str_py = err_str_u8[:err_str_u8_len]  # Performs a copy of the data
    finally:
        free(err_str_u8)
    print("err_str_py {}".format(err_str_py))

    if a == NULL:
        print("a is NULL")
        return 1, <bytes> err_str_py, b''
    entry = prepare_entry()
    if entry == NULL:
        return 1, b'archive entry creation failed', b''
    for f in files:
        print(f)
        f_utf8 = return_utf8(f)
        print(f_utf8)
        result = add_file(a, entry, f_utf8, &err_str_u8, &err_str_u8_len)
        try:
            err_str_py = err_str_u8[:err_str_u8_len]  # Performs a copy of the data
        finally:
            free(err_str_u8)
        if result:
            return 1, <bytes> err_str_py, f
    close_entry(entry)
    close_archive(a)
    return 0, b'', b''
