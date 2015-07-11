fluffy
======

A small session manager using GNOME technologies. Watchdog for startup applications.

## Dependencies

To use fluffy, you'll need `gio` and `glib`. If your using a GNOME-based DE, like GNOME Shell or Pantheon, you'll probably already have these installed.

To build, you'll also need [bake](https://launchpad.net/bake). Once you've got that, just run `bake` from the base directory to build fluffy.

You'll also need to install `com.github.mbullington.fluffy.gschema.xml` as a GSettings schema.

## Configuration

Fluffy uses three layers of applications. Daemons (such as gnome-settings-daemon, etc), the window manager, and then desktop components. They load in that order. Desktop components are also relaunched if they are closed.

You can use GSettings to configure these three layers. It's under the GSettings schema `org.github.mbullington.fluffy`.

## License

Fluffy is under GPLv3. You can read the license under the LICENSE file.
