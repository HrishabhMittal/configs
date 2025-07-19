from utils import *

# --- Widget Skeletons ---

class ProfileWidget(Box):
    def __init__(self, **kwargs):
        super().__init__(orientation="v", name="profile", spacing=20, h_align=Gtk.Align.CENTER, v_align=Gtk.Align.CENTER, **kwargs)
        image_path = os.path.expanduser("~/.config/hypr/dashboard/profile.jpeg")
        size = 192
        try:
            pixbuf = circular_pixbuf(image_path, size)
            profile_image = Image(pixbuf=pixbuf, name="profile-pic")
        except Exception as e:
            print("Error loading image:", e)
            profile_image = Label(label="[No Image]", name="profile-pic")
        profile_image.set_halign(Gtk.Align.CENTER)
        self.add(profile_image)
        username_label = Label(label="Hrishabh Mittal", name="profile-username")
        username_label.set_halign(Gtk.Align.CENTER)
        distro_label = Label(label=get_distro_name(), name="distro-name")
        distro_label.set_halign(Gtk.Align.CENTER)
        self.add(username_label)
        self.add(distro_label)
        self.show_all()
class PieWidget(Box):
    def __init__(self, **kwargs):
        super().__init__(orientation="v", name="pie", spacing=20, **kwargs)
        self.add(PieChartWidget("󱛟",0,get_disk_usage))
        self.show_all()

class VolumeWidget(Box):
    def __init__(self, **kwargs):
        super().__init__(orientation="v", name="volume", spacing=20, **kwargs)
        self.add(PieChartWidget("",0,get_volume))
        self.show_all()

class BatteryWidget(Box):
    def __init__(self, **kwargs):
        super().__init__(orientation="v", name="battery", spacing=20, **kwargs)
        self.add(PieChartWidget("󰁹",0,get_battery))
        self.show_all()

class BrightnessWidget(Box):
    def __init__(self, **kwargs):
        super().__init__(orientation="v", name="brightness", spacing=20, **kwargs)
        self.add(PieChartWidget("󰃠",0,get_brightness))
        self.show_all()

class TimeWidget(Box):
    def __init__(self, **kwargs):
        super().__init__(orientation="v", name="time", spacing=20, **kwargs)
        self.add(Label(label="TimeWidget"))
        self.show_all()

class WeatherWidget(Box):
    def __init__(self, **kwargs):
        super().__init__(orientation="v", name="weather", spacing=20, **kwargs)
        self.add(Label(label="WeatherWidget"))
        self.show_all()

class QuotesWidget(Box):
    def __init__(self, **kwargs):
        super().__init__(orientation="v", name="quotes", spacing=20, **kwargs)
        self.quote_label = Label(label="", name="quotes-text")
        self.add(self.quote_label)
        self.update_quote()
        self.show_all()
    def update_quote(self):
        self.quote_label.set_label(get_quote())
        return True
class TodoWidget(Box):
    def __init__(self, **kwargs):
        super().__init__(orientation="v", name="todo", spacing=20, **kwargs)
        self.add(Label(label="TodoWidget"))
        self.show_all()

class SidebarWidget(Box):
    def __init__(self, **kwargs):
        super().__init__(orientation="v", name="sidebar", spacing=20, **kwargs)
        self.add(Label(label="SidebarWidget"))
        self.show_all()


# --- Dashboard Layout ---

class Dashboard(Window):
    def __init__(self):
        super().__init__(
            name="dashboard",
            layer="top",
            anchor="center",
            margin="20px 20px 20px 20px",
            exclusivity="auto",
            visible=False,
            all_visible=False,
            size=[2000, 1000],
        )

        left_col = Box(
            orientation="v",
            spacing=20,
            children=[
                ProfileWidget(),
                QuotesWidget(),
            ]
        )

        # Center top: Four circular widgets in a grid
        four_together = Box(
            orientation="h",
            spacing=20,
            children=[
                Box(
                    orientation="v",
                    spacing=20,
                    children=[
                        PieWidget(),
                        BatteryWidget(),
                    ]
                ),
                Box(
                    orientation="v",
                    spacing=20,
                    children=[
                        VolumeWidget(),
                        BrightnessWidget(),
                    ]
                ),
            ]
        )
        center_top = Box(orientation='h',spacing=20,children=[
                Box(orientation='v',spacing=20,children=[
                        four_together,
                        TimeWidget(),
                    ]
                ),
                TodoWidget(),
            ]
        )

        # Center bottom: Three panels (Quotes, Weather, Todo)
        center_bottom = Box(
            orientation="h",
            spacing=20,
            children=[
                WeatherWidget()
            ]
        )

        # Center column: Stack everything vertically
        center_col = Box(
            orientation="v",
            spacing=20,
            children=[
                center_top,
                center_bottom,
            ]
        )

        # Right: Sidebar
        right_col = SidebarWidget()

        # Main horizontal layout: left, center, right
        main_layout = Box(
            orientation="h",
            spacing=40,
            children=[
                left_col,
                center_col,
                right_col,
            ]
        )

        self.main_container = Box(
            orientation="v",
            spacing=20,
            h_align=Gtk.Align.CENTER,
            v_align=Gtk.Align.CENTER,
            children=[main_layout]
        )

        self.children = self.main_container
        self.show_all()
if __name__ == "__main__":
    dashboard = Dashboard()
    dashboard.set_title("dashboard")
    app = Application("dashboard", dashboard)
    app.set_stylesheet_from_file(get_relative_path("./style.css"))
    app.run()
