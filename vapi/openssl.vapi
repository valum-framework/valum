/* OpenSSL Vala Bindings
 * Copyright 2016 Guillaume Poirier-Morency <guillaumepoiriermorency@gmail>
 *
 * Copyright 1995-2016 The OpenSSL Project Authors. All Rights Reserved.
 *
 * Licensed under the OpenSSL license (the "License").  You may not use
 * this file except in compliance with the License.  You can obtain a copy
 * in the file LICENSE in the source distribution or at
 * https://www.openssl.org/source/license.html
 */

namespace OpenSSL {

	[CCode (lower_case_cprefix = "CRYPTO_", cheader_filename = "openssl/crypto.h")]
	namespace Crypto {

		public int memcmp (void* v1, void* v2, size_t n);
	}
}
