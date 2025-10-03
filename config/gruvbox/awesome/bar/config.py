
import subprocess
import re
from datetime import datetime

from fabric import Application
from fabric.widgets.box import Box
from fabric.widgets.label import Label
from fabric.widgets.overlay import Overlay
from fabric.widgets.eventbox import EventBox
from fabric.widgets.datetime import DateTime
from fabric.widgets.centerbox import CenterBox
from fabric.widgets.x11 import X11Window as Window

from fabric.utils import (
    FormattedString,
    bulk_replace,
    invoke_repeater,
    get_relative_path,
)
# Enable or disable the volume widget
AUDIO_WIDGET = True

# --- Volume Widget Icons ---
volume_icons = {
    'muted':  '󰝟',
    'low':    '󰕿',
    'medium': '󰖀',
    'high':   '󰕾',
}

def get_volume_icon(volume, muted):
    if muted or volume == 0:
        return volume_icons['muted']
    elif volume <= 30:
        return volume_icons['low']
    elif volume <= 70:
        return volume_icons['medium']
    else:
        return volume_icons['high']

class VolumeWidget(Box):
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.icon_label = Label(
            label=volume_icons['medium'],
            style="margin: 0px 6px 0px 0px; font-size: 16px",
        )
        self.event_box = EventBox(
            events="scroll",
            child=self.icon_label,
        )
        self.event_box.connect("scroll-event", self.on_scroll)
        self.add(self.event_box)
        self.update_volume()
        invoke_repeater(2000, self.update_volume)

    def on_scroll(self, _, event):
        step = 2
        if event.direction == 0:
            subprocess.run(["amixer", "-q", "set", "Master", f"{step}%+"])
        elif event.direction == 1:
            subprocess.run(["amixer", "-q", "set", "Master", f"{step}%-"])
        self.update_volume()

    def get_volume_status(self):
        try:
            output = subprocess.check_output(
                ["amixer", "get", "Master"],
                stderr=subprocess.STDOUT,
                text=True
            )
            is_muted = "[off]" in output
            vol_match = re.search(r'\[(\d+)%\]', output)
            volume = int(vol_match.group(1)) if vol_match else 0
            return is_muted, volume
        except Exception:
            return True, 0

    def update_volume(self):
        is_muted, volume = self.get_volume_status()
        icon = get_volume_icon(volume, is_muted)
        self.icon_label.set_label(icon)

# --- Bluetooth Widget ---
class BluetoothWidget(Box):
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.icon_label = Label(
            label="󰂯",
            style="margin: 0px 6px 0px 0px; font-size: 16px",
        )
        self.add(self.icon_label)
        invoke_repeater(5000, self.update_status)

    def update_status(self):
        try:
            output = subprocess.check_output(
                ['bluetoothctl', 'devices', 'Connected'],
                text=True,
                stderr=subprocess.DEVNULL
            )
            connected = bool(output.strip())
        except Exception:
            connected = False
        self.icon_label.set_label("󰂰" if connected else "󰂯")
        return True

# --- WiFi Widget ---
class WifiWidget(Box):
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.icon_label = Label(
            label="󰖪",
            style="margin: 0px 6px 0px 0px; font-size: 16px",
        )
        self.add(self.icon_label)
        invoke_repeater(3000, self.update_status)

    def get_signal(self):
        try:
            output = subprocess.check_output(
                ["nmcli", "-t", "-f", "IN-USE,SIGNAL", "device", "wifi"],
                text=True,
                stderr=subprocess.DEVNULL
            )
            for line in output.splitlines():
                parts = line.split(':')
                if parts[0] == '*':
                    return int(parts[1])
            return None
        except Exception:
            return None

    def update_status(self):
        signal = self.get_signal()
        if signal is None:
            icon = "󰤭"
        elif signal > 75:
            icon = "󰤨"
        elif signal > 50:
            icon = "󰤢"
        elif signal > 25:
            icon = "󰤟"
        else:
            icon = "󰤯"
        self.icon_label.set_label(icon)
        return True

# --- Battery Widget ---
class BatteryWidget(Box):
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.icon_label = Label(
            label="󰁽",
            style="margin: 0px 6px 0px 0px; font-size: 16px",
        )
        self.add(self.icon_label)
        invoke_repeater(5000, self.update_status)

    def get_battery_info(self):
        try:
            battery_path = subprocess.check_output(
                "upower -e | grep BAT",
                shell=True,
                text=True
            ).strip()
            output = subprocess.check_output(
                ["upower", "-i", battery_path],
                text=True
            )
            state_match = re.search(r'state:\s+(\w+)', output)
            perc_match = re.search(r'percentage:\s+(\d+)%', output)
            if state_match and perc_match:
                state = state_match.group(1).lower()
                percentage = int(perc_match.group(1))
                return state, percentage
        except Exception:
            pass
        return "unknown", 0

    def get_battery_icon(self, state, percentage):
        if state == "charging":
            if percentage <= 10:   return "󰢟"
            if percentage <= 20:   return "󰢜"
            if percentage <= 40:   return "󰢝"
            if percentage < 100:   return "󰢞"
            return "󰂅"
        if state == "fully-charged":
            return "󰂅"
        if percentage <= 10:       return "󰁺"
        if percentage <= 20:       return "󰁻"
        if percentage <= 40:       return "󰁽"
        if percentage <= 50:       return "󰁾"
        if percentage <= 60:       return "󰁿"
        if percentage <= 70:       return "󰂀"
        if percentage <= 80:       return "󰂁"
        if percentage <= 90:       return "󰂂"
        return "󰁹"

    def update_status(self):
        state, percentage = self.get_battery_info()
        icon = self.get_battery_icon(state, percentage)
        self.icon_label.set_label(f"{icon} {percentage}%")
        return True
def get_screen_width():
    out = subprocess.check_output(["xrandr"]).decode()
    m = re.search(r"current\s+(\d+)\s+x\s+\d+", out)
    return int(m.group(1)) if m else 1920
# --- Status Bar ---
class StatusBar(Window):
    def __init__(self):
        width=get_screen_width()
        super().__init__(
            title="bar",
            geometry="top",
            type_hint="dock",
            margin="0px",
            size=(width,24),
            visible=False,
            all_visible=False,
        )

        self.date_time = DateTime(name="date-time")

        self.bluetooth_widget = BluetoothWidget()
        self.wifi_widget     = WifiWidget()
        self.battery_widget  = BatteryWidget()

        # Container for end-of-bar widgets
        self.status_container = Box(
            name="widgets-container",
            spacing=4,
            orientation="h",
            children=[
                self.bluetooth_widget,
                self.wifi_widget,
                self.battery_widget,
            ],
        )
        if AUDIO_WIDGET:
            self.status_container.add(VolumeWidget())

        # Assemble bar layout
        self.children = CenterBox(
            name="bar-inner",
            start_children=Box(
                name="start-container",
                spacing=4,
                orientation="h",
                children=[
                    # Add any custom start-side widgets here
                ],
            ),
            center_children=Box(
                name="center-container",
                spacing=4,
                orientation="h",
                children=self.date_time,
            ),
            end_children=Box(
                name="end-container",
                spacing=4,
                orientation="h",
                children=[
                    self.status_container,
                ],
            ),
        )

        self.show_all()

if __name__ == "__main__":
    bar = StatusBar()
    app = Application("bar", bar)
    app.set_stylesheet_from_file(get_relative_path("./style.css"))
    app.run()
