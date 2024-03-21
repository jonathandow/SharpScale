from bluetooth import *
import time
from pybleno import Bleno, BlenoPrimaryService, Characteristic


SERVICE_UUID = '77670a58-1cb4-4652-ae7d-2492776d303d'
CHARACTERISTIC_UUID = '13092a53-7511-4ae0-8c9f-97c84cfb5d9a'

DEVICE_NAME = "RaspberryPi5_BLE"

def setup_service():
    try:
        print("1")
        server_sock = BluetoothSocket(RFCOMM)
        print("2")
        server_sock.bind(("", PORT_ANY))
        print("3")
        server_sock.listen(1)
        print("4")

        advertise_service(
            server_sock,
            DEVICE_NAME,
            service_id=SERVICE_UUID,
            service_classes=[SERVICE_UUID, SERIAL_PORT_CLASS],
            profiles=[SERIAL_PORT_PROFILE],
        )
        print("5")
        print("Waiting for connection...")
        client_sock, address = server_sock.accept()
        print(f"Accepted connection from {address}")

        return client_sock, server_sock

    except btcommon.BluetoothError as e:
        print("Bluetooth error:", e)
        return None, None

if __name__ == "__main__":
    print("Main 1")
    client_sock, server_sock = setup_service()
    print("Main 2")
    if client_sock is not None:
        try:
            while True:
                data = "Hello, iOS!"
                client_sock.send(data.encode())
                print(f"Sent data: {data}")

                time.sleep(1)

        except KeyboardInterrupt:
            print("Peripheral stopped")

        finally:
            client_sock.close()
            server_sock.close()
