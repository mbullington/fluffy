/*
  Copyright (C) 2015 Michael Bullington <mikebullingtn@gmail.com>

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
using Gtk;

public static int main(string[] args) {
  Gtk.init(ref args);

  LoginManager login;
  try {
    login = Bus.get_proxy_sync(BusType.SYSTEM, "org.freedesktop.login1",
        "/org/freedesktop/login1");
  } catch(IOError e) {
    error("fluffy-dialog only works on systemd enviroments, or a system with a logind compatible DBus API.");
  }

  var dialog = new Fluffy.Dialog();
  dialog.destroy.connect(Gtk.main_quit);

  var box = new Box(Orientation.VERTICAL, 5);

  var logout = new Button.with_label("Logout");
  logout.clicked.connect(() => {
    dialog.close();
    Process.spawn_command_line_async("fluffy log-out");
  });


  var sleep = new Button.with_label("Sleep");
  sleep.clicked.connect(() => {
    dialog.close();
    login.suspend(true);
  });

  var restart = new Button.with_label("Restart");
  restart.clicked.connect(() => {
    dialog.close();
    login.reboot(true);
  });

  var power_off = new Button.with_label("Power Off");
  power_off.get_style_context().add_class("destructive-action");
  power_off.clicked.connect(() => {
    dialog.close();
    login.power_off(true);
  });

  box.pack_end(power_off, false, false);
  box.pack_end(restart, false, false);
  box.pack_end(sleep, false, false);
  box.pack_start(logout, false, false);

  box.margin = 15;

  dialog.add(box);
  dialog.show_all();

  Gtk.main();
  return 0;
}
