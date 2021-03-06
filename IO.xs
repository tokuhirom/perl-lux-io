#include <luxio/btree.h>

#define PERL_NO_GET_CONTEXT

#ifdef __cplusplus
extern "C" {
#endif
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include "ppport.h"
#ifdef __cplusplus
}
#endif

#define XS_STATE(type, x) \
    INT2PTR(type, SvROK(x) ? SvIV(SvRV(x)) : SvIV(x))

#define XS_STRUCT2OBJ(sv, class, obj) \
    if (obj == NULL) { \
        sv_setsv(sv, &PL_sv_undef); \
    } else { \
        sv_setref_pv(sv, class, (void *) obj); \
    }

typedef Lux::db_flags_t        Lux_db_flags_t;
typedef Lux::IO::db_index_t    Lux_IO_db_index_t;
typedef Lux::IO::insert_mode_t Lux_IO_insert_mode_t;
typedef Lux::IO::Btree         Lux_IO_Btree;

MODULE=Lux::IO    PACKAGE=Lux    PREFIX=xs_lux_

Lux_db_flags_t
xs_lux_DB_RDONLY()
CODE:
    RETVAL = Lux::DB_RDONLY;
OUTPUT:
    RETVAL

Lux_db_flags_t
xs_lux_DB_RDWR()
CODE:
    RETVAL = Lux::DB_RDWR;
OUTPUT:
    RETVAL

Lux_db_flags_t
xs_lux_DB_CREAT()
CODE:
    RETVAL = Lux::DB_CREAT;
OUTPUT:
    RETVAL

Lux_db_flags_t
xs_lux_DB_TRUNC()
CODE:
    RETVAL = Lux::DB_TRUNC;
OUTPUT:
    RETVAL

MODULE=Lux::IO    PACKAGE=Lux::IO    PREFIX=xs_lux_io_

BOOT:
    HV *stash;
    stash = gv_stashpv("Lux::IO", 1);
    newCONSTSUB(stash, "NONCLUSTER",  newSViv(Lux::IO::NONCLUSTER));
    newCONSTSUB(stash, "CLUSTER",     newSViv(Lux::IO::CLUSTER));
    newCONSTSUB(stash, "OVERWRITE",   newSViv(Lux::IO::OVERWRITE));
    newCONSTSUB(stash, "NOOVERWRITE", newSViv(Lux::IO::NOOVERWRITE));
    newCONSTSUB(stash, "APPEND",      newSViv(Lux::IO::APPEND));

MODULE=Lux::IO    PACKAGE=Lux::IO::Btree    PREFIX=xs_lux_io_

Lux_IO_Btree*
xs_lux_io_btree_new(int index_type)
CODE:
    RETVAL = new Lux::IO::Btree((Lux::IO::db_index_t) index_type);
OUTPUT:
    RETVAL

void
xs_lux_io_btree_free(Lux_IO_Btree* bt)
CODE:
    bt->close();
    delete bt;

bool
xs_lux_io_btree_open(Lux_IO_Btree* bt, const char* db_name, int oflags)
CODE:
    RETVAL = bt->open(db_name, (Lux::db_flags_t) oflags);
OUTPUT:
    RETVAL

bool
xs_lux_io_btree_close(Lux_IO_Btree* bt)
CODE:
    RETVAL = bt->close();
OUTPUT:
    RETVAL

char*
xs_lux_io_btree_get(Lux_IO_Btree* bt, const char* key)
CODE:
    Lux::IO::data_t  k = { key, strlen(key) };
    Lux::IO::data_t* v = bt->get(&k);
    if (v) {
        RETVAL = (char *) v->data;
    } else {
        RETVAL = NULL;
    }
OUTPUT:
    RETVAL

bool
xs_lux_io_btree_put(Lux_IO_Btree* bt, const char* key, const char* value, int insert_mode)
CODE:
    Lux::IO::data_t k = { key,   strlen(key)   };
    Lux::IO::data_t v = { value, strlen(value) };
    RETVAL = bt->put(&k, &v, (Lux::IO::insert_mode_t) insert_mode);
OUTPUT:
    RETVAL

bool
xs_lux_io_btree_del(Lux_IO_Btree* bt, const char *key)
CODE:
    Lux::IO::data_t k = { key, strlen(key) };
    RETVAL = bt->del(&k);
OUTPUT:
    RETVAL
