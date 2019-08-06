namespace Niu.Utils {
    public struct Resources {
        public string ar;
        public string bt;
        public string ne;
        public bool po;

        public bool get_pomodoro_state () {
            var settings = AppSettings.get_default ();
            if (settings.pomodoro) {
                po = true;
            } else {
                po = false;
            }
            return po;
        }

        public string get_arvelie_calendar_str (GLib.DateTime date) {
            string resm = "";
            double resd;
            string m = "";
            string d = "";
            var doty = double.parse(date.format ("%j"))-1;
            var y = date.get_year ().to_string ().substring (2, 2);
            if (doty == 364 || doty == 365) {
                m = "+";
            } else {
                // Ascii: 97 = A
                double an = 97 + Math.floor(doty / 14);
                resm = ((char)an).to_string ().up ();
                m = resm;
            }
            if (doty == 365) {
                d = "01";
            } else if (doty == 366) {
                d = "02";
            } else {
                resd = (doty % 14)+1;
                if (resd < 10 && resd > 0) {
                    d = "0" + resd.to_string ();
                } else if (resd == 0) {
                    d = "00";
                } else {
                    d = resd.to_string ();
                }
            }
            var arvelie = "%s%s%s".printf (y, m, d);
            return arvelie;
        }

        public string get_neralie_time_str (GLib.DateTime date) {
            double e = date.to_unix ();
            double d = new DateTime.local (date.get_year (), date.get_month (), date.get_day_of_month (), 0, 0, 0).to_unix ();
            double va = ((e - d) / 8640 / 10000) / 10000;
            string val_fmt = (va * 10000000).to_string ();
            string val_pulse = val_fmt.substring(2, 3);
            string val_beat = val_fmt.substring(5, 3);

            var neralie = "%s:%s".printf(val_pulse, val_beat);
            return neralie;
        }

        public string get_neralie_beat_str (GLib.DateTime date) {
            double e = date.to_unix ();
            double d = new DateTime.local (date.get_year (), date.get_month (), date.get_day_of_month (), 0, 0, 0).to_unix ();
            double va = ((e - d) / 8640 / 10000) / 10000;
            string val_fmt = (va * 10000000).to_string ();
            string val_pulse = val_fmt.substring(2, 3);
            return val_pulse;
        }
    }
}
