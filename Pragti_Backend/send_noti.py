import ctypes
from winotify import Notification, audio
import winreg
import os
import sys


def register_app_icon(app_id, icon_path):
    """Register app icon for Windows notifications"""
    icon_path = os.path.abspath(icon_path)
    reg_path = r"Software\Classes\AppUserModelId\{}".format(app_id)
    
    try:
        key = winreg.CreateKey(winreg.HKEY_CURRENT_USER, reg_path)
        winreg.SetValueEx(key, "IconUri", 0, winreg.REG_SZ, icon_path)
        winreg.SetValueEx(key, "DisplayName", 0, winreg.REG_SZ, "My App")
        winreg.CloseKey(key)
    except Exception as e:
        print(f"Error registering icon: {e}")


if getattr(sys, 'frozen', False):
    base_path = sys._MEIPASS
else:
    base_path = os.path.dirname(os.path.abspath(__file__))

icon_path = os.path.join(base_path, "assets/icon.png")

register_app_icon("Pragti",icon_path)

def register_app_icon_call():
    register_app_icon("Pragti",icon_path)
# pyinstaller --onefile --icon=icon.ico --add-data "icon.png;." main.py

def show_ai_notification(title:str,content:str):
    icon_path = os.path.join(base_path, "assets/icon.png")

    toast = Notification(
        app_id="Pragti",
        title=f"{title}",
        msg=f"{content}",
        icon=icon_path,
        duration="long"
    )
    toast.set_audio(audio.Default, loop=False)
    toast.add_actions(label="I Will Work Now", launch="https://example.com")
    toast.add_actions(label="Dismiss", launch= "http://127.0.0.1:8000/dismiss_notification")

    toast.show()



def dismiss_popup(title:str,message:str):
    def show_popup(title, message):
        ctypes.windll.user32.MessageBoxW(0, message, title, 0x40 | 0x1000)

    show_popup(title, message)


def show_notification(title:str,content:str):
    toast = Notification(
        app_id="Pragti",
        title=f"{title}",
        msg=f"{content}",
        duration="long"
    )
    toast.set_audio(audio.Default, loop=False)
    toast.show()