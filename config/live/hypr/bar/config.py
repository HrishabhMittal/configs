
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
# from fabric.system_tray.widgets import SystemTray
from fabric.widgets.wayland import WaylandWindow as Window
from fabric.hyprland.widgets import Language, ActiveWindow, Workspaces, WorkspaceButton
from fabric.utils import (
    FormattedString,
    bulk_replace,
    invoke_repeater,
    get_relative_path,
    math,
)

AUDIO_WIDGET = True

# --- Volume Widget Icons ---
volume_icons = {
    'muted': '󰝟',    # Muted
    'low':   '󰕿',    # Low
    'medium':'󰖀',    # Medium
    'high':  '󰕾',    # High
}
brightness=""


def get_brightness_icon(b):
    b-=0.1
    if b<0:
        b=0
    b/=100.0
    b*=len(brightness)
    return brightness[math.floor(b)] 
def get_volume_icon(volume, muted):
    if muted or volume == 0:
        return volume_icons['muted']
    elif volume <= 30:
        return volume_icons['low']
    elif volume <= 70:
        return volume_icons['medium']
    else:
        return volume_icons['high']

class BrightnessWidget(Box):
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
        self.update_brightness()
        invoke_repeater(2000, self.update_brightness)  # Periodically update

    def on_scroll(self, _, event):
        step = 2
        if event.direction == 0:
            subprocess.run(["brightnessctl", "s", f"+{step}%"])
        elif event.direction == 1:
            subprocess.run(["brightnessctl", "s", f"{step}%-"])
        self.update_brightness()

    def get_brightness_status(self):
        try:
            output = subprocess.check_output(
                ["brightnessctl","g"],
                stderr=subprocess.STDOUT,
                text=True
            )
            output2 = subprocess.check_output(
                ["brightnessctl","m"],
                stderr=subprocess.STDOUT,
                text=True
            )
            output=int(output)*100//int(output2);
            return output
        except Exception:
            return True, 0
    def update_brightness(self):
        volume = self.get_brightness_status()
        icon = get_brightness_icon(volume)
        self.icon_label.set_label(icon)



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
        invoke_repeater(2000, self.update_volume)  # Periodically update

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
            label="󰂯",  # Default: disconnected
            style="margin: 0px 6px 0px 0px; font-size: 16px"
        )
        self.add(self.icon_label)
        invoke_repeater(5000, self.update_status)

    def update_status(self):
        try:
            # Check if any device is connected
            output = subprocess.check_output(
                ['bluetoothctl', 'devices', 'Connected'],
                text=True,
                stderr=subprocess.DEVNULL
            )
            connected = (output!="")
        except Exception:
            connected = False
        self.icon_label.set_label("󰂰" if connected else "󰂯")  # Connected/Disconnected
        return True

# --- WiFi Widget ---
class WifiWidget(Box):
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.icon_label = Label(
            label="󰖪",  # Default: disconnected/off icon
            style="margin: 0px 6px 0px 0px; font-size: 16px"
        )
        self.add(self.icon_label)
        invoke_repeater(3000, self.update_status)

    def get_signal(self):
        try:
            # Get active WiFi connection info
            output = subprocess.check_output(
                ["nmcli", "-t", "-f", "IN-USE,SIGNAL", "device", "wifi"],
                text=True,
                stderr=subprocess.DEVNULL
            )
            # Parse lines where ACTIVE=yes and TYPE=wifi
            for line in output.split('\n'):
                parts = line.split(':')
                if len(parts) < 2:
                    continue
                inuse, signal = parts[0], parts[1]
                if inuse == '*':
                    return int(signal)
            return None
        except Exception:
            return None

    def update_status(self):
        signal = self.get_signal()
        # Icon mapping based on signal strength (0-100)
        if signal is None:
            icon = "󰤭"  # WiFi off/disconnected
        elif signal > 75:
            icon = "󰤨"  # Excellent
        elif signal > 50:
            icon = "󰤢"  # Good
        elif signal > 25:
            icon = "󰤟"  # Fair
        else:
            icon = "󰤯"  # Weak
        self.icon_label.set_label(icon)
        return True

# --- Battery Widget ---
class BatteryWidget(Box):
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.icon_label = Label(
            label="󰁽",  # Default to battery-good
            style="margin: 0px 6px 0px 0px; font-size: 16px",
        )
        self.add(self.icon_label)
        invoke_repeater(5000, self.update_status)

    def get_battery_info(self):
        try:
            battery_path = subprocess.check_output(
                "upower -e | grep BAT", shell=True, text=True
            ).strip()
            output = subprocess.check_output(
                ["upower", "-i", battery_path], text=True
            )
            state_match = re.search(r'state:\s+(\w+)', output)
            perc_match = re.search(r'percentage:\s+(\d+)%', output)
            if state_match and perc_match:
                state = state_match.group(1).lower()
                percentage = int(perc_match.group(1))
                return state, percentage
            else:
                return "unknown", 0
        except Exception as e:
            # print(f"Battery error: {e}")
            return "unknown", 0

    def update_status(self):
        state, percentage = self.get_battery_info()
        icon = self.get_battery_icon(state, percentage)
        self.icon_label.set_label(f"{icon} {percentage}%")
        return True

    def get_battery_icon(self, state, percentage):
        # Nerd Font battery icons mapping
        if state == "charging":
            if percentage <= 10: return "󰢟"  # empty-charging
            elif percentage <= 20: return "󰢜"  # caution-charging
            elif percentage <= 40: return "󰢝"  # low-charging
            elif percentage < 100: return "󰢞"  # good-charging
            else: return "󰂅"       # full-charged
        elif state == "fully-charged":
            return "󰂅"
        else:
            if percentage <= 10: return "󰁺"  # empty
            elif percentage <= 20: return "󰁻"  # caution
            elif percentage <= 40: return "󰁽"  # low
            elif percentage <=50: return "󰁾"
            elif percentage <=60: return "󰁿"
            elif percentage <=70: return "󰂀"
            elif percentage <=80: return "󰂁"
            elif percentage <=90: return "󰂂"
            elif percentage < 100: return "󰂂"  # good
            else: return "󰁹"        # full

# --- Status Bar ---
class StatusBar(Window):
    def __init__(self):
        super().__init__(
            name="bar",
            layer="top",
            anchor="left top right",
            margin="0px 0px 0px 0px",
            exclusivity="auto",
            visible=False,
            all_visible=False,
        )
        self.workspaces = Workspaces(
            name="workspaces",
            spacing=4,
            buttons_factory=lambda ws_id: WorkspaceButton(id=ws_id, label=None),
        )
        self.active_window = ActiveWindow(name="hyprland-window")
        self.language = Language(
            formatter=FormattedString(
                "{replace_lang(language)}",
                replace_lang=lambda lang: bulk_replace(
                    lang,
                    (r".*Eng.*", r".*Ar.*"),
                    ("ENG", "ARA"),
                    regex=True,
                ),
            ),
            name="hyprland-window",
        )
        self.date_time = DateTime(name="date-time")
#        self.system_tray = SystemTray(name="system-tray", spacing=4)

        self.bluetooth_widget = BluetoothWidget()
        self.wifi_widget = WifiWidget()
        self.brightness_widget = BrightnessWidget()
        self.battery_widget = BatteryWidget()
        self.status_container = Box(
            name="widgets-container",
            spacing=4,
            orientation="h",
            children=[
                self.bluetooth_widget,
                self.wifi_widget,
                self.battery_widget,
                self.brightness_widget,
            ],
        )
        if AUDIO_WIDGET:
            self.status_container.add(VolumeWidget())

        self.children = CenterBox(
            name="bar-inner",
            start_children=Box(
                name="start-container",
                spacing=4,
                orientation="h",
                children=[
                    self.workspaces,
                    self.active_window
                ]
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
#                    self.system_tray,
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
