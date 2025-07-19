import gi
gi.require_version('Gtk', '3.0')
gi.require_version('GdkPixbuf', '2.0')
import requests
from urllib.request import urlopen
from gi.repository import Gtk, Gdk, GdkPixbuf, cairo, GLib
import cairo
import subprocess
import re
import json
import os
from datetime import datetime
from typing import Optional
import gi
gi.require_version('Gtk', '3.0')
from gi.repository import Gtk

import glob
import configparser

import datetime
from fabric import Application
from fabric.widgets.box import Box
from fabric.widgets.label import Label
from fabric.widgets.overlay import Overlay
from fabric.widgets.eventbox import EventBox
from fabric.widgets.datetime import DateTime
from fabric.widgets.centerbox import CenterBox
from fabric.widgets.scale import Scale
from fabric.widgets.image import Image
from fabric.widgets.circularprogressbar import CircularProgressBar
from fabric.system_tray.widgets import SystemTray
from fabric.widgets.wayland import WaylandWindow as Window
from fabric.hyprland.widgets import Language, ActiveWindow, Workspaces, WorkspaceButton
from fabric.utils import (
    FormattedString,
    Gtk,
    bulk_replace,
    invoke_repeater,
    get_relative_path,
)
def get_distro_name():
    output = subprocess.check_output('cat /etc/*-release', shell=True, text=True)
    distro_name = ""
    for line in output.splitlines():
        if line.startswith('NAME='):
            distro_name = line.split('=', 1)[1].strip('"')
            break
    return distro_name

def circular_pixbuf(path, size):
    # Load original image
    pixbuf = GdkPixbuf.Pixbuf.new_from_file_at_scale(path, size, size, True)
    # Create a surface to draw the circle
    surface = cairo.ImageSurface(cairo.FORMAT_ARGB32, size, size)
    ctx = cairo.Context(surface)
    ctx.arc(size/2, size/2, size/2, 0, 2*3.1416)
    ctx.clip()
    Gdk.cairo_set_source_pixbuf(ctx, pixbuf, 0, 0)
    ctx.paint()
    # Convert surface back to pixbuf
    data = surface.get_data()
    circular = GdkPixbuf.Pixbuf.new_from_data(
        data,
        GdkPixbuf.Colorspace.RGB,
        True,
        8,
        size,
        size,
        surface.get_stride()
    )
    return circular


def get_uptime():
    try:
        with open('/proc/uptime', 'r') as f:
            uptime_seconds = float(f.readline().split()[0])
        hours = int(uptime_seconds // 3600)
        minutes = int((uptime_seconds % 3600) // 60)
        return hours, minutes
    except Exception:
        return 0, 0


APP_DIRS = [
    "/usr/share/applications",
    os.path.expanduser("~/.local/share/applications"),
]

def get_desktop_entries():
    entries = []
    for app_dir in APP_DIRS:
        for filepath in glob.glob(os.path.join(app_dir, "*.desktop")):
            config = configparser.ConfigParser(interpolation=None)
            try:
                config.read(filepath)
                entry = config["Desktop Entry"]
                if entry.get("NoDisplay", "false").lower() == "true":
                    continue
                name = entry.get("Name")
                icon = entry.get("Icon")
                exec_cmd = entry.get("Exec")
                if name and icon and exec_cmd:
                    entries.append({
                        "name": name,
                        "icon": icon,
                        "exec": exec_cmd.split(" ")[0],  # Remove arguments for now
                    })
            except Exception:
                continue
    # Remove duplicates by name
    seen = set()
    unique = []
    for e in entries:
        if e["name"] not in seen:
            seen.add(e["name"])
            unique.append(e)
    return unique


def get_cpu_usage():
    try:
        output = subprocess.check_output(
            ["top", "-bn1"], text=True
        )
        for line in output.split('\n'):
            if "Cpu(s)" in line:
                # Extract CPU usage percentage
                val = float(line.split()[1].replace('%us,', ''))
                return int(val)
    except Exception:
        return 50

def get_ram_usage():
    try:
        output = subprocess.check_output(["free"], text=True)
        lines = output.split('\n')
        mem_line = lines[1].split()
        total = int(mem_line[1])
        used = int(mem_line[2])
        return int((used / total) * 100)
    except Exception:
        return 0

def get_disk_usage():
    try:
        output = subprocess.check_output(["df", "/"], text=True)
        lines = output.split('\n')
        if len(lines) > 1:
            percent = lines[1].split()[4].replace('%', '')
            return int(percent)
    except Exception:
        return 0

def get_gpu_usage():
    try:
        # Use nvidia-smi to get GPU utilization
        output = subprocess.check_output([
            "nvidia-smi", 
            "--query-gpu=utilization.gpu", 
            "--format=csv,noheader,nounits"
        ], text=True, stderr=subprocess.DEVNULL) [15][16]
        
        # Parse the output to get GPU utilization percentage
        gpu_util = int(output.strip().split('\n')[0])
        return gpu_util
    except Exception:
        # Return 0 if nvidia-smi is not available or GPU not found
        return 0

def get_brightness():
    try:
        current = subprocess.check_output(["brightnessctl", "g"], text=True)
        maximum = subprocess.check_output(["brightnessctl", "m"], text=True)
        val = int(current.strip())
        max_val = int(maximum.strip())
        return int((val / max_val) * 100)
    except Exception:
        return 0
def get_battery():
    try:
        # Get the list of battery devices
        devices = subprocess.check_output(
            ["upower", "-e"], text=True
        ).splitlines()
        # Find the first device that looks like a battery
        battery = next((dev for dev in devices if "BAT" in dev), None)
        if not battery:
            return 0
        # Query battery info
        info = subprocess.check_output(
            ["upower", "-i", battery], text=True
        ).splitlines()
        for line in info:
            if "percentage" in line:
                percent = line.split(":")[1].strip()
                if percent.endswith("%"):
                    percent = percent[:-1]
                return int(percent)
        return 0
    except Exception as e:
        return 0


ICON_MAP = {
    "01d": "",  # clear day
    "01n": "",  # clear night
    "02d": "",  # few clouds day
    "02n": "",  # few clouds night
    "03d": "",  # scattered clouds
    "03n": "",
    "04d": "",  # broken clouds
    "04n": "",
    "09d": "",  # shower rain
    "09n": "",
    "10d": "󰖔",  # rain day
    "10n": "󰖔",  # rain night
    "11d": "",  # thunderstorm
    "11n": "",
    "13d": "",  # snow
    "13n": "",
    "50d": "",  # mist
    "50n": "",
}

def get_location():
    resp = requests.get("https://get.geojs.io/v1/ip/geo.json")
    data = resp.json()
    city = data.get("city")
    return city

def get_api_key():
    api_key = None
    try:
        with open(os.path.expanduser('~/.config/hypr/dashboard/.env'), 'r') as f:
            for line in f:
                if line.startswith('API_KEY='):
                    api_key = line.strip().split('=', 1)[1]
    except FileNotFoundError:
        api_key = None
    return api_key
def get_weather(api_key,city):
    url = f'https://api.openweathermap.org/data/2.5/weather?q={city}&appid={api_key}&units=metric'
    try:
        response = requests.get(url)
        data = response.json()
        if data.get('cod') != 200:
            return
        temp = data['main']['temp']
        desc = data['weather'][0]['description'].capitalize()
        icon_code = data['weather'][0]['icon']
        emoji = ICON_MAP.get(icon_code, "")
        return temp, desc, city, emoji+" "
    except Exception as e:
        return e

def get_goals():
    path = "./goals.txt"
    if not os.path.isfile(path):
        return []
    with open(path, "r") as f:
        return [line.strip() for line in f if line.strip()]


def get_quote():
    try:
        quote = subprocess.check_output(["fortune"], text=True)
        quote = quote.strip()
        if len(quote) > 400:
            quote = quote[:400] + "..."
        return quote
    except Exception as e:
        return "No fortune today :("

def center_everything(widget):
    widget.set_halign(Gtk.Align.CENTER)
    widget.set_valign(Gtk.Align.CENTER)
    # Recursively center all children, if any
    if hasattr(widget, "get_children"):
        for child in widget.get_children():
            center_everything(child)

def get_volume():
    try:
        quote = subprocess.check_output(["amixer","get","Master"], text=True).splitlines()
        for lines in quote:
            if lines.startswith("Front"):
                percent=lines.split(" ")[4]
                percent=int(percent[1:3])
                return percent
    except Exception:
        return 0

class PieChartWidget(Box):
    def __init__(self, icon_name, value, value_func):
        interval_ms=1000
        super().__init__(orientation="v", spacing=4)
        self.value_func = value_func
        self.progress = CircularProgressBar(
            value=value / 100.0,
            pie=True,
        )
        self.add(self.progress)
        self.icon_label = Label(text=icon_name)
        self.add(self.icon_label)

        # Start automatic updates if value_func is provided
        if self.value_func is not None:
            GLib.timeout_add(interval_ms, self.update_value)
        self.show_all()

    def update_value(self):
        new_value = self.value_func()
        if new_value is not None:
            self.progress.value = new_value / 100.0
        return self.value_func is not None
