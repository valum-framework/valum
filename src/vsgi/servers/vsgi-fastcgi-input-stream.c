#include "vsgi-fastcgi.h"
#include "vsgi-fastcgi-input-stream.h"

typedef struct
{
	FCGX_Stream *in;
} VSGIFastCGIInputStreamPrivate;

struct _VSGIFastCGIInputStream
{
	GUnixInputStream               parent_instance;
	VSGIFastCGIInputStreamPrivate *priv;
};

G_DEFINE_TYPE_WITH_PRIVATE (VSGIFastCGIInputStream,
                            vsgi_fastcgi_input_stream,
                            G_TYPE_UNIX_INPUT_STREAM)

gssize
vsgi_fastcgi_input_stream_real_read (GInputStream  *self,
                                     void          *buffer,
                                     gsize          count,
                                     GCancellable  *cancellable,
                                     GError       **error)
{
	FCGX_Stream *in_stream;
	gint ret;
	gint err;

	g_return_val_if_fail (VSGI_FASTCGI_IS_INPUT_STREAM (self), -1);

	in_stream = VSGI_FASTCGI_INPUT_STREAM (self)->priv->in;

	ret = FCGX_GetStr (buffer, count, in_stream);

	if (G_UNLIKELY (ret == -1))
	{
		err = FCGX_GetError (in_stream);

		g_set_error (error,
		             G_IO_ERROR,
		             g_io_error_from_errno (err),
		             vsgi_fastcgi_strerror (err));

		FCGX_ClearError (in_stream);

		return -1;
	}

	return ret;
}

gboolean
vsgi_fastcgi_input_stream_real_close (GInputStream  *self,
                                      GCancellable  *cancellable,
                                      GError       **error)
{
	FCGX_Stream *in_stream;
	gint ret;
	gint err;

	g_return_val_if_fail (VSGI_FASTCGI_IS_INPUT_STREAM (self), FALSE);

	in_stream = VSGI_FASTCGI_INPUT_STREAM (self)->priv->in;

	ret = FCGX_FClose (in_stream);

	if (G_UNLIKELY (ret == -1))
	{
		err = FCGX_GetError (in_stream);

		g_set_error (error,
		             G_IO_ERROR,
		             g_io_error_from_errno (err),
		             vsgi_fastcgi_strerror (err));

		FCGX_ClearError (in_stream);

		return FALSE;
	}

    return in_stream->isClosed;
}

static void
vsgi_fastcgi_input_stream_init (VSGIFastCGIInputStream *self)
{
	self->priv = vsgi_fastcgi_input_stream_get_instance_private (self);
}

static void
vsgi_fastcgi_input_stream_class_init (VSGIFastCGIInputStreamClass *klass)
{
	klass->parent_class.parent_class.read_fn = vsgi_fastcgi_input_stream_real_read;
	klass->parent_class.parent_class.close_fn = vsgi_fastcgi_input_stream_real_close;
}

VSGIFastCGIInputStream*
vsgi_fastcgi_input_stream_new (gint fd, FCGX_Stream* in)
{
	VSGIFastCGIInputStream *self;

	self = g_object_new (VSGI_FASTCGI_TYPE_INPUT_STREAM, "fd", fd, NULL);

	self->priv->in = in;

	return self;
}
