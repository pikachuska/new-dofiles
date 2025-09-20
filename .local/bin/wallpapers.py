#!/usr/bin/env python3
import sys, os, random, serial, serial.tools.list_ports
from PyQt5.QtWidgets import QApplication, QGraphicsScene, QGraphicsView, QGraphicsPixmapItem
from PyQt5.QtGui import QPixmap, QColor
from PyQt5.QtCore import Qt
from subprocess import call
import json

WALLS_DIR = os.path.expanduser("~/Изображения/wallpapers")

# === Поиск COM-порта ===
def find_serial_port():
    ports = serial.tools.list_ports.comports()
    for port in ports:
        if "ttyUSB" in port.device or "ttyACM" in port.device:
            return port.device
    return None

SERIAL_PORT = find_serial_port()
ser = None
if SERIAL_PORT:
    try:
        ser = serial.Serial(SERIAL_PORT, 9600)
        print(f"[OK] Подключено к {SERIAL_PORT}")
    except Exception as e:
        print(f"[Ошибка] Не удалось открыть {SERIAL_PORT}: {e}")
else:
    print("[!] Не найдено подходящее устройство для подсветки.")


class WallpaperSelector(QGraphicsView):
    def __init__(self):
        super().__init__()

        # Список картинок
        self.images = []
        for root, _, files in os.walk(WALLS_DIR):
            for file in files:
                if file.lower().endswith(('.png', '.jpg', '.jpeg')):
                    self.images.append(os.path.join(root, file))
        if not self.images:
            print("Нет картинок!")
            sys.exit(1)

        self.current_index = random.randint(0, len(self.images)-1)

        # Сцена и пиксмап
        self.scene = QGraphicsScene()
        self.setScene(self.scene)
        self.pixmap_item = QGraphicsPixmapItem()
        self.scene.addItem(self.pixmap_item)

        # Настройки окна
        self.setBackgroundBrush(QColor(18,18,18))
        self.setWindowTitle("Wallpaper Selector")
        self.resize(800, 600)  # оконный режим
        self.setHorizontalScrollBarPolicy(Qt.ScrollBarAlwaysOff)
        self.setVerticalScrollBarPolicy(Qt.ScrollBarAlwaysOff)
        self.show()

        self.update_image()

    def update_image(self):
        pix = QPixmap(self.images[self.current_index])
        scaled_pix = pix.scaled(
            self.width(), self.height(),
            Qt.KeepAspectRatio,
            Qt.SmoothTransformation
        )
        self.pixmap_item.setPixmap(scaled_pix)
        # Центруем
        self.pixmap_item.setPos(
            (self.width() - scaled_pix.width()) / 2,
            (self.height() - scaled_pix.height()) / 2
        )

    def mousePressEvent(self, event):
        if event.button() == Qt.LeftButton:
            if event.pos().x() < self.width() / 2:
                self.prev_wallpaper()
            else:
                self.next_wallpaper()

    def keyPressEvent(self, event):
        if event.key() == Qt.Key_Left:
            self.prev_wallpaper()
        elif event.key() == Qt.Key_Right:
            self.next_wallpaper()
        elif event.key() in (Qt.Key_Return, Qt.Key_Enter):
            self.apply_wallpaper()
        elif event.key() == Qt.Key_Escape:
            self.close()

    def next_wallpaper(self):
        self.current_index = (self.current_index + 1) % len(self.images)
        self.update_image()

    def prev_wallpaper(self):
        self.current_index = (self.current_index - 1) % len(self.images)
        self.update_image()

    def apply_wallpaper(self):
        img = self.images[self.current_index]
        # Применяем через swww
        call(["swww", "img", img])
        # Применяем через pywal
        call(["wal", "-i", img])

        # Читаем палитру pywal
        colors_file = os.path.expanduser("~/.cache/wal/colors.json")
        if os.path.exists(colors_file):
            with open(colors_file, "r") as f:
                data = json.load(f)
                color1 = data["colors"]["color1"]  # hex вида "#rrggbb"
                r = int(color1[1:3], 16)
                g = int(color1[3:5], 16)
                b = int(color1[5:7], 16)
                print(f"[+] Подсветка: {r},{g},{b}")
                if ser:
                    ser.write(bytes([r, g, b]))

    def resizeEvent(self, event):
        self.update_image()


if __name__ == "__main__":
    app = QApplication(sys.argv)
    win = WallpaperSelector()
    win.show()
    sys.exit(app.exec_())
