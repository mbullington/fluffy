using GLib;
using Gee;

int main() {
  new FluffyMain();
  return 0;
}

class FluffyMain : GLib.Object {

  Gee.List<int> status_codes;
  string home_dir;
  MainLoop loop;

  public FluffyMain() {
    status_codes = new ArrayList<int>();
    home_dir = Environment.get_home_dir();
    loop = new MainLoop();
  
    message("Starting Fluffy.");
    add_all({2, 126, 127, 130});
  
    var settings = new Settings("com.github.mbullington.fluffy");

    string[] desktop_daemons = settings.get_strv("desktop-daemons");
    string desktop_wm = settings.get_string("desktop-wm");
    string[] desktop_components = settings.get_strv("desktop-components");

    Log.set_always_fatal(LogLevelFlags.LEVEL_CRITICAL);

    try {
      foreach(string daemon in desktop_daemons) {
        Process.spawn_command_line_async(daemon);
      }
    } catch(SpawnError err) {
      critical("Failed to launch a daemon. Quiting.\n%s\n", err.message);
    }

    int? wm_pid = null;
    try {
      Process.spawn_async(home_dir, {desktop_wm}, null, SpawnFlags.DO_NOT_REAP_CHILD | SpawnFlags.SEARCH_PATH, null, out wm_pid);
      ChildWatch.add(wm_pid, (pid, status) => { 
        loop.quit();
      });
    } catch(SpawnError err) {
      critical("Failed to launch the window manager. Quiting.\n%s\n", err.message);
    }

    try {
      foreach(string app in desktop_components) {
        spawn_app(app);
      }
    } catch(Error err) {
      message("Failed to start an application component. Ignoring.\n%s\n", err.message);
    }

    loop.run();
  }
  
  void add_all(int[] array) {
    foreach(int obj in array) {
      status_codes.add(obj);
    }
  }
  
  void spawn_app(string app) throws SpawnError, ShellError {
    string[]? argv = null;
    Shell.parse_argv(app, out argv);
        
    int pid;
    Process.spawn_async(home_dir, argv, null, SpawnFlags.STDOUT_TO_DEV_NULL | SpawnFlags.STDERR_TO_DEV_NULL | SpawnFlags.DO_NOT_REAP_CHILD | SpawnFlags.SEARCH_PATH, null, out pid);
    ChildWatch.add(pid, (pid0, status) => { 
      if(status_codes.index_of(status) == -1) {
        Timeout.add(100, () => {
          try {
            message(app);
            spawn_app(app);
            message("Restarted an application component.\n");
          } catch(Error err) {
            message("Failed to restart an application component.\n%s\n", err.message);
          }
          return false;
        });
      } else {
        message("Stopped handling an application component.\n");
      }
    });
  }

}

