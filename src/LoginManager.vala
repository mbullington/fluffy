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

[DBus(name = "org.freedesktop.login1.Manager")]
public interface LoginManager : Object {
  public abstract Variant[] list_inhibitors() throws IOError;

  public abstract void power_off(bool interactive) throws IOError;
  public abstract void reboot(bool interactive) throws IOError;
  public abstract void suspend(bool interactive) throws IOError;
}
