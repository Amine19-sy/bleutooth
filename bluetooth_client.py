#!/usr/bin/env python3

import bluetooth

# Adresse MAC de l'appareil Raspberry Pi ou autre périphérique Bluetooth
# Remplace ceci si nécessaire par l'adresse exacte de ta Pi
target_name = "raspberrypi243"
ssid = "amine"
password = "amine"
message = f"{ssid},{password}\n"

def find_target_address():
    print("🔍 Recherche des périphériques Bluetooth...")
    nearby_devices = bluetooth.discover_devices(duration=8, lookup_names=True)

    for addr, name in nearby_devices:
        if target_name.lower() in name.lower():
            print(f"✅ Appareil trouvé : {name} ({addr})")
            return addr

    print("❌ Appareil non trouvé.")
    return None

def send_wifi_credentials(target_address):
    port = 1  # canal RFCOMM
    sock = bluetooth.BluetoothSocket(bluetooth.RFCOMM)

    try:
        print(f"🔗 Connexion à {target_address}:{port} ...")
        sock.connect((target_address, port))
        print("📡 Envoi des identifiants Wi-Fi...")
        sock.send(message)
        response = sock.recv(1024).decode()
        print(f"📬 Réponse : {response}")
    except Exception as e:
        print(f"❌ Erreur : {e}")
    finally:
        sock.close()
        print("🔌 Connexion fermée.")

if __name__ == "__main__":
    address = find_target_address()
    if address:
        send_wifi_credentials(address)

