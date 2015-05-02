/*
  Copyright (C) 2014-2015 Michael Bullington <mikebullingtn@gmail.com>

  This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

using GLib;

int main() {
  new FluffyMain();
  return 0;
}

enum FluffyState {
  INIT,
  WINDOWMANAGER,
  COMPONENT,
  APPS;

  public string to_string() {
    return ((EnumClass) typeof (FluffyState).class_ref()).get_value(this).value_nick;
  }
}

class FluffyMain : GLib.Object {

  List<int> status_codes;
  string home_dir;
  MainLoop loop;

  FluffyState _state;
  FluffyState state {
    get {
      return this._state;
    }
    set {
      this._state = value;
      message("Entering state %s", this._state.to_string());
    }
  }

  public FluffyMain() {
    status_codes = Utilities.get_list({2, 126, 127, 130});

    home_dir = Environment.get_home_dir();
    loop = new MainLoop();

    Posix.openlog("fluffy", Posix.LOG_PID, Posix.LOG_USER);
    Log.set_default_handler(glib_log_func);

    var settings = new Settings("com.github.mbullington.fluffy");

    state = FluffyState.INIT;
    launch_apps(settings.get_strv("desktop-daemons"));

    state = FluffyState.WINDOWMANAGER;
    launch_app(settings.get_string("desktop-wm"));

    state = FluffyState.COMPONENT;
    launch_apps(settings.get_strv("desktop-components"));

    loop.run();
  }

  int launch_app(string app) {
    try {
      message("Starting application '%s'", app);
      return spawn_app(app);
    } catch(Error err) {
      message("Failed to start the application.\n%s\n", err.message);
      return -1;
    }
  }

  void launch_apps(string[] apps) {
    foreach(string app in apps) {
      try {
        message("Starting application '%s'", app);
        spawn_app(app);
      } catch(Error err) {
        message("Failed to start the application.\n%s\n", err.message);
      }
    }
  }

  int spawn_app(string app) throws SpawnError, ShellError {
    string[]? argv = null;
    Shell.parse_argv(app, out argv);

    int pid, std_out, std_err;
    Process.spawn_async_with_pipes(home_dir, argv, null,
	      SpawnFlags.DO_NOT_REAP_CHILD |
	      SpawnFlags.SEARCH_PATH, null, out pid, null, out std_out, out std_err);

    ChildWatch.add(pid, (pid0, status) => {
      if(status_codes.index(status) == -1) {
        Timeout.add(100, () => {
          try {
            spawn_app(app);
            message("Restarted application '%s'.\n", app);
          } catch(Error err) {
            message("Failed to restart application '%s'.\n%s\n", app, err.message);
          }
          return false;
        });
      } else {
        warning("Application '%s' stopped with status %s.\n", app, status.to_string());
      }
    });
    return pid;
  }
}

static int get_log_level(LogLevelFlags flags) {
  switch(flags) {
  case LogLevelFlags.LEVEL_DEBUG:
    return 7;
  case LogLevelFlags.LEVEL_WARNING:
    return 4;
  case LogLevelFlags.LEVEL_ERROR:
    return 3;
  case LogLevelFlags.LEVEL_CRITICAL:
    return 2;
  default:
    return 6; // INFO
  }
}

static void glib_log_func(string? d, LogLevelFlags flags, string msg) {
  var domain = "";
  if(d != null)
    domain = ("[%s] ").printf(d ?? "");

  var message = msg.replace("\n", "").replace("\r", "");
  message = ("%s%s").printf(domain, message);

  Posix.syslog(get_log_level(flags), message);
  stdout.printf(" %s\n", message);
}
