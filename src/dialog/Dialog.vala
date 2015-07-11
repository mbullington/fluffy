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

namespace Fluffy {

// helper class for creating top-level windows that are dialog-like
class Dialog : Window {
  public Dialog(int width = 300, int height = 400) {
    set_position(WindowPosition.CENTER_ALWAYS);
    set_size_request(width, height);
    set_resizable(false);

    set_skip_taskbar_hint(true);
    set_skip_pager_hint(true);
    set_keep_above(true);

    var box = new Box(Orientation.HORIZONTAL, 0);
    set_titlebar(box);
    box.get_style_context().remove_class("titlebar");

    get_style_context().add_class("message-dialog");
  }
}

}
