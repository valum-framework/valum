[CCode (lower_case_cprefix = "sd_")]
namespace Systemd {

	[CCode (cheader_filename = "systemd/sd-journal.h")]
	namespace Journal {
		public int send (string format, ...);
	}
}
