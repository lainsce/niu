/*-
 * Copyright (c) 2019 Lains
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 2.1 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */

namespace Niu {
    public class AppSettings : GLib.Settings {
        public int window_x { 
            get { return get_int ("window-x"); }
            set { set_int ("window-x", value); }
        }
        public int window_y { 
            get { return get_int ("window-y"); }
            set { set_int ("window-y", value); }
        }
        public bool indicator_state { 
            get { return get_boolean ("indicator-state"); }
            set { set_boolean ("indicator-state", value); }
        }
        public bool background_state { 
            get { return get_boolean ("background-state"); }
            set { set_boolean ("background-state", value); }
        }
        public bool pomodoro { 
            get { return get_boolean ("pomodoro"); }
            set { set_boolean ("pomodoro", value); }
        }
        public bool beats { 
            get { return get_boolean ("beats"); }
            set { set_boolean ("beats", value); }
        }

        private static AppSettings? instance;
        public static unowned AppSettings get_default () {
            if (instance == null) {
                instance = new AppSettings ();
            }

            return instance;
        }

        private AppSettings () {
            Object (schema_id: "com.github.lainsce.niu");
        }
    }
}
