[DBus (name = "com.github.lainsce.niu")]
public class Niu.DBusServer : Object {
    private const string DBUS_NAME = "com.github.lainsce.niu";
    private const string DBUS_PATH = "/com/github/lainsce/niu";

    private static GLib.Once<DBusServer> instance;

    public static unowned DBusServer get_default () {
        return instance.once (() => { return new DBusServer (); });
    }

    public signal void indicator_state (bool state);
    public signal void update (Utils.Resources data);
    public signal void quit ();
    public signal void show ();

    construct {
        Bus.own_name (
            BusType.SESSION,
            DBUS_NAME,
            BusNameOwnerFlags.NONE,
            (connection) => on_bus_aquired (connection),
            () => { },
            null
        );
    }

    public void quit_niu () throws IOError, DBusError {
        quit ();
    }

    public void show_niu () throws IOError, DBusError {
        show ();
    }

    private void on_bus_aquired (DBusConnection conn) {
        try {
            debug ("DBus registered!");
            conn.register_object ("/com/github/lainsce/niu", get_default ());
        } catch (Error e) {
            error (e.message);
        }
    }
}

[DBus (name = "com.github.lainsce.niu")]
public errordomain DBusServerError {
    SOME_ERROR
}

